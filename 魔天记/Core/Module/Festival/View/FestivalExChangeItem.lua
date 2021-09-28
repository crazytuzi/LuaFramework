require "Core.Module.Common.UIItem"
local FestivalExChangeItem = class("FestivalExChangeItem", UIItem)

function FestivalExChangeItem:New()
    self = { }
    setmetatable(self, { __index = FestivalExChangeItem })
    return self
end

function FestivalExChangeItem:_Init()
    self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt")
    self.txtLimit = UIUtil.GetChildByName(self.transform, "UILabel", "txtLimit")
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
    self:UpdateItem(self.data)
end 

function FestivalExChangeItem:UpdateItem(data)
    self.data = data
    local tt = self.data.exchange_time
    self.lt = 1
    if tt > 0 then
        local t = FestivalMgr.GetExchangeTime(self.data.id)
        self.lt = (tt - t)
        local c = self.lt <= 0 and '[ff0000]' or '[00ff00]'
        self.txtLimit.text = c .. LanguageMgr.Get("FestivalPanel/limitTime", { t = self.lt })
    else
        self.txtLimit.text = ''
    end
    local rewards = self.data.req_item
    local reward_num = table.getn(rewards)
    local ok = true
    for i = 1, reward_num do
        local info = ProductInfo.GetProductInfo(rewards[i])
        self.productCtrs[i]:SetData(info)
        self.productCtrs[i]:SetActive(true)
        local nn = info:GetAm()
        local hn = BackpackDataManager.GetProductTotalNumBySpid(info:GetSpId())
        if hn < nn then
            ok = false
            self.productCtrs[i]:UpAm('[ff0000]' .. hn .. '/' .. nn)
        else
            self.productCtrs[i]:UpAm('[00ff00]' ..  hn .. '/' .. nn)
        end
    end

    local pk = PlayerManager.GetPlayerKind()
    local its = self.data.exchange_item
    local tps = nil
    for i = #its, 1, -1 do
        if string.find(its[i], pk) then
            tps = its[i]
            break
        end
    end
    local toInd = 5
    local info = ProductInfo.GetProductInfo(tps)
    self.productCtrs[toInd]:SetData(info)
    self.productCtrs[toInd]:UpAm((ok and '[00ff00]' or '[ff0000]') ..  info:GetAm())
    self.productCtrs[toInd]:SetActive(true)
end

function FestivalExChangeItem:_OnClickAwardBt()
    if self.lt <= 0 then
        MsgUtils.ShowTips("FestivalPanel/limitTimeOver")
        return
    end
    FestivalProxy.SendYYExChange(self.data.id)
end

function FestivalExChangeItem:_Dispose()
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick")
    self._onClickAwardBt = nil
    for i = 1, self.productMaxNum do
        self.productCtrs[i]:Dispose()
        self.productCtrs[i] = nil
    end
    self.awardBt = nil
    self.txtLimit = nil
    self.elseRechargeTxt = nil
    self.productTfs = nil
    self.productCtrs = nil
    self._onClickAwardBt = nil
end

return FestivalExChangeItem 