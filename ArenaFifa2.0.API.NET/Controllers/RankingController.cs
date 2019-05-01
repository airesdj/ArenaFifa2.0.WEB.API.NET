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
            try
            {

                if (model.actionUser == "summary")
                {

                    listScorers listScorers = new listScorers();
                    List<listScorers> listOfScorersH2H = new List<listScorers>();
                    List<listScorers> listOfScorersPRO = new List<listScorers>();

                    try
                    {
                        paramName = new string[] { };
                        paramValue = new string[] { };
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
                        listScorers = null;
                        listOfScorersH2H = null;
                        listOfScorersPRO = null;
                    }

                }
                else if (model.actionUser == "rankingGeneral")
                {

                    RankingViewModel rankingModel = new RankingViewModel();
                    listRanking ranking;
                    List<listRanking> listOfRanking = new List<listRanking>();
                    int halfStars = 0;
                    int fullStars = 0;
                    double generalUse = 0;
                    int totalMaxStars = 5;


                    try
                    {
                        paramName = new string[] { "pTotalRecords", "pTypeMode" };
                        paramValue = new string[] { Convert.ToString(model.totalRecordsRanking), model.typeMode};
                        dt = db.executePROC("spGetAllGeneralRanking", paramName, paramValue);

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            ranking = new listRanking();
                            ranking.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                            ranking.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            ranking.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            ranking.state = dt.Rows[i]["DS_ESTADO"].ToString();
                            ranking.total = Convert.ToUInt16(dt.Rows[i]["PT_TOTAL"].ToString());
                            ranking.totalSeason = Convert.ToUInt16(dt.Rows[i]["PT_TOTAL_TEMPORADA"].ToString());
                            ranking.totalPreviousSeason = Convert.ToUInt16(dt.Rows[i]["PT_TOTAL_TEMPORADA_ANTERIOR"].ToString());
                            ranking.totalLeague = Convert.ToUInt16(dt.Rows[i]["PT_LIGAS"].ToString());
                            ranking.totalCup = Convert.ToUInt16(dt.Rows[i]["PT_COPAS"].ToString());
                            ranking.position = Convert.ToInt16(dt.Rows[i]["IN_POSICAO_ATUAL"].ToString());

                            ranking.totalHalfStars = 0;
                            ranking.totalStars = 0;
                            ranking.totalEmptyStars = 0;

                            if (String.IsNullOrEmpty(dt.Rows[i]["PC_APROVEITAMENTO_GERAL"].ToString()))
                            {
                                ranking.totalEmptyStars = totalMaxStars;
                            }
                            else
                            {
                                generalUse = Convert.ToDouble(dt.Rows[i]["PC_APROVEITAMENTO_GERAL"].ToString());

                                if (generalUse <= 0)
                                {
                                    fullStars = 0;
                                    halfStars = 0;
                                }
                                else if (generalUse > 0 && generalUse < 10)
                                {
                                    fullStars = 1;
                                    halfStars = 0;
                                }
                                else if (generalUse >= 10 && generalUse < 20)
                                {
                                    fullStars = 1;
                                    halfStars = 1;
                                }
                                else if (generalUse >= 20 && generalUse < 30)
                                {
                                    fullStars = 2;
                                    halfStars = 0;
                                }
                                else if (generalUse >= 30 && generalUse < 40)
                                {
                                    fullStars = 2;
                                    halfStars = 1;
                                }
                                else if (generalUse >= 40 && generalUse < 50)
                                {
                                    fullStars = 3;
                                    halfStars = 0;
                                }
                                else if (generalUse >= 50 && generalUse < 60)
                                {
                                    fullStars = 3;
                                    halfStars = 1;
                                }
                                else if (generalUse >= 60 && generalUse < 70)
                                {
                                    fullStars = 4;
                                    halfStars = 0;
                                }
                                else if (generalUse >= 70 && generalUse < 75)
                                {
                                    fullStars = 4;
                                    halfStars = 1;
                                }
                                else if (generalUse >= 75 && generalUse <= 100)
                                {
                                    fullStars = 5;
                                    halfStars = 0;
                                }

                                for (var j = 1; j<= totalMaxStars; j++)
                                {
                                    if (fullStars>=j) { ranking.totalStars += 1; }
                                    else if (fullStars < j && halfStars==1) { halfStars = 0; ranking.totalHalfStars += 1; }
                                    else if (fullStars < j && halfStars == 0) { ranking.totalEmptyStars += 1; }
                                }
                            }
                            listOfRanking.Add(ranking);
                        }

                        rankingModel.listOfRanking = listOfRanking;
                        rankingModel.returnMessage = "RankingSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    catch (Exception ex)
                    {
                        rankingModel = new RankingViewModel();
                        rankingModel.listOfRanking = new List<listRanking>();
                        rankingModel.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    finally
                    {
                        rankingModel = null;
                        ranking = null;
                        listOfRanking = null;
                    }
                }
                else if (model.actionUser == "rankingCurrent")
                {

                    RankingViewModel rankingModel = new RankingViewModel();
                    listRanking ranking;
                    List<listRanking> listOfRanking = new List<listRanking>();


                    try
                    {
                        paramName = new string[] { "pTypeMode" };
                        paramValue = new string[] { model.typeMode };
                        dt = db.executePROC("spGetAllRankingCurrent", paramName, paramValue);

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            ranking = new listRanking();
                            ranking.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                            ranking.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            ranking.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            ranking.teamName = dt.Rows[i]["NM_TIME"].ToString();
                            ranking.state = dt.Rows[i]["DS_ESTADO"].ToString();
                            ranking.total = Convert.ToUInt16(dt.Rows[i]["PT_TOTAL"].ToString());
                            listOfRanking.Add(ranking);
                        }

                        rankingModel.listOfRanking = listOfRanking;
                        rankingModel.returnMessage = "RankingSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    catch (Exception ex)
                    {
                        rankingModel = new RankingViewModel();
                        rankingModel.listOfRanking = new List<listRanking>();
                        rankingModel.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    finally
                    {
                        rankingModel = null;
                        ranking = null;
                        listOfRanking = null;
                    }
                }
                else if (model.actionUser == "rankingByDivision")
                {

                    RankingViewModel rankingModel = new RankingViewModel();
                    listRanking ranking;
                    List<listRanking> listOfRanking = new List<listRanking>();


                    try
                    {
                        paramName = new string[] { "pSiglaCamp", "pTypeMode" };
                        paramValue = new string[] { model.typeChampionship, model.typeMode };
                        dt = db.executePROC("spGetRankingByDivision", paramName, paramValue);

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            ranking = new listRanking();
                            ranking.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                            ranking.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            ranking.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            ranking.teamName = dt.Rows[i]["NM_TIME"].ToString();
                            ranking.state = dt.Rows[i]["DS_ESTADO"].ToString();
                            ranking.total = Convert.ToUInt16(dt.Rows[i]["PT_TOTAL"].ToString());
                            ranking.inAccessCurrentSeason = dt.Rows[i]["IN_ACESSO_TEMP_ATUAL"].ToString();
                            ranking.inRelegatePreviousSeason = dt.Rows[i]["IN_REBAIXADO_TEMP_ANTERIOR"].ToString();
                            listOfRanking.Add(ranking);
                        }

                        rankingModel.typeMode = model.typeMode;
                        rankingModel.typeChampionship = model.typeChampionship;
                        rankingModel.listOfRanking = listOfRanking;
                        rankingModel.returnMessage = "RankingSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    catch (Exception ex)
                    {
                        rankingModel = new RankingViewModel();
                        rankingModel.listOfRanking = new List<listRanking>();
                        rankingModel.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, rankingModel);

                    }
                    finally
                    {
                        rankingModel = null;
                        ranking = null;
                        listOfRanking = null;
                    }
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
            }

        }


    }
}