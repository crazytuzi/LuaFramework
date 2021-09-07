-- region *.lua
-- Date 2017-5-3 jia
-- 此文件由[BabeLua]插件自动生成
--- 周年庆兑换manager
-- endregion
CakeExchangeManager = CakeExchangeManager or BaseClass(BaseManager)

function CakeExchangeManager:__init()
    if CakeExchangeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
        return
    end
    CakeExchangeManager.Instance = self
    self.model = CakeExchangeModel.New()
    self.lev = 0
    self.TotalList = { }
    self.TodayList = { }
    self:InitHandler()
end

function CakeExchangeManager:__delete(args)
    DollsRandomManager.Instance = nil
    if self.model ~= nil then
        self.model:DeleteMe()
    end
    self.model = nil
    self:RemoveNetHandler(17845, self.tmp17845)
    self:RemoveNetHandler(17846, self.tmp17846)
end

function CakeExchangeManager:InitHandler()
    self.tmp17845 = self:AddNetHandler(17845, self.on17845)
    self.tmp17846 = self:AddNetHandler(17846, self.on17846)
end

function CakeExchangeManager:send17845()
    local data = { }
    self:Send(17845, data)
end

function CakeExchangeManager:send17846(lev, id)
    local data = { lev = lev, id = id }
    self:Send(17846, data)
end

function CakeExchangeManager:on17845(data)
    self.lev = data.lev
    self.TotalList = { }
    self.TodayList = { }
    for _, data in pairs(data.list) do
        self.TotalList[data.id] = data
    end
    for _, data in pairs(data.day_list) do
        self.TodayList[data.id] = data
    end
    EventMgr.Instance:Fire(event_name.cake_exchange_data_update)
end

function CakeExchangeManager:GetTodayData(curId, list)
    for _, data in pairs(list) do
        if data.id == id then
            return data
        end
    end
    return nil
end

function CakeExchangeManager:on17846(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--检测配置的奖励是否可以兑换 
function CakeExchangeManager:CheckExchangeIsOpen(tmpData)
    local preId = tmpData.pre_id
    local preNum = tmpData.pre_num
    if preId > 0 and preNum > 0 then
        -- 有限制
        local preData = self.TotalList[preId]
        if preData == nil then
            return false
        end
        if preData.num < preNum then
            return false
        end
    else
        return true
    end
    return true
end

