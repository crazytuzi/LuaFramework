----------------------------------------------------------------
local require = require

require("i3k_global");
require("i3k_math");


----------------------------------------------------------------
i3k_net_params = i3k_class("i3k_net_params");
function i3k_net_params:ctor(lst)
	self._lst = lst;
	self._pos = 1;
	self._cnt = #lst;
end
 
function i3k_net_params:pop()
	if self._pos > self._cnt then
		return nil;
	end

	local v = self._lst[self._pos];

	self._pos = self._pos + 1;

	return v;
end

function i3k_net_params:pop_str()
	return self:pop();
end

function i3k_net_params:pop_int()
	local v = self:pop();
	if v then
		v = i3k_integer(tonumber(v));
	end

	return v;
end

function i3k_net_params:pop_float()
	local v = self:pop();
	if v then
		v = tonumber(v);
	end

	return v;
end

function i3k_net_params:pop_equip()
	local equip = {}
	
	local equip_id = self:pop_int()
	if equip_id ~= 0 then
		local equip_guid = self:pop_str()
		local _count = self:pop_int()
		local attribute = {}
		for j=1,_count do
			attribute[j] = self:pop_int()
		end
		
		local naijiu = self:pop_int()
		equip.equip_id = equip_id
		equip.equip_guid = equip_guid
		equip.attribute = attribute
		equip.slot = slot
		equip.naijiu = naijiu
	
	end
	if equip.equip_id then
		return equip
	else
		return nil
	end
end

----------------------------------------------------------------
-- login 登录返回值错误码
eUSERLOGIN_OK							= 0;
eUSERROLELOGIN_OK						= 1;
eUSERLOGIN_NOT_INSERVICE				= -1;
eUSERLOGIN_ID_INVALID					= -2;
eUSERLOGIN_VERIFY_FAILED				= -3;
eUSERLOGIN_ALREADY_LOGIN				= -4;
eUSERLOGIN_LOGIN_KEY_EXPIRED			= -5;
eUSERLOGIN_LOAD_USER_FAILED				= -6;
eUSERLOGIN_LOCK_BUSY					= -7;
eUSERLOGIN_ROLE_BANNED					= -8;
eUSERLOGIN_LOAD_ROLE_FAILED				= -9;
eUSERLOGIN_CLASSTYPE_INVALID			= -10;
eUSERLOGIN_ROLENAME_INVALID				= -11;
eUSERLOGIN_RECONNECT_CREATE_INVALID		= -12;
eUSERLOGIN_CREATE_ROLE_NAME_USED		= -13;
eUSERLOGIN_CREATE_ROLE_FAILED			= -14;
eUSERLOGIN_USER_NAME_EMPTY				= -15;
eUSERLOGIN_ZONE_ID_INVALID				= -16;
eUSERLOGIN_GAME_CHANNEL_INVALID			= -17;
eUSERLOGIN_NEED_VERIFY_REGISTER 		= -18;
eUSERLOGIN_VERIFY_REGISTER_FAILED		= -19;
eUSERLOGIN_ONLINE_ROLE_FULL				= -20;
eUSERLOGIN_QUEUE_ROLE_FULL				= -21;
eUSERLOGIN_DENY_CREATE_USER				= -22;	
eUSERLOGIN_DENY_CREATE_ROLE				= -23;

-- 激活码 key code
eUSERLOGIN_ACTIVE_KEY_INVALID 				= -1;
eUSERLOGIN_ACTIVE_KEY_BATCHID_INVALID		= -2;
eUSERLOGIN_ACTIVE_KEY_DB_ERROR 				= -100;
eUSERLOGIN_ACTIVE_KEY_DB_NOT_CONTAIN_KEY 	= -1001;
eUSERLOGIN_ACTIVE_KEY_DB_KEY_UESD 			= -1002;


eUSERLOGIN_USER_KEY_TOKEN_EXPIRED			= -2



----------------------------------------------------------------
-- role
eROLE_BASE		= "base";
eROLE_BRIEF		= "brief";
eROLE_MONEY		= "money";
eROLE_BAG		= "bag";
eROLE_CHG_MAP	= "changemap";
eROLE_ENTER		= "enter";
eROLE_EXIT		= "exit";
eROLE_EQUIPS	= "equips";
eROLE_ENERGY	= "energy";
eROLE_SKILLS	= "skills";
eROLE_BUFFS		= "buffs";
eROLE_SPIRIT	= "spirit";
eROLE_MAINTASK		= "maintask";
eROLE_WEAPONTASK		= "weapontask";
eROLE_PETTASK		= "pettask";
eROLE_HPPOOL	= "hppool";
eROLE_WEAPON	= "weapon";
eROLE_EQUIP 	= "equip"
eROLE_EQUIPADD  = "add"
eROLE_ITEM		= "item"
eROLE_ITEMADD	= "add"
eROLE_EXP		= "exp"
eROLE_EXPADD	= "add"
eROLE_REVIVE_STAY	= "reviveinstiu"
eROLE_REVIVE_OTHER	= "reviveother"
eROLE_PET		= "pet"
eROLE_LOGINDAYS = "logindays"
eROLE_MAPLOG	= "maplog"
eROLE_MAPLOGADD = "add"
eROLE_TRANSFROM = "transfrom"
eROLE_Mroom = "mroom"






