require "Core.Module.Common.UIComponent"
require "Core.Module.Mall.View.Item.SubMallVIPListItem"
local MallVipInfo = require "Core.Module.Mall.View.Item.MallVipInfo"
local VipGetPanel = require "Core.Module.Mall.View.Item.VipGetPanel"

local MallVipLevPanel = class("MallVipLevPanel", UIComponent);
function MallVipLevPanel:New(trs)
	self = {};
	setmetatable(self, {__index = MallVipLevPanel});
	if(trs) then self:Init(trs) end
	return self
end


function MallVipLevPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    self._vipInfo:InitData()
end

function MallVipLevPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._trsVipItems = UIUtil.GetChildByName(self._gameObject, "Transform", "trsVipItems");
	self._btnItem = UIUtil.GetChildByName(self._trsVipItems, "Transform", "btnItem")
	self._btnItemGo = self._btnItem.gameObject
	self._txtLevel2 = UIUtil.GetChildInComponents(txts, "txtLevel2");
	
	self._comLeft = UIUtil.GetChildByName(self._gameObject, "Transform", "comLeft");
--	self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
--	self._trsPrivilegeItem = UIUtil.GetChildByName(self._comLeft, "Transform", "trsPrivilegeItem");
	self._txtContext = UIUtil.GetChildByName(self._comLeft, "UITextList", "txtContext");
	self._txtContext2 = UIUtil.GetChildByName(self._comLeft, "UITextList", "txtContext2");
    self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	self._imgTilte = UIUtil.GetChildByName(self._comLeft, "UISprite", "imgTilte");
	self._btnGo = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnGo");
	
--	self._comRight = UIUtil.GetChildByName(self._gameObject, "Transform", "comRight");
--	self._txtTitle2 = UIUtil.GetChildInComponents(txts, "txtTitle2");
--	self._txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
--	self._txtPrice2 = UIUtil.GetChildInComponents(txts, "txtPrice2");
--	self._btnBuy = UIUtil.GetChildByName(self._comRight, "UIButton", "btnBuy");
--	self._buyedGo = UIUtil.GetChildByName(self._comRight, "Transform", "trsBuyed").gameObject;
--	self._trsContainer = UIUtil.GetChildByName(self._comRight, "UITable", "trsContainer");

    self._trsVipInfo = UIUtil.GetChildByName(self._gameObject, "Transform", "trsVipInfo")
    self._vipInfo = MallVipInfo:New(self._trsVipInfo)
	
--	self.PropsItemGos = {};
end

function MallVipLevPanel:_InitListener()
--	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
--	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
	self._onClickbtnGo = function(go) self:_OnClickbtnGo(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnGo);
end

function MallVipLevPanel:_OnClickbtnGo()
	if not self._vipVipGet then
        self._trsVipGetPanel = UIUtil.GetChildByName(self._gameObject, "Transform", "trsVipGetPanel")
        self._vipVipGet = VipGetPanel:New(self._trsVipGetPanel)
    end
    self._vipVipGet:UpdatePanel()
end

function MallVipLevPanel:_OnClickBtnItem(self, go)
	self:_ShowVipForLevel(tonumber(go.name))
end
--function MallVipLevPanel:_OnClickBtnBuy()
--	if self.currentLev > VIPManager.GetSelfVIPLevel() then
--		MsgUtils.ShowTips("Mall/vip/buyError")
--		return
--	end

--	local buyFun = function()
--		VIPManager.Bug(self.currentLev)
--	end
--	local config = VIPManager.GetConfigByLevel(self.currentLev)
--	MsgUtils.UseGoldConfirm(config.price, nil, "common/goldBuy"
--	, {num = config.price, pn = "VIP " .. config.lev .. LanguageMgr.Get("Mall/vip/vipTitle2")}, buyFun, nil, nil)


--end

function MallVipLevPanel:_Dispose()
    self._vipInfo:Dispose();
    self._vipInfo = nil
    if self._vipVipGet then self._vipVipGet:Dispose() self._vipVipGet = nil end
	self:_DisposeReference();
end

function MallVipLevPanel:UpdatePanel()
	local mylev = VIPManager.GetSelfVIPLevel()
	if not self.inited then		
		--self.privilegeGoxy = self._trsPrivilegeItem.localPosition
		--MessageManager.AddListener(VIPManager, VIPManager.VipChange, MallVipLevPanel.UpdateBuyed, self);
		self.inited = true
	end
	self:InitVipLevels(mylev)
	--self:_UpdateVipTips(mylev)
    if mylev < 1 then mylev = 1 end
	self:_ShowVipForLevel(mylev)
	local go = UIUtil.GetChildByName(self._trsVipItems, "Transform", mylev .. "")
	go:GetComponent("UIToggle").value = true
end
--function MallVipLevPanel:UpdateBuyed(data)
--	self:_UpdateBuyed(self.currentLev)
--	local mylev = VIPManager.GetSelfVIPLevel()
--    self:_UpdateVipTips(mylev)
--end
--function MallVipLevPanel:_UpdateVipTips(mylev)
--    local myMon = MoneyDataManager.Get_gold()
--	for i, v in pairs(VIPManager.GetVipConfigs()) do
--		local go = self["btnItemGo" .. i]
--		if go and go.activeSelf then
--            local f = v.lev <= mylev and v.price <= myMon and not VIPManager.GetMyBuyedGift(v.lev)
--			UIUtil.GetChildByName(go, "UISprite", "imgMsg").enabled = f
--		end
--	end
--end

