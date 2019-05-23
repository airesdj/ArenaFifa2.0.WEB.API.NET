using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.TeamTypeModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class TeamTypeController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            TeamTypeDetailsModel modelDetails = new TeamTypeDetailsModel();
            TeamTypeListViewModel mainModel = new TeamTypeListViewModel();
            List<TeamTypeDetailsModel> listOfModel = new List<TeamTypeDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] {  };
                paramValue = new string[] {  };
                dt = db.executePROC("spGetAllTiposTime", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new TeamTypeDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_TIPO_TIME"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_TIPO_TIME"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfType = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new TeamTypeListViewModel();
                mainModel.listOfType = new List<TeamTypeDetailsModel>();
                mainModel.returnMessage = "errorGetAllTeamType_" + ex.Message;
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