using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class SpoolerModel
    {
        public class SpoolerViewModel
        {
            public int id { get; set; }
            public int championshipID { get; set; }
            public int totalSentEmails { get; set; }
            public string typeProcess { get; set; }
            public string descriptionProcess { get; set; }
            public int userIDResponsible { get; set; }
            public string nextTimeProcessSpooler { get; set; }
            public List<SpoolerTypeModel> listSpoolerInProgress { get; set; }
            public List<SpoolerTypeModel> listSpoolerWaiting { get; set; }
            public List<SpoolerTypeModel> listSpoolerFinished { get; set; }
            public List<SpoolerTypeModel> listSpoolerAdmin { get; set; }
            public List<SpoolerDetailModel> listSpoolerDetails { get; set; }
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
            public string championshipName { get; set; }
            public int matchID { get; set; }
            public int stageID { get; set; }
            public int roundID { get; set; }
            public string frequency { get; set; }
            public string timeProcess { get; set; }
            public Boolean activeProcess { get; set; }
            public string dateFormattedLastProcessing { get; set; }
            public Boolean processedToday { get; set; }
        }


        public class SpoolerDetailModel
        {
            public int id { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string email { get; set; }
            public string currentTeamName { get; set; }
            public int sequenceID { get; set; }
            public DateTime dt_execution { get; set; }
            public string hr_execution { get; set; }
            public int championshipID { get; set; }
            public string championshipName { get; set; }
            public int seasonID { get; set; }
            public Boolean isModerator { get; set; }
            public int blogID { get; set; }
            public DateTime dt_Blog { get; set; }
            public int moderatorID { get; set; }
            public string title { get; set; }
            public int inCoach { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

    }
}