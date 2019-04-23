using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.BlackListModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class BlackListController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult blackList(BlackListViewModel model)
        {


            db.openConnection();
            DataTable dt = null;
            Boolean bActionUser = false;

            try
            {

                if (model.actionUser == "summaryList")
                {
                    paramName = new string[] { "pIdTemp" };
                    paramValue = new string[] { Convert.ToString(model.seasonID) };
                    dt = db.executePROC("spGetListaNegraSummaryByTemporada", paramName, paramValue);

                    SetBlackListSummarySeason(dt, model);

                    bActionUser = true;
                }
                else if (model.actionUser == "detailsList")
                {
                    paramName = new string[] { "pIdTemp", "pIdUsu" };
                    paramValue = new string[] { Convert.ToString(model.seasonID), Convert.ToString(model.userID) };
                    dt = db.executePROC("spGetListaNegraDetalheByTemporadaEUsuario", paramName, paramValue);

                    SetBlackListDetailsSeason(dt, model);

                    bActionUser = true;

                }

                if (bActionUser)
                {
                    model.returnMessage = "BlackListSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                model = new BlackListViewModel();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;

            }

        }

        private void SetBlackListSummarySeason(DataTable dt, BlackListViewModel blackListDetails)
        {
            List<BlackListSummary> listOfBlackList = new List<BlackListSummary>();
            BlackListSummary summaryDetails= new BlackListSummary();

            blackListDetails.seasonID = Convert.ToInt16(dt.Rows[0]["ID_TEMPORADA"].ToString());
            blackListDetails.dtUpdateFormated = dt.Rows[0]["DT_FORMATADA"].ToString();
            blackListDetails.seasonName = dt.Rows[0]["NM_TEMPORADA"].ToString();

            for (var i = 0; i < dt.Rows.Count; i++)
            {
                summaryDetails = new BlackListSummary();
                summaryDetails.userID = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                summaryDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                summaryDetails.nameUser = dt.Rows[i]["NM_USUARIO"].ToString();
                summaryDetails.noWarning = Convert.ToInt16(dt.Rows[i]["QT_ADVERTENCIAS"].ToString());
                summaryDetails.noPartialOmission = Convert.ToInt16(dt.Rows[i]["QT_OMISSAO_PARCIAL"].ToString());
                summaryDetails.noTotalOmission = Convert.ToInt16(dt.Rows[i]["QT_OMISSAO_TOTAL"].ToString());
                summaryDetails.noUnsportsmanlike = Convert.ToInt16(dt.Rows[i]["QT_ANTIDESPORTIVA"].ToString());
                summaryDetails.total = Convert.ToInt16(dt.Rows[i]["PT_TOTAL"].ToString());
                listOfBlackList.Add(summaryDetails);
            }

            blackListDetails.listSummary = listOfBlackList;

            listOfBlackList = null;
            summaryDetails = null;
        }


        private void SetBlackListDetailsSeason(DataTable dt, BlackListViewModel blackListDetails)
        {
            List<BlackListDetails> listOfBlackList = new List<BlackListDetails>();
            BlackListDetails summaryDetails = new BlackListDetails();

            blackListDetails.seasonID = Convert.ToInt16(dt.Rows[0]["ID_TEMPORADA"].ToString());
            blackListDetails.userID = Convert.ToInt16(dt.Rows[0]["ID_USUARIO"].ToString());
            blackListDetails.dtUpdateFormated = dt.Rows[0]["DT_FORMATADA"].ToString();
            blackListDetails.seasonName = dt.Rows[0]["NM_TEMPORADA"].ToString();
            blackListDetails.psnID = dt.Rows[0]["PSN_ID"].ToString();
            blackListDetails.nameUser = dt.Rows[0]["NM_USUARIO"].ToString();

            for (var i = 0; i < dt.Rows.Count; i++)
            {
                summaryDetails = new BlackListDetails();
                summaryDetails.matchID = Convert.ToInt16(dt.Rows[i]["ID_TABELA_JOGO"].ToString());
                summaryDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                summaryDetails.championshipName = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                summaryDetails.stageName = dt.Rows[i]["NM_FASE"].ToString();
                summaryDetails.typeMode = dt.Rows[i]["TYPE_MODE"].ToString();
                summaryDetails.roundID = Convert.ToInt16(dt.Rows[i]["IN_NUMERO_RODADA"].ToString());
                summaryDetails.noWarning = Convert.ToInt16(dt.Rows[i]["IN_ADVERTENCIAS"].ToString());
                summaryDetails.noPartialOmission = Convert.ToInt16(dt.Rows[i]["IN_OMISSAO_PARCIAL"].ToString());
                summaryDetails.noTotalOmission = Convert.ToInt16(dt.Rows[i]["IN_OMISSAO_TOTAL"].ToString());
                summaryDetails.noUnsportsmanlike = Convert.ToInt16(dt.Rows[i]["IN_ANTIDESPORTIVA"].ToString());
                summaryDetails.valueBlackList = Convert.ToInt16(dt.Rows[i]["PT_NEGATIVO"].ToString());
                listOfBlackList.Add(summaryDetails);
            }

            blackListDetails.listDetails = listOfBlackList;

            listOfBlackList = null;
            summaryDetails = null;
        }


    }
}