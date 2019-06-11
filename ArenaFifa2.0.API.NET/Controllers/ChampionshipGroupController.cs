using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipGroupModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipGroupController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAllByChampionship(int id)
        {

            ChampionshipGroupDetailsModel modelDetails = new ChampionshipGroupDetailsModel();
            ChampionshipGroupListViewModel mainModel = new ChampionshipGroupListViewModel();
            List<ChampionshipGroupDetailsModel> listOfModel = new List<ChampionshipGroupDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllGrupoOfCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipGroupDetailsModel();
                    modelDetails.id = Convert.ToInt16(dt.Rows[i]["ID_GRUPO"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_GRUPO"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfGroup = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipGroupListViewModel();
                mainModel.listOfGroup = new List<ChampionshipGroupDetailsModel>();
                mainModel.returnMessage = "errorGetAllGroupForChampionship_" + ex.Message;
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