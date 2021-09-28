require "Core.Module.Common.UIItem"

local FestivalLoginItem = class("FestivalLoginItem", UIItem)

FestivalLoginItem.MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE = "MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE"

FestivalLoginItem.currselect = nil


function FestivalLoginItem:New()
    self = { }
    setmetatable(self, { __index = FestivalLoginItem })
    return self
end


function FestivalLoginItem:_Init()

    self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt")
    self.proNameTxt = UIUtil.GetChildByName(self.transform, "UILabel", "proNameTxt")

    self.product = UIUtil.GetChildByName(self.transform, "Transform", "product")

    self.bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg")
    self.select_bg = UIUtil.GetChildByName(self.transform, "Transform", "select_bg")
    self.tipIcon = UIUtil.GetChildByName(self.transform, "Transform", "tipIcon")

    self.productCtr = ProductCtrl:New()
    self.productCtr:Init(self.product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)


    self.enterFrameRun = EnterFrameRun:New()

    self:UpdateItem(self.data)

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick)

    self.select_bg.gameObject:SetActive(false)
    self.tipIcon.gameObject:SetActive(false)

end 


function FestivalLoginItem:UpdateItem(data)
    self.data = data

    local nb = GetNumByCh(self.data.id)
    self.titleTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardItem/label1", { n = nb })

    self.bg.spriteName = "bg" .. self.data.base_map


    local info = ProductInfo.GetProductInfo(data.show_icon)
    self.productCtr:SetData(info)

    local quality = info:GetQuality()
    self.proNameTxt.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName())

end

function FestivalLoginItem:UpInfo()

    local st = FestivalMgr.GetLoginState(self.data.id)
    self.data.st = st
    if st == 1 then
        self.tipIcon.gameObject:SetActive(true)
    else
        self.tipIcon.gameObject:SetActive(false)
    end

end
function FestivalLoginItem:SetPanel(p)
    self.p = p
end
function FestivalLoginItem:_OnClick()

    if FestivalLoginItem.currselect ~= nil then
        FestivalLoginItem.currselect:ChangeSample()
    end

    FestivalLoginItem.currselect = self
    FestivalLoginItem.currselect:ChangeBig()

    if self.p then self.p:SelectChange(self.data) end
end


function FestivalLoginItem:ChangeBig()

    self:CreanEnterFramer()
    self.select_bg.gameObject:SetActive(true)

    self.enterFrameRun:AddHandler(FestivalLoginItem.ChangeSc, self, 1, { sc = 1.10 })
    self.enterFrameRun:AddHandler(FestivalLoginItem.ChangeSc, self, 1, { sc = 1.20 })

    self.enterFrameRun:Start()

end


function FestivalLoginItem:ChangeSample()

    self:CreanEnterFramer()
    self.select_bg.gameObject:SetActive(false)

    self.enterFrameRun:AddHandler(FestivalLoginItem.ChangeSc, self, 1, { sc = 1.10 })
    self.enterFrameRun:AddHandler(FestivalLoginItem.ChangeSc, self, 1, { sc = 1.00 })

    self.enterFrameRun:Start()

end

function FestivalLoginItem:ChangeSc(data)


    local sc = data.sc
    self.bg.transform.localScale = Vector3.New(sc, sc, 1)
    self.select_bg.transform.localScale = Vector3.New(sc, sc, 1)


end


function FestivalLoginItem:CreanEnterFramer()
    self.enterFrameRun:Stop()
    self.enterFrameRun:Clean()
end

function FestivalLoginItem:_Dispose()

    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick")
    self._onClick = nil

    self.productCtr:Dispose()

    self:CreanEnterFramer()
    self.enterFrameRun = nil
    FestivalLoginItem.currselect = nil


    self.titleTxt = nil
    self.proNameTxt = nil

    self.product = nil

    self.bg = nil
    self.select_bg = nil
    self.tipIcon = nil

    self.productCtr = nil

end

return FestivalLoginItem
 