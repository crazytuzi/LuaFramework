-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")
require("ui/ui_funcs")

-------------------------------------------------------

wnd_offline_exp = i3k_class("wnd_offline_exp",ui.wnd_base)

local LXSYT_WIDGET = "ui/widgets/lxsyt"
local RowitemCount = 5
local WIZARD_WIDGET = "ui/widgets/lxsyt2"
local WIZARD_HEAD = "ui/widgets/lxsyt3"
local TITLE_ICON = {3007, 3008}
local SHOW_TIME = 2 --tips显示时间
local COLOR1 = "ffff0000" -- 红色
local COLOR2 = "ff008000"	--绿色
local isBuySpirit = false;
local isFight = false;
local isAdditionType = 2 --求取礼物

local LIUDAOXIANGMO_ID = 12 --六道降魔杵ID
local LIUDAOZANG_ID = 7 --六道藏ID

function wnd_offline_exp:ctor()
	self.offlineTime = 0
	self.liziTb = {}
	self.addTime = 0
	self.doubleTime = 0
	self.isChange = false
	self.oldPercent = 0
	self.curPercent = 0
	self.curExp = 0
	self.lastExp = 0
	self.maxOfflineExp = 0
	self.needPoint = 0
	self.singlePercent = 0
	self.doublePercent = 0
	self._type = 1
	self.record_time = 0 --记录时间
	self._selectIdx = 1
	self._giftData = nil;
	self._wishTime = nil;
	self._isStartCount = false;
	self._giftWizardData = nil;
	self._targetPos = 0
	self._targetMapId = 0
	self._monsterID = 0
end

function wnd_offline_exp:configure()
	local widgets = self._layout.vars
	self.titleImg = widgets.titleImg
	widgets.closeBtn:onClick(self, self.onCloseUI)
	
	-- 离线经验
	self.expUI = widgets.expUI
	self.expRed	= widgets.expRed
	self.timeTotal = widgets.timeTotal
	self.expValue = widgets.expValue
	self.expPercentage = widgets.expPercentage	
	self.curOfflineExp = widgets.curOfflineExp
	self.roleLevel = widgets.roleLevel
	self.monsterDesc = widgets.monsterDesc
	self.scroll = widgets.scroll
	self.itemIcon = widgets.itemIcon
	self.pointIcon = widgets.pointIcon
	self.singleBar = widgets.singleBar
	self.doubleBar = widgets.doubleBar
	self.singleBtn = widgets.singleBtn
	self.doubleBtn = widgets.doubleBtn
	widgets.addPoint:onClick(self, self.onAddPoint)
	self.diamondCount = widgets.diamondCount
	self.c_guang = self._layout.anis.c_guang
	
	self.singleLizi = widgets.singleLizi
	self.doubleLizi = widgets.doubleLizi
	
	for i = 1, 6 do
		local lizi = string.format("lizi%s", i)
		table.insert(self.liziTb, widgets[lizi])
	end 
	
	widgets.singleBtn:onClick(self, self.onSingle)
	widgets.doubleBtn:onClick(self, self.onDouble)
	
	-- 挂机精灵
	self.wizardUI = widgets.wizardUI
	self.wizardRed = widgets.wizardRed
	self.wizardLvl = widgets.wizardLvl
	self.wizardPoint = widgets.wizardPoint
	self.wizardBtn = widgets.wizardBtn
	self.wizardScroll = widgets.wizardScroll
	self.wizardModel = widgets.wizardModel
	self.maxPoint = widgets.maxPoint
	self.coinAddition = widgets.coinAddition
	self.expAddition = widgets.expAddition
	self.dropAddition = widgets.dropAddition
	self.battleLabel = widgets.battleLabel
	self.battleBtn	= widgets.battleBtn
	self.headScroll = widgets.headScroll
	self.renewBtn = widgets.renewBtn
	self.name     = widgets.name
	self.validTime = widgets.validTime
	self.maopao = widgets.maopao
	self.buyBtn = widgets.buyBtn
	self.additionDesc = widgets.additionDesc
	self.mark = widgets.mark
	self.markImg = widgets.markImg
    self.buyExp_btn = widgets.buyExp_btn
	self.photoBtn = widgets.photoBtn
	self.tripBtn = widgets.tripBtn
	self.tripTitle = widgets.tripTitle
	
	self.typeButton = {widgets.expBtn, widgets.wizardBtn}
	self.typeButton[1]:stateToPressed()
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onTypeChanged, i)
	end
	widgets.helpBtn:onClick(self, self.onHelp)
	widgets.battleBtn:onClick(self, self.onBattle);
	widgets.renewBtn:onClick(self, self.onRenew);
	widgets.buyBtn:onClick(self, self.onBuy);
	widgets.tripBtn:onClick(self, self.onTrip);
	widgets.photoBtn:onClick(self, self.onPhoto);
	widgets.gotoBt:onClick(self, self.onGotoBtClick);
	
	self.getGiftTimes = widgets.getGiftTimes
	self.getGiftBtn = widgets.getGiftBtn;
	self.getGiftIcon = widgets.getGiftIcon;
	self.getGiftCount = widgets.getGiftCount;
	self.getGiftRed = widgets.getGiftRed;
	widgets.hideOfflineBtn:onClick(self, self.onHideOfflineBtnClick)
	self:updateOfflineExpState()
