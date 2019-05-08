using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class BenchModel
    {
        public class BenchModesViewModel
        {
            public List<BenchDetailsModel> listOfBench { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class BenchDetailsModel
        {
            public int id { get; set; }
            public int userID { get; set; }
            public string psnID { get; set; }
            public string name { get; set; }
            public string state { get; set; }
            public string team { get; set; }
            public DateTime dateStarted { get; set; }
            public DateTime dateFinished { get; set; }
            public string console { get; set; }
            public string typeBench { get; set; }
        }

        public class SubscribeBench
        {
            public int id { get; set; }
            public bool checkH2H { get; set; }
            public bool checkFUT { get; set; }
            public bool checkPRO { get; set; }
            public string teamNameFUT { get; set; }
            public string teamNamePRO { get; set; }
            public string ddd { get; set; }
            public string mobile { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}