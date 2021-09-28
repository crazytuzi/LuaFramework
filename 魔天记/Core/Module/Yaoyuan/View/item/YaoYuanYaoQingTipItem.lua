require "Core.Module.Common.UIItem"


YaoYuanYaoQingTipItem = class("YaoYuanYaoQingTipItem", UIItem);

function YaoYuanYaoQingTipItem:New()
    self = { };
    setmetatable(self, { __index = YaoYuanYaoQingTipItem });
    return self
end
 

function YaoYuanYaoQingTipItem:UpdateItem(data)
    self.data = data
end

function YaoYuanYaoQingTipItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.label = UIUtil.GetChildByName(self.gameObject, "UILabel", "label");

    self.ok_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "ok_bt");

    self._onClickok_bt = function(go) self:_OnClickok_bt(self) end
    UIUtil.GetComponent(self.ok_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickok_bt);


    self:SetActive(true);

end

function YaoYuanYaoQingTipItem:_OnClickok_bt()

    YaoyuanProxy.AcceptForShouHu(self.data.id, 1);
end


function YaoYuanYaoQingTipItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


--  S <-- 16:03:27.786, 0x140A, 0, {"name":"\u5211\u5E38\u575A","id":"20100002"}
function YaoYuanYaoQingTipItem:SetData(data)

    self.data = data;

    if self.data ~= nil then
        self.label.text = data.name .. LanguageMgr.Get("Yaoyuan/YaoYuanYaoQingTipItem/label1");
        self:SetActive(true);
    else
        self:SetActive(false);
    end



end


function YaoYuanYaoQingTipItem:_Dispose()
   


    UIUtil.GetComponent(self.ok_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickok_bt = nil;

     self.gameObject = nil;
     self.label = nil;

    self.ok_bt = nil;

end