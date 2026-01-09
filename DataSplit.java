/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package store;

import model.Group;
import model.User;
import model.Transaction;
import strategy.EvenSplitStrategy;
import strategy.ISplitStrategy;
import strategy.UnevenSplitStrategy;

import java.sql.*;
import java.util.*;

/**
 *
 * @author edelweiss
 */
public class DataSplit {

    public List<Group> getGroups() {
        List<Group> list = new ArrayList<>();
        String sql = "SELECT id, name FROM groups ORDER BY id";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Group(rs.getString("id"), rs.getString("name")));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    public void addGroup(String id, String name) {
        String sql = "INSERT INTO groups(id, name) VALUES(?, ?)";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public Group findGroup(String gid) {
        String sql = "SELECT id, name FROM groups WHERE id=?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, gid);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Group g = new Group(rs.getString("id"), rs.getString("name"));
                g.getMembers().addAll(getMembers(gid));
                g.getTransactions().addAll(getTransactionsWithParticipants(gid));
                return g;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public List<User> getMembers(String gid) {
        List<User> members = new ArrayList<>();
        String sql = "SELECT u.id, u.name " +
                     "FROM group_members gm JOIN users u ON u.id = gm.user_id " +
                     "WHERE gm.group_id=? ORDER BY u.id";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, gid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    members.add(new User(rs.getString("id"), rs.getString("name")));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return members;
    }

    public void addMember(String gid, String uid, String uname) {
        try (Connection c = DB.getConnection()) {
            c.setAutoCommit(false);

            try (PreparedStatement up = c.prepareStatement("INSERT IGNORE INTO users(id,name) VALUES(?,?)")) {
                up.setString(1, uid);
                up.setString(2, uname);
                up.executeUpdate();
            }

            try (PreparedStatement gm = c.prepareStatement("INSERT INTO group_members(group_id,user_id) VALUES(?,?)")) {
                gm.setString(1, gid);
                gm.setString(2, uid);
                gm.executeUpdate();
            }

            c.commit();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public User findUserInGroup(String gid, String uid) {
        String sql = "SELECT u.id, u.name " +
                     "FROM group_members gm JOIN users u ON u.id=gm.user_id " +
                     "WHERE gm.group_id=? AND gm.user_id=?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, gid);
            ps.setString(2, uid);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new User(rs.getString("id"), rs.getString("name"));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private boolean transactionExists(String tid) {
        String sql = "SELECT 1 FROM transactions WHERE id=? LIMIT 1";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, tid);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void addTransaction(String tid, String gid, String payerId, double total, String splitType, List<String> participantIds) {
        if (transactionExists(tid)) {
            throw new RuntimeException("ID transaksi sudah dipakai: " + tid);
        }

        try (Connection c = DB.getConnection()) {
            c.setAutoCommit(false);

            try (PreparedStatement tx = c.prepareStatement(
                    "INSERT INTO transactions(id, group_id, payer_id, total_amount, split_type) VALUES(?,?,?,?,?)")) {
                tx.setString(1, tid);
                tx.setString(2, gid);
                tx.setString(3, payerId);
                tx.setBigDecimal(4, java.math.BigDecimal.valueOf(total));
                tx.setString(5, splitType);
                tx.executeUpdate();
            }

            try (PreparedStatement tp = c.prepareStatement(
                    "INSERT INTO transaction_participants(tx_id, user_id) VALUES(?, ?)")) {
                for (String uid : participantIds) {
                    tp.setString(1, tid);
                    tp.setString(2, uid);
                    tp.addBatch();
                }
                tp.executeBatch();
            }

            c.commit();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private List<Transaction> getTransactionsWithParticipants(String gid) {
        List<Transaction> list = new ArrayList<>();

        String sql = "SELECT t.id, t.total_amount, t.split_type, u.id AS payer_id, u.name AS payer_name " +
                     "FROM transactions t JOIN users u ON u.id=t.payer_id " +
                     "WHERE t.group_id=? ORDER BY t.created_at DESC";

        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, gid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String txId = rs.getString("id");
                    double total = rs.getBigDecimal("total_amount").doubleValue();
                    String type = rs.getString("split_type");

                    User payer = new User(rs.getString("payer_id"), rs.getString("payer_name"));
                    List<User> participants = getParticipants(txId);

                    ISplitStrategy strategy;
                    if ("UNEVEN".equalsIgnoreCase(type)) {
                        Map<String, Double> dbShares = getUnevenShares(txId);
                        Map<User, Double> custom = new HashMap<>();
                        for (User u : participants) {
                            custom.put(u, dbShares.getOrDefault(u.getId(), 0.0));
                        }
                        strategy = new UnevenSplitStrategy(custom);
                    } else {
                        strategy = new EvenSplitStrategy();
                    }

                    list.add(new Transaction(txId, payer, total, participants, strategy));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return list;
    }

    private List<User> getParticipants(String txId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.name " +
                     "FROM transaction_participants tp JOIN users u ON u.id=tp.user_id " +
                     "WHERE tp.tx_id=? ORDER BY u.id";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, txId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new User(rs.getString("id"), rs.getString("name")));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    public void saveUnevenShares(String txId, Map<User, Double> shares) {
        String del = "DELETE FROM transaction_shares WHERE tx_id=?";
        String ins = "INSERT INTO transaction_shares(tx_id, user_id, share_amount) VALUES(?,?,?)";

        try (Connection c = DB.getConnection()) {
            c.setAutoCommit(false);

            try (PreparedStatement ps = c.prepareStatement(del)) {
                ps.setString(1, txId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = c.prepareStatement(ins)) {
                for (Map.Entry<User, Double> e : shares.entrySet()) {
                    ps.setString(1, txId);
                    ps.setString(2, e.getKey().getId());
                    ps.setBigDecimal(3, java.math.BigDecimal.valueOf(e.getValue()));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            c.commit();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public Map<String, Double> getUnevenShares(String txId) {
        Map<String, Double> map = new HashMap<>();
        String sql = "SELECT user_id, share_amount FROM transaction_shares WHERE tx_id=?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, txId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("user_id"), rs.getBigDecimal("share_amount").doubleValue());
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return map;
    }
}

