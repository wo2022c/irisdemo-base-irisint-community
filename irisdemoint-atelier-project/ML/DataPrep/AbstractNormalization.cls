Class ML.DataPrep.AbstractNormalization Extends ML.DataPrep.AbstractDataPrep [Abstract]
{
ClassMethod PrepareMethod(pABTName As %String, pColumn As %String, pMethodDetails As %String="")
{
	Set tQueryResult = ..PrepareNorm(pABTName, pColumn)
	$$$ThrowSQLExceptionIfResultError(tQueryResult, "PrepareMethodExecDirectException")
	Do tQueryResult.%Next()
	Set tSub = tQueryResult.%Get("normsubtract")
	Set tDiv = tQueryResult.%Get("normdivide")
	If tDiv = 0
	{
		Set tDiv = 1
		// $$$ThrowException("ScaleByZero", "Normalization of "_pColumn_" would involve dividing by zero.")
	}
	If tDiv '= 1
	{
		Set $Piece(^PublishedABT(pABTName,"ROWSPEC"),",",^PublishedABT(pABTName,"PMap2",pColumn)) = pColumn_":%Double"
	}
	Set ^PublishedABT(pABTName,"NormSubtract",pColumn) = tSub
	Set ^PublishedABT(pABTName,"NormDivide",pColumn) = tDiv
}

ClassMethod PrepareNorm(pABTName As %String, pColumn As %String) [Abstract]
{
}

ClassMethod GetExpression(pABTName As %String, pColumn As %String)
{
	If $Data(^PublishedABT(pABTName,"NormSubtract",pColumn)) && $Data(^PublishedABT(pABTName,"NormDivide",pColumn))
	{
		Set tSub = ^PublishedABT(pABTName,"NormSubtract",pColumn)
		Set tDiv = ^PublishedABT(pABTName,"NormDivide",pColumn)
		Set tMethod = "(("_^PublishedABT(pABTName,"DataPrepCode",pColumn)
		If tSub = 0
		{
			Set tMethod = tMethod_")"
		}
		ElseIf tSub < 0
		{
			Set tMethod = tMethod_"+"_(-tSub)_")"
		}
		Else
		{
			Set tMethod = tMethod_"-"_tSub_")"
		}
		If tDiv '= 1
		{
			Set tMethod = tMethod_"/"_(tDiv)
		}
		Set ^PublishedABT(pABTName,"DataPrepCode",pColumn) = tMethod_")"
	}
	Else
	{
		$$$ThrowException("MissingData", "MinMaxScaling of "_pColumn_" is missing data. Either MinMaxScaling was not prepared on this column or the scaling was invalid.")
	}
}
Storage Default
{
<Type>%Storage.Serial</Type>
}

}