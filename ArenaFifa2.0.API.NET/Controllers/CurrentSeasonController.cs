using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.CurrentSeasonModel;
using static ArenaFifa20.API.NET.Models.ScorerModel;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamTableModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Text;

namespace ArenaFifa20.API.NET.Controllers
{
    public class CurrentSeasonController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult getPost(CurrentSeasonSummaryViewModel model)
        {

            CurrentSeasonSummaryViewModel CurrentSeasonModel = new CurrentSeasonSummaryViewModel();
            CurrentSeasonMenuViewModel MenuModel = new CurrentSeasonMenuViewModel();
            ChampionshipTeamTableDetailsModel teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
            db.openConnection();
            DataTable dt = null;
            string returnMessage = String.Empty;
            StringBuilder strConcat = new StringBuilder();
            try
            {
                CurrentSeasonModel.listOfScorersH2H = new List<listScorers>();
                CurrentSeasonModel.listOfScorersPRO = new List<listScorers>();
                CurrentSeasonModel.listOfTeamTableSerieA = new List<ChampionshipTeamTableDetailsModel>();
                CurrentSeasonModel.listOfTeamTableSerieB = new List<ChampionshipTeamTableDetailsModel>();
                CurrentSeasonModel.userID = model.userID;
                CurrentSeasonModel.modeType = model.modeType;
                CurrentSeasonModel.actionUser = model.actionUser;

                if (model.actionUser == "summary")
                {
                    CurrentSeasonModel.menuCurrentSeason = getDetailsMenu(CurrentSeasonModel.modeType, CurrentSeasonModel.userID, 0, db);

                    paramName = new string[] { "pType" };
                    paramValue = new string[] { model.modeType };
                    dt = db.executePROC("spGetSummaryCurrentSeason", paramName, paramValue);

                    CurrentSeasonModel.modeType = model.modeType;

                    if (dt.Rows.Count > 0)
                    {
                        CurrentSeasonModel.totalGoals = Convert.ToInt16(dt.Rows[0]["totalGoals"].ToString());
                        CurrentSeasonModel.totalMatches = Convert.ToInt16(dt.Rows[0]["totalMatches"].ToString());
                        CurrentSeasonModel.averageGoals = Convert.ToInt16(dt.Rows[0]["averageGoals"].ToString());

                        if (CurrentSeasonModel.modeType=="H2H")
                            CurrentSeasonModel.listOfScorersH2H = GlobalFunctions.getListScorers("H2H", db, 0);
                        else if (CurrentSeasonModel.modeType == "PRO")
                            CurrentSeasonModel.listOfScorersPRO = GlobalFunctions.getListScorers("PRO", db, 0);

                        if (CurrentSeasonModel.menuCurrentSeason.championshipSerieAID > 0 && CurrentSeasonModel.menuCurrentSeason.championshipSerieAForGroup == 0)
                            CurrentSeasonModel.listOfTeamTableSerieA = getListTeamTableByChampionship(CurrentSeasonModel.menuCurrentSeason.championshipSerieAID, db);

                        if (CurrentSeasonModel.menuCurrentSeason.championshipSerieBID > 0 && CurrentSeasonModel.menuCurrentSeason.championshipSerieBForGroup == 0)
                            CurrentSeasonModel.listOfTeamTableSerieB = getListTeamTableByChampionship(CurrentSeasonModel.menuCurrentSeason.championshipSerieBID, db);

                        CurrentSeasonModel.menuCurrentSeason.listOActiveChampionship = GlobalFunctions.getAllActiveChampionshipCurrentSeason(db, 
                                                                                       CurrentSeasonModel.menuCurrentSeason.currentChampionshipID, CurrentSeasonModel.modeType);

                        CurrentSeasonModel.menuCurrentSeason.currentChampionshipDetails = GlobalFunctions.getChampionshipDetails(db, CurrentSeasonModel.menuCurrentSeason.currentChampionshipID);

                        CurrentSeasonModel.returnMessage = "CurrentSeasonSuccessfully";
                    }
                    else
                        CurrentSeasonModel.returnMessage = "CurrentSeasonNotFound";

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, CurrentSeasonModel);
                }
                if (model.actionUser == "just_menu")
                {
                    MenuModel = getDetailsMenu(CurrentSeasonModel.modeType, CurrentSeasonModel.userID, 0, db);

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MenuModel);
                }
                if (model.actionUser == "getAllForecastSecondStage")
                {
                    CurrentSeasonModel.listOfForecastTeamQualified = new List<ChampionshipTeamTableDetailsModel>();
                    CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace = new List<ChampionshipTeamTableDetailsModel>();

                    for (int j = 1; j<= model.totalGroupPerChampionship; j++)
                    {
                        paramName = new string[] { "pIdCamp", "pIdGrupo", "pTotalQualified" };
                        paramValue = new string[] { model.championshipID.ToString(), j.ToString(), model.totalQualifiedPerGroup.ToString() };
                        dt = db.executePROC("spGetAllClassificacaoTimeOfCampeonatoByGrupo", paramName, paramValue);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                            teamTableDetailsModel.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                            CurrentSeasonModel.listOfForecastTeamQualified.Add(teamTableDetailsModel);
                        }
                    }

