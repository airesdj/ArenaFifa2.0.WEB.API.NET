using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.UserTeamModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class UserTeamController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAllByChampionship(int id)
        {

            UserTeamDetailsModel modelDetails = new UserTeamDetailsModel();
            UserTeamViewModel mainModel = new UserTeamViewModel();
            List<UserTeamDetailsModel> listOfModel = new List<UserTeamDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { id.ToString() };
                dt = db.executePROC("spGetAllUsuarioTimeOfCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new UserTeamDetailsModel();
                    modelDetails.championshipID = id;
                    modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.teamID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfModel.Add(modelDetails);
                }
                if (dt.Rows.Count>0) { mainModel.drawDone = 1; } else { mainModel.drawDone = 0; }
                mainModel.listOfUserTeam = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new UserTeamViewModel();
                mainModel.listOfUserTeam = new List<UserTeamDetailsModel>();
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