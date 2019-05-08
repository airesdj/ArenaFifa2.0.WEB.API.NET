using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.SeasonModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class SeasonController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult season(SeasonModesViewModel model)
        {

            db.openConnection();
            DataTable dt = null;
            SeasonDetails seasonDetails = new SeasonDetails();

            try
            {

                if (model.actionUser == "add")
                {
                    model.returnMessage = "subscribeBenchSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "current")
                {

                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetIDCurrentTemporada", paramName, paramValue);

                    SetDetailsSeason(dt, seasonDetails);

                    seasonDetails.returnMessage = "subscribeBenchSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, seasonDetails);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);

                }
            }
            catch (Exception ex)
            {
                model = new SeasonModesViewModel();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                seasonDetails = null;

            }


        }

        [HttpGet]
        public IHttpActionResult GetSeasonDetails(int id)
        {

            SeasonDetails seasonDetails = new SeasonDetails();
            SeasonListModesViewModel seasonModel = new SeasonListModesViewModel();
            List<SeasonDetails> listOfSeasons = new List<SeasonDetails>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                if (String.IsNullOrEmpty(Convert.ToString(id)) || id == 0)
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetCurrentTemporada", paramName, paramValue);

                    SetDetailsSeason(dt, seasonDetails);
                    return Ok(seasonDetails);

                }
                else
                {
                    paramName = new string[] { "idTemporada" };
                    paramValue = new string[] { Convert.ToString(id) };
                    dt = db.executePROC("spGetTemporada", paramName, paramValue);

                    SetDetailsSeason(dt, seasonDetails);
                    return Ok(seasonDetails);

                }

            }
            catch (Exception ex)
            {
                seasonDetails = new SeasonDetails();
                seasonDetails.returnMessage = "errorGetSeasonDetails_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, seasonDetails);
            }
            finally
            {
                db.closeConnection();
                seasonDetails = null;
                seasonModel = null;
                listOfSeasons = null;
                dt = null;
            }

        }

        [HttpGet]
        public IHttpActionResult GetAllSeasons()
        {

            SeasonListModesViewModel seasonModel = new SeasonListModesViewModel();
            SeasonDetails seasonDetails = new SeasonDetails();
            List<SeasonDetails> listOfSeasons = new List<SeasonDetails>();
            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] {  };
                paramValue = new string[] {  };
                dt = db.executePROC("spGetAllTemporadasNoFilterCRUD", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    seasonDetails = new SeasonDetails();
                    seasonDetails.id = Convert.ToInt16(dt.Rows[i]["ID_TEMPORADA"].ToString());
                    seasonDetails.name = dt.Rows[i]["NM_TEMPORADA"].ToString();
                    seasonDetails.active = Convert.ToByte(dt.Rows[i]["IN_TEMPORADA_ATIVA"].ToString());
                    seasonDetails.dtStartSeason = Convert.ToDateTime(dt.Rows[i]["DT_INICIO"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[i]["DT_FIM"].ToString())) { seasonDetails.dtEndSeason = Convert.ToDateTime(dt.Rows[i]["DT_FIM"].ToString()); }

                    seasonDetails.typeMode = string.Empty;
                    listOfSeasons.Add(seasonDetails);
                }

                seasonModel.listOfSeasons = listOfSeasons;
                seasonModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, seasonModel);

            }
            catch (Exception ex)
            {
                seasonModel = new SeasonListModesViewModel();
                seasonModel.listOfSeasons = new List<SeasonDetails>();
                seasonModel.returnMessage = "errorGetAllSeasons_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, seasonModel);
            }
            finally
            {
                db.closeConnection();
                seasonDetails = null;
                seasonModel = null;
                listOfSeasons = null;
                dt = null;
            }

        }

        private void SetDetailsSeason(DataTable dt, SeasonDetails seasonDetails)
        {
            var row = dt.Rows[0];

            seasonDetails.id = Convert.ToInt16(row["ID_TEMPORADA"].ToString());
            seasonDetails.name = row["NM_TEMPORADA"].ToString();
            seasonDetails.active = Convert.ToByte(row["IN_TEMPORADA_ATIVA"].ToString());
            seasonDetails.dtStartSeason = Convert.ToDateTime(row["DT_INICIO"].ToString());
            if (!String.IsNullOrEmpty(row["DT_FIM"].ToString())) { seasonDetails.dtEndSeason = Convert.ToDateTime(row["DT_FIM"].ToString()); }

            seasonDetails.typeMode = string.Empty;

            row = null;
        }


    }
}