include("guildPlayer")
include("guildApplyPlayer")

guildData = class("guildData")
guildData.PLAYER_COUNT_PER_PAGE = 6;
guildData.APPLY_COUNT_PER_PAGE = 6;
guildData.MAX_GUILD_NAME_LENGTH = 14;

function guildData:ctor()
	
	self.playerList = {};
	self.applyList = {};
	
	self.guildName = "";
	self.guildNotice = "";
	self.warScore = 0;
end

function guildData:destroy()
	
	self.playerList = {};
	self.applyList = {};
	
	self.guildName = "";
	self.guildNotice = "";
	
end

function guildData:init()
	
end

-- 通用信息
function guildData:setName(name)
	
	self.guildName = name;
	
end

function guildData:getName()

	return self.guildName;

end

function guildData:setWarScore(warScore)
	
	self.warScore = warScore;
	
end

function guildData:getNotice()
	
	if self.guildNotice == "" then
		return "会长很懒，什么都没留下！";
	else
		return self.guildNotice;
	end
	
end

-- 是否有申请状态
function guildData:isHaveNotifyState()
	
	return self:isHaveApplyedPlayer() or (not self:isAlreadySignIn() and self:isHaveGuildMyself());
	
end

function guildData:isHaveApplyedPlayer()
	
	return (self:isMyselfPrecident() or self:isMyselfElders()) and self.applyList and #self.applyList > 0;
	
end

function guildData:setNotice(notice)
	
	self.guildNotice = notice;
	
end

--
function guildData:isAlreadySignIn()
	
	return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_SIGNIN_COUNT) > 0;
	
end

-- 是否激活
function guildData:isActive()
	
	return dataManager.playerData:getLevel() >= dataConfig.configs.ConfigConfig[0].guildLevelLimit;
	
end

-- 是否有公会
function guildData:isHaveGuildMyself()

	return self:getMyGuildID() > 0;
	
end

function guildData:getMyGuildID()
	
	return dataManager.playerData:getExtraAttr(enum.PLAYER_EXTRA_ATTR.PLAYER_EXTRA_ATTR_GUILD);
	
end

-- 是否是会长
function guildData:isMyselfPrecident()
	
	for k,v in ipairs(self.playerList) do
		
		if v:getID() == dataManager.playerData:getPlayerId() then
			
			return v:isPresident();
			
		end
		
	end
	
end

function guildData:isMyselfElders()
	
	for k,v in ipairs(self.playerList) do
		
		if v:getID() == dataManager.playerData:getPlayerId() then
			
			return v:isElders();
			
		end
		
	end
	
	return false;	
end

-- 获得成员
function guildData:getPlayerByID(id)
	
	for k,v in ipairs(self.playerList) do
		
		if v:getID() == id then
			
			return v, k;
			
		end
		
	end
	
	return nil;
end

-- 个人积分
function guildData:getMyScore()
	
	local playerData = self:getPlayerByID(dataManager.playerData:getPlayerId());
	
	return playerData:getWarScore();
end

-- 个人积分奖励加成
function guildData:getMyGuildRewardRate()
	
	local score = self:getMyScore();
	
	if score == 0 then
		return 0;
	end
	
	local data = dataConfig.configs.guildWarPerConfig[score];
	
	if data then
		
		return data.personalRat;
		
	else
		
		local lastData = dataConfig.configs.guildWarPerConfig[#dataConfig.configs.guildWarPerConfig];
		
		return lastData.personalRat;
	end
end

-- 公会积分
function guildData:getGuildScore()
	
	return self.warScore;
	
end

-- 获取申请者信息
function guildData:getApplyPlayerByID(id)
	
	for k,v in ipairs(self.applyList) do
		
		if v:getID() == id then
			
			return v, k;
			
		end
		
	end
	
	return nil;
		
end

function guildMemberListCompare(playerA, playerB) 
		
		if playerA:isPresident() then
		
			return true;
		
		elseif (playerA:isElders() or playerA:isMember()) and playerB:isPresident() then
			
			return false;
		
		elseif (playerA:isElders()) and playerB:isMember() then
			
			return true;
		
		elseif (playerB:isElders()) and playerA:isMember() then
			
			return false;
		
		else

				if playerA:isOnline() and not playerB:isOnline() then
					
					return true;
				
				elseif playerB:isOnline() and not playerA:isOnline() then
					
					return false;
					
				else
					
					return playerA:getLevel() > playerB:getLevel();
					
				end			
				
		end
		
end
-- 
function guildData:initPlayerFromServerData(serverData)
	
	self.playerList = {};
	
	for k, v in ipairs(serverData) do
		
		local player = guildPlayer.new();
		player:createByServerData(v);
		
		table.insert(self.playerList, player);
		
	end

	print("guildData:initPlayerFromServerData")
	table.sort(self.playerList, guildMemberListCompare);
	
end

function guildData:onAddMember(member)
	
	if member.id == dataManager.playerData:getPlayerId() then
		
		-- 自己被加入公会，
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MEMBER, 0);
		
	end
	
	if self:getPlayerByID(member.id) == nil then
		
		-- 玩家不存在，就添加
		
		local player = guildPlayer.new();
		player:createByServerData(member);
		
		table.insert(self.playerList, player);
		
	end
	
	print("guildData:onAddMember")
	
	table.sort(self.playerList, guildMemberListCompare);
	
