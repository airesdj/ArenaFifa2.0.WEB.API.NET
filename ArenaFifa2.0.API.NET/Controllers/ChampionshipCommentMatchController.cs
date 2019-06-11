using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipCommentMatchModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipCommentMatchController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult actionPost(ChampionshipCommentMatchDetailsModel model)
        {

            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser.ToLower() == "save_comment")
                {

                    paramName = new string[] { "pIdJogo", "pIdUsu", "pDsComentario" };

                    paramValue = new string[] { Convert.ToString(model.matchID), Convert.ToString(model.userID), model.comment };

                    dt = db.executePROC("spAddComentarioJogo", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "errorPostChampionshipCommentMatch_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
            }


        }


        [HttpGet]
        public IHttpActionResult GetAllForMatch(int id)
        {

            ChampionshipCommentMatchDetailsModel modelDetails = new ChampionshipCommentMatchDetailsModel();
            ChampionshipCommentMatchListViewModel mainModel = new ChampionshipCommentMatchListViewModel();
            List<ChampionshipCommentMatchDetailsModel> listOfModel = new List<ChampionshipCommentMatchDetailsModel>();
            DataTable dt = null;
            db.openConnection();

            try
            {

                paramName = new string[] { "pIdJogo" };
                paramValue = new string[] { id.ToString() };
                dt = db.executePROC("spGetAllComentarioJogoByJogo", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipCommentMatchDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_COMENTARIO"].ToString());
                    modelDetails.matchID = Convert.ToInt32(dt.Rows[i]["ID_TABELA_JOGO"].ToString());
                    // modelDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.commentDate = Convert.ToDateTime(dt.Rows[i]["DT_COMENTARIO"].ToString());
                    modelDetails.commentHour = dt.Rows[i]["HR_COMENTARIO"].ToString();
                    modelDetails.comment = dt.Rows[i]["DS_COMENTARIO"].ToString();
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfCommentMatch = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);


            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipCommentMatchListViewModel();
                mainModel.listOfCommentMatch = new List<ChampionshipCommentMatchDetailsModel>();
                mainModel.returnMessage = "errorGetAllCommentMatchForMatch_" + ex.Message;
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