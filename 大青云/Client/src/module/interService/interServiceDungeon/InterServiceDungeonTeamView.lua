--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceDungeonTeamView = BaseUI:new("UIInterServiceDungeonTeamView");

function UIInterServiceDungeonTeamView:Create()
	self:AddSWF("interDungeonTeamPanel.swf", true, "center");
end

function UIInterServiceDungeonTeamView:OnLoaded(objSwf)
	self.roleLoaders = { objSwf.loader1, objSwf.loader2, objSwf.loader3, objSwf.loader4 };
	table.foreach( self.roleLoaders, function(_, loader) loader.hitTestDisable = true; end );
end

--更新队员列表显示
function UIInterServiceDungeonTeamView:UpdateMemberListShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	table.foreach( self.roleLoaders, function(_, loader) loader._visible = false; end );
	if TeamModel:IsInTeam() then
		local members = TeamModel:GetMemberList();
		for id, memberVO in pairs(members) do
			self:ShowMember(memberVO);
		end
	end
end

--显示队员( 如果已经在队伍里，更新显示 )
function UIInterServiceDungeonTeamView:ShowMember(memberVO)
	self:Show3DMember(memberVO);
end

--移除某队员
--@param index:队员索引
function UIInterServiceDungeonTeamView:RemoveMember(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
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
end

--显示队员3D形象
function UIInterServiceDungeonTeamView:Show3DMember( memberVO )
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

-----------------------------------------------------------------------
function UIInterServiceDungeonTeamView:IsTween()
	return true;
end

function UIInterServiceDungeonTeamView:GetPanelType()
	return 1;
end

function UIInterServiceDungeonTeamView:IsShowSound()
	return true;
end

function UIInterServiceDungeonTeamView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
		
	--更新队员列表显示
	self:UpdateMemberListShow();	
end

function UIInterServiceDungeonTeamView:OnHide()
end

function UIInterServiceDungeonTeamView:GetWidth()
	return 903;
end

function UIInterServiceDungeonTeamView:GetHeight()
	return 632;
end

function UIInterServiceDungeonTeamView:OnBtnCloseClick()
	self:Hide();
end

function UIInterServiceDungeonTeamView:OnDelete()
	for k,_ in pairs(self.roleLoaders) do
		self.roleLoaders[k] = nil;
	end
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceDungeonTeamView:ListNotificationInterests()
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
function UIInterServiceDungeonTeamView:HandleNotification(name, body)
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
function UIInterServiceDungeonTeamView:OnMemberAdd(index)
	local memberVO = TeamModel:GetMember(index);
	if not memberVO then return; end
	self:ShowMember(memberVO); --面板显示队员
end

--当移除队员
function UIInterServiceDungeonTeamView:OnMemberRemove(index)
	self:RemoveMember( index );
end

--当主玩家加入队伍
function UIInterServiceDungeonTeamView:OnJoin()
	--如果队伍面板处于打开状态，切换到我的队伍标签页
	if UITeam:IsShow() then
		UITeam:ShowMyTeam();
	end
	--切换显示为有队伍状态
	local inTeamState = true;
	self:SwitchShowState(inTeamState);
end

--当主玩家退出队伍
function UIInterServiceDungeonTeamView:OnQuit()
	local inTeamState = false;
	self:SwitchShowState(inTeamState);
	self:UnSelect();
	self:UpdateMemberListShow();
end

--队员信息发生变化
function UIInterServiceDungeonTeamView:OnMemberChange(index)
	local memberVO = TeamModel:GetMember(index);
	self:ShowMemberInfo(memberVO); --面板更新队员显示
	self:UpdatePanelOperate(); -- 更新操作面板
end

--队员信息发生变化
function UIInterServiceDungeonTeamView:OnMemberAppearanceChange(index)
	local memberVO = TeamModel:GetMember(index);
	self:Show3DMember(memberVO); --面板更新队员显示
end