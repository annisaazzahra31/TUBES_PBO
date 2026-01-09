<%-- 
    Document   : group_detail
    Created on : 25 Dec 2025, 21.39.54
    Author     : mutti
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.*"%>
<%--@ include file="partials/navbar.jsp" --%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Detail Group</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>
    <%
        Group g = (Group) request.getAttribute("group");
    %>

  <div class="topbar">
    <div class="brand"><div class="logo">S</div><div><div class="brand-title">SplitIt</div><div class="brand-sub">Detail Group</div></div></div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <a class="nav" href="<%=request.getContextPath()%>/groups">← Kembali</a>
      <a class="nav" href="<%=request.getContextPath()%>/transaction?groupId=<%= g.getId() %>">Tambah Transaksi</a>
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">← Home</a>
    </div>

    <div class="content">
      <div class="card">
        <div class="h1">Group: <%= (g==null ? "-" : g.getName()) %> <span class="badge"><%= (g==null ? "" : g.getId()) %></span></div>
        <p class="p">Tambah anggota/pengguna (User) ke dalam group.</p>
      </div>

      <% if (g != null) { %>
      <div class="card">
        <div class="h1">Tambah Anggota</div>
        <form method="post" action="<%=request.getContextPath()%>/group-detail">
          <input type="hidden" name="groupId" value="<%=g.getId()%>">
          <div class="grid grid-2">
            <div>
              <label class="label">ID User</label>
              <input class="input" name="userId" placeholder="U2" required>
            </div>
            <div>
              <label class="label">Nama User</label>
              <input class="input" name="userName" placeholder="Nama Anggota" required>
            </div>
          </div>
          <div class="actions">
            <button class="btn" type="submit">Tambah</button>
          </div>
        </form>
      </div>

      <div class="card">
        <div class="h1">Anggota</div>
        <table class="table">
          <thead><tr><th>ID</th><th>Nama</th></tr></thead>
          <tbody>
          <% for (User u : g.getMembers()) { %>
            <tr><td><%=u.getId()%></td><td><%=u.getName()%></td></tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <% } %>

    </div>
  </div>
</body>
</html>

