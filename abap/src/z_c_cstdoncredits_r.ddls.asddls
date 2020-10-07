@EndUserText.label: 'Customer Donation Credits Projection View - Reporting'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity Z_C_CSTDONCREDITS_R as projection on Z_I_CSTDONCREDITS_R {
    //Z_I_CSTDONCREDITS_R
    key custid,
    key creationdateyyyymm,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CDC_CUSTOMER_MASTER'
    @EndUserText.label : 'Customer Name'
    virtual customername : abap.char(40),
    totalcredits
}
