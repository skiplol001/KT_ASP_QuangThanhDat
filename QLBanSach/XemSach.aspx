<%@ Page Language="C#" MasterPageFile="~/Layout.Master" Title="Quản Lý Sách" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    string strCon = @"Data Source=.;Initial Catalog=BanSachDB;Integrated Security=True";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadChuDe();
            LoadData();
        }
    }

    private void LoadChuDe()
    {
        using (SqlConnection conn = new SqlConnection(strCon))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ChuDe", conn);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlChuDe.DataSource = dt;
            ddlChuDe.DataTextField = "TenCD";
            ddlChuDe.DataValueField = "MaCD";
            ddlChuDe.DataBind();
            ddlChuDe.Items.Insert(0, new ListItem("-- Tất cả chủ đề --", "0"));
        }
    }

    private void LoadData()
    {
        using (SqlConnection conn = new SqlConnection(strCon))
        {
            string sql = "SELECT * FROM Sach WHERE 1=1";
            
            // Lọc theo chủ đề
            if (ddlChuDe.SelectedValue != "0")
                sql += " AND MaCD = " + ddlChuDe.SelectedValue;

            // Lọc theo tên sách (Tìm gần đúng)
            if (!string.IsNullOrEmpty(txtSearch.Text))
                sql += " AND TenSach LIKE N'%" + txtSearch.Text.Trim() + "%'";

            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                gvSach.DataSource = dt;
                gvSach.DataBind();
                lblStatus.Text = "";
            }
            else
            {
                gvSach.DataSource = null;
                gvSach.DataBind();
                lblStatus.Text = "Tìm kiếm không có kết quả nào.";
            }
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadData(); }
    
    protected void ddlChuDe_SelectedIndexChanged(object sender, EventArgs e) { LoadData(); }

    protected void gvSach_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvSach.PageIndex = e.NewPageIndex;
        LoadData();
    }

    protected void gvSach_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvSach.EditIndex = e.NewEditIndex;
        LoadData();
    }

    protected void gvSach_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvSach.EditIndex = -1;
        LoadData();
    }

    protected void gvSach_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int maSach = Convert.ToInt32(gvSach.DataKeys[e.RowIndex].Value);
        string ten = ((TextBox)gvSach.Rows[e.RowIndex].FindControl("txtEditTen")).Text;
        int gia = Convert.ToInt32(((TextBox)gvSach.Rows[e.RowIndex].FindControl("txtEditGia")).Text);
        bool km = ((CheckBox)gvSach.Rows[e.RowIndex].FindControl("chkEditKM")).Checked;

        using (SqlConnection conn = new SqlConnection(strCon))
        {
            SqlCommand cmd = new SqlCommand("UPDATE Sach SET TenSach=@ten, Dongia=@gia, KhuyenMai=@km WHERE MaSach=@ma", conn);
            cmd.Parameters.AddWithValue("@ten", ten);
            cmd.Parameters.AddWithValue("@gia", gia);
            cmd.Parameters.AddWithValue("@km", km);
            cmd.Parameters.AddWithValue("@ma", maSach);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
        gvSach.EditIndex = -1;
        LoadData();
    }

    protected void gvSach_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int maSach = Convert.ToInt32(gvSach.DataKeys[e.RowIndex].Value);
        using (SqlConnection conn = new SqlConnection(strCon))
        {
            SqlCommand cmd = new SqlCommand("DELETE FROM Sach WHERE MaSach=@ma", conn);
            cmd.Parameters.AddWithValue("@ma", maSach);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
        LoadData();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="NoiDung" runat="server">
    <div class="container mt-3">
        <h3 class="text-center font-weight-bold">QUẢN LÝ DANH MỤC SÁCH</h3>
        <hr />

        <div class="alert alert-info">
            <div class="form-inline justify-content-center">
                <label class="font-weight-bold mr-2">Chủ đề:</label>
                <asp:DropDownList ID="ddlChuDe" CssClass="form-control mr-3" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlChuDe_SelectedIndexChanged"></asp:DropDownList>
                
                <label class="font-weight-bold mr-2">Tên sách:</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control mr-2" placeholder="Nhập tên sách..."></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
            </div>
        </div>

        <div class="sach-container">
            <asp:Label ID="lblStatus" runat="server" ForeColor="Red" CssClass="mb-2 d-block font-italic"></asp:Label>
            
            <asp:GridView ID="gvSach" runat="server" AutoGenerateColumns="false" DataKeyNames="MaSach" 
                CssClass="table table-bordered table-hover" AllowPaging="true" PageSize="4" 
                OnPageIndexChanging="gvSach_PageIndexChanging" 
                OnRowEditing="gvSach_RowEditing" 
                OnRowCancelingEdit="gvSach_RowCancelingEdit" 
                OnRowUpdating="gvSach_RowUpdating" 
                OnRowDeleting="gvSach_RowDeleting">
                
                <HeaderStyle BackColor="#800000" ForeColor="White" HorizontalAlign="Center" />
                <PagerStyle HorizontalAlign="Center" BackColor="#FFFACD" />

                <Columns>
                    <asp:TemplateField HeaderText="Tựa sách">
                        <ItemTemplate>
                            <asp:Label ID="lblTen" runat="server" Text='<%# Eval("TenSach") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditTen" runat="server" Text='<%# Eval("TenSach") %>' CssClass="form-control"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Ảnh Bìa" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <img src='<%# "Bia_sach/" + Eval("Hinh") %>' style="width:70px; height:auto" />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <img src='<%# "Bia_sach/" + Eval("Hinh") %>' style="width:40px;" />
                            <small class="d-block text-muted">Không sửa ảnh</small>
                        </EditItemTemplate> 
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Đơn giá">
                        <ItemTemplate>
                            <%# string.Format("{0:#,##0} đồng", Eval("Dongia")) %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditGia" runat="server" Text='<%# Eval("Dongia") %>' CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Khuyến mãi" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%# (bool)Eval("KhuyenMai") ? "X" : "" %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="chkEditKM" runat="server" Checked='<%# Eval("KhuyenMai") %>' /> 
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Thao tác" ItemStyle-Width="160px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server" CommandName="Edit" Text="Sửa" CssClass="btn btn-info btn-sm" />
                            <asp:Button ID="btnDelete" runat="server" CommandName="Delete" Text="Xoá" CssClass="btn btn-danger btn-sm" OnClientClick="return confirm('Xác nhận xóa sách này?')" />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:Button ID="btnUpdate" runat="server" CommandName="Update" Text="Ghi" CssClass="btn btn-success btn-sm" />
                            <asp:Button ID="btnCancel" runat="server" CommandName="Cancel" Text="Không" CssClass="btn btn-warning btn-sm" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>