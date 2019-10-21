Include DEMOMACROS

/// This service will periodically verify if any look up table needs to be reloaded from the intelligent data lake.
/// The BS will only ask the BO to populate the lookup table if it can't find it under ^IRISDemo.BS.LookupTable("PopulatedTables").
/// The idea is that we could ask, at any time, for this table to be repopulated by killing the respective node under
/// ^IRISDemo.BS.LookupTable("PopulatedTables",<LookupTableName>).
///
/// Once we start populating a lookup table, we will increment global ^IRISDemo.BS.LookupTable("Updating")
/// by one. When it is finished it will decrease it by 1. Services that depend on lookup tables being consistent must check if
/// ^IRISDemo.BS.LookupTable("Updating") is zero. There is a utility method on class IRISDemo.InteroperabilitySupport called
/// AreLookupTablesConsistent() for this.
///
/// You should set the poolsize of this service to as many lookup tables you have. The same for the assiting business operation.
Class IRISDemo.BS.LookupTable.Service extends Ens.BusinessService {

	Parameter ADAPTER = "Ens.InboundAdapter";
	
	/// <p>Use the following pattern to fill in this specification (one line per table):</p>
	/// <pre>Lookup Table Name, Data Lake Table Name, Key Column Name, Value Column  Name [ENTER]</pre>
	Property LookupTableLoadingSpec As %String(MAXLEN="");
	
	Property DownloadBusinessOperation As %String(MAXLEN="");
	
	Parameter SETTINGS = "LookupTableLoadingSpec,DownloadBusinessOperation::selector?multiSelect=0&context={IRISDemo.Util.ContextSearch/LookupTableDownloadItems?targets=1&productionName=@productionId}";
	
	Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
	{
		Set tSC = $$$OK
		Try
		{
			Set tSpecLine=""
			For iLine=1:1:$Length(..LookupTableLoadingSpec,$C(10))
			{
				Set tSpecLine = $ZStrip($Piece(..LookupTableLoadingSpec,$C(10),iLine),"<>W")
				Continue:tSpecLine=""
				
				$$$TRACE("Processing specification on line "_iLine)
				
				If tSpecLine'?.(1A,1"_",1".",1"->")." "1","." ".(1A,1"_",1".",1"->")." "1","." ".(1A,1"_",1".",1"->")." "1","." ".(1A,1"_",1".",1"->")
				{
					$$$ThrowException("InvalidLookupSpecificationSourceException", "Setting LookupTableLoadingSpec contains an invalid lookup specification on line "_iLine)
				}
				
				Set tLookupTableName = $ZStrip($Piece(tSpecLine,",",1),"<>W")
				Set tDatalakeTableName = $ZStrip($Piece(tSpecLine,",",2),"<>W")
				Set tDataLakeKeyColumnName = $ZStrip($Piece(tSpecLine,",",3),"<>W")
				Set tDataLakeValColumnName = $ZStrip($Piece(tSpecLine,",",4),"<>W")
				
				// Is another instance of this business service working on this table already?
				$$$TRACE("Verifying if another instance is working with this lookup table already...")
				Lock +^IRISDemo.BS.LookupTable("PopulatedTables", tLookupTableName):1 
				Else  $$$TRACE("Another instance is working with this one.") Continue //Yes. Let's get the next one.
				$$$TRACE("No instance was working with this lookup table. We can work with it now.")
				// No. We have it then...
				
				// Does this lookup table need to be re-populated?
				If '$Data(^IRISDemo.BS.LookupTable("PopulatedTables", tLookupTableName))
				{
					$$$TRACE("Loading lookup table "_tLookupTableName_"...")
					// Yes... So let's request it.
					Set tSC = ..RequestLookupTable(tLookupTableName, tDatalakeTableName, tDataLakeKeyColumnName, tDataLakeValColumnName)
				}
				Else
				{
					$$$TRACE("No need to load lookup table "_tLookupTableName_".")
				}
				
				// Let's relinquish that lock now...
				Lock -^IRISDemo.BS.LookupTable("PopulatedTables", tLookupTableName)
				
				// Now, let's see if RequestLookupTable() returned an error and report it if it did...
				Quit:$System.Status.IsError(tSC)
			}
		}
		Catch (oException)
		{
			$$$TRACE("An exception just occurred.")
			Set tSC = oException.AsStatus()
		}
		
		Quit tSC
	}
	
	Method RequestLookupTable(pLookupTableName As %String, pDatalakeTableName As %String, pDataLakeKeyColumnName As %String, pDataLakeValColumnName As %String) As %Status
	{
		Set tSC = $$$OK
		Set dummy=$Increment(^IRISDemo.BS.LookupTable("Updating"))
		
		Try
		{
			Set oRequest = ##class(IRISDemo.BS.LookupTable.RequestLookupTableReq).%New()
			Set oRequest.LookupTableName = pLookupTableName
			Set oRequest.DatalakeTableName = pDatalakeTableName
			Set oRequest.DataLakeKeyColumnName = pDataLakeKeyColumnName
			Set oRequest.DataLakeValColumnName = pDataLakeValColumnName
			
			Set tSC = ..SendRequestSync(..DownloadBusinessOperation, oRequest)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Set dummy=$Increment(^IRISDemo.BS.LookupTable("Updating"), -1)
		 
		Quit tSC
	}
	
	ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
	{
		Do ##super(.pArray,pItem)
		If pItem.GetModifiedSetting("DownloadBusinessOperation",.tValue) 
		{
			Set pArray(tValue)=""
		}
	}
}