--function MallVipLevPanel:_UpdateBuyed(lev)
--	self._buyedGo:SetActive(VIPManager.GetMyBuyedGift(lev))
--	self._btnBuy.gameObject:SetActive(not self._buyedGo.activeSelf)
--end
function MallVipLevPanel:_ShowVipForLevel(lev)
	local config = VIPManager.GetConfigByLevel(lev)
	self:UpdateVipContext(config)
    self._txtLevel2.text = lev
    self._imgTilte.spriteName = config.vip_title
    self._txtPower.text = config.title_fighting
	--self:UpdateVipGift(config)
	self.currentLev = lev
end
function MallVipLevPanel:InitVipLevels(mylev)
	local offsetxy = self._btnItem.localPosition
	local visibleMax = VIPManager.GetSelfConfig().visual_lev
    --Warning(VIPManager.GetSelfVIPLevel()..'---'..visibleMax)
    local cs = VIPManager.GetVipConfigs()
    local i = 0
	for k, v in pairs(cs) do
        local lev = v.lev
        if lev >= 1 then
		    local go = self["btnItemGo" .. i]
		    if not go then
			    go = i == 0 and self._btnItemGo or Resourcer.Clone(self._btnItemGo, self._trsVipItems)
			    local trs = go.transform
			    Util.SetLocalPos(trs, offsetxy.x, offsetxy.y -((lev-1) * 78), 0)
			    go.name = lev .. ""
			    UIUtil.GetChildByName(go, "UILabel", "txtItem").text = "VIP " .. lev
			    UIUtil.GetComponent(go, "LuaUIEventListener"):RegisterDelegate("OnClick",
			    function(go) self:_OnClickBtnItem(self, go) end)
			    self["btnItemGo" .. i] = go
		    end
            i = i + 1
		    go:SetActive(lev <= visibleMax)
        end
	end
end
function MallVipLevPanel:UpdateVipContext(config)
	--self._txtTitle.text = "VIP " .. config.lev .. LanguageMgr.Get("Mall/vip/vipTitle")
	local s = config.vip_content
	--for i=1,20 do s = s .. s end
    self._txtContext:Clear()
	self._txtContext:Add(s)
    self._txtContext2:Clear()
	self._txtContext2:Add(config.vip_content2)
    --Warning(s ..'\n'.. tostring(config.vip_content2))
--[[    local privilegeGo = self._trsPrivilegeItem.gameObject
    for i, v in ipairs(VIPManager.GetPrivilege(config)) do
        local go = i == 1 and privilegeGo or
        (self["privilegeGo" .. i] or Resourcer.Clone(privilegeGo, self._comLeft))
        self["privilegeGo" .. i] = go
        local trs = go.transform
            Util.SetLocalPos(trs,self.privilegeGoxy.x, self.privilegeGoxy.y -((i - 1) * 50), 0)

--        trs.localPosition = Vector3(self.privilegeGoxy.x, self.privilegeGoxy.y -((i - 1) * 50), 0)
        UIUtil.GetChildByName(go, "UILabel", "txtPrivilege").text = v
    end
    --]]
end
--function MallVipLevPanel:UpdateVipGift(config)
--	self._txtTitle2.text = "VIP " .. config.lev .. LanguageMgr.Get("Mall/vip/vipTitle2")
--	self._txtPrice.text = "[s]" .. config.display_price
--	self._txtPrice2.text = config.price
--	self:_UpdateBuyed(config.lev)
--	local pinfos = VIPManager.GetGift(config)
--	local newGO = false
--	for i = 1, 8, 1 do
--		local pinfo = pinfos[i]
--		local item = self["PropsItem" .. i]
--		local go = nil
--		if pinfo then
--			if not item then
--				item = PropsItem:New()
--				self["PropsItem" .. i] = item
--				local go = UIUtil.GetUIGameObject(ResID.UI_PropsItem)
--				--go.name = i .. ""
--				self.PropsItemGos[i] = go;
--				UIUtil.AddChild(self._trsContainer.transform, go.transform)
--				item:Init(go, pinfo)
--				item:AddBoxCollider()
--				newGO = true
--				item:SetVisible(false)
--				item:SetVisible(true)
--			else
--				item:UpdateItem(pinfo)
--				item:SetVisible(true)
--			end
--		else
--			if item then item:SetVisible(false) end
--		end
--	end
--	if newGO then self._trsContainer:Reposition() end
--end

function MallVipLevPanel:_DisposeReference()
	self._onClickbtnGo = nil;
	if self._btnGo then
        UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick")
    end
--	MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, MallVipLevPanel.UpdateBuyed)
--	
--	for i, v in ipairs(self.PropsItemGos) do
--		Resourcer.Recycle(v, true);
--		self["PropsItem" .. i]:Dispose();
--	end
end

return MallVipLevPanel