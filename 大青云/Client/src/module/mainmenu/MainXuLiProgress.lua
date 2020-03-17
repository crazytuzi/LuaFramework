--[[
	蓄力Progress  少 -- 多
	wangshuai
]]

_G.UIMainXuLiProgress = BaseUI:new("UIMainXuLiProgress");

UIMainXuLiProgress.skillName = "";	--技能名称
UIMainXuLiProgress.totalTime = 0;        --技能时间
UIMainXuLiProgress.currentTime = 0; --当前时间
UIMainXuLiProgress.isShowBomb = false;--是否在显示爆炸效果
UIMainXuLiProgress.isPlayAnimation = false;
function UIMainXuLiProgress:Create()
	self:AddSWF("mainXuLiProgress.swf", true, "interserver");
end

function UIMainXuLiProgress:OnLoaded(objSwf)
	objSwf.playOver = function() self:OnPlayOver(); end
end

function UIMainXuLiProgress:NeverDeleteWhenHide()
	return true;
end

function UIMainXuLiProgress:Start(skillName,time)
	if self.isPlayAnimation == true then return end;
	self.totalTime = time;
	self.skillName = skillName;
	self.currentTime = 0;
	self.isShowBomb = false;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

--@param isend 0中段,1蓄力满
function UIMainXuLiProgress:End(isend)
	if self.isPlayAnimation == true then
		if isend == 0 then
			self:Hide();
		else
			local objSwf = self.objSwf;
			if not objSwf then self:Hide(); end
			self.objSwf:play();
			self.isShowBomb = true;
		end
	end
end

function UIMainXuLiProgress:OnShow()
	local objSwf = self.objSwf;
	self.objSwf:gotoAndStop(1);
	self:StartProgress();
	self.isPlayAnimation = true;
end;
function UIMainXuLiProgress:StartProgress()
	local objSwf = self.objSwf ;
	if not objSwf then return  end;
	objSwf.txtname.text = self.skillName;
end;


--特效播放完
function UIMainXuLiProgress:OnPlayOver()
	if self.isShowBomb then
		self:Hide();
	end
end

function UIMainXuLiProgress:Update(dwInterval)
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	if self.totalTime <= self.currentTime then 
		self:Hide();
		return ;
	end;
	if self.isShowBomb then
		return;
	end
	self.currentTime = self.currentTime + dwInterval;
	local percent = toint(self.currentTime/self.totalTime*110);
	percent = percent > 110 and 110 or percent;
	self.objSwf:gotoAndStop(percent);
end

function UIMainXuLiProgress:OnHide()
	self.skillName = nil;
	self.totalTime = 0;
	self.currentTime = 0;
	local objSwf = self.objSwf;
	if objSwf then
		objSwf:stop();
	end
	self.isPlayAnimation = false;
end;