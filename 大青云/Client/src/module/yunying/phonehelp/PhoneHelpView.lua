--[[
	2016年1月18日, PM 06:11:34
	wangyanwei
	手机助手APP
]]

_G.UIPhoneHelp = BaseUI:new('UIPhoneHelp');

function UIPhoneHelp:Create()
	self:AddSWF('phoneHelp.swf',true,'center');
end

function UIPhoneHelp:OnLoaded(objSwf)
	objSwf.txt_android.text = StrConfig['phoneHelp1'];
	objSwf.txt_apple.text = StrConfig['phoneHelp2'];
	objSwf.btn_Last.click = function () self:LastClick(); end
	objSwf.btn_Next.click = function () self:NextClick(); end
	
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_android.click = function() self:OnBtnAndroidClick(); end
	objSwf.btn_apple.click = function() self:OnBtnAppleClick(); end
	objSwf.btn_apple.disabled = true;
	objSwf.load_erweima.source = ResUtil:GetPhoneHelpErweima(Version:GetName());
end

function UIPhoneHelp:WithRes()
	local list = {};
	for i=1,UIPhoneHelp.MaxPicNum do
		local url = "resfile/icon/phonehelp/phonehelp" .. i .. ".jpg"
		table.push(list,url);
	end
	return list;
end

function UIPhoneHelp:OnShow()
	self:InitPic();
	self:TimeTween();
end

function UIPhoneHelp:LastClick()
	if self.tweening then
		return
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self:TweemPic(true);
	self:TimeTween();
end

function UIPhoneHelp:NextClick()
	if self.tweening then
		return
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self:TweemPic();
	self:TimeTween();
end

function UIPhoneHelp:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.load_1._y = self.initLoad1Y ;
	objSwf.load_2._y = self.initLoad2Y ;
	self.picIndex = 1;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.initLoad1Y = nil;
	self.initLoad2Y = nil;
	self.TweenLengthNum = math.abs(self.TweenLengthNum);
end

UIPhoneHelp.picIndex = 1;
UIPhoneHelp.MaxPicNum = 4;
UIPhoneHelp.initLoad1Y = nil;
UIPhoneHelp.initLoad2Y = nil;
function UIPhoneHelp:InitPic()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local picIndex = self.picIndex;
	local picUrl = ResUtil:GetPhoneHelpIcon(picIndex);
	local nextPicUrl = ResUtil:GetPhoneHelpIcon(picIndex + 1);
	objSwf.load_1.source = picUrl;
	objSwf.load_2.source = nextPicUrl;
	self.initLoad1Y = objSwf.load_1._y;
	self.initLoad2Y = objSwf.load_2._y;
	self.picIndex = self.picIndex + 1;
	self.tweening = false;
end

UIPhoneHelp.TweenLengthNum = 450;
function UIPhoneHelp:TimeTween()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		self:TweemPic();
	end
	self.timeKey = TimerManager:RegisterTimer(func,3500);
end

UIPhoneHelp.tweening = false;
function UIPhoneHelp:TweemPic(_left)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tweening = true;
	local tweenLength = self.TweenLengthNum;
	
	local lastLoad1Y = objSwf.load_1._y;
	local lastLoad2Y = objSwf.load_2._y;
	if _left then
		self.picIndex = self.picIndex - 1 >= 1 and self.picIndex - 1 or self.MaxPicNum ;
	else
		self.picIndex = self.picIndex + 1 <= self.MaxPicNum and self.picIndex + 1 or 1;
	end
	Tween:To(objSwf.load_1 , 0.5,{_y = objSwf.load_1._y + tweenLength},{onComplete = function ()
		if objSwf.load_1._y > lastLoad1Y then
			objSwf.load_1.source = ResUtil:GetPhoneHelpIcon(self.picIndex);
			self.tweening = false;
		end
	end},false)
	Tween:To(objSwf.load_2 , 0.5,{_y = objSwf.load_2._y - tweenLength},{onComplete = function ()
		if objSwf.load_2._y > lastLoad2Y then
			objSwf.load_2.source = ResUtil:GetPhoneHelpIcon(self.picIndex);
			self.tweening = false;
		end
	end},false)
	self.TweenLengthNum = - self.TweenLengthNum;
end

function UIPhoneHelp:OnBtnAndroidClick()
	Version:DownPhoneAppAndroid();
end

function UIPhoneHelp:OnBtnAppleClick()
	Version:DownPhoneAppIOS();
end

function UIPhoneHelp:GetWidth()
	return 1055
end

function UIPhoneHelp:GetHeight()
	return 650
end

function UIPhoneHelp:IsTween()
	return true;
end

function UIPhoneHelp:GetPanelType()
	return 1;
end

function UIPhoneHelp:IsShowSound()
	return true;
end

function UIPhoneHelp:IsShowLoading()
	return true;
end