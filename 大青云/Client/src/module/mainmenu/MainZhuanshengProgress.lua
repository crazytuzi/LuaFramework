

_G.UIMainZhuanshengProgress = BaseUI:new("UIMainZhuanshengProgress");

UIMainZhuanshengProgress.Name = 0;   --采集名称
UIMainZhuanshengProgress.time = 0;        --采集时间
UIMainZhuanshengProgress.currentTime = 0; --当前时间

function UIMainZhuanshengProgress:Create()
	self:AddSWF("mainZhuanshengProgress.swf", true, "storyBottom");
end

function UIMainZhuanshengProgress:NeverDeleteWhenHide()
	return true;
end

function UIMainZhuanshengProgress:Open(name,time)
	self.Name = name;
	self.time = time;
	self:Show();
end;

function UIMainZhuanshengProgress:GetWidth()
	return 343;
end

function UIMainZhuanshengProgress:OnShow()
	self.currentTime = 0;
	self:StartProgress();
end;
function UIMainZhuanshengProgress:StartProgress()
	local objSwf = self.objSwf ;
	if not objSwf then return  end;
	objSwf.prog.maximum = self.time;
	objSwf.txtname.text = self.Name;
end;

function UIMainZhuanshengProgress:Update(dwInterval)
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	if self.time == 0 then return end;
	
	self.currentTime = self.currentTime + dwInterval;
	objSwf.prog.value = self.currentTime;
	local process = math.floor(self.currentTime/100)
	objSwf.txtProcess.text = '转生完成：'..process.."%"
	if self.currentTime >= self.time then 
	self.currentTime = 0;
	self:Hide();
	end;
end;
function UIMainZhuanshengProgress:OnHide()
	self.Name = 0
	self.time = 0 
	self.currentTime = 0;
end;