end

function guildData:onDelMember(member)
	
	if member == dataManager.playerData:getPlayerId() then
		
		-- 是自己被踢掉了
		-- 清空数据
		self:destroy();
		
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_GUILD, 0);
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MY_APPLYS, 0);
		
	else
		
		local player, key = self:getPlayerByID(member);
		
		if key then
			table.remove(self.playerList, key );
			
			print("guildData:onDelMember")
			table.sort(self.playerList, guildMemberListCompare);
		end
	end
	
end

-- 总页数
function guildData:getPlayerlistTotalPage()
	
	if #self.playerList == 0 then
		
		return 1;
		
	else
	
		return math.ceil(#self.playerList / guildData.PLAYER_COUNT_PER_PAGE);
	
	end
	
end

-- 当前人数
function guildData:getPlayerCount()
	
	return #self.playerList;
	
end

-- 人数上限
function guildData:getMaxPlayerCount()
	
	return dataConfig.configs.ConfigConfig[0].guildPeopleLimit;
	
end

-- 签到奖励
function guildData:getDailyRewardGold()
	
	return dataConfig.configs.ConfigConfig[0].guildSignInGoldRewardCount;
	
end

-- pageNum 从 1 开始
function guildData:getPlayerListByPage(pageNum)

	local pageData = {};
	
	for i= 1 + (pageNum-1) * guildData.PLAYER_COUNT_PER_PAGE, pageNum * guildData.PLAYER_COUNT_PER_PAGE do
	
		local player = clone(self.playerList[i]);
		
		table.insert(pageData, player);
		
	end
	
	return pageData;
		
end

-- 
function guildData:isCanChangeNotice()
	
	return self:isMyselfElders() or self:isMyselfPrecident();
	
end

function guildData:isCanHandleApplyedPlayer()
	
	return self:isMyselfElders() or self:isMyselfPrecident();
	
end

function guildData:isCanEditDefencePlan()
	
	return (self:isMyselfElders() or self:isMyselfPrecident()); 
	
end

-- 申请列表
function guildData:initApplyListFromServerData(serverData)
	
	self.applyList = {};
	
	for k, v in ipairs(serverData) do
	
		local player = guildApplyPlayer.new();
		player:createByServerData(v);
		
		table.insert(self.applyList, player);
		
	end
	
end

function guildData:delApplyFromApplyList(targetID)
	
	local key = nil;
	
	for k,v in ipairs(self.applyList) do
		
		if v:getID() == targetID then
			
			key = k;
			break;
		end
		
	end
	
	if key then
		table.remove(self.applyList, key);
	end
	
	eventManager.dispatchEvent({name = global_event.MAIN_UI_GUILD_STATE});
	
end

function guildData:getTotalApplyPage()
	
	if #self.applyList == 0 then
		return 1;	
	else
		return math.ceil(#self.applyList / guildData.APPLY_COUNT_PER_PAGE);
	end
end

function guildData:getApplyDataByPage(pageNum)

	local pageData = {};
	
	for i= 1 + (pageNum-1) * guildData.APPLY_COUNT_PER_PAGE, pageNum * guildData.APPLY_COUNT_PER_PAGE do
	
		local player = clone(self.applyList[i]);
		
		table.insert(pageData, player);
		
	end
	
	return pageData;
	
end

function guildData:getCreateCostDiamond()
	
	return dataConfig.configs.ConfigConfig[0].createGuildPrice;
	
end

-- 获取备选列表
function guildData:getCandidatePlayers()
	
	local candidateList = {};
	for k, v in ipairs(self.playerList) do
		
		if v:canJoinGuildWar() and not dataManager.guildWarData:isPlayerInGuard(v:getID()) and (v:isOnline() or v:getOfflineTime() < 48 * 3600) then
			
			table.insert(candidateList, v);
		end
		
	end
	
	return candidateList;
end

------------------------------- user interface handle -----------------------------------

---
function guildData:onHandleCreateGuild(guildName)

	if guildName == "" then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="名称不能为空" });
		return;
			
	end
	
	if math.getStrByte(guildName) > guildData.MAX_GUILD_NAME_LENGTH then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="名字过长" });
		return;
	end
	
	if global.hasfilterText(guildName) then
		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "名称中包含不当内容，请重新输入！"});			
		return;
	end
	
	if dataManager.playerData:getGem() < self:getCreateCostDiamond() then
		
		eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
				
		return;
	end

	eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW,
				text = "公会创建后，你将自动成为会长，是否确认创建公会", callBack = function() 
					
					-- send message
					sendAskCreateGuild(guildName);
				end});
	
