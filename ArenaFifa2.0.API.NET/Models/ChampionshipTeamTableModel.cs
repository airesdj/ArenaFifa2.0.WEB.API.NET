using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class ChampionshipTeamTableModel
    {
        public class ChampionshipTeamTableListViewModel
        {
            public List<ChampionshipTeamTableDetailsModel> listOfTeamTable { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class ChampionshipTeamTableDetailsModel
        {
            public int championshipID { get; set; }
            public int teamID { get; set; }
            public int groupID { get; set; }
            public int totalPlayed { get; set; }
            public int totalPoint { get; set; }
            public int totalWon { get; set; }
            public int totalDraw { get; set; }
            public int totalLost { get; set; }
            public int totalGoalsFOR { get; set; }
            public int totalGoalsAGainst { get; set; }
            public int orden { get; set; }
            public string teamName { get; set; }
            public string teamURL { get; set; }
            public string teamType { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public int deletedCurrentSeason { get; set; }
            public int previousPosition { get; set; }
            public string actionUser { get; set; }
        }

    }
}