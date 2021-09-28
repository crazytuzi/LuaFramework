-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_activity_result = i3k_class("wnd_activity_result",ui.wnd_base)

function wnd_activity_result:ctor()
	self._openTime = 1
	self._costMoneyCount = 0
end

function wnd_activity_result:configure()
	local widget = self._layout.vars
	
	local Bonuspanel = widget.Bonuspanel
	widget.exitbtn:onClick(self,self.onClose)
	
	local widget = self._layout.vars
	self._freeLabel = {widget.free1, widget.free2, widget.free3, widget.free4}
	self._countLabel = {widget.countLabel1, widget.countLabel2, widget.countLabel3, widget.countLabel4}
	
	local widgets = self._layout.vars
	self._lockTable = {widgets.lock1, widgets.lock2, widgets.lock3, widgets.lock4}
	
	
	self._rewardIcon = {}
	self._rewardIcon[1] = self._layout.vars.reward1
	self._rewardIcon[2] = self._layout.vars.reward2
	self._rewardIcon[3] = self._layout.vars.reward3
	self._rewardIcon[4] = self._layout.vars.reward4
	
	self._gradeIcon = {}
	self._gradeIcon[1] = self._layout.vars.gradeIcon1
	self._gradeIcon[2] = self._layout.vars.gradeIcon2
	self._gradeIcon[3] = self._layout.vars.gradeIcon3
	self._gradeIcon[4] = self._layout.vars.gradeIcon4
	
	self._coverCard = {}
	self._coverCard[1] = self._layout.vars.cover1
	self._coverCard[2] = self._layout.vars.cover2
	self._coverCard[3] = self._layout.vars.cover3
	self._coverCard[4] = self._layout.vars.cover4
	
	self._costIcon = {}
	self._costIcon[1] = self._layout.vars.yuanbao1
	self._costIcon[2] = self._layout.vars.yuanbao2
	self._costIcon[3] = self._layout.vars.yuanbao3
	self._costIcon[4] = self._layout.vars.yuanbao4
	
	self._costLabel = {}
	self._costLabel[1] = self._layout.vars.cost1
	self._costLabel[2] = self._layout.vars.cost2
	self._costLabel[3] = self._layout.vars.cost3
	self._costLabel[4] = self._layout.vars.cost4
	
	self._cardBtn = {}
	self._cardBtn[1] = self._layout.vars.card1
	self._cardBtn[2] = self._layout.vars.card2
	self._cardBtn[3] = self._layout.vars.card3
	self._cardBtn[4] = self._layout.vars.card4
	
	self.is_max = self._layout.vars.is_max 
	self.is_max:hide()
end


function wnd_activity_result:onClose(sender)
	i3k_sbean.mapcopy_leave()
end
	
function wnd_activity_result:onShow()
	
end
	
function wnd_activity_result:refresh(rewards, mapId, settlement, process)
	local actId = i3k_db_activity_cfg[mapId].groupId
	self._layout.vars.processRoot:setVisible(not(actId == 1 or actId == 2 or actId == 10))
	local record = g_i3k_game_context:getActMapRecord(actId, mapId)
	if rewards then
		self:reload(rewards, mapId, settlement, process)
	end
	local function callbackfun()
		g_i3k_logic:OpenShiLianUI()
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
	local percent = process/100
	self._layout.vars.percentLabel:setText(percent.."%")
	
	self._layout.vars.timeMax:hide()
	if not record then
		self._layout.vars.percentMax:show()
		--self._layout.vars.timeMax:show()
		self._layout.vars.timeMax:setVisible(process == 10000)
		if process == 10000 then
			g_i3k_game_context:setActMapRecord(actId, mapId,process+settlement.finishTime)
		else
			g_i3k_game_context:setActMapRecord(actId, mapId,process)
		end 
	else
		if record<10000 and process>record then
			self._layout.vars.percentMax:show()
			self._layout.vars.timeMax:setVisible(process == 10000)
			if process == 10000 then
				g_i3k_game_context:setActMapRecord(actId, mapId,process+settlement.finishTime)
			else
				g_i3k_game_context:setActMapRecord(actId, mapId,process)
			end 
		end
		if record>10000 and settlement.finishTime<record-10000 then
			self._layout.vars.timeMax:show()
			g_i3k_game_context:setActMapRecord(actId, mapId,process+settlement.finishTime)
		end
	end
	if actId == 10 then
		self._layout.vars.timeMax:hide()
		self._layout.vars.percentMax:hide()
	end 
	if actId == 1 or actId == 2 then
		self._layout.vars.timeMax:hide()
		self._layout.vars.percentMax:hide()
	end
