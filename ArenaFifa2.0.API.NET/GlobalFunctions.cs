using DBConnection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using static ArenaFifa20.API.NET.Models.ChampionshipMatchTableModel;
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


    }
}