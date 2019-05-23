﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class TeamTypeModel
    {
        public class TeamTypeListViewModel
        {
            public List<TeamTypeDetailsModel> listOfType { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class TeamTypeDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
        }


    }
}