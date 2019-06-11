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
    public class ChampionshipCommentUsersController : ApiController
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

                if (model.actionUser.ToLower() == "save_user_comment")
                {
                    paramName = new string[] { "pIdTab", "pIdCamp", "pIdUsu" };

                    paramValue = new string[] { model.matchID.ToString(), model.championshipID.ToString(), model.userID.ToString() };

                    dt = db.executePROC("spAddComentarioUsuario", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "cancel_user_comment")
                {
                    paramName = new string[] { "pIdTab", "pIdCamp", "pIdUsu" };

                    paramValue = new string[] { model.matchID.ToString(), model.championshipID.ToString(), model.userID.ToString() };

                    dt = db.executePROC("spDeleteComentarioUsuario", paramName, paramValue);

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
                model.returnMessage = "errorPostChampionshipCommentMatchUsers_" + ex.Message;
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

            ChampionshipCommentMatchUsersDetailsModel modelDetails = new ChampionshipCommentMatchUsersDetailsModel();
            ChampionshipCommentMatchUsersListViewModel mainModel = new ChampionshipCommentMatchUsersListViewModel();
            List<ChampionshipCommentMatchUsersDetailsModel> listOfModel = new List<ChampionshipCommentMatchUsersDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdJogo" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllComentarioUsuarioByJogo", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipCommentMatchUsersDetailsModel();
                    modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.email = dt.Rows[i]["DS_EMAIL"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfUsersCommentMatch = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipCommentMatchUsersListViewModel();
                mainModel.listOfUsersCommentMatch = new List<ChampionshipCommentMatchUsersDetailsModel>();
                mainModel.returnMessage = "errorGetAllColmmentMatchUsers_" + ex.Message;
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