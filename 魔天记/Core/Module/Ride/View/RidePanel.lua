require "Core.Module.Common.Panel"
require "Core.Module.Ride.View.Item.RideItem"
require "Core.Module.Ride.View.Item.RidePropretyItem"
require "Core.Module.Common.CommonPageItem"
require "Core.Module.Common.UIAnimationModel"
require "Core.Role.ModelCreater.RideModelCreater"

local SubRideInfoPanel = require "Core.Module.Ride.View.Item.SubRideInfoPanel"
local SubRideSoulPanel = require "Core.Module.Ride.View.Item.SubRideSoulPanel"
RidePanel = class("RidePanel", Panel);

function RidePanel:_Init()
	RideManager.ResetCurrentRideId()
	RideProxy.ResetRideFeedMaterials()	
	self._panelIndex = 1
	self:_InitReference();
	self:_InitListener();
	self._toggles = {self._toggleInfo, self._toggleSoul}	
	self._toggleSoul.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.RideFeed))
	self._panels = {}
	self._panels[1] = SubRideInfoPanel.New(self._trsInfo)	
	self._panels[2] = SubRideSoulPanel.New(self._trsSoul)
	-- self._isShowInstruction = false 
	-- self._isInit = false
	-- self:UpdateRidePanel()
	-- self:UpdateRidePanelAllProperty()	
end

function RidePanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");	
	self._toggleInfo = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnInfo");	
	self._toggleSoul = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnSoul");	
	self._trsInfo = UIUtil.GetChildByName(self._trsContent, "RidePanel")
	self._trsSoul = UIUtil.GetChildByName(self._trsContent, "RideSoulPanel")
	self._goTipInfo = UIUtil.GetChildByName(self._toggleInfo, "tip").gameObject
	self._goTipSoul = UIUtil.GetChildByName(self._toggleSoul, "tip").gameObject
	
	
	-- self._roleParent = UIUtil.GetChildByName(self._trsContent, "imgRole/trsRoleParent"); 
	-- self._txtAccess = UIUtil.GetChildByName(self._trsContent,"UILabel", "txtAccess");
	-- self._txtDes = UIUtil.GetChildByName(self._trsContent,"UILabel","txtDes"); 
	-- self._txtSpeedAdd = UIUtil.GetChildByName(self._trsContent,"UILabel", "txtSpeedAdd");	
	-- self._txtName = UIUtil.GetChildByName(self._trsContent,"UILabel", "txtName")
	-- self._btnInstruction = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnInstruction");
	-- self._btnUse = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnUse");
	-- self._btnCancle = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnCancle");
	-- self._btnActive = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnActive");	
	-- self._goRideInstruction = UIUtil.GetChildByName(self._trsContent, "tsRideInstruction").gameObject;
	-- self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "rideParent/phalanx");
	-- self._ridePhalanx = Phalanx:New();
	-- self._ridePhalanx:Init(self._phalanxInfo, RideItem, false)
	-- self._proPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "propertyPhalanx");
	-- self._proPhalanx = Phalanx:New();
	-- self._proPhalanx:Init(self._proPhalanxInfo, RidePropretyItem, false)	
	-- self._allProPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "allpropertyPhalanx");
	-- self._allProPhalanx = Phalanx:New();
	-- self._allProPhalanx:Init(self._allProPhalanxInfo, RidePropretyItem, false)
	-- self._pagePhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "pagePhalanx");
	-- self._pagePhalanx = Phalanx:New();
	-- self._pagePhalanx:Init(self._pagePhalanxInfo, CommonPageItem, true)
	-- self._centerOnChild = UIUtil.GetChildByName(self._trsContent, "UICenterOnChild", "rideParent/phalanx")
	-- self._cocDelegate = function(go) self:_OnCenterCallBack(go) end
	-- self._centerOnChild.onCenter = self._cocDelegate;
end

-- function RidePanel:_OnCenterCallBack(go)
-- 	if(self._isInit == false) then
-- 		return
-- 	end
-- 	if(self._currentGo == go) then
-- 		return
-- 	end
-- 	self._currentGo = go;
-- 	local index = self._ridePhalanx:GetItemIndex(go)
-- 	local item = self._pagePhalanx:GetItem(index)
-- 	if(item) then
-- 		item.itemLogic:SetToggle(true)
-- 	end
-- 	self._ridePhalanx:GetItem(index).itemLogic:_OnClickItem()
-- end
function RidePanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnInfo = function(go) self:_OnClickBtnInfo(self) end
	UIUtil.GetComponent(self._toggleInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInfo);
	self._onClickBtnSoul = function(go) self:_OnClickBtnSoul(self) end
	UIUtil.GetComponent(self._toggleSoul, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSoul);
	-- self._onClickBtnCancle = function(go) self:_OnClickBtnCancle(self) end
	-- UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancle);
	-- self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
	-- UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
end

function RidePanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(RideNotes.CLOSE_RIDEPANEL)
end

function RidePanel:_OnClickBtnInfo()
	self:ChangePanel(1)
end

function RidePanel:_OnClickBtnSoul()
	self:ChangePanel(2)
