/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.List;
import java.util.Map;
import strategy.ISplitStrategy;

/**
 *
 * @author mutti
 */
public class Transaction extends BaseEntity{
    private final User payer;
    private final double totalAmount;
    private final List<User> participants;
    private final ISplitStrategy strategy;

    public Transaction(String id, User payer, double totalAmount, List<User> participants, ISplitStrategy strategy) {
        super(id);
        this.payer = payer;
        this.totalAmount = totalAmount;
        this.participants = participants;
        this.strategy = strategy;
    }

    public Map<User, Double> executeSplit() {
        return strategy.calculateShares(totalAmount, participants);
    }

    public User getPayer() { return payer; }
    public double getTotalAmount() { return totalAmount; }
    public List<User> getParticipants() { return participants; }
}
