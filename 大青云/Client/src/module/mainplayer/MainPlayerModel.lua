--
-- Created by IntelliJ IDEA.
-- User: stefan
-- Date: 2014/7/23
-- Time: 15:08
-- To change this template use File | Settings | File Templates.
--
_G.classlist['MainPlayerModel'] = 'MainPlayerModel'
_G.MainPlayerModel = Module:new();
MainPlayerModel.objName = 'MainPlayerModel'
MainPlayerModel.mainRoleID = 1;
MainPlayerModel.hasInit = false;--是否已初始化
MainPlayerModel.humanDetailInfo = PlayerInfo:new();
MainPlayerModel.sMeShowInfo = nil
MainPlayerModel.sMePlayerInfo = nil
MainPlayerModel.allDropItem = {}
MainPlayerModel.speed = 0
MainPlayerModel.guid = nil;

MainPlayerModel.redundantBackTime = 0; --回城CD剩余时间
MainPlayerModel.timerKey = nil;  -- 计时器

MainPlayerModel.lines = {}

MainPlayerModel.timerKeyLevelUpEffect = nil;  -- 计时器

--设置人物详细信息
function MainPlayerModel:UpdateMainPlayerAttr(info)
	info[enAttrType.eaName] = self.sMeShowInfo.szRoleName;
    for type, value in pairs(info) do
		local oldValue = self.humanDetailInfo and self.humanDetailInfo[type];
		if value ~= oldValue or type == enAttrType.eaExp then
			self.humanDetailInfo:ChangeValue(type, value);
			self:OnPlayerAttrChange(type, self.humanDetailInfo[type], oldValue);
		end
    end
	if not self.hasInit then
		self.hasInit = true;
	end
end

--修改自己的名字
function MainPlayerModel:ChangePlayerName(msgObj)	
	if msgObj.result == 0 then
		self.sMeShowInfo.szRoleName = msgObj.roleName
		self.humanDetailInfo:ChangeValue(enAttrType.eaName, msgObj.roleName)	
		FloatManager:AddNormal( StrConfig["yuanling1010"]);				
	end
	
	Notifier:sendNotification(NotifyConsts.ChangePlayerName);
end

--玩家信息变化
function MainPlayerModel:OnPlayerAttrChange( type, value, oldValue )
	if self.hasInit then
		UIMainAttr:ShowAttrChange(type,toint(value-oldValue,0.5));   --主界面属性飘字
	end
	local oldVal = oldValue and oldValue or 0;
	self:sendNotification( NotifyConsts.PlayerAttrChange, { type = type, val = value, oldVal = oldVal } );  --玩家属性发生变化
	if type == enAttrType.eaTianShenEnergy then
		--- 天神能量变更尝试自动释放技能
		-- TianShenController:AskAutoBianShen()
	end
	if oldValue then
		FloatManager:OnPlayerAttrChange(type, value, oldValue);
		if type == enAttrType.eaLevel then

			self:OnLevelUp( oldValue, value );
		end
	end
	if type == enAttrType.eaMoveSpeed then
		MainPlayerModel.speed = value
	end
	if type == enAttrType.eaLevel then
		--检查功能开启
		FuncOpenController:CheckFuncReadyOpen();
		FuncOpenController:CheckFuncRightOpen();
		--检查领奖提示
		GoalController:CheckGoalOpen();
		-- 播放升级特效
		if UILoginWait:IsShow() then return end
		if UIMainPlayerLevelUp:IsShow() then
			UIMainPlayerLevelUp:OnShow()
		else
			UIMainPlayerLevelUp:Show()
		end
	end
	if type == enAttrType.eaExp then    --经验发生变化 
		local totalExp = t_lvup[MainPlayerModel.humanDetailInfo.eaLevel].exp;  --当前等级升级需要的总经验
		local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel
		if playerLevel < t_consts[40].val1 and value >= totalExp then
			--屏蔽掉大主宰的手动升级功能提示，因为这个功能已经没有了 yanghongbin/jianghaoran  2016-7-20
			--RemindController:AddRemind( RemindConsts.Type_LvlUp, playerLevel );
		end
		if ActivityController:GetCurrId() == ActivityConsts.Lunch then    --玩家头顶飘字  adder:houxudong date:2016/8/22 11:54:25
			if type ~= enAttrType.eaLevel then
				FloatManager:AddCenterLunch(toint(math.abs(value-oldValue),0.5))
			end
		end

	end
	if type == enAttrType.eaZhenQi then
		local tb = EquipUtil:IsRemindRefin();
		if tb then 
			if UIRefinView:IsShow() == false then 
				UIItemGuide:Open(10);
			end;
		end;
		if value > oldVal then
			--灵力变化，坐骑升星提示
			MountController:OnLingLiChange();
		end
	end
	if oldValue then
		if type == enAttrType.eaLevel then
			--升级检测是否有功能消息球提醒
			RemindController:CheckShow();
		end
	end
	if type == enAttrType.eaBindGold then
