-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist = i3k_class("wnd_taoist", ui.wnd_base)

function wnd_taoist:ctor()
	
end

function wnd_taoist:configure()
	self._maxCount = 0
	self._canFight = true
	local widget = self._layout.vars
	
	local heroWidget = {}
	heroWidget.iconType = widget.iconType
	heroWidget.icon = widget.myIcon
	heroWidget.levelLabel = widget.myLevel
	heroWidget.nameLabel = widget.myName
	heroWidget.expPercent = widget.expPercent
	heroWidget.expLabel = widget.expLabel
	heroWidget.taoistLvlLabel = widget.taoistLvlLabel
	
	local reward = {}
	reward.tipLabel = widget.rewardLabel
	reward.percent = widget.percentLabel
	reward.takeBtn = widget.box
	
	local enemies = {}
	for i=1,5 do
		local role = {}
		role.root = widget["root"..i]
		role.nameLabel = widget["nameLabel"..i]
		role.scoreImg = widget["scoreImg"..i]
		role.levelLabel = widget["levelLabel"..i]
		role.iconType = widget["iconType"..i]
		role.icon = widget["icon"..i]
		role.btn = widget["btn"..i]
		role.winImg = widget["winImg"..i]
		role.zhiyeImg = widget["zhiyeImg"..i]
		enemies[i] = role
	end
	
	self._widgets = {}
	self._widgets.rankBtn = widget.rankBtn
	self._widgets.logBtn = widget.logBtn
	self._widgets.hero = heroWidget
	self._widgets.reward = reward
	self._widgets.enemies = enemies
	
	--人物信息
	local hero = i3k_game_get_player_hero()
	local heroWidget = self._widgets.hero
	heroWidget.nameLabel:setText(hero._name)
	heroWidget.levelLabel:setText(hero._lvl)
	heroWidget.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		heroWidget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	
	widget.logBtn:onClick(self, self.syncLogs)
	widget.rankBtn:onClick(self, self.onRank)
	
	widget.toHelp:onClick(self, self.onHelp)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	
	self._petsCount = 0
end

