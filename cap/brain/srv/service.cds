using {cuid} from '@sap/cds/common';
using {API_SALES_ORDER_SRV as external} from './external/API_SALES_ORDER_SRV';

service teched {

    entity Donation : cuid {
        customerId : Integer;
    }

    function invoke() returns String;


};

/*service SalesOrders @(impl: 'srv/salesorders.js') {
    entity Orders as projection on external.A_SalesOrder
}*/