                    if (CurrentSeasonModel.listOfForecastTeamQualified.Count> 0)
                    {
                        strConcat.Clear();
                        foreach (ChampionshipTeamTableDetailsModel item in CurrentSeasonModel.listOfForecastTeamQualified)
                        {
                            if (strConcat.ToString() != string.Empty) { strConcat.Append(","); }
                            strConcat.Append(item.teamID.ToString());
                        }

                        CurrentSeasonModel.listOfForecastTeamQualified = new List<ChampionshipTeamTableDetailsModel>();

                        paramName = new string[] { "pIdCamp", "pIdsTime" };
                        paramValue = new string[] { model.championshipID.ToString(), strConcat.ToString() };
                        dt = db.executePROC("spGetLoadClassificacaoTimeOfCampeonato", paramName, paramValue);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                            teamTableDetailsModel.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                            teamTableDetailsModel.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                            teamTableDetailsModel.groupID = Convert.ToInt16(dt.Rows[i]["ID_GRUPO"].ToString());
                            teamTableDetailsModel.totalPoint = Convert.ToInt16(dt.Rows[i]["QT_PONTOS_GANHOS"].ToString());
                            teamTableDetailsModel.totalPlayed = Convert.ToInt16(dt.Rows[i]["QT_JOGOS"].ToString());
                            teamTableDetailsModel.teamName = dt.Rows[i]["NM_TIME"].ToString();
                            teamTableDetailsModel.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                            teamTableDetailsModel.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            teamTableDetailsModel.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            CurrentSeasonModel.listOfForecastTeamQualified.Add(teamTableDetailsModel);
                        }
                    }


                    if (model.placeQualifiedPerGroup>0)
                    {
                        for (int j = 1; j <= model.totalGroupPerChampionship; j++)
                        {
                            paramName = new string[] { "pIdCamp", "pIdGrupo", "pTotalQualified" };
                            paramValue = new string[] { model.anotherChampionshipID.ToString(), j.ToString(), model.placeQualifiedPerGroup.ToString() };
                            dt = db.executePROC("spGetAllClassificacaoTimeOfCampeonato", paramName, paramValue);

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (i == (model.placeQualifiedPerGroup-1))
                                {
                                    teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                                    teamTableDetailsModel.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                                    CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace.Add(teamTableDetailsModel);
                                }
                            }
                        }

                        if (CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace.Count > 0)
                        {
                            strConcat.Clear();
                            foreach (ChampionshipTeamTableDetailsModel item in CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace)
                            {
                                if (strConcat.ToString() != string.Empty) { strConcat.Append(","); }
                                else { strConcat.Append(item.teamID.ToString()); }
                            }

                            CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace = new List<ChampionshipTeamTableDetailsModel>();

                            paramName = new string[] { "pIdCamp", "pIdsTime" };
                            paramValue = new string[] { model.anotherChampionshipID.ToString(), strConcat.ToString() };
                            dt = db.executePROC("spGetLoadClassificacaoTimeOfCampeonato", paramName, paramValue);

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                                teamTableDetailsModel.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                                teamTableDetailsModel.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                                teamTableDetailsModel.groupID = Convert.ToInt16(dt.Rows[i]["ID_GRUPO"].ToString());
                                teamTableDetailsModel.totalPoint = Convert.ToInt16(dt.Rows[i]["QT_PONTOS_GANHOS"].ToString());
                                teamTableDetailsModel.totalPlayed = Convert.ToInt16(dt.Rows[i]["QT_JOGOS"].ToString());
                                teamTableDetailsModel.teamName = dt.Rows[i]["NM_TIME"].ToString();
                                teamTableDetailsModel.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                                teamTableDetailsModel.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                                teamTableDetailsModel.psnID = dt.Rows[i]["PSN_ID"].ToString();
                                CurrentSeasonModel.listOfForecastTeamQualifiedThirdPlace.Add(teamTableDetailsModel);
                            }
                        }


                    }

                    CurrentSeasonModel.returnMessage = "CurrentSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, CurrentSeasonModel);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                CurrentSeasonModel.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, CurrentSeasonModel);
            }
            finally
            {
                db.closeConnection();
                dt = null;
                CurrentSeasonModel = null;
                MenuModel = null;
                teamTableDetailsModel = null;
                strConcat = null;
            }

        }

        private CurrentSeasonMenuViewModel getDetailsMenu(string modeType, int userActionID, int championshipID, connectionMySQL db)
        {
            CurrentSeasonMenuViewModel model = new CurrentSeasonMenuViewModel();
            DataTable dt = null;
            try
            {

                paramName = new string[] { "pType", "pIdUsu", "pIdCamp" };
                paramValue = new string[] { modeType, userActionID.ToString(), championshipID.ToString() };
                dt = db.executePROC("spGetDetailsMenuCurrentSeason", paramName, paramValue);

                model.modeType = modeType;

                if (dt.Rows.Count > 0)
                {
                    model.currentSeasonName = dt.Rows[0]["seasonName"].ToString();
                    model.currentChampionshipID = Convert.ToInt16(dt.Rows[0]["championshipID"].ToString());
                    model.currentChampionshipName = dt.Rows[0]["championshipName"].ToString();
                    model.currentChampionshipForGroup = Convert.ToInt16(dt.Rows[0]["championchipForGroup"].ToString());
                    model.championshipSerieAID = Convert.ToInt16(dt.Rows[0]["serieA"].ToString());
                    model.championshipSerieBID = Convert.ToInt16(dt.Rows[0]["serieB"].ToString());
                    model.championshipSerieAForGroup = Convert.ToInt16(dt.Rows[0]["serieAForGroup"].ToString());
                    model.championshipSerieBForGroup = Convert.ToInt16(dt.Rows[0]["serieBForGroup"].ToString());
                    model.teamName = dt.Rows[0]["teamName"].ToString();
                    model.userHasTeamFUT = Convert.ToInt16(dt.Rows[0]["userHasTeamFUT"].ToString());
                    model.userHasTeamPRO = Convert.ToInt16(dt.Rows[0]["userHasTeamPRO"].ToString());

                    model.returnMessage = "CurrentSeasonSuccessfully";
                }

                return model;
            }
            catch (Exception ex)
            {
                model = new CurrentSeasonMenuViewModel();
                return model;
            }
            finally
            {
                dt = null;
                model = null;
            }

        }

        private List<ChampionshipTeamTableDetailsModel> getListTeamTableByChampionship(int id, connectionMySQL db)
        {
            ChampionshipTeamTableDetailsModel modelDetails = new ChampionshipTeamTableDetailsModel();
            List<ChampionshipTeamTableDetailsModel> listOfModel = new List<ChampionshipTeamTableDetailsModel>();
            DataTable dt = null;
            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetFirstClassificacaoTimeOfCampeonatoForSummary", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipTeamTableDetailsModel();
                    modelDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                    modelDetails.totalPoint = Convert.ToInt16(dt.Rows[i]["QT_PONTOS_GANHOS"].ToString());
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    listOfModel.Add(modelDetails);
                }
                return listOfModel;
            }
            catch (Exception ex)
            {
                listOfModel = new List<ChampionshipTeamTableDetailsModel>();
                return listOfModel;
            }
            finally
            {
                dt = null;
                listOfModel = null;
                modelDetails = null;
            }

        }

    }
}