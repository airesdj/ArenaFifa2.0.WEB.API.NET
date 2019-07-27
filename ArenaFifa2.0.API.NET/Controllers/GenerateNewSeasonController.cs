using System;
using System.Web.Http;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using static ArenaFifa20.API.NET.Models.GenerateNewSeasonModel;
using System.Configuration;

namespace ArenaFifa20.API.NET.Controllers
{
    public class GenerateNewSeasonController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult getPost(GenerateNewSeasonDetailsModel model)
        {
            db.openConnection(GlobalVariables.DATABASE_NAME_STAGING);
            StandardGenerateNewSeasonChampionshipLeagueDetailsModel modelLeague = null;
            StandardGenerateNewSeasonChampionshipCupDetailsModel modelCup = null;
            GenerateNewSeasonGenerateModel modelGenerate = new GenerateNewSeasonGenerateModel(); ;
            DataTable dt = null;
            int i, j = 0;
            string[] allChampionshipsSelected = { };
            Boolean VARIABLE_FALSE = false;
            Boolean VARIABLE_TRUE = true;


            try
            {
                if (model.actionUser == "getSeasonDetails")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetAllSeasonDetailsNewTemporada", paramName, paramValue);

                    model.seasonID = Convert.ToInt16(dt.Rows[0]["ID_TEMPORADA"].ToString());
                    model.seasonName = dt.Rows[0]["NM_TEMPORADA"].ToString();
                    model.userID = Convert.ToInt16(dt.Rows[0]["ID_USUARIO"].ToString());
                    model.userName = dt.Rows[0]["NM_USUARIO"].ToString();
                    model.psnID = dt.Rows[0]["PSN_ID"].ToString();
                    model.drawDate = Convert.ToDateTime(dt.Rows[0]["DATA_SORTEIO"].ToString());
                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "getAllChampionshipsActiveDetails")
                {
                    paramName = new string[] { "pTpModalidade" };
                    paramValue = new string[] { model.modeType };
                    dt = db.executePROC("spGetAllChampionshipTypesNewTemporadaByMode", paramName, paramValue);

                    model.listChampionshipLeagueDetails = new List<StandardGenerateNewSeasonChampionshipLeagueDetailsModel>();
                    model.listChampionshipCupDetails = new List<StandardGenerateNewSeasonChampionshipCupDetailsModel>();
                    model.listOfTeams = new List<GenerateNewSeasonStandardDetailsModel>();

                    for (i = 0; i < dt.Rows.Count; i++)
                    {
                        if (GlobalVariables.GENERATE_NEWSEASON_CHAMPIONSHIP_ALLSERIES.IndexOf(dt.Rows[i]["SG_CAMPEONATO"].ToString()) > -1)
                            model.listChampionshipLeagueDetails.Add(getDetailsChampionshipLeague(model.modeType, dt.Rows[i]["SG_CAMPEONATO"].ToString()));
                        else
                            model.listChampionshipCupDetails.Add(getDetailsChampionshipCup(model.modeType, dt.Rows[i]["SG_CAMPEONATO"].ToString()));
                    }

                    getAllTeamToTheMainModel(ref model);

                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "saveChampionshipsLeagueDetails")
                {

                    paramName = new string[] { "pIdTemporada", "pNmTemporada", "pIdUsu", "pNmUsu", "pPsnID", "pDtSorteio" };
                    paramValue = new string[] { model.seasonID.ToString(), model.seasonName, model.userID.ToString(), model.userName, model.psnID, model.drawDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]" };
                    db.executePROCNonResult("spAddUpdateSeasonGenerateNewSeason", paramName, paramValue);

                    for (i = 0; i < model.listChampionshipLeagueDetails.Count; i++)
                    {
                        modelLeague = model.listChampionshipLeagueDetails[i];

                        string active = Convert.ToBoolean(modelLeague.hasChampionship) ? "1" : "0";
                        string byGroup = Convert.ToBoolean(modelLeague.championship_ByGroup) ? "1" : "0";
                        string byGroupPots = Convert.ToBoolean(modelLeague.championship_byGroupPots) ? "1" : "0";
                        string doubleRound = Convert.ToBoolean(modelLeague.championship_DoubleRound) ? "1" : "0";

                        paramName = new string[] { "pTpModalidade", "pSgCampeonato", "pDtInicio", "pQtTimes", "pQtDiasFase0", "pQtDiasPlayoff",
                                                   "pQtTimesRebaixados", "pInAtivo", "pInPorGrupo", "pQtGrupos", "pInPorPotes", "pInDoubleRound"};
                        paramValue = new string[] { modelLeague.modeType, modelLeague.championshipType, modelLeague.startDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                    modelLeague.totalTeams.ToString(), modelLeague.totalDaysToPlayStage0.ToString(), modelLeague.totalDaysToPlayPlayoff.ToString(),
                                                    modelLeague.totalRelegate.ToString(), active, byGroup, modelLeague.totalGroups.ToString(),
                                                    byGroupPots, doubleRound};
                        db.executePROCNonResult("spUpdateChampionshipLeagueGenerateNewSeason", paramName, paramValue);
                    }

                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "saveChampionshipsCupDetails")
                {
                    for (i = 0; i < model.listChampionshipCupDetails.Count; i++)
                    {
                        modelCup = model.listChampionshipCupDetails[i];

                        string active = Convert.ToBoolean(modelCup.hasChampionship) ? "1" : "0";
                        string byGroup = Convert.ToBoolean(modelCup.championship_ByGroup) ? "1" : "0";
                        string byGroupPots = Convert.ToBoolean(modelCup.championship_byGroupPots) ? "1" : "0";
                        string destiny = Convert.ToBoolean(modelCup.hasChampionshipDestiny) ? "1" : "0";
                        string source = Convert.ToBoolean(modelCup.hasChampionshipSource) ? "1" : "0";
                        string justSerieA = Convert.ToBoolean(modelCup.hasJust_SerieA) ? "1" : "0";
                        string justSerieB = Convert.ToBoolean(modelCup.hasJust_SerieB) ? "1" : "0";
                        string justSerieC = Convert.ToBoolean(modelCup.hasJust_SerieC) ? "1" : "0";
                        string serieA_B = Convert.ToBoolean(modelCup.has_SerieA_B) ? "1" : "0";
                        string serieA_B_C = Convert.ToBoolean(modelCup.has_SerieA_B_C) ? "1" : "0";
                        string serieA_B_C_D = Convert.ToBoolean(modelCup.has_SerieA_B_C_D) ? "1" : "0";
                        string nationalTeam = Convert.ToBoolean(modelCup.has_NationalTeams) ? "1" : "0";

                        paramName = new string[] { "pTpModalidade", "pSgCampeonato", "pDtInicio", "pQtTimes", "pQtDiasFase0", "pQtDiasPlayoff",
                                                   "pInAtivo", "pInPorGrupo", "pQtGrupos", "pInPorPotes", "pInDestino", "pInOrigem", "pInSerieA",
                                                   "pInSerieB", "pInSerieC", "pInSerieA_B", "pInSerieA_B_C", "pInSerieA_B_C_D", "pInSelecao"};
                        paramValue = new string[] { modelCup.modeType, modelCup.championshipType, modelCup.startDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                    modelCup.totalTeams.ToString(), modelCup.totalDaysToPlayStage0.ToString(), modelCup.totalDaysToPlayPlayoff.ToString(),
                                                    active, byGroup, modelCup.totalGroups.ToString(), byGroupPots, destiny, source, justSerieA, justSerieB, justSerieC,
                                                    serieA_B, serieA_B_C, serieA_B_C_D, nationalTeam};
                        db.executePROCNonResult("spUpdateChampionshipCupGenerateNewSeason", paramName, paramValue);
                    }

                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "addTeam")
                {
                    paramName = new string[] { "pTpModalidade", "pSgCampeonato", "pIdStandard", "pIdItem", "pIdNumPote" };
                    paramValue = new string[] { model.modeType, model.championshipType, GlobalVariables.GENERATE_NEWSEASON_ITEM_TYPE_TEAM.ToString(),
                                                model.itemID.ToString(), model.poteNumber.ToString() };
                    db.executePROCNonResult("spAddTeamGenerateNewSeason", paramName, paramValue);

                    getAllTeamToTheMainModel(ref model);

                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "delTeam")
                {
                    paramName = new string[] { "pTpModalidade", "pSgCampeonato", "pIdStandard", "pIdItem", "pNmItem" };
                    paramValue = new string[] { model.modeType, model.championshipType, GlobalVariables.GENERATE_NEWSEASON_ITEM_TYPE_TEAM.ToString(),
                                                model.itemID.ToString(), model.itemName };
                    db.executePROCNonResult("spDeleteTeamGenerateNewSeason", paramName, paramValue);

                    getAllTeamToTheMainModel(ref model);

                    model.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "validate")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spValidGenerationNewSeason", paramName, paramValue);

