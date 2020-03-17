--[[
	2015年9月29日, PM 03:02:44
	wangyanwei
	成就主界面按钮
]]

_G.AchievementBtnView = BaseUI:new('AchievementBtnView');

function AchievementBtnView:Create()
	self:AddSWF('achievementSmall.swf',true,'bottom');
end

function AchievementBtnView:OnLoaded(objSwf)
	objSwf.btn_open.click = function () FuncManager:OpenFunc(FuncConsts.Achievement); end
end

function AchievementBtnView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local funcCfg = t_funcOpen[FuncConsts.Achievement];
	if not funcCfg then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	objSwf.btn_open.visible = level >= funcCfg.open_level and true or false;
	self:OnGetIsShow();
end

function AchievementBtnView:OnHide()
	
end

function AchievementBtnView:OnShowBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.showState then objSwf.btn_open.visible = false; return end
	local funcCfg = t_funcOpen[FuncConsts.Achievement];
	if not funcCfg then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	objSwf.btn_open.visible = level >= funcCfg.open_level and true or false;
end

AchievementBtnView.showState = true;
function AchievementBtnView:ChangeShowType()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.showState = true;
	self:OnShowBtn();
end

function AchievementBtnView:ChangeHideType()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.showState = false;
	self:OnShowBtn();
end

function AchievementBtnView:OnGetIsShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local achievementEffect = AchievementModel:GetInComplete();
	if achievementEffect or AchievementModel:GetInCompletePointReward() then
		objSwf.btn_open.effect._visible = true;
	else
		objSwf.btn_open.effect._visible = false;
	end
	if AchievementModel:GetInCompletePointReward() then
		objSwf.btn_open.effect._visible = true;
	end
end

function AchievementBtnView:GetWidth()
	return 185
end

function AchievementBtnView:GetHeight()
	return 50
end

function AchievementBtnView:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:OnShowBtn();
		end
	elseif name == NotifyConsts.AchievementUpData then
		self:OnGetIsShow();
	end
end

function AchievementBtnView:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.AchievementUpData,
	}
end