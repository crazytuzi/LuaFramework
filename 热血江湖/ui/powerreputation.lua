-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_powerReputation = i3k_class("wnd_powerReputation", ui.wnd_base)

function wnd_powerReputation:ctor()

end

function wnd_powerReputation:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.roleTitle_btn:onClick(self, self.onRoleTitleBtn)
	widgets.xinjueBtn:onClick(self, self.onXinjueBtnClick)
	widgets.reqBtn:stateToPressed()
end

function wnd_powerReputation:onShow()
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end

function wnd_powerReputation:refresh(index)
	self:setMainInfo(index)
	self:setScroll(index)
	self:setOtherInfo()
	local _,level = g_i3k_game_context:GetRoleDetail()
	self._layout.vars.xinjueBtn:setVisible(level >= i3k_db_xinjue.showLevel)
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end

function wnd_powerReputation:setScroll(index)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local list = i3k_db_power_reputation
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/shengwangt")()
		ui.vars.name:setText(v.name)
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		ui.vars.btn:onClick(self, self.onScrollItem, k)
		if index == k then
			ui.vars.btn:stateToPressed()
		end
		scroll:addItem(ui)
	end
end

function wnd_powerReputation:setMainInfo(index)
	local widgets = self._layout.vars

	local cfg = g_i3k_db.i3k_db_get_power_reputation_info(index)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.name:setText(cfg.name)

	local info = g_i3k_game_context:getPowerRep()
	local value = info.fame[index] or 0
	local levelCfg = g_i3k_db.i3k_db_power_rep_get_text_and_levelName(value)

	widgets.levelName:setText(levelCfg.levelName)
	widgets.levelName:setTextColor(levelCfg.color)
	widgets.bar:setPercent(levelCfg.percent)  -- 0~100
	widgets.barCount:setText(levelCfg.text)
	widgets.scroll_npc:removeAllChildren()
	local node = require("ui/widgets/shengwangt2")()
	node.vars.icon:setImage(cfg.npcLeader.icon)
	node.vars.name:setText(cfg.npcLeader.name)
	node.vars.transBtn:hide()
	node.vars.transLabel:hide()
	widgets.scroll_npc:addItem(node)
	for i,v in ipairs(cfg.npcs) do
		if next(v) then
			local node = require("ui/widgets/shengwangt2")()
			local item = node.vars
			item.icon:setVisible(true)
			item.icon:setImage(v.icon)
			item.name:setText(v.functionName .."："..v.name)
			item.transBtn:onClick(self, self.onTrans, v.transNpcID)
			item.transLabel:show()
			item.transLabel:setText("寻路")
			widgets.scroll_npc:addItem(node)
	end
	end
	widgets.desc:setText(cfg.desc)
	widgets.desc2:setText(cfg.desc2)
end

function wnd_powerReputation:setOtherInfo()
	local syncInfo = g_i3k_game_context:getPowerRep()
	local t = syncInfo
end


function wnd_powerReputation:onTrans(sender, npcID)
	g_i3k_logic:OpenBattleUI()
	g_i3k_game_context:GotoNpc(npcID) -- 这里传送过去只是一个npc的范围，仅仅相当于一个坐标
end


function wnd_powerReputation:onScrollItem(sender, id)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if k == id then
			v.vars.btn:stateToPressed()
		else
			v.vars.btn:stateToNormal()
		end
	end
	self:setMainInfo(id)
end

function wnd_powerReputation:onRoleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PowerReputation)
	g_i3k_logic:OpenRoleLyUI()
end

function wnd_powerReputation:onRoleTitleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PowerReputation)
	g_i3k_logic:OpenRoleTitleUI()
end

function wnd_powerReputation:onXinjueBtnClick()
	local _,level = g_i3k_game_context:GetRoleDetail()
	if level < i3k_db_xinjue.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s级解锁心决",i3k_db_xinjue.openLevel))
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PowerReputation)
		g_i3k_logic:OpenXinJueUI()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_powerReputation.new()
	wnd:create(layout, ...)
	return wnd;
end
