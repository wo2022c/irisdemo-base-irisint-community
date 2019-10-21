/// This request will use the provided SourceId to identify the record on the ABT from which to fetch 
/// the required feature row to run the configured PMML model on the executor.
/// SourceID is the ID of the base table used to build the cube from which the ABT was derived.
Class ML.Model.BO.Executor.ExecuteModelWithABTReq Extends (%Persistent, Ens.Request)
{

Property SourceID As %String [ Required ];

}
