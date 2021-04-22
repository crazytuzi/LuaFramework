local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityVerChangeLogin = class("QUIWidgetActivityVerChangeLogin", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActivity = import("...utils.QActivity")
local QListView = import("...views.QListView")

local QUIWidgetActivityExchange = import("..widgets.QUIWidgetActivityExchange")
local QUIWidgetActivityVerChangeLoginClient = import("..widgets.QUIWidgetActivityVerChangeLoginClient")

function QUIWidgetActivityVerChangeLogin:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Ver_Change_Login.ccbi"
    local callBacks = {
    }
    QUIWidgetActivityVerChangeLogin.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end


----------------------------------------
---生命周期部分

function QUIWidgetActivityVerChangeLogin:onEnter()
end

function QUIWidgetActivityVerChangeLogin:onExit()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end



----------------------------------------
---接口部分

-- 设置信息
function QUIWidgetActivityVerChangeLogin:setInfo(activityInfo)
	self._activityInfo = activityInfo
	self._data = activityInfo.targets
	self._startTime = activityInfo.start_at
	self._endTime = activityInfo.end_at

	self:_initContentListView()
	self:_setActivityTime()
end

-- 给条目widget使用，获取所在listview
function QUIWidgetActivityVerChangeLogin:getContentListView()
	return self._contentListView
end




----------------------------------------
---私有部分

-- 活动倒计时的定时器
function QUIWidgetActivityVerChangeLogin:_setActivityTime()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local endTime = (self._endTime or 0) / 1000

	local timeFunc
	timeFunc = function ( ... )
		local lastTime = endTime - q.serverTime()
		local timeStr = ""
		if lastTime > 0 then
			local day = math.floor(lastTime/DAY)
			lastTime = lastTime%DAY
			timeStr = q.timeToHourMinuteSecond(lastTime)
			if day > 0 then
				timeStr = day.."天 "..timeStr
			end
		else
			self._ccbOwner.tf_time_title:setString("活动已结束")
		end
		self._ccbOwner.tf_activity_time:setString(timeStr)
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

-- 条目列表刷新或初始化
function QUIWidgetActivityVerChangeLogin:_initContentListView()
	if self._contentListView then
		self._contentListView:refreshData()
		return
    end

    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local data = self._data[index]
            local item = list:getItemFromCache()
            if not item then
                item = QUIWidgetActivityVerChangeLoginClient.new()
                isCacheNode = false
            end

            item:setInfo(data, self, self._startTime)
            info.item = item
            info.size = item:getContentSize()

			list:registerTouchHandler(index,"onTouchListView")
			list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
            return isCacheNode
        end,
        spaceY = 6,
        enableShadow = false,
		ignoreCanDrag = true,
		curOffset = 50,
        totalNumber = #self._data,
    }  
	self._contentListView = QListView.new(self._ccbOwner.sheet_content, cfg)
end



return QUIWidgetActivityVerChangeLogin
