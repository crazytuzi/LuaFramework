-- @刮刮乐系列活动
-- @date #2019/01/14#

CardExchangeManager = CardExchangeManager or BaseClass(BaseManager)

function CardExchangeManager:__init()
    if CardExchangeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    CardExchangeManager.Instance = self
    self.model = CardExchangeModel.New()
    self:InitHandler()
    self.updateScratchcard = EventLib.New()
    --self.updateScratchItemchange = EventLib.New()
    self.updateScratchprice = EventLib.New()  --领奖协议回调

    self.OnUpdateCellListEvent = EventLib.New() --惊喜折扣商店
    self.OnUpdateItemListEvent = EventLib.New() --集字兑奖活动

    self.SurpriseShopTag = "SurpriseShopTag"
end

function CardExchangeManager:__delete()
end

function CardExchangeManager:RequestInitData()
    self:Send20465()
    self:Send20467()
    self:Send20464(1)
end

function CardExchangeManager:InitHandler()
    self:AddNetHandler(20463, self.on20463)
    self:AddNetHandler(20464, self.on20464)
    self:AddNetHandler(20465, self.On20465)
    self:AddNetHandler(20466, self.On20466)
    self:AddNetHandler(20467, self.On20467)
    self:AddNetHandler(20468, self.On20468)
    self:AddNetHandler(20469, self.on20469)
end

function CardExchangeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function CardExchangeManager:Send20463(type)
    -- print("Send20463")
    self:Send(20463, {type = type})
end

function CardExchangeManager:on20463(data)
    -- BaseUtils.dump(data,"On20463")
    if data.flag == 1 then
        --self.model.currShowId = data.id
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CardExchangeManager:Send20464(_flag)
    -- print("Send20464")
    self:Send(20464, {flag = _flag})
end

function CardExchangeManager:on20464(data)
    -- BaseUtils.dump(data,"On20464")
    self.updateScratchprice:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function CardExchangeManager:Send20465()
    -- print("发送20465协议")
    self:Send(20465,{})
end

function CardExchangeManager:On20465(data)
    BaseUtils.dump(data,"On20465")
    if data ~= nil then 
        self.OnUpdateCellListEvent:Fire(data)
    end
end

function CardExchangeManager:Send20466(id,num)
    -- print("发送20466协议id="..id..",num="..num)
    self:Send(20466,{id = id , num = num})
end

function CardExchangeManager:On20466(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CardExchangeManager:Send20467()
    -- print("发送20467协议")
    self:Send(20467,{})
end

function CardExchangeManager:On20467(data)
    -- BaseUtils.dump(data,"On20467")
    if data ~= nil then 
        self.model.collect_word_data = data
        self.OnUpdateItemListEvent:Fire(data)
    end
end

function CardExchangeManager:Send20468(plan_id)
    -- print("发送20468协议plan_id="..plan_id)
    self:Send(20468,{plan_id = plan_id})
end

function CardExchangeManager:On20468(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CardExchangeManager:Send20469()
    -- print("发送20469协议")
    self:Send(20469,{})
end

function CardExchangeManager:on20469(data)
    -- BaseUtils.dump(data,"on20469")
    self.model.preStoreId = data.id
    self.updateScratchcard:Fire()
    
end
