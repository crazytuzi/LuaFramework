-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qieCuoResult = i3k_class("wnd_qieCuoResult", ui.wnd_base)

function wnd_qieCuoResult:ctor()
end

function wnd_qieCuoResult:configure()
	
end

function wnd_qieCuoResult:refresh(data)
	local isShare = false
	--0平局1胜利2失败
	local result = data.win
	local enemyInfo = data.enemy
	local resultMsg = ""
	if result == 0 then
		self._layout.anis.c_pj.play()
		resultMsg = i3k_get_string(15557,enemyInfo.name)
	elseif result == 1 then
		self._layout.anis.c_sl.play()
		resultMsg = i3k_get_string(15555,enemyInfo.name)
	elseif result == 2 then
		self._layout.anis.c_sb.play()
		resultMsg = i3k_get_string(15556,enemyInfo.name)
	end
	
	self._layout.vars.desc:setText(resultMsg)
	--世界分享
	self._layout.vars.shareBtn:onClick(self,function ()
		if isShare then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15558))
			return
		end
		isShare = true
		local msg = string.format("#SOLO%d,%s#", result, enemyInfo.name)
		i3k_sbean.world_msg_send_req(msg)
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_qieCuoResult.new()
		wnd:create(layout, ...)
	return wnd
end
