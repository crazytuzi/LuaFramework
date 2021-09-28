
require "Core.Module.Common.UISubPanel"
local SubRideInfoPanel = class("SubRideInfoPanel", UISubPanel);

function SubRideInfoPanel:_InitReference()
	self._currentGo = nil
	self._isShowInstruction = false
	self._isInit = false
	
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/trsRoleParent");
	self._txtAccess = UIUtil.GetChildByName(self._transform, "UILabel", "txtAccess");
	self._txtDes = UIUtil.GetChildByName(self._transform, "UILabel", "txtDes");
	self._txtSpeedAdd = UIUtil.GetChildByName(self._transform, "UILabel", "txtSpeedAdd");	
	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName")
	self._btnInstruction = UIUtil.GetChildByName(self._transform, "UIButton", "btnInstruction");
	self._btnUse = UIUtil.GetChildByName(self._transform, "UIButton", "btnUse");
	self._btnCancle = UIUtil.GetChildByName(self._transform, "UIButton", "btnCancle");
	self._btnActive = UIUtil.GetChildByName(self._transform, "UIButton", "btnActive");	
	self._goRideInstruction = UIUtil.GetChildByName(self._transform, "tsRideInstruction").gameObject;
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "rideParent/phalanx");
	self._ridePhalanx = Phalanx:New();
	self._ridePhalanx:Init(self._phalanxInfo, RideItem, false)
	self._proPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx");
	self._proPhalanx = Phalanx:New();
	self._proPhalanx:Init(self._proPhalanxInfo, RidePropretyItem, false)	
	self._allProPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "allpropertyPhalanx");
	self._allProPhalanx = Phalanx:New();
	self._allProPhalanx:Init(self._allProPhalanxInfo, RidePropretyItem, false)
	
	self._pagePhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "pagePhalanx");
	self._pagePhalanx = Phalanx:New();
	self._pagePhalanx:Init(self._pagePhalanxInfo, CommonPageItem, true)
	
	self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "rideParent/phalanx")
	
	self.txtPower = UIUtil.GetChildByName(self._transform, "UILabel", "power/txtPower");
	
	self._cocDelegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._cocDelegate;
end

function SubRideInfoPanel:_OnCenterCallBack(go)
	
	if(self._isInit == false) then
		return
	end
	if(self._currentGo == go) then
		return
	end
	self._currentGo = go;
	local index = self._ridePhalanx:GetItemIndex(go)
	local item = self._pagePhalanx:GetItem(index)
	if(item) then
		item.itemLogic:SetToggle(true)
	end
	self._ridePhalanx:GetItem(index).itemLogic:_OnClickItem()
end

function SubRideInfoPanel:_DisposeReference()
	self._currentGo = nil
	
	--    self._btnTitle = nil;
	self._btnInstruction = nil;
	self._btnUse = nil;
	self._btnCancle = nil;
	self._btnActive = nil;
end

function SubRideInfoPanel:_InitListener()
	self._onClickBtnInstruction = function(go) self:_OnClickBtnInstruction(self) end
	UIUtil.GetComponent(self._btnInstruction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInstruction);
	self._onClickBtnUse = function(go) self:_OnClickBtnUse(self) end
	UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUse);
	self._onClickBtnCancle = function(go) self:_OnClickBtnCancle(self) end
	UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancle);
	self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
end

function SubRideInfoPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnInstruction, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnInstruction = nil;
	UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnUse = nil;
	UIUtil.GetComponent(self._btnCancle, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCancle = nil;
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnActive = nil;
end

function SubRideInfoPanel:_OnEnable()
	self:UpdatePanel()
end

function SubRideInfoPanel:_Dispose()
	self._ridePhalanx:Dispose()
	self._ridePhalanx = nil
	self._proPhalanx:Dispose()
	self._proPhalanx = nil
	self._pagePhalanx:Dispose()
	self._pagePhalanx = nil
	self._allProPhalanx:Dispose()
	self._allProPhalanx = nil;
	
	if self.tmpTimer then
		self.tmpTimer:Stop();
		self.tmpTimer = nil;
	end
	
	if(self._uiRideAnimationModel ~= nil) then
		self._uiRideAnimationModel:Dispose()
		self._uiRideAnimationModel = nil
	end
	self._currentGo = nil
	self._cocDelegate = nil;
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy()
	end
	self._goRideInstruction = nil
end

function SubRideInfoPanel:SetOpenVal(val)
	self.openParam = val;
end

local expAdd = LanguageMgr.Get("ride/rideItem/addexp")
function SubRideInfoPanel:UpdatePanel()
	
	local ridesData = RideManager.GetAllRideData()
	self._ridePhalanx:Build(1, table.getCount(ridesData), ridesData)
	self._pagePhalanx:BuildSpe(table.getCount(ridesData), {})
	
	if self._currentGo == nil then
		local idx = 1;
		
		if self.openParam then
			for i, v in ipairs(ridesData) do
				if v.info.id == self.openParam then
					idx = i;
					break;
				end
			end
		end
		local item = self._ridePhalanx:GetItem(idx);
		if item then
			self._isInit = true
			self.tmpTimer = Timer.New(function()
				self._centerOnChild:CenterOn(item.gameObject.transform);
			end, 0.1, 1, true):Start();
			--self._centerOnChild:CenterOn(item.gameObject.transform);
		end
	end
	
	local currentRideData = RideManager.GetCurrentRideData()
	if(currentRideData) then
		self._txtDes.text = currentRideData.info.desc
		local isActivate = currentRideData.info:GetIsActivate()
		
		local isUsed = currentRideData.info:GetIsUse()
		
		self._btnUse.gameObject:SetActive(isActivate and not isUsed)
		self._btnCancle.gameObject:SetActive(isActivate and isUsed)
		self._txtAccess.gameObject:SetActive(not isActivate)
		self._txtAccess.text = currentRideData.info.obtain_des;
		self._txtSpeedAdd.text = tostring(currentRideData.info.speed_per / 10)
		
		self._txtName.text = currentRideData.info.name
		self._txtName.color = ColorDataManager.GetColorByQuality(currentRideData.info.quality)
		local tempData = currentRideData.info:GetPropertyAndDes()
		
		self.txtPower.text = tostring(currentRideData.info:GetPower());
		
		
		local count = table.getCount(tempData)
		self._proPhalanx:Build(math.ceil((count - 1)) / 2 + 1, 2, tempData)
		local need = currentRideData.info:GetSynthetic()
		local count = BackpackDataManager.GetProductTotalNumBySpid(need.itemId)
		
		local flag = false
		flag =(count >= need.itemCount)
		self._btnActive.gameObject:SetActive((not isActivate) and flag)
		
	else
		self._btnActive.gameObject:SetActive(false)
		self._btnUse.gameObject:SetActive(false)
		self._btnCancle.gameObject:SetActive(false)
		self._txtSpeedAdd.text = "0"
		
		self._txtName.text = ""
	end
	
	if(self._uiRideAnimationModel == nil) then
		self._uiRideAnimationModel = UIAnimationModel:New(currentRideData.info, self._roleParent, RideModelCreater)
	else
		self._uiRideAnimationModel:ChangeModel(currentRideData.info, self._roleParent)
	end
	self._uiRideAnimationModel:SetScale(currentRideData.info.model_scale_rate)
	self:UpdateRidePanelAllProperty()
end

function SubRideInfoPanel:UpdateRidePanelAllProperty()
	local allRideProperty = RideManager.GetAllRideProperty()
	
	local count = table.getCount(allRideProperty)
	self._allProPhalanx:Build(math.ceil((count - 1)) / 2 + 1, 2, allRideProperty:GetAllPropertyAndDes())
end


function SubRideInfoPanel:_OnClickBtnActive()
	local id = RideManager.GetCurrentRideId();
	RideProxy.SendActivateRide(id)
end

function SubRideInfoPanel:_OnClickBtnInstruction()
	if(self._isShowInstruction) then
		self._goRideInstruction:SetActive(false)	
	else
		self._goRideInstruction:SetActive(true)
	end
	self._isShowInstruction = not self._isShowInstruction
	
end

function SubRideInfoPanel:_OnClickBtnUse()
	RideProxy.SendUseRide()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.MOUNT_USE, RideManager.GetCurrentRideId());
end

function SubRideInfoPanel:_OnClickBtnCancle()
	RideProxy.SendCancleRide()
end

return SubRideInfoPanel