end

function wnd_offline_exp:refresh(isWizardUI)
	i3k_sbean.wizardWishSync()
	if isWizardUI then
		self:onTypeChanged(nil, 2)  --打开挂机精灵界面
	else
		self:updateExpRed()
		self:updateExpUI()
	end
end

function wnd_offline_exp:onTypeChanged(sender, tag)
	--if self._type ~= tag then
	self._type = tag
	self:updateBtnState()
	if tag == 1 then --离线经验
		self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(TITLE_ICON[1]))
		self:updateExpUI()
	else
		self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(TITLE_ICON[2]))
		self:updateWizardUI()
	end
	--end
end

function wnd_offline_exp:updateBtnState()
	for _, e in ipairs(self.typeButton) do
		e:stateToNormal()
	end
	self.typeButton[self._type]:stateToPressed()
end

function wnd_offline_exp:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(816))
end

-----------------------------------------------------------
--local function 离线经验
function wnd_offline_exp:updateExpUI()
	self.expUI:show()
	self.wizardUI:hide()
	self:updateLabel()
	self:updateData()
end

function wnd_offline_exp:onOfflineExpChanged()
	if self._type == 1 then
		self:updateExpUI()
	end
end

function wnd_offline_exp:onAddPoint(sender)
	g_i3k_logic:OpenBuyWizardPointUI()
end

function wnd_offline_exp:updateExpRed()
	local info = g_i3k_game_context:GetOfflineExpData()
	local pushMinTime = i3k_db_offline_exp.pushMinTime
	self.expRed:setVisible(info.accTimeTotal ~= 0)
end

function wnd_offline_exp:updateLabel()
	self.maxOfflineExp = g_i3k_db.i3k_db_get_offline_max_exp()
	local info = g_i3k_game_context:GetOfflineExpData()
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	self.offlineTime = info.accTimeTotal
	self.lastExp = self.curExp
	self.curExp = info.dailyOfflineExp
	self.timeTotal:setText(self:getTime(self.offlineTime))
	self.expValue:setText(info.accExpTotal)
	self.curOfflineExp:setText(self.curExp)
	self.needPoint = math.ceil(i3k_db_offline_exp.needDiamond * self.offlineTime)
	self.diamondCount:setText("x"..self.needPoint)
	local roleLvl = g_i3k_game_context:GetLevel()
	self.roleLevel:setText(roleLvl)
	self._monsterID = i3k_db_offline_exp.fairyMonster[roleLvl].monsterID
	self.monsterDesc:setText(g_i3k_db.i3k_db_get_monster_name(self._monsterID))
	self._targetPos = g_i3k_db.i3k_db_get_monster_pos(self._monsterID)
	self._targetMapId = g_i3k_db.i3k_db_get_monster_map_id(self._monsterID)
	self.pointIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_OFFLINE_POINT,i3k_game_context:IsFemaleRole()))
	self.wizardPoint:setText(wizardData.funcPoint)
	self:updateItems(info.accDrops)
	self.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_OFFLINE_POINT,i3k_game_context:IsFemaleRole()))
