require "Core.Module.Common.UIItem"


YaoYuanMyXMItem = class("YaoYuanMyXMItem", UIItem);

function YaoYuanMyXMItem:New()
    self = { };
    setmetatable(self, { __index = YaoYuanMyXMItem });
    return self
end
 

function YaoYuanMyXMItem:UpdateItem(data)
    self.data = data
end

function YaoYuanMyXMItem:Init(gameObject, data) 
    self.gameObject = gameObject; 
    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.xm_nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "xm_nameTxt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level"); 
    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon"); 
    self.joinBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "joinBt");
    self.joinBtTipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "joinBt/tipIcon");

    self._onClickjoinBt = function(go) self:_OnClickjoinBt(self) end
    UIUtil.GetComponent(self.joinBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickjoinBt); 
    self:SetActive(false); 
end

function YaoYuanMyXMItem:_OnClickjoinBt()
    if self.data ~= nil then
        YaoyuanProxy.TryGetXianMenNumberInfo(self.data.pid, YaoyuanProxy.NUMBER_INFO_TYPE_1, self.data)
    end
end 

function YaoYuanMyXMItem:SetActive(v)
    self.gameObject:SetActive(v);
end 

function YaoYuanMyXMItem:SetData(data)
    self.data = data;

    if self.data == nil then

        self:SetActive(false);
    else

        if self.data.wts >= 1 then
            self.joinBtTipIcon.gameObject:SetActive(true);
        else
            self.joinBtTipIcon.gameObject:SetActive(false);
        end

        self.icon.spriteName = self.data.c;
        self.name_txt.text = self.data.n;
        self.xm_nameTxt.text = GuildDataManager.data.name;
        self.level.text = self.data.l;

        self:SetActive(true);
    end
end 

function YaoYuanMyXMItem:_Dispose()
    self.gameObject = nil;
    UIUtil.GetComponent(self.joinBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickjoinBt = nil;

    self.name_txt = nil;
    self.xm_nameTxt = nil;
    self.level = nil;
    self.icon = nil;
    self.joinBt = nil;
    self.joinBtTipIcon =nil;

end