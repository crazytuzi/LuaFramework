require "Core.Module.Common.UIItem"

SubMallItem = UIItem:New();
function SubMallItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtLimit = UIUtil.GetChildByName(self.transform, "UILabel", "limit")
    self._txtPrice = UIUtil.GetChildByName(self.transform, "UILabel", "price")
    self._txtDisCount = UIUtil.GetChildByName(self.transform, "UILabel", "discount")
    self._txtVIP = UIUtil.GetChildByName(self.transform, "UILabel", "vipTag/vip")

    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._imgCoin = UIUtil.GetChildByName(self.transform, "UISprite", "coin")
    self._goTag = UIUtil.GetChildByName(self.transform, "tag").gameObject
    self._vipTag = UIUtil.GetChildByName(self.transform, "vipTag").gameObject
    self._onClickItem = function(go) self:_OnClickItem() end
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);

    self:UpdateItem(self.data)
end

function SubMallItem:_OnClickItem()
    MallManager.SetCurrentSelectItemInfo(self.data)
    ModuleManager.SendNotification(MallNotes.UPDATE_MALLITEMINFO)
end

function SubMallItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;

    self._imgCoin = nil
    self._imgQuality = nil
    self._goTag = nil
end
local todayLimit = LanguageMgr.Get("Mall/SubMallItem/todayLimit")
local allLimit = LanguageMgr.Get("Mall/SubMallItem/allLimit")
local weekLimit = LanguageMgr.Get("Mall/SubMallItem/weekLimit")

function SubMallItem:GetLimitStr(str, sn)
    local res = str .. sn;
    if sn == 0 then
        res = LanguageMgr.Get("Mall/SubMallItem/hasSellAll");
    end
    return res;
end

function SubMallItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        self._txtName.text = self.data.configData.name
        self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
        if (self.data.st == 0) then
            self._txtLimit.text = ""
        elseif (self.data.st == 1) then
            self._txtLimit.text = self:GetLimitStr(todayLimit, self.data.sn);
        elseif (self.data.st == 2) then
            self._txtLimit.text = self:GetLimitStr(allLimit, self.data.sn);
        elseif (self.data.st == 3) then
            self._txtLimit.text = self:GetLimitStr(weekLimit, self.data.sn);
        end
        if (self.data.np == self.data.op) then
            self._goTag:SetActive(false)
            self._txtDisCount.text = ""
            self._txtPrice.text = tostring(self.data.op)
        else
            self._txtPrice.text = ColorDataManager.GetColorText(ColorDataManager.Get_red(), "[s]" .. self.data.op .. "[/s]  ") .. self.data.np
            self._goTag:SetActive(true)
            self._txtDisCount.text = self.data.ds
        end

        self._txtVIP.text = self.data.vip > 0 and tostring(self.data.vip) or ""
        self._vipTag:SetActive(self.data.vip > 0)
        ProductManager.SetIconSprite(self._imgIcon, tostring(self.data.configData.icon_id))
        self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
        if (self.data.ri == SpecialProductId.Gold) then
            self._imgCoin.spriteName = "xianyu"
        elseif self.data.ri == SpecialProductId.BGold then
            self._imgCoin.spriteName = "bangdingxianyu"
        end
    end
end

function SubMallItem:SetToggleActive(enable)
    self._toggle.value = enable
    if (enable) then
        self:_OnClickItem()
    end
end

