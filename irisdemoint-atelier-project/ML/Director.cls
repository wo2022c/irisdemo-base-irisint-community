Include DEMOMACROS
Class ML.Director
{
	ClassMethod PublishCubeAsABT(pCubeName As %String, pABTName As %String = "", pFullColumnExpansion As %Boolean = 0, pDataPrep As %String = "")
	{
		#Dim oMethod As %Dictionary.MethodDefinition
		#Dim oTemplateQuery As %Dictionary.QueryDefinition
		#Dim oTemplateClass As %Dictionary.ClassDefinition
		#Dim oGeneratedClass As %Dictionary.ClassDefinition
		
		Set tSC = $$$OK
		Try
		{
			If pABTName="" Set pABTName=pCubeName
			If pABTName'?1A.(1A,1N)
			{
				$$$ThrowException("InvalidABTNameException", "The name '"_pABTName_"' can not be used as a valid ABT name. Please specify a valid ABT name on the pABTName parameter")
			}
			Set tGeneratedClassName = "PublishedABT."_pABTName
			
			Set tDataPrepLists = ##class(ML.DataPrep.Utils).Parse($ZStrip(pDataPrep,"*"," "))
			
			Do ##class(%Dictionary.ClassDefinition).%DeleteId(tGeneratedClassName)
			
			Do ##class(ML.ABT.Utils).StoreABTMetaData(pCubeName, pABTName, pFullColumnExpansion)
			
			Do ##class(ML.DataPrep.Utils).PrepareAll(pABTName,tDataPrepLists)
			
			//
			// CLASS
			//

			Set oGeneratedClass = ##class(%Dictionary.ClassDefinition).%New()
			Set oGeneratedClass.Name = tGeneratedClassName
			Set oGeneratedClass.IncludeCode="DEMOMACROS"
			Set oGeneratedClass.Super="ML.ABT.AbstractABT"			

			//
			// QUERY
			//
			
			Set oQuery = ##class(%Dictionary.QueryDefinition).%New()
			Set oQuery.parent = oGeneratedClass
			Do oGeneratedClass.Queries.Insert(oQuery)

			Set oQuery.Name=pABTName_"GetFeatures"
			Set oQuery.FormalSpec="pSourceId:%String"
			Set oQuery.Type="%Query"
			Do oQuery.Parameters.SetAt(^PublishedABT(pABTName,"ROWSPEC"), "ROWSPEC")
			Set oQuery.SqlName=oQuery.Name
			Set oQuery.SqlProc=1
			
			//
			// METHOD CLOSE
			//
			Set oMethodClose = ##class(%Dictionary.MethodDefinition).%New()
			Set oMethodClose.parent=oGeneratedClass
			Set oMethodClose.Name=pABTName_"GetFeaturesClose"
			Set oMethodClose.ClassMethod=1
			Set oMethodClose.FormalSpec="&qHandle:%Binary,pSourceId:%String"
			Set oMethodClose.ReturnType="%Status"
			Do oMethodClose.Implementation.WriteLine(" Quit $$$OK")

			//
			// METHOD EXECUTE
			//
			Set oMethodExecute = ##class(%Dictionary.MethodDefinition).%New()
			Set oMethodExecute.parent=oGeneratedClass
			Set oMethodExecute.Name=pABTName_"GetFeaturesExecute"
			Set oMethodExecute.ClassMethod=1
			Set oMethodExecute.FormalSpec="&qHandle:%Binary,pSourceId:%String"
			Set oMethodExecute.ReturnType="%Status"
			Do oMethodExecute.Implementation.WriteLine(" Set tSC = $$$OK")
			Do oMethodExecute.Implementation.WriteLine(" Try {")
			Do oMethodExecute.Implementation.WriteLine("   Set pSourceId=$Get(pSourceId)")
			Do oMethodExecute.Implementation.WriteLine("   If pSourceId="""" {")
			Do oMethodExecute.Implementation.WriteLine("     Set qHandle(""RS"") = ##class(%SQL.Statement).%ExecDirect(,""select * from "_^PublishedABT(pABTName,"FACTTABLENAME")_""")")
			Do oMethodExecute.Implementation.WriteLine("   } Else {")
			Do oMethodExecute.Implementation.WriteLine("     Set tID = ##class(ML.ABT.Utils).GetFactIdForCubeSourceId("""_pCubeName_""", pSourceId)")
			Do oMethodExecute.Implementation.WriteLine("     Set qHandle(""RS"") = ##class(%SQL.Statement).%ExecDirect(,""select * from "_^PublishedABT(pABTName,"FACTTABLENAME")_" where ID=""_tID)")
			Do oMethodExecute.Implementation.WriteLine("   }")
			Do oMethodExecute.Implementation.WriteLine("   $$$ThrowSQLExceptionIfResultError(qHandle(""RS""), ""ABTFactTableQueryException"")")
			Do oMethodExecute.Implementation.WriteLine(" } Catch (oException) { Set tSC = oException.AsStatus() }")
			Do oMethodExecute.Implementation.WriteLine(" Quit tSC")

			//
			// METHOD FETCH
			//
			Set oMethodFetch = ##class(%Dictionary.MethodDefinition).%New()
			Set oMethodFetch.parent=oGeneratedClass
			Set oMethodFetch.Name=pABTName_"GetFeaturesFetch"
			Set oMethodFetch.ClassMethod=1
			Set oMethodFetch.FormalSpec="&qHandle:%Binary,&Row:%List,&AtEnd:%Integer=0"
			Set oMethodFetch.ReturnType="%Status"
			Do oMethodFetch.Implementation.WriteLine(" Set tSC = $$$OK")
			Do oMethodFetch.Implementation.WriteLine(" Try {")

			// FUTURE: Default values should be different accordingly to flag that defines if this ABT is for decision tress or neural networks
			//		   There is an additional one-hot-encoding to be done on single star table references.
			Do oMethodFetch.Implementation.WriteLine("   Set Row=^PublishedABT("""_pABTName_""",""DEFAULTVALUES"")")
			Do oMethodFetch.Implementation.WriteLine("   Set oRS = qHandle(""RS"")")
			Do oMethodFetch.Implementation.WriteLine("   If oRS.%Next(.tSC) {")

			//For every column I care about...
			Set tFactTablePropertyName = ""
			For
			{
				Set tFactTablePropertyName = $Order(^PublishedABT(pABTName,"PMap1",tFactTablePropertyName))
				Quit:tFactTablePropertyName=""
				
				Set tStarTableName=^PublishedABT(pABTName,"PMap1",tFactTablePropertyName)
				Do oMethodFetch.Implementation.WriteLine()
				
				// Is this a measure or a single star table reference?
				// FUTURE: Here is where we should consider the flag to do one-hot-encoding of single star table references
				
				If tStarTableName=""
				{
					If '$Data(^PublishedABT(pABTName,"Dropped",tFactTablePropertyName))
					{
						Set iColumnIndex=^PublishedABT(pABTName,"PMap2",tFactTablePropertyName)
						Set ^PublishedABT(pABTName,"DataPrepCode",tFactTablePropertyName) = "oRS.%Get("""_tFactTablePropertyName_""")"
						
						For tStepNumber = 1:1:$Get(^PublishedABT(pABTName,"N_PREP_STEPS",tFactTablePropertyName),0)
						{
							Do $ClassMethod(^PublishedABT(pABTName,"PREP_STEP",tFactTablePropertyName,tStepNumber),"GetExpression",pABTName,tFactTablePropertyName)
						}
					Do oMethodFetch.Implementation.WriteLine("     Set $List(Row,"_iColumnIndex_") = "_^PublishedABT(pABTName,"DataPrepCode",tFactTablePropertyName))
					}
				}
				Else
				{
					Do oMethodFetch.Implementation.WriteLine("     //"_tFactTablePropertyName)
					Do oMethodFetch.Implementation.WriteLine("     Set tColumnValue = oRS.%Get("""_tFactTablePropertyName_""")")

					//tColumnValue is a list of IDs on the tStarTableName
					Do oMethodFetch.Implementation.WriteLine("     Set listRS = ##class(%SQL.Statement).%ExecDirect(,""SELECT * from "_tStarTableName_" Where ID IN ( ""_tColumnValue_"" )"")")
					Do oMethodFetch.Implementation.WriteLine("     $$$ThrowSQLExceptionIfResultError(listRS, ""StarTableFetchException"")")
					
					Do oMethodFetch.Implementation.WriteLine("     While listRS.%Next() {")
					Do oMethodFetch.Implementation.WriteLine("       Set explodedPropertySuffix = listRS.%Get("""_tFactTablePropertyName_""")")
					Do oMethodFetch.Implementation.WriteLine("       If explodedPropertySuffix '= ""<null>"" {")
					Do oMethodFetch.Implementation.WriteLine("         Set explodedPropertySuffix = ##class(ML.ABT.Utils).NormalizeColumnName(explodedPropertySuffix)")
					Do oMethodFetch.Implementation.WriteLine("         Set fullExplodedPropertyName = """_tFactTablePropertyName_"_""_explodedPropertySuffix")
					Do oMethodFetch.Implementation.WriteLine("         Set iColumnIndex = ^PublishedABT("""_pABTName_""",""PMap1"","""_tFactTablePropertyName_""", fullExplodedPropertyName)")
					//One is the positive One_Hot_Encoding Value
					Do oMethodFetch.Implementation.WriteLine("         Set $List(Row,iColumnIndex)=1")
					Do oMethodFetch.Implementation.WriteLine("       }") 
					Do oMethodFetch.Implementation.WriteLine("     }") 
				}
			}

			Do oMethodFetch.Implementation.WriteLine("   } Else {")
			Do oMethodFetch.Implementation.WriteLine("     $$$ThrowStatusExceptionIfError(tSC, ""ABTFactTableFetchException"")")
			Do oMethodFetch.Implementation.WriteLine("     Set AtEnd=1")
			Do oMethodFetch.Implementation.WriteLine("     Set Row=""""")
			Do oMethodFetch.Implementation.WriteLine("   }")

			Do oMethodFetch.Implementation.WriteLine(" } Catch (oException) { Set tSC = oException.AsStatus() }")
			Do oMethodFetch.Implementation.WriteLine(" Quit tSC")

			Set tSC = oGeneratedClass.%Save()
			Quit:$$$ISERR(tSC)
			
			Set tSC = $System.OBJ.Compile(tGeneratedClassName,"ck")
			
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
				
		Quit tSC	
	}

	ClassMethod RunModelOnABTSourceId(pPublishedABTName As %String, pSourceID As %String, pModel As %DeepSee.PMML.Model.AbstractModel, pModelDataOutput, pSynchronizeFirst As %Boolean = 0)
	{
		Set tSC = $$$OK
		
		Try{
		
			If pSynchronizeFirst
			{
				Set tCubeName=^PublishedABT(pPublishedABTName, "CUBENAME")
				Set tSC = ##class(%DeepSee.Utils).%ProcessFact(tCubeName,pSourceID, 0)
				$$$ThrowStatusExceptionIfError(tSC, "RunModelOnABTSourceIdException")
			}
	
			Set pFeaturesStmt = ##class(%SQL.Statement).%New()
			Set tSC = pFeaturesStmt.%PrepareClassQuery("PublishedABT."_pPublishedABTName, pPublishedABTName_"GetFeatures")
			$$$ThrowStatusExceptionIfError(tSC, "RunModelOnABTSourceIdException")
	
			Set oRS = pFeaturesStmt.%Execute(pSourceID)
			$$$ThrowSQLExceptionIfResultError(oRS, "StarTableFetchException")
			
			Kill tInput
			If oRS.%Next() 
			{
				Set metaData = oRS.%GetMetaData()
				For i=1:1:metaData.columns.Count() 
				{
					Set metaColumn = metaData.columns.GetAt(i)
					Set tInput(metaColumn.colName) = oRS.%Get(metaColumn.colName)
				}
				
			}
	
			Set tSC = pModel.%ExecuteModel(.tInput, .pModelDataOutput)
			$$$ThrowStatusExceptionIfError(tSC, "RunModelOnABTSourceIdException")
			
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Quit tSC
	}
}