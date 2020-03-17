--[[
主界面：队友头像
郝户
2014年9月28日10:29:50
]]

_G.UIMainTeammate = BaseUI:new("UIMainTeammate");

-------------------------Private functions--------------------------------

function UIMainTeammate:Create()
	self:AddSWF( "mainPageTeammate.swf", true, "bottom" );
end

function UIMainTeammate:OnLoaded(objSwf)
	objSwf.btnTitle.select = function(e) self:OnBtnTitleSelect(e); end
	local list = objSwf.listContainer.list;
	list.itemClick    = function(e) self:OnItemClick(e); end
	list.itemRClick   = function(e) self:OnItemClick(e); end
	list.itemRollOver = function(e) self:OnItemRollOver(e); end
	list.itemRollOut  = function() self:OnItemRollOut(); end
	list.hpRollOver   = function(e) self:OnHpRollOver(e); end
	list.hpRollOut    = function() self:OnHpRollOut(); end
	list.btnQuitClick = function() self:OnBtnQuitClick(); end
end

function UIMainTeammate:NeverDeleteWhenHide()
	return true;
end

function UIMainTeammate:OnShow()
	self:UpdateState();
	self:UpdateShow();
end

--左侧图标排列接口
function UIMainTeammate:GetNextY()
	local objSwf = self.objSwf;
	if not objSwf then return 0 end;
	if TeamModel:IsInTeam() then
		local mc = objSwf.listContainer;
		if mc._visible then
			local num = TeamModel:GetMemberNum();
			local listHeight = mc._height;
			local height = mc._y + ( mc._height / TeamConsts.MemberCeiling ) * num;
			return objSwf._y + height;
		else
			return objSwf._y + mc._y;
		end
	end
	return 0;
end

--事件处理-----------------------------------

--鼠标点击头像
function UIMainTeammate:OnItemClick(e)
	local index = e.item.index;
	local memberVO = TeamModel:GetMember(index);
	if memberVO then
		UITeamRoleOper:Open(memberVO);
		TipsManager:Hide();
	end
end

--鼠标悬浮头像
function UIMainTeammate:OnItemRollOver(e)
	local str = "";
	local data = e.item;
	local index = data and data.index;
	if not index then return end;
	local vo = TeamModel:GetMember(index);
	if vo then
		local profName  = PlayerConsts:GetProfName( vo.prof );
		local guildName = vo.guildName;
		if not guildName or guildName == "" then guildName = StrConfig['mainmenuTeam002'] end
		local mapName = MapUtils:GetMapName( vo.mapId );
		str = string.format( StrConfig['tips401'], vo.roleName, vo.level, profName, guildName, vo.line, mapName );
		--头像tips
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
end

--鼠标滑离头像
function UIMainTeammate:OnItemRollOut()
	TipsManager:Hide();
end

--鼠标悬浮血条
function UIMainTeammate:OnHpRollOver(e)
	local data = e.item;
	if not data then return; end
	local hp, maxHp = data.hp, data.maxHp;
	if hp and maxHp then
		TipsManager:ShowBtnTips( hp.."/"..maxHp );
	end
end

--鼠标划离血条
function UIMainTeammate:OnHpRollOut()
	TipsManager:Hide();
end

function UIMainTeammate:OnBtnQuitClick()
	TeamController:ConfirmQuit()
end

--点击标题
function UIMainTeammate:OnBtnTitleSelect(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.listContainer._visible = not e.selected;
end


------------------------Public functions----------------------------------

--更新显示
function UIMainTeammate:UpdateShow()
	self:UpdateTitle();
	self:UpdateList();
end

--更新表头
function UIMainTeammate:UpdateTitle()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numMember = TeamModel:GetMemberNum();
	objSwf.btnTitle.htmlLabel = string.format( StrConfig["mainmenuTeam001"], numMember, numMember, TeamConsts.MemberCeiling );
end

--更新列表
function UIMainTeammate:UpdateList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local mc = objSwf.listContainer;
	if not mc._visible then return end;
	local list = mc.list;
	list.dataProvider:cleanUp();
	local dataProvider = self:GetMainPageTeammateUIData();
	for i = 1, #dataProvider do
		local uiData = dataProvider[i];
		list.dataProvider:push( uiData );
	end
	list:invalidateData();
end

--获取队员头像列表UIData数据
function UIMainTeammate:GetMainPageTeammateUIData()
	local memberUIDataList = {};
	local memberList = {}
	for _, memberVO in pairs(TeamModel.memberList) do
		table.push( memberList, memberVO )
	end
	table.sort( memberList, function( A, B ) return A:Precede(B) end )
	for _, memberVO in ipairs( memberList ) do
		local vo = {};
		vo.index     = memberVO.index;
		vo.level     = memberVO.level;
		vo.hp        = memberVO.hp;
		vo.maxHp     = memberVO.maxHp;
		vo.online    = memberVO.online == TeamConsts.Online;
		vo.nameLabel = memberVO.roleName;
		vo.nameColor = memberVO:GetNameColor()
		vo.isCaptain = memberVO:IsCaptain()
		vo.isMainPlayer = memberVO:IsMainPlayer()
		table.push( memberUIDataList, UIData.encode(vo) );
	end

	while #memberUIDataList < TeamConsts.MemberCeiling do
		table.push( memberUIDataList, "" );
	end
	return memberUIDataList;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIMainTeammate:ListNotificationInterests()
	return {
		NotifyConsts.TeamMemberAdd,
		NotifyConsts.TeamMemberRemove,
		NotifyConsts.MemberChange,
		NotifyConsts.TeamJoin,
		NotifyConsts.TeamQuit,
	};
end

--处理消息
function UIMainTeammate:HandleNotification(name, body)
	if name == NotifyConsts.TeamMemberAdd then
		self:UpdateShow();
	elseif name == NotifyConsts.TeamMemberRemove then
		self:UpdateShow();
	elseif name == NotifyConsts.MemberChange then
		if TeamConsts.MainPageTeamAttrs[ body.attrType ] then
			self:UpdateShow();
		end
	elseif name == NotifyConsts.TeamJoin then
		self:OnTeamJoin();
	elseif name == NotifyConsts.TeamQuit then
		self:OnTeamQuit();
	end
end

function UIMainTeammate:OnTeamQuit()
	self:UpdateState();
end

function UIMainTeammate:OnTeamJoin()
	self:UpdateState();
	self:UpdateShow();
end

function UIMainTeammate:UpdateState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local inTeam = TeamModel:IsInTeam();
	objSwf.listContainer._visible = inTeam;
	objSwf.btnTitle._visible = inTeam;
	objSwf.btnTitle.hitTestDisable = not inTeam;
end
