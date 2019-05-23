using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ArenaFifa20.API.NET.Models
{
    public class BlogModel
    {
        public class BlogListViewModel
        {
            public int id { get; set; }
            public int userID { get; set; }
            public List<BlogDetailsModel> listOfBlog{ get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }

        public class BlogDetailsModel
        {
            public int id { get; set; }
            public int userID { get; set; }
            public string userName { get; set; }
            public string psnID { get; set; }
            public string title { get; set; }
            public DateTime registerDate { get; set; }
            public String registerDateFormatted { get; set; }
            public double registerDateTimeFormatted { get; set; }
            public string registerTime { get; set; }
            public string text { get; set; }
            public string actionUser { get; set; }
            public string returnMessage { get; set; }
        }


    }
}