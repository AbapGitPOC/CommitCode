--******************************************************************************
--Version           : 1.0 
--WRIEF             : FIN_AFC_R0007
--Date              : 15-07-2022
--Requested by      : N/A 
--Developer         : INSMZ3
--Requirement       : Merge Profit & Loss Plan/Actual Reports and add features
--                    of CompanyCode Hierarchy, Currency Translations
--Logic             : Create a custom Analytical View similar to 
--                    C_ProfitLossPlanActQ2901    
--OData Service     : N/A
--TS Doc Link       : 
--FS Spec Link      : 
--Fiori App Link    : https://sapdd56.europe.shell.com:8556/sap/bc/ui2/flp?sap-client=110&sap-language=EN&appState=lean#ZGLACCOUNT-analyzePL?sap-ui-tech-hint=WDA
--TR/Charm ID       : D56K902240/8000004257
--******************************************************************************
@AbapCatalog.sqlViewName: 'ZZSFIPLPA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #PRIVILEGED_ONLY
@EndUserText.label: 'P&L - Plan/Actual'
@VDM.viewType: #CONSUMPTION
@Analytics.query: true

@Analytics.settings.maxProcessingEffort: #HIGH
@ClientHandling.algorithm: #SESSION_VARIABLE
@AbapCatalog.buffering.status: #NOT_ALLOWED
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.supportedCapabilities: [ #ANALYTICAL_QUERY ]
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.usageType.sizeCategory: #XXL
@ObjectModel.usageType.serviceQuality: #D
@ObjectModel.usageType.dataClass: #MIXED
define view zpl_github
with parameters 
@EndUserText.label: 'Fiscal Year'
@AnalyticsDetails.query.variableSequence: 28
@Consumption.derivation: { lookupEntity: 'I_CalendarDate',
        resultElement: 'CalendarYear', binding: [
        { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'P_KeyDate' } ] }
P_FiscalYear : calendaryear,
 
@EndUserText.label: 'Category'
@Consumption.defaultValue: 'PLN'
@AnalyticsDetails.query.variableSequence: 35
@Consumption.valueHelp: '_ACT01'
P_PlanningCategory : fcom_category,  
  
@Consumption.hidden: true
@Semantics.businessDate.at: true
@Environment.systemField: #SYSTEM_DATE
P_KeyDate    : vdm_v_key_date,

@EndUserText.label: 'Additional Category'
@Consumption.defaultValue: 'LE'
@AnalyticsDetails.query.variableSequence: 36
//@Consumption.valueHelp: '_ACT01'
 @Consumption.valueHelpDefinition: {
         entity: { name:    '/CFIN/BV_PlanningCategory', element: 'PlanningCategory' }}
P_ExtraCategory : fcom_category, 

@EndUserText.label: 'Analysis Currency'
@Consumption.defaultValue: 'EUR'
@AnalyticsDetails.query.variableSequence: 55
P_Currency : vdm_v_display_currency, 
  
@EndUserText.label: 'Exchange Rate Type'
@Consumption.defaultValue: 'AVG'
@AnalyticsDetails.query.variableSequence: 60
P_ExchangeRateType : kurst,  
  
@Consumption.hidden: true
@Environment.systemField: #SYSTEM_LANGUAGE
P_Language   : sylangu,
  
@Consumption.hidden: true
@Environment.systemField: #USER
P_BusinessUser: syuname,

@Consumption.hidden: true
@Consumption.derivation: { lookupEntity: 'I_UserSetGetParamForCtrlgArea', 
      resultElement: 'ControllingArea', 
      binding: [ { targetElement : 'BusinessUser' , type : #PARAMETER, value : 'P_BusinessUser' } ] }
@AnalyticsDetails.query.variableSequence: 5
P_ControllingArea: kokrs

//@Consumption.derivation: { lookupEntity: 'I_Ledger', 
//  resultElement: 'Ledger',
//  binding:
//  [ { targetElement : 'IsLeadingLedger' ,
//      type : #CONSTANT,
//      value : 'X'
//    }
//  ]
//}
//@Consumption.hidden: true
//@Consumption.defaultValue: '0L'
//@AnalyticsDetails.query.variableSequence: 10
///P_Ledger: fins_ledger

as select from I_ActualPlanJrnlEntryItemCube as I_ActualPlanJrnlEntryItemCube
//association [1..1] to /CFIN/BV_PlanningCategory      as _ACT01  on _ACT01.PlanningCategory = :P_PlanningCategory
{

------------------------------------------------------------------------------------------
-- ROWS
------------------------------------------------------------------------------------------

@AnalyticsDetails.query.variableSequence: 42
@EndUserText.label: 'GLAccount / GL Account Group'
@Consumption.filter: {  selectionType: #HIERARCHY_NODE, multipleSelections: true, mandatory: false,
                                      hierarchyBinding : [  { type: #USER_INPUT, value: 'GLAccountHierarchy', variableSequence: 41 } ] }
@AnalyticsDetails.query.displayHierarchy: #FILTER
@AnalyticsDetails.query.axis: #ROWS
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
GLAccount,
//_GLAccountInChartOfAccounts._Text[1:Language = $parameters.P_Language].GLAccountName,


------------------------------------------------------------------------------------------
-- FREE
------------------------------------------------------------------------------------------
@EndUserText.label: 'Activity Type'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
CostCtrActivityType,

@EndUserText.label: 'Business Transaction Type'
@AnalyticsDetails.query.variableSequence: 84
@Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
BusinessTransactionType,

@AnalyticsDetails.query.variableSequence: 83
@Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
BusinessTransactionCategory,

//@AnalyticsDetails.query.totals: #SHOW
//@AnalyticsDetails.query.display: 'Allocation Data'
//AllocData,

@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
CalendarMonth,
@AnalyticsDetails.query.display: #KEY_TEXT
CalendarQuarter,
@AnalyticsDetails.query.display: #KEY_TEXT
CalendarWeek,

@EndUserText.label: 'Fiscal Year'
@AnalyticsDetails.query.display: #KEY_TEXT
CalendarYear,

@Consumption.filter: { selectionType: #SINGLE, multipleSelections: false, mandatory: true, hidden: true }
@Consumption.derivation: { lookupEntity: 'I_ControllingArea', 
  resultElement: 'ChartOfAccounts',
  binding:
  [
    {
      targetElement : 'ControllingArea' ,
      type : #PARAMETER,
      value : 'P_ControllingArea'
    }
  ]
}
@AnalyticsDetails.query.variableSequence: 45
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
ChartOfAccounts,

@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.variableSequence: 40
@EndUserText.label: 'Company Code / Company Code Group'
@Consumption.filter: {  selectionType: #HIERARCHY_NODE, multipleSelections: true, mandatory: false,
                                      hierarchyBinding : [  { type: #USER_INPUT, value: 'CompanyCodeHierarchy', variableSequence: 39 } ] }
@AnalyticsDetails.query.displayHierarchy: #FILTER                                      
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
CompanyCode,

@AnalyticsDetails.query.totals: #SHOW
CompanyCodeCurrency,

@ObjectModel.foreignKey.association: '_ControllingArea'
ControllingArea,

@EndUserText.label: 'Department'
@AnalyticsDetails.query.axis: #FREE
@ObjectModel.foreignKey.association: '_ProfitCenter'
I_ActualPlanJrnlEntryItemCube._ProfitCenter.Department as Dept,


@AnalyticsDetails.query.axis: #FREE
//@ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'
I_ActualPlanJrnlEntryItemCube._GLAccountInChartOfAccounts._GLAccountType._GLAccountTypeText.GLAccountTypeName ,

@EndUserText.label: 'Cost Center'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
CostCenter,

@EndUserText.label: 'Unit of Measure'
@Semantics.unitOfMeasure:true
CostSourceUnit,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
Customer,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
@AnalyticsDetails.query.axis: #FREE
CustomerGroup,

@ObjectModel.foreignKey.association: '_CustomerSupplierCountry'
@EndUserText.label: 'Country'
@AnalyticsDetails.query.display: #KEY_TEXT
CustomerSupplierCountry,

@ObjectModel.foreignKey.association: '_CustomerSupplierCountry'
@EndUserText.label: 'Industry'
@AnalyticsDetails.query.display: #KEY_TEXT
CustomerSupplierIndustry,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
DistributionChannel,

@AnalyticsDetails.query.display: #KEY_TEXT
Division,

@EndUserText.label: 'Controlling Area D/C'
@AnalyticsDetails.query.axis: #FREE
ControllingDebitCreditCode,

@Consumption.filter: {selectionType: #RANGE, multipleSelections: true, mandatory:true }
//@Consumption.derivation: { lookupEntity: 'I_CalendarDate',
//        resultElement: 'CalendarMonth', binding: [
//        { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'P_KeyDate' } ] }
@AnalyticsDetails.query.variableSequence : 30
@AnalyticsDetails.query.display: #KEY_TEXT
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.totals: #SHOW
FiscalPeriod,


@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
FiscalQuarter,
@AnalyticsDetails.query.display: #KEY_TEXT
FiscalWeek,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
FiscalYearPeriod,

@AnalyticsDetails.query.display: #KEY_TEXT
FiscalYearWeek,

@AnalyticsDetails.query.display: #KEY_TEXT
FiscalYearVariant,

@EndUserText.label: 'Functional Area'
@AnalyticsDetails.query.display: #KEY_TEXT
@AnalyticsDetails.query.totals: #SHOW
FunctionalArea,

@AnalyticsDetails.query.totals: #SHOW
GlobalCurrency,

@AnalyticsDetails.query.variableSequence: 01
@Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: true }
@Consumption.derivation: { lookupEntity: 'I_Ledger', 
  resultElement: 'Ledger',
  binding:
  [ { targetElement : 'IsLeadingLedger' ,
      type : #CONSTANT,
      value : 'X'
    }
  ]
}
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
@Consumption.defaultValue: '0L'
Ledger,

//Due to performance removing Document number and line item
//@AnalyticsDetails.query.totals: #SHOW    
//AccountingDocument,     
//
//@AnalyticsDetails.query.totals: #SHOW
//LedgerGLLineItem, 

@EndUserText.label: 'Acc.Assignment Type'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
AccountAssignmentType, 

@EndUserText.label: 'Order'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
OrderID,

@EndUserText.label: 'Partn. Activity Type'
@AnalyticsDetails.query.totals: #SHOW
PartnerCostCtrActivityType,

@EndUserText.label: 'Partner Cost Center'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerCostCenter,

@AnalyticsDetails.query.totals: #SHOW
@EndUserText.label: 'Partn.Bus.Area'
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerBusinessArea,

@EndUserText.label: 'Partner Funct. Area'
@AnalyticsDetails.query.totals: #SHOW    
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerFunctionalArea,

@EndUserText.label: 'Partner Order Number'
@AnalyticsDetails.query.totals: #SHOW    
@AnalyticsDetails.query.axis: #FREE 
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerOrder,

@EndUserText.label: 'Partn. Profit Center'
@AnalyticsDetails.query.totals: #SHOW    
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerProfitCenter,

@EndUserText.label: 'Partner Project Def'
@AnalyticsDetails.query.totals: #SHOW    
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerProject,

@AnalyticsDetails.query.totals: #SHOW    
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerWBSElement,

@EndUserText.label: 'Category'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
PlanningCategory, 

@AnalyticsDetails.query.totals: #SHOW
PostingDate,          

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
Product, 

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
SoldProduct,

@EndUserText.label: 'Material'
@VDM.lifecycle.status:    #DEPRECATED
@VDM.lifecycle.successor: 'Product'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
Material,

@EndUserText.label: 'Material Group'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
MaterialGroup,

@AnalyticsDetails.query.variableSequence: 60
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
@AnalyticsDetails.query.axis: #FREE
ProfitCenter,

@EndUserText.label: 'Project Definition'
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
Project,

@EndUserText.label: 'Sales Order'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
SalesOrder,

@EndUserText.label: 'Sales Order Item'
@AnalyticsDetails.query.totals: #SHOW
SalesOrderItem,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
SalesOrganization,

@EndUserText.label: 'Sales District'
@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
SalesDistrict,

@AnalyticsDetails.query.variableSequence: 80
@Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
@AnalyticsDetails.query.totals: #SHOW
Segment,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
PartnerCompany, // = TradingPartner

TransactionCurrency,

@AnalyticsDetails.query.totals: #SHOW
@AnalyticsDetails.query.display: #KEY_TEXT
WBSElement,

@ObjectModel.foreignKey.association: '_BillingDocumentType'
@AnalyticsDetails.query.display: #KEY_TEXT
BillingDocumentType,

@AnalyticsDetails.query.display: #KEY_TEXT
YearMonth,
@AnalyticsDetails.query.display: #KEY_TEXT
YearQuarter,
@AnalyticsDetails.query.display: #KEY_TEXT
YearWeek,

@EndUserText.label: 'Partn.Co.Code'
PartnerCompanyCode,

@EndUserText.label: 'Partn.Segment'
PartnerSegment,

@EndUserText.label: 'Business Area'
@AnalyticsDetails.query.display: #KEY_TEXT
BusinessArea,

@EndUserText.label: 'Plant'
@AnalyticsDetails.query.display: #KEY_TEXT
Plant,

@EndUserText.label: 'Partn.Acc.Assignment.type'
PartnerAccountAssignmentType,

@EndUserText.label: 'Account Assignment'
AccountAssignment,

@AnalyticsDetails.query.variableSequence: 88
@EndUserText.label: 'Accounting Document Type'
@Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
@AnalyticsDetails.query.axis: #FREE
@AnalyticsDetails.query.display: #KEY_TEXT
AccountingDocumentType,  

@EndUserText.label: 'User'
UserName,

@EndUserText.label: 'Partn.Acc.Assignment'
PartAcctAssgmt,

@EndUserText.label: 'Additional UoM 1'
AdditionalUoM1,

@EndUserText.label: 'Additional UoM 2'
AdditionalUoM2,

@EndUserText.label: 'Additional UoM 3'
AdditionalUoM3,



------------------------------------------------------------------------------------------
-- Key Figures
------------------------------------------------------------------------------------------
//
// Transaction Currency: WSL
//
@EndUserText.label: 'Actual Amount in Trans Crcy'    
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
@AnalyticsDetails.query.axis: #COLUMNS
case when PlanningCategory = 'ACT01' then ActualAmountInTransactionCrcy 
                      else cast( 0 as fins_vkcur12)
end as ActualAmountInTransactionCrcy,

//@EndUserText.label: 'Plan Amount in Trans Crcy'    
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
@AnalyticsDetails.query.axis: #COLUMNS
@Consumption.dynamicLabel: { label: ' &1 Amount in Trans Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }                                                                                                        
case when PlanningCategory = :P_PlanningCategory then PlanAmountInTransactionCrcy 
                      else cast( '0' as fins_vhcur12)
end as PlanAmountInTransactionCrcy,
@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Addtl. Category Amount in Trans Crcy'    
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
@AnalyticsDetails.query.axis: #COLUMNS
@Consumption.dynamicLabel: { label: ' &1 Amount in Trans Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }                                                                                                                                   
case when PlanningCategory = :P_ExtraCategory then PlanAmountInTransactionCrcy 
                      else cast( '0' as fins_vhcur12)
end as ExtraAmtInTransactionCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Pln Amt in Trans Crcy'    
@Consumption.dynamicLabel: { label: ' Difference Act/&1 Amt in Trans Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }                                                                                                                                   
@DefaultAggregation : #FORMULA
@AnalyticsDetails.query.formula : '$projection.ActualAmountInTransactionCrcy - $projection.PlanAmountInTransactionCrcy'
1 as DifferenceAmtInTransCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Addtl. Amt. in Trans Crcy'    
@Consumption.dynamicLabel: { label: 'Difference Act/&1 Amt. in Trans Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }                                                                                                                                   
@DefaultAggregation : #FORMULA
@AnalyticsDetails.query.formula : '$projection.ActualAmountInTransactionCrcy - $projection.ExtraAmtInTransactionCrcy'
1 as DifferenceAmtActExtInTransCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Pln Amt in Trans Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Trans Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }                                                                                                                                   
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula : 'CASE WHEN $projection.ActualAmountInTransactionCrcy > 0 
                                   THEN ($projection.ActualAmountInTransactionCrcy - $projection.PlanAmountInTransactionCrcy) / $projection.ActualAmountInTransactionCrcy * 100 
                                   ELSE NDIV0(($projection.PlanAmountInTransactionCrcy - $projection.ActualAmountInTransactionCrcy ) / $projection.ActualAmountInTransactionCrcy) * 100 END'
1 as ActPlnTransCrcyDifferencePct,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Addtl. Amt in Trans Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Trans Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }                                                                                                                                   
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula : 'CASE WHEN $projection.ActualAmountInTransactionCrcy > 0 
                                   THEN ($projection.ActualAmountInTransactionCrcy - $projection.ExtraAmtInTransactionCrcy) / $projection.ActualAmountInTransactionCrcy * 100 
                                   ELSE NDIV0(($projection.ExtraAmtInTransactionCrcy - $projection.ActualAmountInTransactionCrcy ) / $projection.ActualAmountInTransactionCrcy) * 100 END'
1 as ActExtTransCrcyDifferencePct,

//
// Company Code Currency: HSL
//
@AnalyticsDetails.query.axis: #COLUMNS
@EndUserText.label: 'Actual Amount in Company Code Currency'    
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
case when PlanningCategory = 'ACT01' then ActualAmountInCompanyCodeCrcy 
                      else cast( 0 as fins_vhcur12)
end as ActualAmountInCompanyCodeCrcy,

@AnalyticsDetails.query.axis: #COLUMNS
//@EndUserText.label: 'Plan Amount in Company Code Crcy'    
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Company Code Crcy ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] } 
case when PlanningCategory = :P_PlanningCategory then PlanAmountInCompanyCodeCrcy 
                      else cast( '0' as fins_vhcur12)
end as PlanAmountInCompanyCodeCrcy,

@AnalyticsDetails.query.axis: #COLUMNS
//@EndUserText.label: 'Additional Amount in Company Code Currency'    
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Company Code Crcy ', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
case when PlanningCategory = :P_ExtraCategory then PlanAmountInCompanyCodeCrcy 
                      else cast( '0' as fins_vhcur12)
end as ExtAmountInCompanyCodeCrcy,

//@EndUserText.label: 'Difference Actual Plan in Company Code Crcy' 
@Consumption.dynamicLabel: { label: ' Difference Actual/&1 in Company Code Crcy ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }   
@DefaultAggregation : #FORMULA
@AnalyticsDetails.query.formula : '$projection.ActualAmountInCompanyCodeCrcy - $projection.PlanAmountInCompanyCodeCrcy'
1 as DifferenceAmtInCoCodeCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Addtl. Amt in Company Code Crcy'  
@Consumption.dynamicLabel: { label: ' Difference Actual/&1 Amt in Company Code Crcy ', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }   
@AnalyticsDetails.query.formula : '$projection.ActualAmountInCompanyCodeCrcy - $projection.ExtAmountInCompanyCodeCrcy'
0 as DiffAmtActExtInCoCCrcy,

//@EndUserText.label : 'Diff.(%) Act/Plan Amt in Company Code Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Company Code Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }   
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula : 'CASE WHEN $projection.ActualAmountInCompanyCodeCrcy > 0 
                                   THEN ($projection.ActualAmountInCompanyCodeCrcy - $projection.PlanAmountInCompanyCodeCrcy) / $projection.ActualAmountInCompanyCodeCrcy * 100 
                                   ELSE NDIV0(($projection.PlanAmountInCompanyCodeCrcy - $projection.ActualAmountInCompanyCodeCrcy ) / $projection.ActualAmountInCompanyCodeCrcy) * 100 END'
1 as CoCodeCrcyDifferencePct,

//@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Addtl. Amt in Company Code Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Company Code Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }   
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualAmountInCompanyCodeCrcy > 0 
                                   THEN ($projection.ActualAmountInCompanyCodeCrcy - $projection.ExtAmountInCompanyCodeCrcy) / $projection.ActualAmountInCompanyCodeCrcy * 100 
                                   ELSE NDIV0(($projection.ExtAmountInCompanyCodeCrcy - $projection.ActualAmountInCompanyCodeCrcy ) / $projection.ActualAmountInCompanyCodeCrcy) * 100 END'
1 as ActExtCoCodeDifferencePct,

//
// Global Currency: KSL RKCUR
//
@AnalyticsDetails.query.axis: #COLUMNS
@EndUserText.label: 'Actual Amount in Global Crcy'    
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
case when PlanningCategory = 'ACT01' then ActualAmountInGlobalCurrency 
                      else cast( 0 as fins_vkcur12)
end as ActualAmountInGlobalCurrency,

@AnalyticsDetails.query.axis: #COLUMNS
//@EndUserText.label: 'Plan Amount in Global Crcy'    
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Global Crcy ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
case when PlanningCategory = :P_PlanningCategory then PlanAmountInGlobalCurrency 
                      else cast( '0' as fins_vkcur12)
end as PlanAmountInGlobalCurrency,

@AnalyticsDetails.query.axis: #COLUMNS
//@EndUserText.label: 'Addtl. Category Amount in Global Crcy'    
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Global Crcy ', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
case when PlanningCategory = :P_ExtraCategory then PlanAmountInGlobalCurrency 
                      else cast( '0' as fins_vkcur12)
end as ExtCategoryAmtInGlobalCrcy,


//@EndUserText.label: 'Difference Actual Plan in Global Crcy'   
@Consumption.dynamicLabel: { label: 'Difference Actual/&1 in Global Crcy ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] } 
@AnalyticsDetails.query.formula : '$projection.ActualAmountInGlobalCurrency - $projection.PlanAmountInGlobalCurrency'
0 as DifferenceAmtInGlobalCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Addtl. Amt in Global Crcy'   
@Consumption.dynamicLabel: { label: 'Difference Act/&1 Amt in Global Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] } 
@AnalyticsDetails.query.formula : '$projection.ActualAmountInGlobalCurrency - $projection.ExtCategoryAmtInGlobalCrcy'
0 as DifferenceAmtActExtInGblCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Pln Amt in Global Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Global Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] } 
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualAmountInGlobalCurrency > 0 
                                   THEN ($projection.ActualAmountInGlobalCurrency - $projection.PlanAmountInGlobalCurrency) / $projection.ActualAmountInGlobalCurrency * 100 
                                   ELSE NDIV0(($projection.PlanAmountInGlobalCurrency - $projection.ActualAmountInGlobalCurrency ) / $projection.ActualAmountInGlobalCurrency) * 100 END'
1 as ActPlnGlobalCrcyDifferencePct,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Addtl. Amt in Global Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Global Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] } 
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualAmountInGlobalCurrency > 0 
                                   THEN ($projection.ActualAmountInGlobalCurrency - $projection.ExtCategoryAmtInGlobalCrcy) / $projection.ActualAmountInGlobalCurrency * 100 
                                   ELSE NDIV0(($projection.ExtCategoryAmtInGlobalCrcy - $projection.ActualAmountInGlobalCurrency ) / $projection.ActualAmountInGlobalCurrency) * 100 END'
1 as ActExtGlobalCrcyDifferencePct,



@AnalyticsDetails.query.hidden: true
@EndUserText.label: 'Actual Amount in Analysis Crcy'    
@Semantics: { amount : {currencyCode: '$parameter.P_Currency'} }
@DefaultAggregation : #FORMULA
case when PlanningCategory = 'ACT01'
     then 
     currency_conversion(  amount => AmountInCompanyCodeCurrency,
                          source_currency => CompanyCodeCurrency,
                          target_currency => $parameters.P_Currency,
                          exchange_rate_type=> $parameters.P_ExchangeRateType, --config
                          exchange_rate_date => FiscalPeriodEndDate
                          )          
     else cast('0' as fins_vhcur12 )
end as ActualAmountInAnalysisCurrency,
    
@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Plan Amount in Analysis Crcy'    
@Semantics: { amount : {currencyCode: '$parameter.P_Currency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Analysis Currency ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
@DefaultAggregation : #FORMULA
case when PlanningCategory = :P_PlanningCategory 
     then 
     currency_conversion(  amount => PlanAmountInCompanyCodeCrcy,
                          source_currency => CompanyCodeCurrency,
                          target_currency => $parameters.P_Currency,
                          exchange_rate_type=> $parameters.P_ExchangeRateType, --config
                          exchange_rate_date => FiscalPeriodEndDate
                          )          
     else cast('0' as fins_vhcur12 )
end as PlanAmountInAnalysisCurrency,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Addtl. Category Amount in Analysis Crcy'    
@Semantics: { amount : {currencyCode: '$parameter.P_Currency'} }
@Consumption.dynamicLabel: { label: ' &1 Amount in Analysis Currency ', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
@DefaultAggregation : #FORMULA
case when PlanningCategory = :P_ExtraCategory 
     then 
     currency_conversion(  amount => PlanAmountInCompanyCodeCrcy,
                          source_currency => CompanyCodeCurrency,
                          target_currency => $parameters.P_Currency,
                          exchange_rate_type=> $parameters.P_ExchangeRateType, --config
                          exchange_rate_date => FiscalPeriodEndDate
                          )          
     else cast('0' as fins_vhcur12 )
end as ExtCategoryAmtInAnalysisCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Pln in Analysis Crcy'    
@Consumption.dynamicLabel: { label: ' Difference Act/&1 in Analysis Crcy ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
@AnalyticsDetails.query.formula : '$projection.ActualAmountInAnalysisCurrency - $projection.PlanAmountInAnalysisCurrency'
0 as DifferenceAmtInAnalysisCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Addtl. in Analysis Crcy'    
@Consumption.dynamicLabel: { label: 'Difference Act/&1 in Analysis Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
@AnalyticsDetails.query.formula : '$projection.ActualAmountInAnalysisCurrency - $projection.ExtCategoryAmtInAnalysisCrcy'
0 as DifferenceAmtActExtInAnlyCrcy,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Pln Amt in Analysis Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Amt in Analysis Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
@AnalyticsDetails.query.decimals: 2
@DefaultAggregation : #FORMULA
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualAmountInAnalysisCurrency > 0 
                                   THEN ($projection.ActualAmountInAnalysisCurrency - $projection.PlanAmountInAnalysisCurrency) / $projection.ActualAmountInAnalysisCurrency * 100 
                                   ELSE NDIV0(($projection.PlanAmountInAnalysisCurrency - $projection.ActualAmountInAnalysisCurrency ) / $projection.ActualAmountInAnalysisCurrency) * 100 END'
1 as AnalysisCrcyDifferencePct,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Addtl. Amt in Analysis Crcy'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/Addtl. Amt in Analysis Crcy', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
@AnalyticsDetails.query.decimals: 2
@DefaultAggregation : #FORMULA
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualAmountInAnalysisCurrency > 0 
                                   THEN ($projection.ActualAmountInAnalysisCurrency - $projection.ExtCategoryAmtInAnalysisCrcy) / $projection.ActualAmountInAnalysisCurrency * 100 
                                   ELSE NDIV0(($projection.ExtCategoryAmtInAnalysisCrcy - $projection.ActualAmountInAnalysisCurrency ) / $projection.ActualAmountInAnalysisCurrency) * 100 END'
1 as ActExtAnlyCrcyDifferencePct,

@EndUserText.label: 'Quantity'
@AnalyticsDetails.query.hidden: true
@AnalyticsDetails.query.axis: #COLUMNS
@DefaultAggregation : #SUM
@Semantics: { quantity : {unitOfMeasure: 'CostSourceUnit'} }
ValuationQuantity,

@EndUserText.label: 'Actual Quantity'
@AnalyticsDetails.query.hidden: true
@AnalyticsDetails.query.axis: #COLUMNS
@Semantics: { quantity : {unitOfMeasure: 'CostSourceUnit'} }
case when PlanningCategory = 'ACT01' then ActualValuationQuantity
                      else cast( '0' as fis_val_quan_act)
end as ActualValuationQuantity,

//@EndUserText.label: 'Plan Quantity'
@AnalyticsDetails.query.hidden: true
@AnalyticsDetails.query.axis: #COLUMNS
//@Semantics: { quantity : {unitOfMeasure: 'CostSourceUnit'} }
@Consumption.dynamicLabel: { label: ' &1 Quantity ', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
case when PlanningCategory =  :P_PlanningCategory then PlanValuationQuantity
                      else cast( '0' as fis_val_quan_plan)
end as PlanValuationQuantity,

//@EndUserText.label: 'Additional Quantity'
@AnalyticsDetails.query.hidden: true
@AnalyticsDetails.query.axis: #COLUMNS
@Semantics: { quantity : {unitOfMeasure: 'CostSourceUnit'} }
@Consumption.dynamicLabel: { label: ' &1 Quantity ', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
case when PlanningCategory =  :P_ExtraCategory then PlanValuationQuantity
                      else cast( '0' as fis_val_quan_plan)
end as ExtraValuationQuantity,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Pln Quantity'   
@Consumption.dynamicLabel: { label: 'Difference Act/&1 Quantity', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
@AnalyticsDetails.query.formula : '$projection.ActualValuationQuantity - $projection.PlanValuationQuantity'
0 as DifferenceQuantity,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Difference Act/Addtl. Quantity'    
@Consumption.dynamicLabel: { label: 'Difference Act/&1 Quantity', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
@AnalyticsDetails.query.formula : '$projection.ActualValuationQuantity - $projection.ExtraValuationQuantity'
0 as DifferenceQuantityExtraCat,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Pln Quantity'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Quantity', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualValuationQuantity > 0 
                                   THEN ($projection.ActualValuationQuantity - $projection.PlanValuationQuantity) / $projection.ActualValuationQuantity * 100 
                                   ELSE NDIV0(($projection.PlanValuationQuantity - $projection.ActualValuationQuantity ) / $projection.ActualValuationQuantity) * 100 END'
1 as ActPlnQuantityDifferencePct,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label : 'Diff.(%) Act/Addtl. Quantity'
@Consumption.dynamicLabel: { label: 'Diff.(%) Act/&1 Quantity', binding: [ { index: 1, parameter: 'P_ExtraCategory'} ] }
@AnalyticsDetails.query.decimals: 2
@AnalyticsDetails.query.formula :  'CASE WHEN $projection.ActualValuationQuantity > 0 
                                   THEN ($projection.ActualValuationQuantity - $projection.ExtraValuationQuantity) / $projection.ActualValuationQuantity * 100 
                                   ELSE NDIV0(($projection.ExtraValuationQuantity - $projection.ActualValuationQuantity ) / $projection.ActualValuationQuantity) * 100 END'
1 as ActExtQuantityDifferencePct,

@AnalyticsDetails.query.hidden: true
//@EndUserText.label: 'Plan Year in Company Code Crcy'    
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'}}
@DefaultAggregation : #SUM
@Consumption.dynamicLabel: { label: '&1 Year in Company Code Crcy', binding: [ { index: 1, parameter: 'P_PlanningCategory'} ] }
case when PlanningCategory = :P_PlanningCategory //and FiscalPeriod <= :P_YTD 
                    then PlanAmountInCompanyCodeCrcy
                      else cast( '0' as fins_vhcur12)
end as PlanFAmtInCoCodeCrcy,

@AnalyticsDetails.query.hidden: true
@DefaultAggregation : #SUM
@Semantics: { quantity : {unitOfMeasure: 'AdditionalUoM1'} }
@EndUserText.label: 'Additional Quantity 1'
AdditionalQuantity1,

@AnalyticsDetails.query.hidden: true
@DefaultAggregation : #SUM
@Semantics: { quantity : {unitOfMeasure: 'AdditionalUoM2'} }
@EndUserText.label: 'Additional Quantity 2'
AdditionalQuantity2,

@AnalyticsDetails.query.hidden: true
@DefaultAggregation : #SUM
@Semantics: { quantity : {unitOfMeasure: 'AdditionalUoM3'} }
@EndUserText.label: 'Additional Quantity 3'
AdditionalQuantity3,

@AnalyticsDetails.query.hidden: true
@DefaultAggregation : #SUM
@EndUserText.label: 'Price in Local Currency'
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
StandardPriceinLocalCurrency

} where //Ledger = :P_Ledger and 
        ControllingArea = :P_ControllingArea                                                                                                                                                                                                                              
    and ( PlanningCategory = 'ACT01' or PlanningCategory = :P_PlanningCategory or PlanningCategory = :P_ExtraCategory)
    and FiscalYear = :P_FiscalYear
;                                                                                                                                                                                                                                                                                        

  
  
  
