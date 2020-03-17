--[[
V计划，主界面

]]

_G.UIVplanMain = BaseUI:new("UIVplanMain")

UIVplanMain.tabButton = {};

function UIVplanMain:Create()
	self:AddSWF("vplanMainPanel.swf",true,"center")


	self:AddChild(UIVplanPrivilege		,VplanConsts.UItequan) -- 特权介绍
	self:AddChild(UIVplanNoviceBag		,VplanConsts.UIchouchong) -- 新手礼包
	self:AddChild(UIVplanLevelGift 		,VplanConsts.UIdengji)   -- 等级礼包
	self:AddChild(UIVplanTitleNew	    ,VplanConsts.UIchenghao) -- 称号礼包
	self:AddChild(UIVplanPowerNew			,VplanConsts.UIweili) -- 会员威力
	self:AddChild(UIVplanDailyReward	,VplanConsts.UImeiri) --每日奖励
	self:AddChild(UIMyVplanInfo			,VplanConsts.UIMyinfo) --我的信息
	self:AddChild(UIVplanBuyGift		,VplanConsts.UIBuyGift) --我的信息
	-- self:AddChild(UIVplanShop			,VplanConsts.UIshangcheng) --商城打折
	-- self:AddChild(UIVplanYear			,VplanConsts.UInianfei) --年费
	
end;

function UIVplanMain:OnLoaded(objSwf)
	objSwf.closepanle.click = function() self:ClosePanle() end;
	
	-- 特权介绍
	self.tabButton[VplanConsts.UItequan] = objSwf.btn1;
	self:GetChild(VplanConsts.UItequan):SetContainer(objSwf.childPanel);

	-- 新手礼包
	self.tabButton[VplanConsts.UIchouchong] = objSwf.btn2;
	self:GetChild(VplanConsts.UIchouchong):SetContainer(objSwf.childPanel);

	-- 每日礼包
	self.tabButton[VplanConsts.UImeiri] = objSwf.btn3;
	self:GetChild(VplanConsts.UImeiri):SetContainer(objSwf.childPanel);

	-- 等级礼包
	self.tabButton[VplanConsts.UIdengji] = objSwf.btn4;
	self:GetChild(VplanConsts.UIdengji):SetContainer(objSwf.childPanel);
	
	-- 专属称号
	self.tabButton[VplanConsts.UIchenghao] = objSwf.btn5;
	self:GetChild(VplanConsts.UIchenghao):SetContainer(objSwf.childPanel);
	
	-- 专属BUFF
	self.tabButton[VplanConsts.UIweili] = objSwf.btn6;
	self:GetChild(VplanConsts.UIweili):SetContainer(objSwf.childPanel);

	-- 我的信息
	self.tabButton[VplanConsts.UIMyinfo] = objSwf.btn7;
	self:GetChild(VplanConsts.UIMyinfo):SetContainer(objSwf.childPanel);
	
	-- 消费礼包
	self.tabButton[VplanConsts.UIBuyGift] = objSwf.btn8;
	self:GetChild(VplanConsts.UIBuyGift):SetContainer(objSwf.childPanel);

	-- self.tabButton[VplanConsts.UInianfei] = objSwf.btn8;
	-- self:GetChild(VplanConsts.UInianfei):SetContainer(objSwf.childPanel);
	
	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;

	objSwf.btnopenyueV_btn.click = function() self:OpenYueVplan()end;    --v计划开通会员
	objSwf.btnopennianV_btn.click = function() self:OPenNianVplan()end;  --v计划开通年费会员
	objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
end;

function UIVplanMain:OpenYueVplan()
	VplanController:ToMRecharge()
end;

function UIVplanMain:OPenNianVplan()
	VplanController:ToYRecharge()
end;

function UIVplanMain:OnShow()
	self:OnTabButtonClick(VplanConsts.UIMyinfo)
end;

function UIVplanMain:OnTabButtonClick(name)
	if not self.tabButton[name] then return end;
	local child = self:GetChild(name);
	if not child then return end;
	self.tabButton[name].selected = true;
	self:ShowChild(name)

end;

function UIVplanMain:ClosePanle()
	self:Hide();
end;

function UIVplanMain:OnHide()

end;
-- 是否缓动
function UIVplanMain:IsTween()
	return true;
end

--面板加载的附带资源
function UIVplanMain:WithRes()
	return {"vplanPrivilegePanel.swf"}
end

--面板类型
function UIVplanMain:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIVplanMain:IsShowSound()
	return true;
end

function UIVplanMain:IsShowLoading()
	return true;
end

