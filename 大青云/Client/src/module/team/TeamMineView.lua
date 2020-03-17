--[[
队伍:我的队伍面板
郝户
2014年9月24日17:18:51
]]

_G.UITeamMine = BaseUI:new("UITeamMine")

--队员显示MovieClip列表
UITeamMine.memberDisplays = {};
--当前选中队员索引
UITeamMine.selectedMemberIndex = nil;
--[index] = pfxName;
UITeamMine.selectPfxNameMap = {};
UITeamMine.captainPfxNameMap = {};
UITeamMine.memberPfxNameMap = {};

-------------------- 组队设置(默认开启) ------------------
--是否自动接受邀请
UITeamMine.autoAcceptInvite = true;
--是否自动同意入队
UITeamMine.autoAcceptJoin = true;
----------------------------------------------------------------------


function UITeamMine:Create()
	self:AddSWF("teamMinePanel.swf", true, nil);

end

function UITeamMine:OnLoaded(objSwf, name)
	objSwf.panelOperate.btnLike._visible = false;

	self.memberDisplays = { objSwf.member1, objSwf.member2, objSwf.member3, objSwf.member4 };
	self.roleLoaders = { objSwf.loader1, objSwf.loader2, objSwf.loader3, objSwf.loader4 };
	table.foreach( self.roleLoaders, function(_, loader) loader.hitTestDisable = true; end );

	--选中队员
	for index, mc in pairs( self.memberDisplays ) do
		mc.click = function(e) self:OnMemberClick( index ) end;
		mc.txtName.autoSize     = "center";
		mc.txtLevel.autoSize    = "center";
		mc.txtLocation.autoSize = "center";
		mc.txtfighting.autoSize="center";
	end
	--自动接受check box
	objSwf.chkboxAutoAcceptInvite.click = function(e) self:OnAutoAcceptInviteClick(e); end
	objSwf.chkboxAutoAcceptApplay.click = function(e) self:OnAutoAcceptApplyClick(e); end
	--创建队伍按钮
	objSwf.btnTeamCreate.click = function()	self:OnBtnTeamCreateClick(); end
	--队员相关操作按钮
	local panelOperate = objSwf.panelOperate;
	panelOperate.btnLike.click    = function() self:OnBtnLikeClick(); end
	panelOperate.btnInfo.click    = function() self:OnBtnInfoClick(); end
	panelOperate.btnFriend.click  = function() self:OnBtnFriendClick();	end
	panelOperate.btnQuit.click    = function() self:OnBtnQuitClick(); end
	panelOperate.btnAppoint.click = function() self:OnBtnAppointClick();end
	panelOperate.btnKick.click    = function() self:OnBtnKickClick(); end
	panelOperate.btnAdd.click     = function() self:OnBtnAddClick(); end
	--组队加持
	objSwf.bonusMoney.rollOver = function() self:OnBonusMoneyRollOver() end
	objSwf.bonusMoney.rollOut  = function() self:OnBonusRollOut() end
	objSwf.bonusExp.rollOver   = function() self:OnBonusExpRollOver() end
	objSwf.bonusExp.rollOut    = function() self:OnBonusRollOut() end
end

function UITeamMine:OnDelete()
	for i=1, TeamConsts.MemberCeiling do
		local name = TeamUtils:GetDrawObjName(i);
		local objUIDraw = UIDrawManager:GetUIDraw(name);
		if objUIDraw then
			objUIDraw:SetUILoader(nil);
		end
	end
	for k,_ in pairs(self.memberDisplays) do
		self.memberDisplays[k] = nil;
	end
	for k,_ in pairs(self.roleLoaders) do
		self.roleLoaders[k] = nil;
	end
end

function UITeamMine:OnShow(name)
	--更新显示队伍状态或非队伍状态显示
	local isInTeam = TeamModel:IsInTeam();
	self:SwitchShowState(isInTeam);
	--更新队员列表显示
	self:UpdateMemberListShow();
	--更新显示队伍操作面板(队伍操作按钮的disable状态)
	self:UpdatePanelOperate();
	-- 开启攻击播放
	self:StartNormalAttackTimer();
	-- 显示组队设置
	self:OnShowSelecteBtn();
   
