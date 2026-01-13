<%@ Page Language="C#" MasterPageFile="~/Layout.Master" Title="Thêm Sách Mới" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    string strCon = @"Data Source=.;Initial Catalog=BanSachDB;Integrated Security=True";

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

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
            lblMsg.Text = "Lỗi kết nối Server khi tải chủ đề: " + ex.Message;
        }
    }

    protected void btnThem_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            try
            {
                string tenFile = "no-image.jpg"; 
                if (fHinh.HasFile)
                {
                    tenFile = Path.GetFileName(fHinh.FileName);
                    string path = Server.MapPath("~/Bia_sach/") + tenFile;
                    fHinh.SaveAs(path);
                }

                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    string sql = "INSERT INTO Sach (TenSach, Dongia, MaCD, Hinh, KhuyenMai, NgayCapNhat) " +
                                 "VALUES (@ten, @gia, @macd, @hinh, @km, @ngay)";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@ten", txtTenSach.Text.Trim());
                    cmd.Parameters.AddWithValue("@gia", txtDonGia.Text);
                    cmd.Parameters.AddWithValue("@macd", ddlChuDe.SelectedValue);
                    cmd.Parameters.AddWithValue("@hinh", tenFile);
                    cmd.Parameters.AddWithValue("@km", chkKhuyenMai.Checked);
                    cmd.Parameters.AddWithValue("@ngay", DateTime.Now);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    
                    Response.Redirect("XemSach.aspx");
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Lỗi khi lưu dữ liệu: " + ex.Message;
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="NoiDung" runat="server">
    <div class="container mt-3" style="max-width: 600px; border: 1px solid #ddd; padding: 25px; border-radius: 10px; background-color: #f9f9f9;">
        <h3 class="text-center text-primary font-weight-bold">THÊM SÁCH MỚI</h3>
        <hr />
        
        <div class="form-group">
            <label class="font-weight-bold">Tên sách:</label>
            <asp:TextBox ID="txtTenSach" runat="server" CssClass="form-control" placeholder="Ví dụ: Lập trình C#"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvTen" runat="server" ControlToValidate="txtTenSach"
                ErrorMessage="(*) Tên sách không được bỏ trống" ForeColor="Red" Display="Dynamic" SetFocusOnError="true" />
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Chủ đề:</label>
            <asp:DropDownList ID="ddlChuDe" runat="server" CssClass="form-control"></asp:DropDownList>
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Đơn giá (VNĐ):</label>
            <asp:TextBox ID="txtDonGia" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvGia" runat="server" ControlToValidate="txtDonGia"
                ErrorMessage="(*) Vui lòng nhập giá sách" ForeColor="Red" Display="Dynamic" SetFocusOnError="true" />
            <asp:RangeValidator ID="rvGia" runat="server" ControlToValidate="txtDonGia"
                MinimumValue="1000" MaximumValue="10000000" Type="Integer"
                ErrorMessage="(*) Giá phải từ 1,000 đến 10,000,000" ForeColor="Red" Display="Dynamic" />
        </div>

        <div class="form-group">
            <label class="font-weight-bold">Ảnh bìa:</label>
            <asp:FileUpload ID="fHinh" runat="server" CssClass="form-control-file border p-1 bg-white" />
            <asp:RequiredFieldValidator ID="rfvHinh" runat="server" ControlToValidate="fHinh"
                ErrorMessage="(*) Vui lòng chọn tệp ảnh" ForeColor="Red" Display="Dynamic" />
        </div>

        <div class="form-group form-check">
            <asp:CheckBox ID="chkKhuyenMai" runat="server" CssClass="form-check-input" />
            <label class="form-check-label ml-2">Áp dụng chương trình khuyến mãi</label>
        </div>

        <div class="text-center mt-4">
            <asp:Button ID="btnThem" runat="server" Text="Lưu Sách" CssClass="btn btn-primary px-5" OnClick="btnThem_Click" />
            <a href="XemSach.aspx" class="btn btn-outline-secondary px-4 ml-2">Hủy</a>
        </div>

        <asp:Label ID="lblMsg" runat="server" ForeColor="Red" CssClass="mt-3 d-block text-center font-weight-bold"></asp:Label>
    </div>
</asp:Content>