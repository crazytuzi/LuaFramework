--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineAward = class("QUIWidgetSilverMineAward", QUIWidget)

-- local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
-- local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
local QUIWidgetSilverMineBox = import("..widgets.QUIWidgetSilverMineBox")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIWidgetSilverMineAward.EVENT_CLICK = "QUIWIDGETSILVERMINEAWARD_EVENT_CLICK"
QUIWidgetSilverMineAward.EVENT_INFO = "QUIWIDGETSILVERMINEAWARD_EVENT_INFO"
QUIWidgetSilverMineAward.WEI_WAN_CHENG = "WEI_WAN_CHENG"
QUIWidgetSilverMineAward.DONE = "DONE"
QUIWidgetSilverMineAward.YI_LING_QU = "YI_LING_QU"

function QUIWidgetSilverMineAward:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_zljl.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickAwards",  callback = handler(self, QUIWidgetSilverMineAward._onTriggerClick)},
        {ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetSilverMineAward._onTriggerInfo)},
	}
	QUIWidgetSilverMineAward.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilverMineAward:onEnter()
end

function QUIWidgetSilverMineAward:onExit()   
end

function QUIWidgetSilverMineAward:resetAll()
	self._ccbOwner.normal_banner:setVisible(false)
	self._ccbOwner.done_banner:setVisible(false)
	self._ccbOwner.node_ready:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	if self._award and self._award.occupyEndType == 1 then
		self._ccbOwner.btn_info:setVisible(true)
		self._ccbOwner.btn_info:setEnabled(true)
	else
		self._ccbOwner.btn_info:setVisible(false)
		self._ccbOwner.btn_info:setEnabled(false)
	end
end

function QUIWidgetSilverMineAward:init( award, parent ) 
	self._award = award
	self._parent = parent

	self._state = QUIWidgetSilverMineAward.YI_LING_QU
	self._totalAwardWidth = 0
	-- local awards = self._award.occupyAward..";"..self._award.miningAward
	local awards = self._award.miningAward
	self._configs = self:_analyseAwards(awards, self._award.occupyAward, self._award.exOccupyAward)

	self:_initListView()
end

