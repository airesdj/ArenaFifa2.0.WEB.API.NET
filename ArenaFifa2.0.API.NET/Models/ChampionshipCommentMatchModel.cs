using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipCommentMatchModel
    {
        public class ChampionshipCommentMatchListViewModel
        {
            public List<ChampionshipCommentMatchDetailsModel> listOfCommentMatch { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipCommentMatchUsersListViewModel
        {
            public List<ChampionshipCommentMatchUsersDetailsModel> listOfUsersCommentMatch { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipCommentMatchDetailsModel
        {
            public int id { get; set; }
            public int matchID { get; set; }
            public int championshipID { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public DateTime commentDate { get; set; }
            public string commentHour { get; set; }
            public string comment { get; set; }
            public string teamName { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipCommentMatchUsersDetailsModel
        {
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string email { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

    }
}