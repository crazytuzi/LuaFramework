--[[
队伍:附近队伍面板
郝户
2014年9月24日17:31:09
]]

_G.UITeamNearby = BaseUI:new("UITeamNearby")

--刷新列表冷却剩余时间
UITeamNearby.cdTime = 0;
--timer key
UITeamNearby.timerKey = nil;
--缓存附近队伍列表
UITeamNearby.teamList = nil;

function UITeamNearby:Create()
	self:AddSWF("teamNearbyPanel.swf", true, nil);
end

function UITeamNearby:OnLoaded(objSwf)
	objSwf.btnRefresh.click      = function() self:OnBtnRefreshClick() end
	objSwf.listTeam.itemBtnClick = function(e) self:OnBtnApplyClick(e) end
end

function UITeamNearby:OnShow()
	self:UpdateShow();
	self:TryQueryTeamNearby();
end

function UITeamNearby:UpdateShow()
	self:UpdateList();
	self:UpdateBtn();
end

function UITeamNearby:UpdateList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local teamList = TeamModel:GetNearbyTeams();
	local list = objSwf.listTeam;
	list.dataProvider:cleanUp();
	for _, teamVO in pairs(teamList) do
		local vo = table.clone(teamVO);
		vo.maxRoleNum = TeamConsts.MemberCeiling;
		list.dataProvider:push( UIData.encode(vo) );
	end
	list:invalidateData();
end

function UITeamNearby:UpdateBtn()
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

function UITeamNearby:TryQueryTeamNearby()
	if self.cdTime <= 0 then
		TeamController:QueryTeamNearByInfo();
	end
end

function UITeamNearby:OnBtnRefreshClick()
	--请求刷新列表
	self:TryQueryTeamNearby();
	--开始刷新cd计时
	self:StartCDTimer();
end

--点击申请按钮
function UITeamNearby:OnBtnApplyClick(e)
	-- 申请失败：申请入队玩家已有队伍
	if TeamModel:IsInTeam() then
		FloatManager:AddCenter( t_sysnotice[2001017].text );--"您当前已经有队伍了"
		return;
	end
	-- 申请入队
	local teamId = e.item.teamId;
	if teamId then
		TeamController:ApplyJoinTeam(teamId);
	end
end

function UITeamNearby:StartCDTimer()
	self.cdTime = TeamConsts.RefreshCD;
	local cb = function()
		self:OnTimer();
	end
	self.timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	self:UpdateBtn();
end

--倒计时
function UITeamNearby:OnTimer()
	self.cdTime = self.cdTime - 1;
	if self.cdTime == 0 then
		self:OnTimeUp();
	end
	self:UpdateBtn();
end

function UITeamNearby:OnTimeUp()
	self:StopTimer();
	self:UpdateBtn();
end

function UITeamNearby:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

function UITeamNearby:ListNotificationInterests()
	return { NotifyConsts.TeamNearby };
end

function UITeamNearby:HandleNotification(name, body)
	if name == NotifyConsts.TeamNearby then
		self:UpdateList();
	end
end