function QUIWidgetSilverMineAward:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.reandFunHandler),
            enableShadow = false,
	        isVertical = false,
	        spaceX = 6,
	        totalNumber = #self._configs,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_content, cfg)
	else
		self._listView:reload({totalNumber = #self._configs})
	end

    self:_init()
end

function QUIWidgetSilverMineAward:reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._configs[index]
    local item = list:getItemFromCache()
    local id, type, count = remote.silverMine:getItemBoxParaMetet(masterConfig)
    local isGoldPickaxe = false

    if not item then
        item = QUIWidgetSilverMineBox.new()
        isCacheNode = false
    end

    for _, value in pairs(self._exOccupyAwardIndexTbl) do
    	if value == index then
    		isGoldPickaxe = true
    	end
    end
    item:update( id, type, count, isGoldPickaxe )
    info.item = item
    info.size = item:getContentSize()
    info.size.width = info.size.width
    list:registerItemBoxPrompt(index, 1, item:getItemBox(), nil, nil)
    return isCacheNode
end

function QUIWidgetSilverMineAward:_init()
	self:resetAll()

	if self._award.getAward then
		-- 已领取
		self._state = QUIWidgetSilverMineAward.YI_LING_QU
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.normal_banner:setVisible(true)
	else
		-- 已完成
		self._state = QUIWidgetSilverMineAward.DONE
		self._ccbOwner.node_ready:setVisible(true)
		self._ccbOwner.done_banner:setVisible(true)
	end

	local mineId = self._award.mineId
	local mineConfig = remote.silverMine:getMineConfigByMineId( mineId )
	local cnName = remote.silverMine:getMineCNNameByQuality(mineConfig.mine_quality)
	-- mineConfig.mine_name.." "..
	self._ccbOwner.tf_mine_name:setString(cnName)

	local sec = self._award.occupySec
	local time = ""
	local h = math.floor(sec/3600)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)
	if h == 0 and m == 0 then
		time = s.."秒"
	elseif h == 0 then
		time = m.."分钟"
	else
		time = h.."小时"
	end
	if self._award.occupyEndType == 0 then
		self._ccbOwner.tf_occupy_info:setString("狩猎"..time.."奖励")
	elseif self._award.occupyEndType == 1 then
		local attackerName = self._award.attackerName or ""
		self._ccbOwner.tf_occupy_info:setString("狩猎"..time.."后被"..attackerName.."夺走")
		self._ccbOwner.btn_info:setVisible(true)
		self._ccbOwner.btn_info:setEnabled(true)
	end
end

function QUIWidgetSilverMineAward:onTouchListView( event )
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._parent:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._parent:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetSilverMineAward:_analyseAwards( awards, occupyAward, exOccupyAward )
    if awards == "" and occupyAward == "" and exOccupyAward == "" then return {} end
    self._exOccupyAwardIndexTbl = {}
    local tbl = string.split(awards, ";")
    if tbl and table.nums(tbl) > 0 then
    	local removeTbl = {}
        for index, value in pairs(tbl) do
        	if value == "" then
        		table.insert(removeTbl, index)
        	end
        end
        -- QPrintTable(tbl)
        -- QPrintTable(removeTbl)
        if removeTbl and table.nums(removeTbl) > 0 then
        	table.sort(removeTbl, function(a, b) return a > b end)
        	for _, index in pairs(removeTbl) do
        		table.remove(tbl, index)
        	end
        end
        -- QPrintTable(tbl)
        remote.silverMine:arrangeByQuality( tbl )

        tbl = self:_analyseOccupyAwards( tbl, occupyAward, exOccupyAward )
    else
    	tbl = {}
    	tbl = self:_analyseOccupyAwards( tbl, occupyAward, exOccupyAward )
    end
    
    return tbl
end

function QUIWidgetSilverMineAward:_analyseOccupyAwards( tbl, occupyAward, exOccupyAward )
	local exOccupyAwardTbl = {}
	local occupyAwardTbl = {}
	if exOccupyAward ~= "" then 
		exOccupyAwardTbl = string.split(exOccupyAward, ";")
		local removeTbl = {}
        for index, value in pairs(exOccupyAwardTbl) do
        	if value == "" then
        		table.insert(removeTbl, index)
        	end
        end
        if removeTbl and table.nums(removeTbl) > 0 then
        	table.sort(removeTbl, function(a, b) return a > b end)
        	for _, index in pairs(removeTbl) do
        		table.remove(exOccupyAwardTbl, index)
        	end
        end
        remote.silverMine:arrangeByQuality( exOccupyAwardTbl )
	end

	if occupyAward ~= "" then 
		occupyAwardTbl = string.split(occupyAward, ";")
		local removeTbl = {}
        for index, value in pairs(occupyAwardTbl) do
        	if value == "" then
        		table.insert(removeTbl, index)
        	end
        end
        if removeTbl and table.nums(removeTbl) > 0 then
        	table.sort(removeTbl, function(a, b) return a > b end)
        	for _, index in pairs(removeTbl) do
        		table.remove(occupyAwardTbl, index)
        	end
        end
        remote.silverMine:arrangeByQuality( occupyAwardTbl )
	end

	local index = 1
	while true do
		local count = 0
		if exOccupyAwardTbl and #exOccupyAwardTbl > 0 then
			local value = table.remove(exOccupyAwardTbl, 1)
			if value then
				table.insert(tbl, index, value)
				table.insert(self._exOccupyAwardIndexTbl, index)
				index = index + 1
			end
		else
			count = count + 1
		end

		if occupyAwardTbl and #occupyAwardTbl > 0 then
			local value = table.remove(occupyAwardTbl, 1)
			if value then
				table.insert(tbl, index, value)
				index = index + 1
			end
		else
			count = count + 1
		end

		if count >= 2 then
			break
		end
	end

	-- QPrintTable( tbl )
	return tbl
end

function QUIWidgetSilverMineAward:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSilverMineAward.EVENT_CLICK, occupyId = self._award.occupyId, state = self._state})
	self:resetAll()
	self._state = QUIWidgetSilverMineAward.YI_LING_QU
	self._ccbOwner.sp_done:setVisible(true)
	self._ccbOwner.normal_banner:setVisible(true)
end

function QUIWidgetSilverMineAward:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetSilverMineAward:_onTriggerInfo(e)
    app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetSilverMineAward.EVENT_INFO, fightReportId = self._award.fightReportId})
end

return QUIWidgetSilverMineAward