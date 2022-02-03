AnimateActionModel = AnimateActionModel or BaseClass()

function AnimateActionModel:__init(ctrl)
	self.ctrl = ctrl
    self:config()
end

function AnimateActionModel:config()

end

--设置倒计时
function AnimateActionModel:setLessTime(node,less_time)
    if tolua.isnull(node) then
        return
    end
    local less_time = less_time or 0
    doStopAllActions(node)
    if less_time > 0 then
        self:setTimeFormatString(node,less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(node)
                    node:setString("00:00:00")
                else
                    self:setTimeFormatString(node,less_time)
                end
            end))))
    else
        self:setTimeFormatString(node,less_time)
    end
end
function AnimateActionModel:setTimeFormatString(node,time)
    if time > 0 then
        node:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        node:setString("00:00:00")
    end
end
--获取活动ID
function AnimateActionModel:setHolidayID(id)
	self.holiday_id = id
end
function AnimateActionModel:getHolidayID()
	return self.holiday_id or 0
end
function AnimateActionModel:setRemainChallageNum(num)
	self.challage_num = num
end
function AnimateActionModel:getRemainChallageNum()
	return self.challage_num or 0
end
--元宵厨房剩余次数
function AnimateActionModel:setKitchenRemainData(data)
    if not data or next(data) == nil then return end
	self.remain_data = {}
	for i,v in pairs(data) do
		self.remain_data[v.id] = v.num
	end
end
function AnimateActionModel:getKitchenRemainData(id)
    if not self.remain_data then return 0 end
	return self.remain_data[id] or 0
end
--领取等级奖励
function AnimateActionModel:setKitchenLevData(data)
    if not data or next(data) == nil then return end
	self.lev_data = {}
	for i,v in pairs(data) do
		self.lev_data[v.id] = true
	end
end
function AnimateActionModel:getKitchenLevData(lev)
    if not self.lev_data then return end
    if self.lev_data and self.lev_data[lev] then
    	return self.lev_data[lev] or false
    end
end

function AnimateActionModel:__delete()
end