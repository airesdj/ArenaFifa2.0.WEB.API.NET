using System;
using System.Web.Http;
using static ArenaFifa20.API.NET.Models.MyMatchesModel;
using static ArenaFifa20.API.NET.Models.HallOfFameModel;
using DBConnection;
using System.Data;
using System.Net;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Controllers
{
    public class HallOfFameController : ApiController
    {

        private connectionMySQL db = new DBConnection.connectionMySQL();
        string[] paramName = null;
        string[] paramValue = null;

        [HttpPost]
        public IHttpActionResult hallOfFame(HallOfFameSummaryViewModel model)
        {
            if (String.IsNullOrEmpty(model.dataBaseName)) { model.dataBaseName = GlobalVariables.DATABASE_NAME_ONLINE; }
            db.openConnection(model.dataBaseName);
            DataTable dt = null;
            string returnMessage = String.Empty;

            try
            {

                if (model.actionUser == "summary")
                {
                    paramName = new string[] {  };
                    paramValue = new string[] {  };
                    dt = db.executePROC("spGetSummaryHallOfFame", paramName, paramValue);

                    model.psnIDSerieAH2H = dt.Rows[0]["psnIDH2HChampion"].ToString();
                    model.teamIDSerieAH2H = dt.Rows[0]["teamNameH2HChampion"].ToString();

                    model.psnIDSerieAFUT = dt.Rows[0]["psnIDFUTChampion"].ToString();
                    model.teamIDSerieAFUT = dt.Rows[0]["teamNameFUTChampion"].ToString();

                    model.psnIDSerieAPRO = dt.Rows[0]["psnIDPROChampion"].ToString();
                    model.teamIDSerieAPRO = dt.Rows[0]["teamNamePROChampion"].ToString();

                    model.psnIDCDM = dt.Rows[0]["psnIDCDMChampion"].ToString();
                    model.teamIDCDM = dt.Rows[0]["teamNameCDMChampion"].ToString();

                    model.psnIDUCL = dt.Rows[0]["psnIDUCLChampion"].ToString();
                    model.teamIDUCL = dt.Rows[0]["teamNameUCLChampion"].ToString();

                    model.psnIDSCP = dt.Rows[0]["psnIDSCPChampion"].ToString();
                    model.teamIDSCP = dt.Rows[0]["teamNameSCPChampion"].ToString();

                    model.returnMessage = "HallOfFameSuccessfully";
                    return CreatedAtRoute("DefaultApi", new { id = 0 }, model);
                }
                else if (model.actionUser == "championshipScoring")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetAllCampeonatosScoring", paramName, paramValue);

                    ChampionshipScoreViewModel championshipScoring = new ChampionshipScoreViewModel();
                    ChampionshipTypeModel championshipType = new ChampionshipTypeModel();
                    List<ChampionshipTypeModel> listOfChampionship = new List<ChampionshipTypeModel>();

                    try
                    {
                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            championshipType = new ChampionshipTypeModel();
                            championshipType.championshipType = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                            championshipType.scoreChampion = Convert.ToInt16(dt.Rows[i]["PT_CAMPEAO"].ToString());
                            championshipType.scoreVice = Convert.ToInt16(dt.Rows[i]["PT_VICECAMPEAO"].ToString());
                            championshipType.scoreSemi = Convert.ToInt16(dt.Rows[i]["PT_SEMIS"].ToString());
                            championshipType.scoreQuarter = Convert.ToInt16(dt.Rows[i]["PT_QUARTAS"].ToString());
                            championshipType.scoreRound16 = Convert.ToInt16(dt.Rows[i]["PT_OITAVAS"].ToString());
                            championshipType.scoreQualifyNextStage = Convert.ToInt16(dt.Rows[i]["PT_CLASSIF_FASE2"].ToString());
                            championshipType.scoreWins = Convert.ToInt16(dt.Rows[i]["PT_VITORIAS_FASE1"].ToString());
                            championshipType.scoreDraws = Convert.ToInt16(dt.Rows[i]["PT_EMPATES_FASE1"].ToString());
                            championshipType.score2ndStage = Convert.ToInt16(dt.Rows[i]["PT_FASE2"].ToString());
                            listOfChampionship.Add(championshipType);
                        }

                        championshipScoring.listChampionshipScore = listOfChampionship;
                        championshipScoring.returnMessage = "HallOfFameSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, championshipScoring);
                    }
                    catch (Exception ex)
                    {
                        championshipScoring = new ChampionshipScoreViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, championshipScoring);
                    }
                    finally
                    {
                        championshipScoring = null;
                        championshipType = null;
                        listOfChampionship = null;
                    }
                }
                else if (model.actionUser == "blackList")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    dt = db.executePROC("spGetAllListaNegra", paramName, paramValue);

                    GeneralBlackListViewModel blackListModel = new GeneralBlackListViewModel();
                    GeneralBlackListModel listGeneralBlackList = new GeneralBlackListModel();
                    List<GeneralBlackListModel> listOfBlackList = new List<GeneralBlackListModel>();

                    try
                    {

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            listGeneralBlackList = new GeneralBlackListModel();
                            listGeneralBlackList.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            listGeneralBlackList.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            listGeneralBlackList.total = Convert.ToInt16(dt.Rows[i]["TOTAL_GERAL"].ToString());
                            if (!String.IsNullOrEmpty(dt.Rows[i]["TOTAL_TEMP"].ToString())) 
                                listGeneralBlackList.totalPreviousSeason = Convert.ToInt16(dt.Rows[i]["TOTAL_TEMP"].ToString());
                            else
                                listGeneralBlackList.totalPreviousSeason = 0;
                            listOfBlackList.Add(listGeneralBlackList);
                        }

                        blackListModel.listBlackList = listOfBlackList;
                        blackListModel.returnMessage = "HallOfFameSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, blackListModel);
                    }
                    catch (Exception ex)
                    {
                        blackListModel = new GeneralBlackListViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, blackListModel);
                    }
                    finally
                    {
                        blackListModel = null;
                        listGeneralBlackList = null;
                        listOfBlackList = null;
                    }
                }
                else if (model.actionUser == "renewal")
                {

                    RenewalChampionshipModel renewalChampionship = new RenewalChampionshipModel();
                    RenewalViewModel RenewalModel = new RenewalViewModel();
                    List<RenewalChampionshipModel> listOfRenewal = new List<RenewalChampionshipModel>();
                    int totAcceptedApproved = 0;
                    int totUnderAnalysis = 0;

                    int blackListPoints = 0;

                    try
                    {

                        if (model.seasonID == 0)
                        {
                            paramName = new string[] { "pMode" };
                            paramValue = new string[] { "" };
                            dt = db.executePROC("spGetIDsTemporadaByMode", paramName, paramValue);

                            model.seasonID = Convert.ToInt32(dt.Rows[0]["id_current_temporada"].ToString());
                            model.seasonName = dt.Rows[0]["nm_current_temporada"].ToString();
                            model.previousSeasonID = Convert.ToInt32(dt.Rows[0]["id_previous_temporada"].ToString());
                            model.previousSeasonName = dt.Rows[0]["nm_previous_temporada"].ToString();
                        }

                        paramName = new string[] { "pIdTemporada", "pIdTemporadaAnt", "pIdsCampeonato" };
                        paramValue = new string[] { Convert.ToString(model.seasonID), Convert.ToString(model.previousSeasonID), model.championshipIDRenewal };

                        if (model.renewalMode == "H2H")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoH2H", paramName, paramValue);
                        }
                        else if (model.renewalMode == "FUT")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoFUT", paramName, paramValue);
                        }
                        else if (model.renewalMode == "PRO")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoPRO", paramName, paramValue);
                        }

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {

                            renewalChampionship = new RenewalChampionshipModel();
                            renewalChampionship.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            renewalChampionship.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            renewalChampionship.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                            renewalChampionship.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                            renewalChampionship.teamName = dt.Rows[i]["NM_TIME"].ToString();

                            if (String.IsNullOrEmpty(dt.Rows[i]["PT_LSTNEGRA"].ToString()))
                                blackListPoints = 0;
                            else
                                blackListPoints = Convert.ToInt32(dt.Rows[i]["PT_LSTNEGRA"].ToString());


                            if (String.IsNullOrEmpty(dt.Rows[i]["IN_CONFIRMACAO"].ToString()))
                            {
                                renewalChampionship.actionRenewal = "Ainda não confirmou";
                                renewalChampionship.acceptedRenewal = "-1";
                                renewalChampionship.status = "AGUARDANDO";
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1 && blackListPoints >= model.totalLimitBlackList)
                            {
                                renewalChampionship.actionRenewal = "Confirmou, mas chegou ao limite de pontos na Lista Negra";
                                renewalChampionship.acceptedRenewal = "9";
                                renewalChampionship.status = "NÃO ACEITO";
                                totUnderAnalysis += 1;
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1)
                            {
                                renewalChampionship.actionRenewal = "Confirmou Participação";
                                renewalChampionship.acceptedRenewal = "1";
                                renewalChampionship.status = "APROVADO";
                                totAcceptedApproved += 1;
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 0)
                            {
                                renewalChampionship.actionRenewal = "Não deseja Participar";
                                renewalChampionship.acceptedRenewal = "0";
                                renewalChampionship.status = "DESISTIU";
                            }

                            renewalChampionship.statusInitials = dt.Rows[i]["DS_STATUS"].ToString();


                            if (model.renewalMode == "PRO")
                                renewalChampionship.playersTotal = Convert.ToInt32(dt.Rows[i]["TOTAL_JOGADORES"].ToString());

                            renewalChampionship.blackListtotal = blackListPoints;

                            if (String.IsNullOrEmpty(dt.Rows[i]["PT_TOTAL"].ToString()))
                                renewalChampionship.total = 0;
                            else
                                renewalChampionship.total = Convert.ToInt32(dt.Rows[i]["PT_TOTAL"].ToString());

                            if (String.IsNullOrEmpty(dt.Rows[i]["PT_TOTAL_ATUAL"].ToString()))
                                renewalChampionship.seasonCurrentTotal = 0;
                            else
                                renewalChampionship.seasonCurrentTotal = Convert.ToInt32(dt.Rows[i]["PT_TOTAL_ATUAL"].ToString());

                            renewalChampionship.grandTotal = renewalChampionship.total + renewalChampionship.seasonCurrentTotal;

                            listOfRenewal.Add(renewalChampionship);
                        }


                        //get all of the bench
                        paramName = new string[] { "pIdTemporada", "pIdTemporadaAnt", "pIdsCampeonato" };
                        paramValue = new string[] { Convert.ToString(model.seasonID), Convert.ToString(model.previousSeasonID), model.championshipIDBenchRenewal };

                        if (model.renewalMode == "H2H")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoH2HBco", paramName, paramValue);
                        }
                        else if (model.renewalMode == "FUT")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoFUTBco", paramName, paramValue);
                        }
                        else if (model.renewalMode == "PRO")
                        {
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoPROBco", paramName, paramValue);
                        }
                        for (var i = 0; i < dt.Rows.Count; i++)
                        {

                            renewalChampionship = new RenewalChampionshipModel();
                            renewalChampionship.psnID = dt.Rows[i]["PSN_ID"].ToString();
                            renewalChampionship.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                            renewalChampionship.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                            renewalChampionship.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                            renewalChampionship.teamName = dt.Rows[i]["NM_TIME"].ToString();

                            if (String.IsNullOrEmpty(dt.Rows[i]["PT_LSTNEGRA"].ToString()))
                                blackListPoints = 0;
                            else
                                blackListPoints = Convert.ToInt32(dt.Rows[i]["PT_LSTNEGRA"].ToString());


                            if (String.IsNullOrEmpty(dt.Rows[i]["IN_CONFIRMACAO"].ToString()))
                            {
                                renewalChampionship.actionRenewal = "Ainda não confirmou";
                                renewalChampionship.acceptedRenewal = "-1";
                                renewalChampionship.status = "AGUARDANDO";
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1 && blackListPoints >= model.totalLimitBlackList)
                            {
                                renewalChampionship.actionRenewal = "Confirmou, mas chegou ao limite de pontos na Lista Negra";
                                renewalChampionship.acceptedRenewal = "9";
                                renewalChampionship.status = "NÃO ACEITO";
                                totUnderAnalysis += 1;
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1)
                            {
                                renewalChampionship.actionRenewal = "Confirmou Participação";
                                renewalChampionship.acceptedRenewal = "1";
                                renewalChampionship.status = "APROVADO";
                                totAcceptedApproved += 1;
                            }
                            else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 0)
                            {
                                renewalChampionship.actionRenewal = "Não deseja Participar";
                                renewalChampionship.acceptedRenewal = "0";
                                renewalChampionship.status = "DESISTIU";
                            }

                            renewalChampionship.statusInitials = dt.Rows[i]["DS_STATUS"].ToString();


                            if (model.renewalMode == "PRO")
                                renewalChampionship.playersTotal = Convert.ToInt32(dt.Rows[i]["TOTAL_JOGADORES"].ToString());

                            renewalChampionship.blackListtotal = blackListPoints;
                            if (String.IsNullOrEmpty(dt.Rows[i]["PT_TOTAL"].ToString()))
                                renewalChampionship.total = 0;
                            else
                                renewalChampionship.total = Convert.ToInt32(dt.Rows[i]["PT_TOTAL"].ToString());
                            renewalChampionship.seasonCurrentTotal = 0; // Convert.ToInt16(dt.Rows[i]["PT_TOTAL_ATUAL"].ToString());
                            renewalChampionship.grandTotal = renewalChampionship.total + renewalChampionship.seasonCurrentTotal;

                            listOfRenewal.Add(renewalChampionship);
                        }


                        //get all of H2H world cup or ueaf euro
                        if (model.renewalMode == "H2H" && !String.IsNullOrEmpty(model.championshipIDRenewalWorldCupUefaEuro))
                        {
                            paramName = new string[] { "pIdTemporada", "pIdTemporadaAnt", "pIdsCampeonato" };
                            paramValue = new string[] { Convert.ToString(model.seasonID), Convert.ToString(model.previousSeasonID), model.championshipIDRenewalWorldCupUefaEuro };
                            dt = db.executePROC("spGetAllConfirmacaoTemporadaOfCampeonatoCDM", paramName, paramValue);

                            for (var i = 0; i < dt.Rows.Count; i++)
                            {

                                renewalChampionship = new RenewalChampionshipModel();
                                renewalChampionship.psnID = dt.Rows[i]["PSN_ID"].ToString();
                                renewalChampionship.userName = dt.Rows[i]["NM_USUARIO"].ToString();
                                renewalChampionship.userID = Convert.ToInt32(dt.Rows[i]["ID_USUARIO"].ToString());
                                renewalChampionship.championshipID = Convert.ToInt16(dt.Rows[i]["ID_CAMPEONATO"].ToString());
                                renewalChampionship.teamName = String.Empty;

                                if (String.IsNullOrEmpty(dt.Rows[i]["PT_LSTNEGRA"].ToString()))
                                    blackListPoints = 0;
                                else
                                    blackListPoints = Convert.ToInt32(dt.Rows[i]["PT_LSTNEGRA"].ToString());


                                if (String.IsNullOrEmpty(dt.Rows[i]["IN_CONFIRMACAO"].ToString()))
                                {
                                    renewalChampionship.actionRenewal = "Ainda não confirmou";
                                    renewalChampionship.acceptedRenewal = "-1";
                                    renewalChampionship.status = "AGUARDANDO";
                                }
                                else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1 && blackListPoints >= model.totalLimitBanWorldCupUefaEuro)
                                {
                                    renewalChampionship.actionRenewal = "Confirmou, mas chegou ao limite de pontos na Lista Negra para Copa do Mundo/Eurocopa";
                                    renewalChampionship.acceptedRenewal = "9";
                                    renewalChampionship.status = "NÃO ACEITO";
                                }
                                else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 1)
                                {
                                    renewalChampionship.actionRenewal = "Confirmou Participação";
                                    renewalChampionship.acceptedRenewal = "1";
                                    renewalChampionship.status = "APROVADO";
                                }
                                else if (Convert.ToInt16(dt.Rows[i]["IN_CONFIRMACAO"].ToString()) == 0)
                                {
                                    renewalChampionship.actionRenewal = "Não deseja Participar";
                                    renewalChampionship.acceptedRenewal = "0";
                                    renewalChampionship.status = "DESISTIU";
                                }

                                renewalChampionship.statusInitials = dt.Rows[i]["DS_STATUS"].ToString();


                                renewalChampionship.blackListtotal = blackListPoints;

                                if (String.IsNullOrEmpty(dt.Rows[i]["PT_TOTAL"].ToString()))
                                    renewalChampionship.total = 0;
                                else
                                    renewalChampionship.total = Convert.ToInt32(dt.Rows[i]["PT_TOTAL"].ToString());

                                if (String.IsNullOrEmpty(dt.Rows[i]["PT_TOTAL_ATUAL"].ToString()))
                                    renewalChampionship.seasonCurrentTotal = 0;
                                else
                                    renewalChampionship.seasonCurrentTotal = Convert.ToInt32(dt.Rows[i]["PT_TOTAL_ATUAL"].ToString());

                                renewalChampionship.grandTotal = renewalChampionship.total + renewalChampionship.seasonCurrentTotal;

                                listOfRenewal.Add(renewalChampionship);
                            }
                        }

                        RenewalModel.renewalMode = model.renewalMode;
                        RenewalModel.seasonID = model.seasonID;
                        RenewalModel.seasonName = model.seasonName;
                        RenewalModel.previousSeasonID = model.previousSeasonID;
                        RenewalModel.previousSeasonName = model.previousSeasonName;
                        RenewalModel.championshipIDBenchRenewal = model.championshipIDBenchRenewal;
                        RenewalModel.championshipIDRenewal = model.championshipIDRenewal;
                        RenewalModel.championshipIDRenewalWorldCupUefaEuro = model.championshipIDRenewalWorldCupUefaEuro;
                        RenewalModel.totalApprovedRenewal = totAcceptedApproved;
                        RenewalModel.totalUnderAnalysisRenewal = totUnderAnalysis;
                        RenewalModel.listOfRenewal = listOfRenewal;
                        RenewalModel.returnMessage = "HallOfFameSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, RenewalModel);
                    }
                    catch (Exception ex)
                    {
                        RenewalModel = new RenewalViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, RenewalModel);
                    }
                    finally
                    {
                        renewalChampionship = null;
                        RenewalModel = null;
                        listOfRenewal = null;
                    }
                }
                else if (model.actionUser == "renewalSquad")
                {
                    RenewalPROCLUBSquadViewModel PROCLUBSquadModel = new RenewalPROCLUBSquadViewModel();
                    squadListModel renewalSquad = new squadListModel();
                    List<squadListModel> listOfSquad = new List<squadListModel>();

                    PROCLUBSquadModel.managerID = model.managerID;
                    PROCLUBSquadModel.seasonID = model.seasonID;
                    PROCLUBSquadModel.clubName = model.clubName;

                    try
                    {

                        paramName = new string[] { "pIdUsuario" };
                        paramValue = new string[] { Convert.ToString(PROCLUBSquadModel.managerID) };
                        dt = db.executePROC("spGetUsuarioById", paramName, paramValue);

                        PROCLUBSquadModel.psnID = dt.Rows[0]["PSN_ID"].ToString();
                        PROCLUBSquadModel.mangerName = dt.Rows[0]["NM_USUARIO"].ToString();
                        PROCLUBSquadModel.mobileNumber = dt.Rows[0]["NO_CELULAR"].ToString();
                        PROCLUBSquadModel.codeMobileNumber = dt.Rows[0]["NO_DDD"].ToString();

                        PROCLUBSquadModel.listOfSquad = GlobalFunctions.getListOfSquadPROCLUB(db, model.seasonID, model.managerID, out returnMessage);
                        PROCLUBSquadModel.returnMessage = "HallOfFameSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, PROCLUBSquadModel);
                    }
                    catch (Exception ex)
                    {
                        PROCLUBSquadModel = new RenewalPROCLUBSquadViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, PROCLUBSquadModel);
                    }
                    finally
                    {
                        PROCLUBSquadModel = null;
                        renewalSquad = null;
                        listOfSquad = null;
                    }
                }
                else if (model.actionUser.Substring(0, 11) == "achievement")
                {
                    paramName = new string[] { };
                    paramValue = new string[] { };
                    if (model.actionUser.IndexOf("H2H") > 0)
                        dt = db.executePROC("spGetAchievementH2H", paramName, paramValue);
                    else if (model.actionUser.IndexOf("FUT") > 0)
                        dt = db.executePROC("spGetAchievementFUT", paramName, paramValue);
                    else if (model.actionUser.IndexOf("PRO") > 0)
                        dt = db.executePROC("spGetAchievementPRO", paramName, paramValue);

                    AchievementViewModel GeneralAchievementModel = new AchievementViewModel();
                    AchievementModel achievementModel = new AchievementModel();
                    List<AchievementModel> listOfAchievement = new List<AchievementModel>();

                    try
                    {

                        for (var i = 0; i < dt.Rows.Count; i++)
                        {
                            achievementModel = new AchievementModel();
                            achievementModel.championshipType = dt.Rows[i]["SG_TIPO_CAMPEONATO"].ToString();
                            achievementModel.inGroup = Convert.ToBoolean(dt.Rows[i]["IN_CAMPEONATO_GRUPO"].ToString());
                            achievementModel.seasonName = dt.Rows[i]["ID_TEMPORADA"].ToString() + "ª Temporada (" + dt.Rows[i]["IN_CONSOLE"].ToString() + ")";
                            achievementModel.userName = dt.Rows[i]["NM_USUARIO"].ToString() + " (" + dt.Rows[i]["PSN_ID"].ToString() + ")";
                            achievementModel.teamName = dt.Rows[i]["NM_TIME"].ToString() + "-" + dt.Rows[i]["DS_TIPO"].ToString();
                            listOfAchievement.Add(achievementModel);
                        }

                        GeneralAchievementModel.listOfAchievement = listOfAchievement;
                        GeneralAchievementModel.returnMessage = "HallOfFameSuccessfully";
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, GeneralAchievementModel);
                    }
                    catch (Exception ex)
                    {
                        GeneralAchievementModel = new AchievementViewModel();
                        model.returnMessage = "error_" + ex.Message;
                        return CreatedAtRoute("DefaultApi", new { id = 0 }, GeneralAchievementModel);
                    }
                    finally
                    {
                        GeneralAchievementModel = null;
                        listOfAchievement = null;
                        achievementModel = null;
                    }
                }

                else
                {
                    return StatusCode(HttpStatusCode.NotAcceptable);
                }

            }
            catch (Exception ex)
            {
                model = new HallOfFameSummaryViewModel();
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