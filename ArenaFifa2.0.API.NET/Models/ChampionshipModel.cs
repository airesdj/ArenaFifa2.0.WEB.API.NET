using System;
using System.Collections.Generic;
using static ArenaFifa20.API.NET.Models.ChampionshipTeamModel;
using static ArenaFifa20.API.NET.Models.ChampionshipUserModel;
using static ArenaFifa20.API.NET.Models.ChampionshipStageModel;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipModel
    {
        public class ChampionshipListViewModel
        {
            public int id { get; set; }
            public List<ChampionshipDetailsModel> listOfChampionship{ get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipDetailsModel
        {
            public int id { get; set; }
            public int seasonID { get; set; }
            public string name { get; set; }
            public int totalTeam { get; set; }
            public DateTime startDate { get; set; }
            public String startDateFormatted { get; set; }
            public DateTime drawDate { get; set; }
            public String drawDateFormatted { get; set; }
            public Boolean active { get; set; }
            public Boolean forGroup { get; set; }
            public Boolean twoTurns { get; set; }
            public Boolean justOneTurn { get; set; }
            public int totalGroup { get; set; }
            public Boolean playoff { get; set; }
            public Boolean twoLegs { get; set; }
            public int totalQualify { get; set; }
            public int totalRelegation { get; set; }
            public int totalDayStageOne { get; set; }
            public int totalDayStagePlayoff { get; set; }
            public string type { get; set; }
            public string typeName { get; set; }
            public string modeType { get; set; }
            public int totalQualifyNextStage { get; set; }
            public string console { get; set; }
            public DateTime lastUpdate { get; set; }
            public string psnIDUpdate { get; set; }
            public int totalTeamQualifyDivAbove { get; set; }
            public string stagePlayoffFormatted { get; set; }
            public int championshipDestiny { get; set; }
            public int championshipSource { get; set; }
            public int doubleRound { get; set; }
            public int userID1 { get; set; }
            public int userID2 { get; set; }
            public string userName1 { get; set; }
            public string userName2 { get; set; }
            public string psnID1 { get; set; }
            public string psnID2 { get; set; }
            public string teamName1 { get; set; }
            public string teamName2 { get; set; }
            public int started { get; set; }
            public int firstStageID { get; set; }
            public string seasonName { get; set; }
            public string listTeamsAdd { get; set; }
            public string listUsersAdd { get; set; }
            public string listStagesAdd { get; set; }
            public string listUsersStage2Add { get; set; }
            public string listTeamsStage0Add { get; set; }
            public List<ChampionshipTeamDetailsModel> listOfTeam { get; set; }
            public List<ChampionshipUserDetailsModel> listOfUser { get; set; }
            public List<ChampionshipStageDetailsModel> listOfStage { get; set; }
            public List<ChampionshipUserDetailsModel> listOfUserStage2 { get; set; }
            public List<ChampionshipTeamDetailsModel> listOfTeamStage0 { get; set; }
            public string stageID_Round { get; set; }
            public string psnOperation { get; set; }
            public int idUserOperation { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}