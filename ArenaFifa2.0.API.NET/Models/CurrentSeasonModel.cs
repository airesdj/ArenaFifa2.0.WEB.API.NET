using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static ArenaFifa20.API.NET.Models.ChampionshipModel;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamTableModel;
using static ArenaFifa20.API.NET.Models.ScorerModel;

namespace ArenaFifa20.API.NET.Models
{
    public class CurrentSeasonModel
    {
        public class CurrentSeasonSummaryViewModel
        {
            public int championshipID { get; set; }
            public int userID { get; set; }
            public string modeType { get; set; }
            public int averageGoals { get; set; }
            public int totalMatches { get; set; }
            public int totalGoals { get; set; }
            public int anotherChampionshipID { get; set; }
            public int totalGroupPerChampionship { get; set; }
            public int totalQualifiedPerGroup { get; set; }
            public int placeQualifiedPerGroup { get; set; }

            public List<listScorers> listOfScorersH2H { get; set; }
            public List<listScorers> listOfScorersPRO { get; set; }
            public List<listScorers> listOfScorers { get; set; }
            public List<ChampionshipTeamTableDetailsModel> listOfTeamTableSerieA { get; set; }
            public List<ChampionshipTeamTableDetailsModel> listOfTeamTableSerieB { get; set; }
            public CurrentSeasonMenuViewModel menuCurrentSeason { get; set; }
            public List<ChampionshipTeamTableDetailsModel> listOfForecastTeamQualified { get; set; }
            public List<ChampionshipTeamTableDetailsModel> listOfForecastTeamQualifiedThirdPlace { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class CurrentSeasonMenuViewModel
        {
            public string modeType { get; set; }
            public int currentChampionshipID { get; set; }
            public string currentChampionshipName { get; set; }
            public int currentChampionshipForGroup { get; set; }
            public string currentSeasonName { get; set; }
            public string currentSeasonType { get; set; }
            public List<ActiveChampionshipTypeOfCurrentSeason> listOfActiveChampionship { get; set; }
            public List<ActiveChampionshipTypeOfCurrentSeason> listOfActiveSeasonType { get; set; }
            public List<ChampionshipDetailsModel> listOActiveChampionship { get; set; }
            public List<OtherModeTypeOfCurrentSeason> listOtherModeType { get; set; }
            public ChampionshipDetailsModel currentChampionshipDetails { get; set; }
            public int championshipSerieAID { get; set; }
            public int championshipSerieBID { get; set; }
            public int championshipSerieAForGroup { get; set; }
            public int championshipSerieBForGroup { get; set; }
            public int userHasTeamFUT { get; set; }
            public int userHasTeamPRO { get; set; }
            public string teamName { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ActiveChampionshipTypeOfCurrentSeason
        {
            public int id { get; set; }
            public string name { get; set; }
            public string modeType { get; set; }
            public string partialURL { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class OtherModeTypeOfCurrentSeason
        {
            public string name { get; set; }
            public string modeType { get; set; }
            public string url { get; set; }
        }

    }
}