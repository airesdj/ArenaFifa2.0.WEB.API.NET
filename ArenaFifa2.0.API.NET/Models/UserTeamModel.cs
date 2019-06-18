using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class UserTeamModel
    {
        public class UserTeamViewModel
        {
            public int championshipID { get; set; }
            public int userID { get; set; }
            public int teamID { get; set; }
            public int drawDone { get; set; }
            public List<UserTeamDetailsModel> listOfUserTeam { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class UserTeamDetailsModel
        {
            public int championshipID { get; set; }
            public int userID { get; set; }
            public int teamID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string teamName { get; set; }
            public string teamType { get; set; }
        }

    }
}