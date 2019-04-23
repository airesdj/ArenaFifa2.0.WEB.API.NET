using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.BenchModel;
using DBConnection;
using System.Data;

namespace ArenaFifa20.API.NET.Controllers
{
    public class SubscribeBenchController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult subscribe(SubscribeBench model)
        {
            db.openConnection();

            try
            {
                if (model.checkH2H)
                {
                    paramName = new string[] { "pIdUsu", "pNmTime", "pTpBanco" };
                    paramValue = new string[] { Convert.ToString(model.id), "", "H2H" };
                    db.executePROCNonResult("spAddBancoReserva", paramName, paramValue);
                }

                if (model.checkFUT)
                {
                    paramName = new string[] { "pIdUsu", "pNmTime", "pTpBanco" };
                    paramValue = new string[] { Convert.ToString(model.id), model.teamNameFUT, "FUT" };
                    db.executePROCNonResult("spAddBancoReserva", paramName, paramValue);
                }

                if (model.checkPRO)
                {
                    paramName = new string[] { "pIdUsu", "pNmTime", "pTpBanco" };
                    paramValue = new string[] { Convert.ToString(model.id), model.teamNamePRO, "PRO" };
                    db.executePROCNonResult("spAddBancoReserva", paramName, paramValue);

                    if (!String.IsNullOrWhiteSpace(model.mobile))
                    {
                        paramName = new string[] { "pIdUsuario", "pDDD", "pMobile" };
                        paramValue = new string[] { Convert.ToString(model.id), model.ddd, model.mobile };
                        db.executePROCNonResult("spUpdateMobile", paramName, paramValue);
                    }

                }

                model.returnMessage = "subscribeBenchSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
            }
            catch (Exception ex)
            {
                model = new SubscribeBench();
                model.returnMessage = "error_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();

            }

        }
    }
}