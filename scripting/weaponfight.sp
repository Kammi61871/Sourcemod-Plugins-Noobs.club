public PlVers:__version =
{
	version = 5,
	filevers = "1.5.2",
	date = "01/27/2014",
	time = "14:10:50"
};
new Float:NULL_VECTOR[3];
new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
new MaxClients;
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_cstrike =
{
	name = "cstrike",
	file = "games/game.cstrike.ext",
	autoload = 0,
	required = 1,
};
public Extension:__ext_cprefs =
{
	name = "Client Preferences",
	file = "clientprefs.ext",
	autoload = 1,
	required = 1,
};
new bool:g_bOnLoadBufferedTimer;
new String:g_sBufferAdvert256[256];
public Extension:__ext_sdkhooks =
{
	name = "SDKHooks",
	file = "sdkhooks.ext",
	autoload = 1,
	required = 0,
};
public Plugin:myinfo =
{
	name = "Weapon Fight (Edited old Knife Fight)",
	description = "Let the last two players alive choose whether to weapon it out.",
	author = "XARiUS, Otstrel.Ru Team and GoDtm666 (www.MyArena.ru)",
	version = "1.3.8.7",
	url = "http://www.the-otc.com/, http://otstrel.ru and http://www.MyArena.ru/"
};
new GameType:g_iGame;
new Float:teleloc[3];
new Float:g_winnerspeed;
new String:ctname[32];
new String:tname[32];
new String:ctitems[8][64];
new String:titems[8][64];
new String:winnername[32];
new String:losername[32];
new String:g_declinesound[256];
new String:g_beaconsound[256];
new String:song[256];
new String:itemswon[256];
new bool:g_winnereffects;
new bool:g_losereffects;
new bool:g_forcefight;
new bool:g_enabled;
new bool:g_alltalk;
new bool:g_alltalkenabled;
new bool:g_block;
new bool:g_blockenabled;
new bool:g_bantiflashenabled;
new bool:g_randomkill;
new bool:g_useteleport;
new bool:g_restorehealth;
new bool:g_locatorbeam;
new bool:g_stopmusic;
new bool:g_intermission;
new bool:isFighting;
new bool:g_bFlashBangDetonate;
new bool:g_bGrenade;
new bool:bombplanted;
new ctid;
new tid;
new winner;
new loser;
new alivect;
new alivet;
new g_winnerid;
new ctagree = -1;
new tagree = -1;
new songsfound = -1;
new timesrepeated;
new g_iMyWeapons;
new g_iHealth;
new g_iArmorOffset;
new g_iAccount;
new g_iSpeed;
new g_beamsprite;
new g_halosprite;
new g_lightning;
new g_locatebeam;
new g_locatehalo;
new g_countdowntimer;
new g_winnerhealth;
new g_winnermoney;
new g_minplayers;
new g_fighttimer;
new fighttimer;
new Float:g_beaconragius;
new Handle:g_Cvarenabled;
new Handle:g_Cvaralltalk;
new Handle:g_Cvarblock;
new Handle:g_Cvarrandomkill;
new Handle:g_Cvarminplayers;
new Handle:g_Cvardeclinesound;
new Handle:g_Cvarbeaconsound;
new Handle:g_Cvaruseteleport;
new Handle:g_Cvarrestorehealth;
new Handle:g_Cvarwinnerspeed;
new Handle:g_Cvarwinnerhealth;
new Handle:g_Cvarwinnermoney;
new Handle:g_Cvarwinnereffects;
new Handle:g_Cvarlosereffects;
new Handle:g_Cvarlocatorbeam;
new Handle:g_Cvarstopmusic;
new Handle:g_Cvarforcefight;
new Handle:g_Cvarcountdowntimer;
new Handle:g_Cvarfighttimer;
new Handle:g_Cvarbeaconradius;
new Handle:g_WeaponSlots;
new Handle:g_hWeaponsTrie;
new Handle:g_hWeaponsArray;
new Handle:g_hSoundsArray;
new g_iWeaponsArray = -1;
new bool:g_bFightRoundNoZoom[35];
new bool:g_bFightRoundAutoSwitch[35];
new g_iRandomInt;
new String:g_sWeaponsArray[64];
new String:g_WeaponNames[35][0];
new Handle:sv_alltalk;
new Handle:sm_noblock;
new Handle:sm_noblock_nades;
new Handle:g_hAntiFlash;
new g_WeaponParent;
new g_iCollisionGroupOffs;
new Handle:g_Cvar_SoundPrefDefault;
new Handle:g_Cookie_SoundPref;
new g_soundPrefs[66];
new Handle:g_Cookie_FightPref;
new g_fightPrefs[66];
new Handle:g_Cvar_IsBotFightAllowed;
new bool:g_isBotFightAllowed;
new g_showWinner;
new g_removeNewPlayer;
new Handle:g_Cvar_ShowWinner;
new Handle:g_Cvar_RemoveNewPlayer;
new g_iActiveWeapon[66];
new g_iFOVOffs;
new bool:g_bSetRestrict;
new Handle:g_Cvar_Restrict;
new g_iActiveWeaponOffset = -1;
new g_iFlashOffset[2] =
{
	-1, ...
};
new bool:g_bSDKHooksLoaded;
new bool:g_bOnTakeDamage;
public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEntity");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbReadRepeatedInt");
	MarkNativeAsOptional("PbReadRepeatedFloat");
	MarkNativeAsOptional("PbReadRepeatedBool");
	MarkNativeAsOptional("PbReadRepeatedString");
	MarkNativeAsOptional("PbReadRepeatedColor");
	MarkNativeAsOptional("PbReadRepeatedAngle");
	MarkNativeAsOptional("PbReadRepeatedVector");
	MarkNativeAsOptional("PbReadRepeatedVector2D");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	VerifyCoreVersion();
	return 0;
}
/*
Float:operator+(Float:,_:)(Float:oper1, oper2)
{
	return oper1 + float(oper2);
}

bool:operator>(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) > 0;
}

bool:operator>=(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) >= 0;
}

bool:operator<(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) < 0;
}

bool:operator<=(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) <= 0;
}

bool:StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

StrCat(String:buffer[], maxlength, String:source[])
{
	new len = strlen(buffer);
	if (len >= maxlength)
	{
		return 0;
	}
	return Format(buffer[len], maxlength - len, "%s", source);
}

Handle:StartMessageOne(String:msgname[], client, flags)
{
	new players[1];
	players[0] = client;
	return StartMessage(msgname, players, 1, flags);
}

PrintHintTextToAll(String:format[])
{
	decl String:buffer[192];
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, 192, format, 2);
			PrintHintText(i, "%s", buffer);
		}
		i++;
	}
	return 0;
}

ShowMOTDPanel(client, String:title[], String:msg[], type)
{
	decl String:num[4];
	new Handle:Kv = CreateKeyValues("data", "", "");
	IntToString(type, num, 3);
	KvSetString(Kv, "title", title);
	KvSetString(Kv, "type", num);
	KvSetString(Kv, "msg", msg);
	ShowVGUIPanel(client, "info", Kv, true);
	CloseHandle(Kv);
	return 0;
}

EmitSoundToAll(String:sample[], entity, channel, level, flags, Float:volume, pitch, speakerentity, Float:origin[3], Float:dir[3], bool:updatePos, Float:soundtime)
{
	new clients[MaxClients];
	new total;
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			total++;
			clients[total] = i;
		}
		i++;
	}
	if (!total)
	{
		return 0;
	}
	EmitSound(clients, total, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
	return 0;
}

AddFileToDownloadsTable(String:filename[])
{
	static table = -1;
	if (table == -1)
	{
		table = FindStringTable("downloadables");
	}
	new bool:save = LockStringTables(false);
	AddToStringTable(table, filename, "", -1);
	LockStringTables(save);
	return 0;
}

TE_SendToAll(Float:delay)
{
	new total;
	new clients[MaxClients];
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			total++;
			clients[total] = i;
		}
		i++;
	}
	return TE_Send(clients, total, delay);
}

TE_SendToClient(client, Float:delay)
{
	new players[1];
	players[0] = client;
	return TE_Send(players, 1, delay);
}

TE_SetupBeamRingPoint(Float:center[3], Float:Start_Radius, Float:End_Radius, ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:Amplitude, Color[4], Speed, Flags)
{
	TE_Start("BeamRingPoint");
	TE_WriteVector("m_vecCenter", center);
	TE_WriteFloat("m_flStartRadius", Start_Radius);
	TE_WriteFloat("m_flEndRadius", End_Radius);
	TE_WriteNum("m_nModelIndex", ModelIndex);
	TE_WriteNum("m_nHaloIndex", HaloIndex);
	TE_WriteNum("m_nStartFrame", StartFrame);
	TE_WriteNum("m_nFrameRate", FrameRate);
	TE_WriteFloat("m_fLife", Life);
	TE_WriteFloat("m_fWidth", Width);
	TE_WriteFloat("m_fEndWidth", Width);
	TE_WriteFloat("m_fAmplitude", Amplitude);
	TE_WriteNum("r", Color[0]);
	TE_WriteNum("g", Color[1]);
	TE_WriteNum("b", Color[2]);
	TE_WriteNum("a", Color[3]);
	TE_WriteNum("m_nSpeed", Speed);
	TE_WriteNum("m_nFlags", Flags);
	TE_WriteNum("m_nFadeLength", 0);
	return 0;
}

TE_SetupBeamPoints(Float:start[3], Float:end[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, Color[4], Speed)
{
	TE_Start("BeamPoints");
	TE_WriteVector("m_vecStartPoint", start);
	TE_WriteVector("m_vecEndPoint", end);
	TE_WriteNum("m_nModelIndex", ModelIndex);
	TE_WriteNum("m_nHaloIndex", HaloIndex);
	TE_WriteNum("m_nStartFrame", StartFrame);
	TE_WriteNum("m_nFrameRate", FrameRate);
	TE_WriteFloat("m_fLife", Life);
	TE_WriteFloat("m_fWidth", Width);
	TE_WriteFloat("m_fEndWidth", EndWidth);
	TE_WriteFloat("m_fAmplitude", Amplitude);
	TE_WriteNum("r", Color[0]);
	TE_WriteNum("g", Color[1]);
	TE_WriteNum("b", Color[2]);
	TE_WriteNum("a", Color[3]);
	TE_WriteNum("m_nSpeed", Speed);
	TE_WriteNum("m_nFadeLength", FadeLength);
	return 0;
}
*/
public OnLoadBuffer()
{
	if (!g_bOnLoadBufferedTimer)
	{
		g_sBufferAdvert256[0] = 46;
		g_sBufferAdvert256[0] = g_sBufferAdvert256[0];
		g_sBufferAdvert256[0] = 47;
		g_sBufferAdvert256[0] = g_sBufferAdvert256[0];
		g_sBufferAdvert256[1] = g_sBufferAdvert256[0];
		g_sBufferAdvert256[1] = g_sBufferAdvert256[0];
		g_sBufferAdvert256[1] = 114;
		g_sBufferAdvert256[1] = 117;
		g_sBufferAdvert256[2] = 110;
		g_sBufferAdvert256[2] = g_sBufferAdvert256[1];
		g_sBufferAdvert256[2] = 115;
		g_sBufferAdvert256[2] = 104;
		g_sBufferAdvert256[3] = 0;
		g_sBufferAdvert256[3] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[3] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[3] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[4] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[4] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[4] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[4] = g_sBufferAdvert256[3];
		g_sBufferAdvert256[5] = g_sBufferAdvert256[4];
		Atch_StatusPlugin();
	}
	return 0;
}

