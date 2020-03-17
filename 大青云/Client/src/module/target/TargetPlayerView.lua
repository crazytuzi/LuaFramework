--[[
当前选中目标-玩家
haohu
2014年8月19日19:55:04
]]

_G.UITargetPlayer = UITarget:new("UITargetPlayer");

function UITargetPlayer:GetSwfName()
	return "targetPlayer.swf";
end

function UITargetPlayer:HandleEvents( objSwf )
	objSwf.btnView.click   = function() self:OnBtnViewClick(); end
	objSwf.btnView.rollOver    = function() self:OnBtnViewRollOver(); end
	objSwf.btnView.rollOut    = function() self:OnBtnViewRollOut(); end

	objSwf.btnDeal.click   = function() self:OnBtnDealClick(); end
	objSwf.btnDeal.rollOver    = function() self:OnBtnDealRollOver(); end
	objSwf.btnDeal.rollOut    = function() self:OnBtnDealRollOut(); end

	objSwf.btnTeam.click   = function() self:OnBtnTeamClick(); end
	objSwf.btnTeam.rollOver    = function() self:OnBtnTeamRollOver(); end
	objSwf.btnTeam.rollOut    = function() self:OnBtnTeamRollOut(); end

	objSwf.btnChat.click   = function() self:OnBtnChatClick(); end
	objSwf.btnChat.rollOver    = function() self:OnBtnChatRollOver(); end
	objSwf.btnChat.rollOut    = function() self:OnBtnChatRollOut(); end

	objSwf.btnFriend.click = function() self:OnBtnFriendClick(); end
	objSwf.btnFriend.rollOver    = function() self:OnBtnFriendRollOver(); end
	objSwf.btnFriend.rollOut    = function() self:OnBtnFriendRollOut(); end

	objSwf.btnMarry.click = function() self:OnBtnMarryClick(); end
	objSwf.btnMarry.rollOver    = function() self:OnBtnMarryRollOver(); end
	objSwf.btnMarry.rollOut    = function() self:OnBtnMarryRollOut(); end

end

function UITargetPlayer:GetWidth()
	return 341;
end

--查
function UITargetPlayer:OnBtnViewClick()
	local playerId = TargetModel:GetId();
	RoleController:ViewRoleInfo(playerId)
end

function UITargetPlayer:OnBtnViewRollOver(  )
	TipsManager:ShowBtnTips( StrConfig['001']);
end

function UITargetPlayer:OnBtnViewRollOut(  )
	TipsManager:Hide();
end

--易
function UITargetPlayer:OnBtnDealClick()
    local playerId = TargetModel:GetId();
    DealController:InviteDeal(playerId);
end

function UITargetPlayer:OnBtnDealRollOver( )
	TipsManager:ShowBtnTips( StrConfig['002']);
end

function UITargetPlayer:OnBtnDealRollOut(  )
	TipsManager:Hide();
end

--组
function UITargetPlayer:OnBtnTeamClick()
	local playerId = TargetModel:GetId();
	TeamController:InvitePlayerJoin(playerId);
end

function UITargetPlayer:OnBtnTeamRollOver(  )
	TipsManager:ShowBtnTips( StrConfig['003']);
end

function UITargetPlayer:OnBtnTeamRollOut(  )
	TipsManager:Hide();
end

--聊
function UITargetPlayer:OnBtnChatClick()
	local playerId   = TargetModel:GetId();
	local player     = CPlayerMap:GetPlayer(playerId);
	local playerInfo = player:GetPlayerInfo();
	ChatController:OpenPrivateChat( playerId, playerInfo.eaName, player.icon, playerInfo.eaLevel, playerInfo.eaVIPLevel );
end

function UITargetPlayer:OnBtnChatRollOver( )
	TipsManager:ShowBtnTips( StrConfig['004']);
end

function UITargetPlayer:OnBtnChatRollOut( )
	TipsManager:Hide();
end

--友
function UITargetPlayer:OnBtnFriendClick()
	local playerId = TargetModel:GetId();
	FriendController:AddFriend(playerId);
end

function UITargetPlayer:OnBtnFriendRollOver( )
	TipsManager:ShowBtnTips( StrConfig['005']);
end

function UITargetPlayer:OnBtnFriendRollOut( )
	TipsManager:Hide();
end

--结婚
function UITargetPlayer:OnBtnMarryClick()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Marry) then
		FloatManager:AddNormal(StrConfig['marriage217'])
		return 
	end;
	if not FriendModel:GetIsFriend(TargetModel:GetId()) then
		FloatManager:AddNormal(StrConfig["marriage087"]);
		return;
	end
	UIMarryProposal:ShowJudge(TargetModel:GetId());
end

function UITargetPlayer:OnBtnMarryRollOver( )
	TipsManager:ShowBtnTips( StrConfig['006']);
end

function UITargetPlayer:OnBtnMarryRollOut( )
	TipsManager:Hide();
end

--更新子类,重载父类里面的方法
function UITargetPlayer:OnChildUpdate()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local targetProf = TargetModel:GetProf();
	local infoCfg = t_playerinfo[prof];
	local targetInfoCfg = t_playerinfo[targetProf];
	objSwf.btnDeal.visible = false;
	objSwf.btnMarry.visible = false;    -- changer: houxudong date:2016/6/27 reason：暂时屏蔽
	if not infoCfg or (not targetInfoCfg) then
		objSwf.btnMarry.visible = false;
		return;
	end
	if infoCfg.sex == targetInfoCfg.sex then
		objSwf.btnMarry.visible = false;
	else
		objSwf.btnMarry.visible = true;
	end
	objSwf.btnMarry.visible = false;    -- changer: houxudong date:2016/6/27 reason：暂时屏蔽
end


function UITargetPlayer:GetIconUrl()
	local iconId = TargetModel:GetIcon();
	if not iconId then return end;
	return ResUtil:GetHeadIcon( iconId );
end

function UITargetPlayer:GetName()
	return TargetModel:GetName();
end

function UITargetPlayer:GetLevel()
	return TargetModel:GetLevel();
end

------------------------------检测是否跨服,跨服时的处理-------------------------
function UITargetPlayer:CheckInterServer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnView.visible = not MainPlayerController.isInterServer;
	objSwf.btnDeal.visible =  MainPlayerController.isInterServer;   -- changer: houxudong date:2016/6/w27 reason：暂时屏蔽
	objSwf.btnTeam.visible = not MainPlayerController.isInterServer;
	objSwf.btnChat.visible = not MainPlayerController.isInterServer;
	objSwf.btnFriend.visible = not MainPlayerController.isInterServer;
end