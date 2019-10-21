Class IRISDemo.Production Extends IRISDemo.BaseProduction
{

XData ProductionDefinition
{
<Production Name="IRISDemo.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="PMML File Loader" Category="" ClassName="ML.PMML.BS.Loader.File.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/common_shared/pmml/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.pmml</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/common_shared/imported_pmml/</Setting>
  </Item>
  <Item Name="Java Gateway Service" Category="Datalake" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>

</Production>
}

}
