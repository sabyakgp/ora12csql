/******************************************************************************
*                  File :   Program.cs
*           Description :   To load and generate report       
*   Classes in the Page :   Program
*                  Auth :   Cognizant
*                  Date :   09/15/2016
*******************************************************************************
** Change History
*******************************************************************************
**Date:         Author:           Version:           Description:
**-----------   -------------     -----------        ------------------------
** 09/15/2016   Cognizant         1.0                Initial Development 
******************************************************************************/


using EMB_GenerateReports.Utility;
using System;
using System.Globalization;
using System.IO;

namespace EMB_GenerateReports
{
    class Program
    {
        [STAThread]
        static int Main(string[] args)
        {
            ReportHandler objReportHandler = null;
            ExecutionStatus exeStatus = ExecutionStatus.Success;
            ArgumentParser objArgumentParser = null;

            try
            {
                //Log application header
                Logger.WriteHeaderToConsole(Resources.ReportResource.GenerateReport);

                //Validate arguments
                objArgumentParser = new ArgumentParser();
                if (objArgumentParser.Parse(args))
                {
                    objReportHandler = new ReportHandler();

                    //Load and validate configuration file
                    if (objReportHandler.ValidateAndLoadFile(objArgumentParser.ConfigurationFile, Path.GetExtension(objArgumentParser.OutputFileName), objArgumentParser.ReportPath))
                    {
                        //set output file name &  connectionstring  tring
                        objReportHandler.ReportDetail.OutputFileName = objArgumentParser.OutputFileName;
                        objReportHandler.ReportDetail.DataSource.ConnectionString = objArgumentParser.ConnectionString;

                        //Load and save the report
                        Logger.WriteMessageToConsole(string.Format(CultureInfo.InvariantCulture, Resources.ReportResource.ReportGenerationStarted, Environment.NewLine,
                                                                                                                            objReportHandler.ReportDetail.Name));
                        objReportHandler.LoadAndSaveReport();
                        Logger.WriteMessageToConsole(string.Format(CultureInfo.InvariantCulture, Resources.ReportResource.ReportGenerationCompleted, objReportHandler.ReportDetail.Name,
                                                                                                                                Environment.NewLine));
                    }
                    else
                    {
                        exeStatus = ExecutionStatus.Failure;
                    }
                }
                else
                {
                    exeStatus = ExecutionStatus.Failure;
                }
            }
            catch (Exception ex)
            {
                Logger.WriteErrorToConsole(Resources.ReportResource.ReportGenerationError, ex);
                exeStatus = ExecutionStatus.Failure;
            }
            finally
            {
                //Log Application footer
                Logger.WriteFooterToConsole(exeStatus);
                objReportHandler = null;
            }
            return (Convert.ToInt32(exeStatus, CultureInfo.InvariantCulture));
        }
    }
}
