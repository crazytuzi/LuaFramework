-- @author xhs(礼包促销)
-- @date 2017年11月28日
SalesPromotionManager = SalesPromotionManager or BaseClass(BaseManager)

function SalesPromotionManager:__init()
    if SalesPromotionManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    SalesPromotionManager.Instance = self

    self.model = SalesPromotionModel.New()

    self:InitHandler()

    self.opened = false

    self.onBuy = EventLib.New()

    self.onFresh = EventLib.New()

end

function SalesPromotionManager:RequestInitData()
    self:Send20406()
end


function SalesPromotionManager:InitHandler()
    self:AddNetHandler(20406, self.On20406)
    self:AddNetHandler(20407, self.On20407)
    self:AddNetHandler(20408, self.On20408)
end

function SalesPromotionManager:__delete()

end

function SalesPromotionManager:Send20406()
    Connection.Instance:send(20406, {})
end

function SalesPromotionManager:On20406(data)
    self.opened = false
    if data ~= nil and data.gift_info[1] ~= nil then
        self.model:SetData(data.gift_info[1])
        self.onFresh:Fire()
        self.left = data.gift_info[1].purchased_num < data.gift_info[1].num
    end
    CampaignManager.Instance.model:CheckActiveRed(818)
end


function SalesPromotionManager:Send20407()
    Connection.Instance:send(20407, {})
end

function SalesPromotionManager:On20407(data)
    -- BaseUtils.dump(data, "购买数据")
    self.model.purchased_num = data.purchased_num
    self.onBuy:Fire()
end

function SalesPromotionManager:Send20408(item_id,num)
    Connection.Instance:send(20408, {item_id = item_id ,num = num})

end

function SalesPromotionManager:On20408(data)
    -- BaseUtils.dump(data, "购买反馈")
    if data.result == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

