using System;
using System.Collections.Generic;
using static ArenaFifa20.API.NET.Models.ScorerModel;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class RankingModel
    {
        public class SummaryViewModel
        {
            public int totGoalsH2H { get; set; }
            public int totGoalsFUT { get; set; }
            public int totGoalsPRO { get; set; }
            public string seasonNameH2H { get; set; }
            public string seasonNameFUT { get; set; }
            public string seasonNamePRO { get; set; }

            public List<listScorers> listOfScorersH2H { get; set; }
            public List<listScorers> listOfScorersPRO { get; set; }

            public int totalRecordsRanking { get; set; }
            public string typeMode { get; set; }
            public string typeChampionship { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class RankingViewModel
        {
            public string typeMode { get; set; }
            public string typeChampionship { get; set; }

            public List<listRanking> listOfRanking { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class listRanking
        {
            public int userID { get; set; }
            public string psnID { get; set; }
            public string userName { get; set; }
            public string teamName { get; set; }
            public string state { get; set; }
            public int total { get; set; }
            public int totalSeason { get; set; }
            public int totalPreviousSeason { get; set; }
            public int totalLeague { get; set; }
            public int totalCup { get; set; }
            public int position { get; set; }
            public string inRelegatePreviousSeason { get; set; }
            public string inAccessCurrentSeason { get; set; }
            public int totalStars { get; set; }
            public int totalHalfStars { get; set; }
            public int totalEmptyStars { get; set; }
        }

    }
}