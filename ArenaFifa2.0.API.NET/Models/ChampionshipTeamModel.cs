using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipTeamModel
    {
        public class ChampionshipTeamListViewModel
        {
            public List<ChampionshipTeamDetailsModel> listOfTeam { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipTeamDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public string type { get; set; }
        }


    }
}