                    modelGenerate.DatabasesLookTheSame = false;
                    modelGenerate.NewSeasonIsGenerated = false;
                    modelGenerate.hasEuroCup = false;
                    modelGenerate.hasEuropeLeague = false;
                    modelGenerate.hasSerieB_FUT = false;
                    modelGenerate.hasSerieB_PRO = false;
                    modelGenerate.hasSerieD_H2H = false;
                    modelGenerate.hasWorldCup = false;

                    if (dt.Rows[0]["databasesLookTheSame"].ToString() == "1")
                        modelGenerate.DatabasesLookTheSame = true;

                    if (dt.Rows[0]["generateNewSeasonIsDone"].ToString() == "1")
                        modelGenerate.NewSeasonIsGenerated = true;

                    if (dt.Rows[0]["hasWorldCup"].ToString() == "1")
                        modelGenerate.hasWorldCup = true;

                    if (dt.Rows[0]["hasEuroCup"].ToString() == "1")
                        modelGenerate.hasEuroCup = true;

                    if (dt.Rows[0]["hasSerieD_H2H"].ToString() == "1")
                        modelGenerate.hasSerieD_H2H = true;

                    if (dt.Rows[0]["hasSerieB_FUT"].ToString() == "1")
                        modelGenerate.hasSerieB_FUT = true;

