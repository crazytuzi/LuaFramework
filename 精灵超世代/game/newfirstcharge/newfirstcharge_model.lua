-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
NewFirstChargeModel = NewFirstChargeModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort
function NewFirstChargeModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function NewFirstChargeModel:config()

end

--充值的状态(充值3选1)
function NewFirstChargeModel:setFirstBtnStatus(data)
    if data and next(data) then
        self.newFirstBtnStatus = {}
        for i,v in ipairs(data) do
            self.newFirstBtnStatus[v.id] = v.status
        end
        local status = false
        for i,v in pairs(data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.first_charge_new, status)
    end
end
--充值的状态(充值选耶梦加得)
function NewFirstChargeModel:setFirstBtnNewStatus(data)
    if data and next(data) then
        self.newFirstBtnStatus = {}
        for i,v in ipairs(data) do
            self.newFirstBtnStatus[v.id] = v.status
        end
        local status = false
        for i,v in pairs(data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.first_charge_new1, status)
    end
end

--充值的状态(充值选利维坦)
function NewFirstChargeModel:setFirstBtnNewStatus2(data)
    if data and next(data) then
        self.newFirstBtnStatus = {}
        for i,v in ipairs(data) do
            self.newFirstBtnStatus[v.id] = v.status
        end
        local status = false
        for i,v in pairs(data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.first_charge_new2, status)
    end
end

--充值的状态(6元送耶梦加得，100元送利维坦)
function NewFirstChargeModel:setFirstBtnNewStatus3(data)
    if data and next(data) then
        self.newFirstBtnStatus = {}
        for i,v in ipairs(data) do
            self.newFirstBtnStatus[v.id] = v.status
        end
        local status = false
        for i,v in pairs(data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.first_charge_new3, status)
    end
end

function NewFirstChargeModel:getFirstBtnStatus(index)
    if not self.newFirstBtnStatus then return 0 end
    return self.newFirstBtnStatus[index] or 0
end

--首充与累充的奖励(宝可梦3选1的)
function NewFirstChargeModel:setFirstRechargeData()
    local data = Config.ChargeData.data_new_first_charge_data
    self.firstRewardData1 = {} -- 6
    self.firstRewardData2 = {} -- 100
    for i,v in pairs(data) do
        if v.fid == 1 then
            table_insert(self.firstRewardData1,v)
        elseif v.fid == 2 then
            table_insert(self.firstRewardData2,v)
        end
    end
    table_sort(self.firstRewardData1, function(a, b) return b.id > a.id end)
    table_sort(self.firstRewardData2, function(a, b) return b.id > a.id end)
end
--首充与累充的奖励(宝可梦耶梦加得的)
function NewFirstChargeModel:setFirstRechargeNewData()
    local data = Config.ChargeData.data_first_charge_data
    self.firstRewardData1 = {} -- 6
    self.firstRewardData2 = {} -- 100
    for i,v in pairs(data) do
        if v.fid == 1 then
            table_insert(self.firstRewardData1,v)
        elseif v.fid == 2 then
            table_insert(self.firstRewardData2,v)
        end
    end
    table_sort(self.firstRewardData1, function(a, b) return b.id > a.id end)
    table_sort(self.firstRewardData2, function(a, b) return b.id > a.id end)
end

--首充与累充的奖励(宝可梦利维坦的)
function NewFirstChargeModel:setFirstRechargeNewData2()
    local data = Config.ChargeData.data_first_charge_lwt_data
    self.firstRewardData1 = {} -- 6
    self.firstRewardData2 = {} -- 100
    for i,v in pairs(data) do
        if v.fid == 1 then
            table_insert(self.firstRewardData1,v)
        elseif v.fid == 2 then
            table_insert(self.firstRewardData2,v)
        end
    end
    table_sort(self.firstRewardData1, function(a, b) return b.id > a.id end)
    table_sort(self.firstRewardData2, function(a, b) return b.id > a.id end)
end

--首充与累充的奖励(6元送耶梦加得，100元送利维坦)
function NewFirstChargeModel:setFirstRechargeNewData3()
    local data = Config.ChargeData.data_new_first_charge_data3
    self.firstRewardData1 = {} -- 6
    self.firstRewardData2 = {} -- 100
    for i,v in pairs(data) do
        if v.fid == 1 then
            table_insert(self.firstRewardData1,v)
        elseif v.fid == 2 then
            table_insert(self.firstRewardData2,v)
        end
    end
    table_sort(self.firstRewardData1, function(a, b) return b.id > a.id end)
    table_sort(self.firstRewardData2, function(a, b) return b.id > a.id end)
end

function NewFirstChargeModel:getFirstRechargeData(index)
    if not self.firstRewardData1 or not self.firstRewardData2 then return {} end
    if index == 1 then
        return self.firstRewardData1
    elseif index == 2 then
        return self.firstRewardData2
    end
end

function NewFirstChargeModel:__delete()
end
