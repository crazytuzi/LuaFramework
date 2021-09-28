--mysteryCard
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_warZoneCard = i3k_class("wnd_warZoneCard", ui.wnd_base)

local PERSONAL_ACTIVATION 	= 1 --已激活
local PERSONAL_BAG			= 2 --卡包

local CARD_CAN_CTIVATION 	= 1	--可以激活
local CARD_CAN_NONE			= 2 --未获得
local CARD_CAN_ACTIVATION 	= 3 --卡片已激活

local PERSONAL_CARD = 0 --个人卡
local FACTION_CARD = 1 --帮派卡


local CARD_ITEM = "ui/widgets/shenmikapiant1"
local LOG_EVENT = "ui/widgets/shenmikapiant3"
local LOG_TIME = "ui/widgets/shenmikapiant4"
local FILTER_STR = "ui/widgets/shenmikapiant5"
local ROLE_DESC = "ui/widgets/shenmikapian6"
local NAME_DESC = "ui/widgets/shenmikapiant7"

function wnd_warZoneCard:ctor()
	self.rightState = 1
	self.logState = g_WAR_ZONE_CARD_PERSONAL_LOG
	self.personState = PERSONAL_ACTIVATION
	self.filterQualityType = 1
	self.cardDate = {}
end

function wnd_warZoneCard:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onClose)
	widgets.help:onClick(self, self.onHelp)
	--person
	widgets.activationBtn:onClick(self, self.onCardBag, PERSONAL_ACTIVATION)
	widgets.bagBtn:onClick(self, self.onCardBag, PERSONAL_BAG)
	
	self.tabInfos = {
		[g_PERSONAL_WAR_ZONE_CARD_STATE] = {root = widgets.personRoot, tab = widgets.personRootBtn, updateUi = "updatePersonUI" , defaultIndex = PERSONAL_ACTIVATION}, 
		[g_FACTION_WAR_ZONE_CARD_STATE] = {root = widgets.factionRoot, tab = widgets.factionRootBtn, updateUi = "updateFactionUI", },
		[g_LOG_WAR_ZONE_CARD_STATE] 	 = {root = widgets.logRoot, tab = widgets.logRootBtn, updateUi = "updateLogUI" , defaultIndex = g_WAR_ZONE_CARD_PERSONAL_LOG},
	}

	self.logBtn = {widgets.personalLog, widgets.warZoneLog}
	self.personalBtn = {widgets.activationBtn, widgets.bagBtn}

	self._useBtn = {
		[PERSONAL_CARD] =	{
								[CARD_CAN_CTIVATION] = {text = i3k_get_string(5727), isCanUse = true,  useType = g_WAR_ZONE_CARD_ACTIVATION },
								[CARD_CAN_NONE] 	 = {text = i3k_get_string(5726), isCanUse = false},
								[CARD_CAN_ACTIVATION] 	 = {text = i3k_get_string(5728), isCanUse = true,  useType = g_WAR_ZONE_CARD_GIVE_UP},},
		[FACTION_CARD] 	= 	{
								[CARD_CAN_CTIVATION] = {text = i3k_get_string(5577), isCanUse = true, useType = g_WAR_ZONE_CARD_FACTION_DONATE},
								[CARD_CAN_NONE] 	 = {text = i3k_get_string(5726), isCanUse = false},
		},
	}
	self._personal = {}

	for i,v in ipairs(self.tabInfos) do
		v.tab:onClick(self, self.selectePage, {state = i})
	end

	for i,v in ipairs(self.logBtn) do
		v:onClick(self, self.onSelectLogState, i)
	end
	widgets.gradeLabel:setText(i3k_get_string(i3k_db_war_zone_map_cfg.cardGrade[self.filterQualityType].gradeDesc))
   	--下拉列表
   	--添加新筛选类型filterNum + 1
	local filterStrs = i3k_db_war_zone_map_cfg.cardGrade--self:getFilterStrs()
	widgets.filterBtn:onClick(self,function ()
		if widgets.levelRoot:isVisible() then                 --如果下拉列表已经显示
			widgets.levelRoot:setVisible(false)				 --则把列表关闭
		else
			widgets.levelRoot:setVisible(true)					--如果没显示就打开下拉列表
			widgets.filterScroll:removeAllChildren();          --清空scroll
			for i = 1, #filterStrs do
				local _item = require(FILTER_STR)();
				local desc = i3k_db.i3k_db_get_war_zone_card_grade_count(i)
				_item.id = i;
				_item.vars.levelLabel:setText(i3k_get_string(filterStrs[i].gradeDesc) .. desc);
				_item.vars.levelBtn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)                        --点击之后关闭下拉列表
					self.filterQualityType = _item.id
					widgets.gradeLabel:setText(i3k_get_string(i3k_db_war_zone_map_cfg.cardGrade[self.filterQualityType].gradeDesc))  --背包面板的显示更变
					self:setCardBag(self.filterQualityType)
				end)
				widgets.filterScroll:addItem(_item);       --添加到scroll
			end
		end
	end)

