/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Ann
 */
public class Group extends BaseEntity {
    private String name;
    private List<User> members = new ArrayList<>();
    private List<Transaction> transactions = new ArrayList<>();

    public Group(String id, String name) {
        super(id);
        this.name = name;
    }

    public String getName() { return name; }
    public List<User> getMembers() { return members; }

    public void addMember(User u) { members.add(u); }
    public void addTransaction(Transaction t) { transactions.add(t); }

    public List<Transaction> getTransactions() {
        return transactions;
    }
}



