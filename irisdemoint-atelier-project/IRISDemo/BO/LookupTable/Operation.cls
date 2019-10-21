Class IRISDemo.BO.LookupTable.Operation extends Ens.BusinessOperation 
{

	Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";
	
	Property Adapter As EnsLib.SQL.OutboundAdapter;
	
	Parameter INVOCATION = "Queue";
	
	Method DownloadLookupTable(pInput As IRISDemo.BS.LookupTable.RequestLookupTableReq, Output pOutput As Ens.Response) As %Status
	{
		Set tSC = $$$OK
		Try
		{
			Set tSQL = "select distinct "_pInput.DataLakeKeyColumnName_", "_pInput.DataLakeValColumnName_ " from "_pInput.DatalakeTableName
			
			Set tSC = ..Adapter.ExecuteQuery(.oRS ,tSQL)
			Quit:$System.Status.IsError(tSC)
			
			TStart
			
			Kill ^Ens.LookupTable(pInput.LookupTableName)
			Set ^Ens.LookupTable(pInput.LookupTableName)=$ListBuild($Horolog)
			
			While oRS.Next()
			{
				Set ^Ens.LookupTable(pInput.LookupTableName, oRS.GetData(1))=oRS.GetData(2)
			}
			
			Set ^IRISDemo.BS.LookupTable("PopulatedTables", pInput.LookupTableName)=$ListBuild($H)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		If $System.Status.IsError(tSC)
		{
			TRollback
		}
		Else
		{
			TCommit
		}
		
		Quit tSC
	}

	XData MessageMap 
	{
	<MapItems>
	    <MapItem MessageType="IRISDemo.BS.LookupTable.RequestLookupTableReq">
	        <Method>DownloadLookupTable</Method>
	    </MapItem>
	</MapItems>
	}

}