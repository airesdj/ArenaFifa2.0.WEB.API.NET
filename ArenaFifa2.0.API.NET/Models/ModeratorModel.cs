using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ModeratorModel
    {
        public class SummaryViewModel
        {
            public int totalActiveCoaches { get; set; }
            public int totalSeasonCoaches { get; set; }
            public string currentStageNameH2H { get; set; }
            public string seasonNameH2H { get; set; }
            public string seasonNameFUT { get; set; }
            public string seasonNamePRO { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


        public class DrawViewModel
        {
            public int championshipID { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}