end

function UITeamMine:OnHide(szName)
	self:UnSelect();
	for i = 1, TeamConsts.MemberCeiling do
		local name = TeamUtils:GetDrawObjName(i);
		local objUIDraw = UIDrawManager:GetUIDraw(name);
		if objUIDraw then
			if objUIDraw.objEntity then
				objUIDraw.objEntity:ExitMap();
			end
			objUIDraw:SetMesh( nil );
			objUIDraw:SetDraw(false);
		end
	end
	-- 关闭攻击播放
	self:StopNormalAttackTimer();
end

---------------------------------按钮点击等事件处理--------------------------

--选中队员
function UITeamMine:OnMemberClick( index )
	self.selectedMemberIndex = index;
	self:PlaySelectPfx(index);
	self:UpdatePanelOperate();
end

--点击自动接受邀请check box
function UITeamMine:OnAutoAcceptInviteClick(e)
 
    local chkbox = e.target;
	self.autoAcceptInvite=chkbox.selected;

	 local val, str = SetSystemModel:GetSetSysModel();
	 if not self.autoAcceptInvite then
	 	
	 	val = val + SetSystemConsts.TEAMINVITE;
	 else
	 	val = val - SetSystemConsts.TEAMINVITE;
	 end
	 SetSystemController:OnSendSetModel(val, str);
end

--点击自动同意入队check box
function UITeamMine:OnAutoAcceptApplyClick(e)
	local chkbox = e.target;
	self.autoAcceptJoin= chkbox.selected;


	local val, str = SetSystemModel:GetSetSysModel();
	if not self.autoAcceptJoin then
		val = val + SetSystemConsts.TEAMAPPLAY;
	else
		val = val - SetSystemConsts.TEAMAPPLAY;
	end

	SetSystemController:OnSendSetModel(val, str);

end
--点击创建队伍
function UITeamMine:OnBtnTeamCreateClick()
	TeamController:CreateTeam();
end

--点赞
function UITeamMine:OnBtnLikeClick()
	if not self.selectedMemberIndex then
		Debug("Please select a player first");
		return;
	end
	local playerId = TeamModel:GetMemberIdByIndex( self.selectedMemberIndex );
	if playerId == MainPlayerController:GetRoleID() then
		Debug("You can not Like yourself");
		return;
	end
	--todo点赞
end

--点击查看资料
function UITeamMine:OnBtnInfoClick()
	if not self.selectedMemberIndex then
		Debug("Please pick a player first")
		return;
	end
	local playerId = TeamModel:GetMemberIdByIndex( self.selectedMemberIndex );
	if playerId == MainPlayerController:GetRoleID() then
		--查看自己的资料
		if not UIRole:IsShow() then
			UIRole:Show();
		elseif not UIRoleBasic:IsShow() then
			UIRole:TurnToSubpanel( UIRole.BASIC )
		end
		return;
	end
	RoleController:ViewRoleInfo(playerId);
end

--点击加为好友
function UITeamMine:OnBtnFriendClick()
	if not self.selectedMemberIndex then return; end
	local playerId = TeamModel:GetMemberIdByIndex( self.selectedMemberIndex );
	if playerId == MainPlayerController:GetRoleID() then
		return;
	end
	FriendController:AddFriend(playerId);
end

--点击退出队伍
function UITeamMine:OnBtnQuitClick()
	TeamController:ConfirmQuit()
end

--点击任命队长
function UITeamMine:OnBtnAppointClick()
	local index = self.selectedMemberIndex;
	if not index then return; end
	local memberVO = TeamModel:GetMember(index);
	if not memberVO then return end
	TeamController:Appoint( memberVO );
end

--点击开除队友
function UITeamMine:OnBtnKickClick()
	local memberIndex = self.selectedMemberIndex;
	if not memberIndex then return; end
	local playerId = TeamModel:GetMemberIdByIndex( memberIndex );
	TeamController:Kick( playerId );
end

