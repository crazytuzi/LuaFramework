-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_dungeon_bouns = i3k_class("wnd_dungeon_bouns",ui.wnd_base)

function wnd_dungeon_bouns:ctor()
	self._openTime = 1
	self._costMoneyCount = 0
	local endtime = g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime
	local nowtime  = i3k_game_get_time()
	self._superMonthCard = nowtime  < endtime
	self._mapID = 0
end

function wnd_dungeon_bouns:configure()
	local widget = self._layout.vars

	local Bonuspanel = widget.Bonuspanel
	widget.exitbtn:onClick(self,self.onClose)

	local widget = self._layout.vars
	self._freeLabel = {widget.free1, widget.free2, widget.free3, widget.free4}
	self._countLabel = {widget.countLabel1, widget.countLabel2, widget.countLabel3, widget.countLabel4}

	local widgets = self._layout.vars
	self._lockTable = {widgets.lock1, widgets.lock2, widgets.lock3, widgets.lock4}


	self._rewardIcon = {
		self._layout.vars.reward1,
		self._layout.vars.reward2,
		self._layout.vars.reward3,
		self._layout.vars.reward4,
	}

	self._gradeIcon = {
		self._layout.vars.gradeIcon1,
		self._layout.vars.gradeIcon2,
		self._layout.vars.gradeIcon3,
		self._layout.vars.gradeIcon4,
	}

	self._coverCard = {
		self._layout.vars.cover1,
		self._layout.vars.cover2,
		self._layout.vars.cover3,
		self._layout.vars.cover4,
	}

	self._costIcon = {
		self._layout.vars.yuanbao1,
		self._layout.vars.yuanbao2,
		self._layout.vars.yuanbao3,
		self._layout.vars.yuanbao4,
	}

	self._costLabel = {
		self._layout.vars.cost1,
		self._layout.vars.cost2,
		self._layout.vars.cost3,
		self._layout.vars.cost4,
	}

	self._cardBtn = {
		self._layout.vars.card1,
		self._layout.vars.card2,
		self._layout.vars.card3,
		self._layout.vars.card4,
	}
end


function wnd_dungeon_bouns:onClose(sender)
	i3k_sbean.mapcopy_leave()
end

function wnd_dungeon_bouns:refresh(rewards, mapId, settlement)
	self._layout.vars.Bonuspanel:show()
	self._mapID = mapId
	
	if rewards then
		self:reload(rewards, mapId, settlement)
	else

	end
	if settlement.score==3 then
		self._layout.anis.c_bao.play()
	elseif settlement.score==2 then
		self._layout.anis.c_bao2.play()
	else
		self._layout.anis.c_bao3.play()
	end
	local oldMapId = g_i3k_game_context:GetWorldMapID()
	local mapId
	if i3k_db_new_dungeon[oldMapId].openType == g_BASE_DUNGEON then
		mapId = oldMapId
	else
		if g_i3k_db.i3k_db_get_finish_dungeon_id(oldMapId) then
			mapId = i3k_db_new_dungeon[oldMapId+1] and oldMapId + 1 or oldMapId
		else
			mapId = oldMapId
		end
	end
	local callbackfun = function()
		local difficulty = i3k_db_new_dungeon[mapId].difficulty
		if difficulty ~= DUNGEON_DIFF_MASTER then
			difficulty = nil -- 如果不是师徒，那么就保持原有的接口调用方式，传一个空值
		end
		g_i3k_logic:OpenDungeonUI(i3k_db_new_dungeon[mapId].openType == g_BASE_DUNGEON, mapId, difficulty)
	end
	local mId,value = g_i3k_game_context:getMainTaskIdAndVlaue()
	local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
	if main_task_cfg.type == g_TASK_GET_TO_FUBEN or g_TASK_ENTER_FUBEN == main_task_cfg.type then
		if main_task_cfg.arg1 == oldMapId then
			callbackfun = nil
		end
	end
	if callbackfun then
		g_i3k_game_context:SetMapLoadCallBack(callbackfun)
	end
end


