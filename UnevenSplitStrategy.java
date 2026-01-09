/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package strategy;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.User;

/**
 *
 * @author amalia
 */
public class UnevenSplitStrategy implements ISplitStrategy{
    private Map<User, Double> customAmounts;

    public UnevenSplitStrategy(Map<User, Double> customAmounts) {
        this.customAmounts = (customAmounts == null) ? new HashMap<>() : customAmounts;
    }

    @Override
    public Map<User, Double> calculateShares(double totalAmount, List<User> participants) {
        Map<User, Double> shares = new HashMap<>();
        if (participants == null) return shares;

        for (User u : participants) {
            shares.put(u, customAmounts.getOrDefault(u, 0.0));
        }
        return shares;
    }
}