--点击添加队员
function UITeamMine:OnBtnAddClick()
	--切换到附近玩家页面
	UITeam:TurnToSubpanel( TeamConsts.TabPlayerNearby );
end

--鼠标悬浮金钱加持图标
function UITeamMine:OnBonusMoneyRollOver()
	local strType = StrConfig['team102'];
	local strStat = self:GetBonusStatStr();
	local str = string.format( StrConfig['team101'], strType, strType, strStat );
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UITeamMine:OnBonusExpRollOver()
	local strType = StrConfig['team103'];
	local strStat = self:GetBonusStatStr();
	local str = string.format( StrConfig['team101'], strType, strType, strStat );
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UITeamMine:GetBonusStatStr( bonueType )
	if TeamModel:IsInTeam() then
		local num = self:GetSameMapMemberNum();
		local str = TeamConsts.BonusMap[num];
		return string.format( StrConfig['team104'], str );
	end
	return StrConfig['team105'];
end

-- 获取与自己同线同地图的队友人数
function UITeamMine:GetSameMapMemberNum()
	local num = 0;
	local members = TeamModel:GetMemberList();
	local myMap = CPlayerMap:GetCurMapID();
	local myLine = CPlayerMap:GetCurLineID();
	for _, memberVO in pairs(members) do
		if memberVO.online == TeamConsts.Online and memberVO.line == myLine and memberVO.mapId == myMap then
			num = num + 1;
		end
	end
	return num;
end

--鼠标滑离加持图标
function UITeamMine:OnBonusRollOut()
	TipsManager:Hide();
end


---------------------------------显示相关------------------------------------

--更新队员列表显示
function UITeamMine:UpdateMemberListShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	table.foreach( self.memberDisplays, function(_, mc) mc._visible = false; end );
	table.foreach( self.roleLoaders, function(_, loader) loader._visible = false; end );
	if TeamModel:IsInTeam() then
		local members = TeamModel:GetMemberList();
		for id, memberVO in pairs(members) do
			self:ShowMember(memberVO);
		end
	end
end

--更新队员相关操作面板状态
function UITeamMine:UpdatePanelOperate()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--未选中队员
	local hasNoSelection = not self.selectedMemberIndex;
	--自己不是队长
	local mainPlayerIsNotCaptain = not TeamUtils:MainPlayerIsCaptain();
	--选中的是自己
	local mainPlayerSelected = TeamModel:GetMainPlayerIndex() == self.selectedMemberIndex;
	local panelOperate = objSwf.panelOperate;
	panelOperate.btnInfo.disabled    = hasNoSelection or mainPlayerSelected;
	panelOperate.btnLike.disabled    = hasNoSelection or mainPlayerSelected;
	panelOperate.btnFriend.disabled  = hasNoSelection or mainPlayerSelected;
	panelOperate.btnAppoint.disabled = hasNoSelection or mainPlayerIsNotCaptain or mainPlayerSelected;
	panelOperate.btnKick.disabled    = hasNoSelection or mainPlayerIsNotCaptain or mainPlayerSelected;
end

--切换队伍状态和非队伍状态显示
function UITeamMine:SwitchShowState(isInTeam)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnTeamCreate._visible = not isInTeam;
	objSwf.panelOperate._visible = isInTeam;
	if isInTeam then
		objSwf.bonusMoney:dye();
		objSwf.bonusExp:dye();
	else
		objSwf.bonusMoney:fade();
		objSwf.bonusExp:fade();
	end
end

--显示队员( 如果已经在队伍里，更新显示 )
function UITeamMine:ShowMember(memberVO)
	self:ShowMemberInfo(memberVO);
	self:Show3DMember(memberVO);
end

