--[[
防沉迷面板
zhangshuhui
2015年3月26日16:57:20
]]

_G.UIFangChenMiView = BaseUI:new("UIFangChenMiView")

UIFangChenMiView.onlinetime = nil;
UIFangChenMiView.consts = 46;

UIFangChenMiView.PENCENTZERO = 0;	--0%收益
UIFangChenMiView.PENCENTFULL = 100;	--100%收益
UIFangChenMiView.PENCENTHOUR = 60;	--一小时60分钟
UIFangChenMiView.isNoTip = false;

function UIFangChenMiView:Create()
	self:AddSWF("fangchenmiPanel.swf", true, "center")
end

function UIFangChenMiView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	--现在就去
	objSwf.fangchenmipanel.btnok.click = function() self:OnBtnOkClick() end
	
	--稍后再去
	objSwf.fangchenmipanel.btncancel.click = function() self:OnBtnCancelClick() end
	
	--前往认证
	objSwf.fangchenmirenzhengpanel.btnok.click = function() self:OnBtnOkRenZhengClick() end
	
	--关闭
	objSwf.fangchenmirenzhengpanel.btncancel.click = function() self:OnBtnCancelClick() end
end

function UIFangChenMiView:IsShowSound()
	return true;
end

function UIFangChenMiView:OnShow(name)
	if self.isNoTip then 
		return
	end
	self:ShowInfo();
end

--点击关闭按钮
function UIFangChenMiView:OnBtnCloseClick()
	self:cbNoTipState()
	self:Hide();
end

function UIFangChenMiView:OnBtnOkClick()
	self:cbNoTipState()
	Version:FangChenMiBrowse();
	
end
function UIFangChenMiView:cbNoTipState()
	local objSwf = self.objSwf;
	if objSwf.cbNoTip.selected then
		self.isNoTip = true;
	end
end
function UIFangChenMiView:OnBtnCancelClick()
	self:cbNoTipState()
	self:Hide();
end

function UIFangChenMiView:OnBtnOkRenZhengClick()
	self:cbNoTipState()
	Version:FangChenMiBrowse();
end

--显示列表
function UIFangChenMiView:ShowInfo()
	if self.onlinetime then
		self:ShowFangChenMiInfo();
	else
		self:ShowFangChenMiRenZhengInfo();
	end
end

--显示防沉迷
function UIFangChenMiView:ShowFangChenMiInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.fangchenmipanel._visible = true;
	objSwf.fangchenmirenzhengpanel._visible = false;
	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local str = t_consts[self.consts].param;
	
	local pencet = 0;
	local list = {};
	local t = split(str,'#');
	for i=1,#t do
		local t1 = split(t[i],',');
		local vo = {};
		vo.left = tonumber(t1[1]);
		vo.pencent = tonumber(t1[2]);
		table.push(list,vo);
	end
	
	--倒序
	table.sort(list,function(A,B)
		if A.left > B.left then
			return true;
		else
			return false;
		end
	end);
	
	local onlinetime = self.onlinetime;
	--针对于使用gm指令的验证
	local yushu = self.onlinetime % self.PENCENTHOUR;
	if yushu > 0 and yushu ~= 30 then
		if yushu < 30 then
			onlinetime = onlinetime - yushu;
		else
			onlinetime = onlinetime - yushu + 30;
		end
	end
	for i,vo in pairs(list) do
		if vo then
			if self.onlinetime >= vo.left then
				if vo.pencent == self.PENCENTZERO then
					objSwf.tfContent.htmlText = StrConfig['fangchenmi3'];
				elseif vo.pencent == self.PENCENTFULL then
					objSwf.tfContent.htmlText = string.format( StrConfig['fangchenmi1'], onlinetime / self.PENCENTHOUR);
				else
					objSwf.tfContent.htmlText = string.format( StrConfig['fangchenmi2'], onlinetime / self.PENCENTHOUR, vo.pencent);
				end
				break;
			end
		end
	end
end

--显示防沉迷认证
function UIFangChenMiView:ShowFangChenMiRenZhengInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.fangchenmipanel._visible = false;
	objSwf.fangchenmirenzhengpanel._visible = true;
	
	objSwf.tfContent.htmlText = StrConfig['fangchenmi4'];
end
function UIFangChenMiView:OpenPanel(onlinetime)
	if onlinetime and onlinetime ~= 0 then
		self.onlinetime = onlinetime
	end
	
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end