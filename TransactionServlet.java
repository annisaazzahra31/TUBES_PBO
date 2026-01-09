package servlet;

import model.Group;
import model.Transaction;
import model.User;
import store.DataSplit;
import strategy.EvenSplitStrategy;
import strategy.ISplitStrategy;
import strategy.UnevenSplitStrategy;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author mutti
 */
@WebServlet("/transaction")
public class TransactionServlet extends HttpServlet {

    private final DataSplit ds = new DataSplit();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        List<Group> groups = ds.getGroups();
        req.setAttribute("groups", groups);

        String gid = req.getParameter("groupId");
        Group selected = null;

        if (gid != null && !gid.isBlank()) {
            selected = ds.findGroup(gid);
        }
        if (selected == null && !groups.isEmpty()) {
            selected = ds.findGroup(groups.get(0).getId());
        }

        req.setAttribute("selectedGroup", selected);
        req.setAttribute("members", (selected == null) ? new ArrayList<User>() : selected.getMembers());

        if (selected != null) {
            req.getSession().setAttribute("activeGroupId", selected.getId());
        }

        RequestDispatcher rd = req.getRequestDispatcher("/WEB-INF/transaction_add.jsp");
        rd.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String gid = req.getParameter("groupId");
        String tid = req.getParameter("txId");
        String payerId = req.getParameter("payerId");
        String totalStr = req.getParameter("totalAmount");
        String splitType = req.getParameter("splitType");

        if (gid == null || gid.isBlank() || tid == null || tid.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/transaction");
            return;
        }

        Group g = ds.findGroup(gid);
        if (g == null) {
            resp.sendRedirect(req.getContextPath() + "/transaction");
            return;
        }

        String[] participantIdsArr = req.getParameterValues("participantIds");
        List<User> participants = new ArrayList<>();
        List<String> participantIds = new ArrayList<>();

        if (participantIdsArr != null) {
            for (String pid : participantIdsArr) {
                if (pid == null || pid.isBlank()) continue;
                User u = ds.findUserInGroup(gid, pid);
                if (u != null) {
                    participants.add(u);
                    participantIds.add(pid);
                }
            }
        }

        User payer = ds.findUserInGroup(gid, payerId);

        if (payer == null || participants.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/transaction?groupId=" + gid);
            return;
        }

        ISplitStrategy strategy;
        double total;

        if ("UNEVEN".equalsIgnoreCase(splitType)) {

            String feeMode = req.getParameter("feeMode");
            if (feeMode == null || feeMode.isBlank()) feeMode = "EQUAL";

            String[] itemUsers = req.getParameterValues("item_user");
            String[] itemAmts = req.getParameterValues("item_amount");

            Map<String, Double> subtotalByUserId = new HashMap<>();
            for (User u : participants) subtotalByUserId.put(u.getId(), 0.0);

            if (itemUsers != null && itemAmts != null) {
                int n = Math.min(itemUsers.length, itemAmts.length);
                for (int i = 0; i < n; i++) {
                    String uid = itemUsers[i];
                    double amt = 0.0;
                    try { amt = Double.parseDouble(itemAmts[i]); } catch (Exception ignored) {}
                    if (uid == null || uid.isBlank() || amt <= 0) continue;
                    if (!subtotalByUserId.containsKey(uid)) continue;
                    subtotalByUserId.put(uid, subtotalByUserId.get(uid) + amt);
                }
            }

            double subtotalAll = 0.0;
            for (User u : participants) subtotalAll += subtotalByUserId.getOrDefault(u.getId(), 0.0);

            if (subtotalAll <= 0) {
                resp.sendRedirect(req.getContextPath() + "/transaction?groupId=" + gid);
                return;
            }

            String[] feeTypes = req.getParameterValues("fee_type");
            String[] feeVals = req.getParameterValues("fee_value");

            double feeFixed = 0.0;
            double feePercent = 0.0;

            if (feeTypes != null && feeVals != null) {
                int n = Math.min(feeTypes.length, feeVals.length);
                for (int i = 0; i < n; i++) {
                    String t = feeTypes[i];
                    double v = 0.0;
                    try { v = Double.parseDouble(feeVals[i]); } catch (Exception ignored) {}
                    if (v <= 0) continue;
                    if ("FIXED".equalsIgnoreCase(t)) feeFixed += v;
                    else feePercent += (subtotalAll * (v / 100.0));
                }
            }

            double feeGlobal = feeFixed + feePercent;

            Map<User, Double> customShares = new HashMap<>();

            if ("PROP".equalsIgnoreCase(feeMode)) {
                for (User u : participants) {
                    double s = subtotalByUserId.getOrDefault(u.getId(), 0.0);
                    double p = subtotalAll > 0 ? (s / subtotalAll) : (1.0 / participants.size());
                    customShares.put(u, s + (feeGlobal * p));
                }
            } else {
                double eachFee = participants.isEmpty() ? 0.0 : (feeGlobal / participants.size());
                for (User u : participants) {
                    double s = subtotalByUserId.getOrDefault(u.getId(), 0.0);
                    customShares.put(u, s + eachFee);
                }
            }

            total = 0.0;
            for (User u : participants) total += customShares.getOrDefault(u, 0.0);

            if (total <= 0) {
                resp.sendRedirect(req.getContextPath() + "/transaction?groupId=" + gid);
                return;
            }

            ds.addTransaction(tid.trim(), gid, payer.getId(), total, "UNEVEN", participantIds);
            ds.saveUnevenShares(tid.trim(), customShares);

            strategy = new UnevenSplitStrategy(customShares);

        } else {

            total = 0.0;
            try { total = Double.parseDouble(totalStr); } catch (Exception ignored) {}

            if (total <= 0) {
                resp.sendRedirect(req.getContextPath() + "/transaction?groupId=" + gid);
                return;
            }

            ds.addTransaction(tid.trim(), gid, payer.getId(), total, "EVEN", participantIds);

            strategy = new EvenSplitStrategy();
        }

        Transaction tx = new Transaction(tid.trim(), payer, total, participants, strategy);

        resp.sendRedirect(req.getContextPath() + "/summary?groupId=" + gid);
    }
}
