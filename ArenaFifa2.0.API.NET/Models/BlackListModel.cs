using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class BlackListModel
    {
        public class BlackListViewModel
        {
            public int seasonID { get; set; }
            public int userID { get; set; }
            public string psnID { get; set; }
            public string nameUser { get; set; }
            public string seasonName { get; set; }
            public List<BlackListSummary> listSummary { get; set; }
            public List<BlackListDetails> listDetails { get; set; }
            public string dtUpdateFormated { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class BlackListSummary
        {
            public int userID { get; set; }
            public string psnID { get; set; }
            public string nameUser { get; set; }
            public int noWarning { get; set; }
            public int noTotalOmission { get; set; }
            public int noPartialOmission { get; set; }
            public int noUnsportsmanlike { get; set; }
            public int total { get; set; }
        }

        public class BlackListDetails
        {
            public int championshipID { get; set; }
            public string championshipName { get; set; }
            public string stageName { get; set; }
            public string typeMode { get; set; }
            public int roundID { get; set; }
            public int matchID { get; set; }
            public int noWarning { get; set; }
            public int noTotalOmission { get; set; }
            public int noPartialOmission { get; set; }
            public int noUnsportsmanlike { get; set; }
            public int valueBlackList { get; set; }
            public DateTime dtUpdate { get; set; }
        }


    }
}