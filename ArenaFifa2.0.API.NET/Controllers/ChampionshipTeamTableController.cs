using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamTableModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipTeamTableController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAllForChampionship(int id)
        {

            ChampionshipTeamTableDetailsModel modelDetails = new ChampionshipTeamTableDetailsModel();
            ChampionshipTeamTableListViewModel mainModel = new ChampionshipTeamTableListViewModel();
            List<ChampionshipTeamTableDetailsModel> listOfModel = new List<ChampionshipTeamTableDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllClassificacaoTimeOfCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipTeamTableDetailsModel();
                    modelDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    modelDetails.groupID = Convert.ToInt16(dt.Rows[i]["ID_GRUPO"].ToString());
                    modelDetails.totalPoint = Convert.ToInt16(dt.Rows[i]["QT_PONTOS_GANHOS"].ToString());
                    modelDetails.totalWon = Convert.ToInt16(dt.Rows[i]["QT_VITORIAS"].ToString());
                    modelDetails.totalPlayed = Convert.ToInt16(dt.Rows[i]["QT_JOGOS"].ToString());
                    modelDetails.totalDraw = Convert.ToInt16(dt.Rows[i]["QT_EMPATES"].ToString());
                    modelDetails.totalLost = Convert.ToInt16(dt.Rows[i]["QT_DERROTAS"].ToString());
                    modelDetails.totalGoalsFOR = Convert.ToInt16(dt.Rows[i]["QT_GOLS_PRO"].ToString());
                    modelDetails.totalGoalsAGainst = Convert.ToInt16(dt.Rows[i]["QT_GOLS_CONTRA"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["IN_ORDENACAO_GRUPO"].ToString()))
                        modelDetails.orden = Convert.ToInt16(dt.Rows[i]["IN_ORDENACAO_GRUPO"].ToString());
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                    modelDetails.teamURL = dt.Rows[i]["DS_URL_TIME"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                        modelDetails.deletedCurrentSeason = Convert.ToInt16(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["PosicaoAnterior"].ToString()))
                        modelDetails.previousPosition = Convert.ToInt16(dt.Rows[i]["PosicaoAnterior"].ToString());
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfTeamTable = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipTeamTableListViewModel();
                mainModel.listOfTeamTable = new List<ChampionshipTeamTableDetailsModel>();
                mainModel.returnMessage = "errorGetAllTeamTableForChampionship_" + ex.Message;
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