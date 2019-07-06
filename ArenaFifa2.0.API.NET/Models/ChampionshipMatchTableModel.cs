using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipMatchTableModel
    {
        public class ChampionshipMatchTableListViewModel
        {
            public List<ChampionshipMatchTableDetailsModel> listOfMatch { get; set; }
            public List<ChampionshipMatchTableClashesByTeamModel> listOfClashes { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipMatchTableDetailsModel
        {
            public int matchID { get; set; }
            public int championshipID { get; set; }
            public string championshipName { get; set; }
            public string seasonName { get; set; }
            public int stageID { get; set; }
            public string stageName { get; set; }
            public int groupID { get; set; }
            public string groupName { get; set; }
            public DateTime startDate { get; set; }
            public DateTime endDate { get; set; }
            public int teamHomeID { get; set; }
            public int teamAwayID { get; set; }
            public string totalGoalsHome { get; set; }
            public string totalGoalsAway { get; set; }
            public DateTime launchDate { get; set; }
            public int round { get; set; }
            public string roundDetails { get; set; }
            public int userHomeID { get; set; }
            public string userHomeName { get; set; }
            public string psnIDHome { get; set; }
            public int userAwayID { get; set; }
            public string userAwayName { get; set; }
            public string psnIDAway { get; set; }
            public int playoffGame { get; set; }
            public string teamNameHome { get; set; }
            public string teamURLHome { get; set; }
            public int teamWithImageHome { get; set; }
            public string teamTypeHome { get; set; }
            public string teamNameAway { get; set; }
            public string teamURLAway { get; set; }
            public int teamWithImageAway { get; set; }
            public string teamTypeAway { get; set; }
            public string modeType { get; set; }
            public int userIDAction { get; set; }
            public string psnIDAction { get; set; }
            public string psnIDSearch { get; set; }
            public string messageBlackList { get; set; }
            public string typeBlackList { get; set; }
            public int totalRecordsOfHistoric { get; set; }
            public Boolean launchResultReleased { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipMatchTableClashesHistoryTotalswModel
        {
            public int userIDLogged { get; set; }
            public string psnIDLogged { get; set; }
            public int userIDSearch { get; set; }
            public string psnIDSearch { get; set; }
            public int totalWinUsuLogged { get; set; }
            public int totalWinUsuSearch { get; set; }
            public int totalDraw { get; set; }
            public int totalLossUsuLogged { get; set; }
            public int totalLossUsuSearch { get; set; }
            public int totalGoalsUsuLogged { get; set; }
            public int totalGoalsUsuSearch { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchWinUsuLogged { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchDraw { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchWinUsuSearch { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


        public class ChampionshipMatchTableClashesHistoryTotalsByTeamswModel
        {
            public int teamIDHome { get; set; }
            public string teamNameHome { get; set; }
            public int teamIDAway { get; set; }
            public string teamNameAway { get; set; }
            public int totalWinTeamHome { get; set; }
            public int totalWinTeamAway { get; set; }
            public int totalDraw { get; set; }
            public int totalLossTeamHome { get; set; }
            public int totalLossTeamAway { get; set; }
            public int totalGoalsTeamHome { get; set; }
            public int totalGoalsTeamAway { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchWinTeamHome { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchDraw { get; set; }
            public List<ChampionshipMatchTableDetailsModel> listOfMatchWinTeamAway { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


        public class ChampionshipMatchTableClashesByTeamModel
        {
            public int userID { get; set; }
            public int championshipID { get; set; }
            public int teamID { get; set; }
            public string teamName { get; set; }
            public int nextMatchTeamID { get; set; }
            public string nextMatchTeamName { get; set; }
            public int nextMatchID { get; set; }
            public string descriptionNextMatch { get; set; }
            public string descriptionPreviousMatch1_1 { get; set; }
            public string descriptionPreviousMatch1_2 { get; set; }
            public string descriptionPreviousMatch1_3 { get; set; }
            public string descriptionPreviousMatch1_4 { get; set; }
            public string statusPreviousMatch1 { get; set; }
            public int prevMatchID1 { get; set; }
            public string descriptionPreviousMatch2_1 { get; set; }
            public string descriptionPreviousMatch2_2 { get; set; }
            public string descriptionPreviousMatch2_3 { get; set; }
            public string descriptionPreviousMatch2_4 { get; set; }
            public string statusPreviousMatch2 { get; set; }
            public int prevMatchID2 { get; set; }
            public string descriptionPreviousMatch3_1 { get; set; }
            public string descriptionPreviousMatch3_2 { get; set; }
            public string descriptionPreviousMatch3_3 { get; set; }
            public string descriptionPreviousMatch3_4 { get; set; }
            public string statusPreviousMatch3 { get; set; }
            public int prevMatchID3 { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

    }
}