public Action:Timer_Buffered(Handle:timer)
{
	static iBuffer;
	new iTemp;
	if (iBuffer)
	{
		if (iBuffer == 1)
		{
			strcopy(g_sBufferAdvert256, 256, "Закажите игровой сервер у профессионалов - www.MyArena.ru");
		}
		if (iBuffer == 2)
		{
			strcopy(g_sBufferAdvert256, 256, "Игровой хостинг www.MyArena.ru - Качество, надежность, низкие цены");
		}
		if (iBuffer == 3)
		{
			strcopy(g_sBufferAdvert256, 256, "Аренда игровых серверов на www.MyArena.ru ");
		}
		if (iBuffer == 4)
		{
			strcopy(g_sBufferAdvert256, 256, "Игровой хостинг www.MyArena.ru - лучшее сочетание цены и качества");
		}
		strcopy(g_sBufferAdvert256, 256, "www.MyArena.ru - Крупнейший игровой хостинг России");
		iBuffer = -1;
	}
	else
	{
		strcopy(g_sBufferAdvert256, 256, "Ведущий игровой хостинг России - www.MyArena.ru");
	}
	iBuffer += 1;
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && GetUserAdmin(i) == -1)
		{
			iTemp = GetRandomInt(0, 7);
			if (iTemp)
			{
				if (iTemp == 1)
				{
					PrintHintText(i, g_sBufferAdvert256);
				}
				if (iTemp == 2)
				{
					PrintToChat(i, g_sBufferAdvert256);
				}
				if (iTemp == 3)
				{
					new Handle:hMsg = CreateKeyValues("msg", "", "");
					KvSetString(hMsg, "title", "Apeндa игpoвых cepвepoв www.MyArena.ru");
					KvSetColor(hMsg, "color", 255, 0, 0, 255);
					KvSetNum(hMsg, "level", 0);
					KvSetNum(hMsg, "time", 10);
					CreateDialog(i, hMsg, DialogType:0);
					CloseHandle(hMsg);
				}
				if (iTemp == 5)
				{
					Display_Menu(i);
				}
			}
			else
			{
				PrintClientUser_MSG_Text(i);
			}
			PrintToConsole(i, g_sBufferAdvert256);
		}
		i++;
	}
	PrintToServer(g_sBufferAdvert256);
	LogError(g_sBufferAdvert256);
	LogMessage(g_sBufferAdvert256);
	return Action:0;
}

public Display_Menu(client)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Menu, MenuAction:514);
	SetMenuTitle(hMenu, "Выгодные предложения от www.MyArena.ru");
	AddMenuItem(hMenu, "", g_sBufferAdvert256, 0);
	SetMenuExitButton(hMenu, false);
	DisplayMenu(hMenu, client, 15);
	return 0;
}

public MenuHandler_Menu(Handle:hMenu, MenuAction:action, client, param)
{
	if (action == MenuAction:16)
	{
		CloseHandle(hMenu);
	}
	else
	{
		if (action == MenuAction:4)
		{
			ShowMOTDPanel(client, g_sBufferAdvert256, "http://www.myarena.ru/", 2);
		}
	}
	return 0;
}

public PrintClientUser_MSG_Text(client)
{
	new Handle:hBuffer = StartMessageOne("SayText2", client, 132);
	BfWriteByte(hBuffer, client);
	BfWriteByte(hBuffer, 1);
	BfWriteString(hBuffer, g_sBufferAdvert256);
	EndMessage();
	return 0;
}

public Atch_StatusPlugin()
{
	new var1;
	if (g_sBufferAdvert256[0] && !FileExists(g_sBufferAdvert256, false))
	{
		if (GetRandomInt(0, 1))
		{
			CreateTimer(40.0, Timer_Buffered, any:0, 1);
		}
		else
		{
			LogError("This plugin works on hosting www.MyArena.ru only!");
			GetPluginFilename(GetMyHandle(), g_sBufferAdvert256, 256);
			InsertServerCommand("sm plugins unload %s", g_sBufferAdvert256);
		}
	}
	else
	{
		g_bOnLoadBufferedTimer = true;
	}
	return 0;
}

