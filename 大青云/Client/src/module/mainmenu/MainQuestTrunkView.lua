--[[
新手任务追踪面板 <15级别 通过新手期后的上方主任务栏显示 通过主线任务表中的主线剧情是否存在判断是否显示这个
2015年4月22日12:04:39
haohu
]]

_G.UIMainQuestTrunk = BaseUI:new("UIMainQuestTrunk");

function UIMainQuestTrunk:Create()
	self:AddSWF( "mainPageTaskTrunk.swf", true, nil );
end

function UIMainQuestTrunk:OnLoaded( objSwf )
	objSwf.mcGirl._visible = false;
	objSwf.mcGirl.hitTestDisable = true;
	--
	objSwf.txtDes.hitTestDisable = true;
	--objSwf.btnGoal.textField.autoSize = "center"
	objSwf.btnTitle.click    = function() self:OnBtnTitleClick() end
	objSwf.btnTitle.rollOver = function() self:OnBtnTitleRollOver() end
	objSwf.btnTitle.rollOut  = function() self:OnBtnTitleRollOut() end
	objSwf.btnGoal.click  = function() self:OnBtnGoalClick() end
	objSwf.btnGuide.click = function() self:OnBtnGuideClick() end
end

function UIMainQuestTrunk:OnShow()
	self:UpdateShow();
	QuestGuideManager:OnEnterGame()
end

function UIMainQuestTrunk:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then
		self:ClearShow()
		return
	end
	-- 任务标题
	objSwf.btnTitle.htmlLabel = questVO:GetTitleLabel();
	-- 任务描述
	local cfg = questVO:GetCfg();
	objSwf.txtDes.text = string.format( "%s", cfg.des ); -- 缩进
	-- 任务目标
	objSwf.btnGoal.htmlLabel = questVO:GetContentLabel(QuestColor.CONTENT_FONTSIZE);
	-- 故事标题
	objSwf.questTitle.htmlText = cfg.new_headline;
	-- 故事
	objSwf.questStory.htmlText  = cfg.new_story;
	-- 刷新特效
	if questVO:GetPlayRefresh() then
		objSwf.refreshEffect:playEffect(1);
	end
end

function UIMainQuestTrunk:ClearShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnTitle.htmlLabel = ""
	objSwf.txtDes.text = ""
	objSwf.btnGoal.htmlLabel = ""
end

function UIMainQuestTrunk:GetWidth()
	return 236;
end

function UIMainQuestTrunk:OnBtnTitleClick()
	if not QuestConsts.IsOpenTrunk then
		return;
	end
	UIQuest:Open( QuestConsts.Type_Trunk );
end

function UIMainQuestTrunk:OnBtnTitleRollOver()
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	local questId   = questVO:GetId()
	local questCfg  = questVO:GetCfg()
	UIQuestTips:Show(questCfg.name, QuestUtil:GetTrunkRewardList(questId));
end

function UIMainQuestTrunk:OnBtnTitleRollOut()
	UIQuestTips:Hide();
end

function UIMainQuestTrunk:OnBtnGoalClick()
	self:DoGuide();
end

function UIMainQuestTrunk:OnBtnGuideClick()
	self:DoGuide();
end

function UIMainQuestTrunk:ShowTrunkGuide(visible)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if visible then
		local showFunc = function()
			if not QuestConsts.IsNewPlayerTrunk then return; end
			if not objSwf then return; end
			objSwf.btnEffect._visible  = true;
			objSwf.mcGirl._visible = true;
			objSwf.mcGirl:gotoAndPlay(1);
		end
		local unshowFunc = function()
			if not QuestConsts.IsNewPlayerTrunk then return; end
			if not objSwf then return; end
			objSwf.btnEffect._visible  = false;
			objSwf.mcGirl._visible = false;
			objSwf.mcGirl:gotoAndStop(1);
		end
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_Quest,
			showtype = UIFuncGuide.ST_Private,
			showFunc = showFunc,
			unshowFunc = unshowFunc,
		});
	else
		UIFuncGuide:Close(UIFuncGuide.Type_Quest);
	end
end

function UIMainQuestTrunk:PlayFinishEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf._visible then return; end
	local effPos = UIManager:PosLtoG( objSwf, -122, 20 );
	UIEffectManager:PlayEffect( ResUtil:GetQuestFinishEff(), effPos );
end
function UIMainQuestTrunk:PlayNewTrunkEffect()
	if self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf._visible then return; end
	local effPos = UIManager:PosLtoG( objSwf, 113, 30 );
	UIEffectManager:PlayEffect( ResUtil:GetQuestTrunkNewEff(), effPos );
end
function UIMainQuestTrunk:DoGuide()
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return end;
	questVO:Proceed();
end

function UIMainQuestTrunk:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestRefreshList,
		NotifyConsts.PlayerAttrChange,
	}
end

function UIMainQuestTrunk:HandleNotification( name, body )
	if name == NotifyConsts.QuestAdd or name == NotifyConsts.QuestRemove or
			name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestRefreshList then
		self:UpdateShow();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:UpdateShow();
		end
	end
end