end

-- 
function guildData:onHandleClickGuildButton()

	if not self:isActive() then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = dataConfig.configs.ConfigConfig[0].guildLevelLimit.."级开启公会" });
					
		return;
		
	end
	
	if self:isHaveGuildMyself() then
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MEMBER, 0);
	else
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_GUILD, 0);
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MY_APPLYS, 0);
	end
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_SHOW, });
	
end

function guildData:onHandleChangeGuildNotice(guildNotice)
	
	if guildNotice == "" then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo ="公告内容不能为空" });
		return;
			
	end

	if global.hasfilterText(guildNotice) then
		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "公告中包含不当内容，请重新输入！"});			
		return;
	end
		
	sendAskSetGuildNotice(guildNotice);
	
end

function guildData:onHandleQuitGuild()

	if self:isMyselfPrecident() then
		
		if self:getPlayerCount() > 1 then
			
			eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "会长暂不能离开公会"});
		
		else
			
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				text = "因你离开公会，会导致公会解散，您确定要解散公会吗？", callBack = function() 
					
					-- send message
					
					sendAskQuitGuild();
				end});
				
		end
		
	else
		
		eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				text = "您确定要退出公会？", callBack = function() 
					
					-- send message
					
					sendAskQuitGuild();
				end});
					
	end
				
end

function guildData:onHandleSignIn()
	
	sendAskGuildSignIn();
	
end

function guildData:onHandleAgreeApply(targetID)
	
	sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_AGREE, targetID);
	
	self:delApplyFromApplyList(targetID);
	
end

function guildData:onHandleRefuseApply(targetID)
	
	sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_REJECT, targetID);
	
	self:delApplyFromApplyList(targetID);
	
end

-- 逐出公会操作
function guildData:onHandleKickPlayer(targetID)

	
	eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				text = "是否将该成员逐出公会？", callBack = function() 
					
					-- send message
					sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_KICKMEMBER, targetID);
					
				end});
	
end

--
function guildData:onHandleClickMemberMenu(targetID, rect)

	eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  targetID, from = "GUILD_MEMBER" });
	
end

function guildData:onHandleClickApplyPlayerMenu(targetID, rect)
	
	eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  targetID, from = "GUILD_APPLY" });
	
end

function guildData:onHandleClickGiveMaster()

	local property = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
							enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
							enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
							enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS + 
							enum.MEMBER_PROPERTY.MEMBER_PROPERTY_APPOINT;
											
	sendAskGuildAppoint(dataManager.playerData:getPlayerId(), property);
									
end


-- 主界面打开的时候就需要请求信息
function guildData:onAskServerGuildApplysInfo()
	
	if not self:isActive() then
		return;
	end

	if self:isHaveGuildMyself() then
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_MEMBER, 0);
		
		if self:isCanHandleApplyedPlayer() then
			sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_APPLYS, 0);
		end
	end
	
		
end

function guildData:onEnterGuildWar()
	
	dataManager.guildWarData:onHandleEnterGuildWarMap();
	
	--[[
			global.changeGameState(function() 	
				
				sceneManager.closeScene();
				eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
				eventManager.dispatchEvent({name = global_event.GUILDCREATE_HIDE});

				game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR, 
						planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });			

			end);
	--]]
					
end
