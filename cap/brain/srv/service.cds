using {cuid} from '@sap/cds/common';

service teched {

    entity Donation : cuid {
        customerId : Integer;
    }

    function invoke() returns String;


};
