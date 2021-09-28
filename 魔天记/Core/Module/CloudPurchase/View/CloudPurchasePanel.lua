require "Core.Module.Common.Panel"

local CloudPurchasePanel = class("CloudPurchasePanel", Panel);
local CloudPurchaseRewardItem = require "Core.Module.CloudPurchase.View.Item.CloudPurchaseRewardItem"
local CloudPurchaseRecoderLabel = require "Core.Module.CloudPurchase.View.Item.CloudPurchaseRecoderLabel"
function CloudPurchasePanel:New()
	self = {};
	setmetatable(self, {__index = CloudPurchasePanel});
	return self
end


function CloudPurchasePanel:_Init()
	self._isInit = true
	self._isShow = false
	self:_InitReference();
	self:_InitListener();
	self:UpdatePanel()
end

function CloudPurchasePanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtBuyCount = UIUtil.GetChildInComponents(txts, "txtBuyCount");
	self._txtDes = UIUtil.GetChildInComponents(txts, "txtDes");
	self._txtLimit = UIUtil.GetChildInComponents(txts, "txtLimit");
	self._txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
	self._txtTitleDes = UIUtil.GetChildInComponents(txts, "txtTitleDes");
	self._txtNum = UIUtil.GetChildInComponents(txts, "txtNum");
	self._txtCost = UIUtil.GetChildInComponents(txts, "txtCost");
	self._txtTime = UIUtil.GetChildInComponents(txts, "txtTime");
	self._txtGetDes = UIUtil.GetChildInComponents(txts, "txtGetDes");
	self._txtRewardCount = UIUtil.GetChildInComponents(txts, "txtRewardCount")
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnLastRecorder = UIUtil.GetChildInComponents(btns, "btnLastRecorder");
	self._btnHelper = UIUtil.GetChildInComponents(btns, "btnHelper");
	self._btnBuy = UIUtil.GetChildInComponents(btns, "btnBuy");
	self._btnGet = UIUtil.GetChildInComponents(btns, "btnGet");
	
	self._trsState0 = UIUtil.GetChildByName(self._trsContent, "goState0")
	self._trsState1 = UIUtil.GetChildByName(self._trsContent, "goState1")	
	
	self._rewardItem = CloudPurchaseRewardItem:New()
	local item = UIUtil.GetChildByName(self._trsContent, "item")
	self._rewardItem:Init(item)
	
	local phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
	self._rewardPhalanx = Phalanx:New()
	self._rewardPhalanx:Init(phalanxInfo, CloudPurchaseRewardItem)
	
	local recorderPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollview/recorderphalanx")
	self._recoderPhalanx = Phalanx:New()
	self._recoderPhalanx:Init(recorderPhalanxInfo, CloudPurchaseRecoderLabel)
	
	self._trsHelper = UIUtil.GetChildByName(self._trsContent, "trsHelper")
	self._txtHelper = UIUtil.GetChildByName(self._trsHelper, "UILabel", "Label")
	self._goMask = UIUtil.GetChildByName(self._trsHelper, "mask")
end

function CloudPurchasePanel:_InitListener()
	self:_AddBtnListen(self._btnClose.gameObject)
	self:_AddBtnListen(self._btnLastRecorder.gameObject)
	self:_AddBtnListen(self._btnHelper.gameObject)
	self:_AddBtnListen(self._btnBuy.gameObject)
	self:_AddBtnListen(self._btnGet.gameObject)
	self:_AddBtnListen(self._goMask)
	
	
end

function CloudPurchasePanel:_OnBtnsClick(go)
	if go == self._btnClose.gameObject then
		self:_OnClickBtnClose()
	elseif go == self._btnLastRecorder.gameObject then
		self:_OnClickBtnLastRecorder()
	elseif go == self._btnHelper.gameObject then
		self:_OnClickBtnHelper()
	elseif go == self._btnBuy.gameObject then
		self:_OnClickBtnBuy()
	elseif go == self._btnGet.gameObject then
		self:_OnClickBtnGet()
	elseif go == self._goMask.gameObject then
		self:_OnClickBtnHelper()
	end
end

function CloudPurchasePanel:_OnClickBtnClose()
	ModuleManager.SendNotification(CloudPurchaseNotes.CLOSE_CLOUDPURCHASEPANEL)
end

function CloudPurchasePanel:_OnClickBtnLastRecorder()
	CloudPurchaseProxy.SendGetLastCloudPurchaseRecorder()
end

function CloudPurchasePanel:_OnClickBtnHelper()
	if(self._isInit) then
		self._isInit = false
		self._txtHelper.text = LanguageMgr.Get("CloudPurchasePanel/help")
	end
	
	self._isShow = not self._isShow
	SetUIEnable(self._trsHelper, self._isShow)
end

function CloudPurchasePanel:_OnClickBtnBuy()
	ModuleManager.SendNotification(CloudPurchaseNotes.OPEN_CLOUDPURCHASEBUYPANEL)
