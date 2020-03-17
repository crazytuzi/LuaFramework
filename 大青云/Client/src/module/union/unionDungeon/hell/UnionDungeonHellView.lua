--[[
帮派副本-地宫炼狱 view
2015年1月8日17:19:50
haohu
]]

_G.UIUnionDungeonHell = BaseUI:new("UIUnionDungeonHell");

-- 当前显示的层级
UIUnionDungeonHell.currentShowStratum = nil;
-- 打开时默认显示的层级
UIUnionDungeonHell.firstShowStratum = nil;
-- uidraw 当前
UIUnionDungeonHell.objUIDraw = nil;
-- uidraw 前一关
UIUnionDungeonHell.uiDrawPre = nil;
-- uidraw 后一关
UIUnionDungeonHell.uiDrawNext = nil;
-- loader cfg
UIUnionDungeonHell.mcCfg = {};
-- 显示完本层是否切换到下一层
UIUnionDungeonHell.willTweenNext = false;
-- 上下层缓动时间
UIUnionDungeonHell.TWEEN_DURATION = 0.3;
-- 上下层缓动距离
UIUnionDungeonHell.TWEEN_DISTANCE = 590;

UIUnionDungeonHell.ActName_Dead = "san_dead";
UIUnionDungeonHell.ActName_Attack = "san_atk";

-- statemc frame:
UIUnionDungeonHell.PASSED       = 'passed'
UIUnionDungeonHell.CAN_FIGHT    = 'canFight'
UIUnionDungeonHell.CANNOT_FIGHT = 'cannotFight'

function UIUnionDungeonHell:Create()
	self:AddSWF("unionDungeonHellPanel.swf", true, nil);
end

function UIUnionDungeonHell:OnLoaded( objSwf )
	objSwf.labRoleNum.text     = StrConfig['unionhell002'];
	objSwf.labWeaken.text      = StrConfig['unionhell003'];
	objSwf.labBest.text        = StrConfig['unionhell004'];
	objSwf.labTime.text        = StrConfig['unionhell005'];
	objSwf.labMyState.text     = StrConfig['unionhell006'];
	objSwf.labMyTime.text      = StrConfig['unionhell007'];
	objSwf.labDungeonName.text = StrConfig['unionhell050'];

	objSwf.btnReturn.click    = function() self:OnBtnReturnClick(); end
	objSwf.btnReturn.rollOver = function() self:OnBtnReturnRollOver(); end
	objSwf.btnReturn.rollOut  = function() self:OnBtnReturnRollOut(); end
	objSwf.btnEnter.click     = function() self:OnBtnEnterClick(); end
	objSwf.btnPre.click       = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click      = function() self:OnBtnNextClick(); end
	RewardManager:RegisterListTips(objSwf.list);
	table.push( self.mcCfg, { mc = objSwf.loaderContainerPre, oy = objSwf.loaderContainerPre._y } );
	table.push( self.mcCfg, { mc = objSwf.loaderContainer, oy = objSwf.loaderContainer._y } );
	table.push( self.mcCfg, { mc = objSwf.loaderContainerNext, oy = objSwf.loaderContainerNext._y } );
end

function UIUnionDungeonHell:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.uiDrawPre then
		self.uiDrawPre:SetUILoader(nil);
	end
	if self.uiDrawNext then
		self.uiDrawNext:SetUILoader(nil);
	end
	self.mcCfg = {};
end

function UIUnionDungeonHell:OnShow()
	UnionDungeonHellController:QueryGuildHellInfo();
	self:ShowStratum( self:GetFirstShowStratum() );
end

function UIUnionDungeonHell:OnHide()
	for _, uidraw in pairs( {self.objUIDraw, self.uiDrawPre, self.uiDrawNext} ) do
		if uidraw then
			uidraw:SetDraw(false);
			uidraw:SetMesh(nil);
		end
	end
end

function UIUnionDungeonHell:UpdateShow()
	self:ShowStratum( self.currentShowStratum );
end

