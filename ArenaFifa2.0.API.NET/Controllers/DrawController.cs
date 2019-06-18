using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.ModeratorModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class DrawController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postUser(DrawViewModel model)
        {

            db.openConnection();
            DataTable dt = null;
            try
            {
                if(model.actionUser.ToLower() == "draw_automatic_user_team")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spAutomaticDrawOfTimes", paramName, paramValue);

                    if (dt.Rows[0]["msgRetornoSorteioAutomaticoTimes"].ToString()==String.Empty)
                        model.returnMessage = "ModeratorSuccessfully";
                    else
                        model.returnMessage = dt.Rows[0]["msgRetornoSorteioAutomaticoTimes"].ToString();

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

                }
                else if (model.actionUser.ToLower() == "cancel_draw_user_team")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spCancelDrawOfTimes", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "assume_draw_user_team")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spAssumeDrawOfTimesByDrawLeague", paramName, paramValue);

                    if (dt.Rows[0]["msgRetornoSorteioAssumirTimesLiga"].ToString() == String.Empty)
                        model.returnMessage = "ModeratorSuccessfully";
                    else
                        model.returnMessage = dt.Rows[0]["msgRetornoSorteioAssumirTimesLiga"].ToString();

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "draw_automatic_match_table")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spAutomaticDrawOfTables", paramName, paramValue);

                    if (dt.Rows[0]["msgRetornoSorteioAutomaticoTabelas"].ToString() == String.Empty)
                        model.returnMessage = "ModeratorSuccessfully";
                    else
                        model.returnMessage = dt.Rows[0]["msgRetornoSorteioAutomaticoTabelas"].ToString();

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "cancel_draw_match_table")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spCancelDrawOfJogos", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "draw_automatic_group_table")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spAutomaticDrawOfGroupForPots", paramName, paramValue);

                    if (dt.Rows[0]["msgRetornoSorteioAutomaticoGruposPorPotes"].ToString() == String.Empty)
                        model.returnMessage = "ModeratorSuccessfully";
                    else
                        model.returnMessage = dt.Rows[0]["msgRetornoSorteioAutomaticoGruposPorPotes"].ToString();

                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "cancel_draw_group_table")
                {
                    paramName = new string[] { "pIdCamp" };
                    paramValue = new string[] { Convert.ToString(model.championshipID) };
                    dt = db.executePROC("spCancelDrawOfGrupos", paramName, paramValue);

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
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;

            }
        }

    }
}
