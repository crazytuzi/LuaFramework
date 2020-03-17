--[[
	连续打击progress 多-- 少
	wangshuai
]]

_G.UIMainLianXuDaJiProgress = BaseUI:new("UIMainLianXuDaJiProgress");

UIMainLianXuDaJiProgress.Name = 0;   --技能名称
UIMainLianXuDaJiProgress.time = 0;        --技能时间
UIMainLianXuDaJiProgress.currentTime = 0; --当前时间

function UIMainLianXuDaJiProgress:Create()
	self:AddSWF("mainLianXuDaJiProgress.swf", true, "interserver");
end

function UIMainLianXuDaJiProgress:NeverDeleteWhenHide()
	return true;
end

function UIMainLianXuDaJiProgress:Open(name,time)
	self.Name = name;
	self.time = time;
	self:Show();
end;
 
function UIMainLianXuDaJiProgress:OnShow()
	self:StartProgress();
end;
function UIMainLianXuDaJiProgress:StartProgress()
	local objSwf = self.objSwf ;
	if not objSwf then return end;
	objSwf.txtname.text = self.Name;
	objSwf.procc.maximum = self.time;
	self.currentTime = self.time - 200;
end;
function UIMainLianXuDaJiProgress:Update(dwInterval)
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end;

	self.currentTime = self.currentTime - dwInterval;
	local ti = self.currentTime / 1000;
	local strTimeRest = toint( ti, -1 ).."."..toint( (ti * 10) % 10, 1 ); -- 转换为"N.N"格式
	local tx = string.format(StrConfig["mainmenuProgress01"],strTimeRest);
	objSwf.timetxt.text = tx;
	objSwf.procc.value = self.currentTime;
	if self.currentTime <= 0 then 
		self:Hide();
	end;
end;
function UIMainLianXuDaJiProgress:OnHide()
	self.Name = 0
	self.time = 0 
	self.currentTime = 0;
end;