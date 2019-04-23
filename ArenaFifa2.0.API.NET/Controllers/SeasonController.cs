using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.SeasonModel;
using DBConnection;
using System.Data;
using System.Net;

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
            DataTable dt = null;
            db.openConnection();


            try
            {
                if (String.IsNullOrEmpty(Convert.ToString(id)) || id == 0)
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetCurrentTemporada", paramName, paramValue);

                }
                else
                {
                    paramName = new string[] { "idTemporada" };
                    paramValue = new string[] { Convert.ToString(id) };
                    dt = db.executePROC("spGetTemporada", paramName, paramValue);

                }

                SetDetailsSeason(dt, seasonDetails);
                return Ok(seasonDetails);

            }
            catch (Exception ex)
            {
                seasonDetails = new SeasonDetails();
                seasonDetails.returnMessage = "errorGetUser_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, seasonDetails);
            }
            finally
            {
                db.closeConnection();
                seasonDetails = null;
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