--[[
公告链接脚本
lizhuangzhuang
2015年1月20日15:03:24
]]

_G.NoticeScriptCfg = {};

function NoticeScriptCfg:Add(script)
	if NoticeScriptCfg[script.name] then
		print("Error:公告脚本重复！！！");
		return;
	end
	NoticeScriptCfg[script.name] = script;
end

_dofile (ClientConfigPath .. "config/noticeScript/openfunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openui.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openactivity.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openguild.lua")
_dofile (ClientConfigPath .. "config/noticeScript/UnionWarPath.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openequipbuild.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openbabel.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openZhuansheng.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openFirstCharge.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openActivity3.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openDayCharge.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openVipView.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openActivity4.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openlianyu.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openSpiritWarprintCfg.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openswyj.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openchristmasIntrusion.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openMarryPanel.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openMagicFunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openXinfaFunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openTianshenFunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openMuYeFunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openZuduiBattleFunc.lua")
_dofile (ClientConfigPath .. "config/noticeScript/openZuduiExpFunc.lua")