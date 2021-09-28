require "Core.Module.Common.UIComponent"

local MallVipNotPanel = class("MallVipNotPanel",UIComponent);
function MallVipNotPanel:New(trs)
	self = { };
	setmetatable(self, { __index =MallVipNotPanel });
	if(trs) then self:Init(trs) end
	return self
end

local maxCard = 3
function MallVipNotPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function MallVipNotPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtName1 = UIUtil.GetChildInComponents(txts, "txtName1");
	self._txtPrice1 = UIUtil.GetChildInComponents(txts, "txtPrice1");
	self._txtName2 = UIUtil.GetChildInComponents(txts, "txtName2");
	self._txtPrice2 = UIUtil.GetChildInComponents(txts, "txtPrice2");
	self._txtName3 = UIUtil.GetChildInComponents(txts, "txtName3");
	self._txtPrice3 = UIUtil.GetChildInComponents(txts, "txtPrice3");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	self._txtContext = UIUtil.GetChildByName(self._gameObject, "UITextList", "txtContext");
	self._txtBtn = UIUtil.GetChildInComponents(txts, "txtBtn");
	self._imgTilte = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgTilte");
	self._btnCard1 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnCard1");
	self._btnCard2 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnCard2");
	self._btnCard3 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnCard3");
	self._btnGo = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnGo");
	local trss = UIUtil.GetComponentsInChildren(self._gameObject, "Transform");
	self._imgIcon1 = UIUtil.GetChildByName(self._btnCard1, "UISprite", "imgIcon1");
	self._imgIcon2 = UIUtil.GetChildByName(self._btnCard2, "UISprite", "imgIcon2");
	self._imgIcon3 = UIUtil.GetChildByName(self._btnCard3, "UISprite", "imgIcon3");
	self._icon_quality1 = UIUtil.GetChildByName(self._btnCard1, "UISprite", "icon_quality");
	self._icon_quality2 = UIUtil.GetChildByName(self._btnCard2, "UISprite", "icon_quality");
	self._icon_quality3 = UIUtil.GetChildByName(self._btnCard3, "UISprite", "icon_quality");
	self._trsNoVip1 = UIUtil.GetChildInComponents(trss, "trsNoVip1");
	self._trsNoVip2 = UIUtil.GetChildInComponents(trss, "trsNoVip2");
	self._trsNoVip3 = UIUtil.GetChildInComponents(trss, "trsNoVip3");
end

function MallVipNotPanel:UpdatePanel()
    if self.inited then return end
	local cs = VIPManager.GetVipCardConfigs()
    for i = 1, maxCard do 
        local c = cs[i]
        self['_txtPrice' .. i].text = c.price
        local pd = ProductInfo:New()
        pd:Init( { spId = c.id})
        local cl = ColorDataManager.GetColorByQuality(pd:GetQuality())
        self['_txtName' .. i].text = pd:GetName()
        self['_txtName' .. i].color = cl
        self['id' .. i] = c.id
        ProductManager.SetIconSprite(self['_imgIcon' .. i], pd:GetIcon_id())
        self['_icon_quality' .. i].color = cl
    end 
    self.inited = true
    self:SelectItem(1)
end

function MallVipNotPanel:SelectItem(i)
    local id = self['id' .. i]
    for j = 1, maxCard do
        self['_trsNoVip' ..j].gameObject:SetActive(self['id' .. j] == id)
    end 
	local cs = VIPManager.GetVipCardConfigs()
    local c = VIPManager.GetVipCardConfigById(id)
    self.cid = id
    self.cind = i
    local vc = VIPManager.GetConfigByLevel(c.vip_level)
    self._txtPower.text = vc.title_fighting
    self._txtContext:Clear()
    self._txtContext:Add(vc.vip_content)
    self._txtContext:Add(vc.vip_content2)
    self._imgTilte.spriteName = vc.vip_title
end


function MallVipNotPanel:_InitListener()
	self._onClickBtnCard1 = function(go) self:_OnClickBtnCard1(self) end
	UIUtil.GetComponent(self._btnCard1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCard1);
	self._onClickBtnCard2 = function(go) self:_OnClickBtnCard2(self) end
	UIUtil.GetComponent(self._btnCard2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCard2);
	self._onClickBtnCard3 = function(go) self:_OnClickBtnCard3(self) end
	UIUtil.GetComponent(self._btnCard3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCard3);
	self._onClickBtnGo = function(go) self:_OnClickBtnGo(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGo);
end

function MallVipNotPanel:_OnClickBtnCard1()
    self:SelectItem(1)
end

function MallVipNotPanel:_OnClickBtnCard2()
    self:SelectItem(2)
end

function MallVipNotPanel:_OnClickBtnCard3()
    self:SelectItem(3)
end

function MallVipNotPanel:_OnClickBtnGo()
    local i = self.cind
	MallProxy.SendBuyVipCard(self.cid, tonumber(self['_txtPrice' .. i].text)
        , self['_txtName' .. i].text)
end

function MallVipNotPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function MallVipNotPanel:_DisposeListener()
    if not self._btnCard1 then return end
	UIUtil.GetComponent(self._btnCard1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCard1 = nil;
	UIUtil.GetComponent(self._btnCard2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCard2 = nil;
	UIUtil.GetComponent(self._btnCard3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCard3 = nil;
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGo = nil;
end

function MallVipNotPanel:_DisposeReference()
	self._btnCard1 = nil;
	self._btnCard2 = nil;
	self._btnCard3 = nil;
	self._btnGo = nil;
	self._txtName1 = nil;
	self._txtPrice1 = nil;
	self._txtName2 = nil;
	self._txtPrice2 = nil;
	self._txtName3 = nil;
	self._txtPrice3 = nil;
	self._txtPower = nil;
	self._txtContext = nil;
	self._txtBtn = nil;
	self._imgTilte = nil;
	self._trsProduct1 = nil;
	self._trsProduct2 = nil;
	self._trsProduct3 = nil;
	self._trsNoVip1 = nil;
	self._trsNoVip2 = nil;
	self._trsNoVip3 = nil;
end
return MallVipNotPanel