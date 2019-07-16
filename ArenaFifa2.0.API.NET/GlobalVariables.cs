using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET
{
    public static class GlobalVariables
    {
        public static string STAGE_QUALIFY2 = "-2";
        public static string STAGE_QUALIFY1 = "-1";
        public static string STAGE_TEAM_TABLE = "0";
        public static string STAGE_SECOND_STAGE = "1";
        public static string STAGE_ROUND_16 = "2";
        public static string STAGE_QUARTER_FINAL = "3";
        public static string STAGE_SEMI_FINAL = "4";
        public static string STAGE_FINAL = "5";

        public static string DATABASE_NAME_ONLINE = "Connection.Database.Online";
        public static string DATABASE_NAME_STAGING = "Connection.Database.Staging";

        public static int GENERATE_NEWSEASON_ITEM_TYPE_TEAM = 1;
        public static int GENERATE_NEWSEASON_ITEM_TYPE_COACH = 2;
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_ALLSERIES = "SERIE_A,SERIE_B,SERIE_C,SERIE_D";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_SERIEA = "SERIE_A";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_SERIEB = "SERIE_B";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_SERIEC = "SERIE_C";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_SERIED = "SERIE_D";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_CHAMPIONS_LEAGUE = "CHAMPLG";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_EUROPE_LEAGUE = "EUROPLG";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_UEFA_CUP = "UEFACUP";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_WORLD_CUP = "WORLDCP";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_EURO_CUP = "EUROCUP";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_SUPER_CUP = "SUPERCP";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_FUT_CUP = "FUT-CUP";
        public static string GENERATE_NEWSEASON_CHAMPIONSHIP_PRO_CUP = "PRO-CUP";
    }

}