using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipStageModel
    {
        public class ChampionshipStageListViewModel
        {
            public List<ChampionshipStageDetailsModel> listOfStage { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipStageDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
        }

    }
}