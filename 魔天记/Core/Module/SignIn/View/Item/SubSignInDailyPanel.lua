require "Core.Module.Common.UIComponent"
require "Core.Module.SignIn.View.Item.SubSignInDailyItem"

SubSignInDailyPanel = class("SubSignInDailyPanel", UIComponent);
local order = LanguageMgr.Get("SignIn/SubSignInDailyPanel/order")
local signDes = LanguageMgr.Get("SignIn/SubSignInDailyPanel/signDes")
function SubSignInDailyPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubSignInDailyPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubSignInDailyPanel:_Init()
	self._isInit = false
	self:_InitReference();
	self:_InitListener();
	
end

function SubSignInDailyPanel:_InitReference()
	-- local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
	--    self._txtSignMonth = UIUtil.GetChildInComponents(txts, "signMonth");
	self._txtSignCount = UIUtil.GetChildByName(self._transform, "UILabel", "signCount");
	self._txtReSign = UIUtil.GetChildByName(self._transform, "UILabel", "trsReSign/reSign");
	self._goResign = UIUtil.GetChildByName(self._transform, "trsReSign").gameObject
	self._btnReSign = UIUtil.GetChildByName(self._goResign, "UIButton", "btnReSign")
	self._btnSign = UIUtil.GetChildByName(self._transform, "UIButton", "btnSign")
	
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SubSignInDailyItem)
	self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")
end

function SubSignInDailyPanel:_InitListener()
	self._onClickBtnReSign = function(go) self:_OnClickBtnReSign() end
	UIUtil.GetComponent(self._btnReSign, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReSign);
	
	self._onClickBtnSign = function(go) self:_OnClickBtnSign() end
	UIUtil.GetComponent(self._btnSign, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSign);
end

function SubSignInDailyPanel:_OnClickBtnReSign()
	SignInProxy.SendReSign()
end

function SubSignInDailyPanel:_OnClickBtnSign()
	SignInProxy.SendSign()
end


function SubSignInDailyPanel:_Dispose()
	self:_DisposeReference();
	UIUtil.GetComponent(self._btnReSign, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnReSign = nil;
	
	UIUtil.GetComponent(self._btnSign, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSign = nil;
	
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
end



function SubSignInDailyPanel:_DisposeReference()
	
end

function SubSignInDailyPanel:UpdatePanel()
	local dailySignData = SignInManager.GetDailySignInData()
	local cansignIn = SignInManager.GetCanSignToday()
	self._btnSign.gameObject:SetActive(cansignIn)
	if(dailySignData) then
		local data = SignInManager.GetMonthSignInConfig()
		self._phalanx:Build(7, 5, data)
		local signCount = SignInManager.GetSignCount()
		self._txtSignCount.text = signCount .. order
		
		local count = SignInManager.GetTodayReSignCount()
		self._goResign:SetActive(count > 0 and(not cansignIn))
		
		
		self._txtReSign.text = tostring(count)
		self._scollview:ResetPosition()
		if(signCount >= 10) then
			if(signCount < 15) then
				self._scollview:MoveRelative(Vector3.up * 70)
			elseif signCount < 20 then
				self._scollview:MoveRelative(Vector3.up * 230)
			elseif signCount < 25 then
				self._scollview:MoveRelative(Vector3.up * 390)
			elseif signCount < 30 then
				self._scollview:MoveRelative(Vector3.up * 550)
			else
				self._scollview:MoveRelative(Vector3.up * 700)
			end
			self._scollview:UpdatePosition()
		end
	else
		self._txtSignCount.text = ""
		self._txtReSign.text = ""
		self._goResign:SetActive(false)
	end
	--    self._txtSignMonth.text = SignInManager.GetCurMonth() .. signDes
end 