end

function wnd_offline_exp:updateData()
	if self.offlineTime == 0 then
		self.singleBtn:disableWithChildren()
		self.doubleBtn:disableWithChildren()
	else
		self.singleBtn:enableWithChildren()
		self.doubleBtn:enableWithChildren()
	end
	self.isChange = true
end

function wnd_offline_exp:updateItems(itemsData)
	self.scroll:removeAllChildren()
	local all_layer = self.scroll:addChildWithCount(LXSYT_WIDGET, RowitemCount, #itemsData)
	for i, e in ipairs(itemsData) do
		local widget = all_layer[i].vars
		local id = e.id
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.item_count:setText("x"..e.count)
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.item_btn:onClick(self, self.onItemInfo, id)
	end
	if #itemsData <= RowitemCount then
		self.scroll:stateToNoSlip()
	else
		self.scroll:stateToSlip()
	end
end

function wnd_offline_exp:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_offline_exp:updateExpBar(curExp)
	local percent = 0
	if curExp > self.maxOfflineExp then
		self:setLoadBar(true)
		local secendExp = curExp - self.maxOfflineExp
		self.singleBar:setPercent(100)
		self.doubleBar:setPercent(secendExp / self.maxOfflineExp * 100)
		percent = secendExp / self.maxOfflineExp * 100
		self.singlePercent = 100
		self.doublePercent = percent
	else
		self:setLoadBar(false)
		self.singleBar:setPercent(curExp / self.maxOfflineExp * 100)
		self.doubleBar:setPercent(0)
		percent = curExp / self.maxOfflineExp * 100
		self.singlePercent = percent
		self.doublePercent = 0
	end
	self.oldPercent = self.curPercent
	self.curPercent = percent
end

function wnd_offline_exp:setLoadBar(isDouble)
	self.singleBar:setHeadAnis(self.singleLizi)
	self.doubleBar:setHeadAnis(self.doubleLizi)
end

function wnd_offline_exp:setSingleParticle(percent)
	local radius = 95  -- 半径
	local deltY = (50 - percent) / 50 * radius
	local x = percent < 50 and 2 * radius * percent / 100 or 2 * radius *(1 - percent / 100)
	local lengthX = math.sqrt(x * (2 * radius - x))
	lengthX = (percent < 10 or percent > 80) and lengthX * 0.78 - 5 or lengthX--]]
	self.singleLizi:setVisible((percent > 1 and percent < 99) and true or false)
	for i=1, 3 do
		if i == 3 then
			self.liziTb[i].ccNode_._nodeEff:setPosVar({x = lengthX, y = 1})
		else
			self.liziTb[i].ccNode_._nodeEff:setPosVar({x = lengthX, y = 2})
		end
	end
end

function wnd_offline_exp:setDoubleParticle(percent)
	local radius = 95  -- 半径
	local deltY = (50 - percent) / 50 * radius
	local x = percent < 50 and 2 * radius * percent / 100 or 2 * radius *(1 - percent / 100)
	local lengthX = math.sqrt(x * (2 * radius - x))
	lengthX = (percent < 10 or percent > 80) and lengthX * 0.78 - 5 or lengthX
	self.doubleLizi:setVisible((percent > 1 and percent < 99) and true or false)
	for i=4, 6 do
		if i == 6 then
			self.liziTb[i].ccNode_._nodeEff:setPosVar({x = lengthX, y = 1})
		else
			self.liziTb[i].ccNode_._nodeEff:setPosVar({x = lengthX, y = 2})
		end
	end
end

