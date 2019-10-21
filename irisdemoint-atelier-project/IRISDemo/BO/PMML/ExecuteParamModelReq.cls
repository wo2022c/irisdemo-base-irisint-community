Class IRISDemo.BO.PMML.ExecuteParamModelReq Extends (%Persistent,IRISDemo.BO.PMML.ExecuteModelReq)
{
	/// PMML Definition class name (should inherit from %DeepSee.PMML.Definition)
	Property ModelClassName As %String [ Required ];



Storage Default
{
<Data name="ExecuteParamModelReqDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ModelClassName</Value>
</Value>
<Value name="3">
<Value>ModelName</Value>
</Value>
</Data>
<Data name="ModelData">
<Attribute>ModelData</Attribute>
<Structure>subnode</Structure>
<Subscript>"ModelData"</Subscript>
</Data>
<DataLocation>^IRISDemo.B117E.ExecuteParamDACD</DataLocation>
<DefaultData>ExecuteParamModelReqDefaultData</DefaultData>
<IdLocation>^IRISDemo.B117E.ExecuteParamDACD</IdLocation>
<IndexLocation>^IRISDemo.B117E.ExecuteParamDACI</IndexLocation>
<StreamLocation>^IRISDemo.B117E.ExecuteParamDACS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}