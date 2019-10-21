/// Allows you to execute a random PMML model (specified by name on ModelClassName) with an array of parameters.
/// This request can be sent to any available Executor. The Executor will ignore its ABT and run the model with
/// the provided data.
Class ML.Model.BO.Executor.ExecuteParamModelReq Extends (%Persistent, ML.Model.BO.Executor.ExecuteModelReq)
{

Property ModelClassName As %String [ Required ];

}