function wnd_dungeon_bouns:onHide()
	self._layout.vars.Bonuspanel:hide()
end

function wnd_dungeon_bouns:openCard(sender, index)
	local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
	local isGroup = g_i3k_game_context:refineIsGroupTypeActivity(self._mapID)
	local value = self._superMonthCard and isGroup
	
	if self._openTime<=2 then
		if i3k_db_common.wipe.ingot>diamondCount and self._openTime~=1 and not value then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(177))
		else
			self._tag = index
			i3k_sbean.commonmap_selectcardReq(self._openTime)
		end
	end
end

function wnd_dungeon_bouns:reload(rewards, mapId, settlement)
	if settlement then
		local difficultyLabel = self._layout.vars.difficulty
		local finishTimeLabel = self._layout.vars.finishTime
		local deadTimesLabel = self._layout.vars.deadTimes
		--local killMonstersLabel = self._layout.vars.killMonsters

		local dungeon = i3k_db_new_dungeon[mapId]
		if dungeon then
			local difficult = dungeon.difficulty
			if difficult==0 then
				difficultyLabel:setText("组队")
			elseif difficult==1 then
				difficultyLabel:setText("剧情")
			elseif difficult==2 then
				difficultyLabel:setText("普通")
			elseif difficult==3 then
				difficultyLabel:setText("困难")
			end
		end
		finishTimeLabel:setText(settlement.finishTime.."秒")
		deadTimesLabel:setText(settlement.deadTimes.."次")
	end

	local expLabel = self._layout.vars.expLabel
	local coinLabel = self._layout.vars.coinLabel
	local score = g_i3k_game_context:getDungeonEndSocre(mapId)

	for i,v in pairs(self._cardBtn) do
		v:onClick(self, self.openCard, i)
	end

	local scroll = self._layout.vars.scroll
	scroll:setBounceEnabled(false)
	local width = scroll:getContentSize().width
	local height = scroll:getContentSize().height


	expLabel:setText("+"..rewards.exp)
	coinLabel:setText("+"..rewards.coin)

	local normalRewards = rewards.normalRewards
	local cardRewards = rewards.cardRewards

	local cardRewardIcon = {}

	for i,v in pairs(cardRewards) do
		local path = g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole())
		cardRewardIcon[i] = path
	end
	self._cardRewards = cardRewards
	for i,v in pairs(self._rewardIcon) do
		v:setImage(cardRewardIcon[i])
	end

	for i,v in ipairs(normalRewards) do
		local node = require("ui/widgets/dj1")()
		local db = g_i3k_db
		local id = v.id
		local path = db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole())
		node.vars.item_icon:setImage(path)
		node.vars.grade_icon:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(id))
		node.vars.item_count:setText(v.count)
		node.vars.bt:onClick(self, self.onItemTips, v.id)
		scroll:addItem(node)
	end

	for i,v in pairs(self._costIcon) do
		v:hide()
		self._costLabel[i]:hide()
		self._freeLabel[i]:show()
	end
	self:setAutoSaleEquipLabel(normalRewards)
end

function wnd_dungeon_bouns:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end

function wnd_dungeon_bouns:checkIsEquip(id)
	return math.abs(id) > 10000000
end

-- 只出售蓝绿色的
function wnd_dungeon_bouns:checkEquipRank(id)
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	return rank < 4 -- 小于紫色品质(白 绿 蓝)
end

function wnd_dungeon_bouns:setAutoSaleEquipLabel(rewards)
	local cfg = g_i3k_game_context:GetUserCfg()
	local open = cfg:GetAutoSaleEquip()
	if open then
		local equipPower = 0
		for k, v in ipairs(rewards) do
			if self:checkIsEquip(v.id) and self:checkEquipRank(v.id) then
				local _equip = g_i3k_db.i3k_db_get_equip_item_cfg(v.id)
				local sell = _equip.sellItem * v.count
				equipPower = equipPower + sell
				i3k_log("id = "..v.id.." energy = ".._equip.sellItem .." count = "..v.count)
			end
		end
		local saleDrugStr = ""
		if cfg:GetAutoSaleDrug() then
			saleDrugStr = "\n" .. i3k_get_string(17140)
		end
		self._layout.vars.equipSaleLabel:setText(i3k_get_string(15523, equipPower) .. saleDrugStr)
	else
		if cfg:GetAutoSaleDrug() then
			self._layout.vars.equipSaleLabel:setText(i3k_get_string(17140))
		else
			self._layout.vars.equipSaleLabel:hide()
		end
	end
