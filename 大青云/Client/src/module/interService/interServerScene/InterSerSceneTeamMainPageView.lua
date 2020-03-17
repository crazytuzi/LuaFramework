--[[
跨服战场 主界面：队友头像
wangshuai
]]

_G.UIInterSerSceneMainPage = BaseUI:new("UIInterSerSceneMainPage");

-------------------------Private functions--------------------------------

function UIInterSerSceneMainPage:Create()
	self:AddSWF( "InterSerSceneMainPageTeam.swf", true, "interserver" );
end

function UIInterSerSceneMainPage:OnLoaded(objSwf)
	objSwf.btnTitle.select = function(e) self:OnBtnTitleSelect(e); end
	local list = objSwf.listContainer.list;
	list.btnQuitClick = function() self:OnBtnQuitClick(); end
end

function UIInterSerSceneMainPage:NeverDeleteWhenHide()
	return true;
end

function UIInterSerSceneMainPage:OnShow()
	-- print("----------显示了")
	self:UpdateState();
	self:UpdateShow();
end

--左侧图标排列接口
function UIInterSerSceneMainPage:GetNextY()
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
function UIInterSerSceneMainPage:OnItemClick()
	InterSerSceneController:ReqInterSSTeamOut()
end

--鼠标悬浮头像
function UIInterSerSceneMainPage:OnItemRollOver(e)
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
function UIInterSerSceneMainPage:OnItemRollOut()
	TipsManager:Hide();
end

function UIInterSerSceneMainPage:OnBtnQuitClick()
	InterSerSceneController:ReqInterSSTeamOut()
end

--点击标题
function UIInterSerSceneMainPage:OnBtnTitleSelect(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.listContainer._visible = not e.selected;
end


------------------------Public functions----------------------------------

--更新显示
function UIInterSerSceneMainPage:UpdateShow()
	self:UpdateTitle();
	self:UpdateList();
end

--更新表头
function UIInterSerSceneMainPage:UpdateTitle()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numMember = InterSerSceneModel:GetMyTeamNum()
	objSwf.btnTitle.htmlLabel = string.format( StrConfig["mainmenuTeam001"], numMember, numMember, TeamConsts.MemberCeiling );
end

--更新列表
function UIInterSerSceneMainPage:UpdateList()
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
function UIInterSerSceneMainPage:GetMainPageTeammateUIData()
	local memberUIDataList = {};
	local memberList = {}
	for _, memberVO in pairs(InterSerSceneModel:GetMyTeamInfo()) do
		table.push( memberList, memberVO )
	end
	--table.sort( memberList, function( A, B ) return A:Precede(B) end )
	for _, memberVO in ipairs( memberList ) do
		local vo = {};
		vo.level     = memberVO.lvl;
		vo.nameLabel = memberVO.roleName;
		vo.nameColor = "0xffffff"
		vo.isCaptain = memberVO.status == 1 and true or false
		vo.isMainPlayer = memberVO.roleID == MainPlayerController:GetRoleID();
		vo.online = 1;
		table.push( memberUIDataList, UIData.encode(vo) );
	end

	while #memberUIDataList < TeamConsts.MemberCeiling do
		table.push( memberUIDataList, "" );
	end
	return memberUIDataList;
end

---------------------------------消息处理------------------------------------

function UIInterSerSceneMainPage:OnTeamQuit()
	self:UpdateState();
end

function UIInterSerSceneMainPage:OnTeamJoin()
	self:UpdateState();
	self:UpdateShow();
end

function UIInterSerSceneMainPage:UpdateState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local inTeam = InterSerSceneModel:GetMyIsHavaTeam()
	objSwf.listContainer._visible = inTeam;
	objSwf.btnTitle._visible = inTeam;
	objSwf.btnTitle.hitTestDisable = not inTeam;
end