function wnd_taoist:refresh(info)
	--关于人物信息的协议部分
	local widget = self._widgets.hero
	widget.taoistLvlLabel:setText(info.lvl.."级")
	local lvlMaxExp = 0
	for i,v in ipairs(i3k_db_taoist_level_cfg) do
		lvlMaxExp = lvlMaxExp+v.needExp
		if i==info.lvl and i3k_db_taoist_level_cfg[info.lvl+1] then
			lvlMaxExp = lvlMaxExp + i3k_db_taoist_level_cfg[i+1].needExp
			break
		end
	end
	widget.expLabel:setText(info.exp.."/"..lvlMaxExp)
	widget.expPercent:setPercent(info.exp/lvlMaxExp*100)
	
	
	--奖励部分
	local rewardWidget = self._widgets.reward
	local canGetRewardScore = i3k_db_taoist.needInteral
	rewardWidget.percent:setText(string.format("%d/%d", info.rewardScore, canGetRewardScore))
	rewardWidget.tipLabel:setText(string.format("每得%d分可以领奖", canGetRewardScore))
	--rewardWidget.takeBtn:setVisible(info.rewardScore>=canGetRewardScore)
	rewardWidget.takeBtn:onClick(self, self.takeReward, info)
	
	self._layout.vars.boxAnis:setVisible(info.rewardScore>=canGetRewardScore)
	if info.rewardScore<canGetRewardScore then
		rewardWidget.takeBtn:setTouchEnabled(false)
	end
	
	
	
	--挑战次数以及换一换
	local freeTimes = i3k_db_taoist.freeTimes
	local surplusTimes = freeTimes+info.timeBuyed-info.timeUsed
	self._layout.vars.challengeTimeLabel:setText(surplusTimes.."/"..freeTimes+info.timeBuyed)
	if surplusTimes>0 then
		self._layout.vars.btnName:setText(string.format("换一换"))
		self._layout.vars.refreshBtn:onClick(self, self.refreshEnemies)
		self._refreshTimes = info.dayRefreshTimes
		if self._refreshTimes >= g_MAX_REFRESH_TIMES then
			self._layout.vars.refreshBtn:disableWithChildren()
		end
		self._canFight = true
	else
		self._canFight = false
		self._layout.vars.btnName:setText(string.format("购买"))
		self._layout.vars.refreshBtn:onClick(self, self.addTimes, info)
	end
	if self:calculateTime()~=1 then
		self._layout.vars.refreshBtn:disableWithChildren()
	else
		self._layout.vars.refreshBtn:enableWithChildren()
	end
	
	--设置对手信息
	self:setEnemiesData(info.enemies)
	
	--出战随从
	local count = i3k_db_taoist_level_cfg[#i3k_db_taoist_level_cfg].maxPetsCount
	local scroll = self._layout.vars.scroll
	local petPower = 0
	local pets = {}
	for i,v in pairs(info.pets) do
		table.insert(pets, i)
		petPower = petPower + g_i3k_game_context:getBattlePower(i)
	end
	self._petsCount = #pets
	self._layout.vars.petsPowerLabel:setText(petPower)
	local cfg = i3k_db_taoist_level_cfg[info.lvl]
	self._maxCount = cfg.maxPetsCount
	self._layout.vars.lackLabel:hide()
	for i=1, count do
		local node = require("ui/widgets/zxdct")()
		if i<=#pets then
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(pets[i])
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			node.vars.petRoot:show()
			node.vars.noPetRoot:hide()
			node.vars.noOpenRoot:hide()
		else
			if i<=cfg.maxPetsCount then
				node.vars.petRoot:hide()
				node.vars.noPetRoot:show()
				node.vars.noOpenRoot:hide()
				self._layout.vars.lackLabel:show()
			else
				node.vars.petRoot:hide()
				node.vars.noPetRoot:hide()
				node.vars.noOpenRoot:show()
				for j,v in ipairs(i3k_db_taoist_level_cfg) do
					if v.maxPetsCount==i then
						node.vars.desc:setText(string.format("%d级开放", j))
						break
					end
				end
			end
		end
		scroll:addItem(node)
	end
	
	self._layout.vars.adjustBtn:onClick(self, self.onAdjustPets, info)
end

function wnd_taoist:addRefreshTimes()
	self._refreshTimes = self._refreshTimes + 1
end

function wnd_taoist:setEnemiesData(enemies)--对手相关操作
	if enemies and #enemies~=0 then
		for i,v in ipairs(self._widgets.enemies) do
			if enemies[i] then
				local role = enemies[i].array.role
				local pets = enemies[i].array.pets
				local win = enemies[i].win--1胜利，0失败，-1没打过
				local score = enemies[i].score
				local imgPath = win==0 and g_i3k_db.i3k_db_get_icon_path(1852) or g_i3k_db.i3k_db_get_icon_path(1851)
				v.winImg:setImage(imgPath)
				v.winImg:setVisible(win>=0)
				local scoreImgPath = score==1 and g_i3k_db.i3k_db_get_icon_path(1920) or g_i3k_db.i3k_db_get_icon_path(1921)
				v.scoreImg:setImage(scoreImgPath)
				v.levelLabel:setText(role.level .. "级")
				v.nameLabel:setText(role.name)
				v.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[role.type].classImg))
				v.iconType:setImage(g_i3k_get_head_bg_path(role.bwType, role.headBorder))
				v.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(role.headIcon, false))
				v.btn:setTag(role.id)
				v.btn:onClick(self, self.onEnemyClick, role.name)
				v.root:show()
			else
				v.root:hide()
			end
		end
	end
end

function wnd_taoist:calculateTime()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local openTime = i3k_db_taoist.openTime
	local endTime = i3k_db_taoist.closeTime
	--判断是否在开启时段
	local open = string.split(openTime, ":")
	local close = string.split(endTime, ":")
	local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
	local closeTimeStamp = os.time({year = year, month = month, day = day, hour = close[1], min = close[2], sec = close[3]})
	if closeTimeStamp<=openTimeStamp then
		closeTimeStamp = closeTimeStamp + 24*60*60
	end
	if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
		--当天活动开启状态
		return 1
	elseif timeStamp>closeTimeStamp then
		--当天活动已结束状态
		return 2
	elseif timeStamp<openTimeStamp then
		--当天活动未开启状态
		return 3
	end
end

function wnd_taoist:onEnemyClick(sender, name)
	if self:calculateTime()== 1 then
		if self._canFight then
			if not self._layout.vars.boxAnis:isVisible() then
				local roleId = sender:getTag()
				local desc = string.format("确定挑战"..name.."?")
				local callback = function (isOk)
					if isOk then
						i3k_sbean.taoist_start_fight(roleId, self._petsCount)
					end
				end
				g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15146))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(131))
		end
	else
		--时间不到
		local openTime = i3k_db_taoist.openTime
		local endTime = i3k_db_taoist.closeTime
		openTime = string.sub(openTime, 1, 5)
		endTime = string.sub(endTime, 1, 5)
		local msg = string.format("大侠，正邪道场正在清理昨天的战斗垃圾。\n               %s~%s开放", openTime, endTime)
		g_i3k_ui_mgr:ShowMessageBox1(msg)
	end
end

