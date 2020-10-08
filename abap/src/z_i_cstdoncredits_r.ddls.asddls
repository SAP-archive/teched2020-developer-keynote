@EndUserText.label: 'Customer Donation Credits View - Reporting View'
@AccessControl.authorizationCheck: #CHECK
define root view entity Z_I_CSTDONCREDITS_R 
   as select from Z_I_CSTDONCREDITS
 {
    key custid,
    key creationdateyyyymm,
    
    @EndUserText.label : 'Total Donation Credits'
    sum(credits) as totalcredits
} group by custid, creationdateyyyymm
