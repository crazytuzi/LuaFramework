--[[
组队副本准备面板
郝户
2014年11月3日15:31:29
]]

_G.UIDungeonTeamPrepare = BaseUI:new("UIDungeonTeamPrepare");

UIDungeonTeamPrepare.dungeonTeamInfo = {};
UIDungeonTeamPrepare.isAllReady = false; --所有人都已经同意
UIDungeonTeamPrepare.confirmUID = nil;

function UIDungeonTeamPrepare:Create()
	self:AddSWF("dungeonTeamPrepare.swf", true, "center" );
end

function UIDungeonTeamPrepare:OnLoaded(objSwf)
	objSwf.txtName.text      = StrConfig['dungeon102'];
	objSwf.txtStatus.text    = StrConfig['dungeon103'];
	objSwf.txtReady.text     = StrConfig['dungeon104'];
	objSwf.txtPrompt.text    = StrConfig['dungeon101'];
	
	objSwf.txtReady._visible = false;
	objSwf.btnClose.click    = function() self:OnBtnCloseClick(); end
	objSwf.btnAgree.click    = function() self:OnBtnAgreeClick(); end
	objSwf.btnRefuse.click   = function() self:OnbtnRefuseClick(); end
end

function UIDungeonTeamPrepare:OnHide()
	self:StopTimer();
	self.dungeonTeamInfo = {};
end

function UIDungeonTeamPrepare:OnBtnAgreeClick()
	local needConfirmCost, itemId, itemNum = self:NeedConfirmCost();
	local needConfirmAbstain, abstainId = self:NeedConfirmAbstain();
	local confirmFunc;
	if needConfirmCost and needConfirmAbstain then
		confirmFunc = function()
			local cb = function()
				self:AgreeEnter();
			end
			self:OpenItemCostConfirm( itemId, itemNum, cb );
		end
		self:OpenAbstainConfirm(abstainId, confirmFunc)
	elseif needConfirmCost then
		confirmFunc = function()
			self:AgreeEnter();
		end
		self:OpenItemCostConfirm( itemId, itemNum, confirmFunc );
	elseif needConfirmAbstain then
		confirmFunc = function()
			UIDungeonCountDown:AbstainDungeon();
			self:AgreeEnter();
		end
		self:OpenAbstainConfirm(abstainId, confirmFunc)
	else
		self:AgreeEnter();
	end
end

function UIDungeonTeamPrepare:NeedConfirmCost()
	local dungeonId = self.dungeonTeamInfo.dungeonId
	local cfg = t_dungeons[dungeonId];
	if not cfg then return; end
	local group = cfg.group;
	local dungeonGroup = DungeonModel:GetDungeonGroup( group );
	local restFreeTimes = dungeonGroup:GetRestFreeTimes()
	local restPayTimes = dungeonGroup:GetRestPayTimes()
	if restFreeTimes <= 0 then
		if restPayTimes > 0 then
			local usedPayTimes = dungeonGroup:GetUsedPayTimes()
			local itemNum = usedPayTimes + 1; -- 第几次付费进入，就需要几个道具
			local itemId = cfg.pay_item;
			if BagModel:GetItemNumInBag( itemId ) >= itemNum then
				return true, itemId, itemNum;
			else
				Debug("道具不足");
				return false;
			end
		else
			Debug("无剩余次数")
			return false;
		end
	else
		return false;
	end
end

-- 是否需放弃确认
function UIDungeonTeamPrepare:NeedConfirmAbstain()
	if UIDungeonCountDown.timerKey ~= nil then
		return true, UIDungeonCountDown.dungeonId;
	else
		return false;
	end
end


-- @param abstainId: 放弃的副本id
function UIDungeonTeamPrepare:OpenAbstainConfirm(abstainId, cb)
	local cfg = t_dungeons[abstainId];
	if cfg then
		local dungeonName = cfg.name;
		local content = string.format( StrConfig["dungeon505"], dungeonName, dungeonName)
		local confirmLabel = StrConfig["dungeon503"];
		local cancelLabel  = StrConfig["dungeon504"];
		self.confirmUID = UIConfirm:Open( content, cb, nil, confirmLabel, cancelLabel );
	end
end

function UIDungeonTeamPrepare:OpenItemCostConfirm(itemId, num, cb)
	local itemCfg = t_item[itemId];
	if itemCfg then
		local itemName = itemCfg.name;
		local content  = string.format( StrConfig["dungeon506"], itemName, num );
		local confirmLabel = StrConfig["dungeon508"];
		local cancelLabel  = StrConfig["dungeon504"];
		self.confirmUID = UIConfirm:Open( content, cb, nil, confirmLabel, cancelLabel );
	end
end

function UIDungeonTeamPrepare:OnbtnRefuseClick()
	self:Refuse();
end

function UIDungeonTeamPrepare:OnBtnCloseClick()
	self:Refuse();
end

function UIDungeonTeamPrepare:AgreeEnter()
	self:StopTimer();
	local dungeonLine = self.dungeonTeamInfo.line;
	if CPlayerMap:GetCurLineID() == dungeonLine then
		self:AgreeEnterDungeon();
		return;
	end
	DungeonController.afterLineChange = function()
		self:AgreeEnterDungeon();
	end
	MainPlayerController:ReqChangeLine(dungeonLine);
end