end

function wnd_warZoneCard:refresh(state, id)
	self:selectePage(nil, {state = state, id = id})
end

--更新展示界面
function wnd_warZoneCard:updateRightBtnState(state, id)
	self.cardDate = {}
	local widgets = self._layout.vars
	self.rightState = state ~= self.rightState and state or self.rightState
	for k,v in pairs(self.tabInfos) do
		v.root:hide()
		v.tab[k == self.rightState and "stateToPressed" or "stateToNormal"](v.tab)
	end
	local  curInfo = self.tabInfos[self.rightState]
	self[curInfo.updateUi](self, curInfo.defaultIndex, nil, id)
	self:updateRed()
end


function wnd_warZoneCard:updateRed()
	local widgets = self._layout.vars
	widgets.personal_red:setVisible(i3k_db.i3k_db_get_war_zone_card_personal_red())
end

function wnd_warZoneCard:onUpdate(dTime)
	if self.rightState == g_PERSONAL_WAR_ZONE_CARD_STATE  then
		self:updateCardTime()
	end
end

function wnd_warZoneCard:selectePage(sender, info)
	local state = info.state
	local callBack = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateRightBtnState", state, info.id)
	end
	if state == g_FACTION_WAR_ZONE_CARD_STATE then
		i3k_sbean.global_world_sect_panel(callBack)
	elseif state == g_LOG_WAR_ZONE_CARD_STATE then
		i3k_sbean.global_world_log(g_WAR_ZONE_CARD_PERSONAL_LOG, callBack)
	else
		callBack()
	end
end
---------------------PERSON-------------------------
function wnd_warZoneCard:updatePersonUI(state, isForActivated, id)
	if state == PERSONAL_ACTIVATION and not self:isHaveInUse() then
		state = PERSONAL_BAG
	end
	self.personState = id and PERSONAL_BAG or state
	local widgets = self._layout.vars
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	widgets.selectGradeRoot:hide()
	widgets.levelRoot:hide()
	widgets.personRoot:show()
	for i,v in ipairs(self.personalBtn) do
		v[i == self.personState and "stateToPressed" or "stateToNormal"](v, true)
	end
	if state == PERSONAL_BAG  then
		local quality, id = self:getDefaultQualityAndSetFilter(isForActivated, id)
		self:setCardBag(quality, isForActivated and id or isForActivated)
	else
		self:setActivated()
	end
	local countDesc = string.format(table.nums(cardInfo.card.inUse) >= i3k_db_war_zone_map_cfg.personalUseMax and "<c=red>%s</c>" or "<c=green>%s</c>", table.nums(cardInfo.card.inUse).. "/" .. i3k_db_war_zone_map_cfg.personalUseMax)
	widgets.useCount:setText(i3k_get_string(5766, countDesc))
	widgets.descTip:setText(i3k_get_string(5794))
