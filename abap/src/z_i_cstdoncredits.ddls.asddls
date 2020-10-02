@AbapCatalog.sqlViewName: 'ZICSTDONCREDITS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Customer Donation Credits View'
define view Z_I_CSTDONCREDITS 
    as select from zcstdoncredits {
    key custid,
    custname,
    credits,
    salesorg
}