function UIDungeonTeamPrepare:AgreeEnterDungeon()
	local reply = DungeonConsts.Agree;
	DungeonController:ReqReplyTeamDungeon(reply);
end

function UIDungeonTeamPrepare:Refuse()
	self:StopTimer();
	local reply = DungeonConsts.Refuse;
	DungeonController:ReqReplyTeamDungeon(reply);
end

---------------------------------------------------------------------------

function UIDungeonTeamPrepare:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime.text = "";
	self:UpdateShow();
	if not TeamUtils:MainPlayerIsCaptain() then
		self:StartTimer(); -- 10秒自动拒绝
	end
end

function UIDungeonTeamPrepare:UpdateShow()
	local objSwf = self.objSwf;
	local list = objSwf and objSwf.list;
	if not list then return; end
	local teamList = self.dungeonTeamInfo.dungeonTeamList;
	local showList, isMainPlayerReady = self:GetShowInfo( teamList );
	if not showList or nil == isMainPlayerReady then return; end
	--更新列表
	list.dataProvider:cleanUp();
	for _, vo in pairs(showList) do
		list.dataProvider:push( UIData.encode(vo) );
	end
	list:invalidateData();
	--更新状态
	objSwf.btnAgree._visible  = not isMainPlayerReady;
	objSwf.btnRefuse._visible = not isMainPlayerReady;
	objSwf.txtReady._visible  = isMainPlayerReady;
end

--获取用于显示的list、主玩家是否已准备
function UIDungeonTeamPrepare:GetShowInfo( list )
	local showList = {};
	local isMainPlayerReady = false;
	for roleId, vo in pairs(list) do
		local roleName = TeamModel:GetMemberName(roleId);
		local status = vo.status;
		if roleId == MainPlayerController:GetRoleID() and status == DungeonConsts.PrepareStatus_Agree then
			isMainPlayerReady = true;
		end
		local statusStr, statusColor = DungeonConsts:GetPrepareStatusTxt(status);
		local showVO = { roleId = roleId, name = roleName, status = statusStr, statusColor = statusColor };
		showList[roleId] = showVO;
	end
	return showList, isMainPlayerReady;
end

local timerKey;
local time;
function UIDungeonTeamPrepare:StartTimer()
	time = DungeonConsts.TeamDungeonAutoRefuse;
	local cb = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	self:UpdateTimeShow();
end

function UIDungeonTeamPrepare:OnTimer()
	time = time - 1;
	if time == 0 then
		self:StopTimer();
		self:OnTimeUp();
		return
	end
	self:UpdateTimeShow();
end

function UIDungeonTeamPrepare:OnTimeUp()
	self:Refuse();
	UIConfirm:Close( self.confirmUID );
end

function UIDungeonTeamPrepare:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:UpdateTimeShow();
	end
end

function UIDungeonTeamPrepare:UpdateTimeShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime._visible = timerKey ~= nil;
	objSwf.txtTime.text = string.format( StrConfig['dungeon105'], time );
end

-------------------------------------------------------------------------------------------------

--打开(已打开则更新)面板
--@param dungeonTeamInfo 从服务器获取到的组队副本信息{ 副本id, 队长所在线, { roleId, status } }
function UIDungeonTeamPrepare:TryOpen( dungeonTeamInfo )
	self:UpdateTeamInfo( dungeonTeamInfo );
	--队伍有人拒绝则本次无法进入副本，直接关闭面板
	if self:IsSomeOneRefused() then
		self:Hide()
		return
	end
	--队伍所有人同意，关闭面板
	if self:IsAllAgree() then
		self:Hide()
		return
	end
	if not self:IsShow() then
		self:Show();
	else
		self:UpdateShow()
	end
end

function UIDungeonTeamPrepare:IsSomeOneRefused()
	local dungeonTeamList = self.dungeonTeamInfo.dungeonTeamList
	if dungeonTeamList then
		for _, statusVO in pairs( dungeonTeamList ) do
			if statusVO.status == DungeonConsts.PrepareStatus_Refuse then --队伍有人拒绝则本次无法进入副本，直接关闭面板
				return true
			end
		end
	end
	return false
end

function UIDungeonTeamPrepare:IsAllAgree()
	local dungeonTeamList = self.dungeonTeamInfo.dungeonTeamList
	if not dungeonTeamList then return false end
	for _, statusVO in pairs( dungeonTeamList ) do
		if statusVO.status ~= DungeonConsts.PrepareStatus_Agree then
			return false
		end
	end
	return true
end

--更新组队副本队友准备状态
function UIDungeonTeamPrepare:UpdateTeamInfo( dungeonTeamInfo )
	if dungeonTeamInfo.dungeonId then
		self.dungeonTeamInfo.dungeonId = dungeonTeamInfo.dungeonId;
	end
	if dungeonTeamInfo.line then
		self.dungeonTeamInfo.line = dungeonTeamInfo.line;
	end
	if dungeonTeamInfo.dungeonTeamList then
		if not self.dungeonTeamInfo.dungeonTeamList then
			self.dungeonTeamInfo.dungeonTeamList = {};
		end
		for _, statusVO in ipairs( dungeonTeamInfo.dungeonTeamList ) do
			self.dungeonTeamInfo.dungeonTeamList[ statusVO.roleId ] = statusVO;
		end
	end
end