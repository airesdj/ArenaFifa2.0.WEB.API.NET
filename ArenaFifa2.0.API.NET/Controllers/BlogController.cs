using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.BlogModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class BlogController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult blog(BlogDetailsModel model)
        {

            db.openConnection("Connection.Database.Blog");
            DataTable dt = null;
            var objFunctions = new Commons.functions();

            try
            {

                if (model.actionUser.ToLower() == "dellcrud")
                {
                    paramName = new string[] { "pIdUser", "pIdBlog" };
                    paramValue = new string[] { Convert.ToString(model.userID), Convert.ToString(model.id) };
                    dt = db.executePROC("spDeleteBlog", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "save" && model.id > 0)
                {
                    paramName = new string[] { "pIdUser", "pIdBlog", "pTitle", "pText" };

                    paramValue = new string[] { Convert.ToString(model.userID), Convert.ToString(model.id),
                                                model.title, model.text + "@[LONGTEXT-TYPE]" };

                    dt = db.executePROC("spUpdateBlog", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else if (model.actionUser.ToLower() == "save" && model.id == 0)
                {
                    paramName = new string[] { "pIdUser", "pTitle", "pDate", "pHour", "pText" };

                    paramValue = new string[] { Convert.ToString(model.userID), model.title,
                                                model.registerDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]", model.registerTime, model.text + "@[LONGTEXT-TYPE]" };


                    dt = db.executePROC("spAddBlog", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else if (model.actionUser.ToLower() == "sendWarningEmail")
                {

                    //coding
                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                }
                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }
            }
            catch (Exception ex)
            {
                model.returnMessage = "errorPostBlog_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                objFunctions = null;
            }


        }


        [HttpGet]
        public IHttpActionResult GetDetails(string id)
        {

            BlogDetailsModel modelDetails = new BlogDetailsModel();
            BlogListViewModel mainModel = new BlogListViewModel();
            List<BlogDetailsModel> listOfModel = new List<BlogDetailsModel>();
            DataTable dt = null;
            db.openConnection("Connection.Database.Blog");


            try
            {
                string[] pkID = id.Split(Convert.ToChar("|"));

                paramName = new string[] { "pIdUser", "pIdBlog" };
                paramValue = new string[] { pkID[0], pkID[1] };
                dt = db.executePROC("spGetBlog", paramName, paramValue);

                if (dt.Rows.Count > 0)
                {
                    modelDetails.id = Convert.ToInt32(dt.Rows[0]["ID_BLOG"].ToString());
                    modelDetails.userID = Convert.ToInt32(dt.Rows[0]["ID_MODERADOR"].ToString());
                    modelDetails.userName = dt.Rows[0]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[0]["PSN_ID"].ToString();
                    modelDetails.title = dt.Rows[0]["DS_TITULO"].ToString();
                    modelDetails.registerDate = Convert.ToDateTime(dt.Rows[0]["DT_BLOG"].ToString());
                    modelDetails.registerDateFormatted = dt.Rows[0]["DT_BLOG_FORMATADA"].ToString();
                    modelDetails.registerTime = dt.Rows[0]["HR_BLOG"].ToString();
                    modelDetails.text = dt.Rows[0]["DS_TEXTO_BLOG"].ToString();
                }

                modelDetails.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

            }
            catch (Exception ex)
            {
                mainModel = new BlogListViewModel();
                mainModel.returnMessage = "errorGetBlogDetails_" + ex.Message;
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
        public IHttpActionResult GetAll()
        {

            BlogDetailsModel modelDetails = new BlogDetailsModel();
            BlogListViewModel mainModel = new BlogListViewModel();
            List<BlogDetailsModel> listOfModel = new List<BlogDetailsModel>();
            DataTable dt = null;
            db.openConnection("Connection.Database.Blog");


            try
            {

                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllBlogNoFilterCRUD", paramName, paramValue);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new BlogDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_BLOG"].ToString());
                    modelDetails.userID = Convert.ToInt32(dt.Rows[i]["ID_MODERADOR"].ToString());
                    modelDetails.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.title = dt.Rows[i]["DS_TITULO"].ToString();
                    modelDetails.registerDate = Convert.ToDateTime(dt.Rows[i]["DT_BLOG"].ToString());
                    modelDetails.registerDateFormatted = dt.Rows[i]["DT_BLOG_FORMATADA"].ToString();
                    modelDetails.registerTime = dt.Rows[i]["HR_BLOG"].ToString();
                    modelDetails.text = dt.Rows[i]["DS_TEXTO_BLOG"].ToString();

                    modelDetails.registerDateTimeFormatted = Convert.ToInt64(modelDetails.registerDate.ToString("yyyyMMdd") + modelDetails.registerTime.Replace(":", ""));

                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfBlog = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            catch (Exception ex)
            {
                mainModel = new BlogListViewModel();
                mainModel.listOfBlog = new List<BlogDetailsModel>();
                mainModel.returnMessage = "errorGetAll_" + ex.Message;
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