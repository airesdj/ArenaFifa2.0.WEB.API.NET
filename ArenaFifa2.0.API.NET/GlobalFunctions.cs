using DBConnection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using static ArenaFifa20.API.NET.Models.ChampionshipMatchTableModel;
using static ArenaFifa20.API.NET.Models.ChampionshipModel;
using static ArenaFifa20.API.NET.Models.ChampionshipStageModel;
using static ArenaFifa20.API.NET.Models.MyMatchesModel;
using static ArenaFifa20.API.NET.Models.ScorerModel;

namespace ArenaFifa20.API.NET
{
    public static class GlobalFunctions
    {

        public static List<listScorers> getListScorers(string typeMode, connectionMySQL db, int userID = 0, Boolean isSummary = true, int championshiID = 0)
        {
            List<listScorers> modelList = new List<listScorers>();
            listScorers listScorers = new listScorers();
            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;
            string returnMessage = String.Empty;

            try
            {

                paramName = new string[] { "pMode", "pIdUsu", "pInSummary", "pIdCamp" };
                paramValue = new string[] { typeMode, userID.ToString(), isSummary.ToString() + ";[BOOLEAN-TYPE]", championshiID.ToString() };
                dt = db.executePROC("spGetSummaryRankingListScorers", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    listScorers = new listScorers();
                    listScorers.playerID = Convert.ToInt32(dt.Rows[i]["ID_GOLEADOR"].ToString());
                    listScorers.playerName = dt.Rows[i]["NM_GOLEADOR"].ToString();
                    listScorers.playerFullName = dt.Rows[i]["NM_GOLEADOR_COMPLETO"].ToString();
                    listScorers.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["DS_Tipo"].ToString()))
                        listScorers.teamName = dt.Rows[i]["NM_TIME"].ToString() + "-" + dt.Rows[i]["DS_Tipo"].ToString();
                    else
                        listScorers.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    listScorers.totalGoals = Convert.ToInt16(dt.Rows[i]["QT_GOLS_MARCADOS"].ToString());
                    modelList.Add(listScorers);
                }

