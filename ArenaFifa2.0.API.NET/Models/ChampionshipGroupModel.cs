﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipGroupModel
    {
        public class ChampionshipGroupListViewModel
        {
            public List<ChampionshipGroupDetailsModel> listOfGroup { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipGroupDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
        }

    }
}