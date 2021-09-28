require "Core.Module.Common.UIComponent"

NoticeItem = class("NoticeItem", UIComponent);
function NoticeItem:New(panel)
    self = { };
    setmetatable(self, { __index = NoticeItem });
    self._panel = panel
    return self
end


function NoticeItem:_Init()
    self:_InitReference();
    self:_InitListener();
end

function NoticeItem:Init(transform, i, config)
    self.super.Init(self, transform)
    self:_InitData(config)
    if i == 1 then self:OnClickItem() end
end
function NoticeItem:_InitData(config)
    self.config = config
    self._txtItem.text = config.label
    self._imgStatus.spriteName = config.tag
    self._transform.name = config.id
end

function NoticeItem:_InitReference()
    self._txtItem = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtItem");
    self._imgSelect = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgSelect");
    self._imgStatus = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgStatus");
end

function NoticeItem:_InitListener()
    self._onClickItem = function(go) self:OnClickItem(self) end
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end
function NoticeItem:OnClickItem()
    self._panel:OnClickItem(self.config.label, self.config.desc)
end

function NoticeItem:_Dispose()
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;

    self:_DisposeReference(); 
end

function NoticeItem:_DisposeReference()
    self._txtItem = nil;
    self._imgSelect = nil;
    self._imgStatus = nil;
end