end

function CloudPurchasePanel:_OnClickBtnGet()
	CloudPurchaseProxy.SendGetCloudPurchaseReward()
end

function CloudPurchasePanel:_Dispose()
	self:_DisposeReference();
	self._rewardItem:Dispose()
	self._rewardItem = nil
	
	self._rewardPhalanx:Dispose()
	self._rewardPhalanx = nil
	
	self._recoderPhalanx:Dispose()
	self._recoderPhalanx = nil
	
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
end

function CloudPurchasePanel:_DisposeReference()
	self._btnClose = nil;
	self._btnLastRecorder = nil;
	self._btnHelper = nil;
	self._btnBuy = nil;
	self._btnGet = nil;
	self._txtBuyCount = nil;
	self._txtDes = nil;
	self._txtLimit = nil;
	self._txtPrice = nil;
	self._txtTitleDes = nil;
	self._txtNum = nil;
	self._txtCost = nil;
	self._txtTime = nil;
	self._txtGetDes = nil;
end
local max = LanguageMgr.Get("CloudPurchasePanel/max")
local min = LanguageMgr.Get("CloudPurchasePanel/min")

local state0 = LanguageMgr.Get("CloudPurchasePanel/state0")
local state1 = LanguageMgr.Get("CloudPurchasePanel/state1")

local rewardstate0 = LanguageMgr.Get("CloudPurchasePanel/rewardstate0")
local rewardstate1 = LanguageMgr.Get("CloudPurchasePanel/rewardstate1")
local rewardstate2 = LanguageMgr.Get("CloudPurchasePanel/rewardstate2")
local fen = LanguageMgr.Get("CloudPurchasePanel/fen")

function CloudPurchasePanel:UpdatePanel()
	self.config = CloudPurchaseManager.GetTodayConfig()
	
	if(self.config) then
		local state = CloudPurchaseManager.GetPurchaseState()
		if(state == 0) then--购买状态
			SetUIEnable(self._trsState0, true)
			SetUIEnable(self._trsState1, false)
			
			self._txtTitleDes.text = state0
		elseif state == 1 then--非购买状态
			if(self._timer == nil) then
				self._timer = FixedTimer.New(function() self:UpdateTime(time) end, 1, - 1, false)
				self._timer:Start()
			end
			SetUIEnable(self._trsState0, false)
			SetUIEnable(self._trsState1, true)
			self._txtTitleDes.text = state1
			local rewardState = CloudPurchaseManager.GetRewardState()
			
			if(rewardState == 0) then
				self._txtGetDes.text = rewardstate0				
			elseif rewardState == 1 then
				self._txtGetDes.text = rewardstate1
			elseif rewardState == 2 then
				self._txtGetDes.text = rewardstate2
			end
		end
		--[[  ]]
		self._txtPrice.text = self.config.value
		self._txtCost.text = self.config.cost
		self._rewardItem:UpdateItem(self.config.careerReward)		
		self._rewardPhalanx:Build(1, #self.config.rewards, self.config.rewards)
		self:UpdateMotifyInfo()	
	end
end

local _GetTime = GetTime
local _GetTimeByStr = GetTimeByStr
function CloudPurchasePanel:UpdateTime()
	local gt = self.config.yunyingConfig.closeTime - _GetTime()
	
	if(gt <= 0) then
		self._timer:Stop()
		ModuleManager.SendNotification(CloudPurchaseNotes.CLOSE_CLOUDPURCHASEPANEL)
		return
	end
	self._txtTime.text = _GetTimeByStr(gt)
end

function CloudPurchasePanel:UpdateMotifyInfo()
	self:UpdateBuyCount()
	self:UpdateRecorder()
end

function CloudPurchasePanel:UpdateRecorder()
	
	local state = CloudPurchaseManager.GetPurchaseState()
	local content = {}
	if(state == 0) then
		content = CloudPurchaseManager.GetBuyRecorders()
	elseif state == 1 then
		content = CloudPurchaseManager.GetRewardRecorders()
	end
	self._recoderPhalanx:Build(#content, 1, content)
end

function CloudPurchasePanel:UpdateBuyCount()
	-- local config = CloudPurchaseManager.GetTodayConfig()
	local allBuyCount = CloudPurchaseManager.GetAllBuyCount()
	self._txtBuyCount.text = tostring(allBuyCount)
	if(allBuyCount < self.config.least_number) then
		self._txtDes.text = min
		self._txtLimit.text = self.config.least_number
	else
		self._txtDes.text = max
		self._txtLimit.text = self.config.most_number
	end
	
	local num = math.max(1, math.floor(allBuyCount / self.config.basics_number))
	local myBuyCount = CloudPurchaseManager.GetMyBuyCount()
	self._txtRewardCount.text = "(" .. num .. fen .. ")"
	self._txtNum.text = "(" .. myBuyCount .. fen .. ")"
end
return CloudPurchasePanel 