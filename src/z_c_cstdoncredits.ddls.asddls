@EndUserText.label: 'Customer Donation Credits Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

define root view entity z_c_cstdoncredits as projection on Z_I_CSTDONCREDITS {
    //Z_I_CSTDONCREDITS

    key salesorder,    
    custid,
    
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CDC_CUSTOMER_MASTER'
    @EndUserText.label : 'Customer Name'
    virtual customername : abap.char(40),

    creationdate,
    creationdateyyyymm,
    credits,
    salesorg
}
