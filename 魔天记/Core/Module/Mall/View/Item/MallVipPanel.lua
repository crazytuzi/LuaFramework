require "Core.Module.Common.UIComponent"
require "Core.Module.Mall.View.Item.SubMallVIPListItem"
local MallVipLevPanel = require "Core.Module.Mall.View.Item.MallVipLevPanel"
local MallVipNotPanel = require "Core.Module.Mall.View.Item.MallVipNotPanel"

local MallVipPanel = class("MallVipPanel", UIComponent);
function MallVipPanel:New(trs)
	self = {};
	setmetatable(self, {__index = MallVipPanel});
	if(trs) then self:Init(trs) end
	return self
end
function UIComponent:SetEnable(enable)
    SetUIEnable(self._transform, enable)
end

function MallVipPanel:SetEnable(enable, panel)
    if enable and not self._transform then
        self.panel = panel
        local go = self.panel:AddSubPanel(ResID.UI_VIP_PANEL)
        self:Init(go.transform)
    end
    if self._transform then SetUIEnable(self._transform, enable) end
end

function MallVipPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function MallVipPanel:_InitReference()
	self._btnBuy = UIUtil.GetChildByName(self._gameObject, "Transform", "bar/btnBuy")
end

function MallVipPanel:_InitListener()
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
    MessageManager.AddListener(VIPManager, VIPManager.VipChange, self.UpdatePanel, self)
end

function MallVipPanel:_OnClickBtnBuy()
	--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
end

function MallVipPanel:UpdatePanel()
    local hasVip = VIPManager.HasVIPLev()
    if hasVip then
        if not self._viplev then
	        self._trsVip = UIUtil.GetChildByName(self._gameObject, "Transform", "trsVip")
	        self._viplev = MallVipLevPanel:New(self._trsVip)
        end
        self._viplev:SetActive(true)
        self._viplev:UpdatePanel()
        if self._vipnot then self._vipnot:SetActive(false) end
    else
        if not self._vipnot then
	        self._trsVipNot = UIUtil.GetChildByName(self._gameObject, "Transform", "trsVipNot")
            self._vipnot = MallVipNotPanel:New(self._trsVipNot)
        end
        self._vipnot:SetActive(true)
        self._vipnot:UpdatePanel()
        if self._viplev then self._viplev:SetActive(false) end
    end
end

function MallVipPanel:_Dispose()
    if self._vipnot then self._vipnot:Dispose() self._vipnot = nil end
    if self._viplev then self._viplev:Dispose() self._viplev = nil end
	self:_DisposeReference()
end


function MallVipPanel:_DisposeReference()
	if self._btnBuy then
        UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick")
    end
	self._onClickBtnBuy = nil
    MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, self.UpdatePanel, self)
end

return MallVipPanel