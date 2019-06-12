using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipStageModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipStageController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;


        [HttpPost]
        public IHttpActionResult GenerateStage(ChampionshipStageListViewModel model)
        {

            db.openConnection();
            DataTable dt = null;

            try
            {
                if (model.actionUser.ToLower() == "generate_stage_playoff_from_playoff")
                {

                    paramName = new string[] { "pIdCamp", "pIdFase", "pIdPreviousFase", "pDtInicioFase" };

                    paramValue = new string[] { Convert.ToString(model.championshipID), Convert.ToString(model.stageID),
                                                Convert.ToString(model.previousStageID), model.startStageDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]" };

                    dt = db.executePROC("spGenerateFasePlayOffFromPlayOff", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "generate_stage_playoff_from_stage0")
                {

                    paramName = new string[] { "pIdCamp", "pIdFase", "pDtInicioFase" };

                    paramValue = new string[] { Convert.ToString(model.championshipID), Convert.ToString(model.stageID),
                                                model.startStageDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]" };

                    dt = db.executePROC("spGenerateFasePlayOffFromStage0", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "generate_stage_playoff_from_qualify1")
                {

                    paramName = new string[] { "pIdCamp", "pIdFase", "pDtInicioFase" };

                    paramValue = new string[] { Convert.ToString(model.championshipID), Convert.ToString(model.stageID),
                                                model.startStageDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]" };

                    dt = db.executePROC("spGenerateFasePlayOffFromStageQualify1", paramName, paramValue);

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
                model.returnMessage = "errorPostChampionshipMatchTable_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
            }


        }

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            ChampionshipStageDetailsModel modelDetails = new ChampionshipStageDetailsModel();
            ChampionshipStageListViewModel mainModel = new ChampionshipStageListViewModel();
            List<ChampionshipStageDetailsModel> listOfModel = new List<ChampionshipStageDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] {  };
                paramValue = new string[] {  };
                dt = db.executePROC("spGetAllFase", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipStageDetailsModel();
                    modelDetails.id = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_FASE"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfStage = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipStageListViewModel();
                mainModel.listOfStage = new List<ChampionshipStageDetailsModel>();
                mainModel.returnMessage = "errorGetAllStage_" + ex.Message;
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
        public IHttpActionResult GetAllForChampionship(int id)
        {

            ChampionshipStageDetailsModel modelDetails = new ChampionshipStageDetailsModel();
            ChampionshipStageListViewModel mainModel = new ChampionshipStageListViewModel();
            List<ChampionshipStageDetailsModel> listOfModel = new List<ChampionshipStageDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllFaseByCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipStageDetailsModel();
                    modelDetails.id = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_FASE"].ToString();
                    modelDetails.totalMatchesNoResult = Convert.ToInt16(dt.Rows[i]["TOTALMATCHESNORESULT"].ToString());
                    modelDetails.existMatches = Convert.ToInt16(dt.Rows[i]["EXISTMATCHES"].ToString());
                    modelDetails.status = dt.Rows[i]["STATUS"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfStage = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipStageListViewModel();
                mainModel.listOfStage = new List<ChampionshipStageDetailsModel>();
                mainModel.returnMessage = "errorGetAllStageForChampionship_" + ex.Message;
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