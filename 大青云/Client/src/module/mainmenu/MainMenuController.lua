--[[
主界面控制
lizhuangzhuang
2014年7月21日19:35:50
]]

_G.MainMenuController = setmetatable( {}, {__index = IController} )
MainMenuController.name = "MainMenuController"

function MainMenuController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_GetPKRule,self,self.OnSubmitPKState)
	CControlBase:RegControl( self, true );
end

function MainMenuController:OnEnterGame()
	local curhp = MainPlayerModel.humanDetailInfo.eaHp
	local alhp = MainPlayerModel.humanDetailInfo.eaMaxHp
	local cur = (curhp/alhp)*100;
	if cur < 20 then 
		if UIBeatenAnimation:IsShow() then 
			UIBeatenAnimation:onBeating()
		else
			UIBeatenAnimation:Show();
		end
	end;
	UIImportantNotice:Show();
end

MainMenuController.inHideTitleMap = false;		--是否隐藏称号的地图
MainMenuController.inShowFightMap = false;		--在隐藏称号的地图是否显示战斗力
function MainMenuController:OnChangeSceneMap()
	local mapId = MainPlayerController:GetMapId();
	UIMapName:Open(mapId);							--版署版本要临时屏蔽@liaoying
	UITargetDropInfoDetail:Hide();
	--在活动类地图关闭一些提醒UI
	local mapCfg = t_map[mapId];
	if mapCfg then
		if mapCfg.unActivityNotice then
			UIActivityNotice:ShowWhenActivity(true);     --在活动地图里面显示活动提醒图标
			UIRemind:ShowWhenActivity(true);             --下发消息球提醒
			UIUnionAcitvity:SetShowState(true)           --左侧下发帮派消息提醒
			UICaveBossTip:Hide()
		else
			UIActivityNotice:ShowWhenActivity(false);
			UIRemind:ShowWhenActivity(false);
			UIUnionAcitvity:SetShowState(false)
		end
		MascotComeNoticeManager:CloseCfg();
		UIConfirm:Close(CPlayerMap.uiconfirmID)
	end
	--
	self.inHideTitleMap = mapCfg.showTitle == 1;
	if self.inHideTitleMap then
		self.inShowFightMap = mapCfg.showAttr == 1;
	else
		self.inShowFightMap = false;
	end
	UIFloat:ClearAllActivity();
end

function MainMenuController:OnLeaveSceneMap()
	if CPlayerMap:GetCurMapID() == MapConsts.FirstMap then
		UIMainFunc:UnHideTop();
		UIMainYunYingFunc:Show();
	end
end

-- 快捷键打开面板
function MainMenuController:OnKeyDown(dwKeyCode)
	--跨服下的处理
	if MainPlayerController.isInterServer then
		return;
	end
	local uiName = MainMenuConsts.HotKeyMap[dwKeyCode];
	local uiPanel = uiName and UIManager:GetUI(uiName);
	if not uiPanel then return; end
	--大摆筵席活动打不开M地图
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		FloatManager:AddSkill("当前活动中不能打开M地图")
		return
	end
	if uiPanel:IsShow() then
		uiPanel:Hide();
	else
		uiPanel:Show();
	end
end

function MainMenuController:Update()

end

--显示主界面
function MainMenuController:ShowMainMenu()
	if _G.sceneTest then
		return;
	end
	-- UIMakinobattleSkillView:Show()  --测试
	UIMainTop:Show();
	UIMainHead:Show();
	UIMainMap:Show();
	UIMainSkill:Show();
	UIMainTeammate:Show();
	UIMainQuest:Show();--任务
	UIMainLvQuestTitle:Show();--目标
	UIMainYunYingFunc:Show();
	UIMainFunc:Show();
	UIChat:Show();
	UIFloatBottom:Show();
	UIRemind:Show();
	UIFloat:Show();
	UIFuncGuide:Show();
	UIMainAttr:Show();
	UISkillNameEffect:Show();
	--UIParticle:Show(); TT759 同时取消从角色模型飞到当前经验条所在位置的绿色特效。 yanghongbin/jianghaoran 2016-8-17
	UILingliEffect:Show();

	AchievementBtnView:Hide();
	UIGoal:Show()
	UIMainXiuweiPool:Show()
	UIFalieffect:Show();
  
end

--主UI预加载
function MainMenuController:Preload()
--	UIMakinobattleSkillView:Show()   --测试
	UIMainTop:Show();
	UIMainHead:Show();
	UIMainMap:Show();
	UIMainSkill:Show();
	UIMainTeammate:Show();
	UIMainQuest:Show();
	UIMainLvQuestTitle:Show();
	UIMainFunc:Show();
	UIChat:Show();
	UIFloatBottom:Show();
	UIRemind:Show();
	UIFloat:Show();
	UIMainAttr:Show();
	UIMainYunYingFunc:Show();
	UIFuncGuide:Show();
	UISkillNameEffect:Show();
	AchievementBtnView:Show();
	ImgUtil:InitFace();
	UIGoal:Show()
	UIMainXiuweiPool:Show()
	--
	UIMainTop:Hide();
	UIMainHead:Hide();
	UIMainMap:Hide();
	UIMainSkill:Hide();
	UIMainTeammate:Hide();
	UIMainQuest:Hide();
	UIMainLvQuestTitle:Hide();
	UIMainFunc:Hide();
	UIChat:Hide();
	UIFloatBottom:Hide();
	UIRemind:Hide();
	UIFloat:Hide();
	UIMainAttr:Hide();
	UIMainYunYingFunc:Hide();
	UIFuncGuide:Hide();
	UISkillNameEffect:Hide();
	AchievementBtnView:Hide();
	UIGoal:Hide()
	UIMainXiuweiPool:Hide()
end

--隐藏右侧任务(副本)
function MainMenuController:HideRight()
	UIMainQuest:Hide();
	UIMainLvQuestTitle:Hide();
	UIMainFunc:CloseTop();
end

--恢复右侧任务
function MainMenuController:UnhideRight()
	UIMainQuest:Show();
	UIMainLvQuestTitle:Show();
	UIMainFunc:UnCloseTop();
end

--隐藏右侧和上侧(活动)
function MainMenuController:HideRightTop()
	UIMainFunc:CloseTop();
	UIMainQuest:Hide();
	UIMainLvQuestTitle:Hide();
	DominateRouteFuncTip:Hide();
end

--恢复右侧和上侧
function MainMenuController:UnhideRightTop()
	UIMainFunc:UnCloseTop();
	UIMainQuest:Show();
	UIMainLvQuestTitle:Show();
end

--主界面全部隐藏(竞技场)
function MainMenuController:HideAll()

end

--恢复主界面
function MainMenuController:UnhideAll()

end

--发送PK数据
function MainMenuController:OnSendPkState(pkid,myselfpk)
	local msg = ReqSendPKRuleMsg:new();
	msg.pkid = pkid;
	if msg.pkid ~= 7 then MsgManager:Send(msg); return; end;
	msg.myselfpk = myselfpk;
	MsgManager:Send(msg);
end

------------------------------[[服务器返回的消息]]-------------------------------
--返回PK数据
function MainMenuController:OnSubmitPKState(msg)
	MainRolePKModel:UpDataPkState(msg)
end