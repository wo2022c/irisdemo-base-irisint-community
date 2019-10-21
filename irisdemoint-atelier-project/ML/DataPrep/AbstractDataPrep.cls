Include (%DeepSee, DEMOMACROS)

Class ML.DataPrep.AbstractDataPrep Extends %SerialObject [Abstract]
{
ClassMethod Prepare(pABTName As %String, pColumn As %String, pMethodDetails As %String="")
{
	If '$Data(^PublishedABT(pABTName,"Dropped",pColumn)) && '$Data(^PublishedABT(pABTName,"Skipped",pColumn))
	{
		Set tParsedDetails = ##class(ML.DataPrep.Utils).DetailSearch(pColumn,pMethodDetails)
		If $List(tParsedDetails,1) = 1
		{
			Do ..PrepareMethod(pABTName,pColumn,$List(tParsedDetails,2))
			Set nsteps = $Get(^PublishedABT(pABTName,"N_PREP_STEPS",pColumn),0) + 1
			Set ^PublishedABT(pABTName,"N_PREP_STEPS",pColumn) = nsteps
			Set ^PublishedABT(pABTName,"PREP_STEP",pColumn,nsteps) = $ClassName()
		}
	}
}
ClassMethod PrepareMethod(pABTName As %String, pColumn As %String, pMethodDetails As %String) [Abstract]
{
}
ClassMethod GetExpression(pABTName As %String, pColumn As %String) [Abstract]
{
}
Storage Default
{
<StreamLocation>^ML.DataPrep.AbstractDataPrepS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}