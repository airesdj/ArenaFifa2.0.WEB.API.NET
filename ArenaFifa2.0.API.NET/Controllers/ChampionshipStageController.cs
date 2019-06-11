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
        public IHttpActionResult GetAllForChampionship(int championshipID)
        {

            ChampionshipStageDetailsModel modelDetails = new ChampionshipStageDetailsModel();
            ChampionshipStageListViewModel mainModel = new ChampionshipStageListViewModel();
            List<ChampionshipStageDetailsModel> listOfModel = new List<ChampionshipStageDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(championshipID) };
                dt = db.executePROC("spGetAllFasePorCampeonato", paramName, paramValue);

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