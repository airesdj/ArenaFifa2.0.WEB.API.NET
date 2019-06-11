using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipUserModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipUserController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAllByChampionship(string id)
        {

            ChampionshipUserDetailsModel modelDetails = new ChampionshipUserDetailsModel();
            ChampionshipUserListViewModel mainModel = new ChampionshipUserListViewModel();
            List<ChampionshipUserDetailsModel> listOfModel = new List<ChampionshipUserDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                if (id.All(char.IsDigit))
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { id };
                    dt = db.executePROC("spGetAllUsuariosOfCampeonato", paramName, paramValue);

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new ChampionshipUserDetailsModel();
                        modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                        modelDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                        modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                        modelDetails.email = dt.Rows[i]["DS_EMAIL"].ToString();
                        listOfModel.Add(modelDetails);
                    }

                }
                else
                {
                    if (id.IndexOf("BCO")==-1 && id.IndexOf("|") == -1)
                    {
                        paramName = new string[] { "pTipo" };
                        paramValue = new string[] { id };
                        dt = db.executePROC("spGetAllUsuariosOfCampeonatoByTipo", paramName, paramValue);
                    }
                    else if (id.IndexOf("BCO") > -1 && id.IndexOf("|") == -1)
                    {
                        paramName = new string[] { "pTpBancoReserva" };
                        paramValue = new string[] { id.Substring(4,3) };
                        dt = db.executePROC("spGetAllBancoReservaByTipo", paramName, paramValue);
                    }
                    else if (id.IndexOf("BCO") == -1 && id.IndexOf("|") > -1)
                    {
                        string[] arrayParam = id.Split(Convert.ToChar("|"));

                        paramName = new string[] { "pIdCamp", "pTipo" };
                        paramValue = new string[] { arrayParam[0], arrayParam[1] };
                        dt = db.executePROC("spGetAllCampeonatoUsuarioToExchange", paramName, paramValue);
                    }

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new ChampionshipUserDetailsModel();
                        modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                        modelDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                        modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                        modelDetails.email = dt.Rows[i]["DS_EMAIL"].ToString();
                        listOfModel.Add(modelDetails);
                    }

                }

                mainModel.listOfUser = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipUserListViewModel();
                mainModel.listOfUser = new List<ChampionshipUserDetailsModel>();
                mainModel.returnMessage = "errorGetAllChampionshipUser_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                mainModel = null;
                listOfModel = null;
                dt = null;
            }

        }

    }
}