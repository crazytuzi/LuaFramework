-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_fight_npc = i3k_class("wnd_fight_npc",ui.wnd_base)

local WidgetFgcst = "ui/widgets/fgcst"

function wnd_fight_npc:ctor()
	self._npcId = 0
	self._condition = 0
end

function wnd_fight_npc:configure()
	local widgets = self._layout.vars
	
	self.roleName = widgets.roleName
	self.desc = widgets.desc
	self.scroll = widgets.scroll
	self.model = widgets.model
	self.npcName = widgets.npcName
	self.btnName = widgets.btnName
	self.goFight = widgets.goFight
	self.winImg = widgets.winImg
	self.titleImg = widgets.titleImg
	
	widgets.goFight:onClick(self, self.onGoFight)
	widgets.close_btn:onClick(self, self.onCloseUI)
end


function wnd_fight_npc:refresh()
	local condition = g_i3k_game_context:GetFightNpcCondition()
	local desc = g_i3k_game_context:GetFightNpcDesc()
	local fightInfo = g_i3k_game_context:GetFightNpcInfo()
	
	local cfg = i3k_db_fight_npc[fightInfo.group][fightInfo.curIndex]
	local roleName = g_i3k_game_context:GetRoleName()
	self._condition = condition
	self._npcId = cfg.npcId

	self.roleName:setText(roleName)
	ui_set_hero_model(self.model, g_i3k_db.i3k_db_get_npc_modelID(self._npcId), nil, nil, nil, nil, cfg.defaultAction)
	self.npcName:setText(i3k_db_npc[self._npcId].remarkName)
	if self._condition == f_CONDITION_STATE_TRIGGER then
		self.goFight:disableWithChildren()
		self.btnName:setText("不服你等著")
	elseif self._condition == f_CONDITION_STATE_OPEN then
		self.btnName:setText("前往挑战")
	elseif self._condition == f_CONDITION_STATE_FIININSH then
		self.btnName:setText("领取奖励")
	end
	self.desc:setText(desc)
	self.winImg:setVisible(self._condition == f_CONDITION_STATE_FIININSH)
	self.titleImg:setVisible(self._condition ~= f_CONDITION_STATE_FIININSH)
	self:loadScrollData(cfg)
end

function wnd_fight_npc:loadScrollData(cfg)
	self.scroll:removeAllChildren()
	local roleClass = g_i3k_game_context:GetRoleType()
	for i, e in ipairs(cfg.rewards) do
		local itemId = e[roleClass]
		if itemId ~= 0 then
			local rewardsNum = cfg.rewardsNum
			local node = require(WidgetFgcst)()
			local widgets = node.vars
			local icon = g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole())
			widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			widgets.item_icon:setImage(icon)
			widgets.suo:setVisible(itemId > 0)
			widgets.item_count:setText("x"..rewardsNum[i])
			widgets.bt:onClick(self, self.onItemTips, itemId)
			self.scroll:addItem(node)
		end
	end
end

function wnd_fight_npc:onGoFight(sender)
	if self._condition == f_CONDITION_STATE_OPEN then
		g_i3k_game_context:GotoNpc(self._npcId)
		self:onCloseUI()
	elseif self._condition == f_CONDITION_STATE_FIININSH then
		local fightInfo = g_i3k_game_context:GetFightNpcInfo()
		local cfg = i3k_db_fight_npc[fightInfo.group][fightInfo.curIndex]
		local reward = {}
		local roleClass = g_i3k_game_context:GetRoleType()
		local rewardsNum = cfg.rewardsNum
		for i, e in pairs(cfg.rewards) do
			local itemId = e[roleClass]
			if itemId ~= 0 then
				table.insert(reward, {id = itemId, count = rewardsNum[i]})
			end
		end
		i3k_sbean.fightnpc_reward(reward)
	end
end

function wnd_fight_npc:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_fight_npc.new()
	wnd:create(layout)
	return wnd
end
