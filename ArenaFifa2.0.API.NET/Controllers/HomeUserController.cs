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
                DataTable dt2 = null;
                string passwordBase64 = string.Empty;
                

                try
                {
                    paramName = new string[] { "dsLogin" };
                    paramValue = new string[] { user.psnID };
                    dt = db.executePROC("spGetUsuarioByLogin", paramName, paramValue);

                    if (dt.Rows.Count>0)
                    {

                        if (user.password != string.Empty)
                        {
                            byte[] byt = System.Text.Encoding.UTF8.GetBytes(user.password);
                            passwordBase64 = Convert.ToBase64String(byt);
                        }

                        SetDetailsUser(dt, userDetails);

                        if (!string.IsNullOrEmpty(userDetails.currentTeam))
                        {
                            paramName = new string[] { "idTime" };
                            paramValue = new string[] { userDetails.currentTeam };
                            dt2 = db.executePROC("spGetTime", paramName, paramValue);
                            userDetails.currentTeam = dt2.Rows[0]["NM_TIME"].ToString();
                        }

                        paramName = new string[] { "idUsu" };
                        paramValue = new string[] { Convert.ToString(userDetails.id) };
                        dt2 = db.executePROC("spGetTitlesWonForUser", paramName, paramValue);
                        userDetails.totalTitlesWon = Convert.ToInt16(dt2.Rows[0]["TOTAL_TITLESWON"].ToString());
                        userDetails.totalVices= Convert.ToInt16(dt2.Rows[0]["TOTAL_VICES"].ToString());


                        if (userDetails.password.ToString() == userDetails.password20.ToString())
                        {

                            validPasswordLogin = objFunctions.validateOldEncryptionPassword(userDetails.password.ToString(), user.password, Convert.ToInt16(userDetails.id.ToString()));

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

                        if (validPasswordLogin == true)
                        {
                            userDetails.returnMessage = "loginSuccessfully";
                            return CreatedAtRoute("DefaultApi", new { id = userDetails.id }, userDetails);
                        }
                        else
                        {
                            user = new UserLoginModel();
                            user.returnMessage = "loginFailed";
                            return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                        }

                    }
                    else
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "UserNotFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }

                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "errorSigninUser_" + ex.Message;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, user);

                }
                finally
                {
                    db.closeConnection();
                    objFunctions = null;
                    userDetails = null;
                    dt = null;
                    dt2 = null;
                }

            }
            else if (user.actionUser == "Register")
            {

                db.openConnection();
                var objFunctions = new Commons.functions();
                DataTable dt = null;
                string passwordBase64 = string.Empty;

                try
                {

                    paramName = new string[] { "pdsPsn", "pNmUsuario", "pDsEmail" };
                    paramValue = new string[] { user.psnID, user.name, user.email };
                    dt = db.executePROC("spValidateRegistrationOfUsuarioNewUsuario", paramName, paramValue);

                    var rowValRegister = dt.Rows[0];

                    if (rowValRegister["COD_VALIDATION"].ToString() == "0")
                    {
                        byte[] byt = System.Text.Encoding.UTF8.GetBytes(user.password);
                        passwordBase64 = Convert.ToBase64String(byt);

                        paramName = new string[] { "pNmUsuario", "pDsSenhaBase64", "pDsEmail", "pPsnId", "pInAtivo", "pDsFicouSabendo",
                                               "pDsQual", "pNmTime", "pDtNasc", "pDsEstado", "pInReceberAlerta", "pInReceberSit",
                                               "pInDesejaPartic", "pInModerador", "pDsPsnCadastro", "pIdUsuarioOperacao",
                                               "pPsnUsuarioOperacao", "pDsPaginaOperacao"};

                        string receiveWarningEachRound = Convert.ToBoolean(user.inEmailWarning) ? "1" : "0";
                        string receiveTeamTable = Convert.ToBoolean(user.inEmailTeamTable) ? "1" : "0";
                        string wishParticipate = Convert.ToBoolean(user.inParticipate) ? "1" : "0";
                        string userActive = Convert.ToBoolean(user.userActive) ? "1" : "0";
                        string userModerator = Convert.ToBoolean(user.userModerator) ? "1" : "0";

                        paramValue = new string[] { user.name, passwordBase64, user.email, user.psnID, userActive,
                                                user.howfindus, user.whathowfindus, user.team, user.birthday.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                user.state, receiveWarningEachRound, receiveTeamTable, wishParticipate,
                                                userModerator, user.psnID, null, "NULL", "UserController.Register"};


                        dt = db.executePROC("spAddUsuario", paramName, paramValue);

                        user.id = Convert.ToInt16(dt.Rows[0]["ID_USUARIO"].ToString());
                        user.returnMessage = "registerSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = user.id }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "1")
                    {
                        user.returnMessage = "PsnFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "2")
                    {
                        user.returnMessage = "NameFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "3")
                    {
                        user.returnMessage = "EmailFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "ValidationNotFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }

                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "errorRegisterUser_" + ex.Message;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                }
                finally
                {
                    db.closeConnection();
                    objFunctions = null;
                    dt = null;
                }


            }
            else if (user.actionUser == "Update")
            {

                db.openConnection();
                var objFunctions = new Commons.functions();
                DataTable dt = null;
                string passwordBase64 = string.Empty;

                try
                {

                    paramName = new string[] { "pIdUsuario", "pdsPsn", "pNmUsuario", "pDsEmail" };
                    paramValue = new string[] { Convert.ToString(user.id), user.psnID, user.name, user.email };
                    dt = db.executePROC("spValidateRegistrationOfUsuarioOldUsuario", paramName, paramValue);

                    var rowValRegister = dt.Rows[0];

                    if (rowValRegister["COD_VALIDATION"].ToString() == "0")
                    {
                        paramName = new string[] { "pIdUsuario", "pNmUsuario", "pDsEmail", "pPsnId", "pInAtivo", "pDsFicouSabendo",
                                               "pDsQual", "pNmTime", "pDtNasc", "pDsEstado", "pInReceberAlerta", "pInReceberSit",
                                               "pInDesejaPartic", "pInModerador", "pDsPsnCadastro", "pIdUsuarioOperacao",
                                               "pPsnUsuarioOperacao", "pDsPaginaOperacao"};

                        string receiveWarningEachRound = Convert.ToBoolean(user.inEmailWarning) ? "1" : "0";
                        string receiveTeamTable = Convert.ToBoolean(user.inEmailTeamTable) ? "1" : "0";
                        string wishParticipate = Convert.ToBoolean(user.inParticipate) ? "1" : "0";
                        string userActive = Convert.ToBoolean(user.userActive) ? "1" : "0";
                        string userModerator = Convert.ToBoolean(user.userModerator) ? "1" : "0";

                        paramValue = new string[] { Convert.ToString(user.id), user.name, user.email, user.psnID, userActive,
                                                user.howfindus, user.whathowfindus, user.team, user.birthday.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                user.state, receiveWarningEachRound, receiveTeamTable, wishParticipate,
                                                userModerator, user.psnRegister, Convert.ToString(user.idUserOperation), user.psnOperation, "UserController.Update"};


                        dt = db.executePROC("spUpdadeUsuario", paramName, paramValue);

                        user.returnMessage = "updateSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = user.id }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "1")
                    {
                        user.returnMessage = "PsnFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "2")
                    {
                        user.returnMessage = "NameFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "3")
                    {
                        user.returnMessage = "EmailFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "ValidationNotFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }

                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "errorUpdateUser_" + ex.Message;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                }
                finally
                {
                    db.closeConnection();
                    objFunctions = null;
                    dt = null;
                }


            }
            else if (user.actionUser == "ChangePassword")
            {

                db.openConnection();
                var objFunctions = new Commons.functions();
                UserModel userDetails = new UserModel();
                string passwordBase64 = string.Empty;
                DataTable dt = null;

                try
                {
                    if (user.current_password == string.Empty || user.password == string.Empty || user.confirm_password == string.Empty)
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "emptyPasswordFields";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (user.password != user.confirm_password)
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "newPasswordFieldsDifferent";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else if (user.current_password == user.password && user.password == user.confirm_password)
                    {
                        user = new UserLoginModel();
                        user.returnMessage = "newPasswordEqual";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                    }
                    else
                    {
                        byte[] byt = System.Text.Encoding.UTF8.GetBytes(user.current_password);
                        passwordBase64 = Convert.ToBase64String(byt);

                        paramName = new string[] { "pIdUsuario", "pPassWDBase64" };
                        paramValue = new string[] { Convert.ToString(user.id), passwordBase64 };
                        dt = db.executePROC("spValidatePasswdOfUsuario", paramName, paramValue);

                        var rowVal = dt.Rows[0];

                        if (rowVal["COD_VALIDATION"].ToString() == "0")
                        {
                            byte[] byt2 = System.Text.Encoding.UTF8.GetBytes(user.password);
                            passwordBase64 = Convert.ToBase64String(byt2);

                            paramName = new string[] { "pIdUsuario", "pPassWDBase64" };
                            paramValue = new string[] { Convert.ToString(user.id), passwordBase64 };
                            db.executePROCNonResult("spUpdadePassWDUsuario", paramName, paramValue);

                            user.returnMessage = "changedSuccessfully";
                            return CreatedAtRoute("DefaultApi", new { id = user.id }, user);
                        }
                        else
                        {
                            user = new UserLoginModel();
                            user.returnMessage = "loginFailed";
                            return CreatedAtRoute("DefaultApi", new { id = 0 }, user);
                        }
                    }
                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "errorChangePassword_" + ex.Message;
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
            else if (user.actionUser == "RankingSupporters")
            {
                db.openConnection();
                DataTable dt = null;
                List<SupportesTeamModel> oList = new List<SupportesTeamModel>();
                SupportesTeamModel supporters = new SupportesTeamModel();
                RankingSupportersModel ranking = new RankingSupportersModel();

                try
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetListRankingSupporters", paramName, paramValue);

                    var rowVal = dt.Rows[0];

                    for (var i = 0; i< dt.Rows.Count; i++)
                    {
                        supporters = new SupportesTeamModel();
                        supporters.teamName = dt.Rows[i]["NM_TIME"].ToString();
                        supporters.total = Convert.ToInt16(dt.Rows[i]["TOTAL"].ToString());
                        oList.Add(supporters);
                    }

                    ranking.dtUpdateFormated = dt.Rows[0]["DT_CADASTRO_FORMATADA"].ToString();
                    ranking.totalUser = Convert.ToInt16(dt.Rows[0]["TOTAL_USUARIO"].ToString());
                    ranking.listSupportesTeam = oList;
                    ranking.returnMessage = "rankingSuccessfully";
                    return CreatedAtRoute("DefaultApi", new {  }, ranking);
                }
                catch (Exception ex)
                {
                    user = new UserLoginModel();
                    user.returnMessage = "errorRankingSupporters_" + ex.Message;
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, user);

                }
                finally
                {
                    db.closeConnection();
                    oList = null;
                    supporters = null;
                    ranking = null;
                    dt = null;
                }
            }
            else
            {
                return StatusCode(HttpStatusCode.NotAcceptable);

            }
        }

        private void SetDetailsUser(DataTable dt, UserModel userDetails)
        {
            var row = dt.Rows[0];

            userDetails.id = Convert.ToInt16(row["ID_USUARIO"].ToString());
            userDetails.name = row["NM_USUARIO"].ToString();
            userDetails.psnID = row["PSN_ID"].ToString();
            userDetails.password = row["DS_SENHA"].ToString();
            userDetails.password20 = row["DS_SENHA20"].ToString();
            userDetails.userActive = Convert.ToBoolean(row["IN_USUARIO_ATIVO"].ToString());
            userDetails.userModerator = Convert.ToBoolean(row["IN_USUARIO_MODERADOR"].ToString());
            userDetails.email = row["DS_EMAIL"].ToString();
            userDetails.lastAccess = Convert.ToDateTime(row["DT_ULTIMO_ACESSO"].ToString());
            userDetails.birthday = Convert.ToDateTime(row["DT_NASCIMENTO"].ToString());
            userDetails.state = row["DS_ESTADO"].ToString();
            userDetails.team = row["NM_TIME"].ToString();
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

            userDetails.currentTeam = row["ID_TIMEH2H"].ToString();

            if (string.IsNullOrEmpty(userDetails.currentTeam))
            {
                if (!string.IsNullOrEmpty(row["ID_TIMEFUT"].ToString())) { userDetails.currentTeam = row["ID_TIMEFUT"].ToString(); }
                else if (!string.IsNullOrEmpty(row["ID_TIMEPRO"].ToString())) { userDetails.currentTeam = row["ID_TIMEPRO"].ToString(); }
            }

            row = null;
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

        [HttpGet]
        public IHttpActionResult GetUserDetails(int id)
        {

            UserModel userDetails = new UserModel();
            DataTable dt = null;

            try
            {
                if (String.IsNullOrEmpty(Convert.ToString(id)) || id == 0)
                {
                    userDetails = new UserModel();
                    userDetails.returnMessage = "loginFailed";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, userDetails);

                }
                else
                {
                    db.openConnection();

                    paramName = new string[] { "pIdUsuario" };
                    paramValue = new string[] { Convert.ToString(id) };
                    dt = db.executePROC("spGetUsuarioById", paramName, paramValue);

                    SetDetailsUser(dt, userDetails);
                    return Ok(userDetails);
                }
            }
            catch (Exception ex)
            {
                userDetails = new UserModel();
                userDetails.returnMessage = "errorGetUser_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, userDetails);
            }
            finally
            {
                db.closeConnection();
                userDetails = null;
                dt = null;
            }

        }

    }
}
