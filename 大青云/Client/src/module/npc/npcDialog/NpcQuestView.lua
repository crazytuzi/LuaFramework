--[[
NPC任务接取完成对话
lizhuangzhuang
2014年8月13日10:32:36
]]

_G.UINpcQuestPanel = BaseUI:new("UINpcQuestPanel");

UINpcQuestPanel.objAvatar = nil;--人物模型
UINpcQuestPanel.scene = nil;
UINpcQuestPanel.npc = nil;--NPC对象
UINpcQuestPanel.questId = 0;--任务ID

UINpcQuestPanel.autoTimerKey = nil;

UINpcQuestPanel.TweenScale = 10;

function UINpcQuestPanel:Create()
	self:AddSWF("npcQuestPanel.swf", true, "center");
end

function UINpcQuestPanel:OnLoaded( objSwf )
	objSwf.mcGirl._visible = false;
	objSwf.mcGirl.hitTestDisable = true;
	objSwf.btnEffect._visible       = false;
	objSwf.btnEffect.hitTestDisable = true;
	objSwf.npcLoader.hitTestDisable = true;
	--
	objSwf.btnClose.click       = function() self:OnBtnCloseClick(); end
	objSwf.btn.click            = function() self:OnBtnClick(); end
	objSwf.btnHit.click         = function() self:OnBtnHitClick(); end
	objSwf.rewardList.itemClick = function(e) self:OnRewardItemClick(); end
	RewardManager:RegisterListTips( objSwf.rewardList );
end

function UINpcQuestPanel:OnDelete()
	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UINpcQuestPanel:IsShowLoading()
	return true;
end

function UINpcQuestPanel:GetWidth()
	return 828;
end

function UINpcQuestPanel:GetHeight()
	return 289;
end

function UINpcQuestPanel:IsTween()
	return true;
end

function UINpcQuestPanel:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UINpcQuestPanel:DoTweenHide()
	self:DoHide();
end

function UINpcQuestPanel:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

function UINpcQuestPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local npcCfg = self.npc:GetCfg();
	if npcCfg then
		objSwf.labelNpcName.text = npcCfg.name;
	end
	--draw3D
	self:DrawNpc();
	--显示任务
	local questVO = QuestModel:GetQuest(self.questId);
	if not questVO then return end
	questVO:PlaySound() -- 播放对话声音
	local questState = questVO:GetState();
	if questState == QuestConsts.State_Going then
		--
	elseif questState == QuestConsts.State_CanFinish then
		ClickLog:Send(ClickLog.T_QuestPanel_Finish,self.questId);
	elseif questState == QuestConsts.State_CanAccept then
		ClickLog:Send(ClickLog.T_QuestPanel_Accept,self.questId);
	end
	local npcTalk, btnLabel, btnDisabled = questVO:GetNpcTalk()
	objSwf.btn.label    = btnLabel
	objSwf.btn.disabled = btnDisabled
	objSwf.tfTalk.text  = npcTalk
	objSwf.tfTime.htmlText = "";
	--显示任务奖励
	local rewardList = questVO:GetShowRewards()
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push( unpack(rewardList) );
	objSwf.rewardList:invalidateData();
	self:StopAutoTimer();
	if questVO:GetType()==QuestConsts.Type_Trunk and (questVO:GetState()==QuestConsts.State_CanFinish 
		or questVO:GetState()==QuestConsts.State_CanAccept) and
		MainPlayerModel.humanDetailInfo.eaLevel<=QuestConsts.AutoLevel then
		local autoTime = 5;
		objSwf.tfTime.htmlText = string.format(StrConfig["npcDialog006"],autoTime);
		self.autoTimerKey = TimerManager:RegisterTimer(function(count)
			if count == autoTime then
				if self:DoQuest() then
					self:Hide();
				end
			else
				if not self.objSwf then return; end
				objSwf.tfTime.htmlText = string.format(StrConfig["npcDialog006"],autoTime-count);
			end
		end,1000,autoTime);
	end
	if questState==QuestConsts.State_CanFinish or questState==QuestConsts.State_CanAccept then
		self:CheckShowGuide(questState)
	end
end

function UINpcQuestPanel:CheckShowGuide(questState)
	local playerLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	if playerLvl < QuestConsts.AutoLevel then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local showFunc = function()
			objSwf.btnEffect._visible  = true;
			objSwf.mcGirl._visible = true;
			objSwf.mcGirl:gotoAndPlay(1);
		end
		local unshowFunc = function()
			objSwf.btnEffect._visible  = false;
			objSwf.mcGirl._visible = false;
			objSwf.mcGirl:gotoAndStop(1);
		end
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_NPC,
			showtype = UIFuncGuide.ST_Private,
			showFunc = showFunc,
			unshowFunc = unshowFunc,
		});
	end
end

-- 停止自动做任务计时
function UINpcQuestPanel:StopAutoTimer()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
end

--打开面板
--@param npcId  NPCID
--@param questId 任务ID
function UINpcQuestPanel:Open(npcId, questId)
	if UITrunkDungeonInfo:IsShow() then
		self:Hide()
		return;
	end
	local npc = NpcModel:GetNpcByNpcId(npcId);
	if not npc then return; end
	self.npc = npc;
	self.questId = questId;
	self:Show();
end

--远离NPC导致任务对话框关闭，同样相当于点  领取继续
function UINpcQuestPanel:Close()
	self:DoQuest();
	self:Hide();
end

--点击下方按钮 
function UINpcQuestPanel:OnBtnClick()
	self:StopAutoTimer();
	if self:DoQuest() then
		self:Hide();
	end
end

--点击面板
function UINpcQuestPanel:OnBtnHitClick()
	if self:DoQuest() then
		self:Hide();
	end
end

--点击关闭
function UINpcQuestPanel:OnBtnCloseClick()
	self:DoQuest()
	self:Hide();
end

--点击奖励Item
function UINpcQuestPanel:OnRewardItemClick(e)
	if self:DoQuest() then
		self:Hide();
	end
end

--执行任务处理
function UINpcQuestPanel:DoQuest()
	local questVO = QuestModel:GetQuest(self.questId);
	if not questVO then return; end
	local questState = questVO:GetState();
--	WriteLog(LogType.Normal,true,'-------------questId',self.questId,questState)
	if questState == QuestConsts.State_CanAccept then
		questVO:SendAccept()
		return true;
	end
	if questState == QuestConsts.State_CanFinish then
		-- self.questId = QuestConsts.LastDungeonQuest
		if self:CheckIsTruckDungeon(self.questId) then 
			local func = function()
				questVO:SendSubmit()
			end
			UITrunkDungeonInfo:Open(func,self.questId)
		else
			questVO:SendSubmit()
		end
		return true;
	end
	return false;
end

-- adder:houxudong date:2016/9/5
-- 判断是不是主线副本任务
function UINpcQuestPanel:CheckIsTruckDungeon(questId)
	if questId == QuestConsts.LastDungeonQuest then
		return true
	elseif questId == QuestConsts.LastDungeonQuestTwo then
		return true
	elseif questId == QuestConsts.LastDungeonQuestThree then
		return true
	elseif questId == QuestConsts.LastDungeonQuestFour then
		return true
	elseif questId == QuestConsts.LastDungeonQuestFive then
		return true
	end
	return false
end

function UINpcQuestPanel:HandleNotification(name,body)
	if name == NotifyConsts.QuestFinish then
		if body.id == self.questId then
			local objSwf = self.objSwf;
			if not objSwf then return; end
			local startPos = UIManager:PosLtoG( objSwf.rewardList, 0, 0 );
			local rewardList = QuestUtil:GetTrunkRewardList( self.questId, true );
			RewardManager:FlyIcon( rewardList, startPos, 6, true, 60 );
			self:Hide();
		end
	end
end

function UINpcQuestPanel:ListNotificationInterests()
	return { NotifyConsts.QuestFinish };
end

--画Npc模型
function UINpcQuestPanel:DrawNpc()
	local swf = self.objSwf;
	if not swf then return; end
	
	local drawCfg = UIDrawNpcCfg[self.npc.npcId];
	if not drawCfg then
		drawCfg = {
						EyePos = _Vector3.new(0,-40,20),
						LookPos = _Vector3.new(0,0,10),
						VPort = _Vector2.new(800,800),
						Rotation = 0
					};
	end
	
	if not self.scene then
		self.scene = UISceneDraw:new(self:GetName(), swf.npcLoader, drawCfg.VPort, false);
	end
	self.scene:SetUILoader(swf.npcLoader)
	
	self.scene:SetScene('v_panel_npc.sen', function()
		self:DrawAvatar(drawCfg);
	end );
	self.scene:SetDraw( true );
	
end

function UINpcQuestPanel:DrawAvatar(drawCfg)
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end

	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.objAvatar = NpcAvatar:NewNpcAvatar(self.npc.npcId);
	self.objAvatar:InitAvatar();
	
	self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
	self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );

	local cfgnpc = t_npc[self.npc.npcId]
	local cfgmodel = t_model[cfgnpc.look];
	self.objAvatar:DoAction(cfgmodel.san_leisure, false, function() end)
	
	local markers = self.scene:GetMarkers();
	local indexc = "marker2";
	self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Npc);
	
end

function UINpcQuestPanel:OnHide(name)
	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	
	NpcController:WhenCloseDialog(self.npc.npcId);
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	UIFuncGuide:Close(UIFuncGuide.Type_NPC);
	TipsManager:Hide();
end


