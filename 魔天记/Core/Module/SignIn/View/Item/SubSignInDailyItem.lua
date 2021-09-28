require "Core.Module.Common.UIItem"

SubSignInDailyItem = class("SubSignInDailyItem", UIItem);
local day = LanguageMgr.Get("SignIn/SubSignInDailyItem/dayDes")
function SubSignInDailyItem:New()
    self = { };
    setmetatable(self, { __index = SubSignInDailyItem });
    return self
end


function SubSignInDailyItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._txtDay = UIUtil.GetChildByName(self.transform, "UILabel", "day")
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "count")
    self._goGet = UIUtil.GetChildByName(self.transform, "get").gameObject
    self._goMask = UIUtil.GetChildByName(self.transform, "mask").gameObject
    --    self._widget = UIUtil.GetComponent(self.transform, "UIWidget")
    self._onClickItem = function(go) self:_OnClickItem() end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    self:UpdateItem(self.data)
end 

function SubSignInDailyItem:_OnClickItem()
    if ((self.index == SignInManager.GetSignCount() + 1) and not SignInManager.GetIsSignToday()) then
        SignInProxy.SendSign()
    else
        ProductCtrl.ShowProductTip(self.data.reward.data.id, ProductCtrl.TYPE_FROM_OTHER, 1)
    end
end

function SubSignInDailyItem:_Dispose()
    self._imgIcon = nil
    self._imgQuality = nil

    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubSignInDailyItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        ProductManager.SetIconSprite(self._imgIcon, self.data.reward.data.icon_id)
        self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.reward.data.quality)
        self._txtDay.text = string.format(day, self.data.day)
        self._txtTitle.text = self.data.vip_title
        self._txtNum.text = tostring(self.data.reward.num)

        if (self.index <= SignInManager.GetSignCount()) then
            self._goGet:SetActive(true)
            self._goMask:SetActive(true)
        else
            self._goGet:SetActive(false)
            self._goMask:SetActive(false)
        end
    end
end

 