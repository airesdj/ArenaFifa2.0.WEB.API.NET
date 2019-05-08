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
        public IHttpActionResult postBench(BenchModesViewModel model)
        {

            db.openConnection();
            var objFunctions = new Commons.functions();
            BenchDetailsModel benchPlayersModel = new BenchDetailsModel();
            BenchModesViewModel listBenchPlayers = new BenchModesViewModel();
            List<BenchDetailsModel> listOfBench = new List<BenchDetailsModel>();
            DataTable dt = null;
            try
            {

                if (model.actionUser == "listMainPage")
                {
                    string[] typeOfBench = { "H2H", "FUT", "PRO" };

                    for (int i = 0; i < typeOfBench.Length; i++)
                    {

                        paramName = new string[] { "pTpBancoReserva" };
                        paramValue = new string[] { typeOfBench[i] };
                        dt = db.executePROC("spGetAllBancoReservaByTipo", paramName, paramValue);

                        if (dt.Rows.Count > 0)
                        {
                            for (int j = 0; j < dt.Rows.Count; j++)
                            {
                                benchPlayersModel = new BenchDetailsModel();
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

                    listBenchPlayers.listOfBench = listOfBench;
                    listBenchPlayers.returnMessage = "getBenchSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, listBenchPlayers);
                }
                else if(model.actionUser == "dellCrud")
                {

                    BenchDetailsModel oDetails = model.listOfBench[0];

                    paramName = new string[] { "pIdBancoReserva" };
                    paramValue = new string[] { Convert.ToString(oDetails.id) };
                    dt = db.executePROC("spUpdateToEndBancoReservaById", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "moveCrud")
                {

                    BenchDetailsModel oDetails = model.listOfBench[0];

                    paramName = new string[] { "pIdBancoReserva" };
                    paramValue = new string[] { Convert.ToString(oDetails.id) };
                    dt = db.executePROC("spAddBancoReservaToEndOfQueue", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "addCrud")
                {

                    BenchDetailsModel oDetails = model.listOfBench[0];

                    paramName = new string[] { "pIdUsu", "pNmTime", "pTpBanco" };
                    paramValue = new string[] { Convert.ToString(oDetails.userID), oDetails.team, oDetails.typeBench };
                    dt = db.executePROC("spAddBancoReserva", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
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

        [HttpGet]
        public IHttpActionResult GetAllBench()
        {

            BenchModesViewModel benchModel = new BenchModesViewModel();
            BenchDetailsModel benchDetails = new BenchDetailsModel();
            List<BenchDetailsModel> listOfBench = new List<BenchDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllBancoReservaNoFilterCRUD", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    benchDetails = new BenchDetailsModel();
                    benchDetails.id = Convert.ToInt16(dt.Rows[i]["ID_BANCO_RESERVA"].ToString());
                    benchDetails.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    benchDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    benchDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    benchDetails.typeBench = dt.Rows[i]["TP_BANCO_RESERVA"].ToString();
                    benchDetails.team = dt.Rows[i]["NM_TIME_FUT"].ToString();

                    listOfBench.Add(benchDetails);
                }

                benchModel.listOfBench = listOfBench;
                benchModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, benchModel);

            }
            catch (Exception ex)
            {
                benchModel = new BenchModesViewModel();
                benchModel.listOfBench = new List<BenchDetailsModel>();
                benchModel.returnMessage = "errorGetAllSeasons_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, benchModel);
            }
            finally
            {
                db.closeConnection();
                benchDetails = null;
                benchModel = null;
                listOfBench = null;
                dt = null;
            }

        }


        [HttpGet]
        public IHttpActionResult GetBench(int id)
        {

            BenchModesViewModel benchModel = new BenchModesViewModel();
            BenchDetailsModel benchDetails = new BenchDetailsModel();
            List<BenchDetailsModel> listOfBench = new List<BenchDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] { "pIdBancoReserva" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetBancoReserva", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    benchDetails = new BenchDetailsModel();
                    benchDetails.id = Convert.ToInt16(dt.Rows[i]["ID_BANCO_RESERVA"].ToString());
                    benchDetails.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    benchDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    benchDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    benchDetails.typeBench = dt.Rows[i]["TP_BANCO_RESERVA"].ToString();
                    benchDetails.team = dt.Rows[i]["NM_TIME_FUT"].ToString();

                    listOfBench.Add(benchDetails);
                }

                benchModel.listOfBench = listOfBench;
                benchModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, benchModel);

            }
            catch (Exception ex)
            {
                benchModel = new BenchModesViewModel();
                benchModel.listOfBench = new List<BenchDetailsModel>();
                benchModel.returnMessage = "errorGetAllSeasons_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, benchModel);
            }
            finally
            {
                db.closeConnection();
                benchDetails = null;
                benchModel = null;
                listOfBench = null;
                dt = null;
            }

        }

    }
}