function wnd_taoist:refreshEnemies(sender)
	if self._refreshTimes >= g_MAX_REFRESH_TIMES then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15162))
		return
	end
	local needDiamond = i3k_db_taoist.refreshDiamond
	local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	if needDiamond<=haveDiamond then
		local desc = i3k_get_string(15145, needDiamond, g_MAX_REFRESH_TIMES - self._refreshTimes)
		local callback = function (isOk)
			if isOk then
				i3k_sbean.refresh_taoist_enemy()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("元宝数量不足，刷新失败"))
	end
end

function wnd_taoist:addTimes(sender, info)
	local needDiamondTable = i3k_db_taoist.buyTimesNeedDiamond
	local needDiamond = info.timeBuyed+1>#needDiamondTable and needDiamondTable[#needDiamondTable] or needDiamondTable[info.timeBuyed+1]
	local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local maxBuyTimes = i3k_db_kungfu_vip[vipLvl].taoistBuyTimes
	local callfunc = function ()
		info.timeBuyed = info.timeBuyed + 1
		g_i3k_game_context:UseDiamond(needDiamond, false,AT_BWARENA_BUY_TIMES)
		self:refresh(info)
	end
	if info.timeBuyed<maxBuyTimes then
		descText = i3k_get_string(15161, needDiamond, maxBuyTimes-info.timeBuyed)
		
		local function callback(isOk)
			if isOk then
				if haveDiamond > needDiamond then
					i3k_sbean.taoist_buy_times(info.timeBuyed+1, callfunc)
				else
					local tips = string.format("%s", "您的元宝不足，购买失败")
					g_i3k_ui_mgr:PopupTipMessage(tips)
				end
			end
		end
		
		g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(148))
	end
	
end

function wnd_taoist:onAdjustPets(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_TaoistPets)
	info.pets = self._infoPets or info.pets
	g_i3k_ui_mgr:RefreshUI(eUIID_TaoistPets, info)
end

function wnd_taoist:refreshFightPets(pets)
	self._petsCount = #pets
	local children = self._layout.vars.scroll:getAllChildren()
	local petPower = 0
	self._layout.vars.lackLabel:hide()
	for i,v in ipairs(children) do
		local node = children[i]
		if i<=#pets then
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(pets[i])
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			node.vars.petRoot:show()
			node.vars.noPetRoot:hide()
			node.vars.noOpenRoot:hide()
			petPower = petPower + g_i3k_game_context:getBattlePower(pets[i])
		else
			if i<=self._maxCount then
				self._layout.vars.lackLabel:show()
				node.vars.noPetRoot:show()
				node.vars.petRoot:hide()
				node.vars.noOpenRoot:hide()
			end
		end
	end
	self._layout.vars.petsPowerLabel:setText(petPower)
	self._infoPets = {}
	for i,v in ipairs(pets) do
		self._infoPets[v] = true
	end
end

function wnd_taoist:syncLogs(sender)
	i3k_sbean.sync_taoist_log()
end

function wnd_taoist:onRank(sender)
	local bwType = g_i3k_game_context:GetTransformBWtype()
	i3k_sbean.sync_taoist_rank(bwType, 0, 10)
end

function wnd_taoist:refreshReward(score, info)
	local rewardWidget = self._widgets.reward
	local canGetRewardScore = i3k_db_taoist.needInteral
	rewardWidget.percent:setText(string.format("%d/%d", score, canGetRewardScore))
	self._layout.vars.boxAnis:setVisible(score>=canGetRewardScore)
	rewardWidget.takeBtn:onClick(self, self.takeReward, info)
	if score<canGetRewardScore then
		rewardWidget.takeBtn:setTouchEnabled(false)
	end
end

function wnd_taoist:takeReward(sender, info)
	local callback = function ()
		local bwType = g_i3k_game_context:GetTransformBWtype()
		local item = {}
		if bwType==1 then
			item.id = i3k_db_taoist_level_cfg[info.lvl].rightItemId
			item.count = i3k_db_taoist_level_cfg[info.lvl].rightItemCount
		else
			item.id = i3k_db_taoist_level_cfg[info.lvl].villainItemId
			item.count = i3k_db_taoist_level_cfg[info.lvl].villainItemCount
		end
		local itemTable = {
			[1] = item
		}
		g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
		local canGetRewardScore = i3k_db_taoist.needInteral
		info.rewardScore = info.rewardScore - canGetRewardScore
		self:refresh(info)
	end
	i3k_sbean.take_taoist_reward(callback)
end

function wnd_taoist:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(15158))
end

function wnd_taoist:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaTaoist)
end

function wnd_create(layout,...)
	local wnd = wnd_taoist.new();
		wnd:create(layout,...)
	return wnd;
end
