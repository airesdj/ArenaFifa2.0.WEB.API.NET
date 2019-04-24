using System;
using System.Web.Http;
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
        public IHttpActionResult hallOfFame(SummaryViewModel model)
        {


            db.openConnection();
            DataTable dt = null;

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
                model = new SummaryViewModel();
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