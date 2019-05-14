// SKILL DRIFT 2015-2018 - d1maz.

#include <a_samp>
#include <a_mysql>
#include <dc_cmd>
#include <streamer>
#include <foreach>
#include <sscanf2>
#include <regex>

main() print("SKILL DRIFT");

// ��������� ����������� � ���� ������
static const MYSQL_HOST[]="localhost";//����, � �������� ����� ������������
static const MYSQL_DATABASE[]="skilldrift";//���� ������ � ���������
static const MYSQL_USER[]="root";//������������
static const MYSQL_PASSWORD[]="";//������ � �����������
new mysql_connection;//������ ����������� � ���� ������

// ���������
#undef MAX_PLAYERS
const MAX_PLAYERS=128;//������������ ���������� ������� ������������ �� �������
const MAX_HOUSES=256;//������������ ���������� �����
const Float:minAngleForDrift=10.0;//����������� ���� ��� ������
const Float:maxAngleForDrift=90.0;//������������ ���� ��� ������
const minSpeedForDrift=30;//����������� �������� ��� ������������ ������
static const gameModeName[]="SKLLDRFT v0.049.r2";//�������� �������� ����

// �����
#define C_RED 0xF45F5FFF//�������
#define C_GREY 0xAFAFAFFF//�����
#define C_LGREY 0xCCCCCCFF//������-�����

#define RED "{f45f5f}"//�������
#define GREY "{afafaf}"//�����
#define LGREY "{cccccc}"//������-�����

// ���������� TextDraw's
enum tddriftcounter{
	PlayerText:TD_LevelAndScore=0,
	PlayerText:TD_PointsAndMoney
}
new PlayerText:TD_DriftCounter[MAX_PLAYERS][tddriftcounter];//�����-�������
new PlayerText:TD_Speed[MAX_PLAYERS];//���������
new Text:TD_NameOfServer;//���������� TextDraw �������� �������
new Text:TD_TimeOfServer;
new scplay[MAX_PLAYERS], chets[MAX_PLAYERS];
//���������� �����-��������
new PlayerDriftCancellation[MAX_PLAYERS];
new Float:ppos[MAX_PLAYERS][3];
//���������
new player_ip[MAX_PLAYERS][16],//�� ��������
	player_time[MAX_PLAYERS];//�� ��������

new randomMessageFromServer[][]={
	"SERVER: IP ������ ������� "GREY"'server.d1maz.ru:2222'",
	"SERVER: ����� ������� ����, ����������� ������� "GREY"'Y'",
	"SERVER: ������ �� �������� "GREY"'/help'"
};

