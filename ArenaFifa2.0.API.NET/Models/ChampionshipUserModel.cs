using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipUserModel
    {
        public class ChampionshipUserListViewModel
        {
            public List<ChampionshipUserDetailsModel> listOfUser { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipUserDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public string psnID { get; set; }
            public string email { get; set; }
        }


    }
}