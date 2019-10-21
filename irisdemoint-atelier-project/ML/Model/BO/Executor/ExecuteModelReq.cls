/// Allows you to run the PMML model specified on the Executor with the data provided on ModelData array
Class ML.Model.BO.Executor.ExecuteModelReq Extends (%Persistent, Ens.Request)
{

/// Array of string values containing model input values
Property ModelData As array Of %String;

}