function UIUnionDungeonHell:ShowStratum(stratum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not stratum then
		stratum = 1;
	end
	local cfg = t_guildHell[stratum];
	if not cfg then return; end
	self.currentShowStratum = stratum;
	local vo = UnionDungeonHellModel:GetStratum( stratum );
	objSwf.txtStratum.htmlText = UnionDungeonHellUtils:GetStratumTxt( stratum );
	objSwf.txtBossName.text = UnionDungeonHellUtils:GetBossName( stratum );
	local txtState = objSwf.txtState;
	if vo.state then
		txtState.text = StrConfig['unionhell009']
		txtState.textColor = 0x00FF00;
	else
		txtState.text = StrConfig['unionhell010'];
		txtState.textColor = 0xFF0000;
	end
	objSwf.txtRoleNum.text   = string.format( StrConfig['unionhell011'], vo.numPass );
	local attrWeakTotal      = math.min( vo.numPass * cfg.reduceAtt, cfg.maxReduceAtt );
	objSwf.txtWeaken.text    = string.format( StrConfig['unionhell014'], attrWeakTotal );
	objSwf.txtBest.text      = vo.bestPass ~= "" and vo.bestPass or StrConfig['unionhell033'];
	objSwf.txtTime.text      = vo.bestPassTime > 0 and SitUtils:ParseTime( vo.bestPassTime ) or StrConfig['unionhell033'];
	objSwf.txtMyTime.text    = vo.state and SitUtils:ParseTime( vo.passTime ) or StrConfig['unionhell033'];
	local stateName = self:GetStratumState(stratum);
	objSwf.loaderContainer.mcState:gotoAndPlay( stateName )
	objSwf.btnEnter._visible = not vo.state;
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local rewardList = UnionDungeonHellUtils:GetRewardProvider(stratum);
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
	objSwf.btnPre._visible = self.currentShowStratum > 1;
	objSwf.btnNext._visible = self.currentShowStratum < UnionHellConsts:GetNumStratum();
	local bossIsAlive = not vo.state;
	self:Show3dBoss(stratum, bossIsAlive);
	self:ShowNeighbor(stratum);
end

function UIUnionDungeonHell:GetStratumState( stratum )
	local currentStratum = UnionDungeonHellModel:GetCurrentStratum()
	if currentStratum > stratum then
		return UIUnionDungeonHell.PASSED
	elseif currentStratum < stratum then
		return UIUnionDungeonHell.CANNOT_FIGHT
	elseif currentStratum == stratum then
		return UIUnionDungeonHell.CAN_FIGHT
	end
end

function UIUnionDungeonHell:Show3dBoss(stratum, alive)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_guildHell[stratum];
	if not cfg then return; end
	local monsterId = cfg.bossid;
	local avatar = MonsterAvatar:NewMonsterAvatar( nil, monsterId );
	avatar:InitAvatar();
	local drawcfg = self:GetDrawCfg(stratum);
	local loader = objSwf.loaderContainer.loader;
	local objUIDraw = self.objUIDraw;
	if not objUIDraw then 
		objUIDraw = UIDraw:new( "HellBossDraw", avatar, loader, drawcfg.VPort, drawcfg.EyePos,  
				drawcfg.LookPos, 0x00000000 );
		self.objUIDraw = objUIDraw;
	else 
		objUIDraw:SetUILoader(loader);
		objUIDraw:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos );
		objUIDraw:SetMesh( avatar );
	end
	-- 模型旋转
	avatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation );
	objUIDraw:SetDraw(true);
	local stratumState = self:GetStratumState( stratum )
	objUIDraw:SetGrey( stratumState == UIUnionDungeonHell.CANNOT_FIGHT )
	if alive then
		self:PlayNormalAttackInSec( UIUnionDungeonHell.TWEEN_DURATION, stratum );
	else
		self:PlayDeadAction(stratum, function()
			self:TryTweenNext();
		end);
	end
end

local timerKey;
function UIUnionDungeonHell:PlayNormalAttackInSec( delay, stratum )
	local avatar = self.objUIDraw and self.objUIDraw.objEntity;
	if avatar then
		avatar:StopAllAction();
	end
	if timerKey ~= nil then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
	timerKey = TimerManager:RegisterTimer( function()
		self:PlayNormalAttack(stratum, function()
			avatar:ExecIdleAction();
		end);
		timerKey = nil;
	end, delay * 1000--[[转为毫秒]], 1 );
end

