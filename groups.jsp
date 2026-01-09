<%-- 
    Document   : groups
    Created on : 25 Dec 2025, 21.39.09
    Author     : Ann
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Group"%>
<%--@ include file="partials/navbar.jsp" --%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Group</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>
  <div class="topbar">
    <div class="brand"><div class="logo">S</div><div><div class="brand-title">SplitIt</div><div class="brand-sub">Manajemen Grup</div></div></div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">Dashboard</a>
      <a class="nav" href="<%=request.getContextPath()%>/groups">Manajemen Grup</a>
      <a class="nav" href="<%=request.getContextPath()%>/transaction">Transaksi</a>
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">← Home</a>

    </div>

    <div class="content">
      <div class="card">
        <div class="h1">Buat Group Baru</div>
        <form method="post" action="<%=request.getContextPath()%>/groups">
          <div class="grid grid-2">
            <div>
              <label class="label">ID Group</label>
              <input class="input" name="id" placeholder="G2" required>
            </div>
            <div>
              <label class="label">Nama Group</label>
              <input class="input" name="name" placeholder="Contoh: Sushi Tei" required>
            </div>
          </div>
          <div class="actions">
            <button class="btn" type="submit">Simpan Group</button>
          </div>
        </form>
      </div>

      <div class="card">
        <div class="h1">Daftar Group</div>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nama</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
          <%
            List<Group> groups = (List<Group>) request.getAttribute("groups");
            for (Group g : groups) {
          %>
            <tr>
              <td><%=g.getId()%></td>
              <td><%=g.getName()%></td>
              <td>
                <a class="btn-ghost" href="<%=request.getContextPath()%>/group-detail?id=<%=g.getId()%>">Detail + Anggota</a>
                <a class="btn-ghost" href="<%=request.getContextPath()%>/summary?groupId=<%=g.getId()%>">Ringkasan</a>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>

    </div>
  </div>
</body>
</html>

