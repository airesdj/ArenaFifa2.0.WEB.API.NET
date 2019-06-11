using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipTypeModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Linq;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipTypeController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            ChampionshipTypeDetailsModel modelDetails = new ChampionshipTypeDetailsModel();
            ChampionshipTypeListViewModel mainModel = new ChampionshipTypeListViewModel();
            List<ChampionshipTypeDetailsModel> listOfModel = new List<ChampionshipTypeDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] {  };
                paramValue = new string[] {  };
                dt = db.executePROC("spGetAllTipoCampeonato", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipTypeDetailsModel();
                    modelDetails.id = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                    modelDetails.name = dt.Rows[i]["DS_TIPO_CAMPEONATO"].ToString();
                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfType = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }

            catch (Exception ex)
            {
                mainModel = new ChampionshipTypeListViewModel();
                mainModel.listOfType = new List<ChampionshipTypeDetailsModel>();
                mainModel.returnMessage = "errorGetAllChampionshipType_" + ex.Message;
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