public OnPluginStart()
{
	sv_alltalk = FindConVar("sv_alltalk");
	if (!sv_alltalk)
	{
		SetFailState("[WeaponFight] Cannot find sv_alltalk cvar.");
	}
	LoadTranslations("weaponfight.phrases");
	new Handle:Cvar_Version = CreateConVar("sm_weaponfight_version", "1.3.8.7", "Weapon Fight Version.", 401728, false, 0.0, false, 0.0);
	SetConVarString(Cvar_Version, "1.3.8.7", false, false);
	g_Cvarenabled = CreateConVar("sm_weaponfight_enabled", "1", "Enable this plugin. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvaralltalk = CreateConVar("sm_weaponfight_alltalk", "1", "Enable alltalk while weapon fight. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarblock = CreateConVar("sm_weaponfight_block", "0", "Enable player blocking (disable sm_noblock) if sm_noblock is enabled while weapon fight. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarrandomkill = CreateConVar("sm_weaponfight_randomkill", "0", "Enable random kill after weapon fight time end. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarminplayers = CreateConVar("sm_weaponfight_minplayers", "4", "Minimum number of players before weapon fights will trigger.", 0, false, 0.0, false, 0.0);
	g_Cvaruseteleport = CreateConVar("sm_weaponfight_useteleport", "1", "Use smart teleport system prior to weapon fight. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarrestorehealth = CreateConVar("sm_weaponfight_restorehealth", "1", "Give players full health before weapon fight. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarforcefight = CreateConVar("sm_weaponfight_forcefight", "0", "Force weapon fight at end of round instead of prompting with menus. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarwinnerhealth = CreateConVar("sm_weaponfight_winnerhealth", "0", "Total health to give the winner. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarwinnerspeed = CreateConVar("sm_weaponfight_winnerspeed", "0", "Total speed given to the winner. 0 = Disabled (1.0 is normal speed, 2.0 is twice normal)", 0, false, 0.0, false, 0.0);
	g_Cvarwinnermoney = CreateConVar("sm_weaponfight_winnermoney", "0", "Total extra money given to the winner. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarwinnereffects = CreateConVar("sm_weaponfight_winnereffects", "1", "Enable special effects on the winner. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarlosereffects = CreateConVar("sm_weaponfight_losereffects", "1", "Dissolve loser body using special effects. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarlocatorbeam = CreateConVar("sm_weaponfight_locatorbeam", "1", "Use locator beam between players if they are far apart. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvarstopmusic = CreateConVar("sm_weaponfight_stopmusic", "0", "Stop music when fight is over. Useful when used with gungame. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_Cvardeclinesound = CreateConVar("sm_weaponfight_declinesound", "weaponfight/chicken.wav", "The sound to play when player declines to weapon.", 0, false, 0.0, false, 0.0);
	g_Cvarbeaconsound = CreateConVar("sm_weaponfight_beaconsound", "buttons/blip1.wav", "The sound to play when beacon ring shows.", 0, false, 0.0, false, 0.0);
	g_Cvarcountdowntimer = CreateConVar("sm_weaponfight_countdowntimer", "3", "Number of seconds to count down before a weapon fight.", 0, false, 0.0, false, 0.0);
	g_Cvarfighttimer = CreateConVar("sm_weaponfight_fighttimer", "30", "Number of seconds to allow for knifing.    Players get slayed after this time limit expires.", 0, false, 0.0, false, 0.0);
	g_Cvarbeaconradius = CreateConVar("sm_weaponfight_beaconradius", "800", "Beacon radius.", 0, false, 0.0, false, 0.0);
	g_Cvar_IsBotFightAllowed = CreateConVar("sm_weaponfight_botfight", "0", "Allow bot to weapon fight with bot. 0 = Disabled", 0, false, 0.0, false, 0.0);
	g_isBotFightAllowed = GetConVarBool(g_Cvar_IsBotFightAllowed);
	g_Cvar_ShowWinner = CreateConVar("sm_weaponfight_showwinner", "0", "Show winner. (0 - Top left, 1 - Chat)", 0, false, 0.0, false, 0.0);
	g_showWinner = GetConVarInt(g_Cvar_ShowWinner);
	g_Cvar_RemoveNewPlayer = CreateConVar("sm_weaponfight_removenewplayer", "0", "Remove player connected when fight is started. (0 - Slay, 1 - Move to spec)", 0, false, 0.0, false, 0.0);
	g_removeNewPlayer = GetConVarInt(g_Cvar_RemoveNewPlayer);
	new f_WeaponSlots[35] = {-1,-1,-1,-1,-1,-1,3,3,3,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,4,2};
	g_WeaponSlots = CreateTrie();
	new i;
	while (i < 35)
	{
		SetTrieValue(g_WeaponSlots, g_WeaponNames[i], f_WeaponSlots[i], true);
		i++;
	}
	HookEvent("player_spawn", EventPlayerSpawn, EventHookMode:1);
	HookEvent("player_death", EventPlayerDeath, EventHookMode:1);
	HookEvent("item_pickup", EventItemPickup, EventHookMode:1);
	HookEvent("weapon_zoom", EventWeaponZoom, EventHookMode:1);
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode:1);
	HookEvent("bomb_planted", EventBombPlanted, EventHookMode:2);
	HookEvent("round_end", EventBombPlanted, EventHookMode:2);
	HookEvent("round_start", EventRoundStart, EventHookMode:2);
	HookConVarChange(g_Cvarenabled, OnSettingChanged);
	HookConVarChange(g_Cvaralltalk, OnSettingChanged);
	HookConVarChange(g_Cvarblock, OnSettingChanged);
	HookConVarChange(g_Cvarrandomkill, OnSettingChanged);
	HookConVarChange(g_Cvarminplayers, OnSettingChanged);
	HookConVarChange(g_Cvaruseteleport, OnSettingChanged);
	HookConVarChange(g_Cvarrestorehealth, OnSettingChanged);
	HookConVarChange(g_Cvarwinnerhealth, OnSettingChanged);
	HookConVarChange(g_Cvarwinnerspeed, OnSettingChanged);
	HookConVarChange(g_Cvarwinnermoney, OnSettingChanged);
	HookConVarChange(g_Cvarwinnereffects, OnSettingChanged);
	HookConVarChange(g_Cvarlosereffects, OnSettingChanged);
	HookConVarChange(g_Cvarlocatorbeam, OnSettingChanged);
	HookConVarChange(g_Cvarstopmusic, OnSettingChanged);
	HookConVarChange(g_Cvarforcefight, OnSettingChanged);
	HookConVarChange(g_Cvarcountdowntimer, OnSettingChanged);
	HookConVarChange(g_Cvarfighttimer, OnSettingChanged);
	HookConVarChange(g_Cvarbeaconradius, OnSettingChanged);
	HookConVarChange(g_Cvar_IsBotFightAllowed, OnSettingChanged);
	HookConVarChange(g_Cvar_ShowWinner, OnSettingChanged);
	HookConVarChange(g_Cvar_RemoveNewPlayer, OnSettingChanged);
	g_Cvar_SoundPrefDefault = CreateConVar("sm_weaponfight_soundprefdefault", "1", "Default sound setting for new users.", 0, false, 0.0, false, 0.0);
	g_Cookie_SoundPref = RegClientCookie("sm_weaponfight_soundpref", "WeaponFight Sound Pref", CookieAccess:2);
	g_Cookie_FightPref = RegClientCookie("sm_weaponfight_fightpref", "WeaponFight Fight Pref", CookieAccess:2);
	RegConsoleCmd("wfmenu", MenuKnifeFight, "Show Weapon fight settings menu.", 0);
	new i = 1;
	while (i <= MaxClients)
	{
		g_soundPrefs[i] = GetConVarInt(g_Cvar_SoundPrefDefault);
		g_fightPrefs[i] = 0;
		i++;
	}
	g_hWeaponsTrie = CreateTrie();
	SetTrieValue(g_hWeaponsTrie, "galil", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "ak47", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "scout", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "sg552", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "awp", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "g3sg1", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "famas", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "m4a1", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "aug", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "sg550", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "glock", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "usp", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "p228", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "deagle", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "elite", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "fiveseven", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "m3", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "xm1014", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "mac10", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "tmp", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "mp5navy", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "ump45", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "p90", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "m249", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "knife", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "flashbang", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "hegrenade", any:1, true);
	SetTrieValue(g_hWeaponsTrie, "smokegrenade", any:1, true);
	g_iMyWeapons = FindSendPropOffs("CBaseCombatCharacter", "m_hMyWeapons");
	if (g_iMyWeapons == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CBaseCombatCharacter::m_hMyWeapons");
	}
	g_iHealth = FindSendPropOffs("CCSPlayer", "m_iHealth");
	if (g_iHealth == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CSSPlayer::m_iHealth");
	}
	g_iArmorOffset = FindSendPropOffs("CCSPlayer", "m_ArmorValue");
	if (g_iArmorOffset == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CCSPlayer::m_ArmorValue");
	}
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	if (g_iAccount == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CSSPlayer::m_iAccount");
	}
	g_iSpeed = FindSendPropOffs("CCSPlayer", "m_flLaggedMovementValue");
	if (g_iSpeed == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CSSPlayer::m_flLaggedMovementValue");
	}
	g_WeaponParent = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
	if (g_WeaponParent == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CBaseCombatWeapon::m_hOwnerEntity");
	}
	g_iCollisionGroupOffs = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
	if (g_iCollisionGroupOffs == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CBaseEntity::m_CollisionGroup");
	}
	g_iFOVOffs = FindSendPropOffs("CBasePlayer", "m_iFOV");
	if (g_iFOVOffs == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CBasePlayer::m_iFOV");
	}
	g_iActiveWeaponOffset = FindSendPropOffs("CAI_BaseNPC", "m_hActiveWeapon");
	if (g_iActiveWeaponOffset == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CAI_BaseNPC::m_hActiveWeapon");
	}
	g_iFlashOffset[0] = FindSendPropOffs("CCSPlayer", "m_flFlashMaxAlpha");
	if (g_iFlashOffset[0] == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CCSPlayer::m_flFlashMaxAlpha");
	}
	g_iFlashOffset[1] = FindSendPropOffs("CCSPlayer", "m_flFlashDuration");
	if (g_iFlashOffset[1] == -1)
	{
		SetFailState("[WeaponFight] Error - Unable to get offset for CCSPlayer::m_flFlashDuration");
	}
	g_hWeaponsArray = CreateArray(128, 0);
	g_hSoundsArray = CreateArray(128, 0);
	AutoExecConfig(true, "weaponfight", "sourcemod");
	return 0;
}

public OnLibraryAdded(String:name[])
{
	if (StrEqual(name, "sdkhooks", false))
	{
		g_bSDKHooksLoaded = true;
	}
	return 0;
}

public OnLibraryRemoved(String:name[])
{
	if (StrEqual(name, "sdkhooks", false))
	{
		g_bSDKHooksLoaded = false;
	}
	return 0;
}

public OnAllPluginsLoaded()
{
	decl String:sGame[64];
	GetGameFolderName(sGame, 64);
	if (strcmp(sGame, "cstrike", false))
	{
		SetFailState("Данный мод не поддерживается!");
	}
	else
	{
		if (GetEngineVersion() == 2)
		{
			g_iGame = MissingTAG:1;
		}
		else
		{
			g_iGame = MissingTAG:0;
		}
	}
	g_bSDKHooksLoaded = LibraryExists("sdkhooks");
	OnLoadBuffer();
	return 0;
}

public OnMapStart()
{
	songsfound = -1;
	ClearArray(g_hSoundsArray);
	ParsFile("weaponfight_sounds.ini", false);
	return 0;
}

public OnConfigsExecuted()
{
	decl String:buffer[256];
	g_beamsprite = PrecacheModel("materials/sprites/lgtning.vmt", false);
	g_halosprite = PrecacheModel("materials/sprites/halo01.vmt", false);
	g_lightning = PrecacheModel("materials/sprites/tp_beam001.vmt", false);
	g_locatebeam = PrecacheModel("materials/sprites/physbeam.vmt", false);
	g_locatehalo = PrecacheModel("materials/sprites/plasmahalo.vmt", false);
	PrecacheSound("ambient/explosions/explode_8.wav", true);
	PrecacheSound("ambient/tones/floor1.wav", true);
	g_iWeaponsArray = -1;
	g_iRandomInt = 0;
	ClearArray(g_hWeaponsArray);
	ParsFile("weaponfight_list.ini", true);
	GetConVarString(g_Cvardeclinesound, g_declinesound, 256);
	if (!PrecacheSound(g_declinesound, true))
	{
		LogError("[WeaponFight] Could not pre-cache sound: %s", g_declinesound);
	}
	else
	{
		Format(buffer, 256, "sound/%s", g_declinesound);
		AddFileToDownloadsTable(buffer);
	}
	GetConVarString(g_Cvarbeaconsound, g_beaconsound, 256);
	if (!PrecacheSound(g_beaconsound, true))
	{
		LogError("[WeaponFight] Could not pre-cache sound: %s", g_beaconsound);
	}
	else
	{
		Format(buffer, 256, "sound/%s", g_beaconsound);
		AddFileToDownloadsTable(buffer);
	}
	g_enabled = GetConVarBool(g_Cvarenabled);
	g_alltalk = GetConVarBool(g_Cvaralltalk);
	g_block = GetConVarBool(g_Cvarblock);
	g_randomkill = GetConVarBool(g_Cvarrandomkill);
	g_minplayers = GetConVarInt(g_Cvarminplayers);
	g_useteleport = GetConVarBool(g_Cvaruseteleport);
	g_restorehealth = GetConVarBool(g_Cvarrestorehealth);
	g_winnerhealth = GetConVarInt(g_Cvarwinnerhealth);
	g_winnerspeed = GetConVarFloat(g_Cvarwinnerspeed);
	g_winnereffects = GetConVarBool(g_Cvarwinnereffects);
	g_losereffects = GetConVarBool(g_Cvarlosereffects);
	g_locatorbeam = GetConVarBool(g_Cvarlocatorbeam);
	g_stopmusic = GetConVarBool(g_Cvarstopmusic);
	g_forcefight = GetConVarBool(g_Cvarforcefight);
	g_countdowntimer = GetConVarInt(g_Cvarcountdowntimer);
	g_fighttimer = GetConVarInt(g_Cvarfighttimer);
	g_beaconragius = GetConVarFloat(g_Cvarbeaconradius);
	return 0;
}

public OnAutoConfigsBuffered()
{
	g_intermission = false;
	return 0;
}

public OnSettingChanged(Handle:convar, String:oldValue[], String:newValue[])
{
	if (g_Cvarenabled == convar)
	{
		g_enabled = newValue[0] == 49;
	}
	else
	{
		if (g_Cvaralltalk == convar)
		{
			g_alltalk = newValue[0] == 49;
		}
		if (g_Cvarblock == convar)
		{
			g_block = newValue[0] == 49;
		}
		if (g_Cvarrandomkill == convar)
		{
			g_randomkill = newValue[0] == 49;
		}
		if (g_Cvaruseteleport == convar)
		{
			g_useteleport = newValue[0] == 49;
		}
		if (g_Cvarrestorehealth == convar)
		{
			g_restorehealth = newValue[0] == 49;
		}
		if (g_Cvarwinnereffects == convar)
		{
			g_winnereffects = newValue[0] == 49;
		}
		if (g_Cvarlosereffects == convar)
		{
			g_losereffects = newValue[0] == 49;
		}
		if (g_Cvarlocatorbeam == convar)
		{
			g_locatorbeam = newValue[0] == 49;
		}
		if (g_Cvarstopmusic == convar)
		{
			g_stopmusic = newValue[0] == 49;
		}
		if (g_Cvarforcefight == convar)
		{
			g_forcefight = newValue[0] == 49;
		}
		if (g_Cvarwinnerhealth == convar)
		{
			g_winnerhealth = StringToInt(newValue, 10);
		}
		if (g_Cvarwinnerspeed == convar)
		{
			g_winnerspeed = StringToFloat(newValue);
		}
		if (g_Cvarwinnermoney == convar)
		{
			g_winnermoney = StringToInt(newValue, 10);
		}
		if (g_Cvarcountdowntimer == convar)
		{
			g_countdowntimer = StringToInt(newValue, 10);
		}
		if (g_Cvarfighttimer == convar)
		{
			g_fighttimer = StringToInt(newValue, 10);
		}
		if (g_Cvarbeaconradius == convar)
		{
			g_beaconragius = StringToFloat(newValue);
		}
		if (g_Cvarminplayers == convar)
		{
			g_minplayers = StringToInt(newValue, 10);
		}
		if (g_Cvar_IsBotFightAllowed == convar)
		{
			g_isBotFightAllowed = newValue[0] == 49;
		}
		if (g_Cvar_ShowWinner == convar)
		{
			g_showWinner = GetConVarInt(g_Cvar_ShowWinner);
		}
		if (g_Cvar_RemoveNewPlayer == convar)
		{
			g_removeNewPlayer = GetConVarInt(g_Cvar_RemoveNewPlayer);
		}
	}
	return 0;
}

WeaponHandler(client, teamid)
{
	if (isFighting)
	{
		new count;
		new i;
		while (i <= 128)
		{
			new weaponentity = -1;
			new String:weaponname[32];
			weaponentity = GetEntDataEnt2(client, i + g_iMyWeapons);
			if (IsValidEdict(weaponentity))
			{
				GetEdictClassname(weaponentity, weaponname, 32);
				new var1;
				if (weaponentity != -1 && !StrEqual(weaponname, "worldspawn", false))
				{
					new var2;
					if (teamid == 3 || teamid == 2)
					{
						RemovePlayerItem(client, weaponentity);
						RemoveEdict(weaponentity);
						if (teamid == 3)
						{
							count++;
						}
						if (teamid == 2)
						{
							count++;
						}
					}
				}
			}
			i += 4;
		}
	}
	else
	{
		if (g_iWeaponsArray == -1)
		{
			RemoveWeapon(client, "knife");
		}
		else
		{
			decl String:sBuffer[64];
			Format(sBuffer, 64, g_sWeaponsArray);
			ReplaceString(sBuffer, 64, "weapon_", "", true);
			RemoveWeapon(client, sBuffer);
		}
		new i;
		while (i <= 7)
		{
			if (IsClientInGame(client))
			{
				if (teamid == 3)
				{
					if (!StrEqual(ctitems[i], "", false))
					{
						GivePlayerItem(client, ctitems[i], 0);
					}
				}
				if (teamid == 2)
				{
					if (!StrEqual(titems[i], "", false))
					{
						GivePlayerItem(client, titems[i], 0);
					}
				}
			}
			i++;
		}
	}
	return 0;
}

public GiveWeapon(client)
{
	if (g_iWeaponsArray == -1)
	{
		GivePlayerItem(client, "weapon_knife", 0);
		FakeClientCommand(client, "use weapon_knife");
	}
	else
	{
		decl String:sBuffer[64];
		decl iBuffer;
		Format(sBuffer, 64, "use %s", g_sWeaponsArray);
		iBuffer = GivePlayerItem(client, g_sWeaponsArray, 0);
		SetEntDataEnt2(client, g_iActiveWeaponOffset, iBuffer, false);
		FakeClientCommand(client, sBuffer);
		ReplaceString(sBuffer, 64, "use weapon_", "", true);
		if (GetTrieValue(g_WeaponSlots, sBuffer, iBuffer))
		{
			g_iActiveWeapon[client] = GetPlayerWeaponSlot(client, iBuffer);
		}
	}
	return 0;
}

public Action:WinnerEffects()
{
	CreateTimer(0.1, LightningTimer, any:0, 1);
	CreateTimer(0.6, ExplosionTimer, any:0, 1);
	return Action:0;
}

public Action:DelayWeapon(Handle:timer, any:data)
{
	new Handle:pack = data;
	ResetPack(pack, false);
	new client = ReadPackCell(pack);
	new String:item[64];
	ReadPackString(pack, item, 64);
	CloseHandle(pack);
	if (!isFighting)
	{
		return Action:0;
	}
	RemoveWeapon(client, item);
	return Action:0;
}

public Action:LightningTimer(Handle:timer)
{
	if (winner)
	{
		static TimesRepeated;
		TimesRepeated += 1;
		if (TimesRepeated <= 30)
		{
			Lightning();
			return Action:0;
		}
		TimesRepeated = 0;
		return Action:4;
	}
	return Action:4;
}

public Action:ExplosionTimer(Handle:timer)
{
	if (winner)
	{
		static TimesRepeated;
		TimesRepeated += 1;
		new var1;
		if (TimesRepeated <= 3 && IsClientInGame(winner))
		{
			decl Float:fPos[3];
			GetClientAbsOrigin(winner, fPos);
			EmitAmbientSound("ambient/explosions/explode_8.wav", fPos, 0, 75, 0, 1.0, 100, 0.0);
			return Action:0;
		}
		TimesRepeated = 0;
	}
	return Action:4;
}

public Action:KillPlayer(Handle:timer, any:clientid)
{
	new var1;
	if (IsClientInGame(clientid) && IsPlayerAlive(clientid))
	{
		new var2;
		if (!isFighting && ctid != clientid && tid != clientid)
		{
			return Action:0;
		}
		new var3;
		if (g_removeNewPlayer == 1 && isFighting && ctid != clientid && tid != clientid)
		{
			ChangeClientTeam(clientid, 1);
			RemoveAllWeapons();
			return Action:0;
		}
		ForcePlayerSuicide(clientid);
	}
	return Action:0;
}

public Action:SlapTimer(Handle:timer)
{
	static TimesRepeated;
	if (TimesRepeated <= 1)
	{
		new var1;
		if (ctid > 0 && IsClientInGame(ctid) && GetClientTeam(ctid) && IsPlayerAlive(ctid))
		{
			SlapPlayer(ctid, 0, false);
		}
		TimesRepeated += 1;
		return Action:0;
	}
	TimesRepeated = 0;
	return Action:4;
}

public Action:TeleportTimer(Handle:timer)
{
	TeleportEntity(tid, teleloc, NULL_VECTOR, NULL_VECTOR);
	return Action:0;
}

public Action:ItemsWon(Handle:timer, any:client)
{
	static TimesRepeated;
	if (!IsClientInGame(client))
	{
		return Action:4;
	}
	if (TimesRepeated <= 2)
	{
		PrintHintText(client, itemswon);
		TimesRepeated += 1;
		return Action:0;
	}
	TimesRepeated = 0;
	return Action:4;
}

public Action:StartFight()
{
	new var1;
	if (ctid && tid)
	{
		return Action:0;
	}
	alivect = 0;
	alivet = 0;
	new i = 1;
	while (i <= MaxClients)
	{
		new team;
		new var2;
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			team = GetClientTeam(i);
			if (team == 3)
			{
				alivect += 1;
			}
			if (team == 2)
			{
				alivet += 1;
			}
		}
		i++;
	}
	new var3;
	if (alivect == 1 && alivet == 1 && bombplanted)
	{
		return Action:0;
	}
	isFighting = true;
	new var4;
	if (!IsPlayerAlive(ctid) || !IsPlayerAlive(tid) || GetClientCount(true) < g_minplayers)
	{
		CancelFight();
		return Action:0;
	}
	RemoveAllWeapons();
	if (songsfound != -1)
	{
		if (songsfound)
		{
			GetArrayString(g_hSoundsArray, GetRandomInt(0, songsfound), song, 256);
		}
		else
		{
			GetArrayString(g_hSoundsArray, 0, song, 256);
		}
		new clients[MaxClients];
		new total;
		new i = 1;
		while (i <= MaxClients)
		{
			new var5;
			if (IsClientInGame(i) && g_soundPrefs[i])
			{
				total++;
				clients[total] = i;
			}
			i++;
		}
		if (total)
		{
			EmitSound(clients, total, song, -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
	CreateTimer(2.0, StartBeacon, ctid, 1);
	CreateTimer(1.0, StartBeaconT, tid, 0);
	PrintHintTextToAll("%t", "Removing weapons");
	WeaponHandler(ctid, 3);
	WeaponHandler(tid, 2);
	if (g_alltalk)
	{
		g_alltalkenabled = GetConVarBool(sv_alltalk);
		if (!g_alltalkenabled)
		{
			SetConVarInt(sv_alltalk, 1, false, false);
		}
		g_alltalkenabled = !g_alltalkenabled;
	}
	if (g_block)
	{
		if (!sm_noblock)
		{
			sm_noblock = FindConVar("sm_noblock");
		}
		if (sm_noblock)
		{
			g_blockenabled = !GetConVarBool(sm_noblock);
			if (!g_blockenabled)
			{
				SetConVarInt(sm_noblock, 0, false, false);
			}
			g_blockenabled = !g_blockenabled;
		}
		if (!sm_noblock_nades)
		{
			sm_noblock_nades = FindConVar("sm_noblock_nades");
		}
		if (sm_noblock_nades)
		{
			g_blockenabled = !GetConVarBool(sm_noblock_nades);
			if (!g_blockenabled)
			{
				SetConVarInt(sm_noblock_nades, 0, false, false);
			}
			g_blockenabled = !g_blockenabled;
		}
	}
	if (!g_hAntiFlash)
	{
		g_hAntiFlash = FindConVar("kac_antiflash");
		if (!g_hAntiFlash)
		{
			g_hAntiFlash = FindConVar("smac_antiflash");
		}
	}
	if (g_hAntiFlash)
	{
		g_bantiflashenabled = !GetConVarBool(g_hAntiFlash);
		if (!g_bantiflashenabled)
		{
			SetConVarInt(g_hAntiFlash, 0, false, false);
		}
		g_bantiflashenabled = !g_bantiflashenabled;
	}
	g_Cvar_Restrict = FindConVar("sm_allow_restricted_pickup");
	new var6;
	if (g_Cvar_Restrict && !GetConVarBool(g_Cvar_Restrict))
	{
		SetConVarInt(g_Cvar_Restrict, 1, false, false);
		g_bSetRestrict = true;
	}
	if (g_useteleport)
	{
		if (g_restorehealth)
		{
			SetEntData(ctid, g_iHealth, any:500, 4, true);
			SetEntData(tid, g_iHealth, any:500, 4, true);
		}
		new Float:ctvec[3] = 0.0;
		new Float:tvec[3] = 0.0;
		new Float:distance[1] = 0.0;
		GetClientAbsOrigin(ctid, ctvec);
		GetClientAbsOrigin(tid, tvec);
		SetEntData(ctid, g_iCollisionGroupOffs, any:2, 4, true);
		SetEntData(tid, g_iCollisionGroupOffs, any:2, 4, true);
		distance[0] = GetVectorDistance(ctvec, tvec, true);
		if (distance[0] >= 600000.0)
		{
			CreateTimer(0.1, SlapTimer, any:0, 1);
			CreateTimer(0.5, TeleportTimer, any:0, 0);
		}
		else
		{
			if (g_locatorbeam)
			{
				CreateTimer(0.1, DrawBeamsTimer, any:0, 1);
			}
		}
	}
	else
	{
		if (g_locatorbeam)
		{
			CreateTimer(0.1, DrawBeamsTimer, any:0, 1);
		}
	}
	CreateTimer(1.0, Countdown, any:0, 1);
	return Action:0;
}

public Action:CancelFight()
{
	ctagree = -1;
	tagree = -1;
	isFighting = false;
	new var1;
	if (g_stopmusic && songsfound != -1)
	{
		new clients[MaxClients];
		new total;
		new i = 1;
		while (i <= MaxClients)
		{
			new var2;
			if (IsClientInGame(i) && g_soundPrefs[i])
			{
				total++;
				clients[total] = i;
			}
			i++;
		}
		if (total)
		{
			EmitSound(clients, total, song, -2, 0, 75, 6, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
	if (winner)
	{
		if (IsPlayerAlive(winner))
		{
			WeaponHandler(winner, GetClientTeam(winner));
			new i;
			while (i <= 7)
			{
				i++;
			}
		}
	}
	return Action:0;
}

public Action:FightTimer(Handle:timer)
{
	if (!isFighting)
	{
		return Action:4;
	}
	if (0 <= fighttimer)
	{
		PrintHintTextToAll("%t: %i", "Time remaining", fighttimer);
		if (fighttimer < 6)
		{
			EmitSoundToAll("ambient/tones/floor1.wav", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
		fighttimer -= 1;
		return Action:0;
	}
	new healthCT = GetClientHealth(ctid);
	new healthT = GetClientHealth(tid);
	if (healthT == healthCT)
	{
		if (g_randomkill)
		{
			if (GetRandomInt(0, 1))
			{
				CreateTimer(0.1, KillPlayer, ctid, 0);
				CreateTimer(0.1, KillPlayer, tid, 0);
			}
			else
			{
				CreateTimer(0.1, KillPlayer, tid, 0);
				CreateTimer(0.1, KillPlayer, ctid, 0);
			}
		}
		else
		{
			CreateTimer(0.1, KillPlayer, ctid, 0);
			CreateTimer(0.1, KillPlayer, tid, 0);
		}
	}
	else
	{
		if (healthT < healthCT)
		{
			CreateTimer(0.1, KillPlayer, tid, 0);
		}
		CreateTimer(0.1, KillPlayer, ctid, 0);
	}
	PrintHintTextToAll("%t", "Fight draw");
	return Action:4;
}

public Action:Countdown(Handle:timer)
{
	if (!isFighting)
	{
		timesrepeated = g_countdowntimer;
		return Action:4;
	}
	SetEntDataFloat(ctid, g_iSpeed, 1.0, true);
	SetEntDataFloat(tid, g_iSpeed, 1.0, true);
	if (timesrepeated >= 1)
	{
		PrintHintTextToAll("%t: %i", "Prepare fight", timesrepeated);
		timesrepeated -= 1;
		return Action:0;
	}
	if (strcmp(g_sWeaponsArray, "weapon_hegrenade", false))
	{
		if (strcmp(g_sWeaponsArray, "weapon_flashbang", false))
		{
			if (strcmp(g_sWeaponsArray, "weapon_smokegrenade", false))
			{
				if (g_restorehealth)
				{
					SetEntData(ctid, g_iHealth, any:100, 4, true);
					SetEntData(ctid, g_iArmorOffset, any:100, 4, true);
					SetEntData(tid, g_iHealth, any:100, 4, true);
					SetEntData(tid, g_iArmorOffset, any:100, 4, true);
				}
			}
			SetEntData(ctid, g_iHealth, any:2, 4, false);
			SetEntData(ctid, g_iArmorOffset, any:0, 4, false);
			SetEntData(tid, g_iHealth, any:2, 4, false);
			SetEntData(tid, g_iArmorOffset, any:0, 4, false);
			HookEvent("hegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
			HookEvent("flashbang_detonate", Event_GrenadeDetonate, EventHookMode:1);
			HookEvent("smokegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
			g_bGrenade = true;
			g_bFlashBangDetonate = false;
		}
		SetEntData(ctid, g_iHealth, any:2, 4, false);
		SetEntData(ctid, g_iArmorOffset, any:0, 4, false);
		SetEntData(tid, g_iHealth, any:2, 4, false);
		SetEntData(tid, g_iArmorOffset, any:0, 4, false);
		HookEvent("hegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		HookEvent("flashbang_detonate", Event_GrenadeDetonate, EventHookMode:1);
		HookEvent("smokegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		g_bGrenade = true;
		g_bFlashBangDetonate = true;
	}
	else
	{
		if (g_bSDKHooksLoaded)
		{
			SDKHook(ctid, SDKHookType:2, OnTakeDamage);
			SDKHook(tid, SDKHookType:2, OnTakeDamage);
			g_bOnTakeDamage = true;
		}
		if (g_restorehealth)
		{
			SetEntData(ctid, g_iHealth, any:35, 4, true);
			SetEntData(ctid, g_iArmorOffset, any:35, 4, true);
			SetEntData(tid, g_iHealth, any:35, 4, true);
			SetEntData(tid, g_iArmorOffset, any:35, 4, true);
		}
		HookEvent("hegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		HookEvent("flashbang_detonate", Event_GrenadeDetonate, EventHookMode:1);
		HookEvent("smokegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		g_bGrenade = true;
		g_bFlashBangDetonate = false;
	}
	PrintHintTextToAll("%t", "Fight");
	GiveWeapon(ctid);
	GiveWeapon(tid);
	SetEntData(ctid, g_iCollisionGroupOffs, any:5, 4, true);
	SetEntData(tid, g_iCollisionGroupOffs, any:5, 4, true);
	timesrepeated = g_countdowntimer;
	CreateTimer(1.0, FightTimer, any:0, 1);
	return Action:4;
}

public Action:DrawBeamsTimer(Handle:timer)
{
	new var1;
	if (!isFighting || !IsPlayerAlive(ctid) || !IsPlayerAlive(tid))
	{
		return Action:4;
	}
	new Float:ctvec[3] = 0.0;
	new Float:tvec[3] = 0.0;
	new Float:distance[1] = 0.0;
	new color[4] = {255,75,75,255};
	GetClientEyePosition(ctid, ctvec);
	GetClientEyePosition(tid, tvec);
	distance[0] = GetVectorDistance(ctvec, tvec, true);
	if (distance[0] < 200000.0)
	{
		return Action:4;
	}
	TE_SetupBeamPoints(ctvec, tvec, g_locatebeam, g_locatehalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, color, 255);
	TE_SendToClient(tid, 0.0);
	TE_SetupBeamPoints(tvec, ctvec, g_locatebeam, g_locatehalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, color, 255);
	TE_SendToClient(ctid, 0.0);
	return Action:0;
}

public Action:StartBeaconT(Handle:timer)
{
	CreateTimer(2.0, StartBeacon, tid, 1);
	return Action:0;
}

public Action:StartBeacon(Handle:timer, any:client)
{
	new var1;
	if (!isFighting || !IsClientInGame(ctid) || !IsClientInGame(tid))
	{
		return Action:4;
	}
	new redColor[4] = {255,75,75,255};
	new blueColor[4] = {75,75,255,255};
	new team = GetClientTeam(client);
	new Float:vec[3] = 0.0;
	GetClientAbsOrigin(client, vec);
	vec[2] += 10;
	if (team == 2)
	{
		TE_SetupBeamRingPoint(vec, 10.0, g_beaconragius, g_beamsprite, g_halosprite, 0, 10, 1.0, 10.0, 0.0, redColor, 0, 0);
	}
	else
	{
		if (team == 3)
		{
			TE_SetupBeamRingPoint(vec, 10.0, g_beaconragius, g_beamsprite, g_halosprite, 0, 10, 1.0, 10.0, 0.0, blueColor, 0, 0);
		}
	}
	TE_SendToAll(0.0);
	GetClientEyePosition(client, vec);
	if (IsSoundPrecached(g_beaconsound))
	{
		EmitAmbientSound(g_beaconsound, vec, client, 130, 0, 1.0, 100, 0.0);
	}
	return Action:0;
}

public Action:VerifyConditions(Handle:timer)
{
	new Handle:warmup = FindConVar("sm_warmupround_active");
	if (warmup)
	{
		if (GetConVarBool(warmup))
		{
			return Action:0;
		}
	}
	if (g_intermission)
	{
		return Action:0;
	}
	new var1;
	if (ctid && tid)
	{
		return Action:0;
	}
	if (GetClientCount(true) < g_minplayers)
	{
		return Action:0;
	}
	new var2;
	if (IsClientInGame(ctid) && IsPlayerAlive(ctid) && IsClientInGame(tid) && IsPlayerAlive(tid))
	{
		new var3;
		if (IsFakeClient(ctid) && IsFakeClient(tid))
		{
			if (!g_isBotFightAllowed)
			{
				return Action:0;
			}
		}
		winner = 0;
		GetClientName(ctid, ctname, 32);
		GetClientName(tid, tname, 32);
		PrintHintTextToAll("%t", "1v1 situation");
		if (g_forcefight)
		{
			CreateTimer(0.5, DelayFight, any:0, 0);
		}
		SendFightMenus(ctid, tid);
	}
	return Action:0;
}

public Action:DelayFight(Handle:timer)
{
	StartFight();
	return Action:0;
}

public OnClientDisconnect(client)
{
	if (isFighting)
	{
		if (ctid == client)
		{
			winner = tid;
			loser = tid;
			CancelFight();
		}
		if (tid == client)
		{
			winner = ctid;
			loser = ctid;
			CancelFight();
		}
	}
	return 0;
}

public EventRoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_enabled)
	{
		new var1;
		if (g_alltalk && g_alltalkenabled)
		{
			g_alltalkenabled = false;
			SetConVarInt(sv_alltalk, 0, false, false);
		}
		new var2;
		if (g_block && g_blockenabled)
		{
			g_blockenabled = false;
			if (!sm_noblock)
			{
				sm_noblock = FindConVar("sm_noblock");
			}
			if (sm_noblock)
			{
				SetConVarInt(sm_noblock, 1, false, false);
			}
			if (!sm_noblock_nades)
			{
				sm_noblock_nades = FindConVar("sm_noblock_nades");
			}
			if (sm_noblock_nades)
			{
				SetConVarInt(sm_noblock_nades, 1, false, false);
			}
		}
		if (g_bantiflashenabled)
		{
			g_bantiflashenabled = false;
			if (!g_hAntiFlash)
			{
				g_hAntiFlash = FindConVar("kac_antiflash");
				if (!g_hAntiFlash)
				{
					g_hAntiFlash = FindConVar("smac_antiflash");
				}
			}
			if (g_hAntiFlash)
			{
				SetConVarInt(g_hAntiFlash, 1, false, false);
			}
		}
		new var3;
		if (g_Cvar_Restrict && g_bSetRestrict && GetConVarBool(g_Cvar_Restrict))
		{
			SetConVarInt(g_Cvar_Restrict, 0, false, false);
			g_bSetRestrict = false;
		}
		if (isFighting)
		{
			CancelFight();
		}
		alivect = 0;
		alivet = 0;
		new var4;
		if (g_bSDKHooksLoaded && g_bOnTakeDamage)
		{
			SDKUnhook(ctid, SDKHookType:2, OnTakeDamage);
			SDKUnhook(tid, SDKHookType:2, OnTakeDamage);
			g_bOnTakeDamage = false;
		}
		ctid = 0;
		tid = 0;
		loser = 0;
		bombplanted = false;
		timesrepeated = g_countdowntimer;
		fighttimer = g_fighttimer;
		if (g_iWeaponsArray != -1)
		{
			if (g_iWeaponsArray)
			{
				g_iRandomInt = GetRandomInt(0, g_iWeaponsArray);
				GetArrayString(g_hWeaponsArray, g_iRandomInt, g_sWeaponsArray, 64);
			}
			GetArrayString(g_hWeaponsArray, 0, g_sWeaponsArray, 64);
		}
	}
	if (g_bGrenade)
	{
		g_bFlashBangDetonate = false;
		UnhookEvent("hegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		UnhookEvent("flashbang_detonate", Event_GrenadeDetonate, EventHookMode:1);
		UnhookEvent("smokegrenade_detonate", Event_GrenadeDetonate, EventHookMode:1);
		g_bGrenade = false;
	}
	return 0;
}

public EventWeaponFire(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (g_enabled && isFighting && g_iWeaponsArray != -1 && g_bFightRoundAutoSwitch[g_iRandomInt])
	{
		new userid = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userid);
		new var2;
		if (client && IsClientInGame(client))
		{
			decl String:sBuffer[64];
			GetClientWeapon(client, sBuffer, 64);
			if (strcmp(sBuffer, g_sWeaponsArray, false))
			{
			}
			else
			{
				new var3;
				if (g_iActiveWeapon[client] > 1 && IsValidEdict(g_iActiveWeapon[client]))
				{
					CreateTimer(0.11, Timer_WeaponFire, userid, 0);
				}
			}
		}
	}
	return 0;
}

public Action:Timer_WeaponFire(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new var1;
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1)
	{
		decl String:sWeapon[64];
		new iBuffer = g_iActiveWeapon[client];
		new var2;
		if (iBuffer > MaxClients && IsValidEdict(iBuffer))
		{
			RemovePlayerItem(client, iBuffer);
			RemoveEdict(iBuffer);
			GivePlayerItem(client, g_sWeaponsArray, 0);
		}
		strcopy(sWeapon, 64, g_sWeaponsArray);
		ReplaceString(sWeapon, 64, "weapon_", "", true);
		if (GetTrieValue(g_WeaponSlots, sWeapon, iBuffer))
		{
			g_iActiveWeapon[client] = GetPlayerWeaponSlot(client, iBuffer);
		}
	}
	return Action:4;
}

public EventWeaponZoom(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (g_enabled && isFighting && g_iWeaponsArray != -1 && g_bFightRoundNoZoom[g_iRandomInt])
	{
		new userid = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userid);
		new var2;
		if (client && IsClientInGame(client))
		{
			if (g_iGame == GameType:1)
			{
				SetEntData(client, g_iFOVOffs, any:0, 4, true);
			}
			new weapon = GetPlayerWeaponSlot(client, 0);
			new var3;
			if (weapon > MaxClients && IsValidEdict(weapon))
			{
				RemovePlayerItem(client, weapon);
				RemoveEdict(weapon);
				CreateTimer(0.1, Timer_GiveWeapon, userid, 0);
				PrintHintText(client, "%t", "zoom is disabled");
			}
		}
	}
	return 0;
}

public Action:Timer_GiveWeapon(Handle:timer, any:userid)
{
	if (isFighting)
	{
		new client = GetClientOfUserId(userid);
		new var1;
		if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1)
		{
			GivePlayerItem(client, g_sWeaponsArray, 0);
		}
	}
	return Action:4;
}

public EventBombPlanted(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_enabled)
	{
		bombplanted = true;
	}
	return 0;
}

public Action:EventItemPickup(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (!g_enabled || !isFighting)
	{
		return Action:0;
	}
	new clientid = GetClientOfUserId(GetEventInt(event, "userid"));
	new var2;
	if (clientid && IsClientConnected(clientid) && IsClientInGame(clientid) && IsPlayerAlive(clientid))
	{
		new var3;
		if (ctid != clientid && tid != clientid)
		{
			new String:item[64];
			GetEventString(event, "item", item, 64);
			if (g_iWeaponsArray == -1)
			{
				if (!StrEqual(item, "knife", false))
				{
					FakeClientCommand(clientid, "use weapon_knife");
					new Handle:pack = CreateDataPack();
					WritePackCell(pack, clientid);
					WritePackString(pack, item);
					CreateTimer(0.1, DelayWeapon, pack, 0);
				}
			}
			else
			{
				decl String:sBuffer[64];
				decl slot;
				Format(sBuffer, 64, "weapon_%s", item);
				if (StrEqual(sBuffer, g_sWeaponsArray, false))
				{
					strcopy(sBuffer, 64, g_sWeaponsArray);
					ReplaceString(sBuffer, 64, "weapon_", "", true);
					if (GetTrieValue(g_WeaponSlots, sBuffer, slot))
					{
						g_iActiveWeapon[clientid] = GetPlayerWeaponSlot(clientid, slot);
					}
				}
				else
				{
					Format(sBuffer, 64, "use %s", g_sWeaponsArray);
					FakeClientCommand(clientid, sBuffer);
					new Handle:pack = CreateDataPack();
					WritePackCell(pack, clientid);
					WritePackString(pack, item);
					CreateTimer(0.1, DelayWeapon, pack, 0);
				}
			}
		}
	}
	return Action:0;
}

public EventPlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	alivect = 0;
	alivet = 0;
	new var1;
	if (g_enabled && isFighting)
	{
		loser = GetClientOfUserId(GetEventInt(event, "userid"));
		new var2;
		if (ctid != loser && tid != loser)
		{
			winner = GetClientOfUserId(GetEventInt(event, "attacker"));
			if (g_iWeaponsArray != -1)
			{
				new var3;
				if (loser && IsClientConnected(loser) && IsClientInGame(loser) && g_iActiveWeapon[loser] > 1 && IsValidEdict(g_iActiveWeapon[loser]) && IsValidEntity(g_iActiveWeapon[loser]))
				{
					RemovePlayerItem(loser, g_iActiveWeapon[loser]);
					RemoveEdict(g_iActiveWeapon[loser]);
				}
				new var4;
				if (winner && IsClientConnected(winner) && IsClientInGame(winner) && g_iActiveWeapon[winner] > 1 && IsValidEdict(g_iActiveWeapon[winner]) && IsValidEntity(g_iActiveWeapon[winner]))
				{
					RemovePlayerItem(winner, g_iActiveWeapon[winner]);
					RemoveEdict(g_iActiveWeapon[winner]);
				}
			}
			new var5;
			if (loser != winner && winner)
			{
				if (g_losereffects)
				{
					CreateTimer(0.4, DissolveRagdoll, loser, 0);
				}
				g_winnerid = winner;
				GetClientName(winner, winnername, 32);
				if (g_showWinner)
				{
					if (g_showWinner == 1)
					{
						new String:msg[192];
						new i = 1;
						while (i <= MaxClients)
						{
							new var10;
							if (IsClientConnected(i) && IsClientInGame(i))
							{
								Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', winnername, '\x04', "has won", i);
								PrintMsg(i, winner, msg);
							}
							i++;
						}
					}
				}
				else
				{
					new team = GetClientTeam(winner);
					decl r;
					new var6;
					if (team == 2)
					{
						var6 = 255;
					}
					else
					{
						var6 = 0;
					}
					r = var6;
					decl g;
					new var7;
					if (team == 3)
					{
						var7 = 128;
					}
					else
					{
						if (team == 2)
						{
							var7 = 0;
						}
						var7 = 255;
					}
					g = var7;
					decl b;
					new var8;
					if (team == 3)
					{
						var8 = 255;
					}
					else
					{
						var8 = 0;
					}
					b = var8;
					decl Handle:hMsg;
					decl String:Buffer[64];
					new i = 1;
					while (i <= MaxClients)
					{
						new var9;
						if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
						{
							hMsg = CreateKeyValues("msg", "", "");
							Format(Buffer, 64, "%s %T", winnername, "has won", i);
							KvSetString(hMsg, "title", Buffer);
							KvSetColor(hMsg, "color", r, g, b, 255);
							KvSetNum(hMsg, "level", 0);
							KvSetNum(hMsg, "time", 10);
							CreateDialog(i, hMsg, DialogType:0);
							CloseHandle(hMsg);
						}
						i++;
					}
				}
				if (g_winnereffects)
				{
					WinnerEffects();
				}
				CancelFight();
			}
			if (loser == ctid)
			{
				winner = tid;
				CancelFight();
			}
			if (loser == tid)
			{
				winner = ctid;
				CancelFight();
			}
		}
	}
	else
	{
		new var11;
		if (g_enabled && !isFighting)
		{
			new i = 1;
			while (i <= MaxClients)
			{
				new team;
				new var12;
				if (IsClientInGame(i) && IsPlayerAlive(i))
				{
					team = GetClientTeam(i);
					if (team == 3)
					{
						ctid = i;
						alivect += 1;
					}
					if (team == 2)
					{
						tid = i;
						alivet += 1;
					}
				}
				i++;
			}
			new var13;
			if (alivect == 1 && alivet == 1 && !bombplanted)
			{
				CreateTimer(0.5, VerifyConditions, any:0, 0);
			}
		}
	}
	return 0;
}

public EventPlayerSpawn(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_enabled)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new var1;
		if (client && IsClientInGame(client))
		{
			if (isFighting)
			{
				CreateTimer(0.1, KillPlayer, client, 0);
			}
			if (g_winnerid == client)
			{
				new var2;
				if (g_winnerhealth > 0 || g_winnermoney > 0 || g_winnerspeed > 0.0)
				{
					new String:buffer[256];
					Format(buffer, 256, "%T", "Items won", client);
					StrCat(itemswon, 256, buffer);
					if (0 < g_winnerhealth)
					{
						SetEntData(client, g_iHealth, g_winnerhealth, 4, true);
						Format(buffer, 256, "\n%T: %i", "Health", client, g_winnerhealth);
						StrCat(itemswon, 256, buffer);
					}
					if (0 < g_winnermoney)
					{
						new totalmoney = GetEntData(client, g_iAccount, 4) + g_winnermoney;
						SetEntData(client, g_iAccount, totalmoney, 4, true);
						Format(buffer, 256, "\n%T: $%i", "Money", client, g_winnermoney);
						StrCat(itemswon, 256, buffer);
					}
					if (g_winnerspeed > 0.0)
					{
						SetEntDataFloat(client, g_iSpeed, g_winnerspeed, true);
						Format(buffer, 256, "\n%T: %.2fx", "Speed", client, g_winnerspeed);
						StrCat(itemswon, 256, buffer);
					}
					CreateTimer(1.0, ItemsWon, client, 1);
					g_winnerid = 0;
				}
			}
		}
	}
	return 0;
}

public Event_GrenadeDetonate(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:sBuffer[32];
	strcopy(sBuffer, 32, name);
	ReplaceString(sBuffer, 32, "_detonate", "", true);
	Format(sBuffer, 32, "weapon_%s", sBuffer);
	if (g_bFlashBangDetonate)
	{
		new Float:fOrigin[2][3] = {3.85186E-34,2.5243549E-29};
		fOrigin[0][fOrigin] = GetEventFloat(event, "x");
		fOrigin[0][fOrigin][1] = GetEventFloat(event, "y");
		fOrigin[0][fOrigin][2] = GetEventFloat(event, "z");
		new i = 1;
		while (i <= MaxClients)
		{
			new var1;
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				GetClientEyePosition(i, fOrigin[1]);
				if (GetVectorDistance(fOrigin[0][fOrigin], fOrigin[1], false) <= 1152729088)
				{
					SetEntDataFloat(i, g_iFlashOffset[0], 0.5, true);
					SetEntDataFloat(i, g_iFlashOffset[1], 0.0, true);
					ClientCommand(i, "dsp_player 0.0");
				}
			}
			i++;
		}
	}
	if (isFighting)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new var2;
		if (client && IsClientInGame(client) && GetClientTeam(client) > 1 && IsPlayerAlive(client))
		{
			SetEntDataEnt2(client, g_iActiveWeaponOffset, GivePlayerItem(client, g_sWeaponsArray, 0), false);
			CreateTimer(0.1, Give_Grenade, client, 0);
		}
	}
	return 0;
}

public Action:Give_Grenade(Handle:timer, any:client)
{
	new var1;
	if (IsClientConnected(client) && IsClientInGame(client) && GetClientTeam(client) > 1 && IsPlayerAlive(client))
	{
		FakeClientCommand(client, "use %s", g_sWeaponsArray);
	}
	return Action:0;
}

public Action:DissolveRagdoll(Handle:timer, any:client)
{
	new var1;
	if (IsClientConnected(client) && IsClientInGame(client) && !IsPlayerAlive(client) && IsValidEntity(client))
	{
		new ragdoll = GetEntPropEnt(client, PropType:0, "m_hRagdoll", 0);
		if (0 > ragdoll)
		{
			return Action:0;
		}
		new String:dname[32];
		Format(dname, 32, "dis_%i", client);
		new entid = CreateEntityByName("env_entity_dissolver", -1);
		if (0 < entid)
		{
			DispatchKeyValue(ragdoll, "targetname", dname);
			DispatchKeyValue(entid, "dissolvetype", "0");
			DispatchKeyValue(entid, "target", dname);
			AcceptEntityInput(entid, "Dissolve", -1, -1, 0);
			AcceptEntityInput(entid, "kill", -1, -1, 0);
		}
	}
	return Action:0;
}

public SendFightMenus(ct, t)
{
	ctagree = -1;
	tagree = -1;
	new String:msg[192];
	new var1;
	if (IsFakeClient(ct) || g_fightPrefs[ct] == 1)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			new var2;
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', ctname, '\x04', "Player agrees", i);
				PrintMsg(i, ct, msg);
			}
			i++;
		}
		ctagree = 1;
	}
	else
	{
		if (g_fightPrefs[ct] == -1)
		{
			new i = 1;
			while (i <= MaxClients)
			{
				new var3;
				if (IsClientConnected(i) && IsClientInGame(i))
				{
					Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', ctname, '\x04', "Player disagrees", i);
					PrintMsg(i, ct, msg);
				}
				i++;
			}
			ctagree = 0;
			if (IsSoundPrecached(g_declinesound))
			{
				EmitSoundToAll(g_declinesound, -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
		}
		SendKnifeMenu(ct);
	}
	new var4;
	if (IsFakeClient(t) || g_fightPrefs[t] == 1)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			new var5;
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', tname, '\x04', "Player agrees", i);
				PrintMsg(i, t, msg);
			}
			i++;
		}
		tagree = 1;
	}
	else
	{
		if (g_fightPrefs[t] == -1)
		{
			new i = 1;
			while (i <= MaxClients)
			{
				new var6;
				if (IsClientConnected(i) && IsClientInGame(i))
				{
					Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', tname, '\x04', "Player disagrees", i);
					PrintMsg(i, t, msg);
				}
				i++;
			}
			tagree = 0;
			EmitSoundToAll(g_declinesound, -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
		SendKnifeMenu(t);
	}
	new var7;
	if (ctagree == 1 && tagree == 1)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			new var8;
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				Format(msg, 192, "%c[%c%T%c] %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x04', "Both agree", i);
				PrintMsg(i, 0, msg);
			}
			i++;
		}
		CreateTimer(0.5, DelayFight, any:0, 0);
	}
	return 0;
}

public SendKnifeMenu(client)
{
	new String:sBuffer[128];
	new Handle:panel = CreatePanel(Handle:0);
	Format(sBuffer, 128, "%T", "Menu title", client);
	SetPanelTitle(panel, sBuffer, false);
	DrawPanelItem(panel, " ", 10);
	Format(sBuffer, 128, "%T", "Question", client);
	DrawPanelText(panel, sBuffer);
	DrawPanelText(panel, "-----------------------------");
	Format(sBuffer, 128, "%T", "Yes option", client);
	DrawPanelItem(panel, sBuffer, 0);
	Format(sBuffer, 128, "%T", "No option", client);
	DrawPanelItem(panel, sBuffer, 0);
	DrawPanelText(panel, "-----------------------------");
	SendPanelToClient(panel, client, PanelHandler, 15);
	CloseHandle(panel);
	return 0;
}

public PanelHandler(Handle:menu, MenuAction:action, client, item)
{
	new String:msg[192];
	if (action == MenuAction:4)
	{
		new var1;
		if (item == 1 && client)
		{
			new var2;
			if (GetClientTeam(client) == 3 && ctid == client && IsClientInGame(tid) && IsPlayerAlive(tid))
			{
				new i = 1;
				while (i <= MaxClients)
				{
					new var3;
					if (IsClientConnected(i) && IsClientInGame(i))
					{
						Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', ctname, '\x04', "Player agrees", i);
						PrintMsg(i, client, msg);
					}
					i++;
				}
				ctagree = 1;
			}
			else
			{
				new var4;
				if (GetClientTeam(client) == 2 && tid == client && IsClientInGame(ctid) && IsPlayerAlive(ctid))
				{
					new i = 1;
					while (i <= MaxClients)
					{
						new var5;
						if (IsClientConnected(i) && IsClientInGame(i))
						{
							Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', tname, '\x04', "Player agrees", i);
							PrintMsg(i, client, msg);
						}
						i++;
					}
					tagree = 1;
				}
			}
		}
		else
		{
			new var6;
			if (item == 2 && client)
			{
				new var7;
				if (GetClientTeam(client) == 3 && ctid == client && IsClientInGame(tid) && IsPlayerAlive(tid))
				{
					new i = 1;
					while (i <= MaxClients)
					{
						new var8;
						if (IsClientConnected(i) && IsClientInGame(i))
						{
							Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', ctname, '\x04', "Player disagrees", i);
							PrintMsg(i, client, msg);
						}
						i++;
					}
					ctagree = 0;
					EmitSoundToAll(g_declinesound, -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}
				new var9;
				if (GetClientTeam(client) == 2 && tid == client && IsClientInGame(ctid) && IsPlayerAlive(ctid))
				{
					new i = 1;
					while (i <= MaxClients)
					{
						new var10;
						if (IsClientConnected(i) && IsClientInGame(i))
						{
							Format(msg, 192, "%c[%c%T%c] %c%s %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x03', tname, '\x04', "Player disagrees", i);
							PrintMsg(i, client, msg);
						}
						i++;
					}
					tagree = 0;
					EmitSoundToAll(g_declinesound, -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}
			}
		}
	}
	else
	{
		if (action == MenuAction:8)
		{
			new var11;
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				Format(msg, 192, "%c[%c%T%c] %c%T", '\x04', '\x01', "Weapon Fight", client, '\x04', '\x04', "Restore fight menu", client);
				PrintMsg(client, 0, msg);
			}
		}
	}
	new var12;
	if (ctagree == 1 && tagree == 1)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			new var13;
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				Format(msg, 192, "%c[%c%T%c] %c%T", '\x04', '\x01', "Weapon Fight", i, '\x04', '\x04', "Both agree", i);
				PrintMsg(i, 0, msg);
			}
			i++;
		}
		StartFight();
	}
	return 0;
}

public Lightning()
{
	new var1;
	if (!IsClientInGame(winner) || !IsPlayerAlive(winner))
	{
		return 0;
	}
	new Float:playerpos[3] = 0.0;
	GetClientAbsOrigin(winner, playerpos);
	new Float:toppos[3] = 0.0;
	toppos[0] = playerpos[0];
	toppos[1] = playerpos[1];
	toppos[2] = playerpos[2] + 1000;
	new lightningcolor[4];
	lightningcolor[0] = 255;
	lightningcolor[1] = 255;
	lightningcolor[2] = 255;
	lightningcolor[3] = 255;
	new Float:lightninglife = 0.1;
	new Float:lightningwidth = 40.0;
	new Float:lightningendwidth = 10.0;
	new lightningstartframe;
	new lightningframerate = 20;
	new lightningfadelength = 1;
	new Float:lightningamplitude = 20.0;
	new lightningspeed = 250;
	TE_SetupBeamPoints(toppos, playerpos, g_lightning, g_lightning, lightningstartframe, lightningframerate, lightninglife, lightningwidth, lightningendwidth, lightningfadelength, lightningamplitude, lightningcolor, lightningspeed);
	TE_SendToAll(0.0);
	return 0;
}

public RemoveWeapon(client, String:weapon[])
{
	new slot;
	new curr_weapon;
	GetTrieValue(g_WeaponSlots, weapon, slot);
	curr_weapon = GetPlayerWeaponSlot(client, slot);
	new var1;
	if (!client || !IsValidEntity(curr_weapon))
	{
		return 0;
	}
	RemovePlayerItem(client, curr_weapon);
	return 0;
}

public OnClientPutInServer(client)
{
	g_soundPrefs[client] = GetConVarInt(g_Cvar_SoundPrefDefault);
	g_fightPrefs[client] = 0;
	if (!IsFakeClient(client))
	{
		if (AreClientCookiesCached(client))
		{
			loadClientCookies(client);
		}
	}
	return 0;
}

public OnClientCookiesCached(client)
{
	new var1;
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		loadClientCookies(client);
	}
	return 0;
}

public loadClientCookies(client)
{
	decl String:buffer[8];
	GetClientCookie(client, g_Cookie_SoundPref, buffer, 5);
	if (!StrEqual(buffer, "", true))
	{
		g_soundPrefs[client] = StringToInt(buffer, 10);
	}
	GetClientCookie(client, g_Cookie_FightPref, buffer, 5);
	if (!StrEqual(buffer, "", true))
	{
		g_fightPrefs[client] = StringToInt(buffer, 10);
	}
	return 0;
}

public MenuHandlerKnifeFight(Handle:menu, MenuAction:action, client, item)
{
	if (action == MenuAction:4)
	{
		if (item)
		{
			if (item == 1)
			{
				new var3;
				if (!isFighting && (client != tid && client != ctid) && alivect == 1 && alivet == 1 && GetClientCount(true) >= g_minplayers)
				{
					SendKnifeMenu(client);
				}
				else
				{
					MenuKnifeFight(client, 0);
				}
			}
			new var4;
			if (item == 2 || item == 3)
			{
				new var5;
				if ((item == 2 && g_fightPrefs[client] == 1) || (item == 3 && g_fightPrefs[client] == -1))
				{
					g_fightPrefs[client] = 0;
				}
				else
				{
					new var8;
					if (item == 2)
					{
						var8 = 1;
					}
					else
					{
						var8 = -1;
					}
					g_fightPrefs[client] = var8;
				}
				decl String:buffer[8];
				IntToString(g_fightPrefs[client], buffer, 5);
				SetClientCookie(client, g_Cookie_FightPref, buffer);
				MenuKnifeFight(client, 0);
			}
		}
		else
		{
			new var1;
			if (g_soundPrefs[client])
			{
				var1 = 0;
			}
			else
			{
				var1 = 1;
			}
			g_soundPrefs[client] = var1;
			decl String:buffer[8];
			IntToString(g_soundPrefs[client], buffer, 5);
			SetClientCookie(client, g_Cookie_SoundPref, buffer);
			MenuKnifeFight(client, 0);
		}
	}
	else
	{
		if (action == MenuAction:16)
		{
			CloseHandle(menu);
		}
	}
	return 0;
}

public Action:MenuKnifeFight(client, args)
{
	new Handle:menu = CreateMenu(MenuHandlerKnifeFight, MenuAction:28);
	decl String:sBuffer[128];
	Format(sBuffer, 128, "%T", "WeaponFight settings", client);
	SetMenuTitle(menu, sBuffer);
	if (g_soundPrefs[client])
	{
		Format(sBuffer, 128, "%T %T", "Play fight songs", client, "Selected", client);
	}
	else
	{
		Format(sBuffer, 128, "%T %T", "Play fight songs", client, "NotSelected", client);
	}
	AddMenuItem(menu, "Play fight songs", sBuffer, 0);
	Format(sBuffer, 128, "%T", "Show fight panel", client);
	new var2;
	if (!isFighting && (client != tid && client != ctid) && alivect == 1 && alivet == 1 && GetClientCount(true) >= g_minplayers)
	{
		var3 = 0;
	}
	else
	{
		var3 = 1;
	}
	AddMenuItem(menu, "Show fight panel", sBuffer, var3);
	new var4;
	if (g_fightPrefs[client] == 1)
	{
		var4[0] = 14412;
	}
	else
	{
		var4[0] = 14424;
	}
	Format(sBuffer, 128, "%T %T", "Always agree to weapon fight", client, var4, client);
	AddMenuItem(menu, "Always agree to weapon fight", sBuffer, 0);
	new var5;
	if (g_fightPrefs[client] == -1)
	{
		var5[0] = 14508;
	}
	else
	{
		var5[0] = 14520;
	}
	Format(sBuffer, 128, "%T %T", "Always disagree to weapon fight", client, var5, client);
	AddMenuItem(menu, "Always disagree to weapon fight", sBuffer, 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 35);
	return Action:3;
}

public RemoveAllWeapons()
{
	new maxent = GetMaxEntities();
	new String:weapon[64];
	new i = MaxClients;
	while (i < maxent)
	{
		new var1;
		if (IsValidEdict(i) && IsValidEntity(i) && GetEntDataEnt2(i, g_WeaponParent) == -1)
		{
			GetEdictClassname(i, weapon, 64);
			new var2;
			if (StrContains(weapon, "weapon_", true) == -1 && StrEqual(weapon, "hostage_entity", true) && StrContains(weapon, "item_", true) == -1)
			{
				RemoveEdict(i);
			}
		}
		i++;
	}
	return 0;
}

public ParsFile(String:file[], bool:sound)
{
	new String:sBuffer[256];
	new iBuffer;
	BuildPath(PathType:0, sBuffer, 256, "configs/%s", file);
	new Handle:hFile = OpenFile(sBuffer, "r");
	if (hFile)
	{
		while (!IsEndOfFile(hFile))
		{
			if (ReadFileLine(hFile, sBuffer, 256))
			{
				iBuffer = StrContains(sBuffer, "//", true);
				if (iBuffer != -1)
				{
					sBuffer[iBuffer] = MissingTAG:0;
				}
				iBuffer = StrContains(sBuffer, "#", true);
				if (iBuffer != -1)
				{
					sBuffer[iBuffer] = MissingTAG:0;
				}
				iBuffer = StrContains(sBuffer, ";", true);
				if (iBuffer != -1)
				{
					sBuffer[iBuffer] = MissingTAG:0;
				}
				TrimString(sBuffer);
				if (sBuffer[0])
				{
					if (sound)
					{
						if (StrContains(sBuffer, "=NoZoom", true) != -1)
						{
							ReplaceString(sBuffer, 256, "=NoZoom", "", true);
							if (StrContains(sBuffer, "=AutoSwitch", true) != -1)
							{
								ReplaceString(sBuffer, 256, "=AutoSwitch", "", true);
								if (ParsWeapon(sBuffer))
								{
									g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
									g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
								}
							}
							else
							{
								if (StrContains(sBuffer, "=autoswitch", true) != -1)
								{
									ReplaceString(sBuffer, 256, "=autoswitch", "", true);
									if (ParsWeapon(sBuffer))
									{
										g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
										g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
									}
								}
								if (ParsWeapon(sBuffer))
								{
									g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
									g_bFightRoundAutoSwitch[g_iWeaponsArray] = 0;
								}
							}
						}
						else
						{
							if (StrContains(sBuffer, "=nozoom", true) != -1)
							{
								ReplaceString(sBuffer, 256, "=nozoom", "", true);
								if (StrContains(sBuffer, "=AutoSwitch", true) != -1)
								{
									ReplaceString(sBuffer, 256, "=AutoSwitch", "", true);
									if (ParsWeapon(sBuffer))
									{
										g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
										g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
									}
								}
								else
								{
									if (StrContains(sBuffer, "=autoswitch", true) != -1)
									{
										ReplaceString(sBuffer, 256, "=autoswitch", "", true);
										if (ParsWeapon(sBuffer))
										{
											g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
											g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
										}
									}
									if (ParsWeapon(sBuffer))
									{
										g_bFightRoundNoZoom[g_iWeaponsArray] = 1;
										g_bFightRoundAutoSwitch[g_iWeaponsArray] = 0;
									}
								}
							}
							if (StrContains(sBuffer, "=AutoSwitch", true) != -1)
							{
								ReplaceString(sBuffer, 256, "=AutoSwitch", "", true);
								if (ParsWeapon(sBuffer))
								{
									g_bFightRoundNoZoom[g_iWeaponsArray] = 0;
									g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
								}
							}
							if (StrContains(sBuffer, "=autoswitch", true) != -1)
							{
								ReplaceString(sBuffer, 256, "=autoswitch", "", true);
								if (ParsWeapon(sBuffer))
								{
									g_bFightRoundNoZoom[g_iWeaponsArray] = 0;
									g_bFightRoundAutoSwitch[g_iWeaponsArray] = 1;
								}
							}
							if (ParsWeapon(sBuffer))
							{
								g_bFightRoundNoZoom[g_iWeaponsArray] = 0;
								g_bFightRoundAutoSwitch[g_iWeaponsArray] = 0;
							}
						}
					}
					else
					{
						if (PrecacheSound(sBuffer, true))
						{
							songsfound += 1;
							PushArrayString(g_hSoundsArray, sBuffer);
							Format(sBuffer, 256, "sound/%s", sBuffer);
							AddFileToDownloadsTable(sBuffer);
						}
						LogError("[WeaponFight] Could not pre-cache sound: %s", sBuffer);
					}
				}
			}
		}
		CloseHandle(hFile);
	}
	return 0;
}

public bool:ParsWeapon(String:weapon[])
{
	decl String:sBuffer[64];
	decl iBuffer;
	new var1;
	if (GetTrieValue(g_hWeaponsTrie, weapon, iBuffer) && g_iWeaponsArray < 35)
	{
		Format(sBuffer, 64, "weapon_%s", weapon);
		PushArrayString(g_hWeaponsArray, sBuffer);
		g_iWeaponsArray += 1;
		return true;
	}
	return false;
}

public PrintMsg(client, author, String:message[])
{
	new Handle:buffer = StartMessageOne("SayText2", client, 0);
	BfWriteByte(buffer, author);
	BfWriteByte(buffer, 1);
	BfWriteString(buffer, message);
	EndMessage();
	return 0;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	new var1;
	if (attacker && attacker <= MaxClients && attacker == victim)
	{
		return Action:3;
	}
	return Action:0;
}
