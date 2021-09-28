require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"
require "Core.Role.ModelCreater.WingCreater"
require "Core.Module.Common.FloatLabel"
local BaseNextPropertyItem = require "Core.Module.Common.BaseNextPropertyItem"
local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local _WingManager = WingManager
local ItemCountLabel = require "Core.Module.Common.ItemCountLabel"
-- local BasePropertyItem = "Core.Module.Common.BasePropertyItem"
SubWingPanel = class("SubWingPanel", UIComponent);
local floatTime = 1
local _auto1 = LanguageMgr.Get("wing/SubWingPanel/Auto1")
local _auto2 = LanguageMgr.Get("wing/SubWingPanel/Auto2")

function SubWingPanel:New(transform)
	self = {};
	setmetatable(self, {__index = SubWingPanel});
	if(transform) then
		self:Init(transform);
	end
	return self
end

function SubWingPanel:_Init()
	self._maxNotice = LanguageMgr.Get("wing/subWingPanel/maxNotice")
	self:_InitReference();
	self:_InitListener();
	self._curAttr = BaseAttrInfo:New()
	self._nextAttr = BaseAttrInfo:New()
end

function SubWingPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
	
	self._txtMaxNotice = UIUtil.GetChildInComponents(txts, "txtMaxNotice")
	self._txtExp = UIUtil.GetChildInComponents(txts, "txtExp");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	self._btnUpdateLevel = UIUtil.GetChildByName(self._transform, "UIButton", "trsUp/btnUpdateLevel");
	self._sliderExp = UIUtil.GetChildByName(self._transform, "UISlider", "slider_exp");
	self._goUp = UIUtil.GetChildByName(self._transform, "trsUp").gameObject
	self._txtAutoLabel = UIUtil.GetChildByName(	self._goUp, "UILabel", "btnUpdateLevel/Label")
	self._txtAutoLabel.text = _auto1
	
	self._imgRank = UIUtil.GetChildByName(self._transform, "UISprite", "imgRank")
	self._imgRight = UIUtil.GetChildByName(self._transform, "UISprite", "imgRight")
	self._imgLeft = UIUtil.GetChildByName(self._transform, "UISprite", "imgLeft")
	
	self._trsRoleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent");
	self._phalaxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phalanx")
	self._floatTxt = FloatLabel:New()
	self._floatTxt:Init(self._sliderExp.transform, ResID.UI_ADDTXT, floatTime)
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalaxInfo, StarItem)
	
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	
	self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextpropertyPhalanx")
	self._nextPropertyPhalanx = Phalanx:New()
	self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, BaseNextPropertyItem)
	
	self._goLock = UIUtil.GetChildByName(self._transform, "goLock").gameObject
	
	local icon = UIUtil.GetChildByName(self._transform, "trsUp/item").gameObject
	self._baseIcon = BaseIconItem:New()
	self._baseIcon:Init(icon)	
	
	self._expEffect = UIEffect:New();
	self._expEffect:Init(self._sliderExp.transform, self._sliderExp.foregroundWidget, 3, "ui_refining_4")
	
	local starLabel = UIUtil.GetChildByName(self._transform, "UILabel", "StarLabel")
	self._starEffect = UIEffect:New()
	self._starEffect:Init(self._transform, self._sliderExp.backgroundWidget, 3, "ui_star")
	
	local txtCost = UIUtil.GetChildInComponents(txts, "txtCost");
	self._itemCount = ItemCountLabel:New()
	self._itemCount:Init(txtCost)
	
	self._timer = FixedTimer.New(function() self:Update(time) end, 0.2, - 1, false)
	self._timer:Start()
	self._timer:Pause(true)
end

function SubWingPanel:_InitListener()
	self._onClickBtnUpdateLevel = function(go) self:_OnClickBtnUpdateLevel(self) end
	UIUtil.GetComponent(self._btnUpdateLevel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUpdateLevel);
	self._onClickBtnRight = function(go) self:_OnClickBtnRight(self) end
	UIUtil.GetComponent(self._imgRight, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRight);
	self._onClickBtnLeft = function(go) self:_OnClickBtnLeft(self) end
	UIUtil.GetComponent(self._imgLeft, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLeft);
end

function SubWingPanel:Update()	
	local curWing = _WingManager.GetCurrentWingData()
	
	if(BackpackDataManager.GetProductTotalNumBySpid(curWing.needItem.itemId) >= curWing.needItem.itemCount) then
		WingProxy.SendUpdateWing()
	else
		self._timer:Pause(true)
		self._txtAutoLabel.text = _auto1
	end
	
end



function SubWingPanel:_OnClickBtnLeft()
	if(self._dress) then
		local temp = _WingManager.GetFashionDataById(self._dress.id - 1)
		if(temp) then
			self:_UpdateFashionData(temp)
			
		end
	end
end

function SubWingPanel:_OnClickBtnRight()
	if(self._dress) then
		local temp = _WingManager.GetFashionDataById(self._dress.id + 1)
		if(temp) then
			self:_UpdateFashionData(temp)			
		end
	end	
end

function SubWingPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	if(self._nextPropertyPhalanx) then
		self._nextPropertyPhalanx:Dispose()
		self._nextPropertyPhalanx = nil
	end
	
	if(self._curPropertyPhalanx) then
		self._curPropertyPhalanx:Dispose()
		self._curPropertyPhalanx = nil
	end
	
	self._phalanx:Dispose()
	self._phalanx = nil
	
	if(self._floatTxt) then
		self._floatTxt:Dispose()
		self._floatTxt = nil
	end
	if(self._uiWingModel) then
		self._uiWingModel:Dispose()
		self._uiWingModel = nil
	end
	
	if(self._starEffect) then
		self._starEffect:Dispose()
		self._starEffect = nil
		
	end
	
	if(self._expEffect) then
		self._expEffect:Dispose()
		self._expEffect = nil
	end
	
	if(self._itemCount) then
		self._itemCount:Dispose()
		self._itemCount = nil
	end
	
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil		
	end
