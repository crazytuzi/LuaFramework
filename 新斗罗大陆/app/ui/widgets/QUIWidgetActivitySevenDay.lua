-- 
-- zxs
-- 七日登录
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySevenDay = class("QUIWidgetActivitySevenDay", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")

QUIWidgetActivitySevenDay.LOGIN_SEVEN = 1
QUIWidgetActivitySevenDay.LOGIN_FOURTEEN = 2

function QUIWidgetActivitySevenDay:ctor(options)
	local ccbFile = "Widget_Activity_sevenday_client.ccbi"
	local callBacks = {
	}
	QUIWidgetActivitySevenDay.super.ctor(self,ccbFile,callBacks,options)
	
	-- q.setButtonEnableShadow(self._ccbOwner.btn_get)
end

function QUIWidgetActivitySevenDay:setInfo(info, parent,isLocal)
	self._parentPanel = parent
	
	self:setGetState(info)

	local dayNum = info.value or 1
	local strNum = q.numToWord(dayNum)
	-- self._ccbOwner.tf_day:setString("第"..strNum.."日") 
	-- self._ccbOwner.tf_day_shadow:setString("第"..strNum.."日") 
	self._ccbOwner.tf_day:setVisible(false)
	self._ccbOwner.tf_day_shadow:setVisible(false)
	local lineSpacing = 0
	if dayNum > 9 then
		lineSpacing = -2
	end

	self._ccbOwner.node_rt:setVisible(true)
	self._ccbOwner.node_rt:removeAllChildren()
	if self._shadowColor then 
		local rt_shadow = QRichText.new("第"..strNum.."日", 24, {defaultColor = self._shadowColor, defaultSize = 18, stringType = 1, lineSpacing = lineSpacing})
		rt_shadow:setAnchorPoint(ccp(0.5, 0.5))
		rt_shadow:setPosition(ccp(2, 3))
		self._ccbOwner.node_rt:addChild(rt_shadow)
	end
	local rt = QRichText.new("第"..strNum.."日", 24, {defaultColor = self._fontColor, defaultSize = 18, stringType = 1, lineSpacing = lineSpacing})
	rt:setAnchorPoint(ccp(0.5, 0.5))
	rt:setPosition(ccp(0, 5))
	self._ccbOwner.node_rt:addChild(rt)

	self._awards = {}
	self._awardseffect = {}
    local awardsTbl = string.split(info.awards, ";")
    local awardseffectTbl = info.awardseffect 
    if isLocal then
    	awardseffectTbl = string.split(info.awardseffect,";")
    end
    for i, v in pairs(awardsTbl) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            local specialAwards = false
            if awardseffectTbl then
            	for _,awardsEf in pairs(awardseffectTbl) do
            		if tonumber(reward[1]) ~= nil and tonumber(reward[1]) == tonumber(awardsEf) then
            			specialAwards = true
            			break
            		end
            	end
            end

            table.insert(self._awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2]),specialAwards = specialAwards})
        end
    end
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._awards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item, data, index)
	            info.item = item
				info.size = item._ccbOwner.parentNode:getContentSize()
				
				--注册事件
                list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        spaceX = 10,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._awards,
	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._awards})
	end 
end

function QUIWidgetActivitySevenDay:setItemInfo( item, data ,index)
	if not data then
		return
	end
	
	if not item._itemBox then
		local scale = 0.7
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(scale)
		item._itemBox:setPosition(ccp(40, 40))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(item._itemBox:getContentSize().width*scale, 80))
	end

	local id = data.id 
	local count = tonumber(data.count)
	local itemType = remote.items:getItemType(id)

	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		item._itemBox:setGoodsInfo(id, itemType, count)
	else
		item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
	end

	if data.specialAwards then
		item._itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
		-- item._itemBox:showBoxEffect("effects/Auto_Skill_light.ccbi",true, 0, -5, 1.2)
	end
end

function QUIWidgetActivitySevenDay:setIsSevenDay(loginType)
	self._loginType = loginType
	if self._loginType == QUIWidgetActivitySevenDay.LOGIN_SEVEN then
		-- 灰色图改色方案不用了，用直接切图
		-- self._ccbOwner.sp_bg:setColor(ccc3(62, 89, 131)) 
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "ui/update_7_14_activity/sp_bluecell.png")
	else
		-- 灰色图改色方案不用了，用直接切图
		-- self._ccbOwner.sp_bg:setColor(ccc3(132, 101, 127)) 
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, "ui/update_7_14_activity/sp_yellowcell.png")
	end
