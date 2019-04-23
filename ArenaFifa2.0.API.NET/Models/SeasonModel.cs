using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class SeasonModel
    {
        public class SeasonModesViewModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public DateTime dtStartSeason { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class SeasonDetails
        {
            public int id { get; set; }
            public string name { get; set; }
            public byte active { get; set; }
            public DateTime dtStartSeason { get; set; }
            public DateTime dtEndSeason { get; set; }
            public string typeMode { get; set; }
            public string returnMessage { get; set; }
        }


    }
}