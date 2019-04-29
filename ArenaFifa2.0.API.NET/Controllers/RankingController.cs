using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.RankingModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class RankingController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult ranking(SummaryViewModel model)
        {


            db.openConnection();
            DataTable dt = null;
            listScorers listScorers = new listScorers();
            List<listScorers> listOfScorersH2H = new List<listScorers>();
            List<listScorers> listOfScorersPRO = new List<listScorers>();

            try
            {

                if (model.actionUser == "summary")
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetSummaryRanking", paramName, paramValue);

                    model.totGoalsH2H = Convert.ToInt16(dt.Rows[0]["totalGoalsH2H"].ToString());
                    model.totGoalsFUT = Convert.ToInt16(dt.Rows[0]["totalGoalsFUT"].ToString());
                    model.totGoalsPRO = Convert.ToInt16(dt.Rows[0]["totalGoalsPRO"].ToString());

                    model.seasonNameH2H = dt.Rows[0]["seasonNameH2H"].ToString();
                    model.seasonNameFUT = dt.Rows[0]["seasonNameFUT"].ToString();
                    model.seasonNamePRO = dt.Rows[0]["seasonNamePRO"].ToString();

                    paramName = new string[] { "pMode" };
                    paramValue = new string[] { "H2H" };
                    dt = db.executePROC("spGetSummaryRankingListScorers", paramName, paramValue);

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        listScorers = new listScorers();
                        listScorers.playerName = dt.Rows[i]["NM_GOLEADOR"].ToString();
                        listScorers.psnID = dt.Rows[i]["PSN_ID"].ToString();
                        listScorers.teamName = dt.Rows[i]["NM_TIME"].ToString() + "-" + dt.Rows[i]["DS_Tipo"].ToString();
                        listScorers.totalGoals = Convert.ToInt16(dt.Rows[i]["QT_GOLS_MARCADOS"].ToString());
                        listOfScorersH2H.Add(listScorers);
                    }

                    model.listOfScorersH2H = listOfScorersH2H;

                    paramName = new string[] { "pMode" };
                    paramValue = new string[] { "PRO" };
                    dt = db.executePROC("spGetSummaryRankingListScorers", paramName, paramValue);

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        listScorers = new listScorers();
                        listScorers.playerName = dt.Rows[i]["NM_GOLEADOR"].ToString();
                        listScorers.psnID = dt.Rows[i]["PSN_ID"].ToString();
                        listScorers.teamName = dt.Rows[i]["NM_TIME"].ToString() + "-" + dt.Rows[i]["DS_Tipo"].ToString();
                        listScorers.totalGoals = Convert.ToInt16(dt.Rows[i]["QT_GOLS_MARCADOS"].ToString());
                        listOfScorersPRO.Add(listScorers);
                    }

                    model.listOfScorersPRO = listOfScorersPRO;


                    model.returnMessage = "RankingSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                model = new SummaryViewModel();
                model.listOfScorersH2H = new List<listScorers>();
                model.listOfScorersPRO = new List<listScorers>();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
            }
            finally
            {
                db.closeConnection();
                dt = null;
                listScorers = null;
                listOfScorersH2H = null;
                listOfScorersPRO = null;
            }

        }


    }
}