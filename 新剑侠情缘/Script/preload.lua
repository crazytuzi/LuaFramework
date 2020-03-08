if bIsLoad then
	return;
end
bIsLoad = true;

-- 初始化C# 程序集
luanet.load_assembly('UnityEngine');
luanet.load_assembly('Assembly-CSharp');


tbGlobalTable_Pre = {

	---------------  这里可以初始化各种 table，在此处是暂时没有禁用创建全局对象的
	Client = {};
	UiNotify = {};
	Main = {};
	UiManager = {};
	SceneMgr = {};
	Operation = {};
	AutoFight = {};
	Login = {};					--登录创建角色相关的
	XinShouLogin = {};
	PreloadResource = {};
	CGAnimation = {};
	ClientNpc = {};
	AutoPath = {};
	CangBaoTu = {};
	ViewRole = {}; --查看获取玩家数据
	FileServer = {};

	Loading = {};

	Pandora = {}; --精细化运营
	CameraAnimation = {}; --摄像机，UI动画
	WebView = {};

	Decoration = {};
}

GetTimeFrameState_Old = GetTimeFrameState_Old or GetTimeFrameState;
function GetTimeFrameState( ... )
	return TimeFrame:GetTimeFrameState(...)
end

CalcTimeFrameOpenTime_Old = CalcTimeFrameOpenTime_Old or CalcTimeFrameOpenTime;
function CalcTimeFrameOpenTime( ... )
	return TimeFrame:CalcTimeFrameOpenTime(...)
end

-- 这个文件内声明 server 和 client 都有的全局table
Require("CommonScript/GlobalTable.lua");

for k, v in pairs(tbGlobalTable_Pre) do
	tbGlobalTable[k] = v;
end

for k, v in pairs(tbGlobalTable) do
	_G[k] = v;
end


function XT(...)
	return ...;
end

function LogD() --有些logD在com
end

----------------------------- 禁用创建全局对象
global_env = getfenv(0);
getfenv_old = getfenv_old or getfenv;
getfenv = function (value)
	if getfenv_old(value) == getfenv_old(0) then
		return nil;
	end
	return getfenv_old(value);
end
assert(global_env, 'can not get global env!');
newmt = {
	__newindex = function (table, key, value)
		if not key or not tbGlobalTable[key] then
			Log(debug.traceback())
			assert(false, 'can not new global key ' .. tostring(key));
		else
			rawset(table, key, value);
		end
	end
}
setmetatable(global_env, newmt);
global_env = nil;
newmt = nil;
---------------------------- 禁用全局对象 end


---------------------------------  预加载文件
Require("CommonScript/EnvDef.lua");
Require("CommonScript/UiDef.lua");
Require("Script/Ui/Ui.lua");
Require("CommonScript/lib.lua");
Require("CommonScript/calc.lua");
Require("CommonScript/Skill/FightSkill.lua");
Require("Script/Player/KPlayer.lua");
Require("CommonScript/Npc/Npc.lua");
Require("CommonScript/Fuben/FubenMgrCommon.lua");
Require("CommonScript/Item/Item.lua");
Require("CommonScript/Kin/KinDef.lua");
Require("Script/AsyncBattle/AsyncBattle.lua");
Require("CommonScript/Player/Player.lua");
Require("CommonScript/Faction.lua");
Require("Script/Activity/ActivityUi.lua");
Require("CommonScript/Decoration/Decoration.lua");
Require("CommonScript/Decoration/DecorationClassMgr.lua");
Require("CommonScript/JueXue/JueXueDef.lua");