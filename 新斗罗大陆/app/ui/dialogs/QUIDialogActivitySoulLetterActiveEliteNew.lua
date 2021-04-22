-- @Author: liaoxianbo
-- @Date:   2020-08-24 15:40:53
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 18:37:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivitySoulLetterActiveEliteNew = class("QUIDialogActivitySoulLetterActiveEliteNew", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QPayUtil = import("...utils.QPayUtil")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")

function QUIDialogActivitySoulLetterActiveEliteNew:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_Activition_New.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuyRare", callback = handler(self, self._onTriggerBuyRare)},
		{ccbCallbackName = "onTriggerBuyRareUp", callback = handler(self, self._onTriggerBuyRareUp)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogActivitySoulLetterActiveEliteNew.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options.expCallBack then
    	self._expCallBack = options.expCallBack
    end

	q.setButtonEnableShadow(self._ccbOwner.btn_help)
	q.setButtonEnableShadow(self._ccbOwner.btn_88)
	q.setButtonEnableShadow(self._ccbOwner.btn_158)

	self._activityProxy = remote.activityRounds:getSoulLetter()

	self._activityInfo = self._activityProxy:getActivityInfo()
	
	local analysisServerFun = function(awardsTbl)
		local rareAwards = {}
		for _,v in pairs(awardsTbl) do
			remote.items:analysisServerItem(v, rareAwards)
		end

		return self:sortSameAwrads(rareAwards)
	end

	self._showRareAwards = self._activityProxy:getRareAwardsConfig()

	self._sortRareAwards = analysisServerFun(self._showRareAwards)

	local flag_ = remote.flag:getLocalData(remote.flag.FLAG_FRIST_SOIL_LETTER_ACTIVE)
	self.first_buy = tonumber(flag_) ~= 1

	self._lastDay = self:getTimeDeadLineDays()

	
	local level = self._activityInfo.level or 1
	local uplevel = level + 20 
	self._getAwardsTbl = self._activityProxy:getRareAwardsConfigBylevel(uplevel)
	self._sortgetAwards = analysisServerFun(self._getAwardsTbl)

	self:initListViewLeft()
	self:initListViewRight()
	self:initListViewGetFast()
	self:initBtnPrice()
	self:setFinalAvatar()
end

function QUIDialogActivitySoulLetterActiveEliteNew:viewDidAppear()
	QUIDialogActivitySoulLetterActiveEliteNew.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogActivitySoulLetterActiveEliteNew:viewWillDisappear()
  	QUIDialogActivitySoulLetterActiveEliteNew.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogActivitySoulLetterActiveEliteNew:initBtnPrice( )
	local elite1 = self._activityProxy:getBuyExpConfigByType(3)
	local elite2 = self._activityProxy:getBuyExpConfigByType(4)
	local showActive = false
	if self._activityInfo.type == 4 and self._activityInfo.buyState == 1 then
		elite2 = self._activityProxy:getBuyExpConfigByType(5)
		showActive = true
	end

	if elite1[1] and elite1[1].price then
		self._ccbOwner.tf_btnName_88:setString(elite1[1].price.."元")
	end

	if elite2[1] and elite2[1].price then
		self._ccbOwner.tf_btnName_158:setString(elite2[1].price.."元")
	end

	self._ccbOwner.sp_done:setVisible(showActive)
	self._ccbOwner.node_btn_88:setVisible(not showActive)
end

function QUIDialogActivitySoulLetterActiveEliteNew:setFinalAvatar( )
	local finalAward = self._activityProxy:getFinalAward()

	if q.isEmpty(finalAward) == false then
		local award = {}
		self._finalAward = finalAward
		remote.items:analysisServerItem(finalAward.rare_reward1, award)
		local itemConfig = db:getItemByID(award[1].id)
		local skins = string.split(itemConfig.content, "^")
	    local skinConfig = remote.heroSkin:getSkinConfigDictBySkinId(tonumber(skins[2]))
	    if q.isEmpty(skinConfig) == false then
	    	local characterConfig = db:getCharacterByID(skinConfig.character_id)
	        self._ccbOwner.node_avatar:removeAllChildren()
	        self._skinAvatar = QUIWidgetHeroInformation.new()
	        self._ccbOwner.node_avatar:addChild(self._skinAvatar)
		    self._skinAvatar:setAvatarByHeroInfo({skinId = skinConfig.skins_id}, skinConfig.character_id, 1)
		    self._skinAvatar:setNameVisible(false)

		    self._ccbOwner.tf_actor_name:setString((skinConfig.skins_name or "").."·"..(characterConfig.name or ""))
		end
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:sortSameAwrads(awards)
    --合并相同的道具
    local tempAwards = {}

    for _,v in pairs(awards) do
    	local key = v.id
    	if not key then
    		key = v.typeName
	    end
	    if key then
	    	if tempAwards[key] then
	    		tempAwards[key].count = tempAwards[key].count + v.count
	    	else
	    		tempAwards[key] = {id = v.id,count = v.count,typeName = v.typeName}
	    	end
	    end
    end
    local awardsTbl = {}
    for _,v in pairs(tempAwards) do
    	table.insert(awardsTbl, v)
    end
    table.sort(awardsTbl, handler(self, self.sortAwards))
    return awardsTbl
end

function QUIDialogActivitySoulLetterActiveEliteNew:sortAwards(a, b)
	local aColour = 1
	local bColour = 1
	if a.id then
		local itemConfig = db:getItemByID(a.id)
		aColour = itemConfig.colour
	else
		local config = remote.items:getWalletByType(a.typeName)
		aColour = config.colour
	end
	if b.id then
		local itemConfig = db:getItemByID(b.id)
		bColour = itemConfig.colour
	else
		local config = remote.items:getWalletByType(b.typeName)
		bColour = config.colour
	end
	if aColour ~= bColour then
		return aColour > bColour
	elseif a.id and b.id then
		return a.id > b.id
	else
		return false
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:initListViewLeft()
	if not self._awardsListViewleft then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._sortRareAwards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        multiItems = 2,
	        spaceX = -15,
	        spaceY = -10,
	        ignoreCanDrag = false,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._sortRareAwards 
 		}
 		self._awardsListViewleft = QListView.new(self._ccbOwner.layout_normal, cfg)  	
	else
		self._awardsListViewleft:reload({totalNumber = #self._sortRareAwards})
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:initListViewRight()
	if not self._awardsListViewRight then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._sortRareAwards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        multiItems = 2,
	        spaceX = -15,
	        spaceY = -10,
	        ignoreCanDrag = false,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._sortRareAwards 
 		}
 		self._awardsListViewRight = QListView.new(self._ccbOwner.layout_hight, cfg)  	
	else
		self._awardsListViewRight:reload({totalNumber = #self._sortRareAwards})
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:initListViewGetFast()
	if not self._awardsListViewFast then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._sortgetAwards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        spaceX = -15,
	        ignoreCanDrag = false,
	        enableShadow = false,
	        isVertical = false,
	        totalNumber = #self._sortgetAwards 
 		}
 		self._awardsListViewFast = QListView.new(self._ccbOwner.layout_award, cfg)  	
	else
		self._awardsListViewFast:reload({totalNumber = #self._sortgetAwards})
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetItemsBox.new()
		item._itemNode:setPosition(ccp(80/2,80/2))
		item._itemNode:setScale(0.68)
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(80,80))
	end

	item._itemNode:setPromptIsOpen(true)
	item._itemNode:setGoodsInfo(itemData.id, itemData.typeName, itemData.count)
end

--获得魂师手札倒计时天数
function  QUIDialogActivitySoulLetterActiveEliteNew:getTimeDeadLineDays()
	local day = 28
	local endTime = self._activityProxy.endAt or 0
	if remote.user.openServerTime ~= nil and remote.user.openServerTime > 0 then

		local passTime = endTime - remote.user.openServerTime
		local dis_opensvr = math.floor(passTime/(DAY))
		if dis_opensvr <= 28 then
			local lastTime = endTime - q.serverTime()
			if lastTime > 0 then
				day = math.floor(lastTime/(DAY))
			end
		end
	end

	return day
end
--计算剩余可达到的最高等级 包含购买手札后的加成等级
function QUIDialogActivitySoulLetterActiveEliteNew:calGetMaxLevel(day,buy_type)
	local weekNum = self._activityProxy:getCurrentWeekNum()
	local weekExp = self._activityProxy:getWeekExp()--本周获得经验
	local maxExpConfig = self._activityProxy:getWeekMaxExp(weekNum)
	local can_achieve_exp = maxExpConfig.exp or 0

	if day >= 7 then
		local next_week_maxExpConfig = self._activityProxy:getWeekMaxExp(weekNum + 1)
		local next_exp = next_week_maxExpConfig.exp or 0
		can_achieve_exp = can_achieve_exp + next_exp
	end

	can_achieve_exp = can_achieve_exp - weekExp

	local activityInfo = self._activityProxy:getActivityInfo()
	local current_sum_Exp =  activityInfo.exp  or 0 
	local level = activityInfo.level or 1

	if level > 1 then
		for i= 1,level - 1 do
			local expConfig = self._activityProxy:getAwardsConfigByLevel(i)
			local maxExp = expConfig.exp or 1200
			current_sum_Exp = current_sum_Exp + maxExp
		end
	end

	local sum_all = can_achieve_exp + current_sum_Exp
	local max_level = math.floor((sum_all or 0) / 1200 ) + 1
	if buy_type == 4 then
		max_level = max_level + 20
	end

	return max_level
end

function QUIDialogActivitySoulLetterActiveEliteNew:_clickBuy(buyInfo)
	if q.isEmpty(buyInfo) then return end
	app.sound:playSound("common_small")
	local info = buyInfo

	if self._lastDay < 14 and self.first_buy then

		local max_level_= self:calGetMaxLevel(self._lastDay,info.buy_type)
		if max_level_ < 60 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIWidgetSoulLetterActiveEliteTips",
			options = {info = info , title ="系统提示", day =self._lastDay,max_level = max_level_ ,activityProxy = self._activityProxy,buyCallback = function ( info ) self:buyByInfo(info) end ,expCallback = function()
				self:popSelf()	
				if self._expCallBack then 
					self._expCallBack()
				end
			end}})
			return
		end
	end
	self:buyByInfo(info)
end

function QUIDialogActivitySoulLetterActiveEliteNew:buyByInfo(info)
	if q.isEmpty(info) then return end
	if self.first_buy then
		remote.flag:set(remote.flag.FLAG_FRIST_SOIL_LETTER_ACTIVE, 1)
		self.first_buy = false
	end

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(info.price, 3)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(info.price, 3, nil)
		else
			QPayUtil:pay(info.price, 3, nil)
		end
	end
	self:popSelf()	
end

function QUIDialogActivitySoulLetterActiveEliteNew:_onTriggerBuyRare( )
	local elite1 = self._activityProxy:getBuyExpConfigByType(3)
	if elite1[1] then
		self:_clickBuy(elite1[1])
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:_onTriggerBuyRareUp( )
	local elite2 = self._activityProxy:getBuyExpConfigByType(4)
	if self._activityInfo.type == 4 and self._activityInfo.buyState == 1 then
		elite2 = self._activityProxy:getBuyExpConfigByType(5)
	end
	if elite2[1] then
		self:_clickBuy(elite2[1])
	end
end

function QUIDialogActivitySoulLetterActiveEliteNew:_onTriggerHelp()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterHelp",
		options = {helpType = "help_battle_pass1"}})
end

function QUIDialogActivitySoulLetterActiveEliteNew:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivitySoulLetterActiveEliteNew:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivitySoulLetterActiveEliteNew:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivitySoulLetterActiveEliteNew
