using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipTypeModel
    {
        public class ChampionshipTypeListViewModel
        {
            public List<ChampionshipTypeDetailsModel> listOfType { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipTypeDetailsModel
        {
            public string id { get; set; }
            public string name { get; set; }
        }


    }
}