function wnd_offline_exp:onUpdate(dTime)
	local time = i3k_game_get_time() - self.record_time;
	if self.record_time and self.record_time ~= 0 and time >  SHOW_TIME then
		self.maopao:hide()
	end
	if self.isChange then
		self.addTime = self.addTime + dTime
		if self.addTime < 1 then
			local exp = (self.curExp - self.lastExp) * self.addTime + self.lastExp
			self:updateExpBar(exp)
			if self.doublePercent == 0 then
				local percent = (self.curPercent - self.oldPercent) * self.addTime + self.oldPercent
				self:setSingleParticle(percent)
				self.doubleTime = self.addTime
			else
				local ratio = (1 - self.addTime)/ (1 - self.doubleTime)
				local percent = (self.curPercent - self.oldPercent) * ratio + self.oldPercent
				self:setDoubleParticle(percent)
			end
		else
			self:updateExpBar(self.curExp)
			self:setSingleParticle(self.singlePercent)
			self:setDoubleParticle(self.doublePercent)
			self.addTime = 0
			self.isChange = false
		end
	end
	if self._isStartCount and self._giftWizardData then
		if self._giftData and self._giftData[self._giftWizardData.id] and self._giftData[self._giftWizardData.id].lastAddTime then
			local tiem = self._giftWizardData.arg3 - (i3k_game_get_time() - self._giftData[self._giftWizardData.id].lastAddTime)
			if tiem == 0 then
				i3k_sbean.wizardWishSync();
				self._isStartCount = false;
			end
			if self._selectIdx == self._giftWizardData.id then
				self.getGiftTimes:show():setText(self:GetTime(tiem))
			else
				self.getGiftTimes:hide();
			end
		end
	end
	--[[local tripTime = g_i3k_game_context:getTripTime();
	if tripTime and tripTime > 0 then
		self.getGiftTimes:show():setText(self:GetTime(tripTime))
	else
		self.getGiftTimes:hide();
	end--]]
end

function wnd_offline_exp:playAnimation()
	local delay = cc.DelayTime:create(0.5)--序列动作 动画播了0.5秒后开始刷新进度条动画
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self.c_guang.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateExpUI()
	end))
	self:runAction(seq)
end

function wnd_offline_exp:onSingle(sender)
	local info = g_i3k_game_context:GetOfflineExpData()
	local items = {}
	for i, e in ipairs(info.accDrops) do
		items[e.id] = e.count
	end
	if g_i3k_game_context:IsBagEnough(items) then
		i3k_sbean.offlineexp_take(self.offlineTime, 0)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

function wnd_offline_exp:onDouble(sender)
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	if wizardData.funcPoint >= self.needPoint then
		local fun = (function(ok)
			if ok then
				i3k_sbean.offlineexp_take(self.offlineTime, 1, self.needPoint)
			end
		end)
		local desc = i3k_get_string(386, self.needPoint.."修炼点")
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		local fun = (function(ok)
			if ok then
				g_i3k_logic:OpenBuyWizardPointUI()
			end
		end)
		local desc = i3k_get_string(385)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	end
end

function wnd_offline_exp:getTime(t)
	local hour = math.modf(t/60)
	local minute = math.modf(t-60*hour)
	if hour < 10 then
		hour = string.format("0%s",hour)
	end
	if minute < 10 then
		minute = string.format("0%s",minute)
	end
	return string.format("%s小时%s分钟", hour, minute)
end

---------------------------离线精灵----------------------------------------
function wnd_offline_exp:getDays(t)
	local timeTick  = i3k_game_get_time();
	local time = nil;
	if t then
		time = t - timeTick;
	end
	local days = math.ceil(math.max(0, (time/(24*3600)))); --/(24*3600)
	if days then
		return days
	end

	return 0;
end

function wnd_offline_exp:onBattle(sender)
	local wizardId = g_i3k_game_context:GetCurWizard()
	if self:isTripWizard() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17069))
		return false;
	end
	if wizardId and self._selectIdx ~= wizardId then
		g_i3k_game_context:SetCurWizard(self._selectIdx)
		g_i3k_game_context:CreateWizar(self._selectIdx)
		i3k_sbean.setCurWizardID(self._selectIdx)
	end
end

function wnd_offline_exp:tripTip()
	local tip = nil;
	if g_i3k_game_context:GetCurWizard() == self._selectIdx then
		tip = 17070
	elseif self:isTripWizard() then
		tip = 17071
	elseif g_i3k_game_context:getCurrTripWizard() and g_i3k_game_context:getCurrTripWizard() > 0 then
		tip = 17072
	end
	if tip then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(tip))
		return true;
	end
	return false;
end

