Class ML.DataPrep.NaReplace Extends ML.DataPrep.AbstractDataPrep
{
ClassMethod PrepareMethod(pABTName As %String, pColumn As %String, pMethodDetails As %String)
{
	If +pMethodDetails'=0 || ($EXTRACT(pMethodDetails,1,1)=0)
	{
		Set ^PublishedABT(pABTName,"NullReplaced",pColumn) = +pMethodDetails
	}
	ElseIf pMethodDetails="mean"
	{
		Set tQueryResult = ##class(%SQL.Statement).%ExecDirect(,"select avg("_pColumn_") as av from "_^PublishedABT(pABTName,"FACTTABLENAME"))
		Do tQueryResult.%Next()
		Set ^PublishedABT(pABTName,"NullReplaced",pColumn) = tQueryResult.%Get("av")
	}
	ElseIf pMethodDetails="median"
	{
		Set tQueryResult = ##class(%SQL.Statement).%ExecDirect(,"select median("_pColumn_") as med from "_^PublishedABT(pABTName,"FACTTABLENAME"))
		Do tQueryResult.%Next()
		Set ^PublishedABT(pABTName,"NullReplaced",pColumn) = tQueryResult.%Get("med")
	}
	ElseIf pMethodDetails="mode"
	{
		Set tQueryResult = ##class(%SQL.Statement).%ExecDirect(,"select top 1 "_pColumn_" as mode, count("_pColumn_") as ct from "_^PublishedABT(pABTName,"FACTTABLENAME")_" group by "_pColumn_" order by ct desc")
		Do tQueryResult.%Next()
		Set ^PublishedABT(pABTName,"NullReplaced",pColumn) = tQueryResult.%Get("mode")
	}
	Else
	{
		$$$ThrowException("UnknownMethod", "Null replacement value of "_pMethodDetails_" is not understood.")
	}
}

ClassMethod GetExpression(pABTName As %String, pColumn As %String)
{
	If $Data(^PublishedABT(pABTName,"NullReplaced",pColumn))
	{
		Set ^PublishedABT(pABTName,"DataPrepCode",pColumn) = "($CASE("_^PublishedABT(pABTName,"DataPrepCode",pColumn)_","""":"_^PublishedABT(pABTName,"NullReplaced",pColumn)_",:"_^PublishedABT(pABTName,"DataPrepCode",pColumn)_"))"
	}
}
Storage Default
{
<Type>%Storage.Serial</Type>
}

}