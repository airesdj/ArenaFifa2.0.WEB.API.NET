using System;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Models
{
    public class GenerateNewSeasonModel
    {
        public class GenerateNewSeasonViewModel
        {
            public GenerateNewSeasonDetailsModel newSeasonModel { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class GenerateNewSeasonDetailsModel
        {
            public int seasonID { get; set; }
            public string seasonName { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public DateTime drawDate { get; set; }
            public string modeType { get; set; }
            public string championshipType { get; set; }
            public int itemID { get; set; }
            public int poteNumber { get; set; }
            public string itemName { get; set; }

            public List<StandardGenerateNewSeasonChampionshipLeagueDetailsModel> listChampionshipLeagueDetails { get; set; }
            public List<StandardGenerateNewSeasonChampionshipCupDetailsModel> listChampionshipCupDetails { get; set; }
            public List<GenerateNewSeasonStandardDetailsModel> listOfTeams { get; set; }
            public List<GenerateNewSeasonStandardDetailsModel> listOfPots { get; set; }
            public GenerateNewSeasonGenerateModel newSeasonModel { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class StandardGenerateNewSeasonChampionshipLeagueDetailsModel
        {
            public string modeType { get; set; }
            public string championshipType { get; set; }
            public DateTime startDate { get; set; }
            public int totalTeams { get; set; }
            public int totalDaysToPlayStage0 { get; set; }
            public int totalDaysToPlayPlayoff { get; set; }
            public int totalRelegate { get; set; }
            public Boolean hasChampionship { get; set; }
            public int championshipID { get; set; }
            public Boolean championship_ByGroup { get; set; }
            public int totalGroups { get; set; }
            public Boolean championship_byGroupPots { get; set; }
            public Boolean championship_DoubleRound { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class StandardGenerateNewSeasonChampionshipCupDetailsModel
        {
            public string modeType { get; set; }
            public string championshipType { get; set; }
            public DateTime startDate { get; set; }
            public int totalTeams { get; set; }
            public int totalDaysToPlayStage0 { get; set; }
            public int totalDaysToPlayPlayoff { get; set; }
            public Boolean hasChampionship { get; set; }
            public int championshipID { get; set; }
            public Boolean championship_ByGroup { get; set; }
            public int totalGroups { get; set; }
            public Boolean hasJust_SerieA { get; set; }
            public Boolean hasJust_SerieB { get; set; }
            public Boolean hasJust_SerieC { get; set; }
            public Boolean has_SerieA_B { get; set; }
            public Boolean has_SerieA_B_C { get; set; }
            public Boolean has_SerieA_B_C_D { get; set; }
            public Boolean has_NationalTeams { get; set; }
            public int totalTeamsPreCup { get; set; }
            public Boolean championship_byGroupPots { get; set; }
            public Boolean hasChampionshipDestiny { get; set; }
            public Boolean hasChampionshipSource { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class GenerateNewSeasonStandardDetailsModel
        {
            public string modeType { get; set; }
            public string championshipType { get; set; }
            public int typeStandard { get; set; }
            public int id { get; set; }
            public string name { get; set; }
            public string psnID { get; set; }
            public int poteNumber { get; set; }
            public string typeItem { get; set; }
        }


        public class GenerateNewSeasonGenerateModel
        {
            public Boolean bkpIsDone { get; set; }
            public Boolean NewSeasonIsGenerated { get; set; }
            public Boolean DatabasesLookTheSame { get; set; }
            public int currentSeasonID { get; set; }
            public int seasonID { get; set; }
            public string seasonName { get; set; }
            public DateTime startDate { get; set; }
            public DateTime endDate { get; set; }

            //before the new season generation
            public Boolean preparationBkpDatabaseIsDone { get; set; }
            public Boolean preparationCommentDatabaseIsDone { get; set; }
            public Boolean validationSquadOfProClubIsDone { get; set; }
            public Boolean calculateEndOfSeasonIsDone { get; set; }

            //generate new season
            public Boolean serieAIsGenerated_H2H { get; set; }
            public int serieAID_H2H { get; set; }
            public Boolean serieBIsGenerated_H2H { get; set; }
            public int serieBID_H2H { get; set; }
            public Boolean serieCIsGenerated_H2H { get; set; }
            public int serieCID_H2H { get; set; }
            public Boolean hasSerieD_H2H { get; set; }
            public Boolean serieDIsGenerated_H2H { get; set; }
            public int serieDID_H2H { get; set; }

            public Boolean rellocationOfSeries_H2H { get; set; }

            public Boolean hasWorldCup { get; set; }
            public Boolean worldCupIsGenerated { get; set; }
            public int worldCupID_H2H { get; set; }
            public Boolean hasEuroCup { get; set; }
            public Boolean euroCupIsGenerated { get; set; }
            public int euroCupID_H2H { get; set; }

            public Boolean championsLeagueIsGenerated { get; set; }
            public int championsLeagueID { get; set; }
            public Boolean hasEuropeLeague { get; set; }
            public Boolean europeLeagueIsGenerated { get; set; }
            public int europeLeagueID { get; set; }
            public Boolean uefaCupIsGenerated { get; set; }
            public int uefaCupID { get; set; }


            public Boolean serieAIsGenerated_FUT { get; set; }
            public int serieAID_FUT { get; set; }
            public Boolean hasSerieB_FUT { get; set; }
            public Boolean serieBIsGenerated_FUT { get; set; }
            public int serieBID_FUT { get; set; }
            public Boolean futCupIsGenerated { get; set; }
            public int futCupID { get; set; }

            public Boolean serieAIsGenerated_PRO { get; set; }
            public int serieAID_PRO { get; set; }
            public Boolean hasSerieB_PRO { get; set; }
            public Boolean serieBIsGenerated_PRO { get; set; }
            public int serieBID_PRO { get; set; }
            public Boolean proCupIsGenerated { get; set; }
            public int proCupID { get; set; }

            public Boolean maintenanceOfBenchIsDone { get; set; }
            public Boolean tableOfClashesIsDone { get; set; }
            public Boolean purgingOfSystemTablesIsDone { get; set; }

            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

    }
}