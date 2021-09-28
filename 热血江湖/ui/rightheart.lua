-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rightheart = i3k_class("wnd_rightheart", ui.wnd_base)

function wnd_rightheart:ctor()
end

function wnd_rightheart:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.close
	self.callteamBtn = widgets.getAllAnnex
	self.descbtn = widgets.descbtn
	self.imagebg = widgets.imagebg
	self.descText = widgets.desc
	self.lefttime = widgets.lefttime
	self.coloseBtn:onClick(self, self.onCloseUI)	
	self.callteamBtn:onClick(self, self.onClickCallteamBtn)	
	self.descbtn:onClick(self, self.onClickDescBtn)	
end

function wnd_rightheart:onCloseUI()
	g_i3k_ui_mgr:CloseUI(eUIID_RightHeart)
end

function wnd_rightheart:onHideImpl( )
end

function wnd_rightheart:refresh(mtype,curdata,res)
	local str = ""
	if g_i3k_game_context:getRightHeartNowHadEnterTimes() <= 0 then
		str = "\n<c=hlred>可以进入副本帮助他人，但无奖励</c>"
	end
	self.descText:setText(i3k_get_string(15190)..str)
	self.lefttime:setText(g_i3k_game_context:getRightHeartNowHadEnterTimes())
end

function wnd_rightheart:onClickCallteamBtn( sender )
	-- if  g_i3k_game_context:getRightHeartNowHadEnterTimes() <= 0 then
	-- 	return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15188))
	-- end

	g_i3k_game_context:GotoNpc(i3k_db_rightHeart.npcId)
end

function wnd_rightheart:onClickDescBtn( sender )
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(15189))
end

function wnd_create(layout)
	local wnd = wnd_rightheart.new()
	wnd:create(layout)
	return wnd
end


	
