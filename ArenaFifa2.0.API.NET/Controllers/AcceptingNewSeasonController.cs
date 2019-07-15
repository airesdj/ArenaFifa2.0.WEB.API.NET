using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.AcceptingNewSeasonModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class AcceptingNewSeasonController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postAccepting(AcceptingNewSeasonViewModel model)
        {
            if (String.IsNullOrEmpty(model.dataBaseName)) { model.dataBaseName = GlobalVariables.DATABASE_NAME_ONLINE; }
            db.openConnection(model.dataBaseName);
            var objFunctions = new Commons.functions();
            AcceptingNewSeasonViewModel mainModel = new AcceptingNewSeasonViewModel();
            AcceptingDetails modelDetails = new AcceptingDetails();
            DataTable dt = null;
            try
            {

                if (model.actionUser == "save")
                {
                    if (String.IsNullOrEmpty(model.confirmation)) { model.confirmation = null; }
                    if (String.IsNullOrEmpty(model.teamName)) { model.teamName = null; }
                    paramName = new string[] { "pIdTemporada", "pIdCampeonato", "pIdUsu", "pInConfirm", "pInOrdernacao", "pNmTimeFUT" };
                    paramValue = new string[] { Convert.ToString(model.seasonID), Convert.ToString(model.championshipID), Convert.ToString(model.userID), model.confirmation, model.ordering, model.teamName };
                    dt = db.executePROC("spAddUpdateConfirmacaoTemporada", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "getAllAccepting-staging")
                {
                    model.listOfAccepting = getAllAccepting(db);
                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "getAccepting-staging")
                {
                    modelDetails = GetAccepting(db, model.seasonID, model.userID, model.championshipID);
                    modelDetails.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                mainModel = null;
                dt = null;
                modelDetails = null;
            }
        }

        [HttpGet]
        public IHttpActionResult GetAll()
        {
            AcceptingNewSeasonViewModel mainModel = new AcceptingNewSeasonViewModel();
            db.openConnection();

            try
            {
                mainModel.listOfAccepting = getAllAccepting(db);
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            catch (Exception ex)
            {
                mainModel.listOfAccepting = new List<AcceptingDetails>();
                mainModel.returnMessage = "errorGetAllAccepting_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            finally
            {
                db.closeConnection();
                mainModel = null;
            }
        }


        [HttpGet]
        public IHttpActionResult GetDetails(string id)
        {

            AcceptingDetails modelDetails = new AcceptingDetails();
            DataTable dt = null;
            db.openConnection();


            try
            {
                string[] arrayPK = id.Split(Convert.ToChar(";"));

                modelDetails.seasonID = Convert.ToInt16(arrayPK[0]);
                modelDetails.userID = Convert.ToUInt16(arrayPK[1]);
                modelDetails.championshipID = Convert.ToInt16(arrayPK[2]);

                modelDetails = GetAccepting(db, modelDetails.seasonID, modelDetails.userID, modelDetails.championshipID);
                modelDetails.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            catch (Exception ex)
            {
                modelDetails.returnMessage = "errorGetAccepting_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                dt = null;
            }
        }

        private AcceptingDetails GetAccepting(connectionMySQL db, int seasonID, int userID, int championshipID)
        {
            AcceptingDetails modelDetails = new AcceptingDetails();
            DataTable dt = null;

            try
            {
                modelDetails.seasonID = seasonID;
                modelDetails.userID = userID;
                modelDetails.championshipID = championshipID;

                paramName = new string[] { "pIdTemporada", "pIdCampeonato", "pIdUsu" };
                paramValue = new string[] { Convert.ToString(modelDetails.seasonID), Convert.ToString(modelDetails.championshipID), Convert.ToString(modelDetails.userID) };
                dt = db.executePROC("spGetConfirmacaoTemporada", paramName, paramValue);

                if (dt.Rows.Count > 0)
                {
                    modelDetails.confirmation = dt.Rows[0]["IN_CONFIRMACAO"].ToString();
                    modelDetails.ordering = dt.Rows[0]["IN_ORDENACAO"].ToString();
                    modelDetails.DateconfirmationFormatted = dt.Rows[0]["DT_CONFIRMACAO_FORMATADA"].ToString();
                    modelDetails.psnID = dt.Rows[0]["PSN_ID"].ToString();
                    modelDetails.teamName = dt.Rows[0]["NM_TIME"].ToString();
                    modelDetails.statusID = dt.Rows[0]["DS_Status"].ToString();
                    modelDetails.statusDescription = dt.Rows[0]["DS_Descricao_Status"].ToString();
                }

                return modelDetails;
            }
            catch (Exception ex)
            {
                return modelDetails;
            }
            finally
            {
                dt = null;
                modelDetails = null;
            }
        }


        private List<AcceptingDetails> getAllAccepting(connectionMySQL db)
        {
            AcceptingDetails modelDetails = new AcceptingDetails();
            List<AcceptingDetails> listOfModel = new List<AcceptingDetails>();
            DataTable dt = null;

            try
            {
                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllConfirmacaoTemporadaNoFilterCRUD", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new AcceptingDetails();
                    modelDetails.seasonID = Convert.ToInt16(dt.Rows[i]["ID_TEMPORADA"].ToString());
                    modelDetails.userID = Convert.ToUInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.ordering = dt.Rows[i]["IN_ORDENACAO"].ToString();
                    modelDetails.primaryKey = Convert.ToString(modelDetails.seasonID) + ";" +
                                              Convert.ToString(modelDetails.userID) + ";" +
                                              Convert.ToString(modelDetails.championshipID);

                    modelDetails.confirmation = dt.Rows[i]["IN_CONFIRMACAO"].ToString();

                    if (string.IsNullOrEmpty(dt.Rows[i]["IN_CONFIRMACAO"].ToString()))
                        modelDetails.confirmationDescription = "Ainda não confirmou";
                    else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 9)
                        modelDetails.confirmationDescription = "Participação recusada pela Moderação";
                    else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 0)
                        modelDetails.confirmationDescription = "Não deseja Participar";
                    else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1)
                        modelDetails.confirmationDescription = "Confirmou Participação";

                    modelDetails.totalBlackList = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["PT_LSTNEGRA"].ToString()))
                        modelDetails.totalBlackList = Convert.ToInt16(dt.Rows[i]["PT_LSTNEGRA"].ToString());

                    modelDetails.statusID = dt.Rows[i]["DS_STATUS"].ToString();

                    if (!string.IsNullOrEmpty(dt.Rows[i]["IN_CONFIRMACAO"].ToString()))
                    {
                        if (modelDetails.statusID == "AP" && Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 0)
                            modelDetails.statusDescription = "DT - DESISTIU";
                        else if (modelDetails.statusID == "AP" && Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1 && modelDetails.totalBlackList >= 16)
                            modelDetails.statusDescription = "EA - EM ANÁLISE";
                        else if (modelDetails.statusID == "AP" && Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1)
                            modelDetails.statusDescription = "AP - APROVADO";
                        else if (modelDetails.statusID == "AP")
                            modelDetails.statusDescription = "AG - AGUARDANDO";
                        else if (modelDetails.statusID == "EA")
                            modelDetails.statusDescription = "EA - EM ANÁLISE";
                        else if (modelDetails.statusID == "NA")
                            modelDetails.statusDescription = "NA - NÃO ACEITO";

                    }

                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.DateconfirmationFormatted = dt.Rows[i]["DT_CONFIRMACAO_FORMATADA"].ToString();

                    listOfModel.Add(modelDetails);
                }

                return listOfModel;

            }
            catch (Exception ex)
            {
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
