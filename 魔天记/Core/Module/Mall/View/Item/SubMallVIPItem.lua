require "Core.Module.Common.UIItem"

SubMallVIPItem = UIItem:New();
function SubMallVIPItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtLimit = UIUtil.GetChildByName(self.transform, "UILabel", "limit")
    self._txtPrice = UIUtil.GetChildByName(self.transform, "UILabel", "price")
    -- self._txtVIP = UIUtil.GetChildByName(self.transform, "UILabel", "vipLevel")
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._imgCoin = UIUtil.GetChildByName(self.transform, "UISprite", "coin")
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    self._onClickItem = function(go) self:_OnClickItem() end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);

    self:UpdateItem(self.data)
end
 
function SubMallVIPItem:_OnClickItem()
    MallManager.SetCurrentSelectItemInfo(self.data)
    ModuleManager.SendNotification(MallNotes.UPDATE_MALLITEMINFO)
end

function SubMallVIPItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;

    self._imgCoin = nil
    self._imgQuality = nil
    self._imgCoin = nil

end 

local todayLimit = LanguageMgr.Get("Mall/SubMallItem/todayLimit")
local allLimit = LanguageMgr.Get("Mall/SubMallItem/allLimit")  

function SubMallVIPItem:GetLimitStr(str, sn)
    local res = str .. sn;
    if sn == 0 then
        res = LanguageMgr.Get("Mall/SubMallItem/hasSellAll");
    end
    return res;
end

function SubMallVIPItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        self._txtName.text = self.data.configData.name
        local c = ColorDataManager.GetColorByQuality(self.data.configData.quality)
        self._txtName.color = c
        if (self.data.st == 0) then
            self._txtLimit.text = ""
        elseif (self.data.st == 1) then
            self._txtLimit.text = self:GetLimitStr(todayLimit, self.data.sn);
        elseif (self.data.st == 2) then
            self._txtLimit.text = self:GetLimitStr(allLimit, self.data.sn); 
        end
        if (self.data.np == self.data.op) then
            self._txtPrice.text = tostring(self.data.op)
        else
            self._txtPrice.text = ColorDataManager.GetColorText(ColorDataManager.Get_red(), "[s]" .. self.data.op .. "[/s]  ") .. self.data.np

        end
        ProductManager.SetIconSprite(self._imgIcon, tostring(self.data.configData.icon_id))
        self._imgQuality.color = c
        -- self._txtVIP.text = tostring(self.data.vip)

        if (self.data.ri == SpecialProductId.Gold) then
            self._imgCoin.spriteName = "xianyu"
        elseif self.data.ri == SpecialProductId.BGold then
            self._imgCoin.spriteName = "bangdingxianyu"

        elseif self.data.ri == SpecialProductId.GongXunCoin then
            self._imgCoin.spriteName = "xiuwei"
        end

    end
end

function SubMallVIPItem:SetToggleActive(enable)
    self._toggle.value = enable
    if (enable) then
        self:_OnClickItem()
    end
end
 

 
