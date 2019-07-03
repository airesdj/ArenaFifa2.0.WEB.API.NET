using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipMatchTableModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipMatchTableController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult ChampionshipMatchTable(ChampionshipMatchTableDetailsModel model)
        {

            ChampionshipMatchTableListViewModel mainModel = new ChampionshipMatchTableListViewModel();
            ChampionshipMatchTableClashesHistoryTotalswModel modelHistory = new ChampionshipMatchTableClashesHistoryTotalswModel();
            ChampionshipMatchTableClashesHistoryTotalsByTeamswModel modelHistoryTeams = new ChampionshipMatchTableClashesHistoryTotalsByTeamswModel();
            ChampionshipMatchTableDetailsModel modelDetails = new ChampionshipMatchTableDetailsModel();
            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser.ToLower() == "save_simple_result")
                {

                    paramName = new string[] { "pIdJogo", "pIdCamp", "pGoalsTimeHome", "pGoalsTimeAway", "pIdUsuAcao", "pPsnIdUsuAcao"};

                    paramValue = new string[] { Convert.ToString(model.matchID), Convert.ToString(model.championshipID), Convert.ToString(model.totalGoalsHome),
                                                Convert.ToString(model.totalGoalsAway), Convert.ToString(model.userIDAction), model.psnIDAction};

                    dt = db.executePROC("spSaveSimpleResultTabelaJogo", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "decree_result")
                {

                    paramName = new string[] { "pIdJogo", "pIdCamp", "pGoalsTimeHome", "pGoalsTimeAway", "pIdUsuAcao", "pPsnIdUsuAcao", "pMessage", "pSgTpListaNegra" };

                    paramValue = new string[] { Convert.ToString(model.matchID), Convert.ToString(model.championshipID), Convert.ToString(model.totalGoalsHome),
                                                Convert.ToString(model.totalGoalsAway), Convert.ToString(model.userIDAction), model.psnIDAction,
                                                model.messageBlackList, model.typeBlackList};

                    dt = db.executePROC("spDecreeSimpleResultTabelaJogo", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "delete_result_launched")
                {

                    paramName = new string[] { "pIdJogo", "pIdUsuAcao", "pPsnIdUsuAcao" };

                    paramValue = new string[] { Convert.ToString(model.matchID), Convert.ToString(model.userIDAction), model.psnIDAction};

                    dt = db.executePROC("spDeleteResultTabelaJogo", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "show_historic_each_team")
                {

                    List<ChampionshipMatchTableDetailsModel> listOfModel = new List<ChampionshipMatchTableDetailsModel>();

                    paramName = new string[] { "pIdCamp", "pIdTimeCasa", "pIdVisitante", "pTotalRegistroCada" };
                    paramValue = new string[] { model.championshipID.ToString(), model.teamHomeID.ToString(), model.teamAwayID.ToString(), model.totalRecordsOfHistoric.ToString() };
                    dt = db.executePROC("spGetAllTabelaJogoAllHistoricoByTimes", paramName, paramValue);
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new ChampionshipMatchTableDetailsModel();
                        modelDetails.championshipName = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                        modelDetails.stageID = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                        modelDetails.stageName = dt.Rows[i]["NM_FASE"].ToString();
                        modelDetails.startDate = Convert.ToDateTime(dt.Rows[i]["DT_TABELA_INICIO_JOGO"].ToString());
                        modelDetails.endDate = Convert.ToDateTime(dt.Rows[i]["DT_TABELA_FIM_JOGO"].ToString());
                        modelDetails.teamHomeID = Convert.ToInt16(dt.Rows[i]["ID_TIME_CASA"].ToString());
                        modelDetails.totalGoalsHome = dt.Rows[i]["QT_GOLS_TIME_CASA"].ToString();
                        modelDetails.teamAwayID = Convert.ToInt16(dt.Rows[i]["ID_TIME_VISITANTE"].ToString());
                        modelDetails.totalGoalsAway = dt.Rows[i]["QT_GOLS_TIME_VISITANTE"].ToString();
                        modelDetails.round = Convert.ToInt16(dt.Rows[i]["IN_NUMERO_RODADA"].ToString());
                        modelDetails.teamNameHome = dt.Rows[i]["1T"].ToString();
                        modelDetails.teamTypeHome = dt.Rows[i]["DT1"].ToString();
                        modelDetails.psnIDHome = dt.Rows[i]["PSN1"].ToString();
                        modelDetails.teamNameAway = dt.Rows[i]["2T"].ToString();
                        modelDetails.teamTypeAway = dt.Rows[i]["DT2"].ToString();
                        modelDetails.psnIDAway = dt.Rows[i]["PSN2"].ToString();
                        listOfModel.Add(modelDetails);
                    }
                    if (listOfModel!= null)
                        mainModel.listOfMatch = listOfModel;
                    else
                        mainModel.listOfMatch = new List<ChampionshipMatchTableDetailsModel>();

                    listOfModel = null;

                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else if (model.actionUser.ToLower() == "get_clashes_by_team")
                {

                    List<ChampionshipMatchTableClashesByTeamModel> listOfModel = new List<ChampionshipMatchTableClashesByTeamModel>();
                    ChampionshipMatchTableClashesByTeamModel modelClashDetails = new ChampionshipMatchTableClashesByTeamModel();
                    int _teamID = 0;

                    paramName = new string[] { "pIdCamp", "pIdUsu" };
                    paramValue = new string[] { model.championshipID.ToString(), model.userIDAction.ToString() };
                    dt = db.executePROC("spGetDetailsMatchesByTimeFromCampeonato", paramName, paramValue);
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        if (_teamID != Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString()))
                        {
                            if (_teamID > 0) { listOfModel.Add(modelClashDetails); }
                            modelClashDetails = new ChampionshipMatchTableClashesByTeamModel();
                            modelClashDetails.userID = model.userIDAction;
                            modelClashDetails.championshipID = model.championshipID;
                            modelClashDetails.teamID = Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString());
                            modelClashDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                            _teamID = modelClashDetails.teamID;
                        }
                        //modelClashDetails = new ChampionshipMatchTableClashesByTeamModel();
                        if (dt.Rows[i]["ID_ROUND"].ToString()=="0")
                        {
                            modelClashDetails.nextMatchTeamID = Convert.ToInt32(dt.Rows[i]["ID_TIME_NEXT_MATCH"].ToString());
                            modelClashDetails.nextMatchTeamName = dt.Rows[i]["NM_TIME_NEXT_MATCH"].ToString();
                            modelClashDetails.descriptionNextMatch = dt.Rows[i]["DS_MATCTH_1"].ToString();
                        }
                        else if (dt.Rows[i]["ID_ROUND"].ToString() == "1")
                        {
                            modelClashDetails.descriptionPreviousMatch1_1 = dt.Rows[i]["DS_MATCTH_1"].ToString();
                            modelClashDetails.descriptionPreviousMatch1_2 = dt.Rows[i]["DS_MATCTH_2"].ToString();
                            modelClashDetails.descriptionPreviousMatch1_3 = dt.Rows[i]["DS_MATCTH_3"].ToString();
                            modelClashDetails.descriptionPreviousMatch1_4 = dt.Rows[i]["DS_MATCTH_4"].ToString();
                            modelClashDetails.statusPreviousMatch1 = dt.Rows[i]["STATUS_MATCTH"].ToString();
                        }
                        else if (dt.Rows[i]["ID_ROUND"].ToString() == "2")
                        {
                            modelClashDetails.descriptionPreviousMatch2_1 = dt.Rows[i]["DS_MATCTH_1"].ToString();
                            modelClashDetails.descriptionPreviousMatch2_2 = dt.Rows[i]["DS_MATCTH_2"].ToString();
                            modelClashDetails.descriptionPreviousMatch2_3 = dt.Rows[i]["DS_MATCTH_3"].ToString();
                            modelClashDetails.descriptionPreviousMatch2_4 = dt.Rows[i]["DS_MATCTH_4"].ToString();
                            modelClashDetails.statusPreviousMatch2 = dt.Rows[i]["STATUS_MATCTH"].ToString();
                        }
                        else if (dt.Rows[i]["ID_ROUND"].ToString() == "3")
                        {
                            modelClashDetails.descriptionPreviousMatch3_1 = dt.Rows[i]["DS_MATCTH_1"].ToString();
                            modelClashDetails.descriptionPreviousMatch3_2 = dt.Rows[i]["DS_MATCTH_2"].ToString();
                            modelClashDetails.descriptionPreviousMatch3_3 = dt.Rows[i]["DS_MATCTH_3"].ToString();
                            modelClashDetails.descriptionPreviousMatch3_4 = dt.Rows[i]["DS_MATCTH_4"].ToString();
                            modelClashDetails.statusPreviousMatch3 = dt.Rows[i]["STATUS_MATCTH"].ToString();
                        }
                        //listOfModel.Add(modelClashDetails);
                    }
                    if (dt.Rows.Count > 0) { listOfModel.Add(modelClashDetails); }
                    if (listOfModel != null)
                        mainModel.listOfClashes = listOfModel;
                    else
                        mainModel.listOfClashes = new List<ChampionshipMatchTableClashesByTeamModel>();

                    listOfModel = null;
                    modelClashDetails = null;

                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else if (model.actionUser.ToLower() == "clashes_historic_by_coaches")
                {
                    paramName = new string[] { "pType", "pIdUsuLogged", "pPsnIDSearch" };
                    paramValue = new string[] { model.modeType, model.userIDAction.ToString(), model.psnIDSearch };
                    dt = db.executePROC("spGetTotalsClashesHistory", paramName, paramValue);
                    if (dt.Rows.Count > 0)
                    {
                        if (dt.Rows[0]["errorID"].ToString() == "0")
                        {
                            modelHistory.userIDLogged = model.userIDAction;
                            modelHistory.psnIDLogged = model.psnIDAction;
                            modelHistory.userIDSearch = Convert.ToInt32(dt.Rows[0]["idUsuSearch"].ToString());
                            modelHistory.psnIDSearch = model.psnIDSearch;
                            modelHistory.totalWinUsuLogged = Convert.ToInt16(dt.Rows[0]["totalWinUsuLogged"].ToString());
                            modelHistory.totalWinUsuSearch = Convert.ToInt16(dt.Rows[0]["totalWinUsuSearch"].ToString());
                            modelHistory.totalDraw = Convert.ToInt16(dt.Rows[0]["totalDraw"].ToString());
                            modelHistory.totalLossUsuLogged = Convert.ToInt16(dt.Rows[0]["totalLossUsuLogged"].ToString());
                            modelHistory.totalLossUsuSearch = Convert.ToInt16(dt.Rows[0]["totalLossUsuSearch"].ToString());
                            modelHistory.totalGoalsUsuLogged = Convert.ToInt16(dt.Rows[0]["totalGoalsUsuLogged"].ToString());
                            modelHistory.totalGoalsUsuSearch = Convert.ToInt16(dt.Rows[0]["totalGoalsUsuSearch"].ToString());

                            modelHistory.returnMessage = "ModeratorSuccessfully";

                            modelHistory.listOfMatchDraw = new List<ChampionshipMatchTableDetailsModel>();
                            modelHistory.listOfMatchWinUsuLogged = new List<ChampionshipMatchTableDetailsModel>();
                            modelHistory.listOfMatchWinUsuSearch = new List<ChampionshipMatchTableDetailsModel>();

                            paramName = new string[] { "pType", "pIdUsuLogged", "pIdUsuSearch" };
                            paramValue = new string[] { model.modeType, modelHistory.userIDLogged.ToString(), modelHistory.userIDSearch.ToString() };
                            dt = db.executePROC("spGetAllClashesHistory", paramName, paramValue);
                            for (var i = 0; i < dt.Rows.Count; i++)
                            {
                                modelDetails = GlobalFunctions.setDetailsChampionshipMatchTable(dt.Rows[i]);

                                if (modelDetails.totalGoalsHome == modelDetails.totalGoalsAway)
                                    modelHistory.listOfMatchDraw.Add(modelDetails);
                                else if (Convert.ToInt16(modelDetails.totalGoalsHome) > Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.userHomeID == modelHistory.userIDLogged)
                                    modelHistory.listOfMatchWinUsuLogged.Add(modelDetails);
                                else if (Convert.ToInt16(modelDetails.totalGoalsHome) > Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.userHomeID == modelHistory.userIDSearch)
                                    modelHistory.listOfMatchWinUsuSearch.Add(modelDetails);
                                else if (Convert.ToInt16(modelDetails.totalGoalsHome) < Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.userAwayID == modelHistory.userIDLogged)
                                    modelHistory.listOfMatchWinUsuLogged.Add(modelDetails);
                                else if (Convert.ToInt16(modelDetails.totalGoalsHome) < Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.userAwayID == modelHistory.userIDSearch)
                                    modelHistory.listOfMatchWinUsuSearch.Add(modelDetails);

                            }
                        }
                        else
                            modelHistory.returnMessage = "PsnIDSearchNotFound";
                    }
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelHistory);
                }
                else if (model.actionUser.ToLower() == "clashes_historic_by_teams")
                {
                    paramName = new string[] { "pType", "pIdTimeHome", "pIdTimeAway" };
                    paramValue = new string[] { model.modeType, model.teamHomeID.ToString(), model.teamAwayID.ToString() };
                    dt = db.executePROC("spGetTotalsClashesHistoryByTimes", paramName, paramValue);
                    if (dt.Rows.Count > 0)
                    {
                        modelHistoryTeams.teamIDHome = model.teamHomeID;
                        modelHistoryTeams.teamIDAway = model.teamAwayID;
                        modelHistoryTeams.teamNameHome = dt.Rows[0]["nmTimeHome"].ToString();
                        modelHistoryTeams.teamNameAway = dt.Rows[0]["nmTimeAway"].ToString();
                        modelHistoryTeams.totalDraw = Convert.ToInt16(dt.Rows[0]["totalDraw"].ToString());
                        modelHistoryTeams.totalWinTeamHome = Convert.ToInt16(dt.Rows[0]["totalWinUsuLogged"].ToString());
                        modelHistoryTeams.totalWinTeamAway = Convert.ToInt16(dt.Rows[0]["totalWinUsuSearch"].ToString());
                        modelHistoryTeams.totalLossTeamHome = Convert.ToInt16(dt.Rows[0]["totalLossUsuLogged"].ToString());
                        modelHistoryTeams.totalLossTeamAway = Convert.ToInt16(dt.Rows[0]["totalLossUsuSearch"].ToString());
                        modelHistoryTeams.totalGoalsTeamHome = Convert.ToInt16(dt.Rows[0]["totalGoalsUsuLogged"].ToString());
                        modelHistoryTeams.totalGoalsTeamAway = Convert.ToInt16(dt.Rows[0]["totalGoalsUsuSearch"].ToString());

                        modelHistoryTeams.returnMessage = "ModeratorSuccessfully";

                        modelHistoryTeams.listOfMatchDraw = new List<ChampionshipMatchTableDetailsModel>();
                        modelHistoryTeams.listOfMatchWinTeamHome = new List<ChampionshipMatchTableDetailsModel>();
                        modelHistoryTeams.listOfMatchWinTeamAway = new List<ChampionshipMatchTableDetailsModel>();

                        paramName = new string[] { "pType", "pIdTimeHome", "pIdTimeAway" };
                        paramValue = new string[] { model.modeType, model.teamHomeID.ToString(), model.teamAwayID.ToString() };
                        dt = db.executePROC("spGetAllClashesHistoryByTeams", paramName, paramValue);
                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            modelDetails = GlobalFunctions.setDetailsChampionshipMatchTable(dt.Rows[i]);

                            if (modelDetails.totalGoalsHome == modelDetails.totalGoalsAway)
                                modelHistoryTeams.listOfMatchDraw.Add(modelDetails);
                            else if (Convert.ToInt16(modelDetails.totalGoalsHome) > Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.teamHomeID == modelHistoryTeams.teamIDHome)
                                modelHistoryTeams.listOfMatchWinTeamHome.Add(modelDetails);
                            else if (Convert.ToInt16(modelDetails.totalGoalsHome) > Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.teamHomeID == modelHistoryTeams.teamIDAway)
                                modelHistoryTeams.listOfMatchWinTeamAway.Add(modelDetails);
                            else if (Convert.ToInt16(modelDetails.totalGoalsHome) < Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.teamAwayID == modelHistoryTeams.teamIDHome)
                                modelHistoryTeams.listOfMatchWinTeamHome.Add(modelDetails);
                            else if (Convert.ToInt16(modelDetails.totalGoalsHome) < Convert.ToInt16(modelDetails.totalGoalsAway) && modelDetails.teamAwayID == modelHistoryTeams.teamIDAway)
                                modelHistoryTeams.listOfMatchWinTeamAway.Add(modelDetails);

                        }
                    }
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelHistoryTeams);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "errorPostChampionshipMatchTable_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                mainModel = null;
                modelDetails = null;
                modelHistory = null;
                modelHistoryTeams = null;
            }


        }


        [HttpGet]
        public IHttpActionResult GetAllForChampionship(string id)
        {

            ChampionshipMatchTableDetailsModel modelDetails = new ChampionshipMatchTableDetailsModel();
            ChampionshipMatchTableListViewModel mainModel = new ChampionshipMatchTableListViewModel();
            List<ChampionshipMatchTableDetailsModel> listOfModel = new List<ChampionshipMatchTableDetailsModel>();
            DataTable dt = null;
            db.openConnection();
            int roundStageAux = -10;
            int roundAux = 0;
            string roundQualifyDescription = String.Empty;

            try
            {

                if (id.All(char.IsDigit))
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { id };
                    dt = db.executePROC("spGetTabelaJogoAllDetailsOfCampeonato", paramName, paramValue);
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {

                        modelDetails = GlobalFunctions.setDetailsChampionshipMatchTable(dt.Rows[i]);

                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_BLACK_LIST"].ToString()))
                            modelDetails.typeBlackList = dt.Rows[i]["IN_BLACK_LIST"].ToString();

                        if ((roundAux != modelDetails.round && modelDetails.stageID == 0) || (roundStageAux != modelDetails.stageID && modelDetails.stageID != 0 && modelDetails.playoffGame == 0) || (modelDetails.playoffGame > 0))
                        {
                            if (modelDetails.stageID == 0) { roundQualifyDescription = modelDetails.round.ToString("00") + "ª Rodada - "; }
                            else { roundQualifyDescription = String.Empty; }
                            modelDetails.roundDetails = roundQualifyDescription +
                                                        modelDetails.startDate.ToString("dd/MM") + " (" + modelDetails.startDate.DayOfWeek.ToString().Substring(0, 3) + ") à " +
                                                        modelDetails.endDate.ToString("dd/MM") + " (" + modelDetails.endDate.DayOfWeek.ToString().Substring(0, 3) + ")";

                            roundAux = modelDetails.round;
                            roundStageAux = modelDetails.stageID;
                        }

                        listOfModel.Add(modelDetails);
                    }

                    mainModel.listOfMatch = listOfModel;
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else
                {
                    int i = 0;
                    string[] param = id.Split(Convert.ToChar(";"));
                    paramName = new string[] { "pIdCamp", "pIdJogo" };
                    paramValue = new string[] { param[0], param[1] };
                    dt = db.executePROC("spGetTabelaJogoDetailsOfCampeonato", paramName, paramValue);

                    if (dt.Rows.Count > 0) {
                        modelDetails.matchID = Convert.ToInt16(dt.Rows[i]["ID_TABELA_JOGO"].ToString());
                        modelDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                        modelDetails.championshipName = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                        modelDetails.modeType = dt.Rows[i]["TP_CAMPEONATO"].ToString();
                        modelDetails.stageID = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                        modelDetails.stageName = dt.Rows[i]["NM_FASE"].ToString();
                        modelDetails.groupID = Convert.ToInt16(dt.Rows[i]["ID_Grupo"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["NM_Grupo"].ToString()))
                            modelDetails.groupName = dt.Rows[i]["NM_Grupo"].ToString();
                        modelDetails.seasonName = dt.Rows[i]["NM_TEMPORADA"].ToString();
                        modelDetails.startDate = Convert.ToDateTime(dt.Rows[i]["DT_TABELA_INICIO_JOGO"].ToString());
                        modelDetails.endDate = Convert.ToDateTime(dt.Rows[i]["DT_TABELA_FIM_JOGO"].ToString());
                        modelDetails.teamHomeID = Convert.ToInt16(dt.Rows[i]["ID_TIME_CASA"].ToString());
                        modelDetails.totalGoalsHome = dt.Rows[i]["QT_GOLS_TIME_CASA"].ToString();
                        modelDetails.teamAwayID = Convert.ToInt16(dt.Rows[i]["ID_TIME_VISITANTE"].ToString());
                        modelDetails.totalGoalsAway = dt.Rows[i]["QT_GOLS_TIME_VISITANTE"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[i]["DT_EFETIVACAO_JOGO"].ToString()))
                            modelDetails.launchDate = Convert.ToDateTime(dt.Rows[i]["DT_EFETIVACAO_JOGO"].ToString());
                        modelDetails.round = Convert.ToInt16(dt.Rows[i]["IN_NUMERO_RODADA"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_JOGO_MATAXMATA"].ToString()))
                            modelDetails.playoffGame = Convert.ToInt16(dt.Rows[i]["IN_JOGO_MATAXMATA"].ToString());
                        modelDetails.teamURLHome = dt.Rows[i]["DS_URL1"].ToString();
                        modelDetails.teamNameHome = dt.Rows[i]["1T"].ToString();
                        modelDetails.teamTypeHome = dt.Rows[i]["DT1"].ToString();
                        modelDetails.userHomeID = Convert.ToInt32(dt.Rows[i]["ID1"].ToString());
                        modelDetails.userHomeName = dt.Rows[i]["NM_Tecnico_TimeCasa"].ToString();
                        modelDetails.psnIDHome = dt.Rows[i]["PSN1"].ToString();
                        modelDetails.teamURLAway = dt.Rows[i]["DS_URL2"].ToString();
                        modelDetails.teamNameAway = dt.Rows[i]["2T"].ToString();
                        modelDetails.teamTypeAway = dt.Rows[i]["DT2"].ToString();
                        modelDetails.userAwayID = Convert.ToInt32(dt.Rows[i]["ID2"].ToString());
                        modelDetails.userAwayName = dt.Rows[i]["NM_Tecnico_TimeVisitante"].ToString();
                        modelDetails.psnIDAway = dt.Rows[i]["PSN2"].ToString();

                        if (modelDetails.stageID == 0) { roundQualifyDescription = modelDetails.round.ToString("00") + "ª Rodada - "; }
                        else { roundQualifyDescription = String.Empty; }
                        modelDetails.roundDetails = roundQualifyDescription +
                                                    modelDetails.startDate.ToString("dd/MM") + " (" + modelDetails.startDate.DayOfWeek.ToString().Substring(0, 3) + ") à " +
                                                    modelDetails.endDate.ToString("dd/MM") + " (" + modelDetails.endDate.DayOfWeek.ToString().Substring(0, 3) + ")";
                        if (!String.IsNullOrEmpty(modelDetails.groupName))
                            modelDetails.roundDetails = modelDetails.groupName + " - " + modelDetails.roundDetails;

                    }
                    modelDetails.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
                }


            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipMatchTableListViewModel();
                mainModel.listOfMatch = new List<ChampionshipMatchTableDetailsModel>();
                mainModel.returnMessage = "errorGetAllMatchTableForChampionship_" + ex.Message;
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