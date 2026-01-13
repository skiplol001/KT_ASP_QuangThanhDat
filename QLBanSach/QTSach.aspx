<%@ Page Title="" Language="C#" MasterPageFile="~/Layout.Master" AutoEventWireup="true" CodeBehind="QTSach.aspx.cs" Inherits="QLBanSach.QTSach" %>
<asp:Content ID="Content1" ContentPlaceHolderID="NoiDung" runat="server">
     <h2>TRANG QUẢN TRỊ SÁCH</h2>
     <hr />   
     <div class="row mb-2">
         <div class="col-md-6">
              <div class="form-inline">
                   Tựa sách <asp:TextBox ID="txtSearch" runat="server" placeholder="Nhập tựa sách cần tìm" CssClass="form-control ml-2" Width="300"></asp:TextBox>
                  <asp:Button ID="btTraCuu" runat="server" Text="Tra cứu" CssClass="btn btn-info ml-2" />                 
              </div>
         </div>
        <div class="col-md-6 text-right">
             <a href="#" class="btn btn-success">Thêm sách mới</a>
        </div>
    </div>
    


</asp:Content>
