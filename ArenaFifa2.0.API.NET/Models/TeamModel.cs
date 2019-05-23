using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static ArenaFifa20.API.NET.Models.ScorerModel;

namespace ArenaFifa20.API.NET.Models
{
    public class TeamModel
    {
        public class TeamListViewModel
        {
            public int id { get; set; }
            public string teamType { get; set; }
            public List<TeamDetailsModel> listOfTeam { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class TeamDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public string typeMode { get; set; }
            public int typeModeID { get; set; }
            public string teamSofifaURL { get; set; }
            public int teamSofifaID { get; set; }
            public byte teamDeleted { get; set; }
            public byte hasImage { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string pathLogo { get; set; }
            public List<ScorerDetails> listOfScorer { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}