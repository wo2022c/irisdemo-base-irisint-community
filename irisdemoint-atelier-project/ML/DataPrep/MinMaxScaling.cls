Class ML.DataPrep.MinMaxScaling Extends ML.DataPrep.AbstractNormalization
{
ClassMethod PrepareNorm(pABTName As %String, pColumn As %String)
{
	If $Data(^PublishedABT(pABTName,"NullReplaced",pColumn))
	{
		Quit ##class(%SQL.Statement).%ExecDirect(,"select min(coalesce("_pColumn_","_^PublishedABT(pABTName,"NullReplaced",pColumn)_")) as normsubtract, max(coalesce("_pColumn_","_^PublishedABT(pABTName,"NullReplaced",pColumn)_")) - min(coalesce("_pColumn_","_^PublishedABT(pABTName,"NullReplaced",pColumn)_")) as normdivide from "_^PublishedABT(pABTName,"FACTTABLENAME"))
	}
	Else
	{
		Quit ##class(%SQL.Statement).%ExecDirect(,"select min("_pColumn_") as normsubtract, max("_pColumn_")-min("_pColumn_") as normdivide from "_^PublishedABT(pABTName,"FACTTABLENAME"))
	}
}

Storage Default
{
<Type>%Storage.Serial</Type>
}

}