@AbapCatalog.sqlViewName: 'ZICSTDONCREDITS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Customer Donation Credits View'
define root view Z_I_CSTDONCREDITS 
    as select from zcstdoncredits {

    @EndUserText.label : 'Sales Order ID'
    key salesorder,
    
    @EndUserText.label : 'Customer ID'
    custid,
    
    @EndUserText.label : 'Creation Date'
    creationdate,
    
    @EndUserText.label : 'Creation Date YYYY/MM'
    CONCAT ( SUBSTRING (creationdate,1,4), SUBSTRING (creationdate,5,2) ) as creationdateyyyymm, //YearMonth(YYYYMM)    
  
    @EndUserText.label : 'Donation Credits'
    credits,

    @EndUserText.label : 'Sales Org'
    salesorg
    
} 
