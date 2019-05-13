using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;
using DBConnection;
using static ArenaFifa20.API.NET.Models.UserModel;

namespace ArenaFifa20.API.NET.Controllers
{
    public class UserController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult postUser(UserDetailsModel model)
        {

            db.openConnection();
            var objFunctions = new Commons.functions();
            DataTable dt = null;
            try
            {

                if(model.actionUser.ToLower() == "dellcrud")
                {
                    paramName = new string[] { "pIdUsuario", "pIdUsuarioOperacao", "pPsnUsuarioOperacao", "pDsPaginaOperacao" };
                    paramValue = new string[] { Convert.ToString(model.id), Convert.ToString(model.idOperator), model.psnIDOperator, model.pageName };
                    dt = db.executePROC("spDeleteUsuario", paramName, paramValue);

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "save" && model.id > 0)
                {
                    paramName = new string[] { "pIdUsuario", "pdsPsn", "pNmUsuario", "pDsEmail" };
                    paramValue = new string[] { Convert.ToString(model.id), model.psnID, model.name, model.email };
                    dt = db.executePROC("spValidateRegistrationOfUsuarioOldUsuario", paramName, paramValue);

                    var rowValRegister = dt.Rows[0];

                    if (rowValRegister["COD_VALIDATION"].ToString() == "0")
                    {
                        paramName = new string[] { "pIdUsuario", "pNmUsuario", "pDsEmail", "pPsnId", "pInAtivo", "pDsFicouSabendo",
                                               "pDsQual", "pNmTime", "pDtNasc", "pDsEstado", "pInReceberAlerta", "pInReceberSit",
                                               "pInDesejaPartic", "pInModerador", "pDsPsnCadastro", "pIdUsuarioOperacao",
                                               "pPsnUsuarioOperacao", "pDsPaginaOperacao"};

                        string receiveWarningEachRound = Convert.ToBoolean(model.receiveWarningEachRound) ? "1" : "0";
                        string receiveTeamTable = Convert.ToBoolean(model.receiveTeamTable) ? "1" : "0";
                        string wishParticipate = Convert.ToBoolean(model.wishParticipate) ? "1" : "0";
                        string userActive = Convert.ToBoolean(model.userActive) ? "1" : "0";
                        string userModerator = Convert.ToBoolean(model.userModerator) ? "1" : "0";

                        paramValue = new string[] { Convert.ToString(model.id), model.name, model.email, model.psnID, userActive,
                                                model.howfindus, model.whatkindofmedia, model.team, model.birthday.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                model.state, receiveWarningEachRound, receiveTeamTable, wishParticipate,
                                                userModerator, model.psnIDOperator, Convert.ToString(model.idOperator), model.psnIDOperator, "userController.Update"};


                        dt = db.executePROC("spUpdateUsuario", paramName, paramValue);

                        model.returnMessage = "ModeratorSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "1")
                    {
                        model.returnMessage = "PsnFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "2")
                    {
                        model.returnMessage = "NameFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "3")
                    {
                        model.returnMessage = "EmailFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else
                    {
                        model.returnMessage = "ValidationNotFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }

                }
                else if (model.actionUser.ToLower() == "save" && model.id == 0)
                {
                    paramName = new string[] { "pdsPsn", "pNmUsuario", "pDsEmail" };
                    paramValue = new string[] { model.psnID, model.name, model.email };
                    dt = db.executePROC("spValidateRegistrationOfUsuarioNewUsuario", paramName, paramValue);

                    var rowValRegister = dt.Rows[0];

                    if (rowValRegister["COD_VALIDATION"].ToString() == "0")
                    {
                        paramName = new string[] { "pNmUsuario", "pDsSenhaBase64", "pDsEmail", "pPsnId", "pInAtivo", "pDsFicouSabendo",
                                               "pDsQual", "pNmTime", "pDtNasc", "pDsEstado", "pInReceberAlerta", "pInReceberSit",
                                               "pInDesejaPartic", "pInModerador", "pDsPsnCadastro", "pIdUsuarioOperacao",
                                               "pPsnUsuarioOperacao", "pDsPaginaOperacao"};

                        byte[] byt = System.Text.Encoding.UTF8.GetBytes(model.password);
                        string passwordBase64 = Convert.ToBase64String(byt);

                        string receiveWarningEachRound = Convert.ToBoolean(model.receiveWarningEachRound) ? "1" : "0";
                        string receiveTeamTable = Convert.ToBoolean(model.receiveTeamTable) ? "1" : "0";
                        string wishParticipate = Convert.ToBoolean(model.wishParticipate) ? "1" : "0";
                        string userActive = Convert.ToBoolean(model.userActive) ? "1" : "0";
                        string userModerator = Convert.ToBoolean(model.userModerator) ? "1" : "0";

                        paramValue = new string[] { model.name, passwordBase64, model.email, model.psnID, userActive,
                                                model.howfindus, model.whatkindofmedia, model.team, model.birthday.ToString("dd/MM/yyyy") + ";[DATE-TYPE]",
                                                model.state, receiveWarningEachRound, receiveTeamTable, wishParticipate,
                                                userModerator, model.pageName, Convert.ToString(model.idOperator), model.psnIDOperator, "userController.Insert"};


                        dt = db.executePROC("spAddUsuario", paramName, paramValue);

                        model.returnMessage = "ModeratorSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = model.id }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "1")
                    {
                        model.returnMessage = "PsnFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "2")
                    {
                        model.returnMessage = "NameFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else if (rowValRegister["COD_VALIDATION"].ToString() == "3")
                    {
                        model.returnMessage = "EmailFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }
                    else
                    {
                        model.returnMessage = "ValidationNotFound";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                    }

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

        [HttpGet]
        public IHttpActionResult GetAllUser()
        {

            UserDetailsModel modelDetails = new UserDetailsModel();
            UserViewModel mainModel = new UserViewModel();
            List<UserDetailsModel> listOfModel = new List<UserDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllUsuariosNoFilterCRUD", paramName, paramValue);

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new UserDetailsModel();
                    modelDetails.id = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    modelDetails.userActive = Convert.ToBoolean(dt.Rows[i]["IN_USUARIO_ATIVO"].ToString());
                    modelDetails.userModerator = Convert.ToBoolean(dt.Rows[i]["IN_USUARIO_MODERADOR"].ToString());

                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfUser = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);

            }
            catch (Exception ex)
            {
                mainModel = new UserViewModel();
                mainModel.listOfUser = new List<UserDetailsModel>();
                mainModel.returnMessage = "errorGetAllUser_" + ex.Message;
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
        public IHttpActionResult GetUser(int id)
        {

            UserDetailsModel modelDetails = new UserDetailsModel();
            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] { "pIdUsuario" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetUsuarioById", paramName, paramValue);

                if (dt.Rows.Count>0)
                {
                    modelDetails.id = Convert.ToInt16(dt.Rows[0]["ID_USUARIO"].ToString());
                    modelDetails.name = dt.Rows[0]["NM_USUARIO"].ToString();
                    modelDetails.psnID = dt.Rows[0]["PSN_ID"].ToString();
                    modelDetails.password = dt.Rows[0]["DS_SENHA"].ToString();
                    modelDetails.password20 = dt.Rows[0]["DS_SENHA20"].ToString();
                    modelDetails.userActive = Convert.ToBoolean(dt.Rows[0]["IN_USUARIO_ATIVO"].ToString());
                    modelDetails.userModerator = Convert.ToBoolean(dt.Rows[0]["IN_USUARIO_MODERADOR"].ToString());
                    modelDetails.email = dt.Rows[0]["DS_EMAIL"].ToString();
                    if (!String.IsNullOrEmpty(dt.Rows[0]["DT_ULTIMO_ACESSO"].ToString()))
                        modelDetails.lastAccess = Convert.ToDateTime(dt.Rows[0]["DT_ULTIMO_ACESSO"].ToString());
                    modelDetails.birthday = Convert.ToDateTime(dt.Rows[0]["DT_NASCIMENTO"].ToString());
                    modelDetails.state = dt.Rows[0]["DS_ESTADO"].ToString();
                    modelDetails.team = dt.Rows[0]["NM_TIME"].ToString();
                    modelDetails.howfindus = dt.Rows[0]["DS_COMO_FICOU_SABENDO"].ToString();
                    modelDetails.whatkindofmedia = dt.Rows[0]["DS_QUAL"].ToString();
                    modelDetails.receiveWarningEachRound = Convert.ToByte(dt.Rows[0]["IN_RECEBER_EMAIL_ALERTA"].ToString());
                    modelDetails.receiveTeamTable = Convert.ToByte(dt.Rows[0]["IN_RECEBER_EMAIL_SITUACAO_CAMPEONATO"].ToString());
                    modelDetails.wishParticipate = Convert.ToByte(dt.Rows[0]["IN_DESEJA_PARTICIPAR"].ToString());
                    modelDetails.register = Convert.ToDateTime(dt.Rows[0]["DT_CADASTRO"].ToString());
                    modelDetails.linkLiveMatch = dt.Rows[0]["DS_URL_LINK_AOVIVO"].ToString();
                    modelDetails.lastUpdate = Convert.ToDateTime(dt.Rows[0]["DT_ULTIMA_ALTERACAO"].ToString());
                    modelDetails.psnIDLastUpdate = dt.Rows[0]["DS_LOGIN_ALTERACAO"].ToString();
                    modelDetails.passwordManager = dt.Rows[0]["DS_SENHA_CONFIRMACAO"].ToString();
                    modelDetails.passwordManager20 = dt.Rows[0]["DS_SENHA_CONFIRMACAO20"].ToString();
                    modelDetails.workEmail = dt.Rows[0]["DS_EMAIL_CORPORATIVO"].ToString();
                    modelDetails.codeArea = dt.Rows[0]["NO_DDD"].ToString();
                    modelDetails.mobileNumber = dt.Rows[0]["NO_CELULAR"].ToString();
                    modelDetails.psnIDOperator = dt.Rows[0]["DS_LOGIN_ALTERACAO"].ToString();
                    modelDetails.dateLastUpdate = dt.Rows[0]["DT_ALTERACAO_FORMATADA"].ToString();
                    modelDetails.dateRegister = dt.Rows[0]["DT_CADASTRO_FORMATADA"].ToString();

                    modelDetails.currentTeam = dt.Rows[0]["ID_TIMEH2H"].ToString();

                    if (string.IsNullOrEmpty(modelDetails.currentTeam))
                    {
                        if (!string.IsNullOrEmpty(dt.Rows[0]["ID_TIMEFUT"].ToString())) { modelDetails.currentTeam = dt.Rows[0]["ID_TIMEFUT"].ToString(); }
                        else if (!string.IsNullOrEmpty(dt.Rows[0]["ID_TIMEPRO"].ToString())) { modelDetails.currentTeam = dt.Rows[0]["ID_TIMEPRO"].ToString(); }
                    }
                }

                modelDetails.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

            }
            catch (Exception ex)
            {
                modelDetails = new UserDetailsModel();
                modelDetails.returnMessage = "errorGetUser_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                dt = null;
            }

        }

    }
}