end
-- function RidePanel:_OnClickBtnActive()
-- 	local id = RideManager.GetCurrentRideId();
-- 	RideProxy.SendActivateRide(id)
-- end
-- function RidePanel:_OnClickBtnInstruction()
-- 	if(self._isShowInstruction) then
-- 		self._goRideInstruction:SetActive(false)	 
-- 	else
-- 		self._goRideInstruction:SetActive(true)
-- 	end
-- 	self._isShowInstruction = not self._isShowInstruction
-- end
-- function RidePanel:_OnClickBtnUse()
-- 	RideProxy.SendUseRide()
-- 	SequenceManager.TriggerEvent(SequenceEventType.Guide.MOUNT_USE, RideManager.GetCurrentRideId());
-- end
-- function RidePanel:_OnClickBtnCancle()
-- 	RideProxy.SendCancleRide()
-- end
function RidePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	RideProxy.ResetRideFeedMaterials()
	
	for i, v in pairs(self._panels) do
		v:Dispose()
		v = nil
	end
	-- self._ridePhalanx:Dispose()
	-- self._ridePhalanx = nil
	-- self._proPhalanx:Dispose()
	-- self._proPhalanx = nil
	-- self._pagePhalanx:Dispose()
	-- self._pagePhalanx = nil
	-- self._allProPhalanx:Dispose()
	-- self._allProPhalanx = nil;
	-- if(self._uiRideAnimationModel ~= nil) then
	-- 	self._uiRideAnimationModel:Dispose()
	-- 	self._uiRideAnimationModel = nil
	-- end
	-- self._currentGo = nil
	-- self._cocDelegate = nil;
	-- if self._centerOnChild and self._centerOnChild.onCenter then
	-- 	self._centerOnChild.onCenter:Destroy()
	-- end
	-- self._goRideInstruction = nil
end

function RidePanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._toggleInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnInfo = nil;
	UIUtil.GetComponent(self._toggleSoul, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSoul = nil;
	-- UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnCancle = nil;
	-- UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnActive = nil;
end

function RidePanel:_DisposeReference()
	self._btn_close = nil;
	
end

function RidePanel:SetOpenVal(val)
	for i, v in pairs(self._panels) do
		self._panels[i]:SetOpenVal(val);
	end
end

function RidePanel:ChangePanel(index)
	self._panelIndex = index or 1
	
	for i, v in pairs(self._panels) do
		if i == index then
			self._panels[i]:Enable()
			self._toggles[self._panelIndex].value = true
		else
			self._panels[i]:Disable()
		end
	end
end

-- local expAdd = LanguageMgr.Get("ride/rideItem/addexp")
function RidePanel:UpdateRidePanel()
	self._panels[self._panelIndex]:UpdatePanel()
	self:UpdateTip()
	-- local ridesData = RideManager.GetAllRideData()
	-- self._ridePhalanx:Build(1, table.getCount(ridesData), ridesData)
	-- self._pagePhalanx:BuildSpe(table.getCount(ridesData), {})
	-- if(self._currentGo == nil and self._ridePhalanx:GetItem(1) ~= nil) then
	-- 	self._isInit = true
	-- 	self._centerOnChild:CenterOn(self._ridePhalanx:GetItem(1).gameObject.transform)
	-- end
	-- local currentRideData = RideManager.GetCurrentRideData()
	-- if(currentRideData) then
	-- 	self._txtDes.text = currentRideData.info.desc
	-- 	local isActivate = currentRideData.info:GetIsActivate()
	-- 	local isUsed = currentRideData.info:GetIsUse()
	-- 	self._btnUse.gameObject:SetActive(isActivate and not isUsed)
	-- 	self._btnCancle.gameObject:SetActive(isActivate and isUsed)
	-- 	self._txtAccess.gameObject:SetActive(not isActivate)
	-- 	self._txtAccess.text = currentRideData.info.obtain_des;
	-- 	self._txtSpeedAdd.text = tostring(currentRideData.info.speed_per / 10)
	-- 	self._txtName.text = currentRideData.info.name
	-- 	self._txtName.color = ColorDataManager.GetColorByQuality(currentRideData.info.quality)
	-- 	local tempData = currentRideData.info:GetPropertyAndDes()
	-- 	local count = table.getCount(tempData)
	-- 	self._proPhalanx:Build(math.ceil((count - 1)) / 2 + 1, 2, tempData)
	-- 	local need = currentRideData.info:GetSynthetic()
	-- 	local count = BackpackDataManager.GetProductTotalNumBySpid(need.itemId)
	-- 	local flag = false
	-- 	flag =(count >= need.itemCount)
	-- 	self._btnActive.gameObject:SetActive((not isActivate) and flag)
	-- else
	-- 	self._btnActive.gameObject:SetActive(false)
	-- 	self._btnUse.gameObject:SetActive(false)
	-- 	self._btnCancle.gameObject:SetActive(false)
	-- 	self._txtSpeedAdd.text = "0"
	-- 	self._txtName.text = ""
	-- end
	-- if(self._uiRideAnimationModel == nil) then
	-- 	self._uiRideAnimationModel = UIAnimationModel:New(currentRideData.info, self._roleParent, RideModelCreater)
	-- else
	-- 	self._uiRideAnimationModel:ChangeModel(currentRideData.info, self._roleParent)
	-- end
end

function RidePanel:UpdateTip()
	self._goTipInfo:SetActive(RideManager.GetCanActive())
	self._goTipSoul:SetActive(false)
end

function RidePanel:ShowUpdateEffect()
	if(self._panels[2]) then
		self._panels[2]:ShowUpdateEffect()
	end
end

-- function RidePanel:UpdateRidePanelAllProperty()
-- 	-- local allRideProperty = RideManager.GetAllRideProperty()
-- 	-- local count = table.getCount(allRideProperty)
-- 	-- self._allProPhalanx:Build(math.ceil((count - 1)) / 2 + 1, 2, allRideProperty:GetAllPropertyAndDes())
-- end
