Class ML.DataPrep.Skip Extends ML.DataPrep.AbstractDataPrep
{
ClassMethod PrepareMethod(pABTName As %String, pColumn As %String, pMethodDetails As %String)
{
	Set ^PublishedABT(pABTName,"Skipped",pColumn) = 1
}
ClassMethod GetExpression(pABTName As %String, pColumn As %String)
{
}
Storage Default
{
<Type>%Storage.Serial</Type>
}

}