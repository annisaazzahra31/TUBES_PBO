<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.*"%>
<!DOCTYPE html>
<html>
<head>
  <title>SplitIt - Transaksi</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">

  <script>
    function byId(id){ return document.getElementById(id); }

    function toggleUneven() {
      const type = byId("splitType").value;
      byId("unevenBuilder").style.display = (type === "UNEVEN") ? "block" : "none";
      byId("previewBox").style.display = (type === "UNEVEN") ? "block" : "none";
      recalcPreview();
    }

    function reloadByGroup() {
      const gid = byId("groupId").value;
      window.location = "<%=request.getContextPath()%>/transaction?groupId=" + encodeURIComponent(gid);
    }

    function addRow(containerId, html) {
      const wrap = byId(containerId);
      const div = document.createElement("div");
      div.className = "rep-row";
      div.innerHTML = html;
      wrap.appendChild(div);
      recalcPreview();
    }

    function removeRow(btn){
      const row = btn.closest(".rep-row");
      if(row) row.remove();
      recalcPreview();
    }

    function num(v){
      const x = parseFloat(v);
      return isNaN(x) ? 0 : x;
    }

    function money(n){
      n = (isNaN(n) || n === null) ? 0 : n;
      return n.toLocaleString("id-ID", {minimumFractionDigits: 0, maximumFractionDigits: 0});
    }

    function selectedParticipants(){
      const checks = document.querySelectorAll('input[name="participantIds"]:checked');
      const arr = [];
      checks.forEach(c => arr.push(c.value));
      return arr;
    }

    function addItemRow(){
      const opts = byId("memberOptions").innerHTML;
      addRow("itemsBox",
        "<div class='rep-grid rep-grid-3'>" +
          "<div>" +
            "<label class='label'>Nama</label>" +
            "<select class='select' name='item_user' onchange='recalcPreview()'>" + opts + "</select>" +
          "</div>" +
          "<div>" +
            "<label class='label'>Item</label>" +
            "<input class='input' name='item_name' placeholder='Nama Item' oninput='recalcPreview()'>" +
          "</div>" +
          "<div>" +
            "<label class='label'>Nominal</label>" +
            "<div class='rep-inline'>" +
              "<input class='input' name='item_amount' type='number' step='1' placeholder='0' oninput='recalcPreview()'>" +
              "<button class='btn-ghost' type='button' onclick='removeRow(this)'>Hapus</button>" +
            "</div>" +
          "</div>" +
        "</div>"
      );
    }

    function addFeeRow(){
      addRow("feesBox",
        "<div class='rep-grid rep-grid-3'>" +
          "<div>" +
            "<label class='label'>Keterangan</label>" +
            "<input class='input' name='fee_label' placeholder='Pajak / Service / Admin' oninput='recalcPreview()'>" +
          "</div>" +
          "<div>" +
            "<label class='label'>Tipe</label>" +
            "<select class='select' name='fee_type' onchange='recalcPreview()'>" +
              "<option value='PERCENT'>Percent</option>" +
              "<option value='FIXED'>Fixed</option>" +
            "</select>" +
          "</div>" +
          "<div>" +
            "<label class='label'>Nilai</label>" +
            "<div class='rep-inline'>" +
              "<input class='input' name='fee_value' type='number' step='1' placeholder='0' oninput='recalcPreview()'>" +
              "<button class='btn-ghost' type='button' onclick='removeRow(this)'>Hapus</button>" +
            "</div>" +
          "</div>" +
        "</div>"
      );
    }

    function ensureDefaultRows(){
      if(byId("itemsBox").children.length === 0) addItemRow();
      if(byId("feesBox").children.length === 0) addFeeRow();
    }

    function readItems(){
      const rows = document.querySelectorAll("#itemsBox .rep-row");
      const items = [];
      rows.forEach(r => {
        const uid = r.querySelector('select[name="item_user"]').value;
        const name = (r.querySelector('input[name="item_name"]').value || "").trim();
        const amt = num(r.querySelector('input[name="item_amount"]').value);
        if(uid && name && amt > 0) items.push({userId: uid, amount: amt});
      });
      return items;
    }

    function readFees(){
      const rows = document.querySelectorAll("#feesBox .rep-row");
      const fees = [];
      rows.forEach(r => {
        const label = (r.querySelector('input[name="fee_label"]').value || "").trim();
        const type = r.querySelector('select[name="fee_type"]').value;
        const val = num(r.querySelector('input[name="fee_value"]').value);
        if(label && val > 0) fees.push({type:type, value:val});
      });
      return fees;
    }

    function recalcPreview(){
      if(byId("splitType").value !== "UNEVEN") return;

      const participants = selectedParticipants();
      const items = readItems();
      const fees = readFees();
      const feeModeEl = document.querySelector('input[name="feeMode"]:checked');
      const feeMode = feeModeEl ? feeModeEl.value : "EQUAL";

      const sub = {};
      participants.forEach(u => sub[u] = 0);

      items.forEach(it => {
        if(sub[it.userId] !== undefined) sub[it.userId] += it.amount;
      });

      let subtotalAll = 0;
      participants.forEach(u => subtotalAll += (sub[u] || 0));

      let feeFixed = 0;
      let feePercent = 0;

      fees.forEach(f => {
        if(f.type === "FIXED") feeFixed += f.value;
        else feePercent += (subtotalAll * (f.value/100.0));
      });

      const feeGlobal = feeFixed + feePercent;

      const feeShare = {};
      participants.forEach(u => feeShare[u] = 0);

      if(participants.length > 0){
        if(feeMode === "EQUAL"){
          const each = feeGlobal / participants.length;
          participants.forEach(u => feeShare[u] = each);
        } else {
          participants.forEach(u => {
            const p = subtotalAll > 0 ? (sub[u] / subtotalAll) : (1/participants.length);
            feeShare[u] = feeGlobal * p;
          });
        }
      }

      const tbody = byId("previewTbody");
      tbody.innerHTML = "";

      let totalAll = 0;
      participants.forEach(u => {
        const s = sub[u] || 0;
        const f = feeShare[u] || 0;
        const t = s + f;
        totalAll += t;

        const tr = document.createElement("tr");
        tr.innerHTML =
          "<td><span class='badge'>" + u + "</span></td>" +
          "<td>" + money(s) + "</td>" +
          "<td>" + money(f) + "</td>" +
          "<td><b>" + money(t) + "</b></td>";
        tbody.appendChild(tr);
      });

      byId("previewMeta").innerHTML =
        "<span class='pill'>Subtotal: " + money(subtotalAll) + "</span>" +
        "<span class='pill'>Fee: " + money(feeGlobal) + "</span>" +
        "<span class='pill'>Total Akhir: " + money(totalAll) + "</span>";

      const totalAmount = byId("totalAmount");
      if(totalAmount) totalAmount.value = Math.round(totalAll);
    }

    window.addEventListener("load", function(){
      ensureDefaultRows();
      toggleUneven();
      recalcPreview();
    });
  </script>