end

function QUIWidgetActivitySevenDay:onTouchListView( event )
	if not event then
		return
	end
	if event.name == "moved" then
		local contentListView = self._parentPanel:getContentListView()
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
		local contentListView = self._parentPanel:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetActivitySevenDay:setGetState(info)
	-- self._ccbOwner.tf_day_shadow:setColor(ccc3(31, 41, 99)) 
	self._shadowColor = ccc3(31, 41, 99)
	self._fontColor = ccc3(239, 206, 162)
	QSetDisplayFrameByPath(self._ccbOwner.sp_flag, "ui/update_7_14_activity/sp_flag_blue.png")
	-- makeNodeFromGrayToNormal(self._ccbOwner.node_flag)
	if info.isGet then
		QSetDisplayFrameByPath(self._ccbOwner.sp_flag, "ui/update_7_14_activity/sp_flag_red.png")

		self._ccbOwner.sp_get:setVisible(true)
		self._ccbOwner.node_btn:setVisible(false)
		-- makeNodeFromNormalToGray(self._ccbOwner.node_flag)  -- dldl-27350
		-- self._shadowColor = nil
		-- self._fontColor = COLORS.f
	elseif info.isComplete and not info.isGet then
		self._shadowColor = ccc3(86, 29, 27)
		-- self._ccbOwner.tf_day_shadow:setColor(ccc3(86, 29, 27)) 
		QSetDisplayFrameByPath(self._ccbOwner.sp_flag, "ui/update_7_14_activity/sp_flag_red.png")

		self._ccbOwner.sp_get:setVisible(false)
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.btn_get:setEnabled(true)
		self._ccbOwner.tf_get:setString("领取")
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		-- self._ccbOwner.btn_get:setOpacity(255)
		self._ccbOwner.tf_get:enableOutline()
		-- self._ccbOwner.tf_get:setOpacity(255)
	else
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.sp_get:setVisible(false)
		self._ccbOwner.btn_get:setEnabled(false)
		self._ccbOwner.tf_get:setString("领取")
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
		-- self._ccbOwner.btn_get:setOpacity(200)
		self._ccbOwner.tf_get:disableOutline()
		-- self._ccbOwner.tf_get:setOpacity(200)
	end

	self:setScendDayGetState(info.value)
end

function QUIWidgetActivitySevenDay:setScendDayGetState(day)
	local loginDaysCount = remote.user.loginDaysCount or 0
	local entryType = remote.activity.TYPE_FOURTEEN_ENTRY1
	if self._loginType == QUIWidgetActivitySevenDay.LOGIN_SEVEN then
		entryType = remote.activity.TYPE_SEVEN_ENTRY1
	end
	local canGetAwards = remote.activity:checkActivitySevenEntryAwrdsTip(entryType)
	if not canGetAwards then
		if loginDaysCount > 0 and day == loginDaysCount + 1 then
			self._shadowColor = ccc3(86, 29, 27)
			QSetDisplayFrameByPath(self._ccbOwner.sp_flag, "ui/update_7_14_activity/sp_flag_blue.png")
			-- makeNodeFromGrayToNormal(self._ccbOwner.node_flag)
			self._ccbOwner.sp_get:setVisible(false)
			self._ccbOwner.node_btn:setVisible(true)
			self._ccbOwner.btn_get:setEnabled(true)
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
			self._ccbOwner.tf_get:setString("明日可领取")
			self._ccbOwner.btn_get:setBackgroundSpriteFrameForState(QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_yellow.png"), CCControlStateNormal)
			self._ccbOwner.btn_get:setBackgroundSpriteFrameForState(QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_yellow.png"), CCControlStateHighlighted)
			self._ccbOwner.btn_get:setBackgroundSpriteFrameForState(QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_yellow.png"), CCControlStateDisabled)
			self._ccbOwner.tf_get:enableOutline()	
			self._ccbOwner.tf_get:setOpacity(255)
			self._ccbOwner.btn_get:setOpacity(255)
		end
	end	
end

function QUIWidgetActivitySevenDay:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetActivitySevenDay

