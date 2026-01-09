/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package strategy;

import model.User;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author amalia
 */
public class EvenSplitStrategy implements ISplitStrategy{
    @Override
    public Map<User, Double> calculateShares(double totalAmount, List<User> participants) {
        Map<User, Double> shares = new HashMap<>();
        if (participants == null || participants.isEmpty()) return shares;

        double each = totalAmount / participants.size();
        for (User u : participants) shares.put(u, each);
        return shares;
    }
}