end

function wnd_warZoneCard:updateCardTime()
	local widgets = self._layout.vars
	if table.nums(self.cardDate) > 0 then
		for k,v in pairs(self.cardDate) do
			self:updateCardState(k, v)
		end
	end
end

function wnd_warZoneCard:updateCardState(id, info)
	local widgets = info.node.vars
	if info.cardState == CARD_CAN_ACTIVATION then
		local time = info.endTime - i3k_game_get_time()
		if time >= 0 then
			widgets.time:show()
			widgets.time:setText(i3k_get_time_show_text_simple(time))
		else
			if info.pageState == PERSONAL_ACTIVATION then
				widgets.addRoot:show()
				widgets.addBtn:onClick(self, self.onGotoUse, info.id)
			else
				g_i3k_game_context:SetWarZoneCardInvalid(id)
				widgets.icon:disable()
				widgets.state:setText(i3k_get_string(5752))
				widgets.time:hide()
			end
			widgets.jh:hide()
			self.cardDate[id] = nil
		end
	else
		local time = info.endTime - i3k_game_get_time()
		if time >= 0 then
			widgets.time:show()
			widgets.time:setText(i3k_get_time_show_text_simple(time))
		else
			g_i3k_game_context:SetWarZoneCardRecovery(id)
			widgets.icon:disable()
			widgets.state:setText(i3k_get_string(5752))
			widgets.time:hide()
			self.cardDate[id] = nil
		end
	end
end

function wnd_warZoneCard:setActivated()
	local widgets =  self._layout.vars
	self.cardDate = {}
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	widgets.scrollCard:removeAllChildren()
	local activatedInfo = self:activatedSort(cardInfo.card.inUse)
	for i =1,  i3k_db_war_zone_map_cfg.personalUseMax do
		local node = require(CARD_ITEM)()
		local  info  = activatedInfo[i]
		self:setCardItem(node, info and info.id)
		widgets.scrollCard:addItem(node)
	end
	if activatedInfo[1] and  activatedInfo[1].id then
		self:onSelectCard(nil,  activatedInfo[1].id)
	end
end

--已激活跳转
function wnd_warZoneCard:onGotoUse(sender)
	if self:isHaveBuffCard() then
		self:updatePersonUI(PERSONAL_BAG, true)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5725))
	end 
end

--是否有正在激活的卡
function wnd_warZoneCard:isHaveInUse()
	local info = g_i3k_game_context:GetWarZoneCardInfo()
	return table.nums(info.card.inUse) > 0
end

--是否有buff卡
function wnd_warZoneCard:isHaveBuffCard()
	local info = g_i3k_game_context:GetWarZoneCardInfo()
	local bag = info.card.bag
	for k,v in pairs(bag) do
		local cfg = i3k_db_war_zone_map_card[k]
		if cfg.buffId ~= 0 then
			return true
		end
	end
	return false
end

function wnd_warZoneCard:setCardBag(quality, id)
	local widgets = self._layout.vars
	widgets.selectGradeRoot:show()
	self.cardDate = {}
	widgets.scrollCard:removeAllChildren()
	local info = g_i3k_game_context:GetWarZoneCardInfo()
	if not quality then
		quality = self.filterQualityType 
	end
	local curCards = self:bagCardSort(quality)
	local defaultIndex = 1
	for k,v in ipairs(curCards) do
		if id and id == v.id then
			defaultIndex = k
		end
		local node = require(CARD_ITEM)()
		self:setCardItem(node, v.id)
		widgets.scrollCard:addItem(node)
	end
	self:onSelectCard(nil,  curCards[defaultIndex].id)
end

