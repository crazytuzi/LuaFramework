require "Core.Module.Common.UIItem"


YaoYuanXMYaoQingItem = class("YaoYuanXMYaoQingItem", UIItem);

function YaoYuanXMYaoQingItem:New()
    self = { };
    setmetatable(self, { __index = YaoYuanXMYaoQingItem });
    return self
end
 

function YaoYuanXMYaoQingItem:UpdateItem(data)
    self.data = data
end

function YaoYuanXMYaoQingItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.elseTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "elseTimeTxt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");
    self.successPcTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "successPcTxt");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.aicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "aicon");

    self.yaoqingBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "yaoqingBt");

    self._onClickjoinBt = function(go) self:_OnClickyaoqingBt(self) end
    UIUtil.GetComponent(self.yaoqingBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickjoinBt);


    self:SetActive(true);

end

function YaoYuanXMYaoQingItem:_OnClickyaoqingBt()


    YaoyuanProxy.TryInviteForShouHu(self.data.pid);

end


function YaoYuanXMYaoQingItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function YaoYuanXMYaoQingItem:SetData(data)

    self.data = data;

    if self.data == nil then

        self:SetActive(false);
    else

        local odd = data.odd;
        local attV = FarmsDataManager.GetFarm_guard(FarmsDataManager.farms.pf.e, data.e);
        local fbase = FarmsDataManager.GetFarmBaseConfig();

        self.icon.spriteName = self.data.c;
        self.name_txt.text = self.data.n;
        self.level.text = self.data.l;

        self.elseTimeTxt.text =(fbase.guard_num - self.data.gts) .. "/" .. fbase.guard_num;

        local lpc = attV.value + odd;

        self.aicon.spriteName = "a" .. data.e;



        self.successPcTxt.text = attV.name
        -- FarmsDataManager:GetDesByPc(lpc);
        self:SetActive(true);
    end
end

function YaoYuanXMYaoQingItem:_Dispose()
    self.gameObject = nil;

    UIUtil.GetComponent(self.yaoqingBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickjoinBt = nil;

    self.name_txt = nil;
    self.elseTimeTxt = nil;
    self.level = nil;
    self.successPcTxt = nil;

    self.icon = nil;
    self.aicon = nil;

    self.yaoqingBt = nil;


end