function wnd_offline_exp:onTrip(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardItem) and not self:tripTip() then
		g_i3k_ui_mgr:OpenUI(eUIID_TripWizardItem)
		g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardItem, self._selectIdx)
	end
end

function wnd_offline_exp:onPhoto(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardPhotoAlbum) then
		g_i3k_ui_mgr:OpenUI(eUIID_TripWizardPhotoAlbum)
		g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardPhotoAlbum, self._selectIdx)
	end
end

function wnd_offline_exp:onRenew(sender)
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	local wizardTime = wizardData.wizardEndTimes[self._selectIdx] or 0;
	if wizardTime ~= -1 then
		local cfg = i3k_db_arder_pet[self._selectIdx]
		if cfg and cfg.replaceItemId ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_BuyChannelSpiritOther)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyChannelSpiritOther, "updateBuySpiritUI", self._selectIdx);
		else
			g_i3k_ui_mgr:OpenUI(eUIID_BuyChannelSpirit)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyChannelSpirit, "updateBuySpiritUI", self._selectIdx);
		end
	end
end

function wnd_offline_exp:onBuy(sender)
	isBuySpirit = true;
	local cfg = i3k_db_arder_pet[self._selectIdx]
	if cfg and cfg.replaceItemId ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_BuyChannelSpiritOther)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyChannelSpiritOther, "updateBuySpiritUI", self._selectIdx);
	else
		g_i3k_ui_mgr:OpenUI(eUIID_BuyChannelSpirit)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyChannelSpirit, "updateBuySpiritUI", self._selectIdx);
	end
end
--离线精灵UI
function wnd_offline_exp:updateWizardUI()
	self.expUI:hide()
	self.wizardUI:show()
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	local level = wizardData.level
	self.wizardLvl:setText(level)
	self.maxPoint:setText(i3k_db_offline_exp.maxPoint)
	local wipeCfg = i3k_db_activity_wipe[level]
	self.coinAddition:setText(wipeCfg.coinArgs/10000 * 100 .."%")
	self.expAddition:setText(wipeCfg.offlineArgs/10000 * 100 .."%")
	self.dropAddition:setText(wipeCfg.dropArgs/10000 * 100 .."%")
	self:updateWizardScroll(wipeCfg.groupIds)
	self:updateHeadScroll();
	self:updateBarPercent(level, wizardData.exp)
	local curWizardData = i3k_db_arder_pet[wizardData.curWizard];
	if curWizardData and curWizardData.modelID then
		self.record_time = i3k_game_get_time();
		self.maopao:show();
		ui_set_hero_model(self.wizardModel, curWizardData.modelID)
		self._selectIdx = wizardData.curWizard
		self.name:setText(i3k_get_string(959,curWizardData.name));
		self:ShowWizardDays()
		self:updateLeftState()
		self:updateAdditionDesc(curWizardData)
	end
	local info ={lvl = level, exp = wizardData.exp}
	self.buyExp_btn:onClick(self, self.openBuyExpUI, info)
end

function wnd_offline_exp:updateHeadScroll()
	local data = {}
	local channel = i3k_game_get_channel_name();
	local curWizard = g_i3k_game_context:GetOfflineWizardData();
	for i, e in pairs(i3k_db_arder_pet) do	
		if (e.canUseChannel[1] == tonumber(channel)) or (e.canUseChannel[1] == 0)  then
			if e.isShow == 1 then  --显示精灵
				table.insert(data, {id = i, cfg = e})
			end
		end
	end
	table.sort(data,function(a,b)
		return a.id < b.id
	end)
	self.headScroll:removeAllChildren()
	for i, e in ipairs(data) do
		if e ~= 0 then
			local _layer = require(WIZARD_HEAD)()
			_layer.vars.effect:hide();
			_layer.vars.headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(e.cfg.icon))
			_layer.vars.fightIcon:hide();
			_layer.vars.trip:hide();
			
			if self:isGiftTypeWizard(e.cfg) then
				_layer.vars.red:setVisible(self:isHaveWishTimes())
			end	
			_layer.id = e.id
			_layer.vars.headBtn:onClick(self, self.changeWizardModel, e)
			local wizardEndTime = curWizard.wizardEndTimes[e.cfg.id] or 0
			local timeTick = i3k_game_get_time()
			local leftTime = wizardEndTime - timeTick
			if wizardEndTime == -1 or leftTime > 0 then
				_layer.vars.headIcon:enableWithChildren()
			else
				_layer.vars.headIcon:disableWithChildren()
			end
			self.headScroll:stateToSlip()
			self.headScroll:addItem(_layer)
		end
	end
