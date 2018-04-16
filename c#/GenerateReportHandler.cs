/******************************************************************************
*                  File :   GenerateReportHandler.cs
*           Description :   Loads report data  & Saves the Report  in specified format         
*   Classes in the Page :   GenerateReportHandler
*                  Auth :   Cognizant
*                  Date :   09/15/2016
*******************************************************************************
** Change History
*******************************************************************************
**Date:         Author:           Version:           Description:
**-----------   -------------     -----------        ------------------------
** 09/15/2016   Cognizant         1.0                Initial Development 
******************************************************************************/

using CrystalDecisions.CrystalReports.Engine;
using EMB_GenerateReports.DataAccess;
using EMB_GenerateReports.Entity;
using EMB_GenerateReports.Utility;
using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace EMB_GenerateReports
{
    public class ReportHandler
    {
        #region Properties

        /// <summary>
        /// Stores Report Details
        /// </summary>
        public Report ReportDetail { get; set; }

        #endregion

        #region Private Methods

        /// <summary>
        /// Saves the  Report to disk
        /// </summary>
        /// <param name="reportData">Report Data set</param>
        private void SaveReport(DataSet reportData)
        {
            FileFormat eformat = default(FileFormat);
            using (ReportDocument objReportDocument = new ReportDocument())
            {
                //Load the report 
                objReportDocument.Load(ReportDetail.CrystalReportPath);

                //Set Data source
                objReportDocument.SetDataSource(reportData);

                //set report parameters 
                foreach (var reportParameter in ReportDetail.Parameters)
                {
                    objReportDocument.SetParameterValue(reportParameter.Name, reportParameter.Value);
                }

                //Export to disk
                eformat = (FileFormat)Enum.Parse(typeof(FileFormat), ReportDetail.OutputFileFormat);
                switch (eformat)
                {
                    case FileFormat.Text:
                        objReportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.Text, ReportDetail.OutputFileName);
                        break;

                    case FileFormat.Excel:
                        objReportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.Excel, ReportDetail.OutputFileName);
                        break;

                    case FileFormat.Pdf:
                        objReportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, ReportDetail.OutputFileName);
                        break;
                    case FileFormat.Csv:
                        objReportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.CharacterSeparatedValues, ReportDetail.OutputFileName);
                        break;
                }
            }
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// Loads & Saves the EDI report
        /// </summary>
        public void LoadAndSaveReport()
        {
            string strMessage = string.Empty;
            ReportDataAccess objDataAccess = new ReportDataAccess(ReportDetail.DataSource.ConnectionString);
            using (DataSet dsReportData = new DataSet())
            {
                Logger.WriteMessageToConsole(Resources.ReportResource.LoadingData);

                //set data set name
                dsReportData.DataSetName = ReportDetail.DataSource.Name;

                //Load the dataset
                strMessage = objDataAccess.GetReportData(dsReportData, ReportDetail.DataSource.SourceTable);
                if (string.Compare(strMessage, Constants.Success, StringComparison.OrdinalIgnoreCase) != 0)
                {
                    throw new ArgumentException(strMessage);
                }
                Logger.WriteMessageToConsole(Resources.ReportResource.SavingReport);

                //Save the report to disk
                SaveReport(dsReportData);
            }
        }


        /// <summary>
        /// Validates and Load Report configuration
        /// </summary>
        /// <param name="configurationFile">Report configuration file</param>
        /// <param name="outputFileFormat">Ouput file format</param>
        /// <returns></returns>
        public bool ValidateAndLoadFile(string configurationFile, string outputFileFormat, string reportPath)
        {
            XDocument docReport = null;
            XmlSerializer szReport = null;
            XmlSchemaSet schemaSet = null;
            bool blnStatus = false;
            string strExtension = string.Empty;
            try
            {

                Logger.WriteMessageToConsole(string.Format(CultureInfo.InvariantCulture, Resources.ReportResource.ConfigurationValidationStarted, Environment.NewLine));

                //Load file
                docReport = XDocument.Load(configurationFile);

                schemaSet = new XmlSchemaSet();
                schemaSet.Add(null, Application.StartupPath + Constants.SchemaFile);
                schemaSet.Compile();

                //validate structure
                docReport.Validate(schemaSet, (o, e) =>
                {
                    throw new ArgumentException(e.Message);
                });

                //Load data into object
                szReport = new XmlSerializer(typeof(Report));
                ReportDetail = (Report)szReport.Deserialize(docReport.CreateReader());

                //validate file format
                strExtension = ((FileFormat)Enum.Parse(typeof(FileFormat), ReportDetail.OutputFileFormat)).GetDefaultValue();
                if (string.Compare(outputFileFormat, strExtension, false, CultureInfo.InvariantCulture) != 0)
                {
                    throw new ArgumentException(Resources.ReportResource.ReportFormatIncorrect);
                }

                //Check report exist in given path
                if (!File.Exists(Path.Combine(reportPath + ReportDetail.CrystalReportPath)))
                {
                    throw new ArgumentException(Resources.ReportResource.ReportFileNotExist);
                }
                ReportDetail.CrystalReportPath = Path.Combine(reportPath + ReportDetail.CrystalReportPath);

                //check refcursor out variable exist in DB Procedure
                if (ReportDetail.DataSource.SourceTable.Procedure.DatabaseParameters.Find(o => (
                                 (string.Compare(o.Direction, DatabaseParameterDirection.Output.ToString(), false, CultureInfo.InvariantCulture) == 0) &&
                                 (string.Compare(o.Type, ParameterDataType.RefCursor.ToString(), false, CultureInfo.InvariantCulture) == 0))) == null)
                {
                    throw new ArgumentException(Resources.ReportResource.RefCursorMissing);
                }


                blnStatus = true;
                Logger.WriteMessageToConsole(string.Format(CultureInfo.InvariantCulture, Resources.ReportResource.ConfigurationValidationCompleted, Environment.NewLine));
            }
            catch (Exception ex)
            {
                Logger.WriteErrorToConsole(Resources.ReportResource.ConfigurationError + ReportUsage(), ex);
            }
            finally
            {
                docReport = null;
                szReport = null;
            }
            return blnStatus;
        }

        /// <summary>
        /// Report Usage
        /// </summary>
        /// <returns></returns>
        private string ReportUsage()
        {

            StringBuilder sbUsage = new StringBuilder();
            sbUsage.AppendLine("");
            sbUsage.AppendLine("Report configuration file Usage :                                                                                      ");


            sbUsage.AppendLine("<? xml version = \"1.0\" encoding = \"utf-8\" ?>                                                                        ");
            sbUsage.AppendLine("<Report>                                                                                                                ");
            sbUsage.AppendLine("    <Name>{ Required - Report Name}</Name>                                                                              ");
            sbUsage.AppendLine("    <CrystalReport>{ Required - rpt file name with path} </CrystalReport>                                               ");
            sbUsage.AppendLine("    <OutputFileFormat>{ Required - Possible values are :'Text' or 'Pdf' or 'Excel'}</OutputFileFormat>                  ");
            sbUsage.AppendLine("    <Parameters>                                                                                                        ");
            sbUsage.AppendLine("                                                                                                                        ");
            sbUsage.AppendLine("        <!--0 - n Parameter can be added for report-->                                                                  ");
            sbUsage.AppendLine("        <Parameter name = '{Required  - Report Parameter Name}' value = '{Required  - Report Parameter Value}' />       ");
            sbUsage.AppendLine("                                                                                                                        ");
            sbUsage.AppendLine("    </Parameters>                                                                                                       ");
            sbUsage.AppendLine("                                                                                                                        ");
            sbUsage.AppendLine("    <DataSource name = '{Required  - Data Set name}' >                                                                  ");
            sbUsage.AppendLine("        <DataTable name = '{Required  - Data table Name (inside dataset)}' >                                            ");
            sbUsage.AppendLine("            <DBProcedure name = '{Required  - Procedure Name (to load datatable inside dataset)}' >                     ");
            sbUsage.AppendLine("                <Parameters>                                                                                            ");
            sbUsage.AppendLine("                                                                                                                        ");
            sbUsage.AppendLine("                     <!--1 - n Parameter can be added for procedure-->                                                  ");
            sbUsage.AppendLine("                    <Parameter name = '{Required attribute - Parameter name}'                                           ");
            sbUsage.AppendLine("                                type = '{Optional attribute -Data type .Possible values are Varchar2 or RefCursor}'     ");
            sbUsage.AppendLine("                                direction = '{Optional attribute -Possible values are Input or output }'                ");
            sbUsage.AppendLine("                                size = '{Optional attribute -Any integer specfying the length of the data type}'        ");
            sbUsage.AppendLine("                                value = '{Optional attribute -value for the parameter}' />                              ");
            sbUsage.AppendLine("                                                                                                                        ");
            sbUsage.AppendLine("                    <!--parameter of type = RefCursor and Direction = output is required -->                            ");
            sbUsage.AppendLine("                    <Parameter name = '{ref parameter name}' type = 'RefCursor' direction = 'Output' />                 ");
            sbUsage.AppendLine("                </Parameters>                                                                                           ");
            sbUsage.AppendLine("            </DBProcedure>                                                                                              ");
            sbUsage.AppendLine("        </DataTable>                                                                                                    ");
            sbUsage.AppendLine("    </DataSource>                                                                                                       ");
            sbUsage.AppendLine("</Report>                                                                                                               ");
            sbUsage.AppendLine("");
            sbUsage.AppendLine("");
            return sbUsage.ToString();
        }
        #endregion
    }
}
