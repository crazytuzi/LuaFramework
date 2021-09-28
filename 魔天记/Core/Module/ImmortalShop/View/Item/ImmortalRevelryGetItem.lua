require "Core.Module.Common.UIComponent"

local ImmortalRevelryGetItem = class("ImmortalRevelryGetItem", UIItem);
function ImmortalRevelryGetItem:New()
	self = { };
	setmetatable(self, { __index =ImmortalRevelryGetItem });
	return self
end


function ImmortalRevelryGetItem:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateItem(self.data)
end

function ImmortalRevelryGetItem:_InitReference()
	self._txtGetDes = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtGetDes");
	self._txtGetDes1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtGetDes1");
	self._txtPress = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtPress");
	self._imgGetIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgGetIcon");
	self._btnGet = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnGet");
 	self._slider = UIUtil.GetChildByName(self.gameObject, "UISlider", "slider_load");
end

function ImmortalRevelryGetItem:_InitListener()
	self._onClickBtnGet = function(go) self:_OnClickBtnGet(self) end
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet);
end

function ImmortalRevelryGetItem:_OnClickBtnGet()
    local f = self.fid
    ModuleManager.SendNotification(ImmortalShopNotes.CLOSE_IMMORTAL_SHOP_PANEL)
	SystemManager.Nav(f)
end

function ImmortalRevelryGetItem:UpdateItem(d)
    self.data = d
    local c = d.c
    self.fid = c.fun_id
    self._imgGetIcon.spriteName = c.icon
    self._txtGetDes1.text = LanguageMgr.Get("immortalShop/revelryItemGet2",{n = c.point_once})
    local ks = "immortalShop/revelryItemGet"
    if self.fid == 303 then ks = "immortalShop/revelryItemGet1" end
    self._txtGetDes.text = LanguageMgr.Get( ks, { s = c.activity_name})
    local p = d.p
    local np = c.point_all
    local ok = np <= p
    if p > np then p = np end
    self._slider.value = p / np
    self._txtPress.text = p .. '/' .. np
    self._btnGet.gameObject:SetActive(SystemManager.IsOpen(self.fid))
end

function ImmortalRevelryGetItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalRevelryGetItem:_DisposeListener()
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet = nil;
end

function ImmortalRevelryGetItem:_DisposeReference()
	self._btnGet = nil;
	self._txtGetDes = nil;
	self._txtGetDes1 = nil;
	self._txtPress = nil;
	self._imgGetIcon = nil;
end
return ImmortalRevelryGetItem