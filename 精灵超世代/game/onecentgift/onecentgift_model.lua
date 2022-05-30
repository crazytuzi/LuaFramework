-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-02-28
-- --------------------------------------------------------------------
OnecentgiftModel = OnecentgiftModel or BaseClass()

local config = Config.HolidayDimeData
function OnecentgiftModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function OnecentgiftModel:config()
end

function OnecentgiftModel:setBaseInfo(data)
    if data == nil then
        return
    end
    self.data = data
    self:setAwardDataById()
    self:setMainTipsStatus()
end

function OnecentgiftModel:setAwardDataById()
    if self.data == nil and self.data.list == nil and config == nil then
        return
    end
    local period = self:getCurPeriod()
    self.period_award = DeepCopy(config.data_award_list[period])
    if self.period_award == nil then
        self.period_award = {}
    end
    for k, v in pairs(self.period_award) do
        v.rev_state = 0
        for k1, v1 in pairs(self.data.list) do
            if v.id == v1.id then
                v.rev_state = v1.finish
            end
        end
    end
end

function OnecentgiftModel:getAwardData()
    local award_data = {}
    for k, v in pairs(self.period_award) do
        v.is_select = false
        table.insert(award_data, v)
    end
    table.sort(
        award_data,
        function(a, b)
            return b.id > a.id
        end
    )
    if self:getIsBuy() then
        for k, v in pairs(award_data) do
            if v.rev_state == 1 then
                v.is_select = true
                break
            end
        end
    end
    return award_data
end

function OnecentgiftModel:getCurPeriod()
    if self.data ~= nil and self.data.period ~= nil and self.data.period ~= 0 then
        return self.data.period
    end
    return 1
end

function OnecentgiftModel:getIsBuy()
    if self.data ~= nil and self.data.is_buy ~= nil then
        return self.data.is_buy == 1
    end
    return false
end

function OnecentgiftModel:getEndTime()
    if self.data ~= nil and self.data.end_time ~= nil then
        return self.data.end_time
    end
    return 0
end

function OnecentgiftModel:setFirstRed(bool)
    self.first_red = bool
end

function OnecentgiftModel:getFirstRed()
    if self.first_red == false then
        return false
    end
    for k, v in pairs(self.period_award) do
        if v.rev_state ~= 2 then
            return true
        end
    end
    return false
end

function OnecentgiftModel:getIsCheap()
    local period = self:getCurPeriod()
    local period_config = config.data_period_list[period]
    if period_config ~= nil and period_config.is_cheap ~= nil and period_config.is_cheap == 1 then
        return true
    end
    return false
end

--主城红点
function OnecentgiftModel:setMainTipsStatus()
    local bid = 1
    local num = 0
    if self:getFirstRed() then
        num = num + 1
    end
    if self.data and self.data.is_buy == 1 then
        for k, v in pairs(self.data.list) do
            if v.finish == 1 then
                num = num + 1
            end
        end
    end
    local main_id = MainuiConst.icon.one_cent_gift
    local main_id1 = MainuiConst.icon.one_yuan_gift
    local vo = {
        bid = bid,
        num = num
    }
    MainuiController:getInstance():setFunctionTipsStatus(main_id, vo)
    MainuiController:getInstance():setFunctionTipsStatus(main_id1, vo)
end

function OnecentgiftModel:updateRed(curPower)
    if self.period_award then
        local bid = 1
        local num = 0
        if self:getFirstRed() then
            num = num + 1
        end
        for k, v in pairs(self.period_award) do
            if curPower >= v.power_limit and self.data.is_buy == 1 and v.rev_state ~= 2 then --战力达到且已经购买且没有领取
                num = num + 1
            end
        end
        local main_id = MainuiConst.icon.one_cent_gift
        local main_id1 = MainuiConst.icon.one_yuan_gift
        local vo = {
            bid = bid,
            num = num
        }
        MainuiController:getInstance():setFunctionTipsStatus(main_id, vo)
        MainuiController:getInstance():setFunctionTipsStatus(main_id1, vo)
    end
end

function OnecentgiftModel:__delete()
end