end

function wnd_offline_exp:changeWizardModel(sender, data)	
	if self._selectIdx ~= data.id then
		self._selectIdx = data.id
		self.record_time = i3k_game_get_time();
		self.maopao:show();
		self.name:setText(i3k_get_string(959,data.cfg.name));
		ui_set_hero_model(self.wizardModel, data.cfg.modelID)
		self:ShowWizardDays()
		self:updateLeftState()
		self:updateAdditionDesc(data.cfg)
		self:udpateTripTitle();
	end
end

function wnd_offline_exp:isTripWizard()
	if g_i3k_game_context:getCurrTripWizard() == self._selectIdx then
		return true
	end
	return false;
end

function wnd_offline_exp:udpateTripTitle()
	if self:isTripWizard() then
		self.tripTitle:show()
		self.wizardModel:hide()
	else
		self.tripTitle:hide()
		self.wizardModel:show()
	end
end

function wnd_offline_exp:ShowWizardDays()
	self.buyBtn:hide()
	self.validTime:show();
	self.battleBtn:show();
	self.tripBtn:hide()
	self.photoBtn:hide()
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	local wizardEndTime = wizardData.wizardEndTimes[self._selectIdx] or 0;
	local timeTick = i3k_game_get_time()
	local leftTime = wizardEndTime - timeTick
	local allHeadLayer = self.headScroll:getAllChildren()
	for i, e in ipairs(allHeadLayer) do
		if self._selectIdx == e.id and leftTime > 0 then
			e.vars.headIcon:enableWithChildren()
		end
	end
	if wizardEndTime == -1 or leftTime > 0 then
		local cfg = i3k_db_arder_pet[self._selectIdx];
		if cfg and cfg.isTrip > 0 then
			self.tripBtn:show()
			self.photoBtn:show()
		end
	end
	if wizardEndTime == -1  then
		self.validTime:setText(i3k_get_string(960));
	elseif leftTime > 0 then
		self.validTime:setText(i3k_get_string(961,self:getDays(wizardEndTime)))
	else
		self.validTime:hide();
		self.battleBtn:hide();
		self.buyBtn:show()
	end
end

function wnd_offline_exp:updateLeftState(isbattle)
	local allHeadLayer = self.headScroll:getAllChildren()
	local curWizardData = g_i3k_game_context:GetOfflineWizardData();
	local curTripWizard = g_i3k_game_context:getCurrTripWizard();
	for i, e in ipairs(allHeadLayer) do
		e.vars.fightIcon:setVisible(curWizardData.curWizard == e.id)
		e.vars.effect:setVisible(self._selectIdx == e.id)
		e.vars.trip:setVisible(curTripWizard == e.id)
	end
	self:updateBattleBtn(isbattle);
	self:updateMarkState(isbattle)
end

function wnd_offline_exp:updateBattleBtn(isbattle)
	local wizardId = g_i3k_game_context:GetCurWizard()
	if isbattle or self._selectIdx == wizardId then
		self.battleLabel:setText(i3k_get_string(963));
		self.battleBtn:disableWithChildren();
	elseif self._selectIdx ~= wizardId then
		self.battleLabel:setText(i3k_get_string(964));
		self.battleBtn:enableWithChildren();
	end
end

function wnd_offline_exp:wizardGiftData(giftData)
	self._giftData = giftData;
	self.wizardRed:setVisible(self:isHaveWishTimes())
	self:showWishTime()
	self:updateHeadScroll()
	self:updateLeftState()
	if not self:isHaveWishTimes() then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_REWARD_WIZARD_GIFT)
	end
end

