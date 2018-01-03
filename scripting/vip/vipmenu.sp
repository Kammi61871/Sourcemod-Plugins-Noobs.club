new const String:g_sToggleStatus[][] =
{
	"DISABLED",
	"ENABLED",
	"NO_ACCESS"
};

AddFeatureToVIPMenu(const String:sFeatureName[])
{
	DebugMessage("AddFeatureToVIPMenu: %s", sFeatureName)
	if(g_hSortArray != INVALID_HANDLE)
	{
		ResortFeaturesArray();

		RemoveAllMenuItems(g_hVIPMenu);

		decl i, iSize, String:sItemInfo[128], Handle:hArray;
		iSize = GetArraySize(GLOBAL_ARRAY);
		for(i = 0; i < iSize; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sItemInfo, sizeof(sItemInfo));
			if(GetTrieValue(GLOBAL_TRIE, sItemInfo, hArray) && VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) != HIDE)
			{
				DebugMessage("AddMenuItem: %s", sItemInfo)
				AddMenuItem(g_hVIPMenu, sItemInfo, sItemInfo);
			}
		}
	}
	else
	{
		DebugMessage("AddMenuItem")
		AddMenuItem(g_hVIPMenu, sFeatureName, sFeatureName);
	}	
}

ResortFeaturesArray()
{
	DebugMessage("ResortFeaturesArray\n \n ")

	if(GetArraySize(GLOBAL_ARRAY) < 2)
	{
		return;
	}
	
	decl i, x, iSize, index, String:sItemInfo[128];
	iSize = GetArraySize(g_hSortArray);

	#if DEBUG_MODE 1
	PrintArray(g_hSortArray);
	PrintArray(GLOBAL_ARRAY);
	#endif

	x = 0;
	for(i = 0; i < iSize; ++i)
	{
		GetArrayString(g_hSortArray, i, sItemInfo, sizeof(sItemInfo));
		DebugMessage("GetSortArrayString: %s (i: %i, x: %i)", sItemInfo, i, x)
		index = FindStringInArray(GLOBAL_ARRAY, sItemInfo);
		DebugMessage("FindStringInGlobalArray: index: %i", index)
		if(index != -1)
		{
			if(index != x)
			{
				DebugMessage("SwapArrayItems")
				SwapArrayItems(GLOBAL_ARRAY, index, x);
				#if DEBUG_MODE 1
				PrintArray(GLOBAL_ARRAY);
				#endif
			}

			++x;
		}
	}
}

#if DEBUG_MODE 1
stock PrintArray(&Handle:hArray)
{
	DebugMessage("PrintArray")
	decl i, iSize, String:sItemInfo[128];
	iSize = GetArraySize(hArray);
	if(iSize)
	{
		for(i = 0; i < iSize; ++i)
		{
			GetArrayString(hArray, i, sItemInfo, sizeof(sItemInfo));
			DebugMessage("%i: %s", i, sItemInfo)
		}
	}
}
#endif

