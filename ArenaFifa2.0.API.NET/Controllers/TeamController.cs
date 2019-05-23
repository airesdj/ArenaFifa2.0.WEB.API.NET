using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.TeamModel;
using static ArenaFifa20.API.NET.Models.ScorerModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;

namespace ArenaFifa20.API.NET.Controllers
{
    public class TeamController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult team(TeamDetailsModel model)
        {

            db.openConnection();
            DataTable dt = null;
            var objFunctions = new Commons.functions();

            try
            {

                if (model.actionUser.ToLower() == "dellcrud")
                {
                    paramName = new string[] { "idTime" };
                    paramValue = new string[] { Convert.ToString(model.id) };
                    dt = db.executePROC("spDeleteTime", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "save" && model.id > 0)
                {
                    paramName = new string[] { "pIdTime", "pNmTime", "pdsUrl", "pIdTipo", "pIdTimeSofifa", "pIdTecnico"};

                    paramValue = new string[] { Convert.ToString(model.id), model.name, model.teamSofifaURL,
                                                Convert.ToString(model.typeModeID), Convert.ToString(model.teamSofifaID),
                                                Convert.ToString(model.userID) };

                    dt = db.executePROC("spAddTime", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else if (model.actionUser.ToLower() == "save" && model.id == 0)
                {
                    paramName = new string[] { "pNmTime", "pdsUrl", "pIdTipo", "pIdTimeSofifa", "pIdTecnico" };

                    paramValue = new string[] { model.name, model.teamSofifaURL, Convert.ToString(model.typeModeID),
                                                Convert.ToString(model.teamSofifaID), Convert.ToString(model.userID)};


                    dt = db.executePROC("spAddTime", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else if (model.actionUser.ToLower() == "updateteamplayerslist")
                {

                    string getHtmlSofifaTeamPlayersList = objFunctions.getTeamSofifaHTML(model.teamSofifaURL);

                    processSofifaHTML(getHtmlSofifaTeamPlayersList, ref model);

                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "errorPostTeam_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                objFunctions = null;
            }


        }

        private void processSofifaHTML(string teamSofifaHTML, ref TeamDetailsModel teamModel)
        {
            ScorerDetails scorerDetails = new ScorerDetails();
            List<ScorerDetails> listOfScorer = new List<ScorerDetails>();
            DataTable dt = null;

            int position = 0;
            int htmlFinish = 0;
            Boolean playerFound = true;
            string playerDetailsHtml = String.Empty;
            int positonStartPlayerDetals = 0;
            int positonEndPlayerDetals = 0;

            string id = String.Empty;
            string nickname = String.Empty;
            string name = String.Empty;
            string link = String.Empty;
            string country = String.Empty;
            string rating = String.Empty;

            try
            {
                position = teamSofifaHTML.IndexOf("<tbody>");
                teamSofifaHTML = teamSofifaHTML.Substring(position+1);
                position = teamSofifaHTML.Substring(7).IndexOf("tbody>");
                teamSofifaHTML = teamSofifaHTML.Substring(0, position+14);
                teamSofifaHTML = teamSofifaHTML.Replace("<tbody>", "</tbody>");
                teamSofifaHTML = "<" + teamSofifaHTML;

                htmlFinish = teamSofifaHTML.IndexOf("</tbody>");

                positonStartPlayerDetals = teamSofifaHTML.IndexOf("<tr");
                positonEndPlayerDetals = teamSofifaHTML.IndexOf("</tr");
                playerDetailsHtml = teamSofifaHTML.Substring(positonStartPlayerDetals, positonEndPlayerDetals);

                while (playerFound==true)
                {
                    playerDetailsSplitFromHtml(playerDetailsHtml, ref id, ref nickname, ref name, ref link, ref country, ref rating);

                    if (!String.IsNullOrEmpty(id) && id.All(char.IsDigit))
                    {
                        scorerDetails = new ScorerDetails();
                        scorerDetails.id = Convert.ToInt32(id);
                        scorerDetails.name = name;
                        scorerDetails.nickname = nickname;
                        scorerDetails.link = link;
                        scorerDetails.country = country;
                        scorerDetails.rating = rating;
                        scorerDetails.sofifaTeamID = Convert.ToString(teamModel.teamSofifaID);
                        scorerDetails.teamID = teamModel.id;

                        paramName = new string[] { "pIdGoleador" };
                        paramValue = new string[] { id };
                        dt = db.executePROC("spGetGoleadorByGoleador", paramName, paramValue);
                        if (dt.Rows.Count==0)
                        {
                            paramName = new string[] { "pIdGoleador", "pIdTime", "pNmGoleador", "pNmCompleto", "pDsLink", "pDsPais", "pIdSofifa", "pTipo", "pIdUsu" };
                            paramValue = new string[] { Convert.ToString(scorerDetails.id), Convert.ToString(scorerDetails.teamID), scorerDetails.nickname, scorerDetails.name, scorerDetails.link, scorerDetails.country, scorerDetails.sofifaTeamID, "H2H", "0" };
                            dt = db.executePROC("spAddGoleador", paramName, paramValue);
                        }
                        listOfScorer.Add(scorerDetails);

                        positonStartPlayerDetals = positonEndPlayerDetals + 4;
                        positonEndPlayerDetals = teamSofifaHTML.Length - positonStartPlayerDetals;
                        teamSofifaHTML = teamSofifaHTML.Substring(positonStartPlayerDetals, positonEndPlayerDetals);

                        positonStartPlayerDetals = teamSofifaHTML.IndexOf("<tr");
                        positonEndPlayerDetals = teamSofifaHTML.IndexOf("</tr");
                        if (positonStartPlayerDetals>-1 && positonEndPlayerDetals>-1)
                            playerDetailsHtml = teamSofifaHTML.Substring(positonStartPlayerDetals, positonEndPlayerDetals- positonStartPlayerDetals);
                        else
                            playerFound = false;
                    }
                    else
                    {
                        playerFound = false;
                    }

                }

                teamModel.listOfScorer = listOfScorer;
                teamModel.returnMessage = "ModeratorSuccessfully";

            }
            catch (Exception ex)
            {
                teamModel.listOfScorer = new List<ScorerDetails>();
                teamModel.returnMessage = "errorGetTeamDetails_" + ex.Message;
            }
            finally
            {
                scorerDetails = null;
                listOfScorer = null;
                dt = null;
            }

        }

        private void playerDetailsSplitFromHtml(string playerDetailsHtml, ref string id, ref string nickname, ref string name, 
                                                ref string link, ref string country, ref string rating)
        {
            string pos = String.Empty;
            int i = 0;
            int fim = playerDetailsHtml.Length;
            int aux = 0;
            string[] arrayAux = null;
            try
            {
                //link and id
                aux = ("avatar").Length + 24;
                i = playerDetailsHtml.Substring(i, fim).IndexOf("avatar") + aux;
                fim = playerDetailsHtml.Length - 1;
                playerDetailsHtml = playerDetailsHtml.Substring(i, fim - i);
                fim = playerDetailsHtml.Length - 1;
                aux = playerDetailsHtml.Substring(0, fim - i).IndexOf("data-srcset") - 3;
                link = playerDetailsHtml.Substring(1, aux);
                arrayAux = link.Split(Convert.ToChar("/"));
                id = arrayAux[arrayAux.Length - 1].Split(Convert.ToChar("."))[0];


                playerDetailsHtml = playerDetailsHtml.Substring(aux, fim - aux);
                fim = playerDetailsHtml.Length;
                i = 0;


                //country
                aux = ("title").Length + 2;
                i = playerDetailsHtml.Substring(i, fim).IndexOf("title") + aux;
                playerDetailsHtml = playerDetailsHtml.Substring(i, fim - i - 1);
                fim = playerDetailsHtml.Substring(0, playerDetailsHtml.Length).IndexOf(">") + 2;
                country = playerDetailsHtml.Substring(0, fim-3);


                playerDetailsHtml = playerDetailsHtml.Substring(fim, playerDetailsHtml.Length - fim);
                fim = playerDetailsHtml.Length;
                i = 0;


                //name and nickname
                aux = ("title").Length + 2;
                i = playerDetailsHtml.Substring(i, fim).IndexOf("title") + aux;
                playerDetailsHtml = playerDetailsHtml.Substring(i, fim - i - 1);
                fim = playerDetailsHtml.Substring(0, playerDetailsHtml.Length).IndexOf(">") + 2;
                name = playerDetailsHtml.Substring(0, fim - 3);
                i = name.Length + 2;
                fim = playerDetailsHtml.Substring(0, playerDetailsHtml.Length).IndexOf("</a>");
                nickname = playerDetailsHtml.Substring(i, fim - i);


                playerDetailsHtml = playerDetailsHtml.Substring(fim, playerDetailsHtml.Length - fim);
                fim = playerDetailsHtml.Length;
                i = 0;


                //pos
                aux = ("pos0").Length + 2;
                i = playerDetailsHtml.Substring(i, fim).IndexOf("pos0") + aux;
                pos = playerDetailsHtml.Substring(i, 2);


                playerDetailsHtml = playerDetailsHtml.Substring(i, playerDetailsHtml.Length - i);
                fim = playerDetailsHtml.Length;
                i = 0;

                //rating
                aux = ("label p ").Length + 5;
                i = playerDetailsHtml.Substring(0, fim).IndexOf("label p ") + aux;
                rating = playerDetailsHtml.Substring(i, 2);

            }
            catch
            {
                id = String.Empty;
            }
        }

        [HttpGet]
        public IHttpActionResult GetTeamDetails(string id)
        {

            TeamDetailsModel modelDetails = new TeamDetailsModel();
            TeamListViewModel mainModel = new TeamListViewModel();
            List<TeamDetailsModel> listOfModel = new List<TeamDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                if (id.All(char.IsDigit))
                {
                    paramName = new string[] { "idTime" };
                    paramValue = new string[] { id };
                    dt = db.executePROC("spGetTime", paramName, paramValue);

                    if (dt.Rows.Count > 0)
                    {
                        modelDetails.id = Convert.ToInt32(id);
                        modelDetails.name = dt.Rows[0]["NM_TIME"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[0]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                            modelDetails.teamDeleted = Convert.ToByte(dt.Rows[0]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_TIME_SOFIFA"].ToString()))
                            modelDetails.teamSofifaID = Convert.ToInt32(dt.Rows[0]["ID_TIME_SOFIFA"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[0]["IN_TIME_COM_IMAGEM"].ToString()))
                            modelDetails.hasImage = Convert.ToByte(dt.Rows[0]["IN_TIME_COM_IMAGEM"].ToString());
                        modelDetails.typeModeID = Convert.ToUInt16(dt.Rows[0]["ID_TIPO_TIME"].ToString());
                        modelDetails.teamSofifaURL = dt.Rows[0]["DS_URL_TIME"].ToString();
                        modelDetails.typeMode = dt.Rows[0]["NM_Tipo_Time"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[0]["ID_Tecnico_FUT"].ToString()))
                        {
                            modelDetails.userID = Convert.ToInt32(dt.Rows[0]["ID_Tecnico_FUT"].ToString());
                            modelDetails.userName = dt.Rows[0]["NM_Tecnico_FUT"].ToString();
                        }
                    }

                    modelDetails.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

                }
                else
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetAllTimes" + id, paramName, paramValue);

                    mainModel.teamType = id;

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new TeamDetailsModel();
                        modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString());
                        modelDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                            modelDetails.teamDeleted = Convert.ToByte(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["ID_TIME_SOFIFA"].ToString()))
                            modelDetails.teamSofifaID = Convert.ToInt32(dt.Rows[i]["ID_TIME_SOFIFA"].ToString());
                        if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString()))
                            modelDetails.hasImage = Convert.ToByte(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString());
                        modelDetails.typeModeID = Convert.ToUInt16(dt.Rows[i]["ID_TIPO_TIME"].ToString());
                        modelDetails.typeMode = dt.Rows[i]["DS_TIPO"].ToString();
                        modelDetails.teamSofifaURL = dt.Rows[0]["DS_URL_TIME"].ToString();
                        listOfModel.Add(modelDetails);
                    }

                    mainModel.listOfTeam = listOfModel;
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }

            }
            catch (Exception ex)
            {
                mainModel = new TeamListViewModel();
                mainModel.listOfTeam = new List<TeamDetailsModel>();
                mainModel.returnMessage = "errorGetTeamDetails_" + ex.Message;
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

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            TeamDetailsModel modelDetails = new TeamDetailsModel();
            TeamListViewModel mainModel = new TeamListViewModel();
            List<TeamDetailsModel> listOfModel = new List<TeamDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllTimesNoFilterCRUD", paramName, paramValue);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new TeamDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_TIME"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString()))
                        modelDetails.teamDeleted = Convert.ToByte(dt.Rows[i]["IN_TIME_EXCLUIDO_TEMP_ATUAL"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["ID_TIME_SOFIFA"].ToString()))
                        modelDetails.teamSofifaID = Convert.ToInt32(dt.Rows[i]["ID_TIME_SOFIFA"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString()))
                        modelDetails.hasImage = Convert.ToByte(dt.Rows[i]["IN_TIME_COM_IMAGEM"].ToString());
                    modelDetails.typeModeID = Convert.ToUInt16(dt.Rows[i]["ID_TIPO_TIME"].ToString());
                    modelDetails.typeMode = dt.Rows[i]["NM_Tipo_Time"].ToString();
                    modelDetails.teamSofifaURL = dt.Rows[i]["DS_URL_TIME"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[i]["NM_Usuario"].ToString()))
                    {
                        modelDetails.userName = dt.Rows[i]["NM_Tecnico_FUT"].ToString();
                    }
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfTeam = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            catch (Exception ex)
            {
                mainModel = new TeamListViewModel();
                mainModel.listOfTeam = new List<TeamDetailsModel>();
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