----------------------------------------------------------------
-- map
eMAP_MOVE_CMD			= "move";
eMAP_STOP_MOVE_CMD		= "stopmove";
eMAP_ADJUST_POS_CMD		= "adjustpos";
eMAP_ROLE_MOVE_NEARBY_CMD	= "nearby";
eMAP_ROLE_USESKILL_CMD		= "useskill"
eMAP_ROLE_USESKILL_END_CMD	= "endskill"
eMAP_ROLE_PROCESSDAMAGE_CMD	= "processdamage"
eMAP_ROLE_PRIVATE_ADDHP_CMD		= "addprivatemaphp"
eMAP_ROLE_SYNCHP_CMD		= "synchp"
eMAP_ROLE_SYNC_HPPOOL_CMD	= "synchppool"
eMAP_WELCOME_ROLE_ENTER_CMD	= "welcome"
eMAP_UPDATE_EQUIP_BRIEF_CMD	= "updateequipbrief"
eMAP_REMOVE_EQUIP_CMD		= "removeequip"
eMAP_USESKILL_RUSH_BEGIN_CMD	= "rushstart"
eMAP_USESKILL_RUSH_END_CMD	= "rushend"
eMAP_DEAD_CMD			= "dead"
eMAP_PRIVATEMAP_KILL_CMD	= "privatemapkill"
eMAP_PRIVATEMAP_SPAWN_CMD	= "privatemapspawn"
eMAP_PICKUP_DROP		= "pickupdrop"
eMAP_SYNC_DROP			= "syncdrop"
eMAP_DELETE_DROP		= "deldrop"
eMAP_SYNC_PRIVATE_DROP		= "syncalldrops"
eMAP_SYNC_PRIVATE_PROGRESS	= "syncprogress"
eMAP_PRIVATE_TRAP		= "privatemaptrap"
eMAP_PRIVATE_FINISH		= "privatemapfinish"
eMAP_PRIVATE_UPDATE_HP		= "privatemapupdatehp"
eMAP_SYNC_DURABILITY		= "syncdurability"
eMAP_MOTIVATE_WEAPON_CMD	= "motivateweapon"
eMAP_MOTIVATE_WEAPON_END_CMD	= "motivateend"
eMAP_MINERAL_START_CMD		= "mineralstart"
eMAP_MINERAL_QUIT_CMD		= "mineralquit"
eMAP_MINERAL_BREAK_CMD		= "mineralbreak"
eMAP_MINERAL_END_CMD		= "mineralend"
eMAP_SUCKBLOOD_CMD		= "suckblood"
eMAP_SYNC_SP			= "syncsp"
eMAP_REVIVE_CMD			= "entityrevive"
eMAP_DUNGEION_RESULT_CMD	= "dungeonresult"
eMAP_ADD_BUFF_CMD		= "addbuff"
eMAP_REMOVE_BUFF_CMD		= "removebuff"
eMAP_DISPEL_BUFF_CMD		= "dispelbuff"
eMAP_ROLE_LVLUP_CMD		= "lvlup"
eMAP_ROLE_UPDATE_MAXHP_CMD	= "updatemaxhp"
eMAP_ROLE_UPDATE_TEAM_CMD	= "updateteam"
eMAP_TRAP_CHANGE_STATE_CMD	= "trapchangestate"
eMAP_TRAP_CLICK_CMD		= "trapclick"



----------------------------------------------------------------
-- mapcopy
eCMapCmd_FINISH_CMD	= "finish"
eCMapCmd_ENTER_CMD	= "enter"
eCMapCmd_LEAVE_CMD	= "leave"

---------------------------------------------------------------
--private map
ePMapCmd_ENTER = "enter";
ePMapCmd_LEAVE = "leave";

-----------------------------------------------------------------
--query
eQUERY_ENTITY_CMD		="queryentity"
eQUERY_PLAYER_CMD		="role"
eQUERY_PLAYER_BRIEF_CMD		="queryotherrole"
eQUERY_TRAP_CMD			= "querytrap"
----------------------------------------------------------------
-- equip
eEquip_Wear			= "upwear"
eEquip_Out			= "downwear"
eEquip_Replace		= "replace"	
eEquip_AutoIncrease	= "increase"
eEquip_AutoUpStar		= "upstar"
eEquip_Repair		= "repair"
eEquip_AutoWear		= "autoupwear"