public Handler_VIPMenu(Handle:hMenu, MenuAction:action, iClient, iOption)
{
	static String:sItemInfo[FEATURE_NAME_LENGTH], Handle:hBuffer, Function:Function_Call, Handle:hPlugin;
	/*
	switch(action)
	{
		case MenuAction_Display, MenuAction_DrawItem, MenuAction_DisplayItem, MenuAction_Select:
		{
			if(!(g_iClientInfo[iClient] & IS_VIP))
			{
				CancelMenu(g_hVIPMenu);
				DisplayClientInfo(iClient, "expired_info");
				return 0;
			}
		}
	}
	*/
	switch(action)
	{
		case MenuAction_Cancel:
		{
			UNSET_BIT(g_iClientInfo[iClient], IS_MENU_OPEN);
		}
		case MenuAction_Display:
		{
			SET_BIT(g_iClientInfo[iClient], IS_MENU_OPEN);

			DebugMessage("MenuAction_Display: Client: %i", iClient)
			decl String:sTitle[256], iExp;
			if(GetTrieValue(g_hFeatures[iClient], KEY_EXPIRES, iExp) && iExp > 0)
			{
				decl iTime;
				if((iTime = GetTime()) < iExp)
				{
					decl String:sExpires[64];
					UTIL_GetTimeFromStamp(sExpires, sizeof(sExpires), iExp-iTime, iClient);
					FormatEx(sTitle, sizeof(sTitle), "%T\n \n%T: %s\n \n", "VIP_MENU_TITLE", iClient, "EXPIRES_IN", iClient, sExpires);
				}
				else
				{
				//	FakeClientCommand(iClient, "menuselect 0");
					DisplayClientInfo(iClient, "expired_info");
					Clients_ExpiredClient(iClient);
					return 0;
				}
			}
			else
			{
				FormatEx(sTitle, sizeof(sTitle), "%T\n \n", "VIP_MENU_TITLE", iClient);
			}

			SetPanelTitle(Handle:iOption, sTitle);
		}

		case MenuAction_DrawItem:
		{
			decl iStyle;
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo), iStyle);

			DebugMessage("MenuAction_DrawItem: Client: %i, Feature: %s, iStyle: %i", iClient, sItemInfo, iStyle)
	
			if(GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				if(VIP_ValueType:GetArrayCell(hBuffer, FEATURES_VALUE_TYPE) != VIP_NULL && Features_GetStatus(iClient, sItemInfo) == NO_ACCESS)
				{
					iStyle = g_CVAR_bHideNoAccessItems ? ITEMDRAW_RAWLINE:ITEMDRAW_DISABLED;
					DebugMessage("NO_ACCESS -> iStyle: %i", iStyle)
				}

				Function_Call = Function:GetArrayCell(hBuffer, FEATURES_ITEM_DRAW);
				if (Function_Call != INVALID_FUNCTION)
				{
					hPlugin = Handle:GetArrayCell(hBuffer, FEATURES_PLUGIN);
					DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
					if(GetPluginStatus(hPlugin) == Plugin_Running)
					{
						Call_StartFunction(hPlugin, Function_Call);
						Call_PushCell(iClient);
						Call_PushString(sItemInfo);
						Call_PushCell(iStyle);
						Call_Finish(iStyle);
						DebugMessage("Function_Draw -> iStyle: %i", iStyle)
					}
				}
			}

			DebugMessage("return iStyle: %i", iStyle)

			return iStyle;	
		}
		
		case MenuAction_DisplayItem:
		{
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo));
			
			DebugMessage("MenuAction_DisplayItem: Client: %i, Feature: %s", iClient, sItemInfo)

			decl String:sDisplay[128];

			if(GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				Function_Call = Function:GetArrayCell(hBuffer, FEATURES_ITEM_DISPLAY);
				if (Function_Call != INVALID_FUNCTION)
				{
					hPlugin = Handle:GetArrayCell(hBuffer, FEATURES_PLUGIN);
					DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
					if(GetPluginStatus(hPlugin) == Plugin_Running)
					{
						sDisplay[0] = 0;
						decl bool:bResult;
						Call_StartFunction(hPlugin, Function_Call);
						Call_PushCell(iClient);
						Call_PushString(sItemInfo);
						Call_PushStringEx(sDisplay, sizeof(sDisplay), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
						Call_PushCell(sizeof(sDisplay));
						Call_Finish(bResult);
						
						DebugMessage("Function_Display: bResult: %b", bResult)
						
						if(bResult == true)
						{
							return RedrawMenuItem(sDisplay);
						}
					}
				}

				if(VIP_FeatureType:GetArrayCell(hBuffer, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					FormatEx(sDisplay, sizeof(sDisplay), "%T [%T]", sItemInfo, iClient, g_sToggleStatus[_:Features_GetStatus(iClient, sItemInfo)], iClient);
					return RedrawMenuItem(sDisplay);
				}

				FormatEx(sDisplay, sizeof(sDisplay), "%T", sItemInfo, iClient);

				return RedrawMenuItem(sDisplay);
			}
			else if(strcmp(sItemInfo, "NO_FEATURES") == 0)
			{
				FormatEx(sItemInfo, sizeof(sItemInfo), "%T", "NO_FEATURES", iClient);
			}

			return RedrawMenuItem(sItemInfo);
		}
		
		case MenuAction_Select:
		{
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo));

			if(GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				DebugMessage("MenuAction_Select: Client: %i, Feature: %s", iClient, sItemInfo)

				Function_Call = Function:GetArrayCell(hBuffer, FEATURES_ITEM_SELECT);
				hPlugin = Handle:GetArrayCell(hBuffer, FEATURES_PLUGIN);
				DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
				if(VIP_FeatureType:GetArrayCell(hBuffer, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					decl String:sBuffer[4], VIP_ToggleState:OldStatus, VIP_ToggleState:NewStatus;
					OldStatus = Features_GetStatus(iClient, sItemInfo);
					NewStatus = (OldStatus == ENABLED) ? DISABLED:ENABLED;
					if(Function_Call != INVALID_FUNCTION && GetPluginStatus(hPlugin) == Plugin_Running)
					{
						NewStatus = Function_OnItemToggle(hPlugin, Function_Call, iClient, sItemInfo, OldStatus, NewStatus);
					}
					Features_SetStatus(iClient, sItemInfo, NewStatus);
					IntToString(_:NewStatus, sBuffer, sizeof(sBuffer));
					SetClientCookie(iClient, Handle:GetArrayCell(hBuffer, FEATURES_COOKIE), sBuffer);
				}
				else
				{
					if(Function_Call != INVALID_FUNCTION && GetPluginStatus(hPlugin) == Plugin_Running && Function_OnItemSelect(hPlugin, Function_Call, iClient, sItemInfo) == false)
					{
						return 0;
					}
				}

				DisplayMenuAtItem(hMenu, iClient, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
				PlaySound(iClient, ITEM_TOGGLE_SOUND);
			}
		}
	}

	return 0;
}

