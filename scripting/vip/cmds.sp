public OnConfigsExecuted()
{
	static bool:bIsRegistered;
	if(bIsRegistered == false)
	{
		UTIL_LoadVipCmd(g_CVAR_hVIPMenu_CMD, VIPMenu_CMD);

		bIsRegistered = true;
	}
}

public Action:VIPAdmin_CMD(iClient, args)
{
	if(iClient)
	{
		DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

public Action:ReloadVIPPlayers_CMD(iClient, args)
{
	if(iClient && !(GetUserFlagBits(iClient) & g_CVAR_iAdminFlag))
	{
		ReplyToCommand(iClient, "[VIP] %t", "COMMAND_NO_ACCESS");
		return Plugin_Handled;
	}

	UTIL_ReloadVIPPlayers(iClient, true);

	return Plugin_Handled;
}

public Action:ReloadVIPCfg_CMD(iClient, args)
{
	if(iClient && !(GetUserFlagBits(iClient) & g_CVAR_iAdminFlag))
	{
		ReplyToCommand(iClient, "[VIP] %t", "COMMAND_NO_ACCESS");
		return Plugin_Handled;
	}

	ReadConfigs();
	UTIL_ReloadVIPPlayers(iClient, false);
	ReplyToCommand(iClient, "[VIP] %t", "VIP_CFG_REFRESHED");

	return Plugin_Handled;
}

public Action:AddVIP_CMD(iClient, args)
{
	if(iClient && !(GetUserFlagBits(iClient) & g_CVAR_iAdminFlag))
	{
		ReplyToCommand(iClient, "[VIP] %t", "COMMAND_NO_ACCESS");
		return Plugin_Handled;
	}

	if(args < 2)
	{
		ReplyToCommand(iClient, "[VIP] %t!\nSyntax: sm_addvip <steam|ip|name> <steam_id|ip|name|#userid> [time] [group]", "INCORRECT_USAGE");
		return Plugin_Handled;
	}
	
	decl String:sAuth[64], VIP_AuthType:AuthType;
	GetCmdArg(1, sAuth, sizeof(sAuth));

	if(!strcmp(sAuth, "steam"))		AuthType = AUTH_STEAM;
	else if(!strcmp(sAuth, "ip"))	AuthType = AUTH_IP;
	else if(!strcmp(sAuth, "name"))	AuthType = AUTH_NAME;
	else
	{
		ReplyToCommand(iClient, "[VIP] %t", "INCORRECT_ID");
		return Plugin_Handled;
	}

	decl iTarget;
	GetCmdArg(2, sAuth, sizeof(sAuth));

	iTarget = FindTarget(iClient, sAuth, true, false);
	if(iTarget != -1)
	{
		if(g_iClientInfo[iTarget] & IS_VIP || g_iClientInfo[iTarget] & IS_AUTHORIZED)
		{
			ReplyToCommand(iClient, "[VIP] %t", "ALREADY_HAS_VIP");
			return Plugin_Handled;
		}
		sAuth[0] = 0;
	}
	else
	{
		iTarget = 0;
	}

	decl String:sBuffer[64];
	new iTime = 0;
	if(args > 2)
	{
		GetCmdArg(3, sBuffer, sizeof(sBuffer));
		StringToIntEx(sBuffer, iTime);
		if(iTime < 0)
		{
			ReplyToCommand(iClient, "[VIP] %t", "INCORRECT_TIME");
			return Plugin_Handled;
		}
	}

	sBuffer[0] = 0;
	if(args > 3)
	{
		GetCmdArg(4, sBuffer, sizeof(sBuffer));
		if(sBuffer[0] && UTIL_CheckValidVIPGroup(sBuffer) == false)
		{
			ReplyToCommand(iClient, "%t", "VIP_GROUP_DOES_NOT_EXIST");
			return Plugin_Handled;
		}
	}

	UTIL_ADD_VIP_PLAYER(iClient, iTarget, sAuth, UTIL_TimeToSeconds(iTime), AuthType, sBuffer);

	return Plugin_Handled;
}

public Action:DelVIP_CMD(iClient, args)
{
	if(iClient && !(GetUserFlagBits(iClient) & g_CVAR_iAdminFlag))
	{
		ReplyToCommand(iClient, "[VIP] %t", "COMMAND_NO_ACCESS");
		return Plugin_Handled;
	}

	if(args < 1)
	{
		ReplyToCommand(iClient, "%t!\nSyntax: sm_delvip <identity>", "INCORRECT_USAGE");
		return Plugin_Handled;
	}
	
	decl String:sQuery[512], String:sAuth[MAX_NAME_LENGTH];
	GetCmdArg(1, sAuth, sizeof(sAuth));

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id` \
											FROM `vip_users` AS `u` \
											LEFT JOIN `vip_users_overrides` AS `o` \
											ON `o`.`user_id` = `u`.`id` \
											WHERE `o`.`server_id` = '%i' \
											AND `u`.`auth` = '%s' LIMIT 1;", g_CVAR_iServerID, sAuth);
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id` \
											FROM `vip_users` \
											WHERE `auth` = '%s' LIMIT 1;", sAuth);
	}

	DebugMessage(sQuery)
	if(iClient)
	{
		iClient = UID(iClient);
	}

	SQL_TQuery(g_hDatabase, SQL_Callback_OnSelectRemoveClient, sQuery, iClient);

	return Plugin_Handled;
}

public SQL_Callback_OnSelectRemoveClient(Handle:hOwner, Handle:hQuery, const String:sError[], any:iClient)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_OnSelectRemoveClient: %s", sError);
	}
	
	if(iClient)
	{
		iClient = CID(iClient);
	}

	if (SQL_FetchRow(hQuery))
	{
		DB_RemoveClientFromID(iClient, SQL_FetchInt(hQuery, 0), true);
	}
	else
	{
		ReplyToCommand(iClient, "%t", "FIND_THE_ID_FAIL");
	}
}

public Action:VIPMenu_CMD(iClient, args)
{
	if(iClient)
	{
		if(OnVipMenuFlood(iClient) == false)
		{
			if(g_iClientInfo[iClient] & IS_VIP)
			{
				DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
			}
			else
			{
				/*
				PrintToChat(iClient, "%t%t", "VIP_CHAT_PREFIX", "COMMAND_NO_ACCESS");
				*/

				PlaySound(iClient, NO_ACCESS_SOUND);
				DisplayClientInfo(iClient, "no_access_info");
			}
		}
	}
	return Plugin_Handled;
}