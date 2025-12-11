using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ForumDev.DAL
{
    /// <summary>
    /// 資料庫存取輔助類別
    /// </summary>
    public class DBHelper
    {
        private static string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        /// <summary>
        /// 取得資料庫連線
        /// </summary>
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }

        /// <summary>
        /// 執行查詢並返回 DataTable
        /// </summary>
        public static DataTable ExecuteQuery(string query, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            
            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }

                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            adapter.Fill(dt);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("執行查詢時發生錯誤: " + ex.Message, ex);
            }

            return dt;
        }

        /// <summary>
        /// 執行非查詢指令 (INSERT, UPDATE, DELETE)
        /// </summary>
        public static int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            int rowsAffected = 0;

            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }

                        rowsAffected = cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("執行指令時發生錯誤: " + ex.Message, ex);
            }

            return rowsAffected;
        }

        /// <summary>
        /// 執行標量查詢 (返回單一值)
        /// </summary>
        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
        {
            object result = null;

            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }

                        result = cmd.ExecuteScalar();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("執行標量查詢時發生錯誤: " + ex.Message, ex);
            }

            return result;
        }

        /// <summary>
        /// 執行預存程序
        /// </summary>
        public static int ExecuteStoredProcedure(string procedureName, params SqlParameter[] parameters)
        {
            int rowsAffected = 0;

            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }

                        rowsAffected = cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("執行預存程序時發生錯誤: " + ex.Message, ex);
            }

            return rowsAffected;
        }

        /// <summary>
        /// 使用交易執行多個指令
        /// </summary>
        public static bool ExecuteTransaction(params Action<SqlConnection, SqlTransaction>[] actions)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    foreach (var action in actions)
                    {
                        action(conn, transaction);
                    }

                    transaction.Commit();
                    return true;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    throw new Exception("執行交易時發生錯誤: " + ex.Message, ex);
                }
            }
        }

        /// <summary>
        /// 檢查資料庫連線是否正常
        /// </summary>
        public static bool TestConnection()
        {
            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }
    }
}