function wnd_warZoneCard:setCardItem(node, id)
	local widgets = node.vars
	if id then
		local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
		local cfg = i3k_db_war_zone_map_card[id]
		local gradeIcon = i3k_db_war_zone_map_cfg.cardGrade[cfg.grade].gardeIcon
		local inUse = cardInfo.card.inUse
		local bag = cardInfo.card.bag
		local state = (bag[id] and  CARD_CAN_CTIVATION) or (inUse[id] and CARD_CAN_ACTIVATION)
		local endTime = bag[id] or inUse[id]
		if node._cardID then self.cardDate[node._cardID] = nil end
		widgets.addRoot:hide()
		widgets.gradeIcon:show()
		widgets.gradeIcon:setImage(i3k_db.i3k_db_get_icon_path(gradeIcon))
		widgets.icon:setImage(i3k_db.i3k_db_get_icon_path(cfg.icon))
		widgets.name:setText(cfg.name)
		node._cardID = id
		widgets.selectCardBtn:onClick(self, self.onSelectCard, id)
		widgets.icon[endTime and "enable" or "disable"](widgets.icon)
		widgets.activation:setVisible(state and state == CARD_CAN_ACTIVATION)
		
		widgets.state:setText(self:getCardSateDesc(id))
		widgets.time:setVisible(endTime and endTime > 0)
		widgets.time:setText(endTime and i3k_get_string(5767, i3k_get_time_show_text_simple(endTime - i3k_game_get_time())) or i3k_get_string(5752))  
		if state and state == CARD_CAN_ACTIVATION then
			widgets.jh:show()
		else
			widgets.jh:hide()
		end
		
		if state then
			self.cardDate[id] = {
				id = id,
				node = node,
				endTime = endTime,
				pageState = self.personState,
				cardState = state,
			}
		else
			self.cardDate[id] = nil
		end
	else
		widgets.gradeIcon:hide()
		widgets.addRoot:show()
		widgets.addBtn:onClick(self, self.onGotoUse)
		if node._cardID then
			self.cardDate[node._cardID] = nil
		end
	end
end

function wnd_warZoneCard:onCardBag(sender, state)
	if self.personState == state then return end
	if  state == PERSONAL_ACTIVATION and not self:isHaveInUse() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5737))
	end
	self:updatePersonUI(state)
end

function wnd_warZoneCard:setCardDesc(id)
	local widgets = self._layout.vars
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	local cfg = i3k_db_war_zone_map_card[id]
	local useCount = cardInfo.card2DayUseCount[id] or 0
	local effectDesc = ""
	if cfg.buffTime > 0 then
		effectDesc = i3k_get_string(5723, i3k_get_time_show_text_simple(cfg.buffTime))
	else
		effectDesc = i3k_get_string(cfg.useType == 1 and 5788  or 5761 )
	end
	local descInfo = {
		[1] = {name = i3k_get_string(5568), desc = i3k_db.i3k_db_get_war_zone_card_efect_desc(id)} ,
		[2] = {name = i3k_get_string(5569), desc = effectDesc} ,
		[3] = {name = cfg.useType == 0 and i3k_get_string(5570)  or  i3k_get_string(5759), desc = i3k_get_string( cfg.useType == 0 and 5724 or 5760, useCount, cfg.dayUseTimes), color = cfg.dayUseTimes <= useCount and g_i3k_get_red_color() or nil},
		--[4] = {name = i3k_get_string(5571), desc = i3k_get_string(cfg.dropDesc)} ,
	}
	self:setCardDescScroll(widgets.scrollDesc1, descInfo)
end


function wnd_warZoneCard:onSelectCard(sender, id)
	local widgets = self._layout.vars
	local cfg = i3k_db_war_zone_map_card
	local children = widgets.scrollCard:getAllChildren()
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	for k, v in ipairs(children) do
		v.vars.selected:setVisible(v._cardID == id)
	end
	local widgets = self._layout.vars
	local state = self:getCardSate(id)
	self:setCardDesc(id)
	local useBtnInfo = self._useBtn[cfg[id].useType][state]
	widgets.ok[useBtnInfo.isCanUse and "enable" or "disable" ](widgets.ok)
	if cardInfo.card2DayUseCount[id] and cardInfo.card2DayUseCount[id]  >= cfg[id].dayUseTimes then
		widgets.ok:disable()
	end
	widgets.okText:setText(useBtnInfo.text)
	widgets.ok:onClick(self, self.useCard, {id = id, useType = useBtnInfo.useType })