----------------------------------------------------------------
-- force close
eFCLOSE_DIS_CONNECT	= 1;
eFCLOSE_USER_LOGIN	= 2;
eFCLOSE_UPDATE_INS	= 3;
eFCLOSE_UPDATE_HOT	= 4;

---------------------------------------------------------------
--bag
eBagCmd_SaleItem = "sellitem";
eBagCmd_SaleStone = "sellstone";
eBagCmd_SaleEquip = "sellequip"
eBagCmd_BatchSale = "batchsell"
eBagCmd_openItem = "opengiftbag"
eBagCmd_Expand = "bagexpand"
eBagCmd_UseCoidBag = "usecoidbag"
eBagCmd_UseDiamondBag = "usediamondbag"
eBagCmd_UseExpItem = "useexpitem"
eBagCmd_UseDrug = "eathp"
eBagCmd_UseVipDrug = "vipeathp"

---------------------------------------------------------------
--email
eEmailCmd_Sync_Sys		= "syncsys"
eEmailCmd_Sync_Temp		= "synctemp"
eEmailCmd_Read			= "read"
eEmailCmd_Take			= "take"
eEmailCmd_TakeAllSys	= "takeallsys"
eEmailCmd_TakeAllTemp	= "takealltemp"
--eEmailCmd_Delete		= "del"
------------------------------------------------------------
--skill 
eSkillCmd_UpLvl = "uplvl"
eSkillCmd_Bourn = "bourn"
eSkillCmd_Select = "select"
eSkillCmd_Unlock = "unblock"

-------------------------------------------------------------
--xinfa
eSKILLCmd_XinFa = "learn"
eSKILLCmd_UseXinfa = "use"

------------------------------------------------------------
--room
eROOMCmd_Apply = "apply"
eROOMCmd_Create = "create"
eROOMCmd_Enter = "enter"
eROOMCmd_Tchanger = "tchanger"
eROOMCmd_New	= "new"
eROOMCmd_AddMem	= "memjoin"
eROOMCmd_Query = "query"
eROOMCmd_Ask	= "ask"
eROOMCmd_Invite = "invite"
eROOMCmd_PInvite = "pinvite"
eROOMCmd_PInviteres = "pinviteres"
eROOKCmd_Qenter		= "qenter"
eROOKCmd_Kick		= "kick"
eROOKCmd_Kicked		= "kicked"
eROOKCmd_MemKick		= "memkick"
eROOMCmd_Quit		= "quit"
eROOMCmd_MemQuit		= "memquit"
eROOMCmd_List = "list"


--------------------------------------------------------------
--task
eTaskCmd_Refresh = "tick"
eTaskCmd_MainFinish = "mainreward"
eTaskCmd_WeaponFinish = "weapontask"
eTaskCmd_PetFinish	= "pettask"

--------------------------------------------------------------
--jewel
eStoneCmd_Uplvl = "uplvl"
eStoneCmd_Inlay = "inlay"
eStoneCmd_Uninlay = "uninlay"

--------------------------------------------------------------
--weapon
eWeapon_Hecehng = "merge"
eWeapon_Uplvl	= "uplvl"
eWeapon_Upstar	= "upstar"
eWeapon_Use 	= "use"
eWeapon_DiamongUpLvl = "diamonduplvl"

--------------------------------------------------------------
--suicong
eSuicong_Call 	= "beckon"
eSuicong_Uplvl	= "uplvl"
eSuicong_Upstar = "upstar"
eSuicong_Transfer = "changejob"
eSuicong_Diamonduplvl = "diamonduplvl"
eSuicong_Play	= "use"
eSuicong_Back	= "exitUse"
eSuicong_Breakskill = "tuposkill"


-----------------------------------------------------------------
--team--
--need SendCmd
eTeamCmd_Invite			= "invite"
eTeamCmd_Iagree			= "iagree"
eTeamCmd_Irefuse		= "irefuse"
eTeamCmd_Apply			= "apply"
eTeamCmd_Aagree			= "aagree"
eTeamCmd_Arefuse		= "arefuse"
eTeamCmd_Swapleader		= "swapleader"
eTeamCmd_Kick			= "kick"
eTeamCmd_Disband		= "disband"
eTeamCmd_Openteam		= "openteam"
eTeamCmd_Exit			= "exit"
--don't  need SendCmd
eTeamCmd_Pinvite		= "pinvite"
eTeamCmd_New			= "new"
eTeamCmd_Add			= "add"
eTeamCmd_Pirefuse		= "pirefuse"
eTeamCmd_Papply			= "papply"
eTeamCmd_Parefuse		= "parefuse"
eTeamCmd_Swap			= "swap"
eTeamCmd_Remove			= "remove"
eTeamCmd_Quit			= "quit"

