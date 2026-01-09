/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author mutti
 */
public class User extends BaseEntity{
    private String name;
    private double balance;

    public User(String id, String name) {
        super(id);
        this.name = name;
        this.balance = 0.0;
    }

    public String getName() { return name; }
    public double getBalance() { return balance; }

    public void addBalance(double amount) {
        this.balance += amount;
    }
}