--		if oldVal > 0 and (value - oldVal) >= t_consts[313].val1 then
--			UICurrencyFlyView:Show(enAttrType.eaBindGold);
--		end
		RemindFuncController:ExecRemindOnNewItemInBag(type);
		RemindFuncTipsController:ExecRemindOnNewItemInBag(type)
	end
	if type == enAttrType.eaUnBindMoney then
--		if oldVal > 0 and (value - oldVal) >= t_consts[313].val2 then
--			UICurrencyFlyView:Show(enAttrType.eaUnBindMoney);
--		end
		RemindFuncController:ExecRemindOnNewItemInBag(type);
		RemindFuncTipsController:ExecRemindOnNewItemInBag(type)
	end
	if type == enAttrType.eaBindMoney then
--		if oldVal > 0 and (value - oldVal) >= t_consts[313].val2 then
--			UICurrencyFlyView:Show(enAttrType.eaBindMoney);
--		end
		RemindFuncController:ExecRemindOnNewItemInBag(type);
		RemindFuncTipsController:ExecRemindOnNewItemInBag(type)
	end
	if type == enAttrType.eaTianShen then
		RemindFuncController:ExecRemindOnNewItemInBag(type);
	end
end

function MainPlayerModel:OnLevelUp( oldLevel, newLevel )
	--屏幕中央播放升级特效
	self:ShowLevelUpEffect();
	--人物模型升级特效
	MainPlayerController:LevelUp();
	--技能引导
	SkillGuideManager:OnLevelUp();
	--30级下载微端
	if oldLevel<32 and newLevel>=32 then
		LoginController:NoticeMClient();
	end
	--好友推荐提醒
	if newLevel>=20 and newLevel%10==0 then
		FriendController:AutoRecommendFriend();
	end
	--翅膀
	WingController:OnLevelUp(oldLevel,newLevel);
	--打开等级礼包提示框
	UILevelAwardOpen:OpenPanel(oldLevel);
	--卓越引导
	ZhuoyueGuideController:OnLevelUp(oldLevel,newLevel);
	--Boss
	PersonalBossController:OnLevelUp(oldLevel,newLevel)
	Notifier:sendNotification(NotifyConsts.DominateRouteNewOpen);	--侦听是否有新开启未通关的副本
	Version:DuoWanUserLevelUp(MainPlayerModel.humanDetailInfo.eaName,newLevel);
end

function MainPlayerModel:GetIconId()
	return self.sMeShowInfo and self.sMeShowInfo.dwIconID;
end

function MainPlayerModel:GetItemNum()
	local count = 0
	for _, v in pairs(self.allDropItem) do
		if v ~= nil then
			count = count + 1
		end
	end
	return count;
end

function MainPlayerModel:SetCurBackHomeCD(time)
	self.redundantBackTime = time;
	if time < 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		return 
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnBackHomeCDTimer,1000,0);

end;

function MainPlayerModel:OnBackHomeCDTimer()
	local time = MainPlayerModel.redundantBackTime;
	if time < 0 then 
		MainPlayerModel.redundantBackTime = 0;
		if MainPlayerModel.timerKey  then 
			TimerManager:UnRegisterTimer(MainPlayerModel.timerKey);
			MainPlayerModel.timerKey = nil;
		end;
		return 
	end;
	MainPlayerModel.redundantBackTime = MainPlayerModel.redundantBackTime - 1;
end;

function MainPlayerModel:ShowLevelUpEffect()
	if not self.timerKeyLevelUpEffect then
		self.timerKeyLevelUpEffect = TimerManager:RegisterTimer(self.OnLevelUpEffectTimer,500,0);
	end;
end

function MainPlayerModel:OnLevelUpEffectTimer()
	--延迟显示升级特效
	-- UILevelUpEffect:Show();
	-- 角色升级特效屏蔽 @haoran
	if MainPlayerModel.timerKeyLevelUpEffect  then 
		TimerManager:UnRegisterTimer(MainPlayerModel.timerKeyLevelUpEffect);
		MainPlayerModel.timerKeyLevelUpEffect = nil;
	end
end;