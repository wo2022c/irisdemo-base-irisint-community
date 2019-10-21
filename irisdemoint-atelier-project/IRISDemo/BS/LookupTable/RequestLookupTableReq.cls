Class IRISDemo.BS.LookupTable.RequestLookupTableReq Extends (%Persistent,Ens.Request)
{
	Property LookupTableName As %String [ Required ];
	
	Property DatalakeTableName As %String [ Required ];
	
	Property DataLakeKeyColumnName As %String [ Required ];
	
	Property DataLakeValColumnName As %String [ Required ];
}