VIP_ToggleState:Function_OnItemToggle(Handle:hPlugin, Function:ToggleFunction, iClient, const String:sItemInfo[], const VIP_ToggleState:OldStatus, const VIP_ToggleState:NewStatus)
{
	decl VIP_ToggleState:ResultStatus, Action:aResult;
	ResultStatus = NewStatus;
	Call_StartFunction(hPlugin, ToggleFunction);
	Call_PushCell(iClient);
	Call_PushString(sItemInfo);
	Call_PushCell(OldStatus);
	Call_PushCellRef(ResultStatus);
	Call_Finish(aResult);
	
	switch(aResult)
	{
		case Plugin_Continue:
		{
			return NewStatus;
		}
		case Plugin_Changed:
		{
			return ResultStatus;
		}
		case Plugin_Handled, Plugin_Stop:
		{
			return OldStatus;
		}
		default:
		{
			return ResultStatus;
		}
	}
	
	return ResultStatus;
}

bool:Function_OnItemSelect(Handle:hPlugin, Function:SelectFunction, iClient, const String:sItemInfo[])
{
	decl bool:bResult;
	Call_StartFunction(hPlugin, SelectFunction);
	Call_PushCell(iClient);
	Call_PushString(sItemInfo);
	Call_Finish(bResult);
	
	return bResult;
}

bool:IsValidFeature(const String:sFeatureName[])
{
	DebugMessage("IsValidFeature:: FindStringInArray -> %i", FindStringInArray(GLOBAL_ARRAY, sFeatureName))
	return (FindStringInArray(GLOBAL_ARRAY, sFeatureName) != -1);
}

bool:OnVipMenuFlood(iClient)
{
	static Float:fLastTime[MAXPLAYERS+1];
	if(fLastTime[iClient] > 0.0)
	{
		new Float:fSec = GetGameTime();
		if ((fSec - fLastTime[iClient]) < 3.0) return true;
		fLastTime[iClient] = fSec;
	}
	return false;
}