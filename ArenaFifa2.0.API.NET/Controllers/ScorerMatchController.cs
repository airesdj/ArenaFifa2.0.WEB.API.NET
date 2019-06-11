using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.ScorerMatchModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ScorerMatchController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postRequest(ScorerMatchViewModel model)
        {

            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser == "save_all_by_match")
                {
                    paramName = new string[] { "pIdCamp", "pIdJogo", "pIdsGoleadorHome", "pQtGolsGoleadorHome", "pIdsGoleadorAway", "pQtGolsGoleadorAway" };
                    paramValue = new string[] { Convert.ToString(model.championshipID), Convert.ToString(model.matchID), model.loadScorersIDHome,
                                               model.loadScorersGoalsHome, model.loadScorersIDAway, model.loadScorersGoalsAway };
                    dt = db.executePROC("spAddLoadGoleadorJogo", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "delete_all_by_match")
                {
                    paramName = new string[] { "pIdJogo" };
                    paramValue = new string[] { Convert.ToString(model.matchID) };
                    dt = db.executePROC("spDeleteAllGoleadorJogo", paramName, paramValue);

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
                model.returnMessage = "errorScorerMatch_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;

            }
        }

        [HttpGet]
        public IHttpActionResult GetAllByMatch(string id)
        {

            ScorerMatchViewModel mainModel = new ScorerMatchViewModel();
            DataTable dt = null;
            db.openConnection();


            try
            {
                string[] arrayParam = id.Split(Convert.ToChar("|"));

                paramName = new string[] { "pIdCamp", "pIdJogo" };
                paramValue = new string[] { arrayParam[0], arrayParam[1] };
                dt = db.executePROC("spGetAllGoleadoresByJogo", paramName, paramValue);

                if (dt.Rows.Count > 0)
                {
                    mainModel.listOfScorerMatch = setUpListDetailsScorers(dt);
                }

                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);

            }
            catch (Exception ex)
            {
                mainModel.listOfScorerMatch = new List<ScorerMatchDetails>();
                mainModel.returnMessage = "errorGetScorerMatch_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            finally
            {
                db.closeConnection();
                dt = null;
                mainModel = null;
            }

        }

        private List<ScorerMatchDetails> setUpListDetailsScorers(DataTable dt)
        {
            List<ScorerMatchDetails> oList = new List<ScorerMatchDetails>();
            ScorerMatchDetails modelDetails = new ScorerMatchDetails();
            try
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ScorerMatchDetails();
                    modelDetails.scorerID = Convert.ToInt32(dt.Rows[i]["ID_GOLEADOR"].ToString());
                    modelDetails.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                    modelDetails.scorerNickname = dt.Rows[i]["NM_GOLEADOR"].ToString();
                    modelDetails.scorerName = dt.Rows[i]["NM_GOLEADOR_COMPLETO"].ToString();
                    modelDetails.sideScorer = dt.Rows[i]["TP_TIME"].ToString();
                    modelDetails.totalGoals = Convert.ToInt32(dt.Rows[i]["QT_GOLS"].ToString());
                    oList.Add(modelDetails);
                }
                return oList;
            }
            catch
            {
                return new List<ScorerMatchDetails>();
            }
            finally
            {
                oList = null;
                modelDetails = null;
            }
        }
    }
}
