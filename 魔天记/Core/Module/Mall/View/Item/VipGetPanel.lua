require "Core.Module.Common.Panel"

local VipGetPanel = class("VipGetPanel",UIComponent);
function VipGetPanel:New(trs)
	self = { };
	setmetatable(self, { __index =VipGetPanel });
    if(trs) then self:Init(trs) end
	return self
end

local maxCard = 3

function VipGetPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function VipGetPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtName1 = UIUtil.GetChildInComponents(txts, "txtName1");
	self._txtGetDes1 = UIUtil.GetChildInComponents(txts, "txtGetDes1");
	self._txtPrice1 = UIUtil.GetChildInComponents(txts, "txtPrice1");
	self._txtName2 = UIUtil.GetChildInComponents(txts, "txtName2");
	self._txtGetDes2 = UIUtil.GetChildInComponents(txts, "txtGetDes2");
	self._txtPrice2 = UIUtil.GetChildInComponents(txts, "txtPrice2");
	self._txtName3 = UIUtil.GetChildInComponents(txts, "txtName3");
	self._txtGetDes3 = UIUtil.GetChildInComponents(txts, "txtGetDes3");
	self._txtPrice3 = UIUtil.GetChildInComponents(txts, "txtPrice3");
	local imgs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgIcon1 = UIUtil.GetChildInComponents(imgs, "imgIcon1");
	self._imgIcon2 = UIUtil.GetChildInComponents(imgs, "imgIcon2");
	self._imgIcon3 = UIUtil.GetChildInComponents(imgs, "imgIcon3");
	self._icon_quality1 = UIUtil.GetChildInComponents(imgs, "icon_quality1");
	self._icon_quality2 = UIUtil.GetChildInComponents(imgs, "icon_quality2");
	self._icon_quality3 = UIUtil.GetChildInComponents(imgs, "icon_quality3");
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._btnGet1 = UIUtil.GetChildInComponents(btns, "btnGet1");
	self._btnGet2 = UIUtil.GetChildInComponents(btns, "btnGet2");
	self._btnGet3 = UIUtil.GetChildInComponents(btns, "btnGet3");
end

function VipGetPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnGet1 = function(go) self:_OnClickBtnGet1(self) end
	UIUtil.GetComponent(self._btnGet1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet1);
	self._onClickBtnGet2 = function(go) self:_OnClickBtnGet2(self) end
	UIUtil.GetComponent(self._btnGet2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet2);
	self._onClickBtnGet3 = function(go) self:_OnClickBtnGet3(self) end
	UIUtil.GetComponent(self._btnGet3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet3)
    self:_AddBtnListen(self._imgIcon1)
    self:_AddBtnListen(self._imgIcon2)
    self:_AddBtnListen(self._imgIcon3)
end

function VipGetPanel:_OnBtnsClick(go)
    local i = 1
	if go == self._imgIcon1.gameObject then
        i = 1
    elseif go == self._imgIcon2.gameObject then
        i = 2
    elseif go == self._imgIcon3.gameObject then
        i = 3
    end
    ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self['pd' .. i], type = ProductCtrl.TYPE_FROM_OTHER })
end 

function VipGetPanel:_OnClickBtn_close()
	self:SetActive(false)
end

function VipGetPanel:UpdatePanel()
    self:SetActive(true)
	if self.inited then return end
	local cs = VIPManager.GetVipCardConfigs()
    for i = 1, maxCard do 
        local c = cs[i]
        self['_txtPrice' .. i].text = c.price
        self['_txtGetDes' .. i].text = c.renew_desc
        local pd = ProductInfo:New()
        pd:Init( { spId = c.id})
        local cl = ColorDataManager.GetColorByQuality(pd:GetQuality())
        self['_txtName' .. i].text = pd:GetName()
        self['_txtName' .. i].color = cl
        self['id' .. i] = c.id
        self['pd' .. i] = pd
        ProductManager.SetIconSprite(self['_imgIcon' .. i], pd:GetIcon_id())
        self['_icon_quality' .. i].color = cl
    end 
    self.inited = true
end

function VipGetPanel:_OnClickBtnGet1()
	self:_OnClickBtnGet(1)
end

function VipGetPanel:_OnClickBtnGet2()
	self:_OnClickBtnGet(2)
end

function VipGetPanel:_OnClickBtnGet3()
	self:_OnClickBtnGet(3)
end

function VipGetPanel:_OnClickBtnGet(i)
	MallProxy.SendBuyVipCard(self['id' .. i], tonumber(self['_txtPrice' .. i].text)
        , self['_txtName' .. i].text)
    self:_OnClickBtn_close()
end

function VipGetPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function VipGetPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnGet1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet1 = nil;
	UIUtil.GetComponent(self._btnGet2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet2 = nil;
	UIUtil.GetComponent(self._btnGet3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet3 = nil;
end

function VipGetPanel:_DisposeReference()
	self._btn_close = nil;
	self._btnGet1 = nil;
	self._btnGet2 = nil;
	self._btnGet3 = nil;
	self._txtName1 = nil;
	self._txtGetDes1 = nil;
	self._txtPrice1 = nil;
	self._txtName2 = nil;
	self._txtGetDes2 = nil;
	self._txtPrice2 = nil;
	self._txtName3 = nil;
	self._txtGetDes3 = nil;
	self._txtPrice3 = nil;
	self._imgIcon1 = nil;
	self._imgIcon2 = nil;
	self._imgIcon3 = nil;
end
return VipGetPanel