end

function SubWingPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnUpdateLevel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnUpdateLevel = nil;
	UIUtil.GetComponent(self._imgRight, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRight = nil;
	UIUtil.GetComponent(self._imgLeft, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLeft = nil;
	
end

function SubWingPanel:_DisposeReference()
	
end

function SubWingPanel:UpdatePanel()
	self:UpdateLevel()
	self:UpdateFashionData()
end

function SubWingPanel:UpdateLevel()
	local wingData = _WingManager.GetCurrentWingData()
	
	self:UpdateExp()	
	
	local nextLeveldata = nil
	if(wingData) then
		nextLeveldata = _WingManager.GetNextStarConfig(wingData.id)
	end
	
	if(wingData) then
		local allFashionAttr = _WingManager.GetAllFashionAttr()
		self._curAttr:Init(wingData)
		self._curAttr:Add(allFashionAttr)
		local p = self._curAttr:GetPropertyAndDes()
		self._curPropertyPhalanx:Build(#p, 1, p)
		if(nextLeveldata) then
			self._goUp:SetActive(true)
			self._txtMaxNotice.text = ""
			self._nextAttr:Init(nextLeveldata)
			self._nextAttr:Sub(wingData)
			local p = self._nextAttr:GetPropertyAndDes()
			self._nextPropertyPhalanx:Build(#p, 1, p)
		else
			self._goUp:SetActive(false)
			self._txtMaxNotice.text = self._maxNotice	
			self._nextPropertyPhalanx:Build(0, 0, {})	
		end
	end
	
	self._txtPower.text = CalculatePower(wingData)
	local tempData = {}
	for i = 1, 10 do
		if(i <= wingData.lev) then
			tempData[i] = true
		else
			tempData[i] = false
		end
	end
	self._phalanx:Build(1, 10, tempData)
	
	if(wingData.needItem) then
		self._baseIcon:UpdateItem(ProductManager.GetProductById(wingData.needItem.itemId))
	end
end

function SubWingPanel:UpdateExp()
	local wingData = _WingManager.GetCurrentWingData()
	if(wingData.lev == _WingManager.WINGMAXLEVEL and wingData.rank == _WingManager.WINGMAXRANK) then
		self._txtExp.text = wingData.exp .. "/" .. wingData.exp
		self._sliderExp.value = 1
	else
		self._txtExp.text = wingData.curExp .. "/" .. wingData.exp
		self._sliderExp.value = wingData.curExp / wingData.exp
	end
	
	if(wingData.needItem) then
		self._itemCount:UpdateItemByData(BackpackDataManager.GetProductTotalNumBySpid(wingData.needItem.itemId), wingData.needItem.itemCount)		
	end	
end

function SubWingPanel:UpdateFashionData()
	local wingData = _WingManager.GetCurrentWingData()
	local curUsedata = _WingManager.GetFashionDataById(wingData.id)
	self:_UpdateFashionData(curUsedata)	
end

function SubWingPanel:_UpdateFashionData(data)
	local wingData = _WingManager.GetCurrentWingData()
	if(self._uiWingModel == nil) then			
		self._dress = data	
		self._uiWingModel = UIAnimationModel:New(self._dress, self._trsRoleParent, WingCreater)	
	else	
		self._dress = data	
		self._uiWingModel:ChangeModel(self._dress, self._trsRoleParent)	
	end
	
	self._imgRank.spriteName = "rank" .. self._dress.rank	
	self._txtName.text = tostring(self._dress.name)
	self._goLock:SetActive(data.state ~= _WingManager.WingState.HadActive)
end

function SubWingPanel:_OnClickBtnUpdateLevel()
	
	local curWing = _WingManager.GetCurrentWingData()
	
	SequenceManager.TriggerEvent(SequenceEventType.Guide.WING_UPGRADE)
	
	if(BackpackDataManager.GetProductTotalNumBySpid(curWing.needItem.itemId) >= curWing.needItem.itemCount) then
		if(self._timer) then
			self._timer:Pause(false)
			self._txtAutoLabel.text = _auto2			
		end
	else
		ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
		{id = curWing.needItem.itemId, msg = WingNotes.CLOSE_WINGPANEL, updateNote = WingNotes.UPDATE_WINGPANEL})
	end
	
end

local critExp = LanguageMgr.Get("wing/SubWingPanel/critExp")
function SubWingPanel:ShowUpdateLevelLabel(value)
	if(value > 0) then
		if(self._floatTxt) then
			if(value > 10) then
				self._floatTxt:Play(critExp .. value)
			else
				self._floatTxt:Play("+" .. value)				
			end
		end
	end
end

function SubWingPanel:ShowStarEffect()
	
	if(self._starEffect) then
		local wingData = _WingManager.GetCurrentWingData()
		if(wingData.lev ~= 0) then
			local item = self._phalanx:GetItem(wingData.lev)
			self._starEffect:Play()
			if(item) then
				local pos = item.itemLogic.transform.position
				self._starEffect:SetPos1(pos.x, pos.y)
			end
		end		
	end
	
	if(self._timer) then
		self._timer:Pause(true)
		self._txtAutoLabel.text = _auto1		
	end	
	
	if(self._expEffect) then
		self._expEffect:Play()
	end
end

function SubWingPanel:StopAdvanceTimer()
	if(self._timer) then
		self._timer:Pause(true)
		self._txtAutoLabel.text = _auto1
	end
end 