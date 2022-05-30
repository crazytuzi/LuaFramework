-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
StartowerModel = StartowerModel or BaseClass()

function StartowerModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function StartowerModel:config()
    -- 已通关的最大层数
    self.max_tower = 0
    --剩余挑战次数
    self.less_count = 0
    --已购买次数
    self.buy_count = 0
    self.reward_list = {} ----通关奖励状态
end

--是否已经获取试练塔的协议信息
function StartowerModel:isInitStarTowerData()
    if next(self.reward_list) == nil then
        return false
    end
    return true
end

function StartowerModel:setStarTowerData(data)
    self.max_tower = data.max_tower or 0
    self.less_count = data.count or 0
    self.buy_count = data.buy_count or 0 

    if next(data.award_list) ~= nil then
        for i,v in pairs(data.award_list) do
            local tab = {}
            tab.id = v.id
            tab.status = v.status
            self.reward_list[v.id] = tab
        end
    end
    -- self.reward_list = self:sortFunc(self.reward_list)
    self:checkRedPoint()
    GlobalEvent:getInstance():Fire(StartowerEvent.Update_All_Data)
end

function StartowerModel:setRewardData(data)
    if not self.reward_list or not data[1] then return end
    for i,v in pairs(self.reward_list) do
        if v.id == data[1].id then
            self.reward_list[i].status = data[1].status
            break
        end
    end
    -- self.reward_list = self:sortFunc(self.reward_list)
end

function StartowerModel:sortFunc(data)
    local tempsort = {
        [0] = 2,  -- 0 未领取放中间
        [1] = 1,  -- 1 可领取放前面
        [2] = 3,  -- 2 已领取放最后
    }
    local function sortFunc( objA, objB )
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.id < objB.id
        end
    end
    table.sort(data, sortFunc)
    return data
end

function StartowerModel:getRewardData(id)
    if not self.reward_list then return end
    if id == nil then
        return self.reward_list or {}
    else
        return self.reward_list[id] or {}
    end
end

function StartowerModel:checkRedPoint()
    local is_open = StartowerController:getInstance():checkIsOpen() 
    if is_open  == false then return end
    local status = false
    for i,v in pairs(self.reward_list) do
        if v.status == 1 then
            status = true
            break
        end 
    end
    status = status or (self.less_count > 0)
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.startower, {bid = 1, status = status}) 
end

function StartowerModel:updateMaxTower(data)
    if data and data.max_tower and self.max_tower < data.max_tower then 
        self.max_tower = data.max_tower
    end
end

function StartowerModel:updateLessCount(data)
    if data.count then 
        self.less_count = data.count or 0
        self:checkRedPoint()
    end
    if data.buy_count then 
        self.buy_count = data.buy_count
    end
    GlobalEvent:getInstance():Fire(StartowerEvent.Count_Change_Event)
end

function StartowerModel:getNowTowerId()
    return self.max_tower or 0
end
function StartowerModel:getTowerLessCount()
    return self.less_count
end
function StartowerModel:getBuyCount()
    return self.buy_count
end
function StartowerModel:__delete()
end