end

function wnd_dungeon_bouns:openReward(reward)
	for i,v in pairs(self._cardBtn) do
		if i==self._tag then
			local anisLabel = "f"..i
			self._layout.anis[anisLabel].play()

			v:setTouchEnabled(false)
		else
			if self._openTime>2 then
				v:onClick(self, self.cantOpen)
			end
		end
	end
			
	local x = cardRewards
	local cost = i3k_db_common.wipe.ingot
	local isGroup = g_i3k_game_context:refineIsGroupTypeActivity(self._mapID)
	
	for i,v in pairs(self._costIcon) do
		if self._superMonthCard and isGroup then -- 有逍遥卡且是组队本
			self._costLabel[i]:hide()
			v:hide()
			
			if self._openTime < 2 and i ~= self._tag then 
				self._freeLabel[i]:show()
			else
				self._freeLabel[i]:hide()
			end
		else	
			self._freeLabel[i]:hide()
			if self._openTime<2 and i~=self._tag then 
				v:show()
				v:setOpacity(255)
				self._costLabel[i]:show()
				self._costLabel[i]:setText("x"..cost)
			else
				v:hide()
				self._costLabel[i]:hide()
			end
		end
	end

	for i,v in pairs(self._rewardIcon) do
		if i==self._tag then
			local path = g_i3k_db.i3k_db_get_common_item_icon_path(reward.id,i3k_game_context:IsFemaleRole())
			self._gradeIcon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(reward.id))
			self._countLabel[i]:setText("x"..i3k_get_num_to_show(reward.count))
			self._lockTable[i]:setVisible(g_i3k_common_item_has_binding_icon(reward.id))
			v:onClick(self, self.onItemTips,reward.id)
			v:setImage(path)
		end
	end

	if self._openTime > 1 and not (self._superMonthCard and isGroup) then
		g_i3k_game_context:UseDiamond(i3k_db_common.wipe.ingot, false,AT_ON_SELECT_REWARD_CARD)
	end
	
	self._openTime = self._openTime+1
end

function wnd_dungeon_bouns:openRandom(reward)
	local tag = math.random(4)
	for i,v in pairs(self._cardBtn) do
		if i==tag then
			local anisLabel = "f"..tag
			self._layout.anis[anisLabel].play()
			v:setTouchEnabled(false)
		else
			v:onClick(self, self.cantOpen)
		end
	end

	for i,v in pairs(self._costIcon) do
		v:hide()
		self._costLabel[i]:hide()
	end

	for i,v in pairs(self._rewardIcon) do
		if i==tag then
			local path = g_i3k_db.i3k_db_get_common_item_icon_path(reward.id,i3k_game_context:IsFemaleRole())
			self._gradeIcon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(reward.id))
			self._countLabel[i]:setText("x"..i3k_get_num_to_show(reward.count))
			self._lockTable[i]:setVisible(g_i3k_common_item_has_binding_icon(reward.id))
			v:setImage(path)
			v:onClick(self, self.onItemTips,reward.id)
		end
	end
end

function wnd_dungeon_bouns:cantOpen(sender)
	local str
	if self._openTime>2 then
		str = string.format("%s", "仅能翻两张牌")
	else
		str = string.format("%s", "翻牌时间已过，无法继续翻牌")
	end
	g_i3k_ui_mgr:PopupTipMessage(str)
end

function wnd_dungeon_bouns:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.daojishi:setText(str)
end

function wnd_create(layout)
	local wnd = wnd_dungeon_bouns.new()
		wnd:create(layout)
	return wnd
end
