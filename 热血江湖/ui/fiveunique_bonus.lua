-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------爬塔成功通关

wnd_fiveUnique_bonus = i3k_class("wnd_fiveUnique_bonus",ui.wnd_base)

function wnd_fiveUnique_bonus:ctor()
	self._openTime = 1
	
end

function wnd_fiveUnique_bonus:configure()
	local widget = self._layout.vars
	
	local Bonuspanel = widget.Bonuspanel
	widget.exitbtn2:onClick(self,self.onClose)
	

	self._freeLabel = {widget.free1, widget.free2, widget.free3, widget.free4}
	self._countLabel = {widget.countLabel1, widget.countLabel2, widget.countLabel3, widget.countLabel4}
	

	self._lockTable = {widget.lock1, widget.lock2, widget.lock3, widget.lock4}
	
	widget.show_type:hide()
	widget.show_killMonsters:hide()
	widget.show_deadTimes:hide()
	
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

	self._layout.vars.nextLevel:onClick(self, self.onNextLevelBtnClick)
	self._layout.vars.wujueRoot:show()
	self._layout.vars.normalRoot:hide()
end


function wnd_fiveUnique_bonus:onClose(sender)
	i3k_sbean.mapcopy_leave()
end
	
function wnd_fiveUnique_bonus:onShow()
	
end
	
function wnd_fiveUnique_bonus:refresh(rewards, mapId, settlement)
	
	if rewards then
		self:reload(rewards, mapId, settlement)
	end
	local function callbackfun()
		g_i3k_logic:OpenTowerUI(true)--
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end


function wnd_fiveUnique_bonus:onHide()
	
end

function wnd_fiveUnique_bonus:openCard(sender, index)--手动翻牌协议
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

function wnd_fiveUnique_bonus:reload(rewards, mapId, settlement)
	if settlement then
		--local difficultyLabel = self._layout.vars.difficulty
		local finishTimeLabel = self._layout.vars.finishTime
		--local deadTimesLabel = self._layout.vars.deadTimes
		--local killMonstersLabel = self._layout.vars.killMonsters
		
		finishTimeLabel:setText(settlement.finishTime.."秒")
	end
	
	
	local expLabel = self._layout.vars.expLabel
	local coinLabel = self._layout.vars.coinLabel
	
	

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
	
end
function wnd_fiveUnique_bonus:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end
----手动翻牌协议成功后改变状态
function wnd_fiveUnique_bonus:openReward(reward)
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
			self._countLabel[i]:setText("x"..reward.count)
			self._lockTable[i]:setVisible(g_i3k_common_item_has_binding_icon(reward.id))
			v:setImage(path)
		end
	end
	
	if self._openTime>1 then
		g_i3k_game_context:UseDiamond(i3k_db_common.wipe.ingot, false,AT_ON_SELECT_REWARD_CARD)
	end
	self._openTime = self._openTime+1
end

---自动翻牌成功后改变状态
function wnd_fiveUnique_bonus:openRandom(reward)
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
			self._countLabel[i]:setText("x"..reward.count)
			self._lockTable[i]:setVisible(g_i3k_common_item_has_binding_icon(reward.id))
			v:setImage(path)
		end
	end
end

function wnd_fiveUnique_bonus:cantOpen(sender)
	local str
	if self._openTime>2 then
		str = string.format("%s", "仅能翻两张牌")
	else
		str = string.format("%s", "翻牌时间已过，无法继续翻牌")
	end
	g_i3k_ui_mgr:PopupTipMessage(str)
end

function wnd_fiveUnique_bonus:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.daojishi:setText(str)
end

function wnd_fiveUnique_bonus:onNextLevelBtnClick(sender)
	local syncTowerFunc = function(groupId, data)
		local user_cfg = g_i3k_game_context:GetUserCfg()
		local level = user_cfg:GetSelectFiveUniqueLevel() + 1
		local fbCfg = i3k_db_climbing_tower_datas[groupId][level]
		if fbCfg then
			local fbId = fbCfg.fbID
			local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()
			local havetimes = i3k_db_climbing_tower_args.maxattackTimes - data.dayTimesUsed + timeBuy
			local fb2Cfg = i3k_db_climbing_tower_fb[fbId]
			local needVit= fb2Cfg.enterConsume
			local needForce = fb2Cfg.powerNeed
			local needLvl = fb2Cfg.enterLvl
			local vit = g_i3k_game_context:GetVit()
			local starActivity = function()
				local function func()
					g_i3k_game_context:ClearFindWayStatus()
					local user_cfg = g_i3k_game_context:GetUserCfg()
					local index = user_cfg:GetSelectFiveUnique()
					i3k_sbean.startfight_tower_activities(level,groupId,fbId,index)
				end
				g_i3k_game_context:CheckMulHorse(func)
			end

			local fightFunc = function()
				g_i3k_game_context:SetMapLoadCallBack(nil)--跳下一关不打开主界面
				i3k_sbean.mapcopy_leave(eUIID_Activity, starActivity)
				g_i3k_ui_mgr:CloseUI(eUIID_FiveUniqueBonus)
			end

			if g_i3k_game_context:GetLevel() < needLvl then
				g_i3k_ui_mgr:PopupTipMessage("等级不足")
				return
			elseif g_i3k_game_context:GetRolePower() < needForce then
				g_i3k_ui_mgr:PopupTipMessage("战力不足")
				return
			elseif vit < needVit then
				g_i3k_ui_mgr:PopupTipMessage("体力不足")
				return
			elseif havetimes<=0 then
				local maxBuyTimes = #i3k_db_climbing_tower_args.needGold
				local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()----
				local haveTimes = totalTimes - i3k_db_climbing_tower_args.maxattackTimes--剩余次数
				local canBuyTimes = maxBuyTimes - timeBuy  --可购买的次数
				if canBuyTimes>0 then
					local buyTimeCfg = i3k_db_climbing_tower_args.needGold
					local needDiamond = buyTimeCfg[timeBuy+1]
					if not needDiamond then
						needDiamond = buyTimeCfg[#buyTimeCfg]
					end
					local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)--绑定
					if have == 0 then
						descText = string.format("是否花费<c=green>%d元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, canBuyTimes)
					elseif have < needDiamond then
						descText = string.format("是否花费<c=green>%d绑定元宝</c>、<c=green>%d元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次",have, needDiamond-have, canBuyTimes)
					else
						descText = string.format("是否花费<c=green>%d绑定元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, canBuyTimes)
					end
					local function callback(isOk)
						if isOk then
							local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
							if haveDiamond > needDiamond then
								i3k_sbean.set_tower_buytimes(timeBuy+1,needDiamond,nil,level,fightFunc)
							else
								local tips = string.format("%s", "您的元宝不足，购买失败")
								g_i3k_ui_mgr:PopupTipMessage(tips)
							end
						else
						end
					end
					g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(514))
				end
			elseif vit >= needVit then
				fightFunc()
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("五绝试炼已达最大层数，请退出重新选层")
		end
	end
	i3k_sbean.sync_activities_tower(nil, nil, syncTowerFunc, true)
end

function wnd_create(layout, ...)
	local wnd = wnd_fiveUnique_bonus.new()
		wnd:create(layout, ...)
	return wnd
end
