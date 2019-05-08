using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class UserLoginModel
    {
        public int id { get; set; }
        public string psnID { get; set; }
        public string current_password { get; set; }
        public string password { get; set; }
        public string confirm_password { get; set; }

        public string name { get; set; }
        public bool userActive { get; set; }
        public bool userModerator { get; set; }
        public string email { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{dd/MM/yyyy}")]
        public DateTime birthday { get; set; }

        public string state { get; set; }
        public string howfindus { get; set; }
        public string whathowfindus { get; set; }
        public string team { get; set; }
        public bool inEmailWarning { get; set; }
        public bool inEmailTeamTable { get; set; }
        public bool inParticipate { get; set; }

        public string psnRegister { get; set; }
        public string psnOperation { get; set; }
        public int idUserOperation { get; set; }

        public string actionUser { get; set; }
        public string returnMessage { get; set; }
    }


    public class UserModel
    {
        public int id { get; set; }
        public string psnID { get; set; }
        public string name { get; set; }
        public string password { get; set; }
        public string password20 { get; set; }
        public bool userActive { get; set; }
        public bool userModerator { get; set; }
        public string email { get; set; }

        [DataType(DataType.DateTime)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{dd/MM/yyyy hh:mm:ss}")]
        public DateTime lastAccess { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{dd/MM/yyyy}")]
        public DateTime birthday { get; set; }

        public string state { get; set; }
        public string howfindus { get; set; }
        public string whatkindofmedia { get; set; }
        public string team { get; set; }
        public byte receiveWarningEachRound { get; set; }
        public byte receiveTeamTable { get; set; }
        public byte wishParticipate { get; set; }

        [DataType(DataType.DateTime)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{dd/MM/yyyy hh:mm:ss}")]
        public DateTime register { get; set; }

        public string linkLiveMatch { get; set; }

        [DataType(DataType.DateTime)]
        [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{dd/MM/yyyy hh:mm:ss}")]
        public DateTime lastUpdate { get; set; }

        public string psnIDLastUpdate { get; set; }
        public string passwordManager { get; set; }
        public string passwordManager20 { get; set; }
        public string workEmail { get; set; }
        public string codeArea { get; set; }
        public string mobileNumber { get; set; }
        public string returnMessage { get; set; }
        public string currentTeam { get; set; }
        public int totalTitlesWon { get; set; }
        public int totalVices { get; set; }
    }

    public class RankingSupportersModel
    {
        public List<SupportesTeamModel> listSupportesTeam { get; set; }
        public string dtUpdateFormated { get; set; }
        public int totalUser { get; set; }
        public string actionUser { get; set; }
        public string returnMessage { get; set; }
    }

    public class SupportesTeamModel
    {
        public string teamName { get; set; }
        public int total { get; set; }
    }

    public class UserViewModel
    {
        public List<UserDetailsModel> listOfUser { get; set; }
        public string actionUser { get; set; }
        public string returnMessage { get; set; }
    }

    public class UserDetailsModel
    {
        public int id { get; set; }
        public string psnID { get; set; }
        public string name { get; set; }
        public string state { get; set; }
    }

}