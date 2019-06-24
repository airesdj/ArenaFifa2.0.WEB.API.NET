using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.MyMatchesModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class MyMatchesController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult ranking(MyMatchesSummaryViewModel model)
        {

            MyNextMatchesViewModel MyMatchesModel = new MyNextMatchesViewModel();
            db.openConnection();
            DataTable dt = null;
            string returnMessage = String.Empty;
            try
            {

                if (model.actionUser == "summary")
                {
                    paramName = new string[] { "pIdUsu" };
                    paramValue = new string[] { model.userID.ToString() };
                    dt = db.executePROC("spGetSummaryMyMatches", paramName, paramValue);

                    model.totalGoals = Convert.ToInt16(dt.Rows[0]["totalGoals"].ToString());
                    model.totalMatches = Convert.ToInt16(dt.Rows[0]["totalMatches"].ToString());
                    model.averageGoals = Convert.ToInt16(dt.Rows[0]["averageGoals"].ToString());

                    model.teamNameH2H = dt.Rows[0]["teamNameH2H"].ToString();
                    model.teamNameFUT = dt.Rows[0]["teamNameFUT"].ToString();
                    model.teamNamePRO = dt.Rows[0]["teamNamePRO"].ToString();

                    model.listOfScorersH2H = GlobalFunctions.getListScorers("H2H", db, model.userID);
                    model.listOfScorersPRO = GlobalFunctions.getListScorers("PRO", db, model.userID);

                    model.returnMessage = "MyMatchesSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "myNextMatchesH2H")
                {
                    MyMatchesModel.typeMode = "H2H";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("H2H", "NEXT", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;
                    if (returnMessage== "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("NEXT", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDH2H,
                                                                                                MyMatchesModel.totalsMyMatches.natonalTeamIDCPDM,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myMatchesDoneH2H")
                {
                    MyMatchesModel.typeMode = "H2H";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("H2H", "DONE", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;
                    if (returnMessage == "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("DONE", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDH2H,
                                                                                                MyMatchesModel.totalsMyMatches.natonalTeamIDCPDM,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myListOfScorersH2H")
                {
                    MyMatchesModel.typeMode = "H2H";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal(MyMatchesModel.typeMode, "SCORERS", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;
                    if (returnMessage == "MyMatchesSuccessfully")
                        MyMatchesModel.listOfScorers = GlobalFunctions.getListScorers(MyMatchesModel.typeMode, db, model.userID, false, 0);
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myNextMatchesFUT")
                {
                    MyMatchesModel.typeMode = "FUT";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("FUT", "NEXT", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;

                    if (returnMessage == "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("NEXT", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDFUT, 0,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myMatchesDoneFUT")
                {
                    MyMatchesModel.typeMode = "FUT";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("FUT", "DONE", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;

                    if (returnMessage == "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("DONE", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDFUT, 0,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "uploadLogoTeamFUTDetails")
                {
                    MyMatchesModel.typeMode = "FUT";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal(MyMatchesModel.typeMode, "NEXT", db, model.userID);
                    MyMatchesModel.returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myNextMatchesPRO")
                {
                    MyMatchesModel.typeMode = "PRO";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("PRO", "NEXT", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;

                    if (returnMessage == "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("NEXT", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDPRO, 0,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myMatchesDonePRO")
                {
                    MyMatchesModel.typeMode = "PRO";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal("PRO", "DONE", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;

                    if (returnMessage == "MyMatchesSuccessfully")
                    {
                        MyMatchesModel.listOfMatch = GlobalFunctions.getListOfMatchForMyMatches("DONE", db,
                                                                                                MyMatchesModel.totalsMyMatches.teamIDPRO, 0,
                                                                                                out returnMessage);
                    }
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "myListOfScorersPRO")
                {
                    MyMatchesModel.typeMode = "PRO";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal(MyMatchesModel.typeMode, "SCORERS", db, model.userID);
                    returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;
                    if (returnMessage == "MyMatchesSuccessfully")
                        MyMatchesModel.listOfScorers = GlobalFunctions.getListScorers(MyMatchesModel.typeMode, db, model.userID, false, 0);
                    MyMatchesModel.returnMessage = returnMessage;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "uploadLogoTeamPRODetails")
                {
                    MyMatchesModel.typeMode = "PRO";
                    MyMatchesModel.userID = model.userID;
                    MyMatchesModel.totalsMyMatches = GlobalFunctions.getMyMatchesTotal(MyMatchesModel.typeMode, "NEXT", db, model.userID);
                    MyMatchesModel.returnMessage = MyMatchesModel.totalsMyMatches.returnMessage;

                    if (MyMatchesModel.returnMessage == "MyMatchesSuccessfully")
                    {
                        paramName = new string[] { "pIdUsuario" };
                        paramValue = new string[] { Convert.ToString(model.userID) };
                        dt = db.executePROC("spGetUsuarioById", paramName, paramValue);

                        MyMatchesModel.psnID = dt.Rows[0]["PSN_ID"].ToString();
                        MyMatchesModel.userName = dt.Rows[0]["NM_USUARIO"].ToString();
                        MyMatchesModel.mobileNumber = dt.Rows[0]["NO_CELULAR"].ToString();
                        MyMatchesModel.codeMobileNumber = dt.Rows[0]["NO_DDD"].ToString();

                        MyMatchesModel.listOfSquad = GlobalFunctions.getListOfSquadPROCLUB(db, 0, model.userID, out returnMessage);
                        MyMatchesModel.returnMessage = returnMessage;
                    }
                    else
                        MyMatchesModel.listOfSquad = new List<squadListModel>();

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "uploadLogoTeamPROListOfSquad")
                {
                    MyMatchesModel.listOfSquad = GlobalFunctions.getListOfSquadPROCLUB(db, 0, model.userID, out returnMessage);
                    MyMatchesModel.returnMessage = returnMessage;

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
                }
                else if (model.actionUser == "updateMobileManagerPRO")
                {
                    paramName = new string[] { "pIdUsuario", "pDDD", "pMobile" };
                    paramValue = new string[] { Convert.ToString(model.userID), model.codeMobileNumber, model.mobileNumber };
                    db.executePROCNonResult("spUpdateMobile", paramName, paramValue);

                    model.returnMessage = "MyMatchesSuccessfully";

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "spAddPlayerSquadPro")
                {
                    paramName = new string[] { "pIdClub", "pPsnJogador" };
                    paramValue = new string[] { Convert.ToString(model.teamID), model.psnID };
                    dt = db.executePROC("spAddPlayerSquadPro", paramName, paramValue);

                    if (dt.Rows[0]["COD_VALIDATION"].ToString() == "0")
                        model.returnMessage = "MyMatchesSuccessfully";
                    else if(dt.Rows[0]["COD_VALIDATION"].ToString() == "1")
                        model.returnMessage = "PsnNotFound";
                    else if (dt.Rows[0]["COD_VALIDATION"].ToString() == "2")
                        model.returnMessage = "PlayerIsInYourClub";
                    else if (dt.Rows[0]["COD_VALIDATION"].ToString() == "3")
                        model.returnMessage = "PlayerIsInAnotherClub";

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "spDeletePlayerSquadPro")
                {
                    paramName = new string[] { "pIdGoleador" };
                    paramValue = new string[] { Convert.ToString(model.userID) };
                    db.executePROCNonResult("spDeteleGoleador", paramName, paramValue);
                    model.returnMessage = "MyMatchesSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                MyMatchesModel = new MyNextMatchesViewModel();
                MyMatchesModel.listOfMatch = new List<Models.ChampionshipMatchTableModel.ChampionshipMatchTableDetailsModel>();
                MyMatchesModel.totalsMyMatches = new MyMatchesTotalModel();
                MyMatchesModel.userID = model.userID;
                MyMatchesModel.actionUser = model.actionUser;
                MyMatchesModel.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, MyMatchesModel);
            }
            finally
            {
                db.closeConnection();
                dt = null;
                MyMatchesModel = null;
            }

        }

    }
}