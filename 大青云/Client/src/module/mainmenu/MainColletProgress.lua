--[[
 采集progress 少-- 多
 wangshuai
]]

_G.UIMainColletProgress = BaseUI:new("UIMainColletProgress");

UIMainColletProgress.Name = 0;   --采集名称
UIMainColletProgress.time = 0;        --采集时间
UIMainColletProgress.currentTime = 0; --当前时间

function UIMainColletProgress:Create()
	self:AddSWF("mainCollectProgress.swf", true, "storyBottom");
end

function UIMainColletProgress:NeverDeleteWhenHide()
	return true;
end

function UIMainColletProgress:Open(name,time)
	self.Name = name;
	self.time = time;
	self:Show();
end;

function UIMainColletProgress:GetWidth()
	return 243;
end

function UIMainColletProgress:OnShow()
	self:StartProgress();
end;
function UIMainColletProgress:StartProgress()
	local objSwf = self.objSwf ;
	if not objSwf then return  end;
	objSwf.prog.maximum = self.time;
	objSwf.txtname.text = self.Name;
end;

function UIMainColletProgress:Update(dwInterval)
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	if self.time == 0 then return end;
	
	self.currentTime = self.currentTime + dwInterval;
	objSwf.prog.value = self.currentTime;

	if self.currentTime >= self.time - 20 then 
	self.currentTime = 0;
	self:Hide();
	end;
end;
function UIMainColletProgress:OnHide()
	self.Name = 0
	self.time = 0 
	self.currentTime = 0;
end;