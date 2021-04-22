-- @Author: xurui
-- @Date:   2019-03-05 15:28:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-26 18:58:14
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChatSetting = class("QUIWidgetChatSetting", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetChatSettingClient = import("..widgets.QUIWidgetChatSettingClient")

function QUIWidgetChatSetting:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_wanjia_3.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetChatSetting.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._chatSetData = {}
end

function QUIWidgetChatSetting:onEnter()
end

function QUIWidgetChatSetting:onExit()
	if app:getClient() then
		remote.userDynamic:setServerDynamicStatus(nil, nil, true)
	end
end

function QUIWidgetChatSetting:setInfo()
	self._chatSetData = {}
	local data = remote.userDynamic:getDynamicSetting()
	for _, value in pairs(data) do
		if value.unlock and app.unlock:checkLock(value.unlock) then
			value.status = remote.userDynamic:getServerDynamicStatus(value.index)
			self._chatSetData[#self._chatSetData+1] = value
		end
	end
	table.sort(self._chatSetData, function(a, b)
			return a.index < b.index
		end)
	if q.isEmpty(self._chatSetData) == false then
		self._chatSetData[1].title = "动态频道设置"
	end

	self:initListView()
end

function QUIWidgetChatSetting:initListView()
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemFunc),
	        curOriginOffset = 10,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 10,
	        totalNumber = #self._chatSetData,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._chatSetData})
	end
end

function QUIWidgetChatSetting:renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._chatSetData[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetChatSettingClient.new()
		item:addEventListener(QUIWidgetChatSettingClient.EVENT_SWITCH, handler(self, self.clientClickHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData, index)
    if itemData.title then
 		info.offsetPos = ccp(0, -60)
 	else
 		info.offsetPos = nil
    end
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
    return isCacheNode
end

function QUIWidgetChatSetting:clientClickHandler(event)
	if event == nil then return end

	local status = event.status
	local info = event.info

	remote.userDynamic:setServerDynamicStatus(info.index, status, false)
end

return QUIWidgetChatSetting
