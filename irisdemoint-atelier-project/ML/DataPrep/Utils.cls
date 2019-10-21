Include (%DeepSee, DEMOMACROS)

Class ML.DataPrep.Utils
{
ClassMethod Parse(pDataPrep As %String)
{
	Set tPrepList = ..ParseString(pDataPrep, "=")
	If $List(tPrepList,1) = "" Quit $lb(0,0)
	Quit ..Sort($List(tPrepList,1),$List(tPrepList,2))
}
ClassMethod ParseString(pDataPrep As %String, pParseUsing As %String)
{
	Set tNumItems = $Length(pDataPrep,pParseUsing) - 1
	If tNumItems < 1 Quit $ListBuild("","")
	Set tItems = $ListBuild()
	Set tItemDetails = $ListBuild()
	For i = 1:1:tNumItems
	{
		Set $List(tItems,i) = $Piece($Piece(pDataPrep,pParseUsing,i),",",*)
		If i=tNumItems
		{
			Set $List(tItemDetails,i) = $Piece(pDataPrep,pParseUsing,(i+1))
		}
		Else
		{
			Set $List(tItemDetails,i) = $Piece($Piece(pDataPrep,pParseUsing,(i+1)),",",1,*-1)
		}
		If ($Extract($List(tItemDetails,i),1) = "(") && ($Extract($List(tItemDetails,i),*)=")")
		{
			Set $List(tItemDetails,i) = $Extract($List(tItemDetails,i),2,*-1)
		}
	}
	Quit $ListBuild(tItems,tItemDetails)
}

ClassMethod Sort(pMethods As %List, pMethodDetails As %List)
{
	Set tNumMethods = $ListLength(pMethods)
	// tPriority is a list containing those methods which must be performed before (or instead of) the others, in order.
	Set tPriority = $ListBuild("Drop","Skip","NaReplace")
	Set tOrder = $ListBuild()
	Set tPrioritySetting = 1
	For i = 1:1:$ListLength(tPriority)
	{
		Set tInMethodNumber = $ListFind(pMethods,$List(tPriority,i))
		If tInMethodNumber
		{
			Set $List(tOrder,tPrioritySetting) = tInMethodNumber
			Set tPrioritySetting = tPrioritySetting + 1
		}
	}
	For i = 1:1:$ListLength(pMethods)
	{
		If '$ListFind(tPriority,$List(pMethods,i))
		{
			Set $List(tOrder,tPrioritySetting) = i
			Set tPrioritySetting = tPrioritySetting + 1
		}
	}
	Quit $ListBuild(..Reorder(pMethods,tOrder),..Reorder(pMethodDetails,tOrder))
}

ClassMethod Reorder(toReorder As %List, Indices As %List)
{
	If $ListLength(toReorder) '= $ListLength(Indices) $$$ThrowException("NonMatchingLists", "Length of list and index list for reordering is not the same.")
	Set tResult = $ListBuild()
	For i = 1:1:$ListLength(toReorder)
	{
		Set $List(tResult,i) = $List(toReorder,$List(Indices,i))
	}
	Quit tResult
}

ClassMethod DetailSearch(pColumn As %String, pMethodDetails As %String)
{
	Set tResult = $ListBuild(0)
	If $Length(pMethodDetails,":")>1
	{
		Set tDetails = ..ParseString(pMethodDetails,":")
		For i = 1:1:$ListLength($List(tDetails,1))
		{
			If $ListFind($ListFromString($List($List(tDetails,2),i),","),pColumn)
			{
				set tResult = $ListBuild(1,$List($List(tDetails,1),i))
			}
		}
		For i = 1:1:$ListLength($List(tDetails,1))
		{
			If $ListFind($ListFromString($List($List(tDetails,2),i),","),"*")
			{
				set tResult = $ListBuild(1,$List($List(tDetails,1),i))
			}
		}
	}
	Else
	{
		If ($Extract(pMethodDetails,1)="(") && ($Extract(pMethodDetails,*)=")")
		{
			Set tDetails = $ListFromString($Extract(pMethodDetails,2,*-1),",")
		}
		Else
		{
			Set tDetails = $ListFromString(pMethodDetails,",")
		}
		If $ListFind(tDetails,pColumn) || $ListFind(tDetails,"*")
		{
			set tResult = $ListBuild(1,"")
		}
	}
	Quit tResult

}

ClassMethod DeleteFromStringList(pString As %String, pIndex As %Integer)
{
	Set tString1 = $Piece(pString,",",1,pIndex-1)
	Set tString2 = $Piece(pString,",",pIndex+1,*)
	If $Length(tString1) && $Length(tString2)
	{
		Quit tString1_","_tString2
	}
	Else
	{
		Quit tString1_tString2
	}
}

ClassMethod DeleteFromList(pList As %List, pIndex As %Integer)
{
	If pIndex = 1
	{
		Quit $List(pList,2,*)
	}
	Set tLength = $ListLength(pList)
	If pIndex = tLength
	{
		Quit $List(pList,1,pIndex-1)
	}
	ElseIf pIndex < tLength
	{
		Quit ($List(pList,1,pIndex-1)_$List(pList,pIndex+1,*))
	}
	Else
	{
		$$$ThrowException("IndexError","Index out of bounds for list in DeleteFromList")
	}
}

ClassMethod PrepareAll(pABTName As %String, pDataPrepLists As %List)
{
	Set tFactTablePropertyName = ""
	For
	{
		Set tFactTablePropertyName = $Order(^PublishedABT(pABTName,"PMap1",tFactTablePropertyName))
		Quit:tFactTablePropertyName=""
		
		Set tStarTableName=^PublishedABT(pABTName,"PMap1",tFactTablePropertyName)
		If tStarTableName=""
		{
			If $ListValid($List(pDataPrepLists,1))
			{
				For tStepNumber = 1:1:$ListLength($List(pDataPrepLists,1))
				{
					Do $ClassMethod("ML.DataPrep."_$List($List(pDataPrepLists,1),tStepNumber), "Prepare", pABTName, tFactTablePropertyName, $List($List(pDataPrepLists,2),tStepNumber))
				}
			}
			Else
			{
				Set ^PublishedABT(pABTName,"N_PREP_STEPS",tFactTablePropertyName) = 0
			}
		}
	}
}
}