-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_blessing = i3k_class("wnd_faction_blessing", ui.wnd_base)

local IconList = { 7696, 7697, 7698, 7699 }
function wnd_faction_blessing:ctor()

end

function wnd_faction_blessing:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.help_btn:onClick(self, self.onHelp)
end

function wnd_faction_blessing:refresh(blessInfo)
   self:loadList(blessInfo)
end

--活动列表
function wnd_faction_blessing:loadList(blessInfo)
	local widgets = self._layout.vars
	local list = widgets.notice_content
	widgets.titleInfo:setText(i3k_get_string(17481))
	local listCfg = i3k_db_faction_spirit.blessingRewards
	local sub = #listCfg - #IconList
	for i, e in ipairs(listCfg) do
		local node = require("ui/widgets/bpzft")()
		local desc = i3k_get_string(e.blessingText, e.lifeTime / 3600, e.expCount / 100)
		local times = blessInfo[i] or 0
		node.vars.des:setText(desc)
		node.vars.info_btn:onTouchEvent(self, self.onInfo, i3k_get_string(17467,e.spiritCount))
		node.vars.times:setText(i3k_get_string(17479, times))
		if times <= 0 then
			node.vars.blessing:disableWithChildren()
		else
			node.vars.blessing:enableWithChildren()
		end
		node.vars.blessing:onClick(self, self.onUseBlessing, i)
		local path = IconList[1]
		if sub > 0 then
			path = sub >= i and  IconList[1]  or IconList[i - sub]
		else
			path = IconList[i]
		end
		node.vars.title:setImage(g_i3k_db.i3k_db_get_icon_path(path))
		list:addItem(node)
	end
end

--更新活动列表
function wnd_faction_blessing:updataList(order,times)
	local widgets = self._layout.vars
	local list = widgets.notice_content
	local node = list:getChildAtIndex(order)
	if node then
		node.vars.times:setText(i3k_get_string(17479, times))
		if times <= 0 then
			node.vars.blessing:disableWithChildren()
		else
			node.vars.blessing:enableWithChildren()
		end
	end
end
--信息
function wnd_faction_blessing:onInfo(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_BlessingInfoTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_BlessingInfoTips, data)
	elseif eventType == ccui.TouchEventType.moved then

	else
		g_i3k_ui_mgr:CloseUI(eUIID_BlessingInfoTips)
	end
end

--使用祝福
function wnd_faction_blessing:onUseBlessing(sender, index)
	if not g_i3k_game_context:ishaveFactionFightGroupPower(g_FACTION_SPIRIT_BLESS_PERMISSION) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17478))
	end
	if g_i3k_game_context:blessingBuffOpenTime() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17469))
	end
	local callBack = function (ok)
		if ok then
			i3k_sbean.use_sect_zone_spirit_bless(index)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17480), callBack)
end

function wnd_faction_blessing:onHelp()
	local cfg = i3k_db_faction_spirit.spiritCfg
	local lv = cfg.blessingLevel
	local openTime = cfg.openTime
	local factionTime = cfg.factionTime
	local time = i3k_get_time_show_text_simple(openTime)
	local day = factionTime/3600/24
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17471, time, lv, day))
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_blessing.new();
		wnd:create(layout, ...);
	return wnd;
end
