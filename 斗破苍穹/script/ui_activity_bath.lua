require"Lang"
UIActivityBath ={}
local scheduleId = nil
local AMSTime,AMETime,PMSTime,PMETime = 10,14,17,21
local countDownTime = nil

local function netCallbackFunc(pack)
	if tonumber(pack.header) == StaticMsgRule.wash then
      UIManager.showToast(Lang.ui_activity_bath1)
      --删除顶部红点
      UIActivityPanel.addImageHint(false,"wash")
    end
end
local function sendWashData()
    local  sendData = {
      header = StaticMsgRule.wash,
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
local function updateTime()
	local ui_text_hint = ccui.Helper:seekNodeByName(UIActivityBath.Widget, "text_hint")
	local btn_bath = ccui.Helper:seekNodeByName(UIActivityBath.Widget, "btn_bath")
	local washTime = net.InstPlayer.string["30"]
	local curTime = utils.getCurrentTime()
	local curYear,curMonth,curDay,curHour,curMinute,curSencond= nil
	local temp = os.date("*t", curTime)
	curYear= temp.year
	curMonth= temp.month
	curDay= temp.day
	curHour= temp.hour
	curMinute= temp.min
	curSencond= temp.sec
	local time_hint = ""
	local text_hint = ""
	if curHour < AMSTime then --上午时间未到
		countDownTime = AMSTime*3600 - (curHour*3600+curMinute*60+curSencond)
		time_hint = Lang.ui_activity_bath2
		text_hint = Lang.ui_activity_bath3
		btn_bath:setBright(false)
     	btn_bath:setEnabled(false)
	elseif curHour >= AMSTime and curHour < AMETime then --上午泡澡
		local washTime_T = nil
		if washTime ~= "" then 
			washTime_T = utils.changeTimeFormat(washTime)
			local _year = tonumber(washTime_T[1])
			local _month = tonumber(washTime_T[2])
			local _day = tonumber(washTime_T[3])
			local _hour = tonumber(washTime_T[5])
			if _year == curYear and _month == curMonth and _day == curDay then 
				if _hour >= AMSTime and _hour < AMETime then ---泡过了
					text_hint = Lang.ui_activity_bath4
					btn_bath:setBright(false)
         			btn_bath:setEnabled(false)
				elseif  _hour < AMSTime then 
					text_hint = Lang.ui_activity_bath5
					btn_bath:setBright(true)
         			btn_bath:setEnabled(true)
				else 
					text_hint = Lang.ui_activity_bath6
					btn_bath:setBright(false)
         			btn_bath:setEnabled(false)
         		end
			else 
				text_hint = Lang.ui_activity_bath7
				btn_bath:setBright(true)
         		btn_bath:setEnabled(true)
			end
		else 
			text_hint = Lang.ui_activity_bath8
			btn_bath:setBright(true)
 			btn_bath:setEnabled(true)
		end
		countDownTime = AMETime*3600 - (curHour*3600+curMinute*60+curSencond)
		time_hint = Lang.ui_activity_bath9
	elseif curHour >= AMETime and curHour < PMSTime then --下午时间未到
		time_hint = Lang.ui_activity_bath10
		countDownTime = PMSTime*3600 - (curHour*3600+curMinute*60+curSencond)
		btn_bath:setBright(false)
     	btn_bath:setEnabled(false)
     	text_hint = Lang.ui_activity_bath11
	elseif curHour >= PMSTime and curHour < PMETime then --下午泡澡
		local washTime_T = nil
		if washTime ~= "" then 
			washTime_T = utils.changeTimeFormat(washTime)
			local _year = tonumber(washTime_T[1])
			local _month = tonumber(washTime_T[2])
			local _day = tonumber(washTime_T[3])
			local _hour = tonumber(washTime_T[5])
			if _year == curYear and _month == curMonth and _day == curDay then 
				if _hour >= PMSTime and _hour < PMETime then ---泡过了
					text_hint = Lang.ui_activity_bath12
					btn_bath:setBright(false)
         			btn_bath:setEnabled(false)
				elseif  _hour < PMSTime then 
					text_hint = Lang.ui_activity_bath13
					btn_bath:setBright(true)
         			btn_bath:setEnabled(true)
				else 
					text_hint = Lang.ui_activity_bath14
					btn_bath:setBright(false)
         			btn_bath:setEnabled(false)
				end
			else 
				text_hint = Lang.ui_activity_bath15
				btn_bath:setBright(true)
         		btn_bath:setEnabled(true)
			end
		else 
			text_hint = Lang.ui_activity_bath16
			btn_bath:setBright(true)
 			btn_bath:setEnabled(true)
		end
		time_hint = Lang.ui_activity_bath17
		countDownTime = PMETime*3600 - (curHour*3600+curMinute*60+curSencond)
	elseif curHour >= PMETime then --泡澡结束
		text_hint = Lang.ui_activity_bath18
		time_hint = ""
		countDownTime = 0
		btn_bath:setBright(false)
     	btn_bath:setEnabled(false)
	end
    ui_text_hint:setString(text_hint)
end

function UIActivityBath.checkImageHint()
    local washTime = net.InstPlayer.string["30"]
    local curTime = utils.getCurrentTime()
    local curYear,curMonth,curDay,curHour,curMinute,curSencond= nil
	local temp = os.date("*t", curTime)
	local curYear= temp.year
	local curMonth= temp.month
	local curDay= temp.day
	local curHour= temp.hour
	local curMinute= temp.min
	local curSencond= temp.sec
    local AMSTime,AMETime,PMSTime,PMETime = 10,14,17,21
    local result = false
    if curHour >= AMSTime and curHour < AMETime then    --上午泡澡时间
        if washTime ~= "" then --今天泡过澡
            washTime_T = utils.changeTimeFormat(washTime)
			local _year = tonumber(washTime_T[1])
			local _month = tonumber(washTime_T[2])
			local _day = tonumber(washTime_T[3])
			local _hour = tonumber(washTime_T[5])
			if _year == curYear and _month == curMonth and _day == curDay then 
				if _hour >= AMSTime and _hour < AMETime then
					result = false
				elseif  _hour < AMSTime then 
					result = true
				else 
					result = false
         		end
			else 
				result = true
			end
        else    --今天还没泡过澡
            result = true
        end
    elseif curHour >= PMSTime and curHour < PMETime then --下午泡澡
        local washTime_T = nil
		if washTime ~= "" then 
			washTime_T = utils.changeTimeFormat(washTime)
			local _year = tonumber(washTime_T[1])
			local _month = tonumber(washTime_T[2])
			local _day = tonumber(washTime_T[3])
			local _hour = tonumber(washTime_T[5])
			if _year == curYear and _month == curMonth and _day == curDay then 
				if _hour >= PMSTime and _hour < PMETime then ---泡过了
					result = false
				elseif  _hour < PMSTime then 
					result = true
				else 
					result = false
				end
			else 
				result = true
			end
		else 
			result = true
		end
    end
    return result
end

function UIActivityBath.init()
	local btn_bath = ccui.Helper:seekNodeByName(UIActivityBath.Widget, "btn_bath")
	btn_bath:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
          if sender == btn_bath then
          	sendWashData()
          end
      end
    end
    btn_bath:addTouchEventListener(btnTouchEvent)
end

function UIActivityBath.setup()
	updateTime()
    scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime,1,false)
end

function UIActivityBath.free()
	if scheduleId then 
      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
      scheduleId = nil
      countDownTime =nil
    end
end
