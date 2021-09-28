require "Core.Module.Common.UIItem"
local FestivalChargeItem = class("FestivalChargeItem", UIItem)

function FestivalChargeItem:New()
    self = { }
    setmetatable(self, { __index = FestivalChargeItem })
    return self
end

function FestivalChargeItem:_Init()
    self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt")
    self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt")
    self.elseRechargeTxt = UIUtil.GetChildByName(self.transform, "UILabel", "elseRechargeTxt")
    self.productMaxNum = 5
    self.productTfs = { }
    self.productCtrs = { }
    for i = 1, self.productMaxNum do
        self.productTfs[i] = UIUtil.GetChildByName(self.transform, "Transform", "product" .. i)
        self.productCtrs[i] = ProductCtrl:New()
        self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER)
        self.productCtrs[i]:SetActive(false)
    end
    self._onClickAwardBt = function(go) self:_OnClickAwardBt() end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAwardBt)
    self.awardBt.gameObject:SetActive(false)
    self:UpdateItem(self.data)
end 

function FestivalChargeItem:UpdateItem(data)
    self.data = data
    local cost = self.data.param2
    self.titleTxt.text = LanguageMgr.Get("ActivityGifts/SubItem4Item/label1", { n = cost })
    local rewards = self.data.reward
    local reward_num = table.getn(rewards)
    for i = 1, reward_num do
        local info = ProductInfo.GetProductInfo(rewards[i])
        self.productCtrs[i]:SetData(info)
        self.productCtrs[i]:SetActive(true)
    end
    local csum = FestivalMgr.GetRechargeSum()
    local st = FestivalMgr.GetChargeState(self.data.id, cost)
    --Warning(self.data.id .. '___' .. st)
    local canGetAward = st ~= 0
    local hasGetAward = st == 2
    self.data.st = st
    -- log("id " .. self.data.id .. st )
    if canGetAward and not hasGetAward then
        -- 可以领取奖励但还没领取
        --self.hasdoIcon.gameObject:SetActive(false)
        self.awardBt.gameObject:SetActive(true)
        self.elseRechargeTxt.text = ''
    elseif hasGetAward then
        -- 可以领取奖励但已经领取
        --self.hasdoIcon.gameObject:SetActive(true)
        self.awardBt.gameObject:SetActive(false)
        self.elseRechargeTxt.text = LanguageMgr.Get('common/btn/noAward')
    elseif not canGetAward then
        -- 不能领取
        self.awardBt.gameObject:SetActive(false)
        self.elseRechargeTxt.text = csum .. '/' .. cost
    end
end

function FestivalChargeItem:_OnClickAwardBt()
    FestivalProxy.SendYYRechargeGet(self.data.id)
end

function FestivalChargeItem:_Dispose()
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick")
    self._onClickAwardBt = nil
    for i = 1, self.productMaxNum do
        self.productCtrs[i]:Dispose()
        self.productCtrs[i] = nil
    end
    self.awardBt = nil
    self.titleTxt = nil
    self.elseRechargeTxt = nil
    self.productTfs = nil
    self.productCtrs = nil
    self._onClickAwardBt = nil
end

return FestivalChargeItem 