<%-- 
    Document   : transaction_uneven
    Created on : 8 Jan 2026, 19.26.04
    Author     : amalia
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.*"%>
<%--@ include file="partials/navbar.jsp" --%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Uneven Split</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>

<%
  List<Group> groups = (List<Group>) request.getAttribute("groups");
  Group selected = (Group) request.getAttribute("selectedGroup");
  List<User> members = (selected == null) ? new ArrayList<>() : selected.getMembers();
%>

<div class="topbar">
  <div class="brand">
    <div class="logo">S</div>
    <div>
      <div class="brand-title">SplitIt</div>
      <div class="brand-sub">Uneven Split</div>
    </div>
  </div>
</div>

<div class="layout">
  <div class="sidebar
    <a class="nav" href="<%=request.getContextPath()%>/groups">Groups</a>
    <a class="nav" href="<%=request.getContextPath()%>/transaction">Even Split</a>
    <a class="nav active">Uneven Split</a>
  </div>

  <div class="content">

    <div class="card">
      <div class="h1">Pilih Group</div>
      <select class="select"
        onchange="window.location='<%=request.getContextPath()%>/transaction-uneven?groupId=' + this.value">
        <option value="">-- Pilih Group --</option>
        <% for (Group g : groups) { %>
          <option value="<%=g.getId()%>"
            <%= (selected != null && g.getId().equals(selected.getId())) ? "selected" : "" %>>
            <%=g.getId()%> - <%=g.getName()%>
          </option>
        <% } %>
      </select>
    </div>

    <div class="card">
      <div class="h1">Pilih Orang</div>
      <select class="select">
        <option value="">-- Pilih Orang --</option>
        <% for (User u : members) { %>
          <option value="<%=u.getId()%>"><%=u.getName()%></option>
        <% } %>
      </select>
    </div>

    <div class="card">
      <div class="h1">Item yang Dibeli</div>

      <div class="grid grid-2">
        <input class="input" placeholder="Nama Item">
        <input class="input" type="number" placeholder="Nominal">
      </div>

      <button class="btn-ghost" type="button">+ Tambah Item</button>
    </div>

    <div class="card">
      <div class="h1">Biaya Tambahan</div>

      <div class="grid grid-2">
        <input class="input" placeholder="Keterangan (contoh: Pajak)">
        <input class="input" placeholder="10% atau 5000">
      </div>

      <button class="btn-ghost" type="button">+ Tambah Biaya</button>
    </div>

    <div class="actions">
      <button class="btn">Simpan & Hitung Split</button>
    </div>

  </div>
</div>

</body>
</html>



