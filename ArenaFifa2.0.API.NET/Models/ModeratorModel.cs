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


        public class SpoolerViewModel
        {
            public string nextTimeProcessSpooler { get; set; }

            public List<SpoolerTypeModel> listSpoolerInProgress { get; set; }
            public List<SpoolerTypeModel> listSpoolerWaiting{ get; set; }
            public List<SpoolerTypeModel> listSpoolerFinished { get; set; }
            public List<SpoolerTypeModel> listSpoolerAdmin { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class SpoolerTypeModel
        {
            public int id { get; set; }
            public string description { get; set; }
            public string initials { get; set; }
            public DateTime dt_create { get; set; }
            public string hr_create { get; set; }
            public int totalEmails { get; set; }
            public int totalEmailsSent { get; set; }
            public int totalEmailsMissingSend { get; set; }
            public DateTime dt_last_sent { get; set; }
            public string hr_last_sent { get; set; }
            public DateTime dt_end_process { get; set; }
            public string hr_end_process { get; set; }
            public string psnID { get; set; }
            public int seasonID { get; set; }
            public int championshipID { get; set; }
            public int matchID { get; set; }
            public int stageID { get; set; }
            public int roundID { get; set; }
            public string championshipName { get; set; }
            public string frequency { get; set; }
            public string timeProcess { get; set; }
            public Boolean activeProcess { get; set; }
            public string dateFormattedLastProcessing { get; set; }
            public Boolean processedToday { get; set; }
        }

    }
}