--[[
任务脚本
lizhuangzhuang
2014年11月12日14:43:28
]]

_G.QuestScriptCfg = {};

function QuestScriptCfg:Add(script)
	if QuestScriptCfg[script.name] then
		print('Error:任务脚本重复');
		_debug:throwException("Error:引导脚本重复"..script.name);
		return;
	end
	QuestScriptCfg[script.name] = script;
end

_dofile (ClientConfigPath .. "config/questScript/strenguide.lua")
_dofile (ClientConfigPath .. "config/questScript/horseguide.lua")
_dofile (ClientConfigPath .. "config/questScript/equipproguide.lua")
_dofile (ClientConfigPath .. "config/questScript/skillguide.lua")
_dofile (ClientConfigPath .. "config/questScript/julingwanguide.lua")
_dofile (ClientConfigPath .. "config/questScript/lingshouskillguide.lua")
_dofile (ClientConfigPath .. "config/questScript/refinfuncguide.lua")
_dofile (ClientConfigPath .. "config/questScript/equipbuildfuncguide.lua")
_dofile (ClientConfigPath .. "config/questScript/equipbuildfuncguide1.lua")
_dofile (ClientConfigPath .. "config/questScript/equipbuildfuncguide2.lua")
_dofile (ClientConfigPath .. "config/questScript/superdownguide.lua")
_dofile (ClientConfigPath .. "config/questScript/superupguide.lua")
_dofile (ClientConfigPath .. "config/questScript/roadfuncguide.lua")
_dofile (ClientConfigPath .. "config/questScript/roadfuncguide1.lua")
_dofile (ClientConfigPath .. "config/questScript/dungeonguide.lua")
_dofile (ClientConfigPath .. "config/questScript/wingpreviewguide.lua")
_dofile (ClientConfigPath .. "config/questScript/wingfuncguide.lua")
_dofile (ClientConfigPath .. "config/questScript/equipguide.lua")
_dofile (ClientConfigPath .. "config/questScript/ridehorse.lua")
_dofile (ClientConfigPath .. "config/questScript/homequestguide.lua")
_dofile (ClientConfigPath .. "config/questScript/binghungetguide.lua")
_dofile (ClientConfigPath .. "config/questScript/binghunungetguide.lua")
_dofile (ClientConfigPath .. "config/questScript/realmgongguguide.lua")
_dofile (ClientConfigPath .. "config/questScript/fabaochangeguide.lua")