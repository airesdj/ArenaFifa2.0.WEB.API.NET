using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipTeamController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAllByChampionship(int id)
        {

            ChampionshipTeamDetailsModel modelDetails = new ChampionshipTeamDetailsModel();
            ChampionshipTeamListViewModel mainModel = new ChampionshipTeamListViewModel();
            List<ChampionshipTeamDetailsModel> listOfModel = new List<ChampionshipTeamDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllTimesOfCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipTeamDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.type = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfTeam = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipTeamListViewModel();
                mainModel.listOfTeam = new List<ChampionshipTeamDetailsModel>();
                mainModel.returnMessage = "errorGetAllChampionshipTeam_" + ex.Message;
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