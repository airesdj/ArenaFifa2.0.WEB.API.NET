using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.SpoolerModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class SpoolerController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postAction(SpoolerViewModel model)
        {

            db.openConnection();
            DataTable dt = null;
            var objFunctions = new Commons.functions();

            try
            {

                if (model.actionUser.ToLower() == "add_spooler_draw_warning" || model.actionUser.ToLower() == "add_spooler_draw_done")
                {
                    paramName = new string[] { "pIdCamp", "pDescription", "pTypeSpooler", "pIdUsuResponsible" };
                    paramValue = new string[] { Convert.ToString(model.championshipID), model.descriptionProcess, model.typeProcess, model.userIDResponsible.ToString() };
                    dt = db.executePROC("spAddSpoolerDraw", paramName, paramValue);

                    if (dt.Rows.Count > 0) { model.totalSentEmails = Convert.ToInt32(dt.Rows[0]["TOTAL_EMAILS_SENT"].ToString()); }

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
                model.returnMessage = "errorPostSpooler_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                objFunctions = null;
            }


        }


    }
}