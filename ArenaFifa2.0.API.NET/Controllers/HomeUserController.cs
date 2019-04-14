using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using ArenaFifa20.API.NET.Models;
using DBConnection;

namespace ArenaFifa20.API.NET.Controllers
{
    public class HomeUserController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult SigninUser(UserLoginModel user)
        {
            if (user.actionUser=="Signin")
            {
                db.openConnection();
                var objFunctions = new Commons.functions();
                Boolean validPasswordLogin = false;
                UserModel userDetails = new UserModel();
                DataTable dt = null;
                string passwordBase64 = string.Empty;
                

                try
                {
                    paramName = new string[] { "dsLogin" };
                    paramValue = new string[] { user.psnID };
                    dt = db.executePROC("spGetUsuarioByLogin", paramName, paramValue);

                    if (dt.Rows.Count>=0)
                    {

                        if (user.password != string.Empty)
                        {
                            byte[] byt = System.Text.Encoding.UTF8.GetBytes(user.password);
                            passwordBase64 = Convert.ToBase64String(byt);
                        }

                        var row = dt.Rows[0];

                        userDetails.id = Convert.ToInt16(row["ID_USUARIO"].ToString());
                        userDetails.name = row["NM_USUARIO"].ToString();
                        userDetails.psnID = row["PSN_ID"].ToString();
                        userDetails.password = row["DS_SENHA"].ToString();
                        userDetails.password20 = row["DS_SENHA20"].ToString();
                        userDetails.userActive = Convert.ToBoolean(row["IN_USUARIO_ATIVO"].ToString());
                        userDetails.email = row["DS_EMAIL"].ToString();
                        userDetails.lastAccess = Convert.ToDateTime(row["DT_ULTIMO_ACESSO"].ToString());
                        userDetails.birthday = Convert.ToDateTime(row["DT_NASCIMENTO"].ToString());
                        userDetails.state = row["DS_ESTADO"].ToString();
                        userDetails.howfindus = row["DS_COMO_FICOU_SABENDO"].ToString();
                        userDetails.whatkindofmedia = row["DS_QUAL"].ToString();
                        userDetails.receiveWarningEachRound = Convert.ToByte(row["IN_RECEBER_EMAIL_ALERTA"].ToString());
                        userDetails.receiveTeamTable = Convert.ToByte(row["IN_RECEBER_EMAIL_SITUACAO_CAMPEONATO"].ToString());
                        userDetails.wishParticipate = Convert.ToByte(row["IN_DESEJA_PARTICIPAR"].ToString());
                        userDetails.register = Convert.ToDateTime(row["DT_CADASTRO"].ToString());
                        userDetails.linkLiveMatch = row["DS_URL_LINK_AOVIVO"].ToString();
                        userDetails.lastUpdate = Convert.ToDateTime(row["DT_ULTIMA_ALTERACAO"].ToString());
                        userDetails.psnIDLastUpdate = row["DS_LOGIN_ALTERACAO"].ToString();
                        userDetails.passwordManager = row["DS_SENHA_CONFIRMACAO"].ToString();
                        userDetails.passwordManager20 = row["DS_SENHA_CONFIRMACAO20"].ToString();
                        userDetails.workEmail = row["DS_EMAIL_CORPORATIVO"].ToString();
                        userDetails.codeArea = row["NO_DDD"].ToString();
                        userDetails.mobileNumber = row["NO_CELULAR"].ToString();

                        if (row["DS_SENHA"].ToString() == row["DS_SENHA20"].ToString())
                        {

                            validPasswordLogin = objFunctions.validateOldEncryptionPassword(row["DS_SENHA"].ToString(), user.password, Convert.ToInt16(row["ID_USUARIO"].ToString()));

                            if (validPasswordLogin)
                            {

                                paramName = new string[] { "pIdUsuario", "pPassWDBase64" };
                                paramValue = new string[] { Convert.ToString(userDetails.id), passwordBase64 };
                                db.executePROCNonResult("spUpdadePassWDUsuario", paramName, paramValue);

                                paramName = new string[] { "pIdUsuario" };
                                paramValue = new string[] { Convert.ToString(userDetails.id) };
                                db.executePROCNonResult("spUpdateUltimoAcesso", paramName, paramValue);

                                userDetails.lastAccess = DateTime.Now;

                            }

                        }
                        else
                        {
                            paramName = new string[] { "pIdUsuario", "pPassWDBase64" };
                            paramValue = new string[] { Convert.ToString(userDetails.id), passwordBase64 };
                            dt = db.executePROC("spValidatePasswdOfUsuario", paramName, paramValue);

                            var rowVal = dt.Rows[0];

                            if (rowVal["COD_VALIDATION"].ToString()=="0")
                            {
                                validPasswordLogin = true;
                            }
                            else if (rowVal["COD_VALIDATION"].ToString() == "1")
                            {
                                validPasswordLogin = false;
                            }
                            else if (rowVal["COD_VALIDATION"].ToString() == "2")
                            {
                                validPasswordLogin = false;
                            }
                        }

                        row = null;

                    }

                    if (validPasswordLogin==true)
                    {
                        userDetails.returnMessage = "loginSuccessful";
                        return CreatedAtRoute("DefaultApi", new { id = userDetails.id }, userDetails);
                    }
                    else
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "loginFailed";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }

                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "error_"+ex.Message;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, user);

                }
                finally
                {
                    db.closeConnection();
                    objFunctions = null;
                    userDetails = null;
                    dt = null;
                }

            }
            else if (user.actionUser == "Register")
            {

                return RegisterUser(user);

            }
            else if (user.actionUser == "Update")
            {

                return UpdateUserDetails(user);

            }
            else
            {

                return StatusCode(HttpStatusCode.NotAcceptable);

            }
        }

        private IHttpActionResult RegisterUser(UserLoginModel user)
        {
            return CreatedAtRoute("DefaultApi", new { id = user.id }, user);
            //write insert logic  

        }

        private IHttpActionResult UpdateUserDetails(UserLoginModel user)
        {
            return CreatedAtRoute("DefaultApi", new { id = user.id }, user);
            //write insert logic  

        }

        public IHttpActionResult PutUserDetails(int id, UserLoginModel user)
        {
            user.id = id;
            return CreatedAtRoute("DefaultApi", new { id = id }, user);
            //write insert logic  

        }

        public IHttpActionResult GetUserDetails(int id)
        {
            var model = new UserLoginModel();
            model.id = id;
            model.psnID = "airesdias";
            model.password = "marys7377";
            return Ok(model);
            //write insert logic  

        }

    }
}
