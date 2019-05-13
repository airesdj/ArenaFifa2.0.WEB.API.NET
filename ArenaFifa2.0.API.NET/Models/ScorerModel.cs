using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ScorerModel
    {
        public class ScorerViewModel
        {
            public int id { get; set; }
            public string scorerType { get; set; }

            public List<ScorerDetails> listOfScorer { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ScorerDetails
        {
            public string scorerType { get; set; }
            public int id { get; set; }
            public string name { get; set; }
            public string nickname { get; set; }
            public int teamID { get; set; }
            public string teamName { get; set; }
            public string teamType { get; set; }
            public string link { get; set; }
            public string country { get; set; }
            public string sofifaTeamID { get; set; }
            public string rating { get; set; }
            public int userID { get; set; }
            public DateTime DateSubscription { get; set; }
            public string DateSubscriptionFormatted { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}