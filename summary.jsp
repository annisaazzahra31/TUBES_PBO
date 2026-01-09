<%-- 
    Document   : summary
    Created on : 25 Dec 2025, 21.40.21
    Author     : alishadenahutomo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.*"%>
<%--@ include file="partials/navbar.jsp" --%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Ringkasan</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>
  <div class="topbar">
    <div class="brand"><div class="logo">S</div><div><div class="brand-title">SplitIt</div><div class="brand-sub">Summary</div></div></div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">← Home</a>
      <a class="nav" href="<%=request.getContextPath()%>/groups">Manajemen Grup</a>
      <a class="nav" href="<%=request.getContextPath()%>/transaction">Tambah Transaksi</a>
    </div>

    <div class="content">
      <%
        Group g = (Group) request.getAttribute("group");
        Map<User, Double> balances = (Map<User, Double>) request.getAttribute("balances");
      %>

      <div class="card">
        <div class="h1">Ringkasan Biaya - <%= (g==null ? "-" : g.getName()) %></div>
        <p class="p">Positif = piutang, negatif = utang.</p>
      </div>

      <% if (g == null) { %>
        <div class="card">
          <p class="p">Group belum dipilih / tidak ditemukan.</p>
        </div>
      <% } else { %>

        <div class="card">
          <div class="h1">Net Balance (Hutang/Piutang)</div>
          <% if (balances == null || balances.isEmpty()) { %>
            <p class="p">Belum ada data saldo.</p>
          <% } else { %>
            <table class="table">
              <thead>
                <tr><th>User</th><th>Balance</th><th>Status</th></tr>
              </thead>
              <tbody>
                <% for (Map.Entry<User, Double> e : balances.entrySet()) {
                     double val = e.getValue();
                     String status = (val >= 0) ? "Piutang" : "Utang";
                %>
                  <tr>
                    <td><%=e.getKey().getName()%> (<%=e.getKey().getId()%>)</td>
                    <td><%=String.format("%,.2f", val)%></td>
                    <td><%=status%></td>
                  </tr>
                <% } %>
              </tbody>
            </table>
          <% } %>
        </div>

        <div class="card">
          <div class="h1">Detail Split per Transaksi</div>

          <%
            List<Transaction> txs = g.getTransactions();
            if (txs == null || txs.isEmpty()) {
          %>
            <p class="p">Belum ada transaksi di group ini.</p>
          <%
            } else {
              for (Transaction tx : txs) {
                Map<User, Double> shares = tx.executeSplit();
          %>

            <div class="card" style="background:rgba(255,255,255,.03); margin-top:12px;">
              <div class="h1" style="font-size:16px;margin:0;">
                Transaksi: <%=tx.getId()%> • Total: <%=String.format("%,.2f", tx.getTotalAmount())%>
              </div>
              <p class="p" style="margin-top:8px;">
                Payer: <b><%=tx.getPayer().getName()%></b> (<%=tx.getPayer().getId()%>)
              </p>

              <table class="table">
                <thead>
                  <tr><th>Participant</th><th>Share (Harus Bayar)</th></tr>
                </thead>
                <tbody>
                  <% if (shares != null) {
                       for (Map.Entry<User, Double> s : shares.entrySet()) { %>
                      <tr>
                        <td><%=s.getKey().getName()%> (<%=s.getKey().getId()%>)</td>
                        <td><%=String.format("%,.2f", s.getValue())%></td>
                      </tr>
                  <%   }
                     } %>
                </tbody>
              </table>
            </div>

          <%
              }
            }
          %>
        </div>

      <% } %>
    </div>
  </div>
</body>
</html>

