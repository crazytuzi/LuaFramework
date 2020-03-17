--[[
	2015年12月17日18:11:17
	wangyanwei
	圣诞活动主界面
]]

_G.UIChristmasBasic = BaseUI:new('UIChristmasBasic');

UIChristmasBasic.tabButton = {};

function UIChristmasBasic:Create()
	self:AddSWF('mainChristmasPanel.swf',true,'center');
	
	self:AddChild(UIChristmasDonate,"christmasDonate");					--圣诞兑换
	self:AddChild(UIChristmasIntrusion,"christmasIntrusion");			--雪人入侵
	self:AddChild(UIChristmasExchange,"christmasExchange");			    --圣诞兑换
end

UIChristmasBasic.buttonTabel = {};
function UIChristmasBasic:OnLoaded(objSwf)
	self:GetChild('christmasDonate'):SetContainer(objSwf.load_ui);
	self:GetChild('christmasIntrusion'):SetContainer(objSwf.load_ui);
	self:GetChild('christmasExchange'):SetContainer(objSwf.load_ui);

	objSwf.btn_close.click = function () self:Hide(); end
	
	self.tabButton['christmasDonate'] = objSwf.pagebtn_donate;
	self.tabButton['christmasIntrusion'] = objSwf.pagebtn_intrusion;
	self.tabButton['christmasExchange'] = objSwf.pagebtn_exchange;
	
	for i , v in pairs(self.tabButton) do
		v.click = function () self:OnTabClickHandler(i); end
	end
end

function UIChristmasBasic:OnShow()
	if not self.tabName or self.tabName == '' then
		self:OnTabClickHandler('christmasDonate');
	else
		if self.tabButton[self.tabName] then
			self:OnTabClickHandler(self.tabName);
		end
		self.tabName = nil;
	end
end

UIChristmasBasic.tabName = nil;
function UIChristmasBasic:Open(name)
	if not name then return end
	self.tabName = name;
	if self:IsShow() then
		self:OnShow();
		return
	end
	self:Show();
end

function UIChristmasBasic:OnHide()
	self.tabName = nil;
end

UIChristmasBasic.oldTabButton = '';
function UIChristmasBasic:OnTabClickHandler(name)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.oldTabButton = name;
	if not self.tabButton[name] then
		return ;
	end
	local child = self:GetChild(name);
	if not child then
		return ;
	end
	self.tabButton[name].selected = true;
	
	self:ShowChild(name);
end

function UIChristmasBasic:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	for i , v in ipairs(self.buttonTabel) do
		self.buttonTabel[i] = nil;
	end
end

function UIChristmasBasic:GetWidth()
	return 1019;
end

function UIChristmasBasic:GetHeight()
	return 659;
end

--父面板处理↓↓↓↓↓↓↓↓↓↓↓

function UIChristmasBasic:IsTween()
	return true;
end

function UIChristmasBasic:WithRes()
	return {"christmasDonate.swf"};
end

function UIChristmasBasic:IsShowSound()
	return true;
end

function UIChristmasBasic:GetPanelType()
	return 1;
end

function UIChristmasBasic:IsShowLoading()
	return true;
end