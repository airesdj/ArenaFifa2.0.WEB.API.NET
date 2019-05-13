using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.TeamModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class TeamController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult team(TeamListViewModel model)
        {

            db.openConnection();
            DataTable dt = null;
            TeamDetailsModel modelDetails = new TeamDetailsModel();

            try
            {

                if (model.actionUser == "add")
                {
                    //model.returnMessage = "subscribeBenchSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "current")
                {

                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetIDCurrentTemporada", paramName, paramValue);

                    //SetDetailsSeason(dt, seasonDetails);

                    modelDetails.returnMessage = "subscribeBenchSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);

                }
            }
            catch (Exception ex)
            {
                model = new TeamListViewModel();
                model.listOfTeam = new List<TeamDetailsModel>();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                modelDetails = null;

            }


        }

        [HttpGet]
        public IHttpActionResult GetTeamDetails(string id)
        {

            TeamDetailsModel modelDetails = new TeamDetailsModel();
            TeamListViewModel mainModel = new TeamListViewModel();
            List<TeamDetailsModel> listOfModel = new List<TeamDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                if (id.All(char.IsDigit))
                {
                    paramName = new string[] { "idTime" };
                    paramValue = new string[] { id };
                    dt = db.executePROC("spGetTime", paramName, paramValue);

                    if (dt.Rows.Count > 0)
                    {
                        modelDetails.id = Convert.ToUInt16(id);
                        modelDetails.name = dt.Rows[0]["NM_TIME"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[0]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                            modelDetails.teamDeleted = Convert.ToByte(dt.Rows[0]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_TIME_SOFIFA"].ToString()))
                            modelDetails.teamSofifaID = Convert.ToInt32(dt.Rows[0]["ID_TIME_SOFIFA"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["IN_TIME_COM_IMAGEM"].ToString()))
                            modelDetails.hasImage = Convert.ToByte(dt.Rows[0]["IN_TIME_COM_IMAGEM"].ToString());
                        modelDetails.typeModeID = Convert.ToUInt16(dt.Rows[0]["ID_TIPO_TIME"].ToString());
                        modelDetails.typeMode = dt.Rows[0]["DS_TIPO"].ToString();
                    }

                    modelDetails.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

                }
                else
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetAllTimes" + id, paramName, paramValue);

                    mainModel.teamType = id;

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new TeamDetailsModel();
                        modelDetails.id = Convert.ToUInt16(dt.Rows[i]["ID_TIME"].ToString());
                        modelDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                            modelDetails.teamDeleted = Convert.ToByte(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["ID_TIME_SOFIFA"].ToString()))
                            modelDetails.teamSofifaID = Convert.ToInt32(dt.Rows[i]["ID_TIME_SOFIFA"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString()))
                            modelDetails.hasImage = Convert.ToByte(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString());
                        modelDetails.typeModeID = Convert.ToUInt16(dt.Rows[i]["ID_TIPO_TIME"].ToString());
                        modelDetails.typeMode = dt.Rows[i]["DS_TIPO"].ToString();
                        listOfModel.Add(modelDetails);
                    }

                    mainModel.listOfTeam = listOfModel;
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }

            }
            catch (Exception ex)
            {
                modelDetails = new TeamDetailsModel();
                modelDetails.returnMessage = "errorGetTeamDetails_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
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