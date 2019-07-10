using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using static ArenaFifa20.API.NET.Models.MyMatchesModel;

namespace ArenaFifa20.API.NET.Models
{
    public class GenerateRenewalModel
    {
        public class GenerateRenewalViewModel
        {
            public int seasonH2HID { get; set; }
            public string seasonH2HName { get; set; }
            public int seasonFUTID { get; set; }
            public string seasonFUTName { get; set; }
            public int seasonPROID { get; set; }
            public string seasonPROName { get; set; }
            public int totalUsersBcoOnLine { get; set; }
            public int totalUsersBcoStaging { get; set; }
            public int lastSeasonH2HID { get; set; }
            public string lastSeasonH2HName { get; set; }
            public int lastSeasonFUTID { get; set; }
            public string lastSeasonFUTName { get; set; }
            public int lastSeasonPROID { get; set; }
            public string lastSeasonPROName { get; set; }
            public string dataBaseName { get; set; }
            public int inRenewalWithWorldCup { get; set; }
            public int inRenewalWithEuro { get; set; }
            public Boolean databaseStagingPrepared { get; set; }
            public Boolean renewalNewSeasonGenerated { get; set; }
            public Boolean emailsSent { get; set; }
            public int totalUserRenewalForNextSeason { get; set; }
            public int totalEmailSpoolerForRenewal { get; set; }
            public int userActionID { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

    }
}