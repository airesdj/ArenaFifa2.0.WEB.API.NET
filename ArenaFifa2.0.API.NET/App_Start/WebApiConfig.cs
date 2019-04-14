using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;

namespace ArenaFifa20.API.NET
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );

            config.Routes.MapHttpRoute(
                name: "DefaultApiPsnID",
                routeTemplate: "api/{controller}/{psnID}",
                defaults: new { psnID = RouteParameter.Optional }
            );

            config.Routes.MapHttpRoute(
                name: "DefaultApiWithActionAndPsnID",
                routeTemplate: "api/{controller}/{action}/{psnID}",
                defaults: new { psnID = RouteParameter.Optional }
            );

        }
    }
}