end

function wnd_warZoneCard:getCardSate(id)
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo().card
	if cardInfo.bag[id] then
		return CARD_CAN_CTIVATION
	elseif cardInfo.inUse[id] then
		return CARD_CAN_ACTIVATION
	end
	return CARD_CAN_NONE
end

function wnd_warZoneCard:useCard(sender, info)
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	local curCardState = self:getCardSate(info.id)
	local cfg = i3k_db_war_zone_map_card
	local inUse = cardInfo.card.inUse 
	local bag = cardInfo.card.bag
	local callback = function (isOk)
		if isOk then
			i3k_sbean.global_world_card_operation(info.useType, info.id)
		end
	end
	if curCardState == CARD_CAN_NONE then
		 return  --, CARD_NONE_TIPS
	elseif curCardState == CARD_CAN_CTIVATION then
		if cardInfo.card2DayUseCount[info.id] and cardInfo.card2DayUseCount[info.id] >= cfg[info.id].dayUseTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5715))
			return 
		end
		if info.useType == g_WAR_ZONE_CARD_FACTION_DONATE then
			local factionPool = g_i3k_game_context:GetWarZoneFactionCardPool()
			if cardInfo.daySectDonateCount >= i3k_db_war_zone_map_cfg.donaCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5716))
				return 
			end
			if factionPool and factionPool[info.id] and factionPool[info.id] + cfg[info.id].copyCount  > cfg[info.id].maxCount then
				g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(5764), function(isOk)
					if isOk then
						i3k_sbean.global_world_card_sect_donate(info.id)
					end
				end)
				return
			end
			i3k_sbean.global_world_card_sect_donate(info.id)
		else
			if table.nums(inUse) > 0 then
				if inUse[info.id] then
					g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(5717), callback)
					return
				end
				for k,v in pairs(inUse) do
					local curCfg = cfg[k]
					if curCfg.mutexGroupId == cfg[info.id].mutexGroupId then
						g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(5718), callback)
						return
					end
				end
				if cfg[info.id].buffId > 0 and table.nums(inUse) >= i3k_db_war_zone_map_cfg.personalUseMax then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5719))
					return 
				end
			end
			i3k_sbean.global_world_card_operation(info.useType, info.id)
		end
	else
		g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(5736), callback)
	end
end

function wnd_warZoneCard:updateCardItem(cardId, state)
	local widgets = self._layout.vars
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	local node, isReplace = self:getNodeForScroll(widgets.scrollCard, cardId, self.personState == PERSONAL_ACTIVATION)
	if node then 
		if self.personState == PERSONAL_BAG then
			local cfg = i3k_db_war_zone_map_card[cardId]
			self:setCardItem(node, cardId)
			self:onSelectCard(nil, cardId)
		else
			if not cardInfo.card.bag[cardId] then
				self:setCardItem(node, isReplace and cardId )
			end
		end
	end
	local countDesc = string.format(table.nums(cardInfo.card.inUse) >= i3k_db_war_zone_map_cfg.personalUseMax and "<c=red>%s</c>" or "<c=green>%s</c>", table.nums(cardInfo.card.inUse).. "/" .. i3k_db_war_zone_map_cfg.personalUseMax)
	widgets.useCount:setText(i3k_get_string(5766, countDesc))
end

