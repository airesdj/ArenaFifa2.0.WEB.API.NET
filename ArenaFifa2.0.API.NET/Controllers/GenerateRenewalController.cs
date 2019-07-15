using System;
using System.Web.Http;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using static ArenaFifa20.API.NET.Models.GenerateRenewalModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class GenerateRenewalController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult hallOfFame(GenerateRenewalViewModel model)
        {
            if (String.IsNullOrEmpty(model.dataBaseName)) { model.dataBaseName = GlobalVariables.DATABASE_NAME_ONLINE; }
            db.openConnection(model.dataBaseName);
            DataTable dt = null;

            try
            {

                if (model.actionUser == "summary")
                {
                    getSummaryDetails(ref model, db);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "prepareDatabaseBefore")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    db.executePROCNonResult("spDeleteAllRecords", paramName, paramValue);
                    db.executePROCNonResult("spTransferDataFromOnlineDtb", paramName, paramValue);

                    getSummaryDetails(ref model, db, true);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "generateRenewal")
                {
                    string inWorldCup_Euro = "0";
                    if (model.inRenewalWithEuro==1 || model.inRenewalWithWorldCup==1) { inWorldCup_Euro = "1"; }
                    paramName = new string[] { "pInWorldCupNextSeason" };
                    paramValue = new string[] { inWorldCup_Euro };
                    db.executePROCNonResult("spGenerateRenewalsForNextSeason", paramName, paramValue);

                    getSummaryDetails(ref model, db, true);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "createSpooler")
                {
                    paramName = new string[] { "pIdUsuAction" };
                    paramValue = new string[] { model.userActionID.ToString() };
                    db.executePROCNonResult("spCreateRenewalSpoolerForNextSeason", paramName, paramValue);

                    getSummaryDetails(ref model, db, true);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "cancelRenewal")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    db.executePROCNonResult("spCancelRenewalsForNextSeason", paramName, paramValue);

                    getSummaryDetails(ref model, db, true);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "cancelSpooler")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    db.executePROCNonResult("spCancelRenewalSpoolerForNextSeason", paramName, paramValue);

                    getSummaryDetails(ref model, db, true);
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "getDetailsRenewalHome")
                {
                    paramName = new string[] { "pIdUser" };
                    paramValue = new string[] { model.renewalModel.userID.ToString() };
                    dt = db.executePROC("spGetAllDetailsRenewalHome", paramName, paramValue);


                    model.renewalModel.seasonID = Convert.ToInt16(dt.Rows[0]["temporadaID"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[0]["confirmH2H"].ToString()))
                    {
                        if (dt.Rows[0]["confirmH2H"].ToString() == "1")
                            model.renewalModel.checkYESH2H = true;
                        else if (dt.Rows[0]["confirmH2H"].ToString() == "0")
                            model.renewalModel.checkNOH2H = true;
                    }
                    if (!String.IsNullOrEmpty(dt.Rows[0]["confirmFUT"].ToString()))
                    {
                        if (dt.Rows[0]["confirmFUT"].ToString() == "1")
                            model.renewalModel.checkYESFUT = true;
                        else if (dt.Rows[0]["confirmFUT"].ToString() == "0")
                            model.renewalModel.checkNOFUT = true;
                    }
                    if (!String.IsNullOrEmpty(dt.Rows[0]["confirmPRO"].ToString()))
                    {
                        if (dt.Rows[0]["confirmPRO"].ToString() == "1")
                            model.renewalModel.checkYESPRO = true;
                        else if (dt.Rows[0]["confirmPRO"].ToString() == "0")
                            model.renewalModel.checkNOPRO = true;
                    }
                    if (!String.IsNullOrEmpty(dt.Rows[0]["confirmWC"].ToString()))
                    {
                        if (dt.Rows[0]["confirmWC"].ToString() == "1")
                            model.renewalModel.checkYESWDC = true;
                        else if (dt.Rows[0]["confirmWC"].ToString() == "0")
                            model.renewalModel.checkNOWDC = true;
                    }

                    if (!String.IsNullOrEmpty(dt.Rows[0]["nmTimeFUT"].ToString()))
                        model.renewalModel.teamNameFUT = dt.Rows[0]["nmTimeFUT"].ToString();

                    if (!String.IsNullOrEmpty(dt.Rows[0]["nmTimePRO"].ToString()))
                        model.renewalModel.teamNamePRO = dt.Rows[0]["nmTimePRO"].ToString();

                    if (!String.IsNullOrEmpty(dt.Rows[0]["mobile"].ToString()))
                    {
                        model.renewalModel.ddd = dt.Rows[0]["ddd"].ToString();
                        model.renewalModel.mobile = dt.Rows[0]["mobile"].ToString();
                    }

                    model.returnMessage = "GenerateRenewalSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "saveRenewalNewSeasonHome")
                {
                    int confirmH2H = -1;
                    int confirmFUT = -1;
                    int confirmPRO = -1;
                    int confirmWC = -1;

                    if (model.renewalModel.checkYESH2H) { confirmH2H = 1; }
                    else if (model.renewalModel.checkYESH2H) { confirmH2H = 0; }

                    if (model.renewalModel.checkYESFUT) { confirmFUT = 1; }
                    else if (model.renewalModel.checkNOFUT) { confirmFUT = 0; }

                    if (model.renewalModel.checkYESPRO) { confirmPRO = 1; }
                    else if (model.renewalModel.checkNOPRO) { confirmPRO = 0; }

                    if (model.renewalModel.checkYESWDC) { confirmWC = 1; }
                    else if (model.renewalModel.checkNOWDC) { confirmWC = 0; }


                    paramName = new string[] { "pIdTemporada", "pIdUsu", "pInConfirmH2H", "pInConfirmFUT", "pInConfirmPRO", "pInConfirmWC", "pNmTeamFUT", "pNmTeamPRO", "pDDD", "pMobile" };
                    paramValue = new string[] { model.renewalModel.seasonID.ToString(), model.renewalModel.userID.ToString(), confirmH2H.ToString(),
                                                confirmFUT.ToString(), confirmPRO.ToString(), confirmWC.ToString(), model.renewalModel.teamNameFUT,
                                                model.renewalModel.teamNamePRO, model.renewalModel.ddd, model.renewalModel.mobile };
                    db.executePROCNonResult("spControlConfirmacaoTemporada", paramName, paramValue);

                    model.returnMessage = "GenerateRenewalSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                model = new GenerateRenewalViewModel();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
            }
            finally
            {
                db.closeConnection();
                dt = null;
            }

        }

        private void getSummaryDetails(ref GenerateRenewalViewModel model, connectionMySQL db, Boolean bOpenConection = false)
        {
            DataTable dt = null;
            string returnMessage = String.Empty;
            connectionMySQL dbNew = new DBConnection.connectionMySQL();

            if (bOpenConection==true) { dbNew.openConnection(GlobalVariables.DATABASE_NAME_ONLINE); } else { dbNew = db; }

            try
            {

                paramName = new string[] { };
                paramValue = new string[] { };
                dt = dbNew.executePROC("spGetSummaryGenerateRenwal", paramName, paramValue);

                model.seasonH2HID = Convert.ToInt16(dt.Rows[0]["seasonH2HID"].ToString());
                model.seasonH2HName = dt.Rows[0]["seasonH2HName"].ToString();

                model.seasonFUTID = Convert.ToInt16(dt.Rows[0]["seasonFUTID"].ToString());
                model.seasonFUTName = dt.Rows[0]["seasonFUTName"].ToString();

                model.seasonPROID = Convert.ToInt16(dt.Rows[0]["seasonPROID"].ToString());
                model.seasonPROName = dt.Rows[0]["seasonPROName"].ToString();

                model.totalUsersBcoOnLine = Convert.ToInt16(dt.Rows[0]["totalUsersBcoOnLine"].ToString());
                model.totalUsersBcoStaging = Convert.ToInt16(dt.Rows[0]["totalUsersBcoStaging"].ToString());

                model.lastSeasonH2HID = Convert.ToInt16(dt.Rows[0]["lastSeasonH2HID"].ToString());
                model.lastSeasonH2HName = dt.Rows[0]["lastSeasonH2HName"].ToString();

                model.lastSeasonFUTID = Convert.ToInt16(dt.Rows[0]["lastSeasonFUTID"].ToString());
                model.lastSeasonFUTName = dt.Rows[0]["lastSeasonFUTName"].ToString();

                model.lastSeasonPROID = Convert.ToInt16(dt.Rows[0]["lastSeasonPROID"].ToString());
                model.lastSeasonPROName = dt.Rows[0]["lastSeasonPROName"].ToString();

                model.totalUserRenewalForNextSeason = Convert.ToInt16(dt.Rows[0]["totalUsersRenewal"].ToString());
                model.totalEmailSpoolerForRenewal = Convert.ToInt16(dt.Rows[0]["totalEmailsRenewal"].ToString());

                if (dt.Rows[0]["totalSpoolerEmails"].ToString() == "1")
                    model.emailsSent = true;
                else
                    model.emailsSent = false;

                if (dt.Rows[0]["totalRenewals"].ToString() != "0")
                    model.renewalNewSeasonGenerated = true;
                else
                    model.renewalNewSeasonGenerated = false;

                if (dt.Rows[0]["isPreparedBefore"].ToString() == "1")
                    model.databaseStagingPrepared = true;
                else
                    model.databaseStagingPrepared = false;

                model.returnMessage = "GenerateRenewalSuccessfully";

            }
            catch (Exception ex)
            {
                model = new GenerateRenewalViewModel();
                model.returnMessage = "error_" + ex.Message;
            }
            finally
            {
                dt = null;
                if (bOpenConection == true) { dbNew.closeConnection(); }
                dbNew = null;
            }

        }


    }
}