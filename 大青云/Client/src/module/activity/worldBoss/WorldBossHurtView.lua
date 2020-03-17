--[[
世界boss伤害统计
2014年12月8日14:24:08
郝户
]]

_G.UIWorldBossHurt = BaseUI:new("UIWorldBossHurt");

UIWorldBossHurt.activity = nil;
UIWorldBossHurt.isAutoBattle = true   --默认自动挂机

function UIWorldBossHurt:Create()
	self:AddSWF("worldBossHurtPanel.swf", true, "bottom");
end

function UIWorldBossHurt:OnLoaded( objSwf )
	objSwf.btnQuit.click = function() self:OnBtnQuitClick(); end
	objSwf.btnAutoBattle.click = function() self:OnQuicklyBattleClick(); end 
end

function UIWorldBossHurt:OnShow()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_WorldBoss then return; end
	self.activity = activity;
	self:InitBtnState();
	self:ShowBossInfo();
	self:ShowHp();
	self:ShowHurt();
end

function UIWorldBossHurt:DeleteWhenHide()
	return true;
end

function UIWorldBossHurt:OnDelete()
end

function UIWorldBossHurt:OnHide()
	self.activity = nil;
end

function UIWorldBossHurt:Update()
	if not self.bShowState then return; end
	self:ShowHp();
end

--显示名字
function UIWorldBossHurt:ShowBossInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local bossId = self.activity:GetWorldBossId()
	local bossCfg = t_worldboss[bossId];
	if not bossCfg then return end
	objSwf.icon_name.source = ResUtil:GetWorldBossNameImgS(bossId)
	local monsterCfg = t_monster[bossCfg.monster];
	if not monsterCfg then return end
	objSwf.txt_lv.text = string.format( "Lv.%s", monsterCfg.level )
end

--显示血量
function UIWorldBossHurt:ShowHp()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local activity = self.activity;
	-- if not activity then return; end
	-- local maxHp = activity.maxHp;
	-- local hp = activity.hp;
	-- objSwf.siHp.maximum = maxHp;
	-- objSwf.siHp.value   = hp;
	-- objSwf.txtHp.text   = string.format( "%s/%s", toint(hp, 1), maxHp );
end

--显示伤害信息
function UIWorldBossHurt:ShowHurt()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local hurtInfo = self.activity:GetHurtInfo() or {};
	local maxHp = self.activity.maxHp;
	--
	local myRank;
	objSwf.list.dataProvider:cleanUp();
	local mainPlayerId = MainPlayerController:GetRoleID();
	for i = 1, #hurtInfo do
		local vo = hurtInfo[i];
		local uiVO = {};
		uiVO.roleID = vo.roleID;
		uiVO.rank = i;
		uiVO.rankStr = i..". "
		uiVO.roleName = vo.roleName;
		local percent = 0;
		if maxHp > 0 then 
			percent = string.format("%.2f", vo.hurt/maxHp*100)
		end
		uiVO.txtHurt = string.format( StrConfig['worldBoss201'], percent);  --伤害
		objSwf.list.dataProvider:push(UIData.encode(uiVO));
		if vo.roleID == mainPlayerId then
			myRank = i;
		end
	end
	objSwf.list:invalidateData();

	-- 我自己的单独处理一次
	local UI = objSwf.itemme;
	local damage = self.activity:GetMeDamage() or 0;
	if myRank then
		if myRank <= 3 then
			UI.rankMC._visible = true
			UI.rankMC:gotoAndStop(myRank)
			UI.tfRank._visible = false
		else
			UI.rankMC._visible = false
			UI.tfRank._visible = true
			UI.tfRank.text = myRank .. ". "
		end
		UI.rank = "Lv." ..myRank
	else
		UI.rankMC._visible = false
		UI.tfRank._visible = true
		UI.tfRank.text = StrConfig['worldBoss203']
	end
	local percent = 0;
	if maxHp > 0 then
		percent = string.format("%.2f", damage/maxHp*100)
	end
	UI.tfName.text = MainPlayerModel.humanDetailInfo.eaName
	UI.tfHurt.text = string.format(StrConfig['worldBoss201'], percent);
end

function UIWorldBossHurt:OnBtnQuitClick()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_WorldBoss then return; end
	ActivityController:QuitActivity(activity:GetId());
end

-- 自动挂机
function UIWorldBossHurt:OnQuicklyBattleClick( )
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_WorldBoss then return; end
	self:ChangeBtnState()
end

-- 改变按钮的挂机和非挂机状态
function UIWorldBossHurt:ChangeBtnState( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.isAutoBattle = not self.isAutoBattle
	if self.isAutoBattle then
		self:OnAutoFunc()
		objSwf.btnAutoBattle.labelID = 'worldBoss203'
	else
		MainPlayerController:StopMove()
		AutoBattleController:CloseAutoHang()
		objSwf.btnAutoBattle.labelID = 'worldBoss202'
	end
end

-- 跑到一个指定位置开始挂机
function UIWorldBossHurt:OnAutoFunc()
	if not self.activity then
		return
	end
	local bossId = self.activity:GetWorldBossId()
	local bossCfg = t_worldboss[bossId]
	if not bossCfg then 
		Debug("not find bossCfg in t_worldboss,bossId is ",bossId)
		return
	end
	local pos = bossCfg.boss_pos
	local myPos = pos
	if not myPos then return end
	local mapid = CPlayerMap:GetCurMapID()
	local point = split(myPos,",")
	local completeFuc = function()
		AutoBattleController:SetAutoHang()
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(toint(point[1]),toint(point[2]),0),completeFuc);
end

function UIWorldBossHurt:InitBtnState( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnAutoBattle.labelID = 'worldBoss203'
end

--改变挂机按钮文本
function UIWorldBossHurt:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.isAutoBattle = state
	if self.isAutoBattle then
		objSwf.btnAutoBattle.labelID = 'worldBoss203'   --取消挂机
	else
		objSwf.btnAutoBattle.labelID = 'worldBoss202'   --自动挂机
	end
end

---------------------------消息处理---------------------------------
--监听消息列表
function UIWorldBossHurt:ListNotificationInterests()
	return {
		NotifyConsts.WorldBossHurt,
		NotifyConsts.WorldBossMyDamage,
		NotifyConsts.AutoHangStateChange,
	};
end

--处理消息
function UIWorldBossHurt:HandleNotification(name, body)
	if name == NotifyConsts.WorldBossHurt then
		self:ShowHurt()
	elseif name == NotifyConsts.WorldBossMyDamage then
		self:ShowHurt()
	elseif name == NotifyConsts.AutoHangStateChange then
		self:OnChangeAutoText(body.state)
	end
end

