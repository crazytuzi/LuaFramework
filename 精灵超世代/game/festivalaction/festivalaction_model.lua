--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-03-28 20:25:00
FestivalActionModel = FestivalActionModel or BaseClass()

function FestivalActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function FestivalActionModel:config()
end

--获取倒计时
function FestivalActionModel:setCountDownTime(time)
    self.count_down_time = time
end
function FestivalActionModel:getCountDownTime()
    if self.count_down_time then
        return self.count_down_time
    end
    return 0
end

function FestivalActionModel:setActionStartStatus(status)
    self.start_status = status
end
function FestivalActionModel:getActionStartStatus()
    if self.start_status then
        return self.start_status
    end
    return 0
end

--获取夺宝的基本数据
function FestivalActionModel:setTreasureData(data)
	self.treasure_data = {}
	for i,v in pairs(data) do
		self.treasure_data[v.pos] = v
	end
end
function FestivalActionModel:getTreasureAllItemData()
    if self.treasure_data then
        return self.treasure_data
    end
    return nil
end
function FestivalActionModel:getTreasureData(pos)
	if self.treasure_data and self.treasure_data[pos] then
		return self.treasure_data[pos]
	end
	return nil
end

--倒计时
function FestivalActionModel:CountDownTime(node,less_time,time_model)
    time_model = time_model or 1
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    less_time = less_time - GameNet:getInstance():getTime()
    local function setRemainTimeString(time)
        if time > 0 then
            if time_model == 1 then
                node:setString(TimeTool.GetTimeFormat(time))
            elseif time_model == 2 then
                node:setString(TimeTool.GetTimeFormatDay(less_time))
            end
        else
            doStopAllActions(node)
            node:setString("00:00:00")
        end
    end

    if less_time > 0 then
        setRemainTimeString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                setRemainTimeString(less_time)
            end
        end))))
    else
        setRemainTimeString(less_time)
    end
end

--夺宝时间显示
function FestivalActionModel:setSnatchTime()
    local const = Config.HolidaySnatchData.data_const
    if const then
        local time_str = ""
        local snatch_time1 = const.snatch_time1.val
        local str_time1 = self:setTimeModel(snatch_time1)

        local snatch_time2 = const.snatch_time2.val
        local str_time2 = self:setTimeModel(snatch_time2)

        time_str = str_time1 .. "    "..str_time2
        return time_str
    end
end
function FestivalActionModel:setTimeModel(time_data)
    local str = ""
    if time_data[1] and time_data[2] then
        local time_1_1 = time_data[1][1] or ""
        local time_1_2 = time_data[1][2] or ""
        local time_2_1 = time_data[2][1] or ""
        local time_2_2 = time_data[2][2] or ""
        if time_1_2 == 0 then
            time_1_2 = "00"
        end
        if time_2_2 == 0 then
            time_2_2 = "00"
        end
        str = time_1_1..":"..time_1_2.."-"..time_2_1..":"..time_2_2
    end
    return str
end

function FestivalActionModel:__delete()
end