function UIUnionDungeonHell:ShowNeighbor(stratum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 上一层
	local prevo = UnionDungeonHellModel:GetStratum( stratum - 1 );
	if prevo then
		local preStratumState = self:GetStratumState( prevo.id );
		objSwf.loaderContainerPre.mcState:gotoAndPlay( preStratumState );
	end
	if stratum ~= 1 then
		self:ShowPre3dBossOf(stratum);
	end
	-- 下一层
	local nextvo = UnionDungeonHellModel:GetStratum( stratum + 1 );
	if nextvo then
		local nextStratumState = self:GetStratumState( nextvo.id );
		objSwf.loaderContainerNext.mcState:gotoAndPlay( nextStratumState );
	end
	if stratum ~= UnionHellConsts:GetNumStratum() then
		self:ShowNext3dBossOf(stratum);
	end
end

function UIUnionDungeonHell:TryTweenNext()
	if self.willTweenNext then
		self.willTweenNext = false;
		self:TweenToNextStratum();
	end
end

function UIUnionDungeonHell:ShowPre3dBossOf(stratum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local preStratum = stratum - 1;
	local cfg = t_guildHell[preStratum];
	if not cfg then return; end
	local monsterId = cfg.bossid;
	local avatar = MonsterAvatar:NewMonsterAvatar( nil, monsterId );
	avatar:InitAvatar();
	local drawcfg = self:GetDrawCfg(preStratum);
	local loader = objSwf.loaderContainerPre.loader;
	local uiDrawPre = self.uiDrawPre;
	if not uiDrawPre then 
		uiDrawPre = UIDraw:new( "HellBossDrawPre", avatar, loader, drawcfg.VPort, drawcfg.EyePos,  
				drawcfg.LookPos, 0x00000000 );
		self.uiDrawPre = uiDrawPre;
	else 
		uiDrawPre:SetUILoader(loader);
		uiDrawPre:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos );
		uiDrawPre:SetMesh( avatar );
	end
	-- 模型旋转
	avatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation );
	uiDrawPre:SetDraw(true);
	local stratumState = self:GetStratumState( preStratum )
	uiDrawPre:SetGrey( stratumState == UIUnionDungeonHell.CANNOT_FIGHT )
end

function UIUnionDungeonHell:ShowNext3dBossOf(stratum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nextStratum = stratum + 1;
	local cfg = t_guildHell[nextStratum];
	if not cfg then return; end
	local monsterId = cfg.bossid;
	local avatar = MonsterAvatar:NewMonsterAvatar( nil, monsterId );
	avatar:InitAvatar();
	local drawcfg = self:GetDrawCfg(nextStratum);
	local loader = objSwf.loaderContainerNext.loader;
	local uiDrawNext = self.uiDrawNext;
	if not uiDrawNext then 
		uiDrawNext = UIDraw:new( "HellBossDrawNext", avatar, loader, drawcfg.VPort, drawcfg.EyePos,  
				drawcfg.LookPos, 0x00000000 );
		self.uiDrawNext = uiDrawNext;
	else 
		uiDrawNext:SetUILoader(loader);
		uiDrawNext:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos );
		uiDrawNext:SetMesh( avatar );
	end
	-- 模型旋转
	avatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation );
	uiDrawNext:SetDraw(true);
	local stratumState = self:GetStratumState( nextStratum )
	uiDrawNext:SetGrey( stratumState == UIUnionDungeonHell.CANNOT_FIGHT )
end

function UIUnionDungeonHell:PlayDeadAction( stratum, onComplete )
	self:PlayAction(stratum, UIUnionDungeonHell.ActName_Dead, onComplete);
end

function UIUnionDungeonHell:PlayNormalAttack( stratum, onComplete )
	self:PlayAction(stratum, UIUnionDungeonHell.ActName_Attack, onComplete);
end


function UIUnionDungeonHell:PlayAction(stratum, actName, onComplete)
	local cfg = t_guildHell[stratum];
	if not cfg then return; end
	local monsterId = cfg.bossid;
	local avatar = self.objUIDraw and self.objUIDraw.objEntity;
	if not avatar then return end
	local actionFile = self:GetActionIdByName(monsterId, actName);
	if actionFile then
		if actName == UIUnionDungeonHell.ActName_Dead then
			avatar:StopAllAction();
		end
		avatar:DoAction( actionFile, false, onComplete );
	else
		if onComplete then onComplete(); end
	end
end

function UIUnionDungeonHell:GetActionIdByName(monsterId, actName)
	local cfgMonster = t_monster[monsterId]
	if not cfgMonster then
		Debug("don't exist this monster monsterId" .. monsterId)
		return
	end

	local model = t_model[cfgMonster.modelId]
	if not model then
		Debug("don't exist this monster model" .. cfgMonster.modelId)
		return
	end

	return model[actName];