--移除某队员
--@param index:队员索引
function UITeamMine:RemoveMember(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local mc = self.memberDisplays[index];
	if mc then
		mc.selected = false;
		mc._visible = false;
	end
	local loader = self.roleLoaders[index];
	if loader then
		loader._visible = false;
	end
	-- 停止渲染
	local name = TeamUtils:GetDrawObjName( index );
	local objUIDraw = name and UIDrawManager:GetUIDraw( name );
	if objUIDraw then
		objUIDraw:SetDraw(false);
		if objUIDraw.objEntity then
			objUIDraw.objEntity:ExitMap();
			objUIDraw:SetMesh(nil);
		end
	end
	-- 如果移除的玩家是当前选中玩家，取消选择
	if self.selectedMemberIndex == index then
		self:UnSelect();
	end
end

-- 显示队员-非3d形象部分
function UITeamMine:ShowMemberInfo(memberVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local index = memberVO.index;
	if not index then return; end
	local mc = self.memberDisplays[index];
	mc._visible = true;
	local txtName = mc.txtName;
	txtName.textColor = TeamUtils:IsMainPlayer(memberVO) and 0xb3ce1d or 0xbcd386;--自己名字和其他人颜色区分
	txtName.text = memberVO.roleName;
	local signCaptain = mc.signCaptain;
	signCaptain._visible = (memberVO.teamPos == 1);
	if signCaptain._visible then
		signCaptain._x = txtName._x; --将队长图标放在名字的左侧
	end
	mc.txtLevel.text = string.format( "LV.%s", memberVO.level );
	mc.data = memberVO;
	local mapName = MapUtils:GetMapName( memberVO.mapId );
	mc.txtfighting.text=string.format( "战力 %s", memberVO.fight );
	
	mc.txtLocation.text = string.format( StrConfig["team1"], memberVO.line, mapName );
end

--显示队员3D形象
function UITeamMine:Show3DMember( memberVO )
	local index = memberVO.index;
	if not index then return; end
	local loader = self.roleLoaders[index];
	loader._visible = true;
	local objAvatar = TeamUtils:GetMemberAvatar(memberVO);
	local index     = memberVO.index;
	local name      = TeamUtils:GetDrawObjName( index );
	local prof      = memberVO.prof; --取玩家职业
	local drawCfg   = UIDrawTeamCfg[index][prof];
	local cameraPos = drawCfg.EyePos;
	local lookPos   = drawCfg.LookPos;
	local vport     = drawCfg.VPort;
	local objUIDraw = UIDrawManager:GetUIDraw( name );
	if not objUIDraw then
		objUIDraw = UIDraw:new( name, objAvatar, loader, vport, cameraPos, lookPos, 0x00000000,"UIRole", prof);
	else
		objUIDraw:SetUILoader(loader);
		objUIDraw:SetCamera( vport, cameraPos, lookPos );
		objUIDraw:SetMesh( objAvatar );
	end
	objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation );
	
	objAvatar:PlayTeamAction()
	local bIsGrey = memberVO.online == TeamConsts.Offline;
	objUIDraw:SetGrey( bIsGrey ); --离线显示灰色，在线显示彩色
	objUIDraw:SetDraw(true);
end

function UITeamMine:GetPfxRotations()
	if not self.pfxRotations then
		self.pfxRotations = {};
		for index, cfg in pairs(UIDrawTeamCfg) do
			self.pfxRotations[index] = cfg[1].pfx;
		end
	end
	return self.pfxRotations;
end

-- 选中index指定队员选中特效,若index == -1 则为全部停止播放
function UITeamMine:PlaySelectPfx(index)
	local objUIDraw;
	local index = index or self.selectedMemberIndex or -1;
	for i = 1, TeamConsts.MemberCeiling do
		objUIDraw = TeamUtils:GetDrawObj(i);
		if objUIDraw then
			if i == index then
				local pfx;
				Debug("team select pfx:")
				self.selectPfxNameMap[i], pfx = objUIDraw:PlayPfx("duizhang_daiji.pfx");
				local pfxRotations = self:GetPfxRotations();
				pfx.transform:setRotationX( pfxRotations[i] );
			else
				local pfxName = self.selectPfxNameMap[i];
				if pfxName then
					objUIDraw:StopPfx(pfxName);
				end
			end
		end;
	end
end

--设置所有队员为非选中状态
function UITeamMine:UnSelect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.selectedMemberIndex = nil;
	self:UpdatePanelOperate();
	for index, mc in pairs( self.memberDisplays ) do
		mc.selected = false;
	end
	self:PlaySelectPfx(-1);
end


local timerKey;
function UITeamMine:StartNormalAttackTimer()
	local func = function() self:PlayNormalAttack(); end
	timerKey = TimerManager:RegisterTimer( func, 10000, 0 );
end

function UITeamMine:StopNormalAttackTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
end

-- 播放普攻动作, 每10s触发一次，每次最多2个角色播放普攻动作
function UITeamMine:PlayNormalAttack()
	if TeamModel:IsInTeam() then
		for i = 1, 2 do -- 每次最多2个
			local index = math.floor( math.random(0, TeamConsts.MemberCeiling) );
			local memberVO = TeamModel:GetMember(index);
			local prof = memberVO and memberVO.prof;
			if prof then
				local name = TeamUtils:GetDrawObjName( index );
				local objUIDraw = UIDrawManager:GetUIDraw( name );
				local avatar = objUIDraw and objUIDraw.objEntity;
				if avatar then
					local normalAttackSkillId = MainPlayerController:GetNormalAttackSkillIdByProf(prof);
					avatar:PlayDefault( normalAttackSkillId );
				end
			end
		end
	end
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UITeamMine:ListNotificationInterests()
	return {
		NotifyConsts.TeamMemberAdd,
		NotifyConsts.TeamMemberRemove,
		NotifyConsts.TeamJoin,
		NotifyConsts.TeamQuit,
		NotifyConsts.MemberChange,
		NotifyConsts.MemberAppearanceChange
	};
end

--处理消息
function UITeamMine:HandleNotification(name, body)
	if name == NotifyConsts.TeamMemberAdd then
		self:OnMemberAdd(body);
	elseif name == NotifyConsts.TeamMemberRemove then
		self:OnMemberRemove(body);
	elseif name == NotifyConsts.TeamJoin then
		self:OnJoin();
	elseif name == NotifyConsts.TeamQuit then
		self:OnQuit();
	elseif name == NotifyConsts.MemberChange then
		self:OnMemberChange(body.index);
	elseif name == NotifyConsts.MemberAppearanceChange then
		self:OnMemberAppearanceChange(body);
	end
end

--当加入队员
function UITeamMine:OnMemberAdd(index)
	local memberVO = TeamModel:GetMember(index);
	if not memberVO then return; end
	self:ShowMember(memberVO); --面板显示队员
end

--当移除队员
function UITeamMine:OnMemberRemove(index)
	self:RemoveMember( index );
end
function UITeamMine:OnShowSelecteBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end

    
	self.autoAcceptInvite =  not SetSystemVO:GetTeamInvite();
 
	objSwf.chkboxAutoAcceptInvite.selected =  self.autoAcceptInvite;

     self.autoAcceptJoin =  not SetSystemVO:GetTeamApplay();
	 objSwf.chkboxAutoAcceptApplay.selected =  self.autoAcceptJoin;
end
--当主玩家加入队伍
function UITeamMine:OnJoin()
	--如果队伍面板处于打开状态，切换到我的队伍标签页
	if UITeam:IsShow() then
		UITeam:ShowMyTeam();
	end
	--切换显示为有队伍状态
	local inTeamState = true;
	self:SwitchShowState(inTeamState);
end

--当主玩家退出队伍
function UITeamMine:OnQuit()
	local inTeamState = false;
	self:SwitchShowState(inTeamState);
	self:UnSelect();
	for i = 1, TeamConsts.MemberCeiling do
		self:RemoveMember(i)
	end
end

--队员信息发生变化
function UITeamMine:OnMemberChange(index)
	local memberVO = TeamModel:GetMember(index);
	self:ShowMemberInfo(memberVO); --面板更新队员显示
	self:UpdatePanelOperate(); -- 更新操作面板
end

--队员信息发生变化
function UITeamMine:OnMemberAppearanceChange(index)
	local memberVO = TeamModel:GetMember(index);
	self:Show3DMember(memberVO); --面板更新队员显示
end
