using System;
using System.Collections.Generic;

namespace ArenaFifa20.API.NET.Models
{
    public class GenerateNewSeasonModel
    {
        public class GenerateNewSeasonViewModel
        {
            public newSeasonDetailsModel newSeasonModel { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class newSeasonDetailsModel
        {
            public int seasonID { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public DateTime drawDate { get; set; }

            /* H2H CHAMPIONSHIPS DETAILS */

            public List<StandardDetailsModel> listOfTeamsH2H_SerieA { get; set; }
            public DateTime startDateH2H_SerieA { get; set; }
            public int totalDaysToPlayStage0H2H_SerieA { get; set; }
            public int totalDaysToPlayPlayoffH2H_SerieA { get; set; }
            public Boolean hasRelegateH2H_SerieA { get; set; }
            public Boolean hasChampionshipH2H_SerieA { get; set; }
            public int championshipIDH2H_SerieA { get; set; }

            public List<StandardDetailsModel> listOfTeamsH2H_SerieB { get; set; }
            public DateTime startDateH2H_SerieB { get; set; }
            public int totalDaysToPlayStage0H2H_SerieB { get; set; }
            public int totalDaysToPlayPlayoffH2H_SerieB { get; set; }
            public Boolean hasRelegateH2H_SerieB { get; set; }
            public Boolean hasChampionshipH2H_SerieB { get; set; }
            public int championshipIDH2H_SerieB { get; set; }

            public List<StandardDetailsModel> listOfTeamsH2H_SerieC { get; set; }
            public DateTime startDateH2H_SerieC { get; set; }
            public int totalDaysToPlayStage0H2H_SerieC { get; set; }
            public int totalDaysToPlayPlayoffH2H_SerieC { get; set; }
            public Boolean hasRelegateH2H_SerieC { get; set; }
            public Boolean hasChampionshipH2H_SerieC { get; set; }
            public int championshipIDH2H_SerieC { get; set; }

            public List<StandardDetailsModel> listOfTeamsH2H_SerieD { get; set; }
            public DateTime startDateH2H_SerieD { get; set; }
            public int totalDaysToPlayStage0H2H_SerieD { get; set; }
            public int totalDaysToPlayPlayoffH2H_SerieD { get; set; }
            public Boolean hasRelegateH2H_SerieD { get; set; }
            public Boolean hasChampionshipH2H_SerieD { get; set; }
            public int championshipIDH2H_SerieD { get; set; }


            public List<StandardDetailsModel> listOfTeams_WorldCup { get; set; }
            public DateTime startDate_WorldCup { get; set; }
            public int totalDaysToPlayStage0_WorldCup { get; set; }
            public int totalDaysToPlayPlayoff_WorldCup { get; set; }
            public Boolean hasRelegate_WorldCup { get; set; }
            public Boolean hasChampionship_WorldCup { get; set; }
            public int championshipID_WorldCup { get; set; }
            public Boolean WorldCup_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_WorldCup { get; set; }


            public Boolean ChampionsLeague_hasJust_H2HSerieA { get; set; }
            public Boolean ChampionsLeague_has_H2HSerieA_B { get; set; }
            public Boolean ChampionsLeague_has_H2HSerieA_B_C { get; set; }
            public DateTime startDateChampionsLeague { get; set; }
            public int totalDaysToPlayStage0ChampionsLeague { get; set; }
            public int totalDaysToPlayPlayoffChampionsLeague { get; set; }
            public Boolean hasChampionshipChampionsLeague { get; set; }
            public int championshipIDChampionsLeague { get; set; }
            public Boolean ChampionsLeague_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_ChampionsLeague { get; set; }

            public Boolean EuropeLeague_hasJust_H2HSerieC { get; set; }
            public Boolean EuropeLeague_has_H2HSerieB_C { get; set; }
            public Boolean EuropeLeague_has_H2HSerieB_C_D { get; set; }
            public Boolean EuropeLeague_has_H2HSerieC_D { get; set; }
            public DateTime startDateEuropeLeague { get; set; }
            public int totalDaysToPlayStage0EuropeLeague { get; set; }
            public int totalDaysToPlayPlayoffEuropeLeague { get; set; }
            public Boolean haschampionshipEuropeLeague { get; set; }
            public int championshipIDEuropeLeague { get; set; }
            public Boolean EuropeLeague_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_EuropeLeague { get; set; }

            public Boolean UefaCup_has_H2HSerieA_B { get; set; }
            public Boolean UefaCup_has_H2HSerieA_B_C { get; set; }
            public Boolean UefaCup_has_H2HSerieA_B_C_D { get; set; }
            public DateTime startDateUefaCup { get; set; }
            public int totalDaysToPlayPlayoffUefaCup { get; set; }
            public Boolean hasChampionshipUefaCup { get; set; }
            public int championshipIDUefaCup { get; set; }
            public int totalTeamsPreCup_UefaCup { get; set; }

            /* FUT CHAMPIONSHIPS DETAILS */

            public DateTime startDateFUT_SerieA { get; set; }
            public int totalDaysToPlayStage0FUT_SerieA { get; set; }
            public int totalDaysToPlayPlayoffFUT_SerieA { get; set; }
            public Boolean hasRelegateFUT_SerieA { get; set; }
            public Boolean hasChampionshipFUT_SerieA { get; set; }
            public int championshipIDFUT_SerieA { get; set; }
            public Boolean championshipFUT_SerieA_ByGroup { get; set; }
            public int FUT_SerieA_TotalGroup { get; set; }
            public Boolean FUT_SerieA_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_FUT_SerieA { get; set; }

            public DateTime startDateFUT_SerieB { get; set; }
            public int totalDaysToPlayStage0FUT_SerieB { get; set; }
            public int totalDaysToPlayPlayoffFUT_SerieB { get; set; }
            public Boolean hasRelegateFUT_SerieB { get; set; }
            public Boolean hasChampionshipFUT_SerieB { get; set; }
            public int championshipIDFUT_SerieB { get; set; }
            public Boolean championshipFUT_SerieB_ByGroup { get; set; }
            public int FUT_SerieB_TotalGroup { get; set; }
            public Boolean FUT_SerieB_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_FUT_SerieB { get; set; }

            public Boolean FUTCup_hasJust_H2HSerieA { get; set; }
            public Boolean FUTCup_has_H2HSerieA_B { get; set; }
            public DateTime startDateFUTCup { get; set; }
            public int totalDaysToPlayPlayoffFUTCup { get; set; }
            public Boolean hasChampionshipFUTCup { get; set; }
            public int championshipIDFUTCup { get; set; }
            public int totalTeamsPreCup_FUTCup { get; set; }

            /* PRO CHAMPIONSHIPS DETAILS */

            public DateTime startDatePRO_SerieA { get; set; }
            public int totalDaysToPlayStage0PRO_SerieA { get; set; }
            public int totalDaysToPlayPlayoffPRO_SerieA { get; set; }
            public Boolean hasRelegatePRO_SerieA { get; set; }
            public Boolean hasChampionshipPRO_SerieA { get; set; }
            public int championshipIDPRO_SerieA { get; set; }
            public Boolean championshipPRO_SerieA_ByGroup { get; set; }
            public int PRO_SerieA_TotalGroup { get; set; }
            public Boolean PRO_SerieA_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_PRO_SerieA { get; set; }

            public DateTime startDatePRO_SerieB { get; set; }
            public int totalDaysToPlayStage0PRO_SerieB { get; set; }
            public int totalDaysToPlayPlayoffPRO_SerieB { get; set; }
            public Boolean hasRelegatePRO_SerieB { get; set; }
            public Boolean hasChampionshipPRO_SerieB { get; set; }
            public int championshipIDPRO_SerieB { get; set; }
            public Boolean championshipPRO_SerieB_ByGroup { get; set; }
            public int PRO_SerieB_TotalGroup { get; set; }
            public Boolean PRO_SerieB_byGroupPots { get; set; }
            public List<StandardDetailsModel> listOfPots_PRO_SerieB { get; set; }

            public Boolean PROCup_hasJust_H2HSerieA { get; set; }
            public Boolean PROCup_has_H2HSerieA_B { get; set; }
            public DateTime startDatePROCup { get; set; }
            public int totalDaysToPlayPlayoffPROCup { get; set; }
            public Boolean hasChampionshipPROCup { get; set; }
            public int championshipIDPROCup { get; set; }
            public int totalTeamsPreCup_PROCup { get; set; }

            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class StandardDetailsModel
        {
            public int id { get; set; }
            public string name { get; set; }
            public string psnID { get; set; }
        }

    }
}