</head>

<body>
  <div class="topbar">
    <div class="brand">
      <div class="logo">S</div>
      <div>
        <div class="brand-title">SplitIt</div>
        <div class="brand-sub">Transaksi</div>
      </div>
    </div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <a class="nav" href="<%=request.getContextPath()%>/dashboard">Dashboard</a>
      <a class="nav" href="<%=request.getContextPath()%>/groups">Manajemen Grup</a>
      <a class="nav" href="<%=request.getContextPath()%>/transaction">Transaksi</a>
    </div>

    <div class="content">
      <%
        List<Group> groups = (List<Group>) request.getAttribute("groups");
        Group selected = (Group) request.getAttribute("selectedGroup");
        List<User> members = (List<User>) request.getAttribute("members");
        if(members == null) members = new ArrayList<User>();
      %>

      <div class="card">
        <div class="h1">Tambah Transaksi</div>
        <p class="p">Pilih group, payer, participants, lalu mode split. Untuk UNEVEN, isi item per orang + biaya tambahan.</p>

        <form method="post" action="<%=request.getContextPath()%>/transaction">
          <div class="grid grid-2">
            <div>
              <label class="label">ID Transaksi</label>
              <input class="input" name="txId" placeholder="T1" required>
            </div>
            <div>
              <label class="label">Group</label>
              <select class="select" name="groupId" id="groupId" required onchange="reloadByGroup()">
                <% for (Group g : groups) { %>
                  <option value="<%=g.getId()%>" <%= (selected != null && g.getId().equals(selected.getId())) ? "selected" : "" %>>
                    <%=g.getId()%> - <%=g.getName()%>
                  </option>
                <% } %>
              </select>
            </div>
          </div>

          <div class="grid grid-2">
            <div>
              <label class="label">Total Amount</label>
              <input class="input" id="totalAmount" name="totalAmount" type="number" step="1" placeholder="0" value="0" required>
            </div>
            <div>
              <label class="label">Split Type</label>
              <select class="select" name="splitType" id="splitType" onchange="toggleUneven()">
                <option value="EVEN">Even Split (Bagi Rata)</option>
                <option value="UNEVEN">Uneven (Per Item + Biaya Tambahan)</option>
              </select>
            </div>
          </div>

          <div class="card" style="background:rgba(255,255,255,.03); margin-top: 28px;">
            <div class="h1" style="font-size:16px;margin:0 0 8px;">
              Payer & Participants (Group: <%= (selected == null ? "-" : selected.getName()) %>)
            </div>

            <% if (selected == null) { %>
              <p class="p" style="color:#ffb4c7;">Pilih group dulu agar anggota muncul.</p>
            <% } else if (members.isEmpty()) { %>
              <p class="p" style="color:#ffb4c7;">Group ini belum punya anggota. Tambahkan anggota dulu di Detail Group.</p>
            <% } %>

            <label class="label">Payer</label>
            <select class="select" name="payerId" required onchange="recalcPreview()">
              <% for (User u : members) { %>
                <option value="<%=u.getId()%>"><%=u.getId()%> - <%=u.getName()%></option>
              <% } %>
            </select>

            <label class="label" style="margin-top:12px;">Participants</label>
            <% for (User u : members) { %>
              <div style="display:flex;align-items:center;gap:10px;margin:8px 0;">
                <input type="checkbox" name="participantIds" value="<%=u.getId()%>" checked onchange="recalcPreview()">
                <div><b><%=u.getName()%></b> <span class="badge"><%=u.getId()%></span></div>
              </div>
            <% } %>

            <div style="display:none">
              <select id="memberOptions">
                <% for (User u : members) { %>
                  <option value="<%=u.getId()%>"><%=u.getId()%> - <%=u.getName()%></option>
                <% } %>
              </select>
            </div>
          </div>

          <div id="unevenBuilder" class="card" style="display:none;">
            <div class="h1">Uneven Builder</div>
            <p class="p">Isi item per orang, lalu biaya tambahan (pajak/service/admin bisa dimasukin di sini). Sistem akan bagi biaya sesuai masukan.</p>

            <div class="card" style="background:rgba(118,21,60,.10);border-color:rgba(118,21,60,.35);margin-top:12px;">
              <div class="rep-head">
                <div>
                  <div class="h1" style="font-size:16px;margin:0;">Item per Orang</div>
                  <div class="p" style="margin:6px 0 0;">Bisa tambah sebanyak yang diperlukan.</div>
                </div>
                <button class="btn-ghost" type="button" onclick="addItemRow()">+ Tambah Item</button>
              </div>
              <div id="itemsBox" class="rep-box"></div>
            </div>

            <div class="card" style="background:rgba(255,255,255,.03);margin-top:12px;">
              <div class="rep-head">
                <div>
                  <div class="h1" style="font-size:16px;margin:0;">Biaya Tambahan</div>
                </div>
                <button class="btn-ghost" type="button" onclick="addFeeRow()">+ Tambah Biaya</button>
              </div>
              <div id="feesBox" class="rep-box"></div>
            </div>
          </div>

          <div id="previewBox" class="card" style="background:rgba(255,255,255,.03);margin-top:12px;display:none;">
            <div class="rep-head">
              <div>
                <div class="h1" style="font-size:16px;margin:0;">Preview Pembagian (UNEVEN)</div>
                <div class="p" style="margin:10px 0 0;" id="previewMeta"></div>
              </div>
            </div>

              <table class="table" style="margin-top: 20px;">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Subtotal Item</th>
                  <th>Share Biaya</th>
                  <th>Total Akhir</th>
                </tr>
              </thead>
              <tbody id="previewTbody"></tbody>
            </table>
          </div>

          <div class="actions">
            <button class="btn" type="submit">Simpan Transaksi</button>
          </div>
        </form>
      </div>

    </div>
  </div>
</body>
</html>