function wnd_offline_exp:isGiftTypeWizard(data)
	if data and data.isAddition > 0 then 
		local wizardData = g_i3k_game_context:GetOfflineWizardData()
		local wizardEndTime = wizardData.wizardEndTimes[data.id] or 0;
		if data.isAddition == isAdditionType then
			if wizardEndTime == -1 then
				return true;
			end
		end
	end
	return false;
end

function wnd_offline_exp:isHaveWishTimes()
	if self._giftData then
		for k,v in pairs(self._giftData) do
			if v.wishTime > 0 then
				return true;
			end
		end
	end
	return false;
end

function wnd_offline_exp:updateAdditionDesc(data)
	self.mark:hide()
	self.additionDesc:hide()
	self.getGiftIcon:hide();
	self.getGiftBtn:hide();
	self.getGiftTimes:hide();
	self.getGiftRed:hide();
	if data and data.isAddition > 0 then 
		if self:isGiftTypeWizard(data) then
			self._giftWizardData = data;
			self.getGiftBtn:onClick(self, self.onGetGift, data.id);
			if self._giftData and self._giftData[data.id] then
				self._wishTime = self._giftData[data.id].wishTime;
			end
			self:showWishTime();
		else
			self.mark:show()
			self.additionDesc:show()
			local textDesc = ""
			if data.id == LIUDAOZANG_ID then --六道藏文字特殊处理
				local upValue = 0
				local para1 = i3k_db_arder_pet[data.id].arg1 / 100
				local para2 = i3k_db_arder_pet[data.id].arg2
				local para3 = i3k_db_arder_pet[data.id].arg3 / 100
				if g_i3k_game_context:IsShenBingAwake(LIUDAOXIANGMO_ID) then
					upValue = upValue + i3k_db_arder_pet[data.id].arg5 / 100 * #i3k_db_shen_bing_awake[data.id].showSkills
				end
				textDesc = i3k_get_string(1773, para1 + upValue, para2, para3 + upValue)
			else
				textDesc = data.desc
			end
			self.additionDesc:setText(textDesc)
		end
	end
end

function wnd_offline_exp:showWishTime()
	if self._giftWizardData and self._selectIdx == self._giftWizardData.id then
		if self._giftWizardData and self._giftData and self._giftData[self._giftWizardData.id] then
			self._wishTime = self._giftData[self._giftWizardData.id].wishTime;
			if self._wishTime and self._wishTime > 0 then
				self._isStartCount = false;
				self.getGiftRed:show();
				self.getGiftBtn:show():enable();
				self.getGiftTimes:show():setText("剩余次数："..self._wishTime);
				if self._wishTime and self._wishTime > 0 and next(self._giftData[self._giftWizardData.id].selectItem) == nil then
					self.getGiftIcon:show():setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._giftWizardData.arg1,i3k_game_context:IsFemaleRole()))
					self.getGiftCount:setText("x"..self._giftWizardData.arg2)
				end
			else
				self.getGiftRed:hide();
				self.getGiftIcon:hide();
				self._isStartCount = true;
				self.getGiftBtn:show():disable();
			end
		end
	end
end

function wnd_offline_exp:GetTime(time)
	local hour = math.modf(time/(60*60))
	local minite = math.modf((time - hour*60*60)/60)
	local sec = math.modf((time - hour*60*60 - minite *60))
	if hour > 0 then
		return string.format("%d:%d:%d",hour,minite,sec)
	else
		return string.format("%d:%d",minite,sec)
	end
end

function wnd_offline_exp:wizardGiftCount()
	if self._wishTime and self._wishTime > 0 then
		self._wishTime = self._wishTime - 1;
		self.getGiftTimes:setText("剩余次数："..self._wishTime);
	end
end

function wnd_offline_exp:isCanReset(petId)
	local petData = i3k_db_arder_pet[petId];
	local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(petData.arg1)
	if  UseCount >= petData.arg2 then
		return true;
	end
	return false;
end

