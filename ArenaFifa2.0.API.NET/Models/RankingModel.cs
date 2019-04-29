using System;
using System.Collections.Generic;
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

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class listScorers
        {
            public int totalGoals { get; set; }
            public string playerName { get; set; }
            public string psnID { get; set; }
            public string teamName { get; set; }
        }

    }
}