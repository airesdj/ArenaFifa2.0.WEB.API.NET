using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class HallOfFameModel
    {
        public class SummaryViewModel
        {
            public string psnIDSerieAH2H { get; set; }
            public string teamIDSerieAH2H { get; set; }
            public string psnIDSerieAFUT { get; set; }
            public string teamIDSerieAFUT { get; set; }
            public string psnIDSerieAPRO { get; set; }
            public string teamIDSerieAPRO { get; set; }
            public string psnIDCDM { get; set; }
            public string teamIDCDM { get; set; }
            public string psnIDUCL { get; set; }
            public string teamIDUCL { get; set; }
            public string psnIDSCP { get; set; }
            public string teamIDSCP { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipScoreViewModel
        {
            public List<ChampionshipTypeModel> listChampionshipScore { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipTypeModel
        {
            public string championshipType { get; set; }
            public int scoreChampion { get; set; }
            public int scoreVice { get; set; }
            public int scoreSemi { get; set; }
            public int scoreQuarter { get; set; }
            public int scoreRound16 { get; set; }
            public int scoreQualifyNextStage { get; set; }
            public int score2ndStage { get; set; }
            public int scoreWins { get; set; }
            public int scoreDraws { get; set; }
        }

        public class GeneralBlackListViewModel
        {
            public List<GeneralBlackListModel> listBlackList { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class GeneralBlackListModel
        {
            public string psnID { get; set; }
            public string userName { get; set; }
            public int total { get; set; }
            public int totalPreviousSeason { get; set; }
        }

        public class AchievementViewModel
        {
            public List<AchievementModel> listOfAchievement { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class AchievementModel
        {
            public string championshipType { get; set; }
            public Boolean inGroup { get; set; }
            public string userName { get; set; }
            public string seasonName { get; set; }
            public string teamName { get; set; }
        }
    }
}