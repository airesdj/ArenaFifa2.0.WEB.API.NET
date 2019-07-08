using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class AcceptingNewSeasonModel
    {
        public class AcceptingNewSeasonViewModel
        {
            public string primaryKey { get; set; }
            public int seasonID { get; set; }
            public int userID { get; set; }
            public int championshipID { get; set; }
            public string confirmation { get; set; }
            public string teamName { get; set; }
            public string ordering { get; set; }
            public string dataBaseName { get; set; }
            public List<AcceptingDetails> listOfAccepting { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class AcceptingDetails
        {
            public string primaryKey { get; set; }
            public int seasonID { get; set; }
            public int userID { get; set; }
            public int championshipID { get; set; }
            public string seasonName { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string championshipName { get; set; }
            public string confirmation { get; set; }
            public string confirmationDescription { get; set; }
            public DateTime Dateconfirmation { get; set; }
            public string DateconfirmationFormatted { get; set; }
            public string teamName { get; set; }
            public string console { get; set; }
            public string statusID { get; set; }
            public string statusDescription { get; set; }
            public int teamPROID { get; set; }
            public string ordering { get; set; }
            public string ddd { get; set; }
            public string mobileNumber { get; set; }
            public Boolean uploadTeamLogo { get; set; }
            public int totalPoints { get; set; }
            public int totalBlackList { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}