function wnd_offline_exp:onGetGift(sender, petId)
	if self._giftData and self._giftData[petId] and next(self._giftData[petId].selectItem) ~= nil then
		self.getGiftIcon:hide();
		if not g_i3k_ui_mgr:GetUI(eUIID_WizardGift) then
			g_i3k_ui_mgr:OpenUI(eUIID_WizardGift)
			g_i3k_ui_mgr:RefreshUI(eUIID_WizardGift, petId, self._giftData[petId].selectItem)
		end
	else
		if self:isCanReset(petId) then
			i3k_sbean.wizardWishOperate(petId)
		else
			local fun = (function(ok)
				if ok then
					g_i3k_logic:OpenChannelPayUI()
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
		end
	end
end

function wnd_offline_exp:updateMarkState(isbattle)
	local wizardId = g_i3k_game_context:GetCurWizard()
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	local wizardEndTime = wizardData.wizardEndTimes[self._selectIdx] or 0
	if isbattle or self._selectIdx == wizardId or (i3k_db_arder_pet[self._selectIdx].isAddition == 3 and (wizardEndTime == -1 or wizardEndTime > i3k_game_get_time())) then
		self.markImg:show()
	elseif self._selectIdx ~= wizardId then
		self.markImg:hide()
	end
end

function wnd_offline_exp:updateWizardScroll(groupIds)
	local data = {}
	for i, e in pairs(groupIds) do
		data[e] = true
	end
	self.wizardScroll:removeAllChildren()
	for i, e in ipairs(i3k_db_activity_wipe[#i3k_db_activity_wipe].groupIds) do
		if e ~= 0 then
			local _layer = require(WIZARD_WIDGET)()
			local iconID = i3k_db_activity[e].wipeIconID
			_layer.vars.bgImage:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
			local descID = i3k_db_activity[e].wipeDescID
			if descID ~= 0 then
				_layer.vars.descBtn:onTouchEvent(self, self.onBtnTips, i3k_get_string(descID))
			end
			if data[e] then
				_layer.vars.bgImage:enableWithChildren()
			else
				_layer.vars.bgImage:disableWithChildren()
			end
			
			self.wizardScroll:addItem(_layer)
		end
	end
end

function wnd_offline_exp:onBtnTips(sender, eventType, str)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_OfflinWizardTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_OfflinWizardTips, str)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_OfflinWizardTips)
		end
	end
end

function wnd_offline_exp:updateBarPercent(level, exp)
	local percent = 0
	local value = 0
	if level+1 <= #i3k_db_activity_wipe then
		value = i3k_db_activity_wipe[level+1].expArgs
		percent = exp / value * 1000
		self._layout.vars.buyExp_btn:show()
	else
		value = i3k_db_activity_wipe[level].expArgs
		exp = value
		percent = exp / value * 1000
		self._layout.vars.buyExp_btn:hide()
	end
	self._layout.vars.wizardBar:setPercent(math.floor(percent) / 10)
	self._layout.vars.barValue:setText(exp == value and i3k_get_string(5132) or exp .. "/" .. value)
end

function wnd_offline_exp:openBuyExpUI(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyOffineWizardExp)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuyOffineWizardExp, info)
end

function wnd_offline_exp:onGotoBtClick()
	local needValue = {flage = g_TASK_USE_ITEM_AT_POINT, mapId = self._targetMapId, areaId = self._monsterID, npcPos = self._targetPos}
	local targetMapId = self._targetMapId
	local targetPos = self._targetPos
	g_i3k_logic:OpenBattleUI()
	
	if not g_i3k_game_context:IsTransNeedItem() then	
		if not g_i3k_game_context:doTransport(needValue) then
			g_i3k_game_context:SeachPathWithMap(targetMapId, targetPos, nil, nil, needValue)
		end
		
		return
	end
	
	g_i3k_game_context:SeachPathWithMap(targetMapId, targetPos, nil, nil, needValue)
end

function wnd_offline_exp:onHideOfflineBtnClick(sender)
	i3k_sbean.hide_offlineexp_display(g_i3k_game_context:getIsHideOfflineExp() == 1 and 0 or 1)
end
function wnd_offline_exp:updateOfflineExpState()
	self._layout.vars.hideOfflineFlag:setVisible(g_i3k_game_context:getIsHideOfflineExp() == 1)
end
function wnd_create(layout)
	local wnd = wnd_offline_exp.new()
	wnd:create(layout)
	return wnd
end
