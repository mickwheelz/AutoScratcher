// script to set up test data in a scratch org

Contact c = new Contact( Salutation = 'Mr.', FirstName = 'Richard', LastName = 'Nixon', Email = 'tricky.dick@ovoenergy.com', 
Birthdate = Date.newInstance(1913,1,9), Global_Customer_Id__c = 'global-customer-id-1',
Address__c = '1 Rivergate\nBristol\nAvon\nBS1 6ED' );

insert c;

Service_Account__c sa = new Service_Account__c( Service_Account_Id__c = 'service-account-id-1', Mock_Account__c = true );

insert sa;

Contact_Permission__c cp = new Contact_Permission__c( Contact__c = c.id, Service_Account__c = sa.id );

insert cp;

List<Phone_Number__c> phones = new List<Phone_Number__c>{
 new Phone_Number__c( Contact__c = c.id, Number__c = '+44 1234 567890' ),
 new Phone_Number__c( Contact__c = c.id, Number__c = '+44 0987 654321' ) };
 
insert phones;

DD_Details__c dd = new DD_Details__c( Mandate_Id__c = 'mandate-id-1', Mandate_Status__c = 'active', Bank_Name__c = 'Bank of Bristol', 
Bank_Account_Number__c = '34', Mandate_Status_Timestamp__c = 1522590834000L, Reference__c = 'reference123', Subscription_Id__c = 'subs-id-1',
Subscription_Status__c = 'active', Subscription_Status_Timestamp__c = 1522590834000L, Amount__c = 45.00, Day_of_Month__c = 21, 
Service_Account__c = sa.id);

insert dd;

List<Transaction__c> txs = new List<Transaction__c>();
Decimal bal = 0.00;
Integer yr = 2018;
Datetime dt;
for (Integer m = 0; m < 4; m++) {
    for (Integer d = 0; d <25; d++) {
        // add a daily consumption charge
        Decimal consumption = -1.83;
        bal += consumption;
        dt = Datetime.newInstance(yr, m+1, d+1, 9, 0, 0);
        Transaction__c tx = new Transaction__c(
            Amount__c = consumption,
            Balance__c = bal,
            Transaction_Time__c = dt,
            Type__c = 'consumption_charge',
            External_Id__c = 'cons-'+m+'-'+d,
            Service_Account__c = sa.id
        );
        txs.add( tx );

        // add a daily standing charge
        Decimal standing = -2.29;
        bal += standing;
        tx = new Transaction__c(
            Amount__c = standing,
            Balance__c = bal,
            Transaction_Time__c = dt,
            Type__c = 'standing_charge',
            External_Id__c = 'stnd-'+m+'-'+d,
            Service_Account__c = sa.id
        );
        txs.add( tx );
    }
    // add a monthly payment
    Decimal payment = 125.00;
    bal += payment;
    Transaction__c tx = new Transaction__c(
        Amount__c = payment,
        Balance__c = bal,
        Transaction_Time__c = dt.addDays(1),
        Type__c = 'payment',
        External_Id__c = 'paym-'+m,
        Service_Account__c = sa.id
    );
    txs.add( tx );
}

insert txs;

// add a reward
Decimal reward = 10.00;
bal += reward;
Transaction__c tx = new Transaction__c(
    Amount__c = reward,
    Balance__c = bal,
    Transaction_Time__c = dt.addDays(1),
    Type__c = 'reward',
    External_Id__c = 'rewd-0'
    );

insert tx;

// force balance on service account to update
tx.Service_Account__c = sa.id;

update tx;

Supply_Point__c sp1 = new Supply_Point__c( Type__c = 'Gas', Name = 'sp-1', MPXN__c = 'G1234', Address__c = 'Street address', 
Postcode__c = 'PC1 0DE', LDZ__c = 'West');

Supply_Point__c sp2 = new Supply_Point__c( Type__c = 'Electricity', Name = 'sp-2', MPXN__c = 'E1234', Address__c = 'Street address', 
Postcode__c = 'PC1 0DE');

insert new List<Supply_Point__c>{ sp1, sp2 };

Energy_Contract__c ec1 = new Energy_Contract__c( Contract_Id__c = 'ec-1', Fuel__c = 'Gas', MPXN__c = 'G1234', Supply_Point__c = sp1.id,
Service_Account__c = sa.id, Start_Date__c = Date.newInstance(2018,4,1), Expiry_Date__c = Date.newInstance(2018,4,30), Unit_Rate__c = 0.03456,
Standing_Rate__c = 0.22575);

Energy_Contract__c ec2 = new Energy_Contract__c( Contract_Id__c = 'ec-2', Fuel__c = 'Electricity', MPXN__c = 'E1234', Supply_Point__c = sp2.id,
Service_Account__c = sa.id, Start_Date__c = Date.newInstance(2018,4,1), Expiry_Date__c = Date.newInstance(2018,4,30), Unit_Rate__c = 0.15678,
Standing_Rate__c = 0.22575);

insert new List<Energy_Contract__c>{ ec1, ec2 };