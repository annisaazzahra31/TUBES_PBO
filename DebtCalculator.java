/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import model.Group;
import model.Transaction;
import model.User;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author mutti
 */
public class DebtCalculator {
    public Map<User, Double> calculateNetBalance(Group group) {
        Map<User, Double> balances = new HashMap<>();
        if (group == null) return balances;

        for (User u : group.getMembers()) {
            balances.put(u, 0.0);
        }

        List<Transaction> txs = group.getTransactions();
        if (txs == null) return balances;

        for (Transaction tx : txs) {
            if (tx == null) continue;

            Map<User, Double> shares = tx.executeSplit();

            User payer = tx.getPayer();

            balances.put(payer, balances.getOrDefault(payer, 0.0) + tx.getTotalAmount());

            if (shares != null) {
                for (Map.Entry<User, Double> e : shares.entrySet()) {
                    User u = e.getKey();
                    Double share = e.getValue();
                    if (u == null || share == null) continue;

                    balances.put(u, balances.getOrDefault(u, 0.0) - share);
                }
            }
        }

        return balances;
    }

    public String printSummary(Map<User, Double> balances) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<User, Double> e : balances.entrySet()) {
            String status = (e.getValue() >= 0) ? "piutang" : "utang";
            sb.append(e.getKey().getName())
              .append(" : ")
              .append(String.format("%.2f", Math.abs(e.getValue())))
              .append(" (").append(status).append(")\n");
        }
        return sb.toString();
    }
}
