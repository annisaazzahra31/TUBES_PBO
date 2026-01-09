/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlet;

import store.DataSplit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 *
 * @author alishadenahutomo
 */

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private final DataSplit ds = new DataSplit();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("groupsCount", ds.getGroups().size());
        req.setAttribute("active", "dashboard");
        req.getRequestDispatcher("/WEB-INF/dashboard.jsp").forward(req, resp);
    }
}
