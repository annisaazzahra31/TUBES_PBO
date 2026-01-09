<%-- 
    Document   : dashboard
    Created on : 25 Dec 2025, 21.38.58
    Author     : alishadenahutomo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--@ include file="partials/navbar.jsp" --%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Dashboard</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>
  <div class="topbar">
    <div class="brand">
      <div class="logo">S</div>
      <div>
        <div class="brand-title">SplitIt</div>
        <div class="brand-sub">Smart Expense Splitter</div>
      </div>
    </div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">Dashboard</a>
      <a class="nav" href="<%=request.getContextPath()%>/groups">Manajemen Grup</a>
      <a class="nav" href="<%=request.getContextPath()%>/transaction">Transaksi</a>
      <a class="nav" href="<%=request.getContextPath()%>/summary?groupId=G1">Summary</a>
    </div>

    <div class="content">
      <div class="card">
        <div class="h1">Dashboard</div>
        <p class="p">Kelola group, transaksi (even/uneven), dan lihat ringkasan hutang.</p>
      </div>

      <div class="grid grid-2">
        <div class="card">
          <div class="p">Total Group</div>
          <div class="h1" style="margin:8px 0 0;"><%=request.getAttribute("groupsCount")%></div>
        </div>
        <div class="card">
          <div class="p">Quick Start</div>
          <div style="margin-top:10px;display:flex;gap:10px;flex-wrap:wrap;">
            <a class="btn" href="<%=request.getContextPath()%>/groups">Buat / Lihat Group</a>
            <a class="btn-ghost" href="<%=request.getContextPath()%>/transaction">Tambah Transaksi</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