                return modelList;
            }
            catch(Exception ex)
            {
                returnMessage = "Erro na execução da procedure Lista de Artilheiros " + typeMode + ": (" + ex.InnerException.Message + ")"; ;
                modelList = new List<listScorers>();
                return modelList;
            }
            finally
            {
                modelList = null;
                listScorers = null;
                dt = null;
            }
        }


        public static MyMatchesTotalModel getMyMatchesTotal(string typeMode, string typeMyMatches, connectionMySQL db, int userID)
        {
            MyMatchesTotalModel myMatchesTotal = new MyMatchesTotalModel();
            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;

            try
            {

                paramName = new string[] { "pTypeMode", "pTypeMyMactches", "pIdUsu" };
                paramValue = new string[] { typeMode, typeMyMatches, userID.ToString() };
                dt = db.executePROC("spGetTotalsMyMatches", paramName, paramValue);

                if (dt.Rows.Count>0)
                {
                    myMatchesTotal.totalGoals = Convert.ToInt32(dt.Rows[0]["totalGoals"].ToString());
                    myMatchesTotal.totalGoalsFor = Convert.ToInt32(dt.Rows[0]["totalGoalsFOR"].ToString());
                    myMatchesTotal.totalGoalsAgainst = Convert.ToInt32(dt.Rows[0]["totalGoalsAGAINST"].ToString());
                    myMatchesTotal.totalMatchToPlay = Convert.ToInt32(dt.Rows[0]["totalMatchesToPlay"].ToString());
                    myMatchesTotal.totalMatchDelayed = Convert.ToInt32(dt.Rows[0]["totalMatchesDelayed"].ToString());
                    myMatchesTotal.totalMatches = Convert.ToInt32(dt.Rows[0]["totalMatches"].ToString());
                    myMatchesTotal.totalWins = Convert.ToInt32(dt.Rows[0]["totalWins"].ToString());
                    myMatchesTotal.totalLosses = Convert.ToInt32(dt.Rows[0]["totalLosses"].ToString());
                    myMatchesTotal.teamNameH2H = dt.Rows[0]["teamNameH2H"].ToString();
                    myMatchesTotal.nationalTeamNameCPDM = dt.Rows[0]["nationalTeamName"].ToString();
                    myMatchesTotal.teamNameFUT = dt.Rows[0]["teamNameFUT"].ToString();
                    myMatchesTotal.teamNamePRO = dt.Rows[0]["teamNamePRO"].ToString();
                    myMatchesTotal.teamIDH2H = Convert.ToInt32(dt.Rows[0]["teamIDH2H"].ToString());
                    myMatchesTotal.teamIDFUT = Convert.ToInt32(dt.Rows[0]["teamIDFUT"].ToString());
                    myMatchesTotal.teamIDPRO = Convert.ToInt32(dt.Rows[0]["teamIDPRO"].ToString());
                    myMatchesTotal.natonalTeamIDCPDM = Convert.ToInt32(dt.Rows[0]["nationalTeamID"].ToString());
                }
                myMatchesTotal.returnMessage = "MyMatchesSuccessfully";
                return myMatchesTotal;
            }
            catch(Exception ex)
            {
                myMatchesTotal.returnMessage = "Erro na execução da procedure Total My Matches - Próximos Jogos " + typeMode + ": (" + ex.InnerException.Message + ")"; ;
                return myMatchesTotal;
            }
            finally
            {
                myMatchesTotal = null;
                dt = null;
            }
        }


        public static List<squadListModel> getListOfSquadPROCLUB(connectionMySQL db, int seasonID, int managerID, out string returnMessage)
        {
            squadListModel modelDetails = new squadListModel();
            List<squadListModel> listOfModel = new List<squadListModel>();
            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;

            try
            {
                paramName = new string[] { "pIdTemporada", "pIdManager" };
                paramValue = new string[] { seasonID.ToString(), managerID.ToString() };
                dt = db.executePROC("spGetAllSquadOfClub", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new squadListModel();
                    modelDetails.playerID = Convert.ToInt32(dt.Rows[i]["ID_GOLEADOR"].ToString());
                    modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    if (modelDetails.userID == managerID) { modelDetails.isCapitain = true; }
                    modelDetails.recordDate = dt.Rows[i]["DT_CONFIRMACAO_FORMATADA"].ToString();
                    listOfModel.Add(modelDetails);
                }
                returnMessage = "MyMatchesSuccessfully";
                return listOfModel;
            }
            catch (Exception ex)
            {
                returnMessage = "Erro na execução da procedure Lista de Elencos do clube para a modalidade PRO CLUB: (" + ex.InnerException.Message + ")"; ;
                return listOfModel;
            }
            finally
            {
                modelDetails = null;
                listOfModel = null;
                dt = null;
            }
        }



        public static List<ChampionshipMatchTableDetailsModel> getListOfMatchForMyMatches(string typeMyMatches, connectionMySQL db, int teamID, int nationalTeamID, out string returnMessage)
        {
            ChampionshipMatchTableDetailsModel modelDetails = new ChampionshipMatchTableDetailsModel();
            List<ChampionshipMatchTableDetailsModel> listOfModel = new List<ChampionshipMatchTableDetailsModel>();
            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;

            try
            {
                paramName = new string[] { "pTypeMyMactches", "pIdTime", "pIdSelecao" };
                paramValue = new string[] { typeMyMatches, teamID.ToString(), nationalTeamID.ToString() };
                dt = db.executePROC("spGetTabelaJogoAllDetailsForMyMatches", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipMatchTableDetailsModel();
                    modelDetails.matchID = Convert.ToInt32(dt.Rows[i]["ID_TABELA_JOGO"].ToString());
                    modelDetails.championshipID = Convert.ToInt32(dt.Rows[i]["ID_CAMPEONATO"].ToString());
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
                    modelDetails.userHomeID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO_TIME_CASA"].ToString());
                    modelDetails.userAwayID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO_TIME_VISITANTE"].ToString());
                    listOfModel.Add(modelDetails);
                }
                returnMessage = "MyMatchesSuccessfully";
                return listOfModel;
            }
            catch (Exception ex)
            {
                returnMessage = "Erro na execução da procedure Lista " + typeMyMatches + " My Matches - Próximos Jogos: (" + ex.InnerException.Message + ")"; ;
                return listOfModel;
            }
            finally
            {
                modelDetails = null;
                listOfModel = null;
                dt = null;
            }
        }


        public static List<ChampionshipDetailsModel> getAllActiveChampionshipCurrentSeason(connectionMySQL db, int championshipID, string modeType)
        {
            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            List<ChampionshipDetailsModel> listOfModel = new List<ChampionshipDetailsModel>();
            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;

            try
            {
                paramName = new string[] { "pIdTemporada" };
                paramValue = new string[] { "0" };
                dt = db.executePROC("spGetAllCampeonatosActiveOfTemporada", paramName, paramValue);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (dt.Rows[i]["ID_CAMPEONATO"].ToString() != championshipID.ToString() && (dt.Rows[i]["MODE_TYPE"].ToString()== modeType || modeType==String.Empty))
                    {
                        modelDetails = new ChampionshipDetailsModel();
                        modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                        modelDetails.seasonID = Convert.ToInt32(dt.Rows[i]["ID_TEMPORADA"].ToString());
                        modelDetails.seasonName = dt.Rows[i]["NM_TEMPORADA"].ToString();
                        modelDetails.name = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                        modelDetails.type = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                        modelDetails.modeType = dt.Rows[i]["MODE_TYPE"].ToString();
                        modelDetails.totalTeam = Convert.ToInt32(dt.Rows[i]["QT_TIMES"].ToString());
                        modelDetails.startDate = Convert.ToDateTime(dt.Rows[i]["DT_INICIO"].ToString());
                        modelDetails.drawDate = Convert.ToDateTime(dt.Rows[i]["DT_SORTEIO"].ToString());
                        modelDetails.active = Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_ATIVO"].ToString());

                        listOfModel.Add(modelDetails);
                    }
                }

                return listOfModel;
            }
            catch(Exception ex)
            {
                return listOfModel;
            }
            finally
            {
                modelDetails = null;
                listOfModel = null;
                dt = null;
                paramName = null;
                paramValue = null;
            }

        }


        public static ChampionshipDetailsModel getChampionshipDetails(connectionMySQL db, int championshipID)
        {
            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            ChampionshipStageDetailsModel stageDetails = new ChampionshipStageDetailsModel();
            List<ChampionshipStageDetailsModel> listOfStage = new List<ChampionshipStageDetailsModel>();

            DataTable dt = null;
            string[] paramName = null;
            string[] paramValue = null;

            try
            {
                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(championshipID) };
                dt = db.executePROC("spGetCampeonatosDetails", paramName, paramValue);

                if (dt.Rows.Count > 0)
                {
                    modelDetails.id = Convert.ToInt32(dt.Rows[0]["ID_CAMPEONATO"].ToString());
                    modelDetails.seasonID = Convert.ToInt32(dt.Rows[0]["ID_TEMPORADA"].ToString());
                    modelDetails.name = dt.Rows[0]["NM_CAMPEONATO"].ToString();
                    modelDetails.seasonName = dt.Rows[0]["NM_Temporada"].ToString();
                    modelDetails.type = dt.Rows[0]["SG_TIPO_CAMPEONATO"].ToString();
                    modelDetails.typeName = dt.Rows[0]["DS_TIPO_CAMPEONATO"].ToString();
                    modelDetails.modeType = dt.Rows[0]["TIPO_CAMPEONATO"].ToString();
                    modelDetails.active = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_ATIVO"].ToString());
                    //modelDetails.startDateFormatted = dt.Rows[0]["DT_INICIO_FORMATADA"].ToString();
                    //modelDetails.drawDateFormatted = dt.Rows[0]["DT_SORTEIO_FORMATADA"].ToString();
                    modelDetails.startDate = Convert.ToDateTime(dt.Rows[0]["DT_INICIO"].ToString());
                    modelDetails.drawDate = Convert.ToDateTime(dt.Rows[0]["DT_SORTEIO"].ToString());


                    modelDetails.totalTeam = Convert.ToInt16(dt.Rows[0]["QT_TIMES"].ToString());
                    modelDetails.totalGroup = Convert.ToInt16(dt.Rows[0]["QT_GRUPOS"].ToString());
                    modelDetails.totalQualify = Convert.ToInt16(dt.Rows[0]["QT_TIMES_CLASSIFICADOS"].ToString());
                    modelDetails.totalRelegation = Convert.ToInt16(dt.Rows[0]["QT_TIMES_REBAIXADOS"].ToString());
                    modelDetails.totalDayStageOne = Convert.ToInt16(dt.Rows[0]["QT_DIAS_PARTIDA_CLASSIFICACAO"].ToString());
                    modelDetails.totalDayStagePlayoff = Convert.ToInt16(dt.Rows[0]["QT_DIAS_PARTIDA_FASE_MATAxMATA"].ToString());
                    modelDetails.totalQualifyNextStage = Convert.ToInt16(dt.Rows[0]["QT_TIMES_PROX_CLASSIF"].ToString());
                    modelDetails.totalTeamQualifyDivAbove = Convert.ToInt16(dt.Rows[0]["QT_TIMES_ACESSO"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[0]["IN_POSICAO_ORIGEM"].ToString()))
                    {
                        modelDetails.sourcePlaceFromChampionshipSource = Convert.ToInt16(dt.Rows[0]["IN_POSICAO_ORIGEM"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_CAMPEONATO_DESTINO"].ToString()))
                            modelDetails.ChampionshipIDDestiny = Convert.ToInt16(dt.Rows[0]["ID_CAMPEONATO_DESTINO"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_CAMPEONATO_ORIGEM"].ToString()))
                            modelDetails.ChampionshipIDSource = Convert.ToInt16(dt.Rows[0]["ID_CAMPEONATO_ORIGEM"].ToString());
                    }

                    modelDetails.forGroup = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO"].ToString());
                    modelDetails.justOneTurn = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_TURNO_UNICO"].ToString());
                    modelDetails.twoTurns = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_TURNO_RETURNO"].ToString());
                    modelDetails.playoff = Convert.ToBoolean(dt.Rows[0]["IN_SISTEMA_MATA"].ToString());
                    modelDetails.twoLegs = Convert.ToBoolean(dt.Rows[0]["IN_SISTEMA_IDA_VOLTA"].ToString());

                    modelDetails.console = dt.Rows[0]["IN_CONSOLE"].ToString();

                    modelDetails.userID1 = Convert.ToInt32(dt.Rows[0]["ID_USUARIO_MODERADOR"].ToString());
                    modelDetails.userName1 = dt.Rows[0]["NM_Usuario"].ToString();
                    modelDetails.psnID1 = dt.Rows[0]["PSN_ID"].ToString();
                    modelDetails.email1 = dt.Rows[0]["DS_EMAIL"].ToString();

                    modelDetails.userID2 = Convert.ToInt32(dt.Rows[0]["ID_USUARIO_2oMODERADOR"].ToString());
                    modelDetails.userName2 = dt.Rows[0]["NM_Usuario2"].ToString();
                    modelDetails.psnID2 = dt.Rows[0]["PSN_ID2"].ToString();
                    modelDetails.email2 = dt.Rows[0]["DS_EMAIL2"].ToString();

                    modelDetails.stageID_Round = dt.Rows[0]["ID_FASE_NUMERO_RODADA"].ToString();

                    modelDetails.started = Convert.ToInt32(dt.Rows[0]["inInicioCampeonato"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[0]["idPrimFaseCampeonato"].ToString()))
                        modelDetails.firstStageID = Convert.ToInt32(dt.Rows[0]["idPrimFaseCampeonato"].ToString());
                    else
                        modelDetails.firstStageID = 99;


                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(championshipID) };
                    dt = db.executePROC("spGetAllFasePorCampeonato", paramName, paramValue);
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        stageDetails = new ChampionshipStageDetailsModel();
                        stageDetails.id = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                        stageDetails.name = dt.Rows[i]["NM_FASE"].ToString();
                        listOfStage.Add(stageDetails);
                    }
                    modelDetails.listOfStage = listOfStage;
                }

                return modelDetails;
            }
            catch (Exception ex)
            {
                return modelDetails;
            }
            finally
            {
                modelDetails = null;
                dt = null;
                paramName = null;
                paramValue = null;
                stageDetails = null;
                listOfStage = null;
            }
        }


        public static ChampionshipMatchTableDetailsModel setDetailsChampionshipMatchTable(DataRow rowMatchTable)
        {
            ChampionshipMatchTableDetailsModel modelDetails = new ChampionshipMatchTableDetailsModel();

            try
            {
                modelDetails = new ChampionshipMatchTableDetailsModel();
                modelDetails.matchID = Convert.ToInt16(rowMatchTable["ID_TABELA_JOGO"].ToString());
                modelDetails.championshipID = Convert.ToInt16(rowMatchTable["ID_CAMPEONATO"].ToString());
                modelDetails.championshipName = rowMatchTable["NM_CAMPEONATO"].ToString();
                modelDetails.stageID = Convert.ToInt16(rowMatchTable["ID_FASE"].ToString());
                modelDetails.stageName = rowMatchTable["NM_FASE"].ToString();
                modelDetails.groupID = Convert.ToInt16(rowMatchTable["ID_Grupo"].ToString());
                if (!String.IsNullOrEmpty(rowMatchTable["NM_Grupo"].ToString()))
                    modelDetails.groupName = rowMatchTable["NM_Grupo"].ToString();
                modelDetails.seasonName = rowMatchTable["NM_TEMPORADA"].ToString();
                modelDetails.startDate = Convert.ToDateTime(rowMatchTable["DT_TABELA_INICIO_JOGO"].ToString());
                modelDetails.endDate = Convert.ToDateTime(rowMatchTable["DT_TABELA_FIM_JOGO"].ToString());
                modelDetails.teamHomeID = Convert.ToInt16(rowMatchTable["ID_TIME_CASA"].ToString());
                modelDetails.totalGoalsHome = rowMatchTable["QT_GOLS_TIME_CASA"].ToString();
                modelDetails.teamAwayID = Convert.ToInt16(rowMatchTable["ID_TIME_VISITANTE"].ToString());
                modelDetails.totalGoalsAway = rowMatchTable["QT_GOLS_TIME_VISITANTE"].ToString();
                if (!String.IsNullOrEmpty(rowMatchTable["DT_EFETIVACAO_JOGO"].ToString()))
                    modelDetails.launchDate = Convert.ToDateTime(rowMatchTable["DT_EFETIVACAO_JOGO"].ToString());
                modelDetails.round = Convert.ToInt16(rowMatchTable["IN_NUMERO_RODADA"].ToString());
                if (!String.IsNullOrEmpty(rowMatchTable["IN_JOGO_MATAXMATA"].ToString()))
                    modelDetails.playoffGame = Convert.ToInt16(rowMatchTable["IN_JOGO_MATAXMATA"].ToString());
                modelDetails.teamURLHome = rowMatchTable["DS_URL1"].ToString();
                modelDetails.teamNameHome = rowMatchTable["1T"].ToString();
                modelDetails.teamTypeHome = rowMatchTable["DT1"].ToString();
                if (!String.IsNullOrEmpty(rowMatchTable["ID_USUARIO_TIME_CASA"].ToString()))
                {
                    modelDetails.userHomeID = Convert.ToInt32(rowMatchTable["ID_USUARIO_TIME_CASA"].ToString());
                    modelDetails.psnIDHome = rowMatchTable["NM_Tecnico_TimeCasa"].ToString();
                    modelDetails.userHomeName = rowMatchTable["NM_Tecnico_TimeCasa"].ToString();
                    if (String.IsNullOrEmpty(modelDetails.psnIDHome))
                    {
                        modelDetails.psnIDHome = rowMatchTable["PSN1"].ToString();
                        modelDetails.userHomeName = rowMatchTable["PSN1"].ToString();
                    }
                }
                else
                {
                    modelDetails.userHomeID = Convert.ToInt32(rowMatchTable["IDUSU1"].ToString());
                    modelDetails.psnIDHome = rowMatchTable["PSN1"].ToString();
                    modelDetails.userHomeName = rowMatchTable["PSN1"].ToString();
                }
                modelDetails.teamURLAway = rowMatchTable["DS_URL2"].ToString();
                modelDetails.teamNameAway = rowMatchTable["2T"].ToString();
                modelDetails.teamTypeAway = rowMatchTable["DT2"].ToString();

                if (!String.IsNullOrEmpty(rowMatchTable["ID_USUARIO_TIME_VISITANTE"].ToString()))
                {
                    modelDetails.userAwayID = Convert.ToInt32(rowMatchTable["ID_USUARIO_TIME_VISITANTE"].ToString());
                    modelDetails.psnIDAway = rowMatchTable["NM_Tecnico_TimeVisitante"].ToString();
                    modelDetails.userAwayName = rowMatchTable["NM_Tecnico_TimeVisitante"].ToString();
                    if (String.IsNullOrEmpty(modelDetails.psnIDAway))
                    {
                        modelDetails.psnIDAway = rowMatchTable["PSN2"].ToString();
                        modelDetails.userAwayName = rowMatchTable["PSN2"].ToString();
                    }
                }
                else
                {
                    modelDetails.userAwayID = Convert.ToInt32(rowMatchTable["IDUSU2"].ToString());
                    modelDetails.psnIDAway = rowMatchTable["PSN2"].ToString();
                    modelDetails.userAwayName = rowMatchTable["PSN2"].ToString();
                }
                if (DateTime.Now.Date >= modelDetails.startDate)
                    modelDetails.launchResultReleased = true;
                else
                    modelDetails.launchResultReleased = false;

                return modelDetails;
            }
            catch (Exception ex)
            {
                return modelDetails;
            }
            finally
            {
                modelDetails = null;
            }
        }


        public static string UppercaseWords(string value)
        {
            char[] array = value.ToCharArray();
            // Handle the first letter in the string.
            if (array.Length >= 1)
            {
                if (char.IsLower(array[0]))
                {
                    array[0] = char.ToUpper(array[0]);
                }
            }
            // Scan through the letters, checking for spaces.
            // ... Uppercase the lowercase letters following spaces.
            for (int i = 1; i < array.Length; i++)
            {
                if (array[i - 1] == ' ')
                {
                    if (char.IsLower(array[i]))
                    {
                        array[i] = char.ToUpper(array[i]);
                    }
                }
            }
            return new string(array);
        }
    }
}