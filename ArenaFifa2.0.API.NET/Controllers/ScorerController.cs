using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.ScorerModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ScorerController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postRequest(ScorerDetails model)
        {

            ScorerViewModel mainModel = new ScorerViewModel();
            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser == "save")
                {
                    if (model.id > 0)
                    {
                        paramName = new string[] { "pIdGoleador", "pIdTime", "pNmGoleador", "pNmCompleto", "pDsLink", "pDsPais", "pIdSofifa", "pIdUsu" };
                        paramValue = new string[] { Convert.ToString(model.id), Convert.ToString(model.teamID), model.nickname, model.name, model.link, model.country, model.sofifaTeamID, Convert.ToString(model.userID) };
                        dt = db.executePROC("spUpdateGoleador", paramName, paramValue);
                    }
                    else
                    {
                        paramName = new string[] { "pIdGoleador", "pIdTime", "pNmGoleador", "pNmCompleto", "pDsLink", "pDsPais", "pIdSofifa", "pTipo", "pIdUsu" };
                        paramValue = new string[] { "0", Convert.ToString(model.teamID), model.nickname, model.name, model.link, model.country, model.sofifaTeamID, model.scorerType, Convert.ToString(model.userID)};
                        dt = db.executePROC("spAddGoleador", paramName, paramValue);
                    }

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "getListOfScorerByTeam")
                {
                    paramName = new string[] { "pIdTime" };
                    paramValue = new string[] { Convert.ToString(model.teamID) };
                    dt = db.executePROC("spGetAllGoleadorByTime", paramName, paramValue);

                    mainModel.listOfScorer = setUpListDetailsScorers(dt);
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else if (model.actionUser == "getListOfScorerByMatchTeam")
                {
                    paramName = new string[] { "pIdJogo", "pIdTime" };
                    paramValue = new string[] { Convert.ToString(model.id), Convert.ToString(model.teamID) };
                    dt = db.executePROC("spGetGoleadorGolsOfTime", paramName, paramValue);

                    mainModel.listOfScorer = setUpListDetailsScorers(dt);
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
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
                dt = null;
                mainModel = null;

            }
        }

        [HttpGet]
        public IHttpActionResult GetDetails(string id)
        {

            ScorerDetails modelDetails = new ScorerDetails();
            ScorerViewModel mainModel = new ScorerViewModel();
            DataTable dt = null;
            db.openConnection();


            try
            {
                if (id.All(char.IsDigit))
                {
                    paramName = new string[] { "pIdGoleador" };
                    paramValue = new string[] { id };
                    dt = db.executePROC("spGetGoleadorByGoleador", paramName, paramValue);

                    if (dt.Rows.Count > 0)
                    {
                        if (dt.Rows[0]["NM_TIPO_TIME"].ToString()=="PRO CLUB")
                            modelDetails.scorerType = "PRO";
                        else
                            modelDetails.scorerType = "H2H";
                        modelDetails.id = Convert.ToInt32(id);
                        modelDetails.teamID = Convert.ToInt16(dt.Rows[0]["ID_TIME"].ToString());
                        modelDetails.DateSubscriptionFormatted = dt.Rows[0]["DT_FORMATADA"].ToString();
                        modelDetails.nickname = dt.Rows[0]["NM_GOLEADOR"].ToString();
                        modelDetails.name = dt.Rows[0]["NM_GOLEADOR_COMPLETO"].ToString();
                        modelDetails.country = dt.Rows[0]["DS_PAIS"].ToString();
                        modelDetails.link = dt.Rows[0]["DS_LINK_IMAGEM"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_TIME_SOFIFA"].ToString()))
                            modelDetails.sofifaTeamID = dt.Rows[0]["ID_TIME_SOFIFA"].ToString();
                        modelDetails.rating = dt.Rows[0]["IN_RATING"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_USUARIO"].ToString()))
                            modelDetails.userID = Convert.ToInt32(dt.Rows[0]["ID_USUARIO"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["DT_INSCRICAO"].ToString()))
                            modelDetails.DateSubscription = Convert.ToDateTime(dt.Rows[0]["DT_INSCRICAO"].ToString());
                    }

                    modelDetails.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
                }
                else
                {

                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    if (id=="H2H")
                        dt = db.executePROC("spGetAllGoleadoresNoFilterCRUDH2H", paramName, paramValue);
                    else
                        dt = db.executePROC("spGetAllGoleadoresNoFilterCRUDPRO", paramName, paramValue);

                    mainModel.scorerType = id;

                    mainModel.listOfScorer = setUpListDetailsScorers(dt);
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }

            }
            catch (Exception ex)
            {
                modelDetails.returnMessage = "errorGetScorer_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                dt = null;
                mainModel = null;
            }

        }

        private List<ScorerDetails> setUpListDetailsScorers(DataTable dt)
        {
            List<ScorerDetails> oList = new List<ScorerDetails>();
            ScorerDetails modelDetails = new ScorerDetails();
            try
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ScorerDetails();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_GOLEADOR"].ToString());
                    modelDetails.teamID = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    modelDetails.teamName = dt.Rows[i]["NM_TIME"].ToString();
                    modelDetails.teamType = dt.Rows[i]["DS_TIPO"].ToString();
                    modelDetails.DateSubscriptionFormatted = dt.Rows[i]["DT_FORMATADA"].ToString();
                    modelDetails.nickname = dt.Rows[i]["NM_GOLEADOR"].ToString();
                    modelDetails.name = dt.Rows[i]["NM_GOLEADOR_COMPLETO"].ToString();
                    modelDetails.country = dt.Rows[i]["DS_PAIS"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["ID_TIME_SOFIFA"].ToString()))
                        modelDetails.sofifaTeamID = dt.Rows[i]["ID_TIME_SOFIFA"].ToString();
                    modelDetails.rating = dt.Rows[i]["IN_RATING"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["ID_USUARIO"].ToString()))
                        modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["DT_INSCRICAO"].ToString()))
                        modelDetails.DateSubscription = Convert.ToDateTime(dt.Rows[i]["DT_INSCRICAO"].ToString());
                    oList.Add(modelDetails);
                }
                return oList;
            }
            catch
            {
                return new List<ScorerDetails>();
            }
            finally
            {
                oList = null;
                modelDetails = null;
            }
        }
    }
}
