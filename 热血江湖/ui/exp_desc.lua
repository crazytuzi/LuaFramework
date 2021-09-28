-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_exp_desc = i3k_class("wnd_exp_desc", ui.wnd_base)

function wnd_exp_desc:ctor()
	
end

function wnd_exp_desc:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.desc = self._layout.vars.desc
	self.scroll = self._layout.vars.scroll
	--self.scroll:setBounceEnabled(false)
end

function wnd_exp_desc:refresh()
	local msgText = self:getTextStr()
	if msgText then
		self.desc:hide()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = require("ui/widgets/bzt1")()
			gzText.vars.text:setText(msgText)
			ui.scroll:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(ui.scroll, width, height, true)
			end, 1)
		end, 1)
	end
end

function wnd_exp_desc:getTextStr()
	local str = ""
	local cfg = i3k_db_server_limit
	local rushCfg = g_i3k_db.i3k_db_rush_lvl_cfg()
	local isShowLimit = false
	if not g_i3k_game_context:isSealBreak() then
		if i3k_game_get_server_opened_days() >= cfg.openDay then
			isShowLimit = true
			str = str.."1、"..i3k_get_string(820, cfg.sealLevel)..i3k_get_string(821, cfg.sealLevel, cfg.multiple).."\n"
	    end
	else
		isShowLimit = true
		str = str.."1、"..i3k_get_string(820, cfg.breakSealCfg.newSealLevel)..i3k_get_string(821, cfg.breakSealCfg.newSealLevel, cfg.multiple).."\n"
	end
	local tStr = isShowLimit and "2、" or "1、"
	local rushStr = ""
	if rushCfg then
		rushStr = i3k_get_string(823, rushCfg.levelLess, rushCfg.percent.."%")
	else
		local lvl = g_i3k_db.i3k_db_get_min_rush_lvl()
		rushStr = i3k_get_string(824, lvl) 
	end
	str = str..tStr..i3k_get_string(822, g_i3k_game_context:GetSpeedUpLvl())..rushStr
	return str
end

function wnd_create(layout)
	local wnd = wnd_exp_desc.new()
	wnd:create(layout)
	return wnd
end