end

function UIUnionDungeonHell:GetDrawCfg(stratum)
	local drawCfg = UIDrawUnionHellConfig[stratum];
	if not drawCfg then
		drawCfg = {
			EyePos   = _Vector3.new(0,-103,19),
			LookPos  = _Vector3.new(4,0,12),
			VPort    = _Vector2.new(640,640),
			Rotation = 0
		}
	end
	return drawCfg;
end

function UIUnionDungeonHell:OnBtnReturnClick()
	local parent = self.parent;
	if not parent then return; end
	parent:TurnToDungeonListPanel();
end

function UIUnionDungeonHell:OnBtnReturnRollOver()
	TipsManager:ShowBtnTips( StrConfig['unionhell043'] );
end

function UIUnionDungeonHell:OnBtnReturnRollOut()
	TipsManager:Hide();
end

function UIUnionDungeonHell:OnBtnEnterClick()
	-- 先检查当前地图是否可以传送
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig['unionhell049'] )
		return
	end
	local stratumId = self.currentShowStratum;
	if not stratumId then return; end
	UnionDungeonHellController:ReqEnterGuildHell(stratumId);
end

function UIUnionDungeonHell:OnBtnPreClick()
	self:TweenToPreStratum();
	self:BreakAutoTween();
end

function UIUnionDungeonHell:OnBtnNextClick()
	self:TweenToNextStratum();
	self:BreakAutoTween();
end

function UIUnionDungeonHell:BreakAutoTween()
	self.willTweenNext = false;
end

function UIUnionDungeonHell:TweenToPreStratum()
	self:TweenStratum(-1)
end

function UIUnionDungeonHell:TweenToNextStratum()
	self:TweenStratum(1)
end

-- @param direction: 1向下缓动，-1向上缓动
local isTweening
function UIUnionDungeonHell:TweenStratum( direction )
	if isTweening then return end
	isTweening = true
	self:ShowStratum( self.currentShowStratum + direction );
	for index, cfg in pairs(self.mcCfg) do
		local mc, oy = cfg.mc, cfg.oy;
		mc._y = oy + direction * UIUnionDungeonHell.TWEEN_DISTANCE;
		Tween:To( mc, UIUnionDungeonHell.TWEEN_DURATION, { _y = oy }, { onComplete = function()
			isTweening = false
		end} );
	end
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIUnionDungeonHell:ListNotificationInterests()
	return {
		NotifyConsts.GuildHellStratumUpdate,
		NotifyConsts.PlayerAttrChange, -- 玩家升级时,奖励发生变化
	};
end

--处理消息
function UIUnionDungeonHell:HandleNotification(name, body)
	if name == NotifyConsts.GuildHellStratumUpdate then
		self:OnStratumUpdate(body);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:UpdateShow();
		end
	end
end

function UIUnionDungeonHell:OnStratumUpdate(changeStratumId)
	if self.currentShowStratum == changeStratumId then
		self:UpdateShow();
	end
end

----------------------------------------------
function UIUnionDungeonHell:GetFirstShowStratum()
	local firstShowStratum;
	if self.firstShowStratum then
		firstShowStratum = self.firstShowStratum;
		self.firstShowStratum = nil;
	else
		firstShowStratum = math.min( UnionDungeonHellModel:GetCurrentStratum(), UnionHellConsts:GetNumStratum() );
	end
	return firstShowStratum;
end

function UIUnionDungeonHell:SetFirstShowStratum( stratum )
	self.firstShowStratum = stratum;
end

function UIUnionDungeonHell:ShowWhenGetOut(stratum, tweenToNext)
	if not UnionUtils:CheckMyUnion() then return end
	if not stratum then
		stratum = UnionDungeonHellModel:GetCurrentStratum();
	end
	if self:IsShow() then
		self:ShowStratum(stratum);
	else
		if not isDebug then
			if not UnionDungeonUtils:GetUnionDungeonIsOpen( UnionDungeonConsts.ID_Hell ) then return; end
		end
		UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
		UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.TabHell );
		self:SetFirstShowStratum( stratum );
		UIUnionDungeonHell.willTweenNext = tweenToNext;
		UIUnion:Show();
	end
end
