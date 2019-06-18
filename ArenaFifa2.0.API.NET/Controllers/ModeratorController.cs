using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ModeratorModel;
using static ArenaFifa20.API.NET.Models.SpoolerModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ModeratorController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult ranking(SummaryViewModel model)
        {


            DataTable dt = null;
            try
            {

                if (model.actionUser == "summary")
                {

                    db.openConnection();
                    try
                    {
                        paramName = new string[] { };
                        paramValue = new string[] { };
                        dt = db.executePROC("spGetSummaryModeratorMenu", paramName, paramValue);

                        model.totalActiveCoaches = Convert.ToInt16(dt.Rows[0]["totalActiveCoaches"].ToString());
                        model.totalSeasonCoaches = Convert.ToInt16(dt.Rows[0]["totalSeasonCoaches"].ToString());
                        model.currentStageNameH2H = dt.Rows[0]["currentStageNameH2H"].ToString();

                        model.seasonNameH2H = dt.Rows[0]["seasonNameH2H"].ToString();
                        model.seasonNameFUT = dt.Rows[0]["seasonNameFUT"].ToString();
                        model.seasonNamePRO = dt.Rows[0]["seasonNamePRO"].ToString();

                        model.returnMessage = "ModeratorSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                    }
                    catch (Exception ex)
                    {
                        model = new SummaryViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                    }
                    finally
                    {
                    }

                }
                else if (model.actionUser == "spooler")
                {
                    db.openConnection("Connection.Database.Spooler");
                    SpoolerViewModel SpoolerViewModel = new SpoolerViewModel();
                    List<SpoolerTypeModel> listProcessing = new List<SpoolerTypeModel>();
                    List<SpoolerTypeModel> listWaiting = new List<SpoolerTypeModel>();
                    List<SpoolerTypeModel> listFinished = new List<SpoolerTypeModel>();
                    List<SpoolerTypeModel> listAdmin = new List<SpoolerTypeModel>();

                    try
                    {

                        int currentTime = DateTime.Now.Hour;
                        int currentDay = DateTime.Now.Day;
                        int currentMonth = DateTime.Now.Month;
                        int currentYear = DateTime.Now.Year;
                        string nextProcessTime = String.Empty;

                        if (currentTime >= 22 && currentTime <= 23) {
                            currentDay = DateTime.Now.AddDays(1).Day;
                            currentMonth = DateTime.Now.AddDays(1).Month;
                            currentYear = DateTime.Now.AddDays(1).Year;
                            nextProcessTime = "04:00";
                        }
                        else if (currentTime >= 0 && currentTime < 4) { nextProcessTime = "04:00"; }
                        else if (currentTime >= 4 && currentTime < 6) { nextProcessTime = "06:00"; }
                        else if (currentTime >= 6 && currentTime < 8) { nextProcessTime = "08:00"; }
                        else if (currentTime >= 8 && currentTime < 10) { nextProcessTime = "10:00"; }
                        else if (currentTime >= 10 && currentTime < 12) { nextProcessTime = "12:00"; }
                        else if (currentTime >= 12 && currentTime < 14) { nextProcessTime = "14:00"; }
                        else if (currentTime >= 14 && currentTime < 16) { nextProcessTime = "16:00"; }
                        else if (currentTime >= 16 && currentTime < 18) { nextProcessTime = "18:00"; }
                        else if (currentTime >= 18 && currentTime < 20) { nextProcessTime = "20:00"; }
                        else if (currentTime >= 20 && currentTime < 22) { nextProcessTime = "22:00"; }


                        SpoolerViewModel.nextTimeProcessSpooler = currentDay.ToString("00") + "/" +
                                                                  currentMonth.ToString("00") + "/" +
                                                                  currentYear.ToString("0000") + " " +
                                                                  nextProcessTime + "h";


                        paramName = new string[] { };
                        paramValue = new string[] { };
                        dt = db.executePROC("spGetAllSpoolerInProgress", paramName, paramValue);
                        listProcessing = subSetUpListReturnSpooler(dt);


                        dt = db.executePROC("spGetAllSpoolerWaitingProcess", paramName, paramValue);
                        listWaiting = subSetUpListReturnSpooler(dt);

                        dt = db.executePROC("spGetAllSpoolerFinished", paramName, paramValue);
                        listFinished = subSetUpListReturnSpooler(dt);

                        dt = db.executePROC("spGetAllSpoolerAdmin", paramName, paramValue);
                        listAdmin = subSetUpListReturnSpooler(dt);

                        SpoolerViewModel.listSpoolerInProgress = listProcessing;
                        SpoolerViewModel.listSpoolerWaiting = listWaiting;
                        SpoolerViewModel.listSpoolerFinished = listFinished;
                        SpoolerViewModel.listSpoolerAdmin = listAdmin;
                        SpoolerViewModel.returnMessage = "ModeratorSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, SpoolerViewModel);

                    }
                    catch (Exception ex)
                    {
                        SpoolerViewModel = new SpoolerViewModel();
                        SpoolerViewModel.listSpoolerInProgress = new List<SpoolerTypeModel>();
                        SpoolerViewModel.listSpoolerWaiting = new List<SpoolerTypeModel>();
                        SpoolerViewModel.listSpoolerFinished = new List<SpoolerTypeModel>();
                        SpoolerViewModel.listSpoolerAdmin = new List<SpoolerTypeModel>();
                        SpoolerViewModel.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, SpoolerViewModel);

                    }
                    finally
                    {
                        SpoolerViewModel = null;
                        listProcessing = null;
                        listWaiting = null;
                        listFinished = null;
                        listAdmin = null;
                    }

                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                model = new SummaryViewModel();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
            }
            finally
            {
                db.closeConnection();
                dt = null;
            }

        }

        private List<SpoolerTypeModel> subSetUpListReturnSpooler(DataTable dt) 
        {
            List<SpoolerTypeModel> oList = new List<SpoolerTypeModel>();
            SpoolerTypeModel oSpooler = new SpoolerTypeModel();
            try
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    oSpooler = new SpoolerTypeModel();
                    if (String.IsNullOrEmpty(dt.Rows[i]["psn_id_responsavel"].ToString()))
                        oSpooler.description = dt.Rows[i]["ds_processo"].ToString();
                    else
                        oSpooler.description = dt.Rows[i]["ds_processo"].ToString() + " (" + dt.Rows[i]["psn_id_responsavel"].ToString() + ")";
                    oSpooler.totalEmails = Convert.ToInt16(dt.Rows[i]["qtd_total_emails"].ToString());
                    oSpooler.totalEmailsSent = Convert.ToInt16(dt.Rows[i]["qtd_emails_enviados"].ToString());
                    oSpooler.totalEmailsMissingSend = Convert.ToInt16(dt.Rows[i]["qtd_emails_restantes"].ToString());
                    oSpooler.dateFormattedLastProcessing = dt.Rows[i]["dt_ultima_execucao_formatada"].ToString() + " " + dt.Rows[i]["hr_ultima_execucao"].ToString() + "h";
                    oSpooler.timeProcess = dt.Rows[i]["ds_horario_execucao"].ToString();
                    oSpooler.frequency = dt.Rows[i]["ds_periodicidade"].ToString();

                    if (String.IsNullOrEmpty(dt.Rows[i]["dt_ultima_execucao"].ToString()))
                        oSpooler.processedToday = false;
                    else if (Convert.ToDateTime(dt.Rows[i]["dt_ultima_execucao"].ToString()).Date == DateTime.Now.Date)
                        oSpooler.processedToday = true;
                    else
                        oSpooler.processedToday = false;

                    oList.Add(oSpooler);
                }
                return oList;
            }
            catch
            {
                return new List<SpoolerTypeModel>();
            }
            finally
            {
                oList = null;
                oSpooler = null;
            }
        }


    }
}