--获取卡的状态描述
function wnd_warZoneCard:getCardSateDesc(id)
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo().card
	local cfg = i3k_db_war_zone_map_card
	if cardInfo.inUse[id] then
		return i3k_get_string(5756)
	elseif cardInfo.bag[id] then
		local grade = cfg[id].grade
		local mutexGroupId = cfg[id].mutexGroupId
		if cfg[id].useType == 1 then
			return i3k_get_string(5774)
		end
		for k,v in pairs(cardInfo.inUse) do
			if cfg[k].mutexGroupId == mutexGroupId and cfg[k].grade > grade then
				return i3k_get_string(5754)
			end
		end
		for k,v in pairs(cardInfo.bag) do
			if k ~= id and cfg[k].mutexGroupId == mutexGroupId and cfg[k].grade > grade then
				return i3k_get_string(5755)
			end
		end
		return i3k_get_string(5753)
	else
		return i3k_get_string(5752)
	end
end
------------------FACTION--------------------

function wnd_warZoneCard:updateFactionUI()
	local widgets = self._layout.vars
	local factionCard = g_i3k_game_context:GetWarZoneFactionCardPool()
	local info = self:factionCardSort(factionCard)
	widgets.factionRoot:show()
	widgets.scrollFaction:removeAllChildren()
	for k,v in ipairs(info) do
		local node = require(CARD_ITEM)()
		self:setFactionCardItem(node, v)
		widgets.scrollFaction:addItem(node)
	end
	if info[1] then
		self:onSelectFactionCard(nil, info[1].id)
	end
end

