--[[
队伍:附近玩家面板
郝户
2014年9月24日17:31:58
]]

_G.UITeamPlayerNearby = BaseUI:new("UITeamPlayerNearby")

--刷新列表冷却剩余时间
UITeamPlayerNearby.cdTime = 0;
--timer key
UITeamPlayerNearby.timerKey = nil;
--缓存附近玩家列表
UITeamPlayerNearby.playerList = nil;

function UITeamPlayerNearby:Create()
	self:AddSWF( "teamPlayerNearbyPanel.swf", true, nil);
end

function UITeamPlayerNearby:OnLoaded(objSwf, name)
	objSwf.btnRefresh.click        = function() self:OnBtnRefreshClick() end
	objSwf.listPlayer.itemBtnClick = function(e) self:OnBtnInviteClick(e) end
end

function UITeamPlayerNearby:OnShow(name)
	self:UpdateShow();
	self:TryQueryPlayerNearby();
end

function UITeamPlayerNearby:UpdateShow()
	self:UpdateList();
	self:UpdateBtn();
end

function UITeamPlayerNearby:UpdateList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local playerList = TeamModel:GetNearbyPlayers();
	local list = objSwf.listPlayer;
	list.dataProvider:cleanUp();
	for _, playerVO in pairs( playerList ) do
		local vo = table.clone(playerVO);
		vo.profTxt = PlayerConsts:GetProfName( playerVO.prof );
		vo.stateTxt = TeamUtils:GetTeamStateTxt( playerVO.teamState );
		list.dataProvider:push( UIData.encode(vo) );
	end
	list:invalidateData();
end

function UITeamPlayerNearby:UpdateBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local btn = objSwf.btnRefresh;
	if self.cdTime > 0 then
		btn.label = self.cdTime;
		btn.disabled = true;
	else
		btn.label = UIStrConfig["team14"];
		btn.disabled = false;
	end
end

function UITeamPlayerNearby:TryQueryPlayerNearby()
	if self.cdTime <= 0 then
		TeamController:QueryPlayerNearByInfo();
	end
end

function UITeamPlayerNearby:OnBtnRefreshClick()
	self:TryQueryPlayerNearby();
	self:StartCDTimer();
end

--点击邀请按钮
function UITeamPlayerNearby:OnBtnInviteClick(e)
	--邀请失败：你不是队长，无法邀请
	if TeamModel:IsInTeam() and not TeamUtils:MainPlayerIsCaptain() then
		FloatManager:AddCenter( t_sysnotice[2001008].text );--"您不是队长"
		return;
	end
	--邀请失败：所在队伍人满
	if TeamModel:GetMemberNum() >= TeamConsts.MemberCeiling then
		FloatManager:AddCenter( t_sysnotice[2001003].text ); --"队伍已满，无法邀请他人"
		return;
	end
	--发送邀请消息
	local playerId = e.item.roleID;
	if playerId then
		TeamController:InvitePlayerJoin(playerId);
	end
end

function UITeamPlayerNearby:StartCDTimer()
	self.cdTime = TeamConsts.RefreshCD;
	local cb = function()
		self:OnTimer();
	end
	self.timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	self:UpdateBtn();
end

--倒计时
function UITeamPlayerNearby:OnTimer()
	self.cdTime = self.cdTime - 1;
	if self.cdTime == 0 then
		self:OnTimeUp();
	end
	self:UpdateBtn();
end

function UITeamPlayerNearby:OnTimeUp()
	self:StopTimer();
	self:UpdateBtn();
end

function UITeamPlayerNearby:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

function UITeamPlayerNearby:ListNotificationInterests()
	return { NotifyConsts.PlayerNearby };
end

function UITeamPlayerNearby:HandleNotification(name, body)
	if name == NotifyConsts.PlayerNearby then
		self:UpdateList()
	end
end