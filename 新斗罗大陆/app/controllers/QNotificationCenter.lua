--[[
    Class name QNotificationCenter 
    Create by julian 
    This class is a handle notification push stuff
--]]

local EventProtocol = require("framework.cc.components.behavior.EventProtocol")
local QNotificationCenter = class("QNotificationCenter", EventProtocol)

QNotificationCenter.EVENT_BULLET_TIME_TURN_ON = "NOTIFICATION_EVENT_BULLET_TIME_TURN_ON"
QNotificationCenter.EVENT_BULLET_TIME_TURN_OFF = "NOTIFICATION_EVENT_BULLET_TIME_TURN_OFF"

QNotificationCenter.EVENT_BULLET_TIME_TURN_START = "NOTIFICATION_EVENT_BULLET_TIME_TURN_START"
QNotificationCenter.EVENT_BULLET_TIME_TURN_FINISH = "NOTIFICATION_EVENT_BULLET_TIME_TURN_FINISH"

QNotificationCenter.EVENT_TRIGGER_BACK = "NOTIFICATION_EVENT_TRIGGER_BACK"
QNotificationCenter.EVENT_TRIGGER_HOME = "NOTIFICATION_EVENT_TRIGGER_HOME"

QNotificationCenter.EVENT_DIALOG_DID_APPEAR = "EVENT_DIALOG_DID_APPEAR"
QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR = "EVENT_DIALOG_WILL_DISAPPEAR"

QNotificationCenter.EVENT_ENTER_DUNGEON_LOADER = "EVENT_ENTER_DUNGEON_LOADER"
QNotificationCenter.EVENT_EXIT_FROM_BATTLE = "EVENT_EXIT_FROM_BATTLE"
QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE = "EVENT_EXIT_FROM_QUICKBATTLE"

QNotificationCenter.EVENT_CLOSE_QUICK_WAY_DIALOG = "EVENT_CLOSE_QUICK_WAY_DIALOG"

QNotificationCenter.EVENT_CLOSE_EQUIPMENT_COMPOSE_DIALOG = "EVENT_CLOSE_EQUIPMENT_COMPOSE_DIALOG"


QNotificationCenter.VIP_RECHARGED = "VIP_RECHARGED"
QNotificationCenter.VIP_LEVELUP = "VIP_LEVELUP"


QNotificationCenter.UNION_INFO_UPDATE = "UNION_INFO_UPDATE"  --宗门弹劾
QNotificationCenter.UNION_CONSORTIA_KICKED = "UNION_CONSORTIA_KICKED"  --自己被踢出宗门
QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER = "UNION_CONSORTIA_KICKED_OTHER"  --把别人踢出宗门
QNotificationCenter.UNION_JOB_CHANGE = "UNION_JOB_CHANGE"  --宗门职位发生变化
QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY = "UNION_CONSORTIA_APPLY_RATIFY"  --批准加入宗门
QNotificationCenter.UNION_WIDGET_NAME_UPDATE = "UNION_WIDGET_NAME_UPDATE"  --宗门名称 经验 widget update
QNotificationCenter.UNION_SKILL_CHANGE = "UNION_SKILL_CHANGE"  --宗门技能变化

QNotificationCenter.HERO_ADVANCE_SUCCESS = "HERO_ADVANCE_SUCCESS"  --魂师升星成功

QNotificationCenter.SHOW_HERO_CHANGE_SUCCESS = "SHOW_HERO_CHANGE_SUCCESS"  --更换展示魂师成功

QNotificationCenter.STORE_QUICK_BUY_IS_END = "STORE_QUICK_BUY_IS_END"  --商店一键购买结束

QNotificationCenter.EVENT_USER_TEAM_UP = "EVENT_USER_TEAM_UP"  --玩家战队升级

QNotificationCenter.EVENT_UI_VIEW_SIZE_CAHNGE = "EVENT_UI_VIEW_SIZE_CAHNGE"  --UI适配大小改动

QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE = "EVENT_CHANGE_GLVIEW_SIZE"  --屏幕大小发生改动


function QNotificationCenter:sharedNotificationCenter( )
    if app._notificationCenter == nil then
        app._notificationCenter = QNotificationCenter.new()
    end
    return app._notificationCenter
end

function QNotificationCenter:ctor(options)
    -- cc.GameObject.extend(self)
    -- self:addComponent("components.behavior.EventProtocol"):exportMethods()
    QNotificationCenter.super.ctor(self)
    self._handlesInfo = {}
end

function QNotificationCenter:addEventListener(eventName, listener, tag)
	local key1 = listener
	local key2 = tag
	local ttag = type(tag)
    if ttag == "table" or ttag == "userdata" then
        key1 = handler(tag, listener)
        key2 = ""
    end
	local handle = QNotificationCenter.super.addEventListener(self, eventName, key1, key2)
	if listener ~= nil and tag ~= nil then
		table.insert(self._handlesInfo, {handle = handle, listener = listener, tag = tag, eventName = eventName})
	end
end

-- key1 is listener and key2 is tag
function QNotificationCenter:removeEventListener(eventNameOrHandle, key1, key2)
	if key1 ~= nil or key2 ~= nil then
		local handle = nil
		for i, handlerInfo in ipairs(self._handlesInfo) do
			if eventNameOrHandle == handlerInfo.eventName and handlerInfo.listener == key1 and handlerInfo.tag == key2 then
				handle = handlerInfo.handle
				table.remove(self._handlesInfo, i)
				break
			end
		end
		if handle ~= nil then
			return QNotificationCenter.super.removeEventListener(self, handle)
		else
			printInfo("WARN: cannot find event handle for event name " .. eventNameOrHandle)
		end
	else
		return QNotificationCenter.super.removeEventListener(self, eventNameOrHandle, key1, key2)
	end
end

function QNotificationCenter:triggerMainPageEvent(eventName)
	if self._mainPageList == nil then return end
	local lastTarget = self._mainPageList[#self._mainPageList]
	if eventName == QNotificationCenter.EVENT_TRIGGER_BACK then
		if lastTarget ~= nil and lastTarget.onTriggerBackHandler ~= nil and (lastTarget.getEnable == nil or lastTarget:getEnable() == true) then
			lastTarget:onTriggerBackHandler()
		end
	elseif eventName == QNotificationCenter.EVENT_TRIGGER_HOME then
		if lastTarget ~= nil and lastTarget.onTriggerHomeHandler ~= nil and (lastTarget.getEnable == nil or lastTarget:getEnable() == true) then
			lastTarget:onTriggerHomeHandler()
		end
	end
end

function QNotificationCenter:addMainPageEvent(target)
	if self._mainPageList == nil then
		self._mainPageList = {}
	end

    local isExist = false
    for index, value in ipairs(self._mainPageList) do
        if value == target then
            isExist = true
            break
        end
    end

    if isExist == false then
	   table.insert(self._mainPageList, target)
    end
end

function QNotificationCenter:removeMainPageEvent(target)
	if self._mainPageList == nil then return end

	for index, value in ipairs(self._mainPageList) do
		if value == target then
			table.remove(self._mainPageList, index)
            break
		end
	end
end

return QNotificationCenter