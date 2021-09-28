require("app.cfg.activity_drink_info")
require("app.cfg.rebel_special_event_info")

local NotifycationManager = class("NotifycationManager")

local CrossPVPConst = require("app.const.CrossPVPConst")

function NotifycationManager:ctor()
	self._notificationList = {}	
end

function NotifycationManager:init()
	self._notificationList = {}	
	local seconds= G_ServerTime:secondsFromToday(G_ServerTime:getTime())
	--中午喝酒
	local delta1 = activity_drink_info.get(1).start_time - seconds
	local delta2 = activity_drink_info.get(2).start_time - seconds
	local day_seconds = 24*3600
	--叛军推送
	local panjunTime1 = rebel_special_event_info.get(1).open - seconds
	local panjunTime2 = rebel_special_event_info.get(3).open - seconds
	if delta1 < 0 then
	    delta1 = delta1 + day_seconds
	end
	if delta2 < 0 then
	    delta2 = delta2 + day_seconds
	end
	if panjunTime1 < 0 then
	    panjunTime1 = panjunTime1 + day_seconds
	end
	if panjunTime2 < 0 then
	    panjunTime2 = panjunTime2 + day_seconds
	end
	for i=1, 3  do 
		--兑酒
		table.insert(self._notificationList,{
			seconds=delta1 + (i-1)*day_seconds,
			msg=G_lang:get("LANG_LOCAL_DRINK1")
			})
		table.insert(self._notificationList,{
			seconds=delta2+(i-1)*day_seconds,
			msg=G_lang:get("LANG_LOCAL_DRINK2")})

		table.insert(self._notificationList,{
			seconds=panjunTime1+(i-1)*day_seconds,
			msg=G_lang:get("LANG_LOCAL_PANJUN1")})

		table.insert(self._notificationList,{
			seconds=panjunTime2+(i-1)*day_seconds,
			msg=G_lang:get("LANG_LOCAL_PANJUN2") })
	end
	local num = G_Me.cityData:getCityNum()
	for i=1, num do
	    if G_Me.cityData:isPatrollingThisCity(i) then
	        table.insert(self._notificationList,{
	        	seconds=G_Me.cityData:getRemainPatrolTimeByIndex(i),
	        	msg=G_lang:get("LANG_CITY_PATROL_FINISH_NOTIFICATION_DESC") })
	    end
	end
end

function NotifycationManager:initCrossPVP()
	-- 先把其他的通知加上
	self:init()

	-- 决战赤壁的通知
	local curTime = G_ServerTime:getTime()
	local waitTime = 0
	for i = 1, CrossPVPConst.COURSE_FINAL do
		-- 报名开始时间或战斗开始时间
		if i == CrossPVPConst.COURSE_PROMOTE_1024 then
			for j = 1, CrossPVPConst.BATTLE_FIELD_NUM do
				waitTime = G_Me.crossPVPData:notifyBattleTime(i, j) - curTime
				if waitTime > 0 then
					table.insert(self._notificationList,{
						seconds = waitTime,
						msg = G_lang:get("LANG_CROSS_PVP_NOTIFY_" .. i .. "_" ..j) })
				end
			end
		else
			waitTime = G_Me.crossPVPData:notifyBattleTime(i) - curTime
			if waitTime > 0 then
				table.insert(self._notificationList,{
					seconds = waitTime,
					msg = G_lang:get("LANG_CROSS_PVP_NOTIFY_" .. i) })
			end
		end

		-- 投注开始时间
		waitTime = G_Me.crossPVPData:notifyBetTime(i) - curTime
		if waitTime > 0 then
			table.insert(self._notificationList,{
				seconds = waitTime,
				msg = G_lang:get("LANG_CROSS_PVP_NOTIFY_BET_" .. i)	})
		end
	end
end

function NotifycationManager:registerNotifycation()
	self:init()
	self:cancelAllNotifycation()
	if G_Setting:get("open_notification") ~= "1" then
	    return
	end
	for i,notifycation in ipairs(self._notificationList) do
		G_NativeProxy.native_call("registerLocalNotification", {{seconds=notifycation.seconds}, {msg=notifycation.msg}})
	end
end

function NotifycationManager:registerCrossPVPNotification()
	self:initCrossPVP()
	self:cancelAllNotifycation()
	if G_Setting:get("open_notification") ~= "1" then
	    return
	end
	for i,notifycation in ipairs(self._notificationList) do
		G_NativeProxy.native_call("registerLocalNotification", {{seconds=notifycation.seconds}, {msg=notifycation.msg}})
	end
end

function NotifycationManager:addGMNotifycation(seconds,message)
	self:cancelAllNotifycation()
	if G_Setting:get("open_notification") ~= "1" then
	    return
	end
	self:registerNotifycation()

	if type(seconds) ~= "number" then
		return
	end
	if not message or message == "" then
		return
	end
	G_NativeProxy.native_call("registerLocalNotification", {{seconds=seconds}, {msg=message}})
end


function NotifycationManager:cancelAllNotifycation()
	G_NativeProxy.native_call("unregisterAllLocalNotifications")
end

return NotifycationManager