                    if (dt.Rows[0]["hasSerieB_PRO"].ToString() == "1")
                        modelGenerate.hasSerieB_PRO = true;

                    if (dt.Rows[0]["hasEuroLeague"].ToString() == "1")
                        modelGenerate.hasEuropeLeague = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "prepare-database-bkp")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spPrepareDatabaseBKPToNegerateNewSeason", paramName, paramValue);

                    modelGenerate.DatabasesLookTheSame = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "prepare-generate")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spInitializeProxTemporada", paramName, paramValue);

                    modelGenerate.currentSeasonID = Convert.ToInt16(dt.Rows[0]["PreviousTemporadaID"].ToString());
                    modelGenerate.preparationBkpDatabaseIsDone = true;

                    //Today (23/07/19) we don't keep more the match comments
                    modelGenerate.preparationCommentDatabaseIsDone = true;


                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-calculate-season-h2h")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp" };
                    paramValue = new string[] { modelGenerate.currentSeasonID.ToString() };
                    dt = db.executePROC("spCalculateEndOfTemporadaH2H", paramName, paramValue);

                    modelGenerate.seasonID = Convert.ToInt16(dt.Rows[0]["NewTemporadaID"].ToString());
                    modelGenerate.seasonName = dt.Rows[0]["NewTemporadaName"].ToString();

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-calculate-season-fut")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pIdNewTemp" };
                    paramValue = new string[] { modelGenerate.currentSeasonID.ToString(), modelGenerate.seasonID.ToString() };
                    db.executePROCNonResult("spCalculateEndOfTemporadaFUT", paramName, paramValue);

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-calculate-season-pro")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pIdNewTemp" };
                    paramValue = new string[] { modelGenerate.currentSeasonID.ToString(), modelGenerate.seasonID.ToString() };
                    db.executePROCNonResult("spCalculateEndOfTemporadaPRO", paramName, paramValue);

                    modelGenerate.calculateEndOfSeasonIsDone = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-championships-league-h2h")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "SERIE_A", "DIV1", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.serieAID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.serieAID_H2H > 0) { modelGenerate.serieAIsGenerated_H2H = true; }

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "SERIE_B", "DIV2", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.serieBID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.serieBID_H2H > 0) { modelGenerate.serieBIsGenerated_H2H = true; }

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "SERIE_C", "DIV3", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.serieCID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.serieCID_H2H > 0) { modelGenerate.serieCIsGenerated_H2H = true; }

                    modelGenerate.serieDID_H2H = 0;
                    if (modelGenerate.hasSerieD_H2H)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "SERIE_D", "DIV4", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.serieDID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.serieDID_H2H > 0) { modelGenerate.serieDIsGenerated_H2H = true; }
                    }

                    paramName = new string[] { "pIdTemp", "pIdSerieA", "pIdSerieB", "pIdSerieC", "pIdSerieD", "pQtLimitMaxLstNegra", "pCodAcessoTapetao",
                                               "pCodAcesso", "pCodAcessoRelegated", "pCodAcessoInvited" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), modelGenerate.serieAID_H2H.ToString(), modelGenerate.serieBID_H2H.ToString(),
                                                modelGenerate.serieCID_H2H.ToString(), modelGenerate.serieDID_H2H.ToString(), 
                                                ConfigurationManager.AppSettings["renewal.total.limit.blackList"].ToString(), ConfigurationManager.AppSettings["access.current.season.access.direct"].ToString(),
                                                ConfigurationManager.AppSettings["access.current.season.access"].ToString(), ConfigurationManager.AppSettings["access.current.season.access"].ToString(),
                                                ConfigurationManager.AppSettings["access.current.season.invite"].ToString()};
                    dt = db.executePROC("spRellocationLigasH2H", paramName, paramValue);
                    modelGenerate.rellocationOfSeries_H2H = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-championships-cup-h2h")
                {
                    modelGenerate = model.newSeasonModel;

                    modelGenerate.worldCupID_H2H = 0;
                    if (modelGenerate.hasWorldCup)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "WORLDCP", "CPDM", VARIABLE_TRUE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.worldCupID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.worldCupID_H2H > 0) { modelGenerate.worldCupIsGenerated = true; }
                    }

                    modelGenerate.euroCupID_H2H = 0;
                    if (modelGenerate.hasEuroCup)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "EUROCUP", "ERCP", VARIABLE_TRUE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.euroCupID_H2H = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.euroCupID_H2H > 0) { modelGenerate.euroCupIsGenerated = true; }
                    }




                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "CHAMPLG", "CPGL", VARIABLE_TRUE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.championsLeagueID = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.championsLeagueID > 0) { modelGenerate.championsLeagueIsGenerated = true; }

                    modelGenerate.europeLeagueID = 0;
                    if (modelGenerate.hasEuropeLeague)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "EUROPLG", "CPSA", VARIABLE_TRUE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.europeLeagueID = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.europeLeagueID > 0) { modelGenerate.europeLeagueIsGenerated = true; }
                    }

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "H2H", "UEFACUP", "CPGL", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.uefaCupID = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.uefaCupID > 0) { modelGenerate.uefaCupIsGenerated = true; }

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-championships-fut")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "FUT", "SERIE_A", "FUT1", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.serieAID_FUT = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.serieAID_FUT > 0) { modelGenerate.serieAIsGenerated_FUT = true; }

                    modelGenerate.serieBID_FUT = 0;
                    if (modelGenerate.hasSerieB_FUT)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "FUT", "SERIE_B", "FUT2", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.serieBID_FUT = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.serieBID_FUT > 0) { modelGenerate.serieBIsGenerated_FUT = true; }
                    }

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "FUT", "FUT-CUP", "CFUT", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.futCupID = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.futCupID > 0) { modelGenerate.futCupIsGenerated = true; }


                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-championships-pro")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "PRO", "SERIE_A", "PRO1", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.serieAID_PRO = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.serieAID_PRO > 0) { modelGenerate.serieAIsGenerated_PRO = true; }

                    modelGenerate.serieBID_PRO = 0;
                    if (modelGenerate.hasSerieB_PRO)
                    {
                        paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                        paramValue = new string[] { modelGenerate.seasonID.ToString(), "PRO", "SERIE_B", "PRO2", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                        dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                        modelGenerate.serieBID_PRO = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                        if (modelGenerate.serieBID_PRO > 0) { modelGenerate.serieBIsGenerated_PRO = true; }
                    }

                    paramName = new string[] { "pIdTemp", "pTpModalidade", "pSgCampeonato", "pTpCamp", "pByGroup" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), "PRO", "PRO-CUP", "CPRO", VARIABLE_FALSE.ToString() + ";[BOOLEAN-TYPE]" };
                    dt = db.executePROC("spAddNewChampionship", paramName, paramValue);
                    modelGenerate.proCupID = Convert.ToInt16(dt.Rows[0]["idCampNew"].ToString());
                    if (modelGenerate.proCupID > 0) { modelGenerate.proCupIsGenerated = true; }



                    paramName = new string[] { "pIdTemp", "pIdCamp" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), modelGenerate.proCupID.ToString() };
                    dt = db.executePROC("spSubscriptionPlayersForPROCLUB", paramName, paramValue);
                    modelGenerate.validationSquadOfProClubIsDone = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else if (model.actionUser == "generate-maintenance")
                {
                    modelGenerate = model.newSeasonModel;

                    paramName = new string[] { "pIdTemp", "pIdSerieA", "pIdSerieB", "pIdSerieC", "pIdSerieD", "pIdFutA", "pIdFutB", "pIdProA", "pIdProB" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), modelGenerate.serieAID_H2H.ToString(), modelGenerate.serieBID_H2H.ToString(),
                                                modelGenerate.serieCID_H2H.ToString(), modelGenerate.serieDID_H2H.ToString(), modelGenerate.serieAID_FUT.ToString(),
                                                modelGenerate.serieBID_FUT.ToString(), modelGenerate.serieAID_PRO.ToString(), modelGenerate.serieBID_PRO.ToString() };
                    dt = db.executePROC("spMaintenanceBancoAndManagers", paramName, paramValue);
                    modelGenerate.maintenanceOfBenchIsDone = true;

                    paramName = new string[] { "pIdTemp" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString() };
                    dt = db.executePROC("spGenerateClashesNewTemporada", paramName, paramValue);
                    modelGenerate.tableOfClashesIsDone = true;

                    paramName = new string[] { "pIdTemp", "pIdSerieA" };
                    paramValue = new string[] { modelGenerate.seasonID.ToString(), modelGenerate.serieAID_H2H.ToString() };
                    dt = db.executePROC("spDeleteAllTablesForNewTemporada", paramName, paramValue);
                    modelGenerate.purgingOfSystemTablesIsDone = true;
                    modelGenerate.NewSeasonIsGenerated = true;

                    modelGenerate.returnMessage = "GenerateNewSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                modelGenerate.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelGenerate);
            }
            finally
            {
                db.closeConnection();
                dt = null;
                modelLeague = null;
                modelCup = null;
                modelGenerate = null;
            }

        }

        private void getAllTeamToTheMainModel(ref GenerateNewSeasonDetailsModel model)
        {
            GenerateNewSeasonStandardDetailsModel modelItemDetails = null;
            DataTable dt = null;
            int j = 0;

            try
            {
                model.listOfTeams = new List<GenerateNewSeasonStandardDetailsModel>();
                paramName = new string[] { "pTpModalidade" };
                paramValue = new string[] { model.modeType };
                dt = db.executePROC("spGetAllChampionshipItensNewTemporadaByModalidade", paramName, paramValue);

                for (j = 0; j < dt.Rows.Count; j++)
                {
                    modelItemDetails = new GenerateNewSeasonStandardDetailsModel();
                    modelItemDetails.modeType = dt.Rows[j]["TP_MODALIDADE"].ToString();
                    modelItemDetails.championshipType = dt.Rows[j]["SG_CAMPEONATO"].ToString();
                    modelItemDetails.typeStandard = Convert.ToInt16(dt.Rows[j]["ID_STANDARD"].ToString());
                    modelItemDetails.id = Convert.ToInt32(dt.Rows[j]["ITEM_ID"].ToString());
                    modelItemDetails.name = dt.Rows[j]["ITEM_NAME"].ToString();
                    modelItemDetails.psnID = dt.Rows[j]["ITEM_PSN"].ToString();
                    modelItemDetails.poteNumber = Convert.ToInt16(dt.Rows[j]["ITEM_POTE_NUMBER"].ToString());
                    model.listOfTeams.Add(modelItemDetails);
                }

                if (model.modeType == "H2H")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetAllTeamGenerateNewSeasonH2H", paramName, paramValue);

                    for (j = 0; j < dt.Rows.Count; j++)
                    {
                        modelItemDetails = new GenerateNewSeasonStandardDetailsModel();
                        modelItemDetails.id = Convert.ToInt32(dt.Rows[j]["ID_TIME"].ToString());
                        modelItemDetails.name = dt.Rows[j]["NM_TIME"].ToString();
                        modelItemDetails.typeItem = dt.Rows[j]["DS_TIPO"].ToString();
                        model.listOfTeams.Add(modelItemDetails);
                    }

                }

            }
            catch
            {
            }
            finally
            {
                modelItemDetails = null;
                dt = null;
            }
        }

        private StandardGenerateNewSeasonChampionshipLeagueDetailsModel getDetailsChampionshipLeague(string modeType, string championshipType)
        {
            DataTable dt = null;
            StandardGenerateNewSeasonChampionshipLeagueDetailsModel modelDetails = new StandardGenerateNewSeasonChampionshipLeagueDetailsModel();
            try
            {
                paramName = new string[] { "pTpModalidade", "pSgCampeonato" };
                paramValue = new string[] { modeType, championshipType };
                dt = db.executePROC("spGetAllChampionshipLeagueDetailsNewTemporada", paramName, paramValue);
                if (dt.Rows.Count > 0)
                {
                    modelDetails.modeType = modeType;
                    modelDetails.championshipType = championshipType;
                    modelDetails.startDate = Convert.ToDateTime(dt.Rows[0]["DATA_INICIO"].ToString());
                    modelDetails.totalTeams = Convert.ToInt16(dt.Rows[0]["QT_TIMES"].ToString());
                    modelDetails.totalDaysToPlayStage0 = Convert.ToInt16(dt.Rows[0]["DIAS_FASE_CLASSIFICACAO"].ToString());
                    modelDetails.totalDaysToPlayPlayoff = Convert.ToInt16(dt.Rows[0]["DIAS_FASE_PLAYOFF"].ToString());
                    modelDetails.totalRelegate = Convert.ToInt16(dt.Rows[0]["QT_TIMES_REBAIXADOS"].ToString());
                    modelDetails.hasChampionship = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_ATIVO"].ToString());
                    modelDetails.championshipID = Convert.ToInt16(dt.Rows[0]["ID_CAMPEONATO"].ToString());
                    modelDetails.championship_ByGroup = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO"].ToString());
                    modelDetails.totalGroups = Convert.ToInt16(dt.Rows[0]["QT_GRUPOS"].ToString());
                    modelDetails.championship_byGroupPots = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO_POR_POTES"].ToString());
                    modelDetails.championship_DoubleRound = Convert.ToBoolean(dt.Rows[0]["IN_DOUBLE_ROUND"].ToString());
                }
                return modelDetails;
            }
            catch
            {
                return new StandardGenerateNewSeasonChampionshipLeagueDetailsModel();
            }
            finally
            {
                dt = null;
                modelDetails = null;
            }
        }


        private StandardGenerateNewSeasonChampionshipCupDetailsModel getDetailsChampionshipCup(string modeType, string championshipType)
        {
            DataTable dt = null;
            StandardGenerateNewSeasonChampionshipCupDetailsModel modelCupDetails = new StandardGenerateNewSeasonChampionshipCupDetailsModel();
            try
            {
                paramName = new string[] { "pTpModalidade", "pSgCampeonato" };
                paramValue = new string[] { modeType, championshipType };
                dt = db.executePROC("spGetAllChampionshipCupDetailsNewTemporada", paramName, paramValue);
                if (dt.Rows.Count > 0)
                {
                    modelCupDetails.modeType = modeType;
                    modelCupDetails.championshipType = championshipType;
                    modelCupDetails.startDate = Convert.ToDateTime(dt.Rows[0]["DATA_INICIO"].ToString());
                    modelCupDetails.totalTeams = Convert.ToInt16(dt.Rows[0]["QT_TIMES"].ToString());
                    modelCupDetails.totalDaysToPlayStage0 = Convert.ToInt16(dt.Rows[0]["DIAS_FASE_CLASSIFICACAO"].ToString());
                    modelCupDetails.totalDaysToPlayPlayoff = Convert.ToInt16(dt.Rows[0]["DIAS_FASE_PLAYOFF"].ToString());
                    modelCupDetails.hasChampionship = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_ATIVO"].ToString());
                    modelCupDetails.championshipID = Convert.ToInt16(dt.Rows[0]["ID_CAMPEONATO"].ToString());
                    modelCupDetails.championship_ByGroup = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO"].ToString());
                    modelCupDetails.totalGroups = Convert.ToInt16(dt.Rows[0]["QT_GRUPOS"].ToString());
                    modelCupDetails.championship_byGroupPots = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO_POR_POTES"].ToString());
                    modelCupDetails.totalTeamsPreCup = Convert.ToInt16(dt.Rows[0]["QT_TIMES_PRE_COPA"].ToString());
                    modelCupDetails.hasChampionshipDestiny = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_DESTINO"].ToString());
                    modelCupDetails.hasChampionshipSource = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_ORIGEM"].ToString());
                    modelCupDetails.hasJust_SerieA = Convert.ToBoolean(dt.Rows[0]["IN_APENAS_SERIEA"].ToString());
                    modelCupDetails.hasJust_SerieB = Convert.ToBoolean(dt.Rows[0]["IN_APENAS_SERIEB"].ToString());
                    modelCupDetails.hasJust_SerieC = Convert.ToBoolean(dt.Rows[0]["IN_APENAS_SERIEC"].ToString());
                    modelCupDetails.has_SerieA_B = Convert.ToBoolean(dt.Rows[0]["IN_SERIEA_B"].ToString());
                    modelCupDetails.has_SerieA_B_C = Convert.ToBoolean(dt.Rows[0]["IN_SERIEA_B_C"].ToString());
                    modelCupDetails.has_SerieA_B_C_D = Convert.ToBoolean(dt.Rows[0]["IN_SERIEA_B_C_D"].ToString());
                    modelCupDetails.has_NationalTeams = Convert.ToBoolean(dt.Rows[0]["IN_SELECAO"].ToString());
                }
                return modelCupDetails;
            }
            catch
            {
                return new StandardGenerateNewSeasonChampionshipCupDetailsModel();
            }
            finally
            {
                dt = null;
                modelCupDetails = null;
            }
        }

    }
}