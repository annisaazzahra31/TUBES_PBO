/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlet;

import model.Group;
import model.User;
import service.DebtCalculator;
import store.DataSplit;

import java.io.IOException;
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
@WebServlet("/summary")
public class SummaryServlet extends HttpServlet {

    private final DataSplit ds = new DataSplit();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String gid = req.getParameter("groupId");

        if (gid == null || gid.isBlank()) {
            Object last = req.getSession().getAttribute("activeGroupId");
            if (last != null) {
                gid = last.toString();
            }
        }

        Group g = null;
        if (gid != null && !gid.isBlank()) {
            g = ds.findGroup(gid);
        }

        if (g == null) {
            var all = ds.getGroups();
            if (!all.isEmpty()) {
                g = all.get(0);
                gid = g.getId();
            }
        }

        req.setAttribute("group", g);

        if (g != null) {
            DebtCalculator calc = new DebtCalculator();
            Map<User, Double> balances = calc.calculateNetBalance(g);
            req.setAttribute("balances", balances);
            req.getSession().setAttribute("activeGroupId", g.getId());
        }

        req.setAttribute("active", "summary");
        req.getRequestDispatcher("/WEB-INF/summary.jsp").forward(req, resp);
    }
}
