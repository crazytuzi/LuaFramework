-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_defend_result = i3k_class("wnd_defend_result",ui.wnd_base)

function wnd_defend_result:ctor()
	self._openTime = 1
	self._costMoneyCount = 0
end

function wnd_defend_result:configure()
	local widget = self._layout.vars
	widget.exitbtn:onClick(self, self.onClose)
	
	self._freeLabel = {widget.free1, widget.free2, widget.free3, widget.free4}
	self._countLabel = {widget.countLabel1, widget.countLabel2, widget.countLabel3, widget.countLabel4}
	self._lockTable = {widget.lock1, widget.lock2, widget.lock3, widget.lock4}
	self._rewardIcon = {widget.reward1, widget.reward2, widget.reward3, widget.reward4}
	self._gradeIcon = {widget.gradeIcon1, widget.gradeIcon2, widget.gradeIcon3, widget.gradeIcon4}
	self._coverCard = {widget.cover1, widget.cover2, widget.cover3, widget.cover4}
	self._costIcon = {widget.yuanbao1, widget.yuanbao2, widget.yuanbao3, widget.yuanbao4}
	self._costLabel = {widget.cost1, widget.cost2, widget.cost3, widget.cost4}
	self._cardBtn = {widget.card1, widget.card2, widget.card3, widget.card4}

	self.is_max = widget.is_max 
	self.is_max:hide()
end


function wnd_defend_result:onClose(sender)
	i3k_sbean.mapcopy_leave()
end
	
function wnd_defend_result:onShow()
	
end
	
function wnd_defend_result:refresh(score, count, useTime, rewards)
	local mapID = g_i3k_game_context:GetWorldMapID()
	self._layout.vars.processRoot:setVisible(false)
	self:reload(score, count, useTime, rewards, mapID)

	self._layout.vars.percentLabel:hide()
	self._layout.vars.timeMax:hide()
	self._layout.vars.show_type:hide()
end

function wnd_defend_result:openCard(sender, index)
	local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
	if self._openTime<=2 then
		if i3k_db_common.wipe.ingot> diamondCount and self._openTime~=1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(177))
		else
			self._tag = index
			local mapID = g_i3k_game_context:GetWorldMapID()
			if i3k_db_homeland_guard_base[mapID] then
				i3k_sbean.commonmap_selectcardReq(self._openTime)--家园守卫战专用翻牌请求
			else
			i3k_sbean.towerdefence_selectcard(self._openTime)
			end
		end
	end
end

function wnd_defend_result:reload(score, count, useTime, rewards, mapID)
	local widget = self._layout.vars

	widget.finishTime:setText(useTime.."秒")
	widget.monsterCount:setText(count.."波")
	if score == -1 then --家园守卫战不显示分数
		widget.show_killMonsters:setVisible(false)
	end
	widget.score:setText(score.."分")
	widget.expLabel:setText("+"..rewards.exp)
	widget.coinLabel:setText("+"..rewards.coin)

	for i, v in pairs(self._cardBtn) do
		v:onClick(self, self.openCard, i)
	end
	local scroll = widget.scroll
	scroll:setBounceEnabled(false)

	local normalRewards = rewards.normalRewards
	local cardRewards = rewards.cardRewards
	--local cfg = i3k_db_defend_cfg[mapID].monsterRewards
	local cardRewardIcon = {}
	for i,v in pairs(cardRewards) do
		local path = g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole())
		cardRewardIcon[i] = path
	end
	self._cardRewards = cardRewards
	for i,v in pairs(self._rewardIcon) do
		v:setImage(cardRewardIcon[i])
	end
	for _,v in ipairs(normalRewards) do
		local node = require("ui/widgets/dj1")()
		local db = g_i3k_db
		local id = v.id
		if v.id ~= 0 then
			local path = db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole())
			node.vars.item_icon:setImage(path)
			node.vars.grade_icon:setImage(db.i3k_db_get_common_item_rank_frame_icon_path(id))
			node.vars.item_count:setText(v.count)
			node.vars.bt:onClick(self, self.onItemTips, v.id)
			scroll:addItem(node)
		end
	end
	for i,v in pairs(self._costIcon) do
		v:hide()
		self._costLabel[i]:hide()
		self._freeLabel[i]:show()
	end
	
end

function wnd_defend_result:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end

function wnd_defend_result:openReward(reward)
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

function wnd_defend_result:openRandom(reward)
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

function wnd_defend_result:cantOpen(sender)
	local str
	if self._openTime>2 then
		str = string.format("%s", "仅能翻两张牌")
	else
		str = string.format("%s", "翻牌时间已过，无法继续翻牌")
	end
	g_i3k_ui_mgr:PopupTipMessage(str)
end

function wnd_defend_result:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.daojishi:setText(str)
end

function wnd_defend_result:onHide()

end

function wnd_create(layout, ...)
	local wnd = wnd_defend_result.new()
		wnd:create(layout, ...)
	return wnd
end
