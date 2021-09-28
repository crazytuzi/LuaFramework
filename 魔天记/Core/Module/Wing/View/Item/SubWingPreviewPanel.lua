require "Core.Module.Common.UIComponent"
require "Core.Module.Wing.View.Item.WingSelectItem"
require "Core.Module.Common.BasePropertyItem"

SubWingPreviewPanel = class("SubWingPreviewPanel", UIComponent);

function SubWingPreviewPanel:New(transform)
	self = {};
	setmetatable(self, {__index = SubWingPreviewPanel});
	if(transform) then
		self:Init(transform);
	end
	return self
end

function SubWingPreviewPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	
	self._isInit = false
end

function SubWingPreviewPanel:_InitReference()
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "ScrollView/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, WingSelectItem)
	
	self._proPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phaPro")
	self._proPhalanx = Phalanx:New()
	self._proPhalanx:Init(self._proPhalanxInfo, BasePropertyItem)
	
	self._btnUse = UIUtil.GetChildByName(self._transform, "UIButton", "btnUse");
	self._btnCancle = UIUtil.GetChildByName(self._transform, "UIButton", "btnCancle");
	self._btnRenew = UIUtil.GetChildByName(self._transform, "UIButton", "btnRenew");
	self._btnActive = UIUtil.GetChildByName(self._transform, "UIButton", "btnActive");	
	
	self._txtGet = UIUtil.GetChildByName(self._transform, "UILabel", "txtGet")
	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName")
	self._txtLeftTime = UIUtil.GetChildByName(self._transform, "UILabel", "txtLeftTime")
	self._txtNum = UIUtil.GetChildByName(self._btnActive, "UILabel", "txtNum")

    self.txtPower = UIUtil.GetChildByName(self._transform, "UILabel", "power/txtPower")
	
	self._txtRenewCost = UIUtil.GetChildByName(self._btnRenew, "UILabel", "txtNum")
	self._scrollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "ScrollView")
	-- self._trsActive = UIUtil.GetChildByName(self._transform, "trsActive")
	self._imgRank = UIUtil.GetChildByName(self._transform, "UISprite", "imgRank")
	self._imgIcon = UIUtil.GetChildByName(self._btnActive, "UISprite", "imgIcon")
	self._imgRole = UIUtil.GetChildByName(self._transform, "UITexture", "imgRole")
	self._trsRoleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent")
	self._uieffectParent = UIUtil.GetChildByName(self._transform, "EffectParent")
	self._bg = UIUtil.GetChildByName(self._uieffectParent, "UISprite", "bg")
	
	self._effet = UIEffect:New()
	self._effet:Init(self._uieffectParent, self._bg, 5, "ui_changewing")
end

function SubWingPreviewPanel:_InitListener()
	self._onClickBtnUse = function(go) self:_OnClickBtnUse(self) end
	UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUse);
	self._onClickBtnCancle = function(go) self:_OnClickBtnCancle(self) end
	UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancle);
	
	self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
	
	self._onClickBtnRenew = function(go) self:_OnClickBtnRenew(self) end
	UIUtil.GetComponent(self._btnRenew, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRenew);
end

--激活翅膀
function SubWingPreviewPanel:_OnClickBtnActive()
	WingProxy.SendActiveWing(self.data.id)
end

--翅膀续费
function SubWingPreviewPanel:_OnClickBtnRenew()
	
	MsgUtils.UseGoldConfirm(self.data.continue_price, nil, "wing/WingManager/renew", {time = TimeTranslate(self.data.time * 1000), name = self.data.name, num = self.data.continue_price},	WingProxy.RenewWing, nil, self.data.id);
end

function SubWingPreviewPanel:_OnClickBtnCancle()
	WingProxy.SendCancleWing()
end

function SubWingPreviewPanel:_OnClickBtnUse()
	WingProxy.SendUseWing()
end


function SubWingPreviewPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	self._proPhalanx:Dispose()
	self._proPhalanx = nil
	self._scrollView = nil
	self._phalanx:Dispose()
	self._phalanx = nil
	self.data = nil
	if self._effet then
		self._effet:Dispose()
		self._effect = nil
	end
	
	if(self._uiWingModel) then
		self._uiWingModel:Dispose()
		self._uiWingModel = nil
	end
end

function SubWingPreviewPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnUse = nil;
	UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCancle = nil;
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnActive = nil;
	UIUtil.GetComponent(self._btnRenew, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRenew = nil;
end

function SubWingPreviewPanel:_DisposeReference()
	
end

--激活
function SubWingPreviewPanel:UpdatePanelByActive(id)
	if(self._allWingData == nil) then return end
	local dressData = nil
	if(id) then
		dressData = WingManager.GetFashionDataById(id)
	end
	local index = 1
	
	if(dressData) then	
		self._phalanx:Build(table.getCount(self._allWingData), 1, self._allWingData)
		for k, v in ipairs(self._allWingData) do
			if(v.id == dressData.id) then						
				index = k
				break
			end
		end
		
	end	
	
	self._scrollview:ResetPosition()
	self._scrollview:UpdatePosition()
	
	local item = self._phalanx:GetItem(index)
	if(item) then item.itemLogic:SetToggleActive() end
end

local unlockNotice = LanguageMgr.Get("wing/SubWingPreviewPanel/unlockNotice")
local red = ColorDataManager.Get_red()
local green = ColorDataManager.Get_green()
local leftTime = LanguageMgr.Get("wing/SubWingPreviewPanel/leftTime")
function SubWingPreviewPanel:UpdatePanel(data)
	
	if(data) then
		self.txtPower.text = data.power;
		self.data = data
		self._allWingData = WingManager.GetFashionByCareer()
		self._phalanx:Build(table.getCount(self._allWingData), 1, self._allWingData)
		local currentWingData = WingManager.GetCurrentWingData()
		local dressWingData = WingManager.GetCurDressWingData()
		--现在显示的翅膀就是已经穿戴的翅膀
		if(self.data.state == WingManager.WingState.HadActive) then
			if(self.data.t ~= 0) then
				local time = self.data.t - GetTime()
				self._txtLeftTime.color = time > Date.Day and green or red				
				self._txtLeftTime.text = leftTime .. TimeTranslate(time * 1000)
			else
				self._txtLeftTime.text = ""
			end
		else
			self._txtLeftTime.text = ""
		end
		
		if(dressWingData and dressWingData.id == self.data.id) then
			self._btnUse.gameObject:SetActive(false)
			self._btnCancle.gameObject:SetActive(true)			
		else
			self._btnCancle.gameObject:SetActive(false)			
			self._btnUse.gameObject:SetActive(self.data.state == WingManager.WingState.HadActive)
		end	
		
		--活动翅膀
		if(self.data.type == 0) then
			ProductManager.SetIconSprite(self._imgIcon, ProductManager.GetProductById(self.data.active_cost).icon_id)
			self._txtNum.color = BackpackDataManager.GetProductTotalNumBySpid(self.data.active_cost) > 0 and green or red
			if(self.data.continue_price > 0) then
				local btnEnable = BackpackDataManager.GetProductTotalNumBySpid(self.data.active_cost) > 0 and self.data.state ~= WingManager.WingState.HadActive
				self._btnActive.gameObject:SetActive(btnEnable)				
				self._btnRenew.gameObject:SetActive(not btnEnable and self.data.state ~= WingManager.WingState.HadActive)
				self._txtRenewCost.text = "X" .. self.data.continue_price
			else
				
				self._btnActive.gameObject:SetActive(self.data.state ~= WingManager.WingState.HadActive)				
				self._btnRenew.gameObject:SetActive(false)						
			end
			self._imgRank.spriteName = self.data.word_icon
		elseif self.data.type == 1 then
			self._imgRank.spriteName = "rank" .. self.data.rank			
			self._btnActive.gameObject:SetActive(false)						
			self._btnRenew.gameObject:SetActive(false)			
		end
		
		
		self._txtName.text = self.data.name
		self._txtGet.text = self.data.desc
		local attr = self.data.attr
		local properties = attr:GetPropertyAndDes()
		self._proPhalanx:Build(table.getCount(properties), 1, properties)
		if(self._uiWingModel == nil) then
			local dress = WingManager.GetFashionDataById(self.data.id)				
			self._uiWingModel = UIAnimationModel:New(dress, self._trsRoleParent, WingCreater)	
		else
			local dress = WingManager.GetFashionDataById(self.data.id)
			self._uiWingModel:ChangeModel(dress, self._trsRoleParent)		
		end		
	else
		
		local index = 1
		if(table.getCount(self._phalanx:GetItems()) == 0) then
			self._allWingData = WingManager.GetFashionByCareer()
			self._phalanx:Build(table.getCount(self._allWingData), 1, self._allWingData)
		end
		local dressData = WingProxy.GetCurSelectWingData()
		if(dressData) then
			for k, v in ipairs(self._allWingData) do
				if(v.id == dressData.id) then						
					index = k					
					break
				end
			end
		end
		
		self._phalanx:GetItem(index).itemLogic:SetToggleActive()
		
	end
	
end

function SubWingPreviewPanel:UpdateWingItemState()
	
end


function SubWingPreviewPanel:ShowActiveEffect()
	if(self._effet) then
		self._effet:Play()
	end
end 