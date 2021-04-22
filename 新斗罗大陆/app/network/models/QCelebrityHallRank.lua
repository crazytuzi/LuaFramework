local QBaseModel = import("...models.QBaseModel")
local QCelebrityHallRank = class("QCelebrityHallRank", QBaseModel)
local QActivity = import("...utils.QActivity")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetCelebrityHallRank = import("...ui.widgets.QUIWidgetCelebrityHallRank")

function QCelebrityHallRank:ctor(luckyType)
	QCelebrityHallRank.super.ctor(self)
	self.activityId = "a_dlmrt"
	self.activityRedTip = false
	self.activity = {}
	self.isOpen = false

	if luckyType == "CELEBRITY_HALL_RANK" then
		self:init()
		self:loginEnd()
	end
end

function QCelebrityHallRank:init()
	remote.activity:registerDataProxy(self.activityId, self)
end

function QCelebrityHallRank:loginEnd()
	if self.activity.start_at and self.activity.end_at and self.activity.targets and #self.activity.targets > 0 then
		remote.activity:setData({self.activity})
	else
		self:_initActivity()
	end
end

function QCelebrityHallRank:_initActivity(isRefresh)
	local activities = QStaticDatabase:sharedDatabase():getActivities()
	local targets = QStaticDatabase:sharedDatabase():getActivityTarget()
	local cloneActivity = {}
	for _, value in pairs(activities) do
		if value.activityId == self.activityId then
			self.activity.type = QActivity.TYPE_CELEBRITY_HALL_RANK
			self.activity.activityId = self.activityId
			self.activity.title = value.title
			self.activity.title_icon = value.title_icon
			self.activity.description = value.description
			self.activity.targets = {}

			for _, target in pairs(targets) do
				if target.activityId == self.activityId then
					target = q.cloneShrinkedObject(target)

					if not target.repeatCount then
						target.repeatCount = 1
					end
					table.insert(self.activity.targets, target)
				end
			end
			table.sort(self.activity.targets, function(a, b)
                return a.value < b.value
            end)
		end
	end

	if isRefresh then
		remote.activity:setData({self.activity})
	end
end

---------------- 接口实现 ---------------- 

function QCelebrityHallRank:initTips()
	return false
end

--实现活动的代理方法
function QCelebrityHallRank:getWidget(activityInfo)
	local widget
	if activityInfo.type == QActivity.TYPE_CELEBRITY_HALL_RANK then
		widget = QUIWidgetCelebrityHallRank.new()
	end
	return widget
end

function QCelebrityHallRank:getBtnTips(activityInfo)
	-- if activityInfo.activityId == self.activityId then
	-- 	return false
	-- end
	return false
end

function QCelebrityHallRank:checkIsComplete(activityInfo)
	-- if activityInfo.activityId == self.activityId then
	-- 	return false
	-- end
	return false
end

function QCelebrityHallRank:setActivityInfo( data )
	self.activity.start_at = data.startAt
	self.activity.end_at = data.endAt
	self.activity.luckyType = data.luckyType

	if self.activity.targets and #self.activity.targets > 0 then
		remote.activity:setData({self.activity})
	else
		self:_initActivity(true)
	end
end

function QCelebrityHallRank:handleOnLine()
	remote.activity:refreshActivity(true)
end

function QCelebrityHallRank:handleOffLine()
	remote.activity:removeActivity(self.activityId)
	remote.activity:refreshActivity(true)
end

return QCelebrityHallRank