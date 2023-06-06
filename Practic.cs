using Microsoft.Data.SqlClient;
using System.Configuration;
using System.Data;
using System.Globalization;

namespace practic2
{
    public partial class parent : Form
    {

        private static readonly string connectionString = @"Server=DESKTOP-P0J5H9P;Database=S9;Integrated Security=true;TrustServerCertificate=true;";
        private static readonly string selectChildQuery = "SELECT * FROM Copii;";
        private static readonly DataSet ds = new DataSet();
        private static readonly SqlDataAdapter parentDataAdapter = new SqlDataAdapter();
        private static readonly SqlDataAdapter childDataAdapter = new SqlDataAdapter();
        private static readonly BindingSource parentBindingSource = new BindingSource();
        private static readonly BindingSource childBindingSource = new BindingSource();

        public parent()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string parentQuery = "SELECT * FROM InghetatePreferate";
                    string childQuery = "SELECT * FROM Copii";
                    parentDataAdapter.SelectCommand = new SqlCommand(parentQuery, conn);
                    childDataAdapter.SelectCommand = new SqlCommand(childQuery, conn);
                    parentDataAdapter.Fill(ds, "InghetatePreferate");
                    childDataAdapter.Fill(ds, "Copii");

                    DataColumn parentColumn = ds.Tables["InghetatePreferate"].Columns["IPid"];
                    DataColumn childColumn = ds.Tables["Copii"].Columns["IPid"];
                    DataRelation relation = new DataRelation("FK_Copii_Inghetate_Preferate", parentColumn, childColumn);
                    ds.Relations.Add(relation);

                    parentBindingSource.DataSource = ds.Tables["InghetatePreferate"];
                    dataGridViewParent.DataSource = parentBindingSource;
                    childBindingSource.DataSource = parentBindingSource;
                    childBindingSource.DataMember = "FK_Copii_Inghetate_Preferate";
                    dataGridViewChild.DataSource = childBindingSource;
                    conn.Close();
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            try
            {
                //using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Port"].ConnectionString.ToString()))
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string deleteQuery = "DELETE FROM Copii WHERE Cid = @id;";
                    childDataAdapter.SelectCommand = new SqlCommand(selectChildQuery, conn);
                    childDataAdapter.DeleteCommand = new SqlCommand(deleteQuery, conn);
                    childDataAdapter.DeleteCommand.Parameters.Add("@id", SqlDbType.Int).Value = dataGridViewChild.Rows[dataGridViewChild.SelectedRows[0].Index].Cells["Cid"].Value.ToString();
                    conn.Open();
                    ds.Tables["Copii"].Rows[0].Delete();
                    int rowsAffected = childDataAdapter.Update(ds, "Copii");

                    if (rowsAffected > 0)
                    {
                        MessageBox.Show("Deleted successfully!");
                        ds.Tables["Copii"].Clear();
                        childDataAdapter.Fill(ds, "Copii");
                    }
                    else
                    {
                        MessageBox.Show("Error");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string updateQuery = "UPDATE Copii SET Nume=@nume, Prenume=@prenume WHERE Cid=@id;";
                    childDataAdapter.UpdateCommand = new SqlCommand(updateQuery, conn);
                    childDataAdapter.UpdateCommand.Parameters.Add("@nume", SqlDbType.VarChar).Value = textBox6.Text;
                    childDataAdapter.UpdateCommand.Parameters.Add("@prenume", SqlDbType.VarChar).Value = textBox7.Text;
                    childDataAdapter.UpdateCommand.Parameters.Add("@id", SqlDbType.Int).Value = dataGridViewChild.Rows[dataGridViewChild.SelectedRows[0].Index].Cells["Cid"].Value.ToString();

                    string err = "";

                    if (String.IsNullOrWhiteSpace(textBox6.Text.ToString())) err += "Nume can't be null or whitespace!\n";

                    if (err.Length > 0)
                    {
                        MessageBox.Show(err);
                    }
                    else
                    {
                        conn.Open();
                        int rows = childDataAdapter.UpdateCommand.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            MessageBox.Show("Updated!");
                        }
                        conn.Close();

                        conn.Open();
                        childDataAdapter.SelectCommand = new SqlCommand(selectChildQuery, conn);
                        ds.Tables["Copii"].Clear();
                        childDataAdapter.Fill(ds, "Copii");
                        conn.Close();
                    }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string insertQuery = "INSERT INTO Copii(Nume, Prenume, Gen, Varsta, IPid) VALUES (@nume, @prenume, @gen, @varsta, @ipid);";
                    childDataAdapter.InsertCommand = new SqlCommand(insertQuery, conn);
                    childDataAdapter.InsertCommand.Parameters.Add("@nume", SqlDbType.VarChar).Value = textBox6.Text.ToString();
                    childDataAdapter.InsertCommand.Parameters.Add("@prenume", SqlDbType.VarChar).Value = textBox7.Text.ToString();
                    childDataAdapter.InsertCommand.Parameters.Add("@gen", SqlDbType.VarChar).Value = textBox8.Text.ToString();
                    childDataAdapter.InsertCommand.Parameters.Add("@varsta", SqlDbType.Int).Value = Convert.ToInt64(textBox10.Text.ToString());
                    childDataAdapter.InsertCommand.Parameters.Add("@ipid", SqlDbType.Int).Value = Convert.ToInt64(textBox9.Text.ToString());

                    string err = "";

                    if (err.Length > 0)
                    {
                        MessageBox.Show(err);
                    }
                    else
                    {
                        conn.Open();
                        childDataAdapter.InsertCommand.ExecuteNonQuery();
                        conn.Close();

                        conn.Open();
                        childDataAdapter.SelectCommand = new SqlCommand(selectChildQuery, conn);
                        ds.Tables["Copii"].Clear();
                        childDataAdapter.Fill(ds, "Copii");
                        conn.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
