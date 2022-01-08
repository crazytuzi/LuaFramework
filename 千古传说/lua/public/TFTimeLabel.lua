-- TFTimeLabel
-- Author: Stephen
-- Date: 2014-03-21 18:21:19
--


TFTimeLabel = class('TFTimeLabel',function ( )
	local  timeLabel = TFLabelBMFont:create()
	timeLabel.format = "hh:mm:ss"
	timeLabel.delimiter = "h"
	timeLabel:addMEListener(TFWIDGET_EXIT,function()
		timeLabel:removeCompleteCallBack()
		if timeLabel.timerID then
			TFDirector:removeTimer(timeLabel.timerID)
		end
	end)
	--timeLabel.__localSetText = timeLabel.setText
	return timeLabel
end)

function TFTimeLabel:create(fntFile,time)
	local  obj =  TFTimeLabel:new()
	if fntFile then
		obj:setFntFile(fntFile)
	end
	if time then
		obj:setTime(time)
	end
	return obj
end


function TFTimeLabel:setDelimiter( delimiter )
	self.delimiter = delimiter
end

function TFTimeLabel:setFormat( format )
	self.format = format
	if format == "hh:mm:ss" or format == "mm:ss" then
		self.nDelay = 1000
	elseif format == "hh:mm" then
		self.nDelay = 60*1000
	end
end

-- function TFTimeLabel:setText( time )
-- 	self:setTime(time)
-- end

function TFTimeLabel:setTime( time )
	self.time_num = time

	if time <= 0 then
		print("time < 0")
		return
	end

	local delaytime = 1000
	if self.format == "hh:mm" then
		delaytime = time%60--math.floor(time/1000)%60
	end
	self:setLabelShow( time )
	if self.timerID then
		TFDirector:removeTimer(self.timerID)
	end
	self.timerID = TFDirector:addTimer(delaytime , 1 ,function ()
		self.timerID = nil
		self:setTime(time-1)
    end)
end

function TFTimeLabel:setLabelShow( time )
	local temp_time = time --math.floor(time/1000)
	local hour = math.floor(temp_time/3600)
	temp_time = temp_time - hour*3600
	local min = math.floor(temp_time/60)
    local sec = temp_time - min*60
    local strFormat , str
    if self.format == "hh:mm:ss" then
    	strFormat = "%02d"..self.delimiter.."%02d"..self.delimiter.."%02d"
    	str = string.format(strFormat,hour,min,sec)
    elseif self.format == "mm:ss" then
    	strFormat = "%02d"..self.delimiter.."%02d"
    	str = string.format(strFormat,min,sec)
	elseif self.format == "hh:mm" then
    	strFormat = "%02d"..self.delimiter.."%02d"
    	str = string.format(strFormat,hour,min)
	end
    self:setText(str)
end

function TFTimeLabel:setTimeAndEvents( time , completetime , timerCompleteCallBackFunc)
	self:setTime(time)
	self:removeCompleteCallBack()
	self.completetimeID = TFDirector:addTimer(completetime , 1, timerCompleteCallBackFunc)
end

function TFTimeLabel:removeCompleteCallBack()
	if self.completetimeID then
		TFDirector:removeTimer(self.completetimeID)
	end
end
return TFTimeLabel