using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.ChampionshipModel;
using static ArenaFifa20.API.NET.Models.ChampionshipUserModel;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamModel;
using static ArenaFifa20.API.NET.Models.ChampionshipStageModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;
using System.Configuration;

namespace ArenaFifa20.API.NET.Controllers
{
    public class ChampionshipController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult Championship(ChampionshipDetailsModel model)
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            ChampionshipListViewModel mainModel = new ChampionshipListViewModel();
            List<ChampionshipDetailsModel> listOfModel = new List<ChampionshipDetailsModel>();
            db.openConnection();
            DataTable dt = null;

            try
            {

                if (model.actionUser.ToLower() == "save" && model.id > 0)
                {
                    
                    paramName = new string[] { "pId", "pNmCamp", "pQtTimes", "pDtInicio", "pDtSorteio", "pAtivo", "pPorGrupo", "pTurnoUnico",
                                               "pTurnoReturno", "pQtGrupos", "pMataMata", "pIdaVolta", "pQtTimesClassif", "pQtTimesRebaix", "pIdUsuModera",
                                               "pIdUsuModera2", "pQtDiasFaseClassif", "pQtDiasFaseMataMata", "pSgTipoCamp", "pQtTimesProxClassif", "pIdConsole",
                                               "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao"};

                    string active = Convert.ToBoolean(model.active) ? "1" : "0";
                    string group = Convert.ToBoolean(model.forGroup) ? "1" : "0";
                    string justOneTurn = Convert.ToBoolean(model.justOneTurn) ? "1" : "0";
                    string twoTurns = Convert.ToBoolean(model.twoTurns) ? "1" : "0";
                    string playoff = Convert.ToBoolean(model.playoff) ? "1" : "0";
                    string twoLegs = Convert.ToBoolean(model.twoLegs) ? "1" : "0";

                    paramValue = new string[] { Convert.ToString(model.id), model.name, Convert.ToString(model.totalTeam), model.startDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]", model.drawDate.ToString("dd/MM/yyyy") + ";[DATE-TYPE]", active, group, justOneTurn,
                                                twoTurns, Convert.ToString(model.totalGroup), playoff, twoLegs, Convert.ToString(model.totalQualify), Convert.ToString(model.totalRelegation), Convert.ToString(model.userID1),
                                                Convert.ToString(model.userID2), Convert.ToString(model.totalDayStageOne), Convert.ToString(model.totalDayStagePlayoff), model.type, Convert.ToString(model.totalQualifyNextStage), model.console,
                                                model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.Update"};

                    dt = db.executePROC("spUpdateCampeonatoCRUD", paramName, paramValue);


                    paramName = new string[] { "pIdCamp", "pIdsFase" };
                    paramValue = new string[] { Convert.ToString(model.id), model.listStagesAdd };
                    dt = db.executePROC("spAddLoadFaseOfCampeonatoById", paramName, paramValue);

                    if (model.started == 0)
                    {
                        paramName = new string[] { "pIdCamp", "pIdsTime" };
                        paramValue = new string[] { Convert.ToString(model.id), model.listTeamsAdd };
                        dt = db.executePROC("spAddLoadCampeonatoTimeOfCampeonatoById", paramName, paramValue);

                        paramName = new string[] { "pIdCamp", "pIdsUsu" };
                        paramValue = new string[] { Convert.ToString(model.id), model.listUsersAdd };
                        dt = db.executePROC("spAddLoadCampeonatoUsuarioOfCampeonato", paramName, paramValue);

                        paramName = new string[] { "pIdCamp" };
                        paramValue = new string[] { Convert.ToString(model.id) };
                        dt = db.executePROC("spAddLoadClassificacaoInitialOfCampeonatov2", paramName, paramValue);

                        if (!String.IsNullOrEmpty(model.listTeamsStage0Add))
                        {
                            paramName = new string[] { "pIdCamp", "pIdsTime" };
                            paramValue = new string[] { Convert.ToString(model.id), model.listTeamsStage0Add };
                            dt = db.executePROC("spAddLoadTimesFasePreCopaOfCampeonato", paramName, paramValue);
                        }

                        if (!String.IsNullOrEmpty(model.listUsersStage2Add))
                        {
                            paramName = new string[] { "pIdCamp", "pIdsUsu" };
                            paramValue = new string[] { Convert.ToString(model.id), model.listUsersStage2Add };
                            dt = db.executePROC("spAddLoadCampeonatoUsuarioSegFaseOfCampeonato", paramName, paramValue);
                        }
                    }

                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "getallactive")
                {
                    paramName = new string[] { "pIdTemporada" };
                    paramValue = new string[] { "0" };
                    dt = db.executePROC("spGetAllCampeonatosActiveOfTemporada", paramName, paramValue);

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        modelDetails = new ChampionshipDetailsModel();
                        modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                        modelDetails.seasonID = Convert.ToInt32(dt.Rows[i]["ID_TEMPORADA"].ToString());
                        modelDetails.seasonName = dt.Rows[i]["NM_TEMPORADA"].ToString();
                        modelDetails.name = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                        modelDetails.type = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                        modelDetails.totalTeam = Convert.ToInt32(dt.Rows[i]["QT_TIMES"].ToString());
                        modelDetails.startDate = Convert.ToDateTime(dt.Rows[i]["DT_INICIO"].ToString());
                        modelDetails.drawDate = Convert.ToDateTime(dt.Rows[i]["DT_SORTEIO"].ToString());
                        modelDetails.active = Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_ATIVO"].ToString());

                        listOfModel.Add(modelDetails);
                    }

                    mainModel.listOfChampionship = listOfModel;
                    mainModel.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
                }
                else if (model.actionUser.ToLower() == "userexchange")
                {
                    paramName = new string[] { "pTpCamp", "pIdUsuIN", "pNmUsuIN", "pPsnIDIN", "pIdUsuOUT", "pIdTipoAcesso", "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao" };
                    paramValue = new string[] { model.type, model.userID1.ToString(), model.userName1, model.psnID1, model.userID2.ToString(), ConfigurationManager.AppSettings["access.current.season.exchange"].ToString(), model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.UserExchange" };
                    dt = db.executePROC("spDoUserExchange", paramName, paramValue);

                    model.teamName1 = dt.Rows[0]["NM_TIME"].ToString();
                    model.returnMessage = "ModeratorSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser.ToLower() == "managerexchange")
                {
                    paramName = new string[] { "pTpCamp", "pIdUsuIN", "pNmUsuIN", "pPsnIDIN", "pIdUsuOUT", "pPsnUsuOperacao", "pIdUsuarioOperacao", "pDsPaginaOperacao" };
                    paramValue = new string[] { model.type, model.userID1.ToString(), model.userName1, model.psnID1, model.userID2.ToString(), model.psnOperation, Convert.ToString(model.idUserOperation), "championshipCtrl.MngerExchange" };
                    dt = db.executePROC("spDoMangerExchange", paramName, paramValue);

                    model.teamName1 = dt.Rows[0]["NM_TIME"].ToString();
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
                model.returnMessage = "errorPostChampionship_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, model);

            }
            finally
            {
                db.closeConnection();
                dt = null;
                modelDetails = null;
                mainModel = null;
                listOfModel = null;
            }


        }


        [HttpGet]
        public IHttpActionResult GetDetails(int id)
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();

            ChampionshipUserDetailsModel userDetails = new ChampionshipUserDetailsModel();
            List<ChampionshipUserDetailsModel> listOfUser = new List<ChampionshipUserDetailsModel>();

            ChampionshipTeamDetailsModel teamDetails = new ChampionshipTeamDetailsModel();
            List<ChampionshipTeamDetailsModel> listOfTeam = new List<ChampionshipTeamDetailsModel>();

            ChampionshipStageDetailsModel stageDetails = new ChampionshipStageDetailsModel();
            List<ChampionshipStageDetailsModel> listOfStage = new List<ChampionshipStageDetailsModel>();

            DataTable dt = null;
            db.openConnection();


            try
            {
                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetCampeonatosDetails", paramName, paramValue);

                if (dt.Rows.Count > 0)
                {
                    modelDetails.id = Convert.ToInt32(dt.Rows[0]["ID_CAMPEONATO"].ToString());
                    modelDetails.seasonID = Convert.ToInt32(dt.Rows[0]["ID_TEMPORADA"].ToString());
                    modelDetails.name = dt.Rows[0]["NM_CAMPEONATO"].ToString();
                    modelDetails.seasonName = dt.Rows[0]["NM_Temporada"].ToString();
                    modelDetails.type = dt.Rows[0]["SG_TIPO_CAMPEONATO"].ToString();
                    modelDetails.typeName = dt.Rows[0]["DS_TIPO_CAMPEONATO"].ToString();
                    modelDetails.modeType = dt.Rows[0]["TIPO_CAMPEONATO"].ToString();
                    modelDetails.active = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_ATIVO"].ToString());
                    //modelDetails.startDateFormatted = dt.Rows[0]["DT_INICIO_FORMATADA"].ToString();
                    //modelDetails.drawDateFormatted = dt.Rows[0]["DT_SORTEIO_FORMATADA"].ToString();
                    modelDetails.startDate = Convert.ToDateTime(dt.Rows[0]["DT_INICIO"].ToString());
                    modelDetails.drawDate = Convert.ToDateTime(dt.Rows[0]["DT_SORTEIO"].ToString());


                    modelDetails.totalTeam = Convert.ToInt16(dt.Rows[0]["QT_TIMES"].ToString());
                    modelDetails.totalGroup = Convert.ToInt16(dt.Rows[0]["QT_GRUPOS"].ToString());
                    modelDetails.totalQualify = Convert.ToInt16(dt.Rows[0]["QT_TIMES_CLASSIFICADOS"].ToString());
                    modelDetails.totalRelegation = Convert.ToInt16(dt.Rows[0]["QT_TIMES_REBAIXADOS"].ToString());
                    modelDetails.totalDayStageOne = Convert.ToInt16(dt.Rows[0]["QT_DIAS_PARTIDA_CLASSIFICACAO"].ToString());
                    modelDetails.totalDayStagePlayoff = Convert.ToInt16(dt.Rows[0]["QT_DIAS_PARTIDA_FASE_MATAxMATA"].ToString());
                    modelDetails.totalQualifyNextStage = Convert.ToInt16(dt.Rows[0]["QT_TIMES_PROX_CLASSIF"].ToString());
                    modelDetails.totalTeamQualifyDivAbove = Convert.ToInt16(dt.Rows[0]["QT_TIMES_ACESSO"].ToString());

                    modelDetails.forGroup = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_GRUPO"].ToString());
                    modelDetails.justOneTurn = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_TURNO_UNICO"].ToString());
                    modelDetails.twoTurns = Convert.ToBoolean(dt.Rows[0]["IN_CAMPEONATO_TURNO_RETURNO"].ToString());
                    modelDetails.playoff = Convert.ToBoolean(dt.Rows[0]["IN_SISTEMA_MATA"].ToString());
                    modelDetails.twoLegs = Convert.ToBoolean(dt.Rows[0]["IN_SISTEMA_IDA_VOLTA"].ToString());

                    modelDetails.console = dt.Rows[0]["IN_CONSOLE"].ToString();

                    modelDetails.userID1 = Convert.ToInt32(dt.Rows[0]["ID_USUARIO_MODERADOR"].ToString());
                    modelDetails.userName1 = dt.Rows[0]["NM_Usuario"].ToString();
                    modelDetails.psnID1 = dt.Rows[0]["PSN_ID"].ToString();

                    modelDetails.userID2 = Convert.ToInt32(dt.Rows[0]["ID_USUARIO_2oMODERADOR"].ToString());
                    modelDetails.userName2 = dt.Rows[0]["NM_Usuario2"].ToString();
                    modelDetails.psnID2 = dt.Rows[0]["PSN_ID2"].ToString();

                    modelDetails.stageID_Round = dt.Rows[0]["ID_FASE_NUMERO_RODADA"].ToString(); 

                    modelDetails.started = Convert.ToInt32(dt.Rows[0]["inInicioCampeonato"].ToString());
                    if (!String.IsNullOrEmpty(dt.Rows[0]["idPrimFaseCampeonato"].ToString()))
                        modelDetails.firstStageID = Convert.ToInt32(dt.Rows[0]["idPrimFaseCampeonato"].ToString());
                    else
                        modelDetails.firstStageID = 99;
                }

                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllUsuariosOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    userDetails = new ChampionshipUserDetailsModel();
                    userDetails.id = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    userDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    userDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    listOfUser.Add(userDetails);
                }
                modelDetails.listOfUser = listOfUser;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllTimesOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    teamDetails = new ChampionshipTeamDetailsModel();
                    teamDetails.id = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    teamDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    teamDetails.type = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfTeam.Add(teamDetails);
                }
                modelDetails.listOfTeam = listOfTeam;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllFasePorCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    stageDetails = new ChampionshipStageDetailsModel();
                    stageDetails.id = Convert.ToInt16(dt.Rows[i]["ID_FASE"].ToString());
                    stageDetails.name = dt.Rows[i]["NM_FASE"].ToString();
                    listOfStage.Add(stageDetails);
                }
                modelDetails.listOfStage = listOfStage;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                dt = db.executePROC("spGetAllTimesFasePreCopaOfCampeonato", paramName, paramValue);
                listOfTeam = new List<ChampionshipTeamDetailsModel>();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    teamDetails = new ChampionshipTeamDetailsModel();
                    teamDetails.id = Convert.ToInt16(dt.Rows[i]["ID_TIME"].ToString());
                    teamDetails.name = dt.Rows[i]["NM_TIME"].ToString();
                    teamDetails.type = dt.Rows[i]["DS_TIPO"].ToString();
                    listOfTeam.Add(teamDetails);
                }
                modelDetails.listOfTeamStage0 = listOfTeam;


                paramName = new string[] { "pIdCamp" };
                paramValue = new string[] { Convert.ToString(id) };
                listOfUser = new List<ChampionshipUserDetailsModel>();
                dt = db.executePROC("spGetAllUsuariosSegFaseOfCampeonato", paramName, paramValue);
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    userDetails = new ChampionshipUserDetailsModel();
                    userDetails.id = Convert.ToInt16(dt.Rows[i]["ID_USUARIO"].ToString());
                    userDetails.name = dt.Rows[i]["NM_USUARIO"].ToString();
                    userDetails.psnID = dt.Rows[i]["PSN_ID"].ToString();
                    listOfUser.Add(userDetails);
                }
                modelDetails.listOfUserStage2 = listOfUser;


                modelDetails.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);

            }
            catch (Exception ex)
            {
                modelDetails = new ChampionshipDetailsModel();
                modelDetails.listOfStage = new List<ChampionshipStageDetailsModel>();
                modelDetails.listOfTeam = new List<ChampionshipTeamDetailsModel>();
                modelDetails.listOfUser = new List<ChampionshipUserDetailsModel>();
                modelDetails.returnMessage = "errorGetChampionshipDetails_" + ex.Message;
                return CreatedAtRoute("DefaultApi", new { id = 0 }, modelDetails);
            }
            finally
            {
                db.closeConnection();
                modelDetails = null;
                userDetails = null;
                teamDetails = null;
                stageDetails = null;
                listOfUser = null;
                listOfTeam = null;
                listOfStage = null;
                dt = null;
            }

        }

        [HttpGet]
        public IHttpActionResult GetAll()
        {

            ChampionshipDetailsModel modelDetails = new ChampionshipDetailsModel();
            ChampionshipListViewModel mainModel = new ChampionshipListViewModel();
            List<ChampionshipDetailsModel> listOfModel = new List<ChampionshipDetailsModel>();
            DataTable dt = null;
            db.openConnection();


            try
            {

                paramName = new string[] { };
                paramValue = new string[] { };
                dt = db.executePROC("spGetAllCampeonatosNoFilterCRUD", paramName, paramValue);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    modelDetails = new ChampionshipDetailsModel();
                    modelDetails.id = Convert.ToInt32(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                    modelDetails.seasonID = Convert.ToInt32(dt.Rows[i]["ID_TEMPORADA"].ToString());
                    modelDetails.name = dt.Rows[i]["NM_CAMPEONATO"].ToString();
                    modelDetails.psnID1 = dt.Rows[i]["PSN1"].ToString();
                    modelDetails.psnID2 = dt.Rows[i]["PSN2"].ToString();
                    modelDetails.seasonName = dt.Rows[i]["NM_Temporada"].ToString();
                    modelDetails.type = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                    modelDetails.active = Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_ATIVO"].ToString());
                    modelDetails.startDateFormatted = dt.Rows[i]["DT_INICIO_FORMATADA"].ToString();
                    modelDetails.drawDateFormatted = dt.Rows[i]["DT_SORTEIO_FORMATADA"].ToString();

                    listOfModel.Add(modelDetails);
                }

                mainModel.listOfChampionship = listOfModel;
                mainModel.returnMessage = "ModeratorSuccessfully";
                return CreatedAtRoute("DefaultApi", new { id = 0 }, mainModel);
            }
            catch (Exception ex)
            {
                mainModel = new ChampionshipListViewModel();
                mainModel.listOfChampionship = new List<ChampionshipDetailsModel>();
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