--[[
卓越引导
lizhuangzhuang
2015年8月2日15:38:24
]]

_G.ZhuoyueGuideController = setmetatable({},{__index=IController})
ZhuoyueGuideController.name = "ZhuoyueGuideController";

ZhuoyueGuideController.isShowGuide = false;
ZhuoyueGuideController.closeGuideTimer = nil;

function ZhuoyueGuideController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_ZhuoyueGuide,self,self.OnZhuoyueGuide);
	MsgManager:RegisterCallBack(MsgType.SC_ZhuoyueGuideReward,self,self.OnZhuoyueGuideReward);
	ZhuoyueGuideModel:Init();
end

function ZhuoyueGuideController:OnLevelUp(oldLevel,newLevel)
	local openLevel = t_consts[92].val1;
	if oldLevel<openLevel and newLevel>=openLevel then
		--ZhuoyueGuideModel:UpdateToQuest();
		--self:ShowGuide();
		--UIMainFunc:ShowZhuoyueGuide();
	end
end

function ZhuoyueGuideController:IsOpen()
	local openLevel = t_consts[92].val1;
	return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end

function ZhuoyueGuideController:ShowGuide()
	-- TimerManager:RegisterTimer(function()
		-- self.isShowGuide = true;
		-- UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_Super,UIFuncGuide.Type_QuestSuper,StrConfig["funcguide004"]);
		-- self.closeGuideTimer = TimerManager:RegisterTimer(function()
			-- self.closeGuideTimer = nil;
			-- self:CloseGuide();
		-- end,30000,1);
	-- end,1000,1);
end

function ZhuoyueGuideController:CloseGuide()
	-- if self.isShowGuide then
		-- if self.closeGuideTimer then
			-- TimerManager:UnRegisterTimer(self.closeGuideTimer);
			-- self.closeGuideTimer = nil;
		-- end
		-- self.isShowGuide = false;
		-- UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestSuper);
	-- end
end

function ZhuoyueGuideController:OnZhuoyueGuide(msg)
	ZhuoyueGuideModel:SetInfo(msg.id,msg.state);
end

--请求卓越领奖
function ZhuoyueGuideController:GetReward()
	local msg = ReqZhuoyueGuideRewardMsg:new();
	msg.id = ZhuoyueGuideModel:GetId();
	MsgManager:Send(msg);
end

function ZhuoyueGuideController:OnZhuoyueGuideReward(msg)
	if msg.rst == 0 then
		
		ZhuoyueGuideModel:SetInfo(msg.nextId,msg.nextState);
	else
		
	end
end