new Migalka[MAX_PLAYERS];
new Remont[MAX_PLAYERS];
new VehicleNames[212][]={
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
	{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
	{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
	{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
	{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
	{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
	{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
	{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
	{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
	{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
	{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
	{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
	{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
	{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
	{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
	{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
	{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
	{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
	{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
	{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
	{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
	{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
	{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
	{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
	{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
	{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
	{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
	{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
	{"Utility Trailer"}
};

new total_houses;
enum hInfo{
	hID,
	hPrice,
	hInterior,
	hLocked,
	hPick,
	Text3D:hLabel,
	hOwner[MAX_PLAYER_NAME],
	Float:hEnterX,
	Float:hEnterY,
	Float:hEnterZ,
	Float:hEnterA,
	Float:hExitX,
	Float:hExitY,
	Float:hExitZ,
	Float:hExitA,
	hComment[64],
}
new HouseInfo[MAX_HOUSES][hInfo];

enum pInfo{
	pID,
	pName[MAX_PLAYER_NAME],
    pCash,
    pScore,
    pLevel,
    pSkin,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
	pTogPm,
	pTimeInGame,
	pRegDate[32],
	pRegIP[16]
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum aInfo{
	aID,
	aLevel,
	aRankName[32]
}

new AdminInfo[MAX_PLAYERS][aInfo];

enum dialogs{
	dRegistration=1,
	dAuthorization,
	dAuthorizationAdminPanel,
	dAuthorizationCreatePassword,
	dMenu,
	dMenuVehicles,
	dMenuTeleports,
	dMenuTeleportsDrift,
	dMenuTeleportsAirport,
	dMenuTeleportsCity,
	dMenuAccount,
	dMenuAccountSkin,
	dEditHouse,
	dEditHouseMenu,
	dEditHouseMenuPrice,
	dEditHouseMenuInterior,
}
//<< ========== ����� ========= >>
// ��� ����������
SpeedVehicle(playerid)
{
    new Float:ST[4];
	GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);
    ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 100.3;
    return floatround(ST[3]);
}
//�������� TextDraw'ov
TD_s(playerid){
	//�����-�������
    TD_DriftCounter[playerid][TD_LevelAndScore] = CreatePlayerTextDraw(playerid, 499.912292, 106.166717, "LVL:10000~n~SCR:2500000/2500000");
	PlayerTextDrawLetterSize(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 0.234011, 1.127499);
	PlayerTextDrawTextSize(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 606.735290, 16.333330);
	PlayerTextDrawAlignment(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 1);
	PlayerTextDrawColor(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], -1);
	PlayerTextDrawUseBox(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], true);
	PlayerTextDrawBoxColor(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 37);
	PlayerTextDrawSetShadow(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 0);
	PlayerTextDrawSetOutline(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 255);
	PlayerTextDrawFont(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 1);
	PlayerTextDrawSetProportional(playerid, TD_DriftCounter[playerid][TD_LevelAndScore], 1);

	TD_DriftCounter[playerid][TD_PointsAndMoney] = CreatePlayerTextDraw(playerid, 499.506683, 131.083419, "999999999 $999999999~n~x999 $x999");
	PlayerTextDrawLetterSize(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 0.234011, 1.127499);
	PlayerTextDrawTextSize(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 606.735290, 16.333330);
	PlayerTextDrawAlignment(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 1);
	PlayerTextDrawColor(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], -1);
	PlayerTextDrawUseBox(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], true);
	PlayerTextDrawBoxColor(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 37);
	PlayerTextDrawSetShadow(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 0);
	PlayerTextDrawSetOutline(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 255);
	PlayerTextDrawFont(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 1);
	PlayerTextDrawSetProportional(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney], 1);
	//������� "Skill-Drift"
	TD_NameOfServer=TextDrawCreate(28.000000, 430.000000, "Skill-Drift");
	TextDrawBackgroundColor(TD_NameOfServer, 255);
	TextDrawFont(TD_NameOfServer, 2);
	TextDrawLetterSize(TD_NameOfServer, 0.500000, 1.000000);
	TextDrawColor(TD_NameOfServer, -16776961);
	TextDrawSetOutline(TD_NameOfServer, 0);
	TextDrawSetProportional(TD_NameOfServer, 1);
	TextDrawSetShadow(TD_NameOfServer, 1);
	//���������
	TD_Speed[playerid] = CreatePlayerTextDraw(playerid, 499.569641, 156.000061, "MDL:Luggage Trailer B~n~SPD:999km/h");
	PlayerTextDrawLetterSize(playerid, TD_Speed[playerid], 0.234011, 1.127499);
	PlayerTextDrawTextSize(playerid, TD_Speed[playerid], 606.735290, 16.333330);
	PlayerTextDrawAlignment(playerid, TD_Speed[playerid], 1);
	PlayerTextDrawColor(playerid, TD_Speed[playerid], -1);
	PlayerTextDrawUseBox(playerid, TD_Speed[playerid], true);
	PlayerTextDrawBoxColor(playerid, TD_Speed[playerid], 37);
	PlayerTextDrawSetShadow(playerid, TD_Speed[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TD_Speed[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_Speed[playerid], 255);
	PlayerTextDrawFont(playerid, TD_Speed[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TD_Speed[playerid], 1);
	//����
	TD_TimeOfServer = TextDrawCreate(547.000000, 50.000000, "");
	TextDrawBackgroundColor(TD_TimeOfServer, 255);
	TextDrawFont(TD_TimeOfServer, 3);
	TextDrawLetterSize(TD_TimeOfServer, 0.390000, 1.400000);
	TextDrawColor(TD_TimeOfServer, -1);
	TextDrawSetOutline(TD_TimeOfServer, 1);
	TextDrawSetProportional(TD_TimeOfServer, 1);
	//����� TextDraw'i ���� �������
	for(new i; i < MAX_PLAYERS; i ++)
	{
		if(IsPlayerConnected(i))
		{
			TextDrawShowForPlayer(playerid, TD_NameOfServer);
			TextDrawShowForPlayer(playerid, TD_TimeOfServer);
		}
	}
}

SaveAccount(playerid){
	GetPlayerPos(playerid,PlayerInfo[playerid][pPosX],PlayerInfo[playerid][pPosY],PlayerInfo[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid,PlayerInfo[playerid][pPosA]);
    static query[119-2-2-2-2-2-2-2-2-2+11+11+11+11+11+11+11+11+11];
    mysql_format(mysql_connection,query,sizeof(query),"update`users`set`cash`='%i',",PlayerInfo[playerid][pCash]);
    mysql_format(mysql_connection,query,sizeof(query),"%s`score`='%i',",query,PlayerInfo[playerid][pScore]);
    mysql_format(mysql_connection,query,sizeof(query),"%s`level`='%i',",query,PlayerInfo[playerid][pLevel]);
    mysql_format(mysql_connection,query,sizeof(query),"%s`pos`='%f|%f|%f|%f',",query,PlayerInfo[playerid][pPosX],PlayerInfo[playerid][pPosY],PlayerInfo[playerid][pPosZ],PlayerInfo[playerid][pPosA]);
    mysql_format(mysql_connection,query,sizeof(query),"%s`timeingame`='%i'where`id`='%i'",query,PlayerInfo[playerid][pTimeInGame],PlayerInfo[playerid][pID]);
    mysql_query(mysql_connection,query,false);
    query="";
}

ShowStats(playerid, temp_playerid){
	if(!GetPVarInt(temp_playerid,"PlayerLogged")){
	    return true;
	}
    new temp_string[75];
	static string[181-2-2-2-2-2-2-2+MAX_PLAYER_NAME+11+11+11+36+11+24];
	format(temp_string,sizeof(temp_string),"\n"GREY"������� - "LGREY"%s\n",PlayerInfo[temp_playerid][pName]);
	strcat(string,temp_string);
	format(temp_string,sizeof(temp_string),""GREY"������� - "LGREY"%i (%i / %i)\n", PlayerInfo[temp_playerid][pLevel],PlayerInfo[temp_playerid][pScore],PlayerInfo[temp_playerid][pLevel]*250);
	strcat(string,temp_string);
	format(temp_string,sizeof(temp_string),""GREY"������� � ���� - "LGREY"%s\n",convertSeconds(PlayerInfo[playerid][pTimeInGame]));
	strcat(string,temp_string);
	format(temp_string,sizeof(temp_string),""GREY"������ - "LGREY"$%i\n",PlayerInfo[temp_playerid][pCash]);
	strcat(string,temp_string);
	format(temp_string,sizeof(temp_string),""GREY"���� ����������� - "LGREY"%s\n\n", PlayerInfo[temp_playerid][pRegDate]);
	strcat(string,temp_string);
    ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"����������",string,"��","");
    string="";
    return true;
}

convertSeconds(seconds){
	new temp[36];
	new temp_days=0;
    while(seconds>=86400){
        seconds-=86400;
        temp_days++;
    }
    new temp_hours=0;
    while(seconds>=3600){
        seconds-=3600;
        temp_hours++;
    }
    new temp_minutes=0;
    while(seconds>=60){
        seconds-=60;
        temp_minutes++;
    }
    if(temp_days >= 1){
	    format(temp,sizeof(temp),"%02i ���� %02i ����� %02i ����� %02i ������",temp_days,temp_hours,temp_minutes,seconds);
	}
	else if(temp_hours >= 1){
	    format(temp,sizeof(temp),"%02i ����� %02i ����� %02i ������",temp_hours,temp_minutes,seconds);
	}
	else if(temp_minutes >= 1){
	    format(temp,sizeof(temp),"%02i ����� %02i ������",temp_minutes,seconds);
	}
	else if(seconds < 60){
	    format(temp,sizeof(temp),"%02i ������",seconds);
	}
	return temp;
}

// �������� ���� ���� ��� �����-��������
Float:GetPlayerTheoreticAngle(playerid){
	if(!GetPVarInt(playerid,"PlayerLogged")){
	    return 1.0;
	}
	new Float:sin;
	new Float:dis;
	new Float:angle2;
	new Float:x,Float:y,Float:z;
	new Float:tmp3;
	new Float:tmp4;
	new Float:MindAngle;
    GetPlayerPos(playerid,x,y,z);
    dis = floatsqroot(floatpower(floatabs(floatsub(x,ppos[playerid][0])),2)+floatpower(floatabs(floatsub(y,ppos[playerid][1])),2));
    if(IsPlayerInAnyVehicle(playerid)){
		GetVehicleZAngle(GetPlayerVehicleID(playerid), angle2);
	}
	else{
		GetPlayerFacingAngle(playerid, angle2);
	}
    if(x>ppos[playerid][0]){
		tmp3=x-ppos[playerid][0];
	}
	else{
		tmp3=ppos[playerid][0]-x;
	}
    if(y>ppos[playerid][1]){
		tmp4=y-ppos[playerid][1];
	}
	else{
		tmp4=ppos[playerid][1]-y;
	}
    if(ppos[playerid][1]>y && ppos[playerid][0]>x){
    	sin = asin(tmp3/dis);
        MindAngle = floatsub(floatsub(floatadd(sin, 90), floatmul(sin, 2)), -90.0);
	}
    if(ppos[playerid][1]<y && ppos[playerid][0]>x){
        sin = asin(tmp3/dis);
        MindAngle = floatsub(floatadd(sin, 180), 180.0);
	}
    if(ppos[playerid][1]<y && ppos[playerid][0]<x){
        sin = acos(tmp4/dis);
        MindAngle = floatsub(floatadd(sin, 360), floatmul(sin, 2));
	}
    if(ppos[playerid][1]>y && ppos[playerid][0]<x){
        sin = asin(tmp3/dis);
        MindAngle = floatadd(sin, 180);
	}
    if(MindAngle == 0.0){
		return angle2;
    }
	else{
		return MindAngle;
	}
}
// << ======= ����� ������ ======= >>
// << == �������������� ������� == >>
// ���������� ���� ���� ��� �����-��������
@__angleupdate();
@__angleupdate(){
	foreach(new i:Player){
		if(!GetPVarInt(i,"PlayerLogged")){
		    continue;
		}
		if(IsPlayerInAnyVehicle(i)){
			GetVehiclePos(GetPlayerVehicleID(i), ppos[i][0], ppos[i][1], ppos[i][2]);
		}
		else{
			GetPlayerPos(i, ppos[i][0], ppos[i][1], ppos[i][2]);
		}
	}
	SetTimer("@__angleupdate",100,false);
}
// ��� ��������� ������
@__DriftCancellation(playerid);
@__DriftCancellation(playerid){
	PlayerDriftCancellation[playerid] = 0;
	PlayerInfo[playerid][pCash]+=GetPVarInt(playerid,"driftPoints")*GetPVarInt(playerid,"driftComboForMoney");
	PlayerInfo[playerid][pScore]+=GetPVarInt(playerid,"driftPoints")*GetPVarInt(playerid,"driftComboForPoints");
	DeletePVar(playerid,"driftPoints");
	ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,PlayerInfo[playerid][pCash]);
	PlayerTextDrawHide(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney]);
}

// ��� ��� ��������
@__kick_player(playerid);
@__kick_player(playerid){
	Kick(playerid);
}

@__general_timer();
@__general_timer(){
    foreach(new i:Player){
        if(!GetPVarInt(i,"PlayerLogged") && gettime()-GetPVarInt(i,"LoginTime")>60){
            SendClientMessage(i, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���� ������� �� ��������� ������� �������.(1 ������)");
            SetTimerEx("@__kick_player",100,false,"i",i);
  			continue;
        }
        if(!GetPVarInt(i,"PlayerLogged")){
            continue;
        }
 		if(IsPlayerInAnyVehicle(i) && Remont[i]){
			new Float:temp_health;
			GetVehicleHealth(GetPlayerVehicleID(i),temp_health);
            if(temp_health < 1000.0){
				RepairVehicle(GetPlayerVehicleID(i));
			}
		}
		if(IsPlayerInAnyVehicle(i)){
			new string[22-2-2+24+3];
			format(string,sizeof(string),"MDL:%s~n~SPD:%ikm/h", VehicleNames[GetVehicleModel(GetPlayerVehicleID(i))-400],SpeedVehicle(i));
			PlayerTextDrawSetString(i, TD_Speed[i], string);
			format(string,sizeof(string),"LVL:%i~n~SCR:%i/%i",PlayerInfo[i][pLevel],PlayerInfo[i][pScore],PlayerInfo[i][pLevel]*250);
			PlayerTextDrawSetString(i, TD_DriftCounter[i][TD_LevelAndScore],string);
		}
		if(PlayerInfo[i][pScore] >= (PlayerInfo[i][pLevel]*250)){
		    PlayerInfo[i][pScore]-=PlayerInfo[i][pLevel]*250;
		    PlayerInfo[i][pLevel]++;
		    SetPlayerScore(i,PlayerInfo[i][pLevel]);
		    new string[57-2-2+11+11];
			format(string,sizeof(string),"�����������, ��� ������� ��������� �� %d-���. �����: %d$", PlayerInfo[i][pLevel], PlayerInfo[i][pLevel]*100);
			SendClientMessage(i,-1,string);
			ResetPlayerMoney(i);
			PlayerInfo[i][pCash]+=PlayerInfo[i][pLevel]*100;
			GivePlayerMoney(i,PlayerInfo[i][pCash]);
		    new query[68-2-2-2+11+11+11];
		    mysql_format(mysql_connection,query,sizeof(query),"update`users`set`cash`='%i',`level`='%i',`score`='0'where`id`='%i'",PlayerInfo[i][pCash],PlayerInfo[i][pLevel],PlayerInfo[i][pID]);
		    mysql_query(mysql_connection,query,false);
		}
		PlayerInfo[i][pTimeInGame]++;
	}
	if(gettime()-GetSVarInt("timeForRandomMessage") > 120){
	    SendClientMessageToAll(C_LGREY,randomMessageFromServer[random(sizeof(randomMessageFromServer))]);
	    SetSVarInt("timeForRandomMessage",gettime());
	}
	new string[15];
	new temp_hour,temp_minute,temp_seconds;
	gettime(temp_hour,temp_minute,temp_seconds);
	format(string,sizeof(string),"%02i:%02i:%02i",temp_hour,temp_minute,temp_seconds);
	TextDrawSetString(TD_TimeOfServer,string);
	SetTimer("@__general_timer",1000,false);
	return true;
}

public OnGameModeInit(){
	mysql_connection=mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_DATABASE,MYSQL_PASSWORD);
	mysql_set_charset("cp1251",mysql_connection);
	SendRconCommand("hostname SKILL DRIFT");
	SetGameModeText(gameModeName);
	SendRconCommand("mapname San Andreas");
	SendRconCommand("weburl vk.com/d1maz.community");
	SendRconCommand("rcon_password QAZWSXEDC");
	SendRconCommand("language Russian");
	SetSVarInt("timeForRandomMessage",gettime());
	UsePlayerPedAnims(); // ��� ������� � ���� �������
	DisableInteriorEnterExits(); // ������� ������� ����� � ������
	ShowPlayerMarkers(1); // ���������� ��� �� ���������� ������� �� �����
	SetNameTagDrawDistance(40.0); // ���������� �� ������� ����� ����
	new Cache:cache_houses=mysql_query(mysql_connection,"select*from`houses`");
	if(cache_get_row_count(mysql_connection)){
	    new temp_time=GetTickCount();
	    new string[87-2-2-2+11+MAX_PLAYER_NAME+64];
		for(new i=0; i<cache_get_row_count(mysql_connection); i++){
			HouseInfo[i][hID]=cache_get_field_content_int(i,"id",mysql_connection);
			HouseInfo[i][hPrice]=cache_get_field_content_int(i,"price",mysql_connection);
			HouseInfo[i][hInterior]=cache_get_field_content_int(i,"interior",mysql_connection);
			HouseInfo[i][hLocked]=cache_get_field_content_int(i,"locked",mysql_connection);
			cache_get_field_content(i,"owner",HouseInfo[i][hOwner],mysql_connection,MAX_PLAYER_NAME);
			new temp[64];
			cache_get_field_content(i,"enterpos",temp,mysql_connection,sizeof(temp));
			sscanf(temp,"p<|>ffff",HouseInfo[i][hEnterX],HouseInfo[i][hEnterY],HouseInfo[i][hEnterZ],HouseInfo[i][hEnterA]);
			cache_get_field_content(i,"exitpos",temp,mysql_connection,sizeof(temp));
			sscanf(temp,"p<|>ffff",HouseInfo[i][hExitX],HouseInfo[i][hExitY],HouseInfo[i][hExitZ],HouseInfo[i][hExitA]);
			cache_get_field_content(i,"comment",HouseInfo[i][hComment],mysql_connection,64);
			if(!strcmp(HouseInfo[i][hOwner],"-")){
				HouseInfo[i][hPick] = CreateDynamicPickup(1273, 23, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
				format(string, sizeof(string), "{15FF00}���: {FFFFFF}%d\n{FF0000}��������\n{15FF00}����: {FFFFFF}%d", HouseInfo[i][hID], HouseInfo[i][hPrice]);
			}
			else{
			    format(string, sizeof(string), "{15FF00}���: {FFFFFF}%d\n{15FF00}��������: {FFFFFF}%s\n{15FF00}�����������: {FFFFFF}%s", HouseInfo[i][hID], HouseInfo[i][hOwner], HouseInfo[i][hComment]);
				HouseInfo[i][hPick] = CreateDynamicPickup(1272, 23, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
			}
			HouseInfo[i][hLabel] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ], 30.0);
			total_houses++;
		}
		printf("����� ���������: %d/%d [%ims]", total_houses, MAX_HOUSES,GetTickCount()-temp_time);
	}
	cache_delete(cache_houses,mysql_connection);
	SetTimer("@__drift",100,false);
	SetTimer("@__general_timer",1000,false);
	SetTimer("@__angleupdate",100,false);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
	SaveAccount(playerid);
	return true;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid){
    if(GetPVarInt(playerid,"driftPoints")){
	    DeletePVar(playerid,"driftPoints");
		PlayerTextDrawSetString(playerid, TD_DriftCounter[playerid][TD_PointsAndMoney],"~n~CRSH");
	}
	return true;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source){
    ShowStats(playerid, clickedplayerid);
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	//����
  	if(newkeys & KEY_YES){
		ShowPlayerDialog(playerid, dMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ������� ����", "{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������� ���������", "��", "������");
	}
 	if( newkeys == 1 || newkeys == 9 || newkeys == 33 && oldkeys != 1 || oldkeys != 9 || oldkeys != 33){
		new Car = GetPlayerVehicleID(playerid), Model = GetVehicleModel(Car);
		switch(Model){
			case 446,432,448,452,424,453,454,461,462,463,468,471,430,472,449,473,481,484,493,495,509,510,521,538,522,523,532,537,570,581,586,590,569,595,604,611: return 0;
		}
		AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
    }
  	return true;
}

public OnPlayerStateChange(playerid, newstate, oldstate){
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER){
		PlayerTextDrawShow(playerid, TD_DriftCounter[playerid][TD_LevelAndScore]);
		PlayerTextDrawShow(playerid, TD_Speed[playerid]);
	}
	else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER){
		PlayerTextDrawHide(playerid, TD_DriftCounter[playerid][TD_LevelAndScore]);
		PlayerTextDrawHide(playerid, TD_Speed[playerid]);
	}
	return true;
}

public OnPlayerRequestClass(playerid, classid){
	new query[45-2+MAX_PLAYER_NAME];
	mysql_format(mysql_connection,query,sizeof(query),"select`id`from`users`where`name`='%e'limit 1",PlayerInfo[playerid][pName]);
	new Cache:cache_users=mysql_query(mysql_connection,query);
	if(cache_get_row_count(mysql_connection)){
 		ShowPlayerDialog(playerid, dAuthorization, DIALOG_STYLE_PASSWORD,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� ������ � ����-������ �������!\n\n{FFFFFF}��� ���������� ��������������\n\n","��","������");
  		SendClientMessage(playerid, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ��� ����������� ����, ��� ���������� ��������������!");
   	}
	else{
		ShowPlayerDialog(playerid, dRegistration, DIALOG_STYLE_INPUT,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� �� ������ � ����-������ �������!\n\n{FFFFFF}��� ���������� ������������������!\n\n{FFFFFF}������ ������������ � ��������:\n\n{FFFFFF}������ ��������� ����� � �����!\n\n{FFFFFF}�� 4 �� 16 ��������","��","������");
 		SendClientMessage(playerid, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ��� ������ ����, ��� ���������� ������������������!");
  	}
  	cache_delete(cache_users,mysql_connection);
 	return true;
}

public OnPlayerConnect(playerid){
	GetPlayerName(playerid,PlayerInfo[playerid][pName],MAX_PLAYER_NAME);
	TD_s(playerid);
	new temp_ip[16];
	GetPlayerIp(playerid,temp_ip,sizeof(temp_ip));
	for(new i=0; i<MAX_PLAYERS; i++){
	    if(!strcmp(player_ip[i],temp_ip)){
	        if(gettime()-player_time[i] < 20){
				SendClientMessage(i,-1,"�� ���� �������. �������: ���������� �� reconnect");
	            SetTimerEx("@__kick_player",200,false,"i",i);
	            break;
	        }
	    }
	}
	GetPlayerIp(playerid,player_ip[playerid],16);
	scplay[playerid] = 1;
	chets[playerid] = 1;
	Migalka[playerid] = 0;
	Remont[playerid] = 1;
	SetPVarInt(playerid,"LoginTime",gettime());
    return true;
}

public OnPlayerDisconnect(playerid, reason){
    SaveAccount(playerid);
	for(new pInfo:i; i<pInfo; i++){
     	PlayerInfo[playerid][i]=EOS;
	}
	for(new aInfo:i; i<aInfo; i++){
	    AdminInfo[playerid][i]=EOS;
	}
	player_time[playerid]=gettime();
  	return true;
}

public OnPlayerSpawn(playerid){
	if(!GetPVarInt(playerid,"PlayerLogged")){
	    SendClientMessage(playerid,C_RED,"�� ���� ������� ��������! �������: ����� ��� �����������/�����������");
	    SetTimerEx("@__kick_player",250,false,"i",playerid);
	    return true;
	}
 	SetPVarInt(playerid,"PlayerLogged",1);
	DeletePVar(playerid,"PasswordAttemps");
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][pCash]);
    SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	SetPlayerHealth(playerid, 99999999.9);
 	SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
    if(!PlayerInfo[playerid][pPosX] && !PlayerInfo[playerid][pPosY]){
        SetPlayerPos(playerid, 228.228, 228.228, 228.228);
	}
	else{
        SetPlayerPos(playerid,PlayerInfo[playerid][pPosX],PlayerInfo[playerid][pPosY],PlayerInfo[playerid][pPosZ]);
        SetPlayerFacingAngle(playerid,PlayerInfo[playerid][pPosA]);
	}
	return true;
}

Float:ReturnPlayerAngle(playerid){
	new Float:Ang;
	if(IsPlayerInAnyVehicle(playerid)){
		GetVehicleZAngle(GetPlayerVehicleID(playerid), Ang);
	}
 	else{
	 	GetPlayerFacingAngle(playerid, Ang);
	}
	return Ang;
}

@__drift();
@__drift(){
	new Float:Angle1, Float:Angle2;
	foreach(new i:Player){
		if(!GetPVarInt(i,"PlayerLogged")){
		    continue;
		}
		Angle1 = ReturnPlayerAngle(i);
		Angle2 = GetPlayerTheoreticAngle(i);
		if(IsPlayerInAnyVehicle(i) && IsCar(GetPlayerVehicleID(i)) && floatabs(floatsub(Angle1, Angle2)) > minAngleForDrift && floatabs(floatsub(Angle1, Angle2)) < maxAngleForDrift && SpeedVehicle(i) > minSpeedForDrift){
			if(PlayerDriftCancellation[i]){
				KillTimer(PlayerDriftCancellation[i]);
			}
			SetPVarInt(i,"driftPoints",GetPVarInt(i,"driftPoints")+1);
			if(GetPVarInt(i,"driftPoints") <= 50){
			    SetPVarInt(i,"driftComboForPoints",1);
       			SetPVarInt(i,"driftComboForMoney",1);
			}
			if(GetPVarInt(i,"driftPoints") == (150*GetPVarInt(i,"driftComboForPoints"))){
			    SetPVarInt(i,"driftComboForPoints",GetPVarInt(i,"driftComboForPoints")+1);
			}
			if(GetPVarInt(i,"driftPoints") == (200*GetPVarInt(i,"driftComboForMoney"))){
			    SetPVarInt(i,"driftComboForMoney",GetPVarInt(i,"driftComboForMoney")+1);
			}
			PlayerDriftCancellation[i] = SetTimerEx("@__DriftCancellation", 2000, false, "i", i);
		}
		if(GetPVarInt(i,"driftPoints")){
		    if(scplay[i]){
		        new string[18-2-2-2-2+11+11+1+1];
			    PlayerTextDrawShow(i,TD_DriftCounter[i][TD_PointsAndMoney]);
				format(string, sizeof(string), "%i $%i~n~x%i $x%i",GetPVarInt(i,"driftPoints")*GetPVarInt(i,"driftComboForPoints"),GetPVarInt(i,"driftPoints")*GetPVarInt(i,"driftComboForMoney"),GetPVarInt(i,"driftComboForPoints"),GetPVarInt(i,"driftComboForMoney"));
				PlayerTextDrawSetString(i,TD_DriftCounter[i][TD_PointsAndMoney], string);
			}
		}
	}
	SetTimer("@__drift",100,false);
}

IsCar(model){
	switch(model){
		case 406,417,425,443,444,446..448,452..454,460..465,468,469,471..473,476,481,484,487,488,493,497,501,509..513,519..523,530,539,548,553,556,557,563,573,577,581,586,592,593,595:{
			return false;
		}
	}
	return true;
}

public OnPlayerText(playerid, text[]){
	new string[19-2-2-2+MAX_PLAYER_NAME+3+128];
	format(string,sizeof(string), "%s{ffffff}(%i): %s",PlayerInfo[playerid][pName], playerid, text);
	SendClientMessageToAll(GetPlayerColor(playerid), string);
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    switch(dialogid){
        case dRegistration:{
            if(response){
                new temp_password[16];
                if(sscanf(inputtext,"s[128]",temp_password)){
                    ShowPlayerDialog(playerid, dRegistration, DIALOG_STYLE_INPUT,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� �� ������ � ����-������ �������!\n\n{FFFFFF}��� ���������� ������������������!\n\n{FFFFFF}������ ������������ � ��������:\n\n{FFFFFF}������ ��������� ����� � �����!\n\n{FFFFFF}�� 4 �� 16 ��������","��","������");
                    return true;
                }
            	if(!regex_match(temp_password,"[a-zA-Z0-9]{4,16}+")){
					ShowPlayerDialog(playerid, dRegistration, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} �����������","\n{FFFFFF}� ������ ���� ������� ������������ �������!\n","��","�����");
					return true;
				}
				new temp_ip[16];
				GetPlayerIp(playerid,temp_ip,sizeof(temp_ip));
            	new query[68-2-2+MAX_PLAYER_NAME+16+16];
				mysql_format(mysql_connection,query,sizeof(query),"insert into`users`(`name`,`password`,`regip`)values('%e','%e','%e')",PlayerInfo[playerid][pName],inputtext,temp_ip);
				new Cache:cache_users=mysql_query(mysql_connection,query);
				PlayerInfo[playerid][pID]=cache_insert_id(mysql_connection);
				cache_delete(cache_users,mysql_connection);
				mysql_format(mysql_connection,query,sizeof(query),"select`regdate`from`users`where`id`='%i'",PlayerInfo[playerid][pID]);
				cache_users=mysql_query(mysql_connection,query);
				cache_get_field_content(0,"regdate",PlayerInfo[playerid][pRegDate],mysql_connection,32);
				cache_delete(cache_users,mysql_connection);
                PlayerInfo[playerid][pLevel] = 1;
				SetPVarInt(playerid,"PlayerLogged",1);
				SpawnPlayer(playerid);
            }
            else{
				SendClientMessage(playerid, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���� ��������� �� �������, �� ���������� �����������");
				SetTimerEx("@__kick_player",100,false,"i",playerid);
			}
        }
        case dAuthorization:{
            if(response){
                new temp_password[16];
                if(sscanf(inputtext,"s[128]",temp_password)){
                    ShowPlayerDialog(playerid, dAuthorization, DIALOG_STYLE_INPUT,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� ��� ������ � ����-������ �������!","����","�����");
                    return true;
                }
                if(!regex_match(temp_password,"[a-zA-Z0-9]{4,16}+")){
					ShowPlayerDialog(playerid, dAuthorization, DIALOG_STYLE_INPUT,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� ��� ������ � ����-������ �������!","����","�����");
					return true;
				}
                new query[60-2-2+MAX_PLAYER_NAME+16];
                mysql_format(mysql_connection,query,sizeof(query),"select*from`users`where`name`='%e'and`password`='%e'limit 1",PlayerInfo[playerid][pName],inputtext);
				new Cache:cache_users=mysql_query(mysql_connection,query);
                if(cache_get_row_count(mysql_connection)){
                    PlayerInfo[playerid][pID]=cache_get_field_content_int(0,"id",mysql_connection);
                    PlayerInfo[playerid][pCash]=cache_get_field_content_int(0,"cash",mysql_connection);
                    PlayerInfo[playerid][pScore]=cache_get_field_content_int(0,"score",mysql_connection);
                    PlayerInfo[playerid][pLevel]=cache_get_field_content_int(0,"level",mysql_connection);
                    PlayerInfo[playerid][pSkin]=cache_get_field_content_int(0,"skin",mysql_connection);
                    new temp[64];
                    cache_get_field_content(0,"pos",temp,mysql_connection,sizeof(temp));
                    sscanf(temp,"p<|>ffff",PlayerInfo[playerid][pPosX],PlayerInfo[playerid][pPosY],PlayerInfo[playerid][pPosZ],PlayerInfo[playerid][pPosA]);
                    PlayerInfo[playerid][pTogPm]=cache_get_field_content_int(0,"togpm",mysql_connection);
                    PlayerInfo[playerid][pTimeInGame]=cache_get_field_content_int(0,"timeingame",mysql_connection);
                    cache_get_field_content(0,"regdate",PlayerInfo[playerid][pRegDate],mysql_connection,32);
                    cache_get_field_content(0,"regip",PlayerInfo[playerid][pRegIP],mysql_connection,32);
                    mysql_format(mysql_connection,query,sizeof(query),"select`id`from`houses`where`owner`='%e'limit 1",PlayerInfo[playerid][pName]);
					new Cache:cache_houses=mysql_query(mysql_connection,query);
					if(cache_get_row_count(mysql_connection)){
					    new temp_id=cache_get_field_content_int(0,"id",mysql_connection);
					    SetPVarInt(playerid,"HouseOwner",temp_id);
					}
					cache_delete(cache_houses,mysql_connection);
					mysql_format(mysql_connection,query,sizeof(query),"select*from`admins`where`name`='%e'limit 1",PlayerInfo[playerid][pName]);
					new Cache:cache_admins=mysql_query(mysql_connection,query);
					if(cache_get_row_count(mysql_connection)){
						mysql_format(mysql_connection,query,sizeof(query),"select*from`admins`where`name`='%e'and`password`='-'limit 1",PlayerInfo[playerid][pName]);
						cache_admins=mysql_query(mysql_connection,query);
						if(cache_get_row_count(mysql_connection)){
						    ShowPlayerDialog(playerid,dAuthorizationCreatePassword,DIALOG_STYLE_PASSWORD,"�����������","\n{ffffff}����� ��� ��� ����������, ��� ����� ������� ����� ������ � �����-������:\n\n","������","������");
						}
						else{
						    ShowPlayerDialog(playerid,dAuthorizationAdminPanel,DIALOG_STYLE_PASSWORD,"�����������","\n{ffffff}��� ����� �������������� � �����-������:\n\n","������","������");
						}
						cache_delete(cache_admins,mysql_connection);
						return true;
					}
					cache_delete(cache_admins,mysql_connection);
					cache_set_active(cache_users,mysql_connection);
					SetPVarInt(playerid,"PlayerLogged",1);
                    SpawnPlayer(playerid);
                }
                else{
                    ShowPlayerDialog(playerid, dAuthorization, DIALOG_STYLE_INPUT,"{ff0000}�{ffffff} �����������","{FFFFFF}��� ������� ��� ������ � ����-������ �������!","����","�����");
                    SetPVarInt(playerid,"PasswordAttemps",GetPVarInt(playerid,"PasswordAttemps")+1);
                    switch(GetPVarInt(playerid,"PasswordAttemps")){
	                    case 1..3:{
	                        new string[100-2+1];
	                        format(string,sizeof(string),"{FF0000}Skill{FFFFFF}-{FF0000}Drift{FFFFFF}: ������������ ������! ���������� ��� ���! �������: %i/3",GetPVarInt(playerid,"PasswordAttemps"));
							SendClientMessage(playerid,-1,string);
						}
						default:{
							SendClientMessage(playerid, -1,"{FF0000}Skill{FFFFFF}-{FF0000}Drift{FFFFFF}: �� ���� ������� �������� �� ���������� � ������� ������!");
							SetTimerEx("@__kick_player",100,false,"i",playerid);
						}
					}
				}
				cache_delete(cache_users,mysql_connection);
            }
            else{
                SendClientMessage(playerid, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���� ������� �������� �� ���������� �����������");
				SetTimerEx("@__kick_player",100,false,"i",playerid);
            }
        }
        case dAuthorizationAdminPanel:{
            if(response){
                new temp_password[16];
                if(sscanf(inputtext,"s[128]",temp_password)){
                    ShowPlayerDialog(playerid,dAuthorizationAdminPanel,DIALOG_STYLE_PASSWORD,"�����������","\n{ffffff}��� ����� �������������� � �����-������:\n\n","������","������");
                    return true;
                }
                if(!regex_match(temp_password,"[a-zA-Z0-9]{4,16}+")){
                    ShowPlayerDialog(playerid,dAuthorizationAdminPanel,DIALOG_STYLE_PASSWORD,"�����������","\n� ������ ������� ������������ �������!\n\n{ffffff}��� ����� �������������� � �����-������:\n\n","������","������");
                    return true;
                }
                new query[83-2-2+MAX_PLAYER_NAME+16];
                mysql_format(mysql_connection,query,sizeof(query),"select`id`,`level`,`rankname`from`admins`where`name`='%e'and`password`='%e'limit 1",PlayerInfo[playerid][pName],temp_password);
                new Cache:cache_admins=mysql_query(mysql_connection,query);
                if(cache_get_row_count(mysql_connection)){
                    AdminInfo[playerid][aID]=cache_get_field_content_int(0,"id",mysql_connection);
					AdminInfo[playerid][aLevel]=cache_get_field_content_int(0,"level",mysql_connection);
					cache_get_field_content(0,"rankname",AdminInfo[playerid][aRankName],mysql_connection,32);
					SetPVarInt(playerid,"PlayerLogged",1);
					SpawnPlayer(playerid);
                }
                else{
                    SendClientMessage(playerid,C_RED,"��������, ��������� ������!");
                    SetTimerEx("@__kick_player",200,false,"i",playerid);
                }
                cache_delete(cache_admins,mysql_connection);
            }
            else{
                SetTimerEx("@__kick_player",200,false,"i",playerid);
            }
        }
        case dAuthorizationCreatePassword:{
            if(response){
                new temp_password[16];
                if(sscanf(inputtext,"s[128]",temp_password)){
                    ShowPlayerDialog(playerid,dAuthorizationCreatePassword,DIALOG_STYLE_PASSWORD,"�����������","\n{ffffff}����� ��� ��� ����������, ��� ����� ������� ����� ������ � �����-������:\n\n","������","������");
                    return true;
                }
                if(!regex_match(temp_password,"[a-zA-Z0-9]{4,16}+")){
                    ShowPlayerDialog(playerid,dAuthorizationCreatePassword,DIALOG_STYLE_PASSWORD,"�����������","\n{ffffff}� ������ ������� ������������ �������!\n\n����� ��� ��� ����������, ��� ����� ������� ����� ������ � �����-������:\n\n","������","������");
                    return true;
                }
                new query[56-2-2+MAX_PLAYER_NAME+16];
				mysql_format(mysql_connection,query,sizeof(query),"update`admins`set`password`='%e'where`name`='%e'limit 1",temp_password,PlayerInfo[playerid][pName]);
				mysql_query(mysql_connection,query,false);
				SendClientMessage(playerid,-1,"��� ����� ��������� �� ������!");
                SetTimerEx("@__kick_player",200,false,"i",playerid);
            }
            else{
                SetTimerEx("@__kick_player",200,false,"i",playerid);
            }
        }
        case dMenu:{
			if(response){
			    switch(listitem){
					case 0:{
						static string[179-2-2+10+10];
						new temp_repair[10];
						format(temp_repair,sizeof(temp_repair),Remont[playerid]?"���������":"��������");
						new temp_flasher[10];
						format(temp_flasher,sizeof(temp_flasher),Migalka[playerid]?"������":"���������");
						format(string, sizeof(string), "{ff0000}�{ffffff} ������� ���������\n{ff0000}�{ffffff} %s ����-������\n{ff0000}�{ffffff} ���������� �����������\n{ff0000}�{ffffff} %s �������\n{ff0000}�{ffffff} ������� ���������",temp_repair,temp_flasher);
						ShowPlayerDialog(playerid, dMenuVehicles, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", string, "�������", "�����");
						string="";
					}
					case 1:{
						ShowPlayerDialog(playerid, dMenuTeleports, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", "{ff0000}�{ffffff} ����� �����\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ������", "��", "�����");
					}
					case 2:{
						ShowPlayerDialog(playerid, dMenuAccount, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������� ���������", "{ff0000}�{ffffff} ����������� ����������\n{ff0000}�{ffffff} ������� ����\n{ff0000}�{ffffff} ������� ������", "��", "�����");
					}
				}
	   		}
	    }
	    case dMenuVehicles:{
	      	if(response){
	      	    switch(listitem){
				    case 0:{
						if(IsPlayerInAnyVehicle(playerid)){
							SendClientMessage(playerid,-1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ��� ���������� � ����������!");
							return true;
						}
					}
					case 1:{
					    Remont[playerid]=Remont[playerid]?0:1;
					    SendClientMessage(playerid, -1,Remont[playerid]?"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� �������� ������� ����-������!":"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ��������� ������� ����-������!");
					}
					case 2:{
						ShowPlayerDialog(playerid, 430, DIALOG_STYLE_LIST,"{ff0000}�{ffffff} ���������� �����������","������� ���������\n��������� ���������\n������� ��������\n������� ��������\n������� �����\n������� �����\n�������� ����\n��������� ����","��","������");
					}
					case 3:{
						new temp_flasher = CreateObject(18646,0,0,0,0,0,0,100.0);
						if(Migalka[playerid]){
							DestroyObject(temp_flasher);
						}
						else{
							AttachObjectToVehicle(temp_flasher, GetPlayerVehicleID(playerid), -0.4, -0.1, 0.87, 0.0, 0.0, 0.0);
						}
						Migalka[playerid]=Migalka[playerid]?0:1;
						SendClientMessage(playerid, -1,Migalka[playerid]?"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ��������� �������!":"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������ �������!");
					}
					case 4:{
						DestroyVehicle(GetPlayerVehicleID(playerid));
					}
				}
			}
			else{
				ShowPlayerDialog(playerid, dMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ������� ����", "{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������� ���������", "��", "�����");
			}
		}
		case dMenuTeleports:{
			if(response){
			    switch(listitem){
		            case 0:{
						ShowPlayerDialog(playerid, dMenuTeleportsDrift, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �����", "{ff0000}�{ffffff} ����� 1\n{ff0000}�{ffffff} ����� 2\n{ff0000}�{ffffff} ����� 3\n{ff0000}�{ffffff} ����� 4\n{ff0000}�{ffffff} ����� 5\n{ff0000}�{ffffff} ����� 6", "��", "�����");
					}
					case 1:{
						ShowPlayerDialog(playerid, dMenuTeleportsAirport, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", "{ff0000}�{ffffff} �������� LS\n{ff0000}�{ffffff} �������� SF\n{ff0000}�{ffffff} �������� LV\n{ff0000}�{ffffff} ����������� ��������", "��", "�����");
					}
		   			case 2:{
					   	ShowPlayerDialog(playerid, dMenuTeleportsCity, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ������", "{ff0000}�{ffffff} Los Santos\n{ff0000}�{ffffff} San Fierro\n{ff0000}�{ffffff} Las Venturas\n{ff0000}�{ffffff} El Quebrados\n{ff0000}�{ffffff} Las Barrancas\n{ff0000}�{ffffff} Fort Carson\n{ff0000}�{ffffff} Blueberry\n{ff0000}�{ffffff} Dillimore\n{ff0000}�{ffffff} Montgomery\n{ff0000}�{ffffff} Angel Pine\n{ff0000}�{ffffff} Bayside", "��", "�����");
					}
				}
			}
			else{
				ShowPlayerDialog(playerid, dMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ������� ����", "{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ���������� ���������", "��", "�����");
			}
	 	}
	 	case dMenuTeleportsDrift:{
			if(response){
			    new Float:temp_pos[6][3]={
					{-330.3569,1515.5521,75.0184},
					{-2412.5056,-601.7757,132.2340},
					{2283.6584,1391.7118,42.4805},
					{-1987.4824,-858.5297,31.6830},
					{-1755.4816,952.0782,24.4013},
					{1996.9541,-2304.0129,13.2068}
				};
				switch(GetPlayerState(playerid)){
				    case PLAYER_STATE_DRIVER:{
                        SetVehiclePos(GetPlayerVehicleID(playerid),temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				    default:{
                        SetPlayerPos(playerid,temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				}
				new string[36-2+2];
				format(string,sizeof(string),"�� ���� ��������������� �� �����-%i",listitem+1);
				SendClientMessage(playerid,-1,string);
			}
	  		else{
			  	ShowPlayerDialog(playerid, dMenuTeleports, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", "{ff0000}�{ffffff} ����� �����\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ������", "��", "�����");
			}
	 	}
	 	case dMenuTeleportsAirport:{
			if(response){
			    new Float:temp_pos[4][3]={
					{-1329.8973,-202.8663,13.8065},
					{1432.2272,1455.9191,10.4809},
					{-1473.7897,-204.7863,14.1484},
					{386.1420,2538.1768,16.5391}
				};
				switch(GetPlayerState(playerid)){
				    case PLAYER_STATE_DRIVER:{
                        SetVehiclePos(GetPlayerVehicleID(playerid),temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				    default:{
                        SetPlayerPos(playerid,temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				}
				new string[38-2+2];
				format(string,sizeof(string),"�� ���� ��������������� � ��������-%i",listitem+1);
				SendClientMessage(playerid,-1,string);
			}
			else{
				ShowPlayerDialog(playerid, dMenuTeleports, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", "{ff0000}�{ffffff} ����� �����\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ������", "��", "�����");
			}
	 	}
	 	case dMenuTeleportsCity:{
			if(response){
			    new Float:temp_pos[11][3]={
					{1478.7522,-1615.8807,13.6996},
					{-1990.8055,137.5408,27.1984},
					{2108.1091,1433.7200,10.4806},
					{-1400.0054,2645.3564,55.6875},
					{-856.1672,1551.1436,23.5402},
					{-322.7890,1057.1068,19.7422},
					{196.6782,-162.8545,1.5781},
					{677.4210,-476.0571,16.3359},
					{1360.4482,258.2161,19.5669},
					{-2163.8359,-2387.6326,30.6250},
					{-2433.5396,2322.8796,4.9836}
				};
                switch(GetPlayerState(playerid)){
				    case PLAYER_STATE_DRIVER:{
                        SetVehiclePos(GetPlayerVehicleID(playerid),temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				    default:{
                        SetPlayerPos(playerid,temp_pos[listitem][0],temp_pos[listitem][1],temp_pos[listitem][2]);
				    }
				}
				new string[35-2+2];
				format(string,sizeof(string),"�� ���� ��������������� � �����-%i",listitem+1);
				SendClientMessage(playerid,-1,string);
			}
			else{
				ShowPlayerDialog(playerid, dMenuTeleports, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������", "{ff0000}�{ffffff} ����� �����\n{ff0000}�{ffffff} ���������\n{ff0000}�{ffffff} ������", "��", "�����");
			}
	 	}
		case dMenuAccount:{
			if(response){
				switch(listitem){
					case 0:{
						ShowStats(playerid,playerid);
					}
					case 1:{
						ShowPlayerDialog(playerid, dMenuAccountSkin, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ����� �����", "{FFFFFF}��� ����� ����� ��� ���������� ������� �� �����\n{FFFFFF}���������: 1-299", "�������", "�����");
					}
					case 2:{
					}
					case 3:{
					}
				}
			}
		}
		case dMenuAccountSkin:{
			if(response){
			    new temp_value;
			    if(sscanf(inputtext,"i",temp_value)){
			        ShowPlayerDialog(playerid, dMenuAccountSkin, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ����� �����", "{FFFFFF}��� ����� ����� ��� ���������� ������� �� �����\n{FFFFFF}���������: 1-299", "�������", "�����");
			        return true;
			    }
			    if(temp_value < 1 || temp_value > 314){
			        ShowPlayerDialog(playerid, dMenuAccountSkin, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ����� �����", "{FFFFFF}��� ����� ����� ��� ���������� ������� �� �����\n{FFFFFF}���������: 1-314", "�������", "�����");
			        return true;
			    }
			    PlayerInfo[playerid][pSkin]=temp_value;
		  		SetPlayerSkin(playerid,temp_value);
		  		new query[42-2-2+3+11];
		  		mysql_format(mysql_connection,query,sizeof(query),"update`users`set`skin`='%i'where`id`='%i'",PlayerInfo[playerid][pSkin],PlayerInfo[playerid][pID]);
		  		mysql_query(mysql_connection,query,false);
			}
			else{
				ShowPlayerDialog(playerid, dMenuAccount, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} ���������� ���������", "{ff0000}�{ffffff} ����������� ����������\n{ff0000}�{ffffff} ������� ����\n{ff0000}�{ffffff} ������� ������", "��", "�����");
			}
		}
		case dEditHouse:{
			if(response){
			    new temp_value;
			    if(sscanf(inputtext,"i",temp_value)){
			        ShowPlayerDialog(playerid, dEditHouse, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} �������������", "������� ����� ���� ��� ������� ������ ������ ������", "��", "������");
			        return true;
			    }
			    new query[40-2+11];
			    mysql_format(mysql_connection,query,sizeof(query),"select`id`from`houses`where`id`='%i'",temp_value);
			    new Cache:cache_houses=mysql_query(mysql_connection,query);
			    if(!cache_get_row_count(mysql_connection)){
	                SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ��������� ����� ���� �� ������ � ����-������");
	                return true;
			    }
			    cache_delete(cache_houses,mysql_connection);
				SetPVarInt(playerid,"EditHouse_ID",temp_value);
				new string[77-2+11];
				format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������ ������ ��� ����� �%d.",temp_value);
				SendClientMessage(playerid, -1, string);
				ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
			}
		}
		case dEditHouseMenu:{
			if(response){
			    new temp_houseid=GetPVarInt(playerid,"EditHouse_ID");
			    if(!temp_houseid){
			        return true;
			    }
			    switch(listitem){
					case 0:{
						ShowPlayerDialog(playerid, dEditHouseMenuPrice, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} ����", "������� ����� ���� ����", "��", "�����");
					}
					case 1:{
						ShowPlayerDialog(playerid, dEditHouseMenuInterior, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} �������", "������� ����� �������", "��", "�����");
					}
					case 2:{
						strmid(HouseInfo[temp_houseid-1][hOwner],"-",0,strlen("-"),MAX_PLAYER_NAME);
						strmid(HouseInfo[temp_houseid-1][hComment],"/changecomment",0,strlen("/changecomment"),64);
						new query[48-2+11];
						mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`owner`=default where`id`='%i'",HouseInfo[temp_houseid-1][hID]);
						mysql_query(mysql_connection,query,false);
						new string[69-2-2+11+11];
						format(string, sizeof(string), "{15FF00}���:{FFFFFF} %d\n{FF0000}��������\n{15FF00}����:{FFFFFF} %d", HouseInfo[temp_houseid-1][hID], HouseInfo[temp_houseid-1][hPrice]);
						DestroyDynamicPickup(HouseInfo[temp_houseid-1][hPick]);
						HouseInfo[temp_houseid-1][hPick] = CreateDynamicPickup(1273, 23, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ], 0);
						UpdateDynamic3DTextLabelText(HouseInfo[temp_houseid-1][hLabel], 0xFFFFFFFF, string);
						SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ������� ���");
						ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
					}
					case 3:{
						HouseInfo[temp_houseid-1][hLocked] = 1;
						new query[44-2+11];
						mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`locked`='1'where`id`='%i'",HouseInfo[temp_houseid-1][hID]);
						mysql_query(mysql_connection,query,false);
						SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ���");
					    ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");

					}
					case 4:{
						HouseInfo[temp_houseid-1][hLocked] = 0;
						new query[44-2+11];
						mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`locked`='0'where`id`='%i'",HouseInfo[temp_houseid-1][hID]);
						mysql_query(mysql_connection,query,false);
						SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ���");
					    ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
					}
					case 5:{
						SetPlayerPos(playerid, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ]);
		                SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ��������������� � ����");
					    ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
					}
					case 6:{
		                SetPlayerPos(playerid, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ]);
		                SetPlayerInterior(playerid, HouseInfo[temp_houseid-1][hInterior]);
		                SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ����� � ���");
						ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
					}
					case 7:{
		                SetPlayerPos(playerid, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ]);
						SetPlayerInterior(playerid, 0);
		                SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ����� �� ����");
					    ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
					}
				}
			}
			else{
			    DeletePVar(playerid,"EditHouse_ID");
			}
		}
		case dEditHouseMenuPrice:{
		    new temp_houseid=GetPVarInt(playerid,"EditHouse_ID");
		    if(!temp_houseid){
		        return true;
		    }
			if(response){
			    new temp_value;
				if(sscanf(inputtext,"i",temp_value)){
				    ShowPlayerDialog(playerid, dEditHouseMenuPrice, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} ����", "������� ����� ���� ����", "��", "�����");
				    return true;
				}
				if(temp_value < 1){
				    ShowPlayerDialog(playerid, dEditHouseMenuPrice, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} ����", "������� ����� ���� ����", "��", "�����");
				    return true;
				}
				HouseInfo[temp_houseid-1][hPrice] = temp_value;
	            new query[43-2-2+11+11];
	            mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`price`='%i'where`id`='%i'",HouseInfo[temp_houseid-1][hPrice],HouseInfo[temp_houseid-1][hID]);
	            mysql_query(mysql_connection,query,false);
	            new string[80-2+11];
				format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ����� ���� ����: %d$", HouseInfo[temp_houseid-1][hPrice]);
				SendClientMessage(playerid, -1, string);
				ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
			}
			else{
		    	ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
			}
		}
		case dEditHouseMenuInterior:{
		    new temp_houseid=GetPVarInt(playerid,"EditHouse_ID");
		    if(!temp_houseid){
		        return true;
		    }
			if(response){
			    new temp_value;
			    if(sscanf(inputtext,"i",temp_value)){
			        ShowPlayerDialog(playerid, dEditHouseMenuInterior, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} �������", "������� ����� �������", "��", "�����");
			        return true;
			    }
			    if(temp_value < 1 || temp_value > 4){
			        ShowPlayerDialog(playerid, dEditHouseMenuInterior, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} ������������� {ff0000}�{ffffff} �������", "������� ����� �������", "��", "�����");
			        return true;
			    }
				HouseInfo[temp_houseid-1][hInterior] = temp_value;
				new query[46-2-2+3+11];
	            mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`interior`='%i'where`id`='%i'",HouseInfo[temp_houseid-1][hInterior],HouseInfo[temp_houseid-1][hID]);
	            mysql_query(mysql_connection,query,false);
	            new string[83-2+3];
				format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ����� ������� ����: %d.", HouseInfo[temp_houseid-1][hInterior]);
				SendClientMessage(playerid, -1, string);
				ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
			}
			else{
	            ShowPlayerDialog(playerid, dEditHouseMenu, DIALOG_STYLE_LIST, "{ff0000}�{ffffff} �������������", "{ff0000}�{ffffff} ������������� ����\n{ff0000}�{ffffff} ������������� �������\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ������� ���\n{ff0000}�{ffffff} ����������������� � ����\n{ff0000}�{ffffff} ����� � ���\n{ff0000}�{ffffff} ����� �� ����","��","�����");
			}
		}
	}
	return 0;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success){
    if(!success){
        new string[102-2+16];
        format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �������� ���� ������� \"{FF0000}%s{FFFFFF}\" �� �������", cmdtext);
        SendClientMessage(playerid, -1, string);
    }
    return true;
}

// 		������� �������

CMD:nameoff(playerid){
    for(new i = 0; i < MAX_PLAYERS; i++){
		ShowPlayerNameTagForPlayer(playerid, i, false);
	}
    return true;
}

CMD:nameon(playerid){
    for(new i = 0; i < MAX_PLAYERS; i++){
		ShowPlayerNameTagForPlayer(playerid, i, true);
	}
    return true;
}

CMD:help(playerid){
	SendClientMessage(playerid, -1,"________________________�������__________________________");
	SendClientMessage(playerid, -1,"/s /r /hcmds /nameon /nameoff /admins /drift /aero /city");
	SendClientMessage(playerid, -1,"/pm /togpm ");
	SendClientMessage(playerid, -1,"_________________________________________________________");
	return true;
}

CMD:togpm(playerid){
    PlayerInfo[playerid][pTogPm]=PlayerInfo[playerid][pTogPm]?0:1;
    SendClientMessage(playerid,-1,PlayerInfo[playerid][pTogPm]?"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� �������� ���� ������ ���������":"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ��������� ���� ������ ���������");
	new query[43-2-2+1+11];
	mysql_format(mysql_connection,query,sizeof(query),"update`users`set`togpm`='%i'where`id`='%i'",PlayerInfo[playerid][pTogPm],PlayerInfo[playerid][pID]);
	mysql_query(mysql_connection,query,false);
	return true;
}

CMD:pm(playerid,params[]){
    new temp_playerid,temp_text[128];
    if(sscanf(params, "us[128]",temp_playerid,temp_text)){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: /pm [id] [���������]");
		return true;
	}
    if(!GetPVarInt(temp_playerid,"PlayerLogged")){
		SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
		return true;
	}
    if(temp_playerid == playerid){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ������ ��������� ��������� ������ ����!");
		return true;
	}
    if(!PlayerInfo[temp_playerid][pTogPm]){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ���� ����� �������� ���� ������ ���������");
		return true;
	}
	new string[72-2-2+MAX_PLAYER_NAME+128];
    format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ��������� � ������ %s: %s", PlayerInfo[temp_playerid][pName], temp_text);
    SendClientMessage(playerid, -1, string);
    format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ��������� �� ������ %s: %s", PlayerInfo[playerid][pName], temp_text);
    SendClientMessage(temp_playerid, -1, string);
    return true;
}

CMD:admins(playerid){
	new temp_string[76-2-2-2+MAX_PLAYER_NAME+3+1];
	static string[sizeof(temp_string)*10];
	foreach(new i:Player){
		if(AdminInfo[playerid][aLevel] >= 1){
			format(temp_string,sizeof(temp_string),"{ff0000}�  {ffffff} ���:  {FF0000}%s {FFFFFF}(%i)  |  �������: {FF0000}%d\n",PlayerInfo[i][pName],i,AdminInfo[playerid][aLevel]);
			strcat(string,temp_string);
		}
	}
	if(strlen(string)<1){
		strcat(string,"������������� �����������");
	}
	ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"{ff0000}�{ffffff} ������������� ������:",string,"OK","");
	string="";
	return true;
}

CMD:hcmd(playerid){
	SendClientMessage(playerid, -1,"______________������ �� ����___________________________");
	SendClientMessage(playerid, -1,"/buyhouse /sellhouse /lock /enter /exit /changecomment");
	SendClientMessage(playerid, -1,"_______________________________________________________");
 	return true;
}

CMD:s(playerid){
	new Float:temp_x,Float:temp_y,Float:temp_z,Float:temp_a;
	if(IsPlayerInAnyVehicle(playerid)){
	    GetVehicleZAngle(GetPlayerVehicleID(playerid),temp_a);
        GetVehiclePos(GetPlayerVehicleID(playerid),temp_x,temp_y,temp_z);
	}
    else{
    	GetPlayerPos(playerid,temp_x,temp_y,temp_z);
    	GetPlayerFacingAngle(playerid,temp_a);
 	}
 	SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ������� ���������, ����� ����������������� /r");
 	SetPVarInt(playerid,"SavedPos",1);
 	SetPVarFloat(playerid,"SavedPosX",temp_x);
 	SetPVarFloat(playerid,"SavedPosY",temp_y);
 	SetPVarFloat(playerid,"SavedPosZ",temp_z);
 	SetPVarFloat(playerid,"SavedPosA",temp_a);
 	return true;
}

CMD:r(playerid){
	if(!GetPVarInt(playerid,"SavedPos")){
		SendClientMessage(playerid, -1,"{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ������� �� ���� ���������, ����� ��������� /s");
		return true;
	}
	new Float:temp_x=GetPVarFloat(playerid,"SavedPosX");
	new Float:temp_y=GetPVarFloat(playerid,"SavedPosY");
	new Float:temp_z=GetPVarFloat(playerid,"SavedPosZ");
	new Float:temp_a=GetPVarFloat(playerid,"SavedPosA");
	if(IsPlayerInAnyVehicle(playerid)){
		SetVehiclePos(GetPlayerVehicleID(playerid),temp_x,temp_y,temp_z);
		SetVehicleZAngle(GetPlayerVehicleID(playerid),temp_a);
	}
	else{
		SetPlayerPos(playerid,temp_x,temp_y,temp_z);
		SetPlayerFacingAngle(playerid,temp_a);
	}
	SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���� ��������������� �� ���������� �������");
	SetPlayerInterior(playerid,0);
 	return true;
}

CMD:drift(playerid,params[]){
	new temp_id;
	if(sscanf(params,"i",temp_id)){
	    SendClientMessage(playerid,C_GREY,"CMD: /drift [ 1 - 6 ]");
	    return true;
	}
	if(temp_id < 1 || temp_id > 6){
	    return true;
	}
    OnDialogResponse(playerid,dMenuTeleportsDrift,1,temp_id-1,params);
	return true;
}

CMD:aero(playerid,params[]){
	new temp_id;
	if(sscanf(params,"i",temp_id)){
        SendClientMessage(playerid,C_GREY,"CMD: /aero [ 1 - 4 ]");
	    return true;
	}
	if(temp_id < 1 || temp_id > 4){
	    return true;
	}
    OnDialogResponse(playerid,dMenuTeleportsAirport,1,temp_id-1,params);
	return true;
}

CMD:city(playerid,params[]){
    new temp_id;
	if(sscanf(params,"i",temp_id)){
        SendClientMessage(playerid,C_GREY,"CMD: /city [ 1 - 11 ]");
	    return true;
	}
	if(temp_id < 1 || temp_id > 11){
	    return true;
	}
    OnDialogResponse(playerid,dMenuTeleportsCity,1,temp_id-1,params);
	return true;
}

//      ������� �����

CMD:hlock(playerid){
	if(!GetPVarInt(playerid,"HouseOwner")){
	    SendClientMessage(playerid,C_RED,"������: � ��� ��� ����!");
	    return true;
	}
	new temp_houseid=GetPVarInt(playerid,"HouseOwner");
	if(!IsPlayerInRangeOfPoint(playerid,5.0,HouseInfo[temp_houseid-1][hEnterX],HouseInfo[temp_houseid-1][hEnterY],HouseInfo[temp_houseid-1][hEnterZ])){
	    SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ������ �� ����");
	    return true;
	}
	HouseInfo[temp_houseid-1][hLocked]=HouseInfo[temp_houseid-1][hLocked]?0:1;
	GameTextForPlayer(playerid, HouseInfo[temp_houseid-1][hLocked]?"~r~Lock":"~g~Unlock", 5000, 3);
	new query[45-2-2+1+11];
	mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`locked`='%i'where`id`='%i'",HouseInfo[temp_houseid-1][hLocked],HouseInfo[temp_houseid-1][hID]);
	mysql_query(mysql_connection,query,false);
	return true;
}

CMD:enter(playerid){
	for(new i = 0; i < total_houses; i++){
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ])){
			continue;
		}
		if(HouseInfo[i][hLocked]){
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ���� ��� ������");
			return true;
		}
		SetPlayerPos(playerid,HouseInfo[i][hExitX],HouseInfo[i][hExitY],HouseInfo[i][hExitZ]);
		SetPlayerFacingAngle(playerid,HouseInfo[i][hExitA]);
		SetPlayerInterior(playerid, HouseInfo[i][hInterior]);
	}
	return true;
}

CMD:exit(playerid){
	for(new i = 0; i < total_houses; i++){
	    if(!IsPlayerInRangeOfPoint(playerid,5.0,HouseInfo[i][hExitX],HouseInfo[i][hExitY],HouseInfo[i][hExitZ])){
			continue;
		}
		SetPlayerPos(playerid, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
		SetPlayerInterior(playerid, 0);
	}
	return true;
}

CMD:sellhouse(playerid){
    if(!GetPVarInt(playerid,"HouseOwner")){
		SendClientMessage(playerid,C_RED,"������: � ��� ��� ����!");
		return true;
	}
	new temp_houseid=GetPVarInt(playerid,"HouseOwner");
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ])){
	    SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ������ �� ����");
	    return true;
	}
	PlayerInfo[playerid][pCash]+=HouseInfo[temp_houseid-1][hPrice];
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid,PlayerInfo[playerid][pCash]);
	new string[69-2-2+11+11];
	format(string, sizeof(string), "{15FF00}���:{FFFFFF} %d\n{FF0000}��������\n{15FF00}����:{FFFFFF} %d", HouseInfo[temp_houseid-1][hID], HouseInfo[temp_houseid-1][hPrice]);
	DestroyDynamicPickup(HouseInfo[temp_houseid-1][hPick]);
	HouseInfo[temp_houseid-1][hPick] = CreateDynamicPickup(1273, 23, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ]);
	UpdateDynamic3DTextLabelText(HouseInfo[temp_houseid-1][hLabel], 0xFFFFFFFF, string);
	SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ������� ���� ���");
	DeletePVar(playerid,"HouseOwner");
	new query[66-2+11];
	mysql_format(mysql_connection,query,sizeof(query),"update`users`set`cash`='%i'where`id`='%i'",PlayerInfo[playerid][pCash],PlayerInfo[playerid][pID]);
	mysql_query(mysql_connection,query,false);
	mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`comment`=default,`owner`=default where`id`='%i'",HouseInfo[temp_houseid-1][hID]);
	mysql_query(mysql_connection,query,false);
	strmid(HouseInfo[temp_houseid-1][hOwner],"-",0,strlen("-"),MAX_PLAYER_NAME);
	strmid(HouseInfo[temp_houseid-1][hComment],"/changecomment",0,strlen("/changecomment"),64);
	return true;
}

CMD:buyhouse(playerid){
    if(GetPVarInt(playerid,"HouseOwner")){
		SendClientMessage(playerid,C_RED,"������: � ��� ��� ���� ���!");
		return true;
	}
	for(new i = 0; i < total_houses; i++){
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ])){
		    continue;
		}
		if(strcmp(HouseInfo[i][hOwner],"-")){
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ���� ��� ��� ������");
			return true;
		}
		if(PlayerInfo[playerid][pCash] < HouseInfo[i][hPrice]){
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: � ��� ������������ �����");
			return true;
		}
		PlayerInfo[playerid][pCash]-=HouseInfo[i][hPrice];
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid,PlayerInfo[playerid][pCash]);
		DestroyDynamicPickup(HouseInfo[i][hPick]);
		HouseInfo[i][hPick] = CreateDynamicPickup(1272, 1, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
		new string[87-2-2-2+11+MAX_PLAYER_NAME+64];
		format(string, sizeof(string), "{15FF00}���:{FFFFFF} %d\n{15FF00}��������:{FFFFFF} %s\n{15FF00}�����������:{FFFFFF} %s", HouseInfo[i][hID],PlayerInfo[playerid][pName], HouseInfo[i][hComment]);
		UpdateDynamic3DTextLabelText(HouseInfo[i][hLabel], 0xFFFFFFFF, string);
		format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ������ ��� �� %d$", HouseInfo[i][hPrice]);
		SendClientMessage(playerid, -1, string);
		SetPVarInt(playerid,"HouseOwner",HouseInfo[i][hID]);
		strmid(HouseInfo[i][hOwner],PlayerInfo[playerid][pName],0,strlen(PlayerInfo[playerid][pName]),MAX_PLAYER_NAME);
		new query[44-2-2+MAX_PLAYER_NAME+11];
		mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`owner`='%e'where`id`='%i'",HouseInfo[i][hOwner],HouseInfo[i][hID]);
		mysql_query(mysql_connection,query,false);
		mysql_format(mysql_connection,query,sizeof(query),"update`users`set`cash`='%i'where`id`='%i'",PlayerInfo[playerid][pCash],PlayerInfo[playerid][pID]);
		mysql_query(mysql_connection,query,false);
	}
	return true;
}

CMD:changecomment(playerid,params[]){
    if(!GetPVarInt(playerid,"HouseOwner")){
		SendClientMessage(playerid,C_RED,"������: � ��� ��� ����!");
		return true;
	}
	new temp_houseid=GetPVarInt(playerid,"HouseOwner");
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[temp_houseid-1][hEnterX], HouseInfo[temp_houseid-1][hEnterY], HouseInfo[temp_houseid-1][hEnterZ])){
	    SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ������ �� ����");
	    return true;
	}
	new temp_text[64];
	if(sscanf(params,"s[128]",temp_text)){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: /changecomment [�����]");
		return true;
	}
	if(strlen(temp_text) < 1 || strlen(temp_text) > 64){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: ����������� ����� ���� �� ������ 1 � �� ������ 50 ��������");
		return true;
	}
	new string[87-2-2-2+11+MAX_PLAYER_NAME+64];
	format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� �������� ����������� � ���� �� %s", temp_text);
	SendClientMessage(playerid, -1, string);
	strmid(HouseInfo[temp_houseid-1][hComment],temp_text,0,strlen(temp_text),64);
	format(string, sizeof(string), "{15FF00}���:{FFFFFF} %d\n{15FF00}��������:{FFFFFF} %s\n{15FF00}�����������:{FFFFFF} %s", HouseInfo[temp_houseid-1][hID], HouseInfo[temp_houseid-1][hOwner], HouseInfo[temp_houseid-1][hComment]);
	UpdateDynamic3DTextLabelText(HouseInfo[temp_houseid-1][hLabel], 0xFFFFFFFF, string);
	new query[46-2-2+64+11];
	mysql_format(mysql_connection,query,sizeof(query),"update`houses`set`comment`='%e'where`id`='%i'",HouseInfo[temp_houseid-1][hComment],HouseInfo[temp_houseid-1][hID]);
	mysql_query(mysql_connection,query,false);
	return true;
}

//      ������� ��� �������

// 1-� �������

CMD:ahelp(playerid){
	if(!AdminInfo[playerid][aLevel]){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	SendClientMessage(playerid, -1,"__________________________________________________________________");
	if(AdminInfo[playerid][aLevel] >= 1){
	    SendClientMessage(playerid, -1,"1 �������: /a");
	}
	if(AdminInfo[playerid][aLevel] >= 2){
	    SendClientMessage(playerid, -1,"2 �������: /cc /gethere /goto /asay");
	}
	if(AdminInfo[playerid][aLevel] >= 3){
	    SendClientMessage(playerid, -1,"3 �������: /veh /getip");
	}
	if(AdminInfo[playerid][aLevel] >= 4){
	    SendClientMessage(playerid, -1,"4 �������: /kick");
	}
 	if(AdminInfo[playerid][aLevel] >= 5){
	    SendClientMessage(playerid, -1,"5 �������: ");
	}
	if(AdminInfo[playerid][aLevel] >= 6){
	    SendClientMessage(playerid, -1,"6 �������: ");
	}
	if(AdminInfo[playerid][aLevel] >= 7){
	    SendClientMessage(playerid, -1,"7 �������: /makeadmin /outadmin /createhouse /edithouse /setadminname");
	}
	SendClientMessage(playerid, -1,"__________________________________________________________________");
	return true;
}

CMD:a(playerid,params[]){
	if(AdminInfo[playerid][aLevel] < 1){
	    SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
	    return true;
	}
	new temp_text[128];
	if(sscanf(params,"s[128]",temp_text)){
	    SendClientMessage(playerid,C_GREY,"/a [ text ] - ��� ���������������");
	    return true;
	}
	new string[19-2-2-2+32+11+128];
	format(string,sizeof(string),"[A]: %s[aid%i]: %s",AdminInfo[playerid][aRankName],AdminInfo[playerid][aID],temp_text);
	foreach(new i:Player){
	    if(AdminInfo[i][aLevel] < 1){
	        continue;
	    }
	    SendClientMessage(i,C_LGREY,string);
	}
	return true;
}

// 2-� �������

CMD:goto(playerid,params[]){
    if(AdminInfo[playerid][aLevel] < 2){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_playerid;
	if(sscanf(params,"u",temp_playerid)){
        SendClientMessage(playerid,C_GREY,"/goto [ playerid ] - ����������������� � ������");
	    return true;
	}
	if(!GetPVarInt(temp_playerid,"PlayerLogged")){
        SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
	    return true;
	}
	if(temp_playerid == playerid){
	    SendClientMessage(playerid,C_RED,"");
	    return true;
	}
	new Float:temp_x,Float:temp_y,Float:temp_z;
	GetPlayerPos(temp_playerid,temp_x,temp_y,temp_z);
	SetPlayerPos(playerid,temp_x+2.5,temp_y,temp_z+0.5);
	new string[33-2+MAX_PLAYER_NAME];
	format(string,sizeof(string),"�� ����������������� � ������ %s",PlayerInfo[temp_playerid][pName]);
	SendClientMessage(playerid,-1,string);
	return true;
}

CMD:gethere(playerid,params[]){
    if(AdminInfo[playerid][aLevel] < 2){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_playerid;
	if(sscanf(params,"u",temp_playerid)){
        SendClientMessage(playerid,C_GREY,"/gethere [ playerid ] - ��������������� ������ � ����");
	    return true;
	}
	if(!GetPVarInt(temp_playerid,"PlayerLogged")){
        SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
	    return true;
	}
	if(temp_playerid == playerid){
	    SendClientMessage(playerid,C_RED,"");
	    return true;
	}
	new Float:temp_x,Float:temp_y,Float:temp_z;
	GetPlayerPos(playerid,temp_x,temp_y,temp_z);
	SetPlayerPos(temp_playerid,temp_x+2.5,temp_y,temp_z+0.5);
	new string[36-2+MAX_PLAYER_NAME];
	format(string,sizeof(string),"�� ��������������� � ���� ������ %s",PlayerInfo[temp_playerid][pName]);
	SendClientMessage(playerid,-1,string);
	SendClientMessage(temp_playerid,-1,"�� ���� ��������������� ��������������� �������!");
	return true;
}

CMD:asay(playerid,params[]){
	if(AdminInfo[playerid][aLevel] < 2){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_text[128];
    if(sscanf(params,"s[128]",temp_text)){
		SendClientMessage(playerid,C_GREY,"CMD: /asay [ text ] - ��������� ��������� �� ����� ��������������");
		return true;
	}
	new string[14-2-2-2+32+11+128];
    format(string,sizeof(string),"%s[aid%i]: %s",AdminInfo[playerid][aRankName],AdminInfo[playerid][aID],temp_text);
    SendClientMessageToAll(C_LGREY,string);
	return true;
}

CMD:cc(playerid){
	if(AdminInfo[playerid][aLevel]<2){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	for(new i=0; i<50; i++){
		SendClientMessageToAll(-1,"");
	}
    return true;
}

// 3-� �������

CMD:veh(playerid,params[]){
	if(AdminInfo[playerid][aLevel]<3){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_vehicleid,temp_color1,temp_color2;
	if(sscanf(params,"iii",temp_vehicleid,temp_color1,temp_color2)){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: /veh [�� ������] [���� 1] [���� 2]");
		return true;
	}
	if(temp_vehicleid < 400 || temp_vehicleid > 611){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �������� ����� ���� �� 400 �� 611");
		return true;
	}
	new temp_carid;
	new Float:temp_x,Float:temp_y,Float:temp_z;
	GetPlayerPos(playerid,temp_x,temp_y,temp_z);
	temp_carid=CreateVehicle(temp_vehicleid,temp_x+3.0,temp_y,temp_z,0.0,temp_color1,temp_color2,-1);
	SetVehicleNumberPlate(temp_carid, "Skill-Drift");
	LinkVehicleToInterior(temp_carid,GetPlayerInterior(playerid));
	new string[85-2-2-2-2+24+3+3+3];
	format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� %s (ID: %d) �����: %d, %d", VehicleNames[temp_vehicleid-400], temp_vehicleid, temp_color1, temp_color2);
	SendClientMessage(playerid,-1, string);
    return true;
}

CMD:getip(playerid,params[]){
    if(AdminInfo[playerid][aLevel]<3){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_playerid;
	if(sscanf(params,"u",temp_playerid)){
	    SendClientMessage(playerid,-1,"/getip [ playerid ] - ������ IP ����� ������");
		return true;
	}
    if(!GetPVarInt(temp_playerid,"PlayerLogged")){
        SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
	    return true;
	}
	new temp_ip[16];
	GetPlayerIp(playerid,temp_ip,sizeof(temp_ip));
	new string[64-2-2-2+MAX_PLAYER_NAME+3+16];
	format(string,sizeof(string),"[ GETIP ]: PLAYER NAME - %s ; PLAYER ID - %i ; PLAYER IP - %s ;",PlayerInfo[temp_playerid][pName],temp_playerid,temp_ip);
	SendClientMessage(playerid,-1,string);
	return true;
}

// 4-� �������

CMD:kick(playerid,params[]){
    if(AdminInfo[playerid][aLevel]<4){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_playerid,temp_reason[32];
	if(sscanf(params,"us[128]",temp_playerid,temp_reason)){
	    SendClientMessage(playerid,-1,"/kick [ playerid ] [ reason ] - ������� ������");
		return true;
	}
    if(!GetPVarInt(temp_playerid,"PlayerLogged")){
	    SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
	    return true;
	}
	new string[53-2-2-2+MAX_PLAYER_NAME+MAX_PLAYER_NAME+32];
	format(string,sizeof(string),"�� ������� ������ %s",PlayerInfo[temp_playerid][pName]);
	SendClientMessage(playerid,-1,string);
	format(string,sizeof(string),"�� ���� ������� ��������������� %s. �������: %s",PlayerInfo[playerid][pName],temp_reason);
	SendClientMessage(temp_playerid,-1,string);
	format(string,sizeof(string),"[ A ]: %s ��� ������ ��������������� %s. �������: %s",PlayerInfo[temp_playerid][pName],PlayerInfo[playerid][pName],temp_reason);
	SendClientMessageToAll(-1,string);
	SetTimerEx("@__kick_player",250,false,"i",temp_playerid);
	return true;
}

// 5-� �������

// 6-� �������

// 7-� �������

CMD:edithouse(playerid){
	if(AdminInfo[playerid][aLevel]<7){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	ShowPlayerDialog(playerid, dEditHouse, DIALOG_STYLE_INPUT, "{ff0000}�{ffffff} �������������", "������� ����� ���� ��� ������� ������ ������ ������", "��", "������");
	return true;
}

CMD:createhouse(playerid,params[]){
	if(AdminInfo[playerid][aLevel] < 7){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_price,temp_interior;
	if(sscanf(params, "ii", temp_price, temp_interior)){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: /createhouse [����] [�������]");
		return true;
	}
	if(temp_price < 1){
		SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �������� ���� �� ����� ���� ������ $1");
		return true;
	}
	switch(temp_interior){
		case 1:{
			HouseInfo[total_houses][hExitX]=2237.590087;
			HouseInfo[total_houses][hExitY]=-1078.869995;
			HouseInfo[total_houses][hExitZ]=1049.023437;
			HouseInfo[total_houses][hExitA]=0.0;
			HouseInfo[total_houses][hInterior]=2;
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ��� 1-��� ������");
		}
		case 2:{
		    HouseInfo[total_houses][hExitX]=2216.540039;
			HouseInfo[total_houses][hExitY]=-1076.290039;
			HouseInfo[total_houses][hExitZ]=1050.484375;
			HouseInfo[total_houses][hExitA]=0.0;
			HouseInfo[total_houses][hInterior]=1;
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ��� 2-��� ������");
		}
		case 3:{
	        HouseInfo[total_houses][hExitX]=2282.909912;
			HouseInfo[total_houses][hExitY]=-1137.971191;
			HouseInfo[total_houses][hExitZ]=1050.898437;
			HouseInfo[total_houses][hExitA]=0.0;
			HouseInfo[total_houses][hInterior]=11;
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ��� 3-��� ������");
		}
		case 4:{
	        HouseInfo[total_houses][hExitX]=2365.300048;
			HouseInfo[total_houses][hExitY]=-1132.920043;
			HouseInfo[total_houses][hExitZ]=1050.875000;
			HouseInfo[total_houses][hExitA]=0.0;
			HouseInfo[total_houses][hInterior] = 8;
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ��� 4-��� ������");
		}
		case 5:{
	        HouseInfo[total_houses][hExitX]=1299.079956;
			HouseInfo[total_houses][hExitY]=-795.226989;
			HouseInfo[total_houses][hExitZ]=1084.007812;
			HouseInfo[total_houses][hExitA]=0.0;
			HouseInfo[total_houses][hInterior] = 5;
			SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ���������� ��� 5-��� ������");
		}
		default:{
		    SendClientMessage(playerid, -1, "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �������� ������� ����� ���� �� 1 �� 5");
		    return true;
		}
	}
	new string[69-2-2+11+11];
	format(string, sizeof(string), "{ff0000}Skill{ffffff}-{ff0000}Drift{ffffff}: �� ������� ��� ��� ������� %d", total_houses);
	SendClientMessage(playerid, -1, string);
	GetPlayerPos(playerid,HouseInfo[total_houses][hEnterX],HouseInfo[total_houses][hEnterZ],HouseInfo[total_houses][hEnterY]);
	HouseInfo[total_houses][hPrice] = temp_price;
	HouseInfo[total_houses][hPick] = CreateDynamicPickup(1273,23,HouseInfo[total_houses][hEnterX],HouseInfo[total_houses][hEnterZ],HouseInfo[total_houses][hEnterY]);
	new query[108-2-2-2-2-2-2-2-2-2-2+11+3+1+11+11+11+11+11+11+11];
	mysql_format(mysql_connection,query,sizeof(query),"insert into`houses`(`price`,`interior`,`enterpos`,`exitpos`)values('%i','%i','%f|%f|%f|%f','%f|%f|%f|%f')",temp_price,HouseInfo[total_houses][hInterior],HouseInfo[total_houses][hEnterX],HouseInfo[total_houses][hEnterZ],HouseInfo[total_houses][hEnterA],HouseInfo[total_houses][hEnterY],HouseInfo[total_houses][hExitX],HouseInfo[total_houses][hExitY],HouseInfo[total_houses][hExitZ],HouseInfo[total_houses][hExitA]);
	new Cache:cache_houses=mysql_query(mysql_connection,query);
	HouseInfo[total_houses][hID]=cache_insert_id(mysql_connection);
	cache_delete(cache_houses,mysql_connection);
	format(string, sizeof(string), "{15FF00}���:{FFFFFF} %d\n{FF0000}��������\n{15FF00}����:{FFFFFF} %d", HouseInfo[total_houses][hID], temp_price);
	HouseInfo[total_houses][hLabel] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, HouseInfo[total_houses][hEnterX],HouseInfo[total_houses][hEnterZ],HouseInfo[total_houses][hEnterY], 30.0);
	total_houses++;
	return true;
}

CMD:makeadmin(playerid,params[]){
    if(AdminInfo[playerid][aLevel] < 7){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_playerid;
	if(sscanf(params,"u",temp_playerid)){
		SendClientMessage(playerid, -1, "/makeadmin [ playerid ] - ��������� ������ ���������������");
		return true;
	}
	if(!GetPVarInt(temp_playerid,"PlayerLogged")){
	    SendClientMessage(playerid,C_RED,"������: ���� ����� �� � ����!");
	    return true;
	}
	new query[52-2+MAX_PLAYER_NAME];
	mysql_format(mysql_connection,query,sizeof(query),"insert into`admins`(`name`,`level`)values('%e','1')",PlayerInfo[temp_playerid][pName]);
	new Cache:cache_admins=mysql_query(mysql_connection,query);
	AdminInfo[temp_playerid][aID]=cache_insert_id(mysql_connection);
	cache_delete(cache_admins,mysql_connection);
	AdminInfo[temp_playerid][aLevel]=1;
	strmid(AdminInfo[temp_playerid][aRankName],"New Admin",0,strlen("New Admin"),32);
	new string[69-2-2+MAX_PLAYER_NAME+11];
	format(string,sizeof(string),"�� ��������� ������ %s ��������������� �������. ��� ������������� %i",PlayerInfo[temp_playerid][pName],AdminInfo[temp_playerid][aID]);
	SendClientMessage(playerid,-1,string);
	format(string,sizeof(string),"%s �������� ��� ��������������� �������. ��� ������������� %i",PlayerInfo[playerid][pName],AdminInfo[temp_playerid][aID]);
	SendClientMessage(temp_playerid,-1,string);
	return true;
}

CMD:outadmin(playerid,params[]){
    if(AdminInfo[playerid][aLevel]<7){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_name[MAX_PLAYER_NAME];
	if(sscanf(params,"s[128]",temp_name)){
		SendClientMessage(playerid,C_GREY,"CMD: /makeadmin [ name/playerid ] - ���� ������ � ����� ��������������");
		return true;
	}
	new query[43-2+MAX_PLAYER_NAME];
	mysql_format(mysql_connection,query,sizeof(query),"delete from`admins`where`name`='%e'limit 1",temp_name);
	new Cache:cache_admins=mysql_query(mysql_connection,query);
	if(cache_affected_rows(mysql_connection)){
	    new temp_playerid;
		sscanf(temp_name,"u",temp_playerid);
		if(GetPVarInt(temp_playerid,"PlayerLogged")){
		    SendClientMessage(temp_playerid,-1,"�� ���� ����� � ����� �������������� �������!");
		    SetTimerEx("@__kick_player",250,false,"i",temp_playerid);
		}
		new string[51-2+MAX_PLAYER_NAME];
  		format(string,sizeof(string),"�� ����� ������ %s � ����� �������������� �������!",temp_name);
  		SendClientMessage(playerid,-1,string);
	}
	else{
	    SendClientMessage(playerid,C_RED,"������: ������ ������� �� ������ � ���� ������ ���������������!");
	}
	cache_delete(cache_admins,mysql_connection);
	return true;
}

CMD:setadminname(playerid,params[]){
    if(AdminInfo[playerid][aLevel]<7){
		SendClientMessage(playerid,C_RED,"������: �� �� ������ ������������ ��� �������!");
		return true;
	}
	new temp_name[MAX_PLAYER_NAME],temp_rank[32];
	if(sscanf(params,"s[128]s[128]",temp_name,temp_rank)){
	    SendClientMessage(playerid,C_GREY,"CMD: /setadminname [ playerid/name ] [ name ] - ���������� �������������� �������������� ��������");
	    return true;
	}
	new temp_playerid;
	sscanf(temp_name,"u",temp_playerid);
    if(GetPVarInt(temp_playerid,"PlayerLogged")){
        if(!AdminInfo[temp_playerid][aID]){
		    SendClientMessage(playerid,C_RED,"������: ���� ����� �� �������� ���������������!");
		    return true;
		}
	    if(!regex_match(temp_rank,"[a-zA-Z�-��-�0-9\\s]{4,32}+")){
			SendClientMessage(playerid,C_RED,"������: ���������� ���������: [Aa-Zz, ��-��, ' ', 0-9], ����� �� 4 �� 32 ��������!");
			return true;
		}
		strmid(AdminInfo[temp_playerid][aRankName],temp_rank,0,strlen(temp_rank),32);
		new query[47-2-2+32+11];
		mysql_format(mysql_connection,query,sizeof(query),"update`admins`set`rankname`='%e'where`id`='%i'",temp_rank,AdminInfo[temp_playerid][aID]);
		mysql_query(mysql_connection,query,false);
		new string[46-2-2+MAX_PLAYER_NAME+32];
		format(string,sizeof(string),"�� ���������� �������������� %s �������� '%s'",PlayerInfo[temp_playerid][pName],temp_rank);
		SendClientMessage(playerid,C_GREY,string);
		format(string,sizeof(string),"������������� %s ��������� ��� �������� '%s'",PlayerInfo[playerid][pName],temp_rank);
		SendClientMessage(temp_playerid,C_GREY,string);
	}
	else{
		new query[46-2+MAX_PLAYER_NAME];
		mysql_format(mysql_connection,query,sizeof(query),"update`admins`set`rankname`='%e'where`name`='%e'limit 1",temp_rank,temp_name);
		new Cache:cache_admins=mysql_query(mysql_connection,query);
		if(cache_affected_rows(mysql_connection)){
            new string[46-2-2+MAX_PLAYER_NAME+32];
			format(string,sizeof(string),"�� ���������� �������������� %s �������� '%s'",temp_name,temp_rank);
			SendClientMessage(playerid,C_GREY,string);
		}
		else{
            SendClientMessage(playerid,C_RED,"������: ���� ����� �� �������� ���������������!");
		}
		cache_delete(cache_admins,mysql_connection);
	}
	return true;
}