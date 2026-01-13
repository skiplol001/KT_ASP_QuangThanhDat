<%@ Page Language="C#" MasterPageFile="~/Layout.Master" Title="Thêm Sách Mới" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    
    string strCon = @"Data Source=.;Initial Catalog=BanSachDB;Integrated Security=True";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadChuDe();
        }
    }

    private void LoadChuDe()
    {
        try {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ChuDe", conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlChuDe.DataSource = dt;
                ddlChuDe.DataTextField = "TenCD";
                ddlChuDe.DataValueField = "MaCD";
                ddlChuDe.DataBind();
            }
        }
        catch (Exception ex) {
            lblMsg.Text = "Lỗi kết nối Server: " + ex.Message;
        }
    }

    protected void btnThem_Click(object sender, EventArgs e)
    {
        try
        {
            string tenFile = "no-image.jpg";
            if (fHinh.HasFile)
            {
                tenFile = Path.GetFileName(fHinh.FileName);
                // Đảm bảo thư mục Bia_sach đã tồn tại trong Project
                string path = Server.MapPath("~/Bia_sach/") + tenFile;
                fHinh.SaveAs(path);
            }

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = "INSERT INTO Sach (TenSach, Dongia, MaCD, Hinh, KhuyenMai, NgayCapNhat) " +
                             "VALUES (@ten, @gia, @macd, @hinh, @km, @ngay)";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ten", txtTenSach.Text);
                cmd.Parameters.AddWithValue("@gia", txtDonGia.Text);
                cmd.Parameters.AddWithValue("@macd", ddlChuDe.SelectedValue);
                cmd.Parameters.AddWithValue("@hinh", tenFile);
                cmd.Parameters.AddWithValue("@km", chkKhuyenMai.Checked);
                cmd.Parameters.AddWithValue("@ngay", DateTime.Now);

                conn.Open();
                cmd.ExecuteNonQuery();
                
                // Thành công thì quay về trang xem sách
                Response.Redirect("XemSach.aspx");
            }
        }
        catch (Exception ex)
        {
            lblMsg.Text = "Lỗi khi thêm: " + ex.Message;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="NoiDung" runat="server">
    <div class="container mt-3" style="max-width: 600px; border: 1px solid #ddd; padding: 20px; border-radius: 10px;">
        <h3 class="text-center text-primary font-weight-bold">THÊM SÁCH MỚI</h3>
        <hr />
        
        <div class="form-group">
            <label class="font-weight-bold">Tên sách:</label>
            <asp:TextBox ID="txtTenSach" runat="server" CssClass="form-control" placeholder="Nhập tên sách"></asp:TextBox>
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Chủ đề:</label>
            <asp:DropDownList ID="ddlChuDe" runat="server" CssClass="form-control"></asp:DropDownList>
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Đơn giá (VNĐ):</label>
            <asp:TextBox ID="txtDonGia" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Ảnh bìa:</label>
            <asp:FileUpload ID="fHinh" runat="server" CssClass="form-control-file border p-1" />
        </div>

        <div class="form-group form-check">
            <asp:CheckBox ID="chkKhuyenMai" runat="server" CssClass="form-check-input" />
            <label class="form-check-label ml-2">Sách có khuyến mãi</label>
        </div>

        <div class="text-center mt-4">
            <asp:Button ID="btnThem" runat="server" Text="Lưu thông tin" CssClass="btn btn-primary px-4" OnClick="btnThem_Click" />
            <a href="XemSach.aspx" class="btn btn-outline-secondary px-4 ml-2">Hủy bỏ</a>
        </div>

        <asp:Label ID="lblMsg" runat="server" ForeColor="Red" CssClass="mt-3 d-block text-center"></asp:Label>
    </div>
</asp:Content>