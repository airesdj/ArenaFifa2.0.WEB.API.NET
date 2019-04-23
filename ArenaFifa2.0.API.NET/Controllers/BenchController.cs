using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.BenchModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class BenchController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult getListOfBench(BenchModesViewModel bench)
        {

            db.openConnection();
            var objFunctions = new Commons.functions();
            BenchModes benchPlayersModel = new BenchModes();
            BenchModesViewModel listBenchPlayers = new BenchModesViewModel();
            List<BenchModes> listOfBench = new List<BenchModes>();
            DataTable dt = null;
            string[] typeOfBench = { "H2H", "FUT", "PRO" };

            try
            {

                for (int i = 0; i < typeOfBench.Length; i++)
                {

                    paramName = new string[] { "pTpBancoReserva" };
                    paramValue = new string[] { typeOfBench[i] };
                    dt = db.executePROC("spGetAllBancoReservaByTipo", paramName, paramValue);

                    if (dt.Rows.Count > 0)
                    {
                        for (int j = 0; j < dt.Rows.Count; j++)
                        {
                            benchPlayersModel = new BenchModes();
                            benchPlayersModel.id = Convert.ToInt16(dt.Rows[j]["ID_BANCO_RESERVA"]);
                            benchPlayersModel.userID = Convert.ToInt16(dt.Rows[j]["ID_USUARIO"]);
                            benchPlayersModel.name = dt.Rows[j]["NM_USUARIO"].ToString();
                            benchPlayersModel.psnID = dt.Rows[j]["PSN_ID"].ToString();
                            benchPlayersModel.state = dt.Rows[j]["DS_ESTADO"].ToString();
                            benchPlayersModel.team = dt.Rows[j]["NM_TIME_FUT"].ToString();
                            benchPlayersModel.typeBench = typeOfBench[i];
                            listOfBench.Add(benchPlayersModel);

                        }
                    }

                }

                listBenchPlayers.listBench = listOfBench;
                listBenchPlayers.returnMessage = "getBenchSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, listBenchPlayers);
                //return Ok(listBenchPlayers);

            }
            catch (Exception ex)
            {
                listBenchPlayers = new BenchModesViewModel();
                listBenchPlayers.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, listBenchPlayers);

            }
            finally
            {
                db.closeConnection();
                benchPlayersModel = null;
                listBenchPlayers = null;
                listOfBench = null;
                dt = null;

            }
        }
    }
}
