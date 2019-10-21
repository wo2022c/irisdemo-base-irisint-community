Class ML.DataPrep.Standardization Extends ML.DataPrep.AbstractNormalization
{
ClassMethod PrepareNorm(pABTName As %String, pColumn As %String)
{
	If $Data(^PublishedABT(pABTName,"NullReplaced",pColumn))
	{
		Quit ##class(%SQL.Statement).%ExecDirect(,"select avg(coalesce("_pColumn_","_^PublishedABT(pABTName,"NullReplaced",pColumn)_")) as normsubtract, stddev(coalesce("_pColumn_","_^PublishedABT(pABTName,"NullReplaced",pColumn)_")) as normdivide from "_^PublishedABT(pABTName,"FACTTABLENAME"))
	}
	Else
	{
		Quit ##class(%SQL.Statement).%ExecDirect(,"select avg("_pColumn_") as normsubtract, stddev("_pColumn_") as normdivide from "_^PublishedABT(pABTName,"FACTTABLENAME"))
	}
}

Storage Default
{
<Type>%Storage.Serial</Type>
}

}