using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class TeamModel
    {
        public class TeamListViewModel
        {
            public List<TeamDetailsModel> listOfTeam { get; set; }
            public string teamType { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class TeamDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public string typeMode { get; set; }
            public int typeModeID { get; set; }
            public int userID { get; set; }
            public int teamSofifaID { get; set; }
            public byte teamDeleted { get; set; }
            public byte hasImage { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}