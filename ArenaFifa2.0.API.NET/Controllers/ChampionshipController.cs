using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipModel;
using static ArenaFifa20.API.NET.Models.ChampionshipUserModel;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamModel;
using static ArenaFifa20.API.NET.Models.ChampionshipStageModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Configuration;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamTableModel;
using System.Text;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult Championship(ChampionshipDetailsModel model)
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            ChampionshipListViewModel mainModel = new ChampionshipListViewModel();
            List<ChampionshipDetailsModel> listOfModel = new List<ChampionshipDetailsModel>();

            ChampionshipCalendarListViewModel calendarViewModel = new ChampionshipCalendarListViewModel();
            List<ChampionshipCalendarDetailsModel> calendarListModel = new List<ChampionshipCalendarDetailsModel>();
            ChampionshipCalendarDetailsModel calendarDetailsModel = new ChampionshipCalendarDetailsModel();

            ChampionshipLineUpListViewModel LineUpViewModel = new ChampionshipLineUpListViewModel();
            List<ChampionshipLineUpDetailsModel> LineUpListModel = new List<ChampionshipLineUpDetailsModel>();
            ChampionshipLineUpDetailsModel LineUpDetailsModel = new ChampionshipLineUpDetailsModel();

            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser.ToLower() == "save" && model.id > 0)
                {

                    paramName = new string[] { "pId", "pNmCamp", "pQtTimes", "pDtInicio", "pDtSorteio", "pAtivo", "pPorGrupo", "pTurnoUnico",
                                               "pTurnoReturno", "pQtGrupos", "pMataMata", "pIdaVolta", "pQtTimesClassif", "pQtTimesRebaix", "pIdUsuModera",
                                               "pIdUsuModera2", "pQtDiasFaseClassif", "pQtDiasFaseMataMata", "pSgTipoCamp", "pQtTimesProxClassif", "pIdConsole",
                                               "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao"};

                    string active = Convert.ToBoolean(model.active) ? "1" : "0";
                    string group = Convert.ToBoolean(model.forGroup) ? "1" : "0";
                    string justOneTurn = Convert.ToBoolean(model.justOneTurn) ? "1" : "0";
                    string twoTurns = Convert.ToBoolean(model.twoTurns) ? "1" : "0";
                    string playoff = Convert.ToBoolean(model.playoff) ? "1" : "0";
                    string twoLegs = Convert.ToBoolean(model.twoLegs) ? "1" : "0";

                    paramValue = new string[] { Convert.ToString(model.id), model.name, Convert.ToString(model.totalTeam), model.startDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]", model.drawDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]", active, group, justOneTurn,
                                                twoTurns, Convert.ToString(model.totalGroup), playoff, twoLegs, Convert.ToString(model.totalQualify), Convert.ToString(model.totalRelegation), Convert.ToString(model.userID1),
                                                Convert.ToString(model.userID2), Convert.ToString(model.totalDayStageOne), Convert.ToString(model.totalDayStagePlayoff), model.type, Convert.ToString(model.totalQualifyNextStage), model.console,
                                                model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.Update"};

                    dt = db.executePROC("spUpdateCampeonatoCRUD", paramName, paramValue);


                    paramName = new string[] { "pIdCamp", "pIdsFase" };
                    paramValue = new string[] { Convert.ToString(model.id), model.listStagesAdd };
                    dt = db.executePROC("spAddLoadFaseOfCampeonatoById", paramName, paramValue);

                    if (model.started == 0)
                    {
                        paramName = new string[] { "pIdCamp", "pIdsTime" };
                        paramValue = new string[] { Convert.ToString(model.id), model.listTeamsAdd };
                        dt = db.executePROC("spAddLoadCampeonatoTimeOfCampeonatoById", paramName, paramValue);

                        paramName = new string[] { "pIdCamp", "pIdsUsu" };
                        paramValue = new string[] { Convert.ToString(model.id), model.listUsersAdd };
                        dt = db.executePROC("spAddLoadCampeonatoUsuarioOfCampeonato", paramName, paramValue);

                        paramName = new string[] { "pIdCamp" };
                        paramValue = new string[] { Convert.ToString(model.id) };
                        dt = db.executePROC("spAddLoadClassificacaoInitialOfCampeonatov2", paramName, paramValue);

                        if (!String.IsNullOrEmpty(model.listTeamsStage0Add))
                        {
                            paramName = new string[] { "pIdCamp", "pIdsTime" };
                            paramValue = new string[] { Convert.ToString(model.id), model.listTeamsStage0Add };
                            dt = db.executePROC("spAddLoadTimesFasePreCopaOfCampeonato", paramName, paramValue);
                        }

                        if (!String.IsNullOrEmpty(model.listUsersStage2Add))
                        {
                            paramName = new string[] { "pIdCamp", "pIdsUsu" };
                            paramValue = new string[] { Convert.ToString(model.id), model.listUsersStage2Add };
                            dt = db.executePROC("spAddLoadCampeonatoUsuarioSegFaseOfCampeonato", paramName, paramValue);
                        }
                    }

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "getallactive")
                {
                    listOfModel = GlobalFunctions.getAllActiveChampionshipCurrentSeason(db, 0, String.Empty);

                    mainModel.listOfChampionship = listOfModel;
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else if (model.actionUser.ToLower() == "userexchange")
                {
                    paramName = new string[] { "pTpCamp", "pIdUsuIN", "pNmUsuIN", "pPsnIDIN", "pIdUsuOUT", "pIdTipoAcesso", "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao" };
                    paramValue = new string[] { model.type, model.userID1.ToString(), model.userName1, model.psnID1, model.userID2.ToString(), ConfigurationManager.AppSettings["access.current.season.exchange"].ToString(), model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.UserExchange" };
                    dt = db.executePROC("spDoUserExchange", paramName, paramValue);

                    model.teamName1 = dt.Rows[0]["NM_TIME"].ToString();
                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "managerexchange")
                {
                    paramName = new string[] { "pTpCamp", "pIdUsuIN", "pNmUsuIN", "pPsnIDIN", "pIdUsuOUT", "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao" };
                    paramValue = new string[] { model.type, model.userID1.ToString(), model.userName1, model.psnID1, model.userID2.ToString(), model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.MngerExchange" };
                    dt = db.executePROC("spDoMangerExchange", paramName, paramValue);

                    model.teamName1 = dt.Rows[0]["NM_TIME"].ToString();
                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "calendarallactivebytype")
                {
                    DateTime dtInicioCampeonato = DateTime.Now;
                    DateTime dtFimFaseClassif = DateTime.Now;
                    DateTime dtFimFaseMataxMata = DateTime.Now;
                    int iQtdRodadasFaseMataxMata = 0;
                    int iQtdRodadasFaseClassif = 0;
                    int iQtdDiasFaseMataxMata = 0;
                    int iQtdDiasFaseClassif = 0;
                    int iQtdFaseMataxMata = 0;
                    int iQtdeTempoEmDiasFaseClassif = 0;
                    int iQtdeTempoEmDiasFaseMataxMata = 0;
                    Boolean bDoubleRound = false;

                    paramName = new string[] { "pType" };
                    paramValue = new string[] { model.modeType };
                    dt = db.executePROC("spGetAllCampeonatosActiveForCalendarView", paramName, paramValue);
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        calendarDetailsModel = new ChampionshipCalendarDetailsModel();

                        calendarDetailsModel.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                        calendarDetailsModel.championshipName = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                        calendarDetailsModel.type = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                        calendarDetailsModel.startDate = Convert.ToDateTime(dt.Rows[i]["DT_INICIO"].ToString());

                        iQtdDiasFaseMataxMata = Convert.ToInt16(dt.Rows[i]["QT_DIAS_PARTIDA_FASE_MATAxMATA"].ToString());
                        iQtdDiasFaseClassif = Convert.ToInt16(dt.Rows[i]["QT_DIAS_PARTIDA_CLASSIFICACAO"].ToString());
                        if (dt.Rows[i]["IN_DOUBLE_ROUND"].ToString() == "1") { bDoubleRound = true; } else { bDoubleRound = false; }
                        iQtdRodadasFaseClassif = 0;
                        iQtdFaseMataxMata = Convert.ToInt16(dt.Rows[i]["TOTAL_FASE_CAMPEONATO"].ToString());

                        if (Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_GRUPO"].ToString()) && Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_TURNO_UNICO"].ToString()))
                        {
                            if (((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString())) % 2) == 0)
                                iQtdRodadasFaseClassif = ((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString())) - 1);
                            else
                                iQtdRodadasFaseClassif = (Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString()));
                        }
                        else if (Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_GRUPO"].ToString()) && Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_TURNO_RETURNO"].ToString()))
                        {
                            if (((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString())) % 2) == 0)
                                iQtdRodadasFaseClassif = (((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString())) - 1) * 2);
                            else
                                iQtdRodadasFaseClassif = ((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) / Convert.ToInt16(dt.Rows[i]["QT_GRUPOS"].ToString())) * 2);
                        }
                        else if (Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_TURNO_UNICO"].ToString()) && !Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_GRUPO"].ToString()))
                            iQtdRodadasFaseClassif = (Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) - 1);
                        else if (Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_TURNO_RETURNO"].ToString()) && !Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_GRUPO"].ToString()))
                            iQtdRodadasFaseClassif = ((Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) - 1) * 2);
                        else
                        {
                            if (Convert.ToInt16(dt.Rows[i]["QT_TIMES"].ToString()) == 1)
                                iQtdFaseMataxMata = iQtdFaseMataxMata + 1;

                            iQtdRodadasFaseClassif = 0;
                        }

                        if (bDoubleRound && iQtdRodadasFaseClassif > 1) { iQtdRodadasFaseClassif = iQtdRodadasFaseClassif / 2; }

                        dtInicioCampeonato = calendarDetailsModel.startDate;
                        dtFimFaseClassif = calendarDetailsModel.startDate;
                        iQtdRodadasFaseMataxMata = 0;

                        if (Convert.ToBoolean(dt.Rows[i]["IN_SISTEMA_MATA"].ToString()))
                        {
                            iQtdRodadasFaseMataxMata = iQtdRodadasFaseMataxMata + 1;

                            if (Convert.ToBoolean(dt.Rows[i]["IN_SISTEMA_IDA_VOLTA"].ToString())) { iQtdRodadasFaseMataxMata = iQtdRodadasFaseMataxMata + 1; }
                        }

                        if (iQtdRodadasFaseClassif > 0)
                        {
                            iQtdeTempoEmDiasFaseClassif = (iQtdRodadasFaseClassif * iQtdDiasFaseClassif);


                            if (String.IsNullOrEmpty(dt.Rows[i]["DT_TABELA_FIM_JOGO"].ToString()))
                            {
                                dtFimFaseClassif = dtInicioCampeonato.AddDays(iQtdeTempoEmDiasFaseClassif);
                                dtFimFaseClassif = dtFimFaseClassif.AddDays(-1);
                            }
                            else
                                dtFimFaseClassif = Convert.ToDateTime(dt.Rows[i]["DT_TABELA_FIM_JOGO"].ToString());

                            calendarDetailsModel.endStage0 = dtFimFaseClassif;
                            calendarDetailsModel.dayOfStage0 = iQtdDiasFaseClassif;
                        }
                        else
                        {
                            calendarDetailsModel.endStage0 = Convert.ToDateTime("01/01/1900");
                            calendarDetailsModel.dayOfStage0 = 0;
                        }

                        if (iQtdRodadasFaseMataxMata > 0)
                        {
                            iQtdeTempoEmDiasFaseMataxMata = ((iQtdFaseMataxMata * iQtdRodadasFaseMataxMata) * iQtdDiasFaseMataxMata) + iQtdFaseMataxMata;
                            dtFimFaseMataxMata = dtFimFaseClassif.AddDays(iQtdeTempoEmDiasFaseMataxMata);

                            calendarDetailsModel.endStagePlayoff = dtFimFaseMataxMata;
                            calendarDetailsModel.dayOfStagePlayoff = iQtdDiasFaseMataxMata;
                        }

                        calendarListModel.Add(calendarDetailsModel);
                    }

                    calendarViewModel.listOfChampionship = calendarListModel;
                    calendarViewModel.modeType = model.modeType;
                    calendarViewModel.returnMessage = "CurrentSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, calendarViewModel);
                }
                else if (model.actionUser.ToLower() == "lineupbyid")
                {
                    int ID_STAGE_0 = 0;
                    int ID_STAGE_2ND = 1;
                    int ID_STAGE_ROUND16 = 2;
                    int ID_STAGE_QUARTER = 3;
                    int ID_STAGE_SEMI = 4;
                    int ID_STAGE_FINAL = 6;

                    Boolean hasStage0 = false;
                    int totalStagesPlayoff = 0;
                    int firstStageIDPlayoff = 0;
                    int firstStageID = 0;
                    int stageIDInProgress = 0;
                    string championshipType = String.Empty;
                    int championshipIDSource = 0;

                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { model.id.ToString() };
                    dt = db.executePROC("spGetDetailsCampeonatoForLineUpView", paramName, paramValue);

                    totalStagesPlayoff = Convert.ToInt16(dt.Rows[0]["TOTAL_FASES_PLAYOFF"].ToString());
                    firstStageIDPlayoff = Convert.ToInt16(dt.Rows[0]["FIRST_ID_FASE_PLAYOFF"].ToString());
                    firstStageID = Convert.ToInt16(dt.Rows[0]["FIRST_ID_FASE"].ToString());
                    if (String.IsNullOrEmpty(dt.Rows[0]["ID_FASE_IN_PROGRESS"].ToString()))
                        stageIDInProgress = firstStageID;
                    else
                        stageIDInProgress = Convert.ToInt16(dt.Rows[0]["ID_FASE_IN_PROGRESS"].ToString());
                    if (dt.Rows[0]["HAS_FASE_0"].ToString() == "1")
                        hasStage0 = true;
                    championshipType = dt.Rows[0]["SG_TIPO_CAMPEONATO"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[0]["ID_CAMPEONATO_ORIGEM"].ToString()))
                        championshipIDSource = Convert.ToInt16(dt.Rows[0]["ID_CAMPEONATO_ORIGEM"].ToString());

                    LineUpViewModel.championshipName = dt.Rows[0]["NM_CAMPEONATO"].ToString();
                    LineUpViewModel.championshipID = model.id;
                    LineUpViewModel.firstStageIDPlayoff = firstStageIDPlayoff;
                    LineUpViewModel.totalStagesPlayoff = totalStagesPlayoff;
                    LineUpViewModel.firstStageID = firstStageID;
                    LineUpViewModel.stageIDInProgress = stageIDInProgress;

                    if (stageIDInProgress <= ID_STAGE_0)
                    {
                        LineUpViewModel.titleLineUp = "PREVISÃO DOS CONFRONTOS - " + dt.Rows[0]["NM_FIRST_FASE_PLAYOFF"].ToString().ToUpper();
                        LineUpViewModel.clashesDefined = false;
                    }
                    else
                    {
                        LineUpViewModel.titleLineUp = "CONFRONTOS - " + dt.Rows[0]["NM_FASE_IN_PROGRESS"].ToString().ToUpper();
                        LineUpViewModel.clashesDefined = true;
                    }

                    LineUpViewModel.firstStageIsQualify = false;
                    if (firstStageID < ID_STAGE_0) { LineUpViewModel.firstStageIsQualify = true; }

                    LineUpViewModel.listOfStage2 = new List<ChampionshipLineUpDetailsModel>();
                    LineUpViewModel.listOfRound16 = new List<ChampionshipLineUpDetailsModel>();
                    LineUpViewModel.listOfQuarter = new List<ChampionshipLineUpDetailsModel>();
                    LineUpViewModel.listOfSemi = new List<ChampionshipLineUpDetailsModel>();
                    LineUpViewModel.listOfGrandFinal = new List<ChampionshipLineUpDetailsModel>();
                    LineUpViewModel.championTeamName = "CAMPEÃO";

                    if (stageIDInProgress < ID_STAGE_0)
                        LineUpViewModel.messageNotFoundClashes = "A Fase de Qualificação ainda está em andamento, aguarde que assim que terminar será gerada, por sorteio, a próxima fase e esta tela irá mostrar toda a 'árvore' dos confrontos";
                    else
                    {
                        List<ChampionshipTeamTableDetailsModel>  listOfForecastTeamQualified = new List<ChampionshipTeamTableDetailsModel>();
                        List<ChampionshipTeamTableDetailsModel>  listOfForecastTeamQualifiedThirdPlace = new List<ChampionshipTeamTableDetailsModel>();
                        ChampionshipTeamTableDetailsModel teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                        StringBuilder strConcat = new StringBuilder();
                        string[] teamsQualified = { };

                        int totalGroup = Convert.ToInt16(dt.Rows[0]["QT_GRUPOS"].ToString());
                        int groupIDInitial = 0;
                        if (totalGroup>0) { groupIDInitial = 1; }
                        int totalQualified = Convert.ToInt16(dt.Rows[0]["QT_TIMES_CLASSIFICADOS"].ToString());

                        if (!LineUpViewModel.clashesDefined)
                        {
                            for (int j = groupIDInitial; j <= totalGroup; j++)
                            {
                                paramName = new string[] { "pIdCamp", "pIdGrupo", "pTotalQualified" };
                                paramValue = new string[] { model.id.ToString(), j.ToString(), totalQualified.ToString() };
                                dt = db.executePROC("spGetAllClassificacaoTimeOfCampeonatoByGrupo", paramName, paramValue);

                                for (int i = 0; i < dt.Rows.Count; i++)
                                {
                                    teamTableDetailsModel = new ChampionshipTeamTableDetailsModel();
                                    teamTableDetailsModel.teamID = Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString());
                                    listOfForecastTeamQualified.Add(teamTableDetailsModel);
                                }
                            }

                            if (listOfForecastTeamQualified.Count > 0)
                            {
                                strConcat.Clear();
                                foreach (ChampionshipTeamTableDetailsModel item in listOfForecastTeamQualified)
                                {
                                    if (strConcat.ToString() != string.Empty) { strConcat.Append(","); }
                                    strConcat.Append(item.teamID.ToString());
                                }

                                paramName = new string[] { "pIdCamp", "pIdsTime" };
                                paramValue = new string[] { model.id.ToString(), strConcat.ToString() };
                                dt = db.executePROC("spGetLoadClassificacaoTimeOfCampeonato", paramName, paramValue);

                                for (int i = 0; i < dt.Rows.Count; i++)
                                {
                                    Array.Resize(ref teamsQualified, teamsQualified.Length + 1);
                                    if (dt.Rows[i]["NM_TIME"].ToString().Length > 20)
                                        teamsQualified[i] = GlobalFunctions.UppercaseWords(dt.Rows[i]["NM_TIME"].ToString().ToLower().Substring(0,19));
                                    else
                                        teamsQualified[i] = GlobalFunctions.UppercaseWords(dt.Rows[i]["NM_TIME"].ToString().ToLower());

                                }
                            }


                            LineUpViewModel.messageNotFoundClashes = String.Empty;

                            if (firstStageIDPlayoff == ID_STAGE_FINAL)
                            {
                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Campeão Liga Campeões";
                                LineUpDetailsModel.teamName2 = "Campeão Liga Europa";
                                LineUpViewModel.listOfGrandFinal.Add(LineUpDetailsModel);
                            }
                            else if (firstStageIDPlayoff == ID_STAGE_SEMI)
                            {
                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "1º Lugar";
                                LineUpDetailsModel.teamName2 = "4º Lugar";
                                LineUpDetailsModel.teamName3 = "2º Lugar";
                                LineUpDetailsModel.teamName4 = "3º Lugar";
                                LineUpViewModel.listOfSemi.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Semi 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Semi 2";
                                LineUpViewModel.listOfGrandFinal.Add(LineUpDetailsModel);
                            }
                            else if (firstStageIDPlayoff == ID_STAGE_QUARTER && hasStage0)
                            {
                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                if (teamsQualified==null)
                                {
                                    LineUpDetailsModel.teamName1 = "1º Lugar";
                                    LineUpDetailsModel.teamName2 = "8º Lugar";
                                    LineUpDetailsModel.teamName3 = "4º Lugar";
                                    LineUpDetailsModel.teamName4 = "5º Lugar";
                                    LineUpDetailsModel.teamName5 = "2º Lugar";
                                    LineUpDetailsModel.teamName6 = "7º Lugar";
                                    LineUpDetailsModel.teamName7 = "3º Lugar";
                                    LineUpDetailsModel.teamName8 = "6º Lugar";
                                }
                                else
                                {
                                    LineUpDetailsModel.teamName1 = teamsQualified[0];
                                    LineUpDetailsModel.teamName2 = teamsQualified[7];
                                    LineUpDetailsModel.teamName3 = teamsQualified[3];
                                    LineUpDetailsModel.teamName4 = teamsQualified[4];
                                    LineUpDetailsModel.teamName5 = teamsQualified[1];
                                    LineUpDetailsModel.teamName6 = teamsQualified[6];
                                    LineUpDetailsModel.teamName7 = teamsQualified[2];
                                    LineUpDetailsModel.teamName8 = teamsQualified[5];
                                }
                                LineUpViewModel.listOfQuarter.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Quartas 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Quartas 2";
                                LineUpDetailsModel.teamName3 = "Vencedor Quartas 3";
                                LineUpDetailsModel.teamName4 = "Vencedor Quartas 4";
                                LineUpViewModel.listOfSemi.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Semi 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Semi 2";
                                LineUpViewModel.listOfGrandFinal.Add(LineUpDetailsModel);
                            }
                            else if (firstStageIDPlayoff == ID_STAGE_ROUND16 && hasStage0)
                            {
                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                if (championshipType == "CPDM")
                                {
                                    LineUpDetailsModel.teamName1 = "1º do Grupo 1";
                                    LineUpDetailsModel.teamName2 = "2º  do Grupo 2";
                                    LineUpDetailsModel.teamName3 = "1º do Grupo 3";
                                    LineUpDetailsModel.teamName4 = "2º do Grupo 4";
                                    LineUpDetailsModel.teamName5 = "1º do Grupo 2";
                                    LineUpDetailsModel.teamName6 = "2º do Grupo 1";
                                    LineUpDetailsModel.teamName7 = "1º do Grupo 4";
                                    LineUpDetailsModel.teamName8 = "2º do Grupo 3";
                                    LineUpDetailsModel.teamName9 = "1º do Grupo 5";
                                    LineUpDetailsModel.teamName10 = "2º do Grupo 6";
                                    LineUpDetailsModel.teamName11 = "1º do Grupo 7";
                                    LineUpDetailsModel.teamName12 = "2º do Grupo 8";
                                    LineUpDetailsModel.teamName13 = "1º do Grupo 6";
                                    LineUpDetailsModel.teamName14 = "2º do Grupo 5";
                                    LineUpDetailsModel.teamName15 = "1º do Grupo 8";
                                    LineUpDetailsModel.teamName16 = "2º do Grupo 7";
                                }
                                else if (championshipType == "CPSA" && championshipIDSource > 0)
                                {
                                    LineUpDetailsModel.teamName1 = "1º Lugar";
                                    LineUpDetailsModel.teamName2 = "8º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName3 = "8º Lugar";
                                    LineUpDetailsModel.teamName4 = "1º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName5 = "3º Lugar";
                                    LineUpDetailsModel.teamName6 = "6º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName7 = "7º Lugar";
                                    LineUpDetailsModel.teamName8 = "2º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName9 = "2º Lugar";
                                    LineUpDetailsModel.teamName10 = "7º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName11 = "6º Lugar";
                                    LineUpDetailsModel.teamName12 = "3º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName13 = "4º Lugar";
                                    LineUpDetailsModel.teamName14 = "5º melhor 3º da LCE";
                                    LineUpDetailsModel.teamName15 = "5º Lugar";
                                    LineUpDetailsModel.teamName16 = "4º melhor 3º da LCE";
                                }
                                else
                                {
                                    if (teamsQualified==null)
                                    {
                                        LineUpDetailsModel.teamName1 = "1º Lugar";
                                        LineUpDetailsModel.teamName2 = "16º Lugar";
                                        LineUpDetailsModel.teamName3 = "8º Lugar";
                                        LineUpDetailsModel.teamName4 = "9º Lugar";
                                        LineUpDetailsModel.teamName5 = "3º Lugar";
                                        LineUpDetailsModel.teamName6 = "14º Lugar";
                                        LineUpDetailsModel.teamName7 = "7º Lugar";
                                        LineUpDetailsModel.teamName8 = "10º Lugar";
                                        LineUpDetailsModel.teamName9 = "2º Lugar";
                                        LineUpDetailsModel.teamName10 = "15º Lugar";
                                        LineUpDetailsModel.teamName11 = "6º Lugar";
                                        LineUpDetailsModel.teamName12 = "11º Lugar";
                                        LineUpDetailsModel.teamName13 = "4º Lugar";
                                        LineUpDetailsModel.teamName14 = "13º Lugar";
                                        LineUpDetailsModel.teamName15 = "5º Lugar";
                                        LineUpDetailsModel.teamName16 = "12º Lugar";
                                    }
                                    else
                                    {
                                        LineUpDetailsModel.teamName1 = teamsQualified[0];
                                        LineUpDetailsModel.teamName2 = teamsQualified[15];
                                        LineUpDetailsModel.teamName3 = teamsQualified[7];
                                        LineUpDetailsModel.teamName4 = teamsQualified[8];
                                        LineUpDetailsModel.teamName5 = teamsQualified[2];
                                        LineUpDetailsModel.teamName6 = teamsQualified[13];
                                        LineUpDetailsModel.teamName7 = teamsQualified[6];
                                        LineUpDetailsModel.teamName8 = teamsQualified[9];
                                        LineUpDetailsModel.teamName9 = teamsQualified[1];
                                        LineUpDetailsModel.teamName10 = teamsQualified[14];
                                        LineUpDetailsModel.teamName11 = teamsQualified[5];
                                        LineUpDetailsModel.teamName12 = teamsQualified[10];
                                        LineUpDetailsModel.teamName13 = teamsQualified[3];
                                        LineUpDetailsModel.teamName14 = teamsQualified[12];
                                        LineUpDetailsModel.teamName15 = teamsQualified[4];
                                        LineUpDetailsModel.teamName16 = teamsQualified[11];
                                    }
                                }
                                LineUpViewModel.listOfRound16.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Oitavas 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Oitavas 2";
                                LineUpDetailsModel.teamName3 = "Vencedor Oitavas 3";
                                LineUpDetailsModel.teamName4 = "Vencedor Oitavas 4";
                                LineUpDetailsModel.teamName5 = "Vencedor Oitavas 5";
                                LineUpDetailsModel.teamName6 = "Vencedor Oitavas 6";
                                LineUpDetailsModel.teamName7 = "Vencedor Oitavas 7";
                                LineUpDetailsModel.teamName8 = "Vencedor Oitavas 8";
                                LineUpViewModel.listOfQuarter.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Quartas 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Quartas 2";
                                LineUpDetailsModel.teamName3 = "Vencedor Quartas 3";
                                LineUpDetailsModel.teamName4 = "Vencedor Quartas 4";
                                LineUpViewModel.listOfSemi.Add(LineUpDetailsModel);

                                LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                                LineUpDetailsModel.teamName1 = "Vencedor Semi 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Semi 2";
                                LineUpViewModel.listOfGrandFinal.Add(LineUpDetailsModel);

                            }
                        }
                        else
                        {
                            string[] stageIDs = { "1", "2", "3", "4", "5" };
                            string[] stage2ndStage = { };
                            string[] stageRound16 = { };
                            string[] stageQuarter = { };
                            string[] stageSemi = { };
                            string[] stageFinal = { };
                            int countArray = 0;

                            for (int i = 0; i < stageIDs.Length; i++)
                            {
                                paramName = new string[] { "pIdCamp", "pIdFase" };
                                paramValue = new string[] { model.id.ToString(), stageIDs[i] };
                                dt = db.executePROC("spGetTabelaJogoAllDetailsForLineUp", paramName, paramValue);

                                Array.Resize(ref teamsQualified, 0);
                                countArray = -1;

                                for (int j = 0; j < dt.Rows.Count; j++)
                                {
                                    countArray = countArray + 1;

                                    Array.Resize(ref teamsQualified, teamsQualified.Length + 1);
                                    if (dt.Rows[j]["1T"].ToString().Length > 20)
                                        teamsQualified[countArray] = GlobalFunctions.UppercaseWords(dt.Rows[j]["1T"].ToString().ToLower().Substring(0, 19));
                                    else
                                        teamsQualified[countArray] = GlobalFunctions.UppercaseWords(dt.Rows[j]["1T"].ToString().ToLower());

                                    countArray = countArray + 1;

                                    Array.Resize(ref teamsQualified, teamsQualified.Length + 1);
                                    if (dt.Rows[i]["1T"].ToString().Length > 20)
                                        teamsQualified[countArray] = GlobalFunctions.UppercaseWords(dt.Rows[j]["1T"].ToString().ToLower().Substring(0, 19));
                                    else
                                        teamsQualified[countArray] = GlobalFunctions.UppercaseWords(dt.Rows[j]["1T"].ToString().ToLower());
                                }

                                if (stageIDs[i] == GlobalVariables.STAGE_SECOND_STAGE)
                                    stage2ndStage = teamsQualified;
                                else if (stageIDs[i] == GlobalVariables.STAGE_ROUND_16)
                                    stageRound16 = teamsQualified;
                                else if (stageIDs[i] == GlobalVariables.STAGE_QUARTER_FINAL)
                                    stageQuarter = teamsQualified;
                                else if (stageIDs[i] == GlobalVariables.STAGE_SEMI_FINAL)
                                    stageSemi = teamsQualified;
                                else if (stageIDs[i] == GlobalVariables.STAGE_FINAL)
                                    stageFinal = teamsQualified;
                            }

                            LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                            if (stageFinal == null)
                            {
                                LineUpDetailsModel.teamName1 = "Vencedor Semi 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Semi 2";
                            }
                            else
                            {
                                LineUpDetailsModel.teamName1 = stageFinal[0];
                                LineUpDetailsModel.teamName2 = stageFinal[1];
                            }
                            LineUpViewModel.listOfGrandFinal.Add(LineUpDetailsModel);


                            LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                            if (stageSemi == null)
                            {
                                LineUpDetailsModel.teamName1 = "Vencedor Quartas 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Quartas 2";
                                LineUpDetailsModel.teamName3 = "Vencedor Quartas 3";
                                LineUpDetailsModel.teamName4 = "Vencedor Quartas 4";
                            }
                            else
                            {
                                LineUpDetailsModel.teamName1 = stageSemi[0];
                                LineUpDetailsModel.teamName2 = stageSemi[1];
                                LineUpDetailsModel.teamName3 = stageSemi[2];
                                LineUpDetailsModel.teamName4 = stageSemi[3];
                            }
                            LineUpViewModel.listOfSemi.Add(LineUpDetailsModel);

                            LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                            if (stageQuarter == null)
                            {
                                LineUpDetailsModel.teamName1 = "Vencedor Oitavas 1";
                                LineUpDetailsModel.teamName2 = "Vencedor Oitavas 2";
                                LineUpDetailsModel.teamName3 = "Vencedor Oitavas 3";
                                LineUpDetailsModel.teamName4 = "Vencedor Oitavas 4";
                                LineUpDetailsModel.teamName5 = "Vencedor Oitavas 5";
                                LineUpDetailsModel.teamName6 = "Vencedor Oitavas 6";
                                LineUpDetailsModel.teamName7 = "Vencedor Oitavas 7";
                                LineUpDetailsModel.teamName8 = "Vencedor Oitavas 8";
                            }
                            else
                            {
                                LineUpDetailsModel.teamName1 = stageQuarter[0];
                                LineUpDetailsModel.teamName2 = stageQuarter[1];
                                LineUpDetailsModel.teamName3 = stageQuarter[2];
                                LineUpDetailsModel.teamName4 = stageQuarter[3];
                                LineUpDetailsModel.teamName5 = stageQuarter[4];
                                LineUpDetailsModel.teamName6 = stageQuarter[5];
                                LineUpDetailsModel.teamName7 = stageQuarter[6];
                                LineUpDetailsModel.teamName8 = stageQuarter[7];
                            }
                            LineUpViewModel.listOfQuarter.Add(LineUpDetailsModel);

                            LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                            if (stageRound16 == null)
                            {
                                LineUpDetailsModel.teamName1 = "Vencedor 16-Avos 1";
                                LineUpDetailsModel.teamName2 = "Vencedor 16-Avos 2";
                                LineUpDetailsModel.teamName3 = "Vencedor 16-Avos 3";
                                LineUpDetailsModel.teamName4 = "Vencedor 16-Avos 4";
                                LineUpDetailsModel.teamName5 = "Vencedor 16-Avos 5";
                                LineUpDetailsModel.teamName6 = "Vencedor 16-Avos 6";
                                LineUpDetailsModel.teamName7 = "Vencedor 16-Avos 7";
                                LineUpDetailsModel.teamName8 = "Vencedor 16-Avos 8";
                                LineUpDetailsModel.teamName9 = "Vencedor 16-Avos 9";
                                LineUpDetailsModel.teamName10 = "Vencedor 16-Avos 10";
                                LineUpDetailsModel.teamName11 = "Vencedor 16-Avos 11";
                                LineUpDetailsModel.teamName12 = "Vencedor 16-Avos 12";
                                LineUpDetailsModel.teamName13 = "Vencedor 16-Avos 13";
                                LineUpDetailsModel.teamName14 = "Vencedor 16-Avos 14";
                                LineUpDetailsModel.teamName15 = "Vencedor 16-Avos 15";
                                LineUpDetailsModel.teamName16 = "Vencedor 16-Avos 16";
                            }
                            else
                            {
                                LineUpDetailsModel.teamName1 = stageRound16[0];
                                LineUpDetailsModel.teamName2 = stageRound16[1];
                                LineUpDetailsModel.teamName3 = stageRound16[2];
                                LineUpDetailsModel.teamName4 = stageRound16[3];
                                LineUpDetailsModel.teamName5 = stageRound16[4];
                                LineUpDetailsModel.teamName6 = stageRound16[5];
                                LineUpDetailsModel.teamName7 = stageRound16[6];
                                LineUpDetailsModel.teamName8 = stageRound16[7];
                                LineUpDetailsModel.teamName9 = stageRound16[8];
                                LineUpDetailsModel.teamName10 = stageRound16[9];
                                LineUpDetailsModel.teamName11 = stageRound16[10];
                                LineUpDetailsModel.teamName12 = stageRound16[11];
                                LineUpDetailsModel.teamName13 = stageRound16[12];
                                LineUpDetailsModel.teamName14 = stageRound16[13];
                                LineUpDetailsModel.teamName15 = stageRound16[14];
                                LineUpDetailsModel.teamName16 = stageRound16[15];
                            }
                            LineUpViewModel.listOfRound16.Add(LineUpDetailsModel);

                            LineUpDetailsModel = new ChampionshipLineUpDetailsModel();
                            if (stage2ndStage != null)
                            {
                                LineUpDetailsModel.teamName1 = stage2ndStage[0];
                                LineUpDetailsModel.teamName2 = stage2ndStage[1];
                                LineUpDetailsModel.teamName3 = stage2ndStage[2];
                                LineUpDetailsModel.teamName4 = stage2ndStage[3];
                                LineUpDetailsModel.teamName5 = stage2ndStage[4];
                                LineUpDetailsModel.teamName6 = stage2ndStage[5];
                                LineUpDetailsModel.teamName7 = stage2ndStage[6];
                                LineUpDetailsModel.teamName8 = stage2ndStage[7];
                                LineUpDetailsModel.teamName9 = stage2ndStage[8];
                                LineUpDetailsModel.teamName10 = stage2ndStage[9];
                                LineUpDetailsModel.teamName11 = stage2ndStage[10];
                                LineUpDetailsModel.teamName12 = stage2ndStage[11];
                                LineUpDetailsModel.teamName13 = stage2ndStage[12];
                                LineUpDetailsModel.teamName14 = stage2ndStage[13];
                                LineUpDetailsModel.teamName15 = stage2ndStage[14];
                                LineUpDetailsModel.teamName16 = stage2ndStage[15];
                                LineUpDetailsModel.teamName17 = stage2ndStage[16];
                                LineUpDetailsModel.teamName18 = stage2ndStage[17];
                                LineUpDetailsModel.teamName19 = stage2ndStage[18];
                                LineUpDetailsModel.teamName20 = stage2ndStage[19];
                                LineUpDetailsModel.teamName21 = stage2ndStage[20];
                                LineUpDetailsModel.teamName22 = stage2ndStage[21];
                                LineUpDetailsModel.teamName23 = stage2ndStage[22];
                                LineUpDetailsModel.teamName24 = stage2ndStage[23];
                                LineUpDetailsModel.teamName25 = stage2ndStage[24];
                                LineUpDetailsModel.teamName25 = stage2ndStage[25];
                                LineUpDetailsModel.teamName27 = stage2ndStage[26];
                                LineUpDetailsModel.teamName28 = stage2ndStage[27];
                                LineUpDetailsModel.teamName29 = stage2ndStage[28];
                                LineUpDetailsModel.teamName30 = stage2ndStage[29];
                                LineUpDetailsModel.teamName31 = stage2ndStage[30];
                                LineUpDetailsModel.teamName32 = stage2ndStage[31];
                            }
                            LineUpViewModel.listOfStage2.Add(LineUpDetailsModel);
                        }
                        listOfForecastTeamQualified = null;
                        listOfForecastTeamQualifiedThirdPlace = null;
                        teamTableDetailsModel = null;
                        strConcat = null;
                    }

                    LineUpViewModel.returnMessage = "CurrentSeasonSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, LineUpViewModel);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "errorPostChampionship_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                modelDetails = null;
                mainModel = null;
                listOfModel = null;
                calendarViewModel = null;
                calendarDetailsModel = null;
                LineUpViewModel = null;
                LineUpListModel = null;
                LineUpDetailsModel = null;
            }

        }


        [HttpGet]
        public IHttpActionResult GetDetails(int id)
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();

            ChampionshipUserDetailsModel userDetails = new ChampionshipUserDetailsModel();
            List<ChampionshipUserDetailsModel> listOfUser = new List<ChampionshipUserDetailsModel>();

            ChampionshipTeamDetailsModel teamDetails = new ChampionshipTeamDetailsModel();
            List<ChampionshipTeamDetailsModel> listOfTeam = new List<ChampionshipTeamDetailsModel>();

            DataTable dt = null;
            db.openConnection();


            try
            {

                modelDetails = GlobalFunctions.getChampionshipDetails(db, id);

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllUsuariosOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    userDetails = new ChampionshipUserDetailsModel();
                    userDetails.id = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    userDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    userDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    listOfUser.Add(userDetails);
                }
                modelDetails.listOfUser = listOfUser;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllTimesOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    teamDetails = new ChampionshipTeamDetailsModel();
                    teamDetails.id = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    teamDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    teamDetails.type = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfTeam.Add(teamDetails);
                }
                modelDetails.listOfTeam = listOfTeam;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllTimesFasePreCopaOfCampeonato", paramName, paramValue);
                listOfTeam = new List<ChampionshipTeamDetailsModel>();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    teamDetails = new ChampionshipTeamDetailsModel();
                    teamDetails.id = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    teamDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    teamDetails.type = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfTeam.Add(teamDetails);
                }
                modelDetails.listOfTeamStage0 = listOfTeam;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                listOfUser = new List<ChampionshipUserDetailsModel>();
                dt = db.executePROC("spGetAllUsuariosSegFaseOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    userDetails = new ChampionshipUserDetailsModel();
                    userDetails.id = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    userDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    userDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    listOfUser.Add(userDetails);
                }
                modelDetails.listOfUserStage2 = listOfUser;


                modelDetails.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

            }
            catch (Exception ex)
            {
                modelDetails = new ChampionshipDetailsModel();
                modelDetails.listOfStage = new List<ChampionshipStageDetailsModel>();
                modelDetails.listOfTeam = new List<ChampionshipTeamDetailsModel>();
                modelDetails.listOfUser = new List<ChampionshipUserDetailsModel>();
                modelDetails.returnMessage = "errorGetChampionshipDetails_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                userDetails = null;
                teamDetails = null;
                listOfUser = null;
                listOfTeam = null;
                dt = null;
            }

        }

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            ChampionshipListViewModel mainModel = new ChampionshipListViewModel();
            List<ChampionshipDetailsModel> listOfModel = new List<ChampionshipDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllCampeonatosNoFilterCRUD", paramName, paramValue);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.seasonID = Convert.ToInt32(dt.Rows[i]["ID_TEMPORADA"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                    modelDetails.psnID1 = dt.Rows[i]["PSN1"].ToString();
                    modelDetails.psnID2 = dt.Rows[i]["PSN2"].ToString();
                    modelDetails.seasonName = dt.Rows[i]["NM_Temporada"].ToString();
                    modelDetails.type = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                    modelDetails.active = Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_ATIVO"].ToString());
                    modelDetails.startDateFormatted = dt.Rows[i]["DT_INICIO_FORMATADA"].ToString();
                    modelDetails.drawDateFormatted = dt.Rows[i]["DT_SORTEIO_FORMATADA"].ToString();

                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfChampionship = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            catch (Exception ex)
            {
                mainModel = new ChampionshipListViewModel();
                mainModel.listOfChampionship = new List<ChampionshipDetailsModel>();
                mainModel.returnMessage = "errorGetAll_" + ex.Message;
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