using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ScorerMatchModel
    {
        public class ScorerMatchViewModel
        {
            public int matchID { get; set; }
            public int championshipID { get; set; }

            public List<ScorerMatchDetails> listOfScorerMatch { get; set; }

            public string loadScorersIDHome { get; set; }
            public string loadScorersIDAway { get; set; }
            public string loadScorersGoalsHome { get; set; }
            public string loadScorersGoalsAway { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ScorerMatchDetails
        {
            public int teamID { get; set; }
            public string teamName { get; set; }
            public string teamType { get; set; }
            public int scorerID { get; set; }
            public string scorerName { get; set; }
            public string scorerNickname { get; set; }
            public int totalGoals { get; set; }
            public string sideScorer { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}