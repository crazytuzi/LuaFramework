--[[
新技能提示面板
lizhuangzhuang
2015年2月26日11:12:36
]]

_G.UISkillNewTips = BaseUI:new("UISkillNewTips");

UISkillNewTips.skillId = 0;
UISkillNewTips.timerKey = nil;
UISkillNewTips.closeTimerKey = nil;

function UISkillNewTips:Create()
	self:AddSWF("skillNewTips.swf",true,"top");
end

function UISkillNewTips:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
end

function UISkillNewTips:GetWidth()
	return 502;
end

function UISkillNewTips:GetHeight()
	return 300;
end


function UISkillNewTips:OnShow()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:DoLearnSkill();
	end,3000,1);
	local objSwf = self.objSwf;
	local cfg = t_skill[self.skillId];
	if cfg then
		objSwf.panel.loader.source = ResUtil:GetSkillIconUrl(cfg.icon,"64");
		objSwf.panel.tfName.text = cfg.name;
	end
	if self.objSwf then
		self.objSwf:gotoAndPlay(1);
		self.objSwf.panel:gotoAndPlay(1);
	end
end

function UISkillNewTips:OnHide()
	self.skillId = 0;
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	if self.closeTimerKey then
		TimerManager:UnRegisterTimer(self.closeTimerKey);
		self.closeTimerKey = nil;
	end
	SkillGuideManager:CheckNext();
end

function UISkillNewTips:Open(skillId)
	-- WriteLog(LogType.Normal,true,'-------------进入飞界面',skillId)
	if self.skillId > 0 then return; end
	self.skillId = skillId;
	self:Show();
end

function UISkillNewTips:OnHitAreaClick()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self:DoLearnSkill();
end

--学习技能
function UISkillNewTips:DoLearnSkill()
	SkillController:LearnSkill(self.skillId);
	if not self.closeTimerKey then
		self.closeTimerKey = TimerManager:RegisterTimer(function()
			self:Hide();
		end,3000,1);
	end
end

--向技能栏飞图标
function UISkillNewTips:DoFlyIcon(pos)
	local flyEndPos = UIMainSkill:GetSkillItemPos(pos);
	if not flyEndPos then
		self:Hide();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_skill[self.skillId];
	local flyVO = {};
	flyVO.objName = "FlyVO"
	flyVO.startPos = UIManager:PosLtoG(objSwf.panel.loader,0,0);
	flyVO.endPos = flyEndPos;
	flyVO.time = 1;
	flyVO.url = ResUtil:GetSkillIconUrl(cfg.icon,"64");
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 40;
	flyVO.tweenParam._height = 40;
	-- 技能图标飞到终点后的回调
	flyVO.onComplete = function()
		SkillModel:SetShortCut(self.pos,self.skillIds);
   		AutoBattleModel:ResetSpecialSkill(self.skillIds)
   		UIMainSkill:OnShortCutChange(self.pos)
	end 
	FlyManager:FlyIcon(flyVO);
	self:Hide();
end
--[[
	adder:houxudong
	date:2016/9/19 22:52:25
	返回技能栏设置
	SkillController:OnSkillShortCut(msg)
--]]

function UISkillNewTips:ListNotificationInterests()
	return {NotifyConsts.SkillShortCutChange};
end

function UISkillNewTips:HandleNotification(name,body)
	if name == NotifyConsts.SkillShortCutChange then
		if body.skillId == self.skillId then
			self:DoFlyIcon(body.pos);
			self.pos = body.pos;
			self.skillIds = body.skillId;
		end
	end
end