function wnd_warZoneCard:setFactionCardItem(node, info)
	node._cardID  = info.id
	local widgets = node.vars
	local cfg = i3k_db_war_zone_map_card[info.id]
	local gradeIcon = i3k_db_war_zone_map_cfg.cardGrade[cfg.grade].gardeIcon
	widgets.addRoot:hide()
	widgets.gradeIcon:show()
	widgets.activation:hide()
	widgets.gradeIcon:setImage(i3k_db.i3k_db_get_icon_path(gradeIcon))
	widgets.name:setText(cfg.name)
	widgets.icon:setImage(i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.time:setText(info.count.."/" .. cfg.maxCount)
	widgets.state:hide()
	widgets.selectCardBtn:onClick(self, self.onSelectFactionCard, info.id)
	widgets.jh:hide()
end


function wnd_warZoneCard:setFactionCardDesc(id)
	local widgets = self._layout.vars
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	local cfg = i3k_db_war_zone_map_card[id]
	local useCount = cardInfo.card2DaySectDrawCount and cardInfo.card2DaySectDrawCount[id] or 0
	local useAllCount = 0	
	if cardInfo.card2DaySectDrawCount then
		for k,v in pairs(cardInfo.card2DaySectDrawCount) do
			useAllCount = useAllCount + v
		end
	end
	widgets.factionGetBtn:onClick(self, self.onGetFactionCardEfect, id)
	widgets.factionGetBtn:disable()
	--widgets.scrollDesc2:removeAllChildren()
	local descInfo = {
		[1] = {name = i3k_get_string(5568), desc = i3k_db.i3k_db_get_war_zone_card_efect_desc(id) } ,
		[2] = {name = i3k_get_string(5569), desc = i3k_get_string(5720) } ,
		[3] = {name = i3k_get_string(5757), desc = i3k_get_string(5758, useCount and useCount or 0  ,cfg.dayUseTimes), color = cfg.dayUseTimes <= useCount and g_i3k_get_red_color() or nil},
		--[4] = {name = i3k_get_string(5571), desc = i3k_get_string(cfg.dropDesc) } ,
	}
	self:setCardDescScroll(widgets.scrollDesc2, descInfo)
	local countDesc = string.format(useAllCount >= i3k_db_war_zone_map_cfg.factionGetMax and "<c=red>%s</c>" or "<c=green>%s</c>", useAllCount.. "/" .. i3k_db_war_zone_map_cfg.factionGetMax)
	widgets.getDesc:setText(i3k_get_string(5572, countDesc))
	if useAllCount < i3k_db_war_zone_map_cfg.factionGetMax and (useCount and useCount or 0 ) < cfg.dayUseTimes then
		widgets.factionGetBtn:enable()
	end

end
function wnd_warZoneCard:onSelectFactionCard(sender, id)
	local widgets = self._layout.vars
	local children = widgets.scrollFaction:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selected:setVisible(v._cardID == id)
	end
	self:setFactionCardDesc(id)

end
function wnd_warZoneCard:onGetFactionCardEfect(sender, id)
	local cfg = i3k_db_war_zone_map_card[id]
	if cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_REWARD and not g_i3k_game_context:checkBagCanAddCell(1,true) then
	else
		i3k_sbean.global_world_sect_drawcard(id)
	end
	
end

function wnd_warZoneCard:factionCardSort(info)
	local cfg = i3k_db_war_zone_map_card
	local sortInfo = {}
	for k,v in pairs(info) do
		local cfg = i3k_db_war_zone_map_card[k]
		local cardInfo = {}
		cardInfo.cfg = cfg
		cardInfo.count = v
		cardInfo.id = k
		table.insert(sortInfo, cardInfo)
	end
	table.sort(sortInfo, function (a, b)
		if a.cfg.grade == b.cfg.grade then
			return a.count > b.count
		else
			return a.cfg.grade > b.cfg.grade
		end
	end)
	return sortInfo
end
---------invok--
function wnd_warZoneCard:updateFactionItem(id)
	local widgets = self._layout.vars
	local factionCard = g_i3k_game_context:GetWarZoneFactionCardPool()
	local  cfg = i3k_db_war_zone_map_card[id]
	local children = widgets.scrollFaction:getAllChildren()
	for k, v in ipairs(children) do
		if v._cardID == id then
			if v.vars and v.vars.time and factionCard[id] then
				v.vars.time:setText(factionCard[id].."/" .. cfg.maxCount)
				self:setFactionCardDesc(id)
				break
			end
		end
	end
end
---------------------LOG---------------------

function wnd_warZoneCard:updateLogUI(logSteate)
	local widgets = self._layout.vars
	widgets.logRoot:show()
	local info = g_i3k_game_context:GetWarZoneCardLog()
	widgets.scrollLog:removeAllChildren()

	for i,v in ipairs(self.logBtn) do
		v[i == logSteate and "stateToPressed" or "stateToNormal"](v, true)
	end
	if info[logSteate] then
		table.sort(info[logSteate], function(a, b)
			return a.timestamp > b.timestamp
		end)
		for i,v in ipairs(info[logSteate]) do
			local node1 = require(LOG_EVENT)()
			local node2 = require(LOG_TIME)()
			self:setLogItem(node1, node2, v)
			widgets.scrollLog:addItem(node2)
			widgets.scrollLog:addItem(node1)
		end
	end
end

function wnd_warZoneCard:setLogItem(node, node1, info)
	local widgets = node.vars
	local widgets1 = node1.vars
	local cfg = i3k_db_war_zone_map_card
	widgets.desc_label:setText(i3k_db.i3k_db_get_war_zone_card_log_str(info))
	widgets.time_label:setText(g_i3k_get_HourAndMin(info.timestamp))
	widgets1.time_label:setText(g_i3k_get_YearAndDayTime(info.timestamp))
	
end

function wnd_warZoneCard:onSelectLogState(sender, state)
	if self.logState == state then
		return
	end
	self.logState = state
	local callBack = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateLogUI", self.logState)
	end
	i3k_sbean.global_world_log(state, callBack)
end

---------------------------------
function wnd_warZoneCard:getNodeForScroll(scroll, id, isInUse)
	local children = scroll:getAllChildren()
	local cfg = i3k_db_war_zone_map_card[id]
	for k, v in ipairs(children) do
		local cfgCur = i3k_db_war_zone_map_card[v._cardID]
		if v._cardID == id or (isInUse and cfgCur and cfgCur.mutexGroupId == cfg.mutexGroupId ) then
			return v,  v._cardID ~= id
		end
	end
	if self.filterQualityType == cfg.grade or isInUse then
		for i,v in ipairs(children) do
			if not v._cardID then
				return v, true
			end
		end
	end
end

function wnd_warZoneCard:setCardDescScroll(scroll, info)
	local children = scroll:getAllChildren()
	local index = 1
	local color = nil
	for k, v in ipairs(info) do
		local node = children[index] or require(NAME_DESC)()
		node.vars.name:setText(v.name)
		if not children[index] then scroll:addItem(node) end
		local node1 = children[index + 1] or require(ROLE_DESC)()
		if v.color then
			node1.vars.ruleDesc:setTextColor(v.color)
		elseif color then
			node1.vars.ruleDesc:setTextColor(color)
		end
		node1.vars.ruleDesc:setText(v.desc)
		if not children[index + 1] then scroll:addItem(node1) end
		node1.vars.ruleDesc:setRichTextFormatedEventListener(function(sender)
			local textUI = node1.vars.ruleDesc
			local size = node1.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			node1.rootVar:changeSizeInScroll(scroll, width, height, true)
			node1.vars.ruleDesc:setRichTextFormatedEventListener(nil)
		end)
		if not color then
			color = node1.vars.ruleDesc:getTextColor()
		end
		index = index + 2
	end
end

-------sort----------------
function wnd_warZoneCard:getDefaultQualityAndSetFilter(isOnlyBagSort, gotoId)
	local widgets = self._layout.vars
	local info = g_i3k_game_context:GetWarZoneCardInfo()
	local quality = 1
	local id = nil
	if info.card then
		for k,v in pairs(i3k_db_war_zone_map_card) do
			if gotoId then 
				if gotoId == k then
					id = gotoId
					quality = v.grade
					break
				end
			else
				if not isOnlyBagSort then 
					if info.card.inUse[k] then
						if quality < v.grade then
							quality = v.grade
						end
					end
				end
				if info.card.bag[k] then
				  	if not isOnlyBagSort or (isOnlyBagSort and v.buffId ~= 0) then
						if quality <= v.grade then
							quality = v.grade
							id = k
						end
					end
				end
			end
		end
	end
	self.filterQualityType = quality
	widgets.gradeLabel:setText(i3k_get_string(i3k_db_war_zone_map_cfg.cardGrade[quality].gradeDesc))
	return quality, id
end

function wnd_warZoneCard:activatedSort(info)
	local curInfo = {}
	for k,v in pairs(info) do
		local inUse = {}
		inUse.endTime =  v
		inUse.id = k
		table.insert(curInfo, inUse)
	end
	table.sort(curInfo, function (a, b)
		return a.endTime > b.endTime
	end)
	return curInfo
end

function wnd_warZoneCard:bagCardSort(grade)
	local infoSort = {}
	local cfg = clone(i3k_db_war_zone_map_card)
	local info = g_i3k_game_context:GetWarZoneCardInfo()
	local inUse = info.card.inUse
	local bag = info.card.bag
	for k,v in pairs(cfg) do
		if grade == v.grade then
			if bag[k] or inUse[k] then
				if inUse[k] then
					v.sortValue = 10000 + k
				else
					v.sortValue = 1000
				end
			else
				v.sortValue = k
			end
			table.insert(infoSort, v)
		end
			
	end
	table.sort(infoSort, function(a, b)
		return a.sortValue > b.sortValue
	end)
	return infoSort
end
function wnd_warZoneCard:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(5722))
end

function wnd_warZoneCard:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_WarZoneCard)
end

function wnd_create(layout,...)
	local wnd = wnd_warZoneCard.new();
		wnd:create(layout,...)
	return wnd;
end
