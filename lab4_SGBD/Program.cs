using Microsoft.Data.SqlClient;

namespace lab4_SGBD
{
    class Program
    {
        static string ConnectionString = "Data Source=DESKTOP-P0J5H9P;Initial Catalog=Port;Integrated Security=True;TrustServerCertificate=true;";
        static int tries = 3;

        static bool RunTransaction1()
        {
            bool Result = false;
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                try
                {
                    conn.Open();
                    string Query = "EXEC Deadlock_T1_C#;";
                    SqlCommand Command = conn.CreateCommand();
                    Command.CommandText = Query;
                    Command.ExecuteNonQuery();
                    Result = true;
                    Console.WriteLine("Transaction 1 committed!");

                }
                catch (SqlException ex)
                {
                    if (ex.Number == 1205)
                    {
                        Console.WriteLine("Transaction 1 deadlock rolled back\n");
                        Console.WriteLine(ex.Message);
                    }
                }

            }
            return Result;
        }

        static bool RunTransaction2()
        {
            bool Result = false;
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                try
                {
                    conn.Open();
                    string Query = "EXEC Deadlock_T2_C#;";
                    SqlCommand Command = conn.CreateCommand();
                    Command.CommandText = Query;
                    Command.ExecuteNonQuery();
                    Result = true;
                    Console.WriteLine("Transaction 2 committed!");

                }
                catch (SqlException ex)
                {
                    if(ex.Number == 1205)
                    {
                        Console.WriteLine("Transaction 2 deadlock rolled back\n");
                        Console.WriteLine(ex.Message);
                    }
                }

            }
            return Result;
        }

        static void Transaction1()
        {
            int k = 0;
            while(!RunTransaction1())
            {
                k++;
                if (k >= tries) break;

            }
            if(k == tries) Console.WriteLine("Transaction 1 aborted");
        }

        static void Transaction2()
        {
            int k = 0;
            while (!RunTransaction2())
            {
                k++;
                if (k >= tries) break;

            }
            if (k == tries) Console.WriteLine("Transaction 2 aborted");
        }

        public static void Main(string[] args)
        {
            Thread t1 = new Thread(new ThreadStart(Transaction1));
            Thread t2 = new Thread(new ThreadStart(Transaction2));
            t1.Start();
            t1.Join();
            t2.Start(); 
            t2.Join();
        }
    }
}