end


function wnd_activity_result:onHide()
	
end

function wnd_activity_result:openCard(sender, index)
	local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
	if self._openTime<=2 then
		if i3k_db_common.wipe.ingot>diamondCount and self._openTime~=1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(177))
		else
			self._tag = index
			i3k_sbean.commonmap_selectcardReq(self._openTime)
		end
	end
end

function wnd_activity_result:reload(rewards, mapId, settlement, process)
	if settlement then
		local difficultyLabel = self._layout.vars.difficulty
		local finishTimeLabel = self._layout.vars.finishTime
		local deadTimesLabel = self._layout.vars.deadTimes
		local killMonstersLabel = self._layout.vars.killMonsters
		
		local dungeon = i3k_db_activity_cfg[mapId]
		if dungeon then
			local txtID = 1454
			difficultyLabel:setText(i3k_get_string(txtID + dungeon.difficulty))
		end
		finishTimeLabel:setText(settlement.finishTime.."秒")
		deadTimesLabel:setText(settlement.deadTimes.."次")
		killMonstersLabel:setText("x"..settlement.killMonsters)
		local lastCount = g_i3k_game_context:GetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId)
		if i3k_db_activity_cfg[mapId].showMax == 1 and  settlement.killMonsters > lastCount  and lastCount ~= 0 then
			self.is_max:show()
		
		end
		if i3k_db_activity_cfg[mapId].groupId==1 or i3k_db_activity_cfg[mapId].groupId==2 then
			g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,settlement.killMonsters)
		else
			local record = g_i3k_game_context:getActMapRecord(i3k_db_activity_cfg[mapId].groupId, mapId)
			if not record then
				self._layout.vars.percentMax:show()
				self._layout.vars.timeMax:show()
				if process<10000 then
					g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,process)
				else
					g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,process+settlement.finishTime)
				end
			else
				if record<10000 and process>record then
					if process<10000 then
						g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,process)
					else
						g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,process+settlement.finishTime)
					end
				end
				if record>10000 and settlement.finishTime<record-10000 then
					g_i3k_game_context:SetActivityKillMaxCount(i3k_db_activity_cfg[mapId].groupId,mapId,process+settlement.finishTime)
				end
			end
		end
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
	
	--[[local count = 0
	for i,v in ipairs(normalRewards) do
		count = count + 1
	end
	local children = scroll:addChildWithCount("ui/widgets/dj1", count, count)
	for i,v in ipairs(children) do
		local db = g_i3k_db
		local id = normalRewards[i].id
		local path = db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole())
		v.vars.item_icon:setImage(path)
		v.vars.grade_icon:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(id))
		v.vars.item_count:setText(normalRewards[i].count)
	end--]]
	
	for i,v in pairs(self._costIcon) do
		v:hide()
		self._costLabel[i]:hide()
		self._freeLabel[i]:show()
	end
	
end

function wnd_activity_result:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end

function wnd_activity_result:openReward(reward)
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
	
	local cost = i3k_db_common.wipe.ingot
	for i,v in pairs(self._costIcon) do
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
	
	for i,v in pairs(self._rewardIcon) do
		if i==self._tag then
			local path = g_i3k_db.i3k_db_get_common_item_icon_path(reward.id,i3k_game_context:IsFemaleRole())
			self._gradeIcon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(reward.id))
			self._countLabel[i]:setText("x"..i3k_get_num_to_show(reward.count))
			self._lockTable[i]:setVisible(g_i3k_common_item_has_binding_icon(reward.id))
			v:onClick(self, self.onItemTips, reward.id)
			v:setImage(path)
		end
	end
	
	if self._openTime>1 then
		g_i3k_game_context:UseDiamond(i3k_db_common.wipe.ingot, false,AT_ON_SELECT_REWARD_CARD)
	end
	self._openTime = self._openTime+1
end

function wnd_activity_result:openRandom(reward)
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
			v:onClick(self, self.onItemTips, reward.id)
			v:setImage(path)
		end
	end
end

function wnd_activity_result:cantOpen(sender)
	local str
	if self._openTime>2 then
		str = string.format("%s", "仅能翻两张牌")
	else
		str = string.format("%s", "翻牌时间已过，无法继续翻牌")
	end
	g_i3k_ui_mgr:PopupTipMessage(str)
end

function wnd_activity_result:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.daojishi:setText(str)
end

function wnd_create(layout, ...)
	local wnd = wnd_activity_result.new()
		wnd:create(layout, ...)
	return wnd
end
