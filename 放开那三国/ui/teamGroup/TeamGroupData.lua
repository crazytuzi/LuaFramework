-- Filename：	TeamGroupData.lua
-- Author：		zhz
-- Date：		2013-2-17
-- Purpose：		组队的数据层 

module ("TeamGroupData", package.seeall)
require "script/model/user/UserModel"
require "script/ui/guild/GuildDataCache"

_copyId							= nil 		-- 进入的副本Id，
_limitType						= nil		-- 组队成员限制 1.没限制 ,2.成员必须属于同一阵营, 3.成员必须属于同一公会



-------------------------------[[  局部变量 ]]-----------------------------------
local _teamInfo					= nil		-- 所有小队得信息
local  _memberInfo				= {}		-- 
local _isLeader					= false
local _leaderId					= nil 		-- 如果是队长得话
local _ownerTeamId				= nil 		--自己所在的队伍id
local _arrUserDressInfo			= {} 		--玩家
local _isKick					= true		--判断玩家是否被踢出
local _inviteMemberInfo 		= {}		-- 邀请公会成员加入队伍
local _inviteGuildMemInfo		= {}		-- 接到队长的邀请列表
local _isNewInvited				= false		-- 判断是不是新接受
local _onlineTeamInfo			= {}		---为了邀请功能拉去得在线队伍信息
local _onlineInvitedMemInfo		= {}


function cleanData( )
	_teamInfo= nil
	_isLeader= false
	_ownerTeamId= nil
	_isKick= true
end


function getCopyInfo( )
	require "db/DB_Copy_team"
	local copyInfo = DB_Copy_team.getDataById(tonumber(_copyId))
	return copyInfo
end

-- 战斗结束，减少玩家的体力
function changeExecution( )
	local copyInfo =  getCopyInfo()
	local stamina= tonumber( copyInfo.stamina )
	UserModel.addStaminaNumber(stamina)
end

-- 获得物品的星系
function getCopyItems( )
	require "db/DB_Stronghold"
	require "db/DB_Copy_team"
	local copyInfo = DB_Copy_team.getDataById(tonumber(_copyId))
	local strongHold= tonumber(copyInfo.strongHold)
	local holdInfo= DB_Stronghold.getDataById(strongHold)
	local itemTable = lua_string_split(holdInfo.reward_item_id_simple,",")
	local items= {}
	for i=1, #itemTable do 
		local item = {}
		local tempTable = lua_string_split(itemTable[i], "|")
		item.num =1
		item.tid = tonumber(tempTable[1])
		item.type = "item"
		item.desc=  tempTable[2]
		table.insert( items , item)
	end

	return items
end
--[[
autoStart:bool表示是否自动开始
limitType:限制类型
guildName:公会名称
guildId:公会id
groupId:阵营id
members:[{
  uid:用户id
  uname:用户名
  level:等级
  utid:用户模板
}]
}]
--]]
-- 设置队伍信息
function setTeamInfo( teamInfo)
	_teamInfo = teamInfo
end

-- 获得teamInfo的信息
function getTeamInfo( )
	return _teamInfo
end


-- 刷选经过组队限制的 team信息
function getLimitTeamInfo( )
	
	-- _limitType==1 时无限制
	print("_limitType  is : ", _limitType)
	if(_limitType == 1) then
		return _teamInfo
	-- 同一个军团	
	elseif(_limitType== 3)then
		local limitTeamInfo ={}
		for i=1, table.count(_teamInfo) do
			if(GuildDataCache.getGuildId() == tonumber(_teamInfo[i].guildId)) then
				table.insert( limitTeamInfo,_teamInfo[i])
			end
		end
		return limitTeamInfo
	else 
		return {}
	end 
end


-- function getMemberInfo( )
-- 	return _memberInfo
-- end

function isLeader(  )
	return isLeader
end 

function setIsleader( isLeader )
	_isLeader= isLeader
end

function setLeaderId( leaderId)
	_leaderId= leaderId
end

function getLeaderId( ... )
	return tonumber(_leaderId) 
end

function setOwnTeadId( id)
	_ownerTeamId = id
end

function getOwnTeamId(  )
	return tonumber(_ownerTeamId)
end

function setIsKick( isKick )
	_isKick= isKick
	print("_isKick  is : ", _isKick)
end

-- 如果时队长的话， 点击创建队伍时把个人的信息 
function initTeamLeaderInfo( )
	local ownTeamList = {}
	local tempTable = {	level = UserModel.getHeroLevel(), 
						uid =UserModel.getUserUid(), 
						uname= UserModel.getUserName() ,
						dressId= UserModel.getDressIdByPos(1),
						fightForce= UserModel.getFightForceValue(), 
						utid= UserModel.getAvatarHtid()  ,
						guildName= GuildDataCache.getGuildName(),
						vip= UserModel.getVipLevel()
			}

	-- 临时性的做法，到时要改的。
	ownTeamList.members = {}--tempTable
	table.insert(ownTeamList.members,tempTable )
	ownTeamList.autoStart= false
	ownTeamList.groupId= 0
	ownTeamList.limitType= 3
	ownTeamList.guildId = GuildDataCache.getGuildId()
	ownTeamList.guildName = GuildDataCache.getGuildName()

	table.insert( _teamInfo , ownTeamList)

	-- _ownerTeamId= UserModel.getUserUid()

	print("_teamInfo  is : ")
	print_t(_teamInfo)
end

-- 自己是队长时，调整队伍的队形
-- lua 中的table 的数据是从1开始的， 此处的sourceIndex和targetIndex 是传给后端的，lua处理时要加1
function adjuestOwnTeam( sourceIndex, targetIndex)


	print(" before adjuesting teamInfo  is :")
	print_t(_teamInfo)
	for i=1, table.count(_teamInfo) do
		local uid= tonumber(_teamInfo[i].members[1].uid)
		if(tonumber(_teamInfo[i].members[1].uid)== UserModel.getUserUid()) then
			-- local teamInfo=  _teamInfo[i]
			local sourceIndex= tonumber(sourceIndex)+1
			local targetIndex= tonumber(targetIndex)+1
			local memberInfo = _teamInfo[i].members

			local tempTable= memberInfo[sourceIndex]
			memberInfo[sourceIndex]=  memberInfo[targetIndex]
			memberInfo[targetIndex]= tempTable
		end
	end

	print(" after adjuesting teamInfo  is :")
	print_t(_teamInfo)
	
end

function getMemberInfoByUid( uid )
	
	for i=1, table.count(_teamInfo) do
		for j=1, table.count( _teamInfo[i].members) do
			if( tonumber(_teamInfo[i].members[j].uid )== uid) then
				return _teamInfo[i].members[j]
			end
		end
	end

end

--通过teamId得到队员的列表 , 当玩家为队长时，玩家的Uid 极为 teamid
function getTeamListByTeamId(teamId )
	
	local teamId = tonumber(teamId)
	local teamList = {}
	local tmpInfo= {}
	for i=1, table.count(_teamInfo) do

		-- 如果 _teamInfo
		if(tonumber(_teamInfo[i].members[1].uid)== teamId) then
			table.hcopy(_teamInfo[i], tmpInfo)
			break
		end
	end

	for i=1, table.count(tmpInfo.members) do
		table.insert(teamList, tmpInfo.members[i])
		teamList[i].autoStart= tmpInfo.autoStart
		teamList[i].groupId= tmpInfo.groupId
		teamList[i].limitType= tmpInfo.limitType
		teamList[i].guildId = tmpInfo.guildId 
		teamList[i].teamGuildName = tmpInfo.guildName
	end 

	return teamList

end

-- 设置可以邀请玩家的信息
function setInviteMemberInfo( inviteInfo )
	_inviteMemberInfo= inviteInfo
end

-- 得到可以邀请玩家的信息
function getInviteMemberInfo( )
	local inviteInfo= {}
	for k,v in pairs(_inviteMemberInfo) do
		table.insert(inviteInfo, v)
	end

	return inviteInfo
end

function removeInviteByUid(uid )

	-- print("uid uid uid ", uid)
	-- print("========_inviteMemberInfo _inviteMemberInfo _inviteMemberInfo")
	-- print_t(_inviteMemberInfo)
	local uname = ""
	for i=1, table.count(_inviteMemberInfo) do
		print("i is _inviteMemberInfo[i].uid", i, _inviteMemberInfo[i].uid)
		if(tonumber(_inviteMemberInfo[i].uid) == tonumber(uid)) then
			uname = _inviteMemberInfo[i].uname
			table.remove(_inviteMemberInfo, i)
			--break
			return uname
		end
	end
	return uname
end

-- 原版：当自己为队长时，得到所有的uid数组
-- 修改：组队功能全部成员都可以邀请队员，即放开队员的邀请功能
function getTeamUidsList( )
	local uidArray = {}
	local memberArray = {}
	for i=1 , #_teamInfo do
		local memberInfo = _teamInfo[i].members 
		for j= 1, #memberInfo do 
			if(tonumber(memberInfo[j].uid) == UserModel.getUserUid()) then
				memberArray = memberInfo --_teamInfo[j].members
			end
		end
	end

	for j=1, #memberArray do
		local memberid = tonumber(memberArray[j].uid)
		table.insert( uidArray, memberid)
	end
	return uidArray
end


-- 设置接到邀请队长的列表
function setGuildInviteMem( inviteMemInfo)
	-- if( table.isEmpty(_inviteGuildMemInfo) ) then
	-- 	table.insert( _inviteGuildMemInfo,inviteMemInfo )
	-- else
	_isNewInvited= false
	local uid= inviteMemInfo[1].uid
	local copyTeamId= inviteMemInfo[2]
	local isHas= false
	for i=1,#_inviteGuildMemInfo do
		local tempMemInfo= _inviteGuildMemInfo[i]
		local tmpUid = tempMemInfo[1].uid
		local tmpCopyTeamId= tempMemInfo[2]
		if( uid== tmpUid and copyTeamId==tmpCopyTeamId ) then
			isHas= true
			break
		end
	end

	if(isHas == false) then
		table.insert(_inviteGuildMemInfo, inviteMemInfo)
	end
end

-- 得到接到邀请的信息
function getGuildInviteMem( ... )
	return _inviteGuildMemInfo
end

function setOnlineTeamInfo( teamInfo )
	_onlineTeamInfo= teamInfo
end

function setIsNewInvited( status)
	_isNewInvited = status
end

function getIsNewInvited(  )
	return _isNewInvited
end

-- 获得在线
function getOnlineGuildInviteMem( )

	-- print("_onlineTeamInfo is : ")
	-- print_t(_onlineTeamInfo)
	-- print("+++++++++  _inviteGuildMemInfo  ++++++++++++++++++ ")
	-- print_t(_inviteGuildMemInfo )

	_onlineInvitedMemInfo= {}
	print("_inviteGuildMemInfo  _inviteGuildMemInfo  ")
	print_t(_inviteGuildMemInfo)

	-- for i=1, #_onlineTeamInfo do
	-- 	local curOnlineTeamInfo= _onlineTeamInfo[i]
	-- 	local teamId= curOnlineTeamInfo.teamId
	-- 	local copyId= curOnlineTeamInfo.roomId
	-- 	for j=1, table.count(_inviteGuildMemInfo) do
	-- 		local tempMemInfo= _inviteGuildMemInfo[j]
	-- 		-- print("tempMemInfo is : ")
	-- 		-- print_t(tempMemInfo)
	-- 		local tmpUid = tempMemInfo[3]
	-- 		local tmpCopyTeamId= tempMemInfo[2]
	-- 		if(teamId ==  tmpUid and copyId== tmpCopyTeamId ) then
	-- 			-- table.remove(_inviteGuildMemInfo, j)
	-- 			table.insert( _onlineInvitedMemInfo , _inviteGuildMemInfo[j])
	-- 		end
	-- 	end
	-- end

	for j=1, table.count(_inviteGuildMemInfo) do
		local tempMemInfo= _inviteGuildMemInfo[j]
		local tmpTeamId = tempMemInfo[3]
		local tmpCopyTeamId= tempMemInfo[2]

		if( isTeamOnline(tmpTeamId,  tmpCopyTeamId) ) then
			table.insert( _onlineInvitedMemInfo , _inviteGuildMemInfo[j])
		end

	end


	_inviteGuildMemInfo={}

	-- print("_onlineInvitedMemInfo")
	-- print_t(_onlineInvitedMemInfo)
	return _onlineInvitedMemInfo
end

function isTeamOnline( tmpTeamId,  tmpCopyTeamId )
	
	local tmpTeamId= tonumber(tmpTeamId)
	local tmpCopyTeamId = tonumber(tmpCopyTeamId)

	for i=1, #_onlineTeamInfo do
		local curOnlineTeamInfo= _onlineTeamInfo[i]
		local teamId= tonumber(curOnlineTeamInfo.teamId) 
		local copyId= tonumber(curOnlineTeamInfo.roomId) 
		if(tmpTeamId== teamId and copyId == tmpCopyTeamId ) then
			return true
		end
	end
	return false


end


-- 通过index 获得收到邀请的信息
function getGuildInvMemByIndex(index )
	return _inviteGuildMemInfo[index]
end

-- 按照对应的Index来存对
function removeInviteMemByIndex( index )
	table.remove( _inviteGuildMemInfo, index)
end

-- 通过index 获得收到在线的邀请的信息
function getOnlineInviteMemByIndex( index )
	return _onlineInvitedMemInfo[index]
end

-- 按照对应的Index来存对在线邀请信息
function removeOnlineInviteMemByIndex( index )
	table.remove( _onlineInvitedMemInfo, index)
end

-- 判断是否还有接到邀请的信息
-- 有：返回true,没有，返回false
function hasInviteMem( )
	if( table.isEmpty(_inviteGuildMemInfo) or _isNewInvited == false ) then
		return false
	else
		return true
	end
end

-- 设置本次是否自动开始
function setAutoStart( autoStart, teamId )
	
	for i=1, #_teamInfo do
		local uid=  tonumber(_teamInfo[i].members[1].uid)
		if( uid == teamId) then
			_teamInfo[i].autoStart= autoStart
			break
		end
	end
end

-- team.update 时的数据处理
function setTeamUpdate( teamUpdataInfo)

	-- require "script/ui/teamGroup/TeamGroupLayer"
	local dataType = tonumber(teamUpdataInfo[2]) 

	if( _teamInfo == nil) then
		return
	end

	-- 1表示创建队伍
	if(1 == dataType ) then
		local uid = tonumber(teamUpdataInfo[1] )
		table.insert( _teamInfo, teamUpdataInfo[3])

		if( tonumber(TeamGroupLayer.getGroupType() ) ==1) then
			TeamGroupLayer.createTableView()
		end
	--	解散队伍
	--[[
		1, 当自己在队伍时，切换到 groupType == 1 的页面
		2, 当自己在groupType =1 的时候，即那个队伍也没加入时，UI刷新
	--]]
	elseif(2 == dataType ) then

		if(table.isEmpty( _teamInfo)) then
			return
		end

		 local teamId = tonumber(teamUpdataInfo[3])
		 -- print("teamId  jiesan  is : ", teamId , "  and  table.count( _teamInfo) " ,  table.count( _teamInfo))
		 -- print_t(_teamInfo[2])
		 for i=1, table.count(_teamInfo) do
		 	-- print(" i  is : ============== ", i)
		 	-- print_t(_teamInfo[i])
		 	local uid= tonumber(_teamInfo[i].members[1].uid )
		 	if(uid == teamId) then
		 		table.remove(_teamInfo, i)
		 		break
		 	end
		 end
		
		--  判断自己在不在team 中,里面的方法可能有重复的
		if(teamId == _ownerTeamId ) then
		 	_leaderId =0
		 	_ownerTeamId=0
		 	TeamGroupLayer.setGroupType(1)
		 	TeamGroupLayer.createTableView()
		 	TeamGroupLayer.rfcAftQuit()
		end

		if( tonumber(TeamGroupLayer.getGroupType() ) ==1) then
			TeamGroupLayer.createTableView()
		end


	-- 	有人加入
	elseif(3 == dataType ) then
		 --teamId
        local teamId = tonumber(teamUpdataInfo[3].teamId )
        local memberId =  tonumber(teamUpdataInfo[1])
		
		for i=1, table.count(_teamInfo) do

			local uid= tonumber(_teamInfo[i].members[1].uid ) 
			if(uid == teamId) then
				table.insert( _teamInfo[i].members, teamUpdataInfo[3])
			end
		end

		if(memberId == UserModel.getUserUid()) then
			_ownerTeamId= teamId
			TeamGroupLayer.setGroupType(3)
		end

		-- print(" _ownerTeamId is :", _ownerTeamId)
		-- print(" teamId  is : ", teamId)
		if(teamId ==  _ownerTeamId) then
			TeamGroupLayer.createTableView()
			require "script/ui/teamGroup/TeamChangeLayer"
			TeamChangeLayer.refreshTableView()
		end

	-- 	离开队伍
	-- 离开队伍分几种情况
	--[[
		groupType:1表示创建队伍界面，2表示队长开战(即玩家为队长)，3表示加入队伍（玩家为队员
		1, 玩家在 groupType ==1 的时候， 其他人离开队伍 , 不修改UI
		2, 玩家在 groupType ==2 的时候， 即自己是队长时，a,别的小组成员离开队伍,ui 不变，b,自己小组成员改变时UI变化
		3, 玩家在 groupType ==3 的时候，即自己是 队员时, a,自己离开队伍时，ui切换到第一个页面，b,自己小队别的成员离开,UI变化。c,别的小队离开，UI不变
	--]]
	elseif(4== dataType) then

		local teamId= tonumber(teamUpdataInfo[3]) 
		local teamMemberId= tonumber(teamUpdataInfo[1])

		if(table.isEmpty( _teamInfo)) then
			return
		end

		for i=1, table.count(_teamInfo) do
			local uid= tonumber(_teamInfo[i].members[1].uid ) 
			if(uid == teamId) then
				local teamList = _teamInfo[i]
				local memberArray = teamList.members
				for j=1, table.count(memberArray) do
					local memberid = tonumber(memberArray[j].uid)
					-- print("(memberArray[i].uid  is : ", memberArray[j].uid)
					if(memberid == teamMemberId) then
						table.remove(memberArray, j)
						break
					end
				end
			end

		end

		-- 自己是队长时，有人离开队伍
		if(TeamGroupLayer.getGroupType()== 2 and teamId== _ownerTeamId ) then
			TeamGroupLayer.createTableView()
			require "script/ui/teamGroup/TeamChangeLayer"
			TeamChangeLayer.refreshTableView()
		end

		print("UserModel.getUserUid() is : ", UserModel.getUserUid() )
		-- 自己时队员时, 自己离开了, ui切换到第一个页面
		if(  TeamGroupLayer.getGroupType() == 3 and teamMemberId == UserModel.getUserUid()) then
			_ownerTeamId=0
			TeamGroupLayer.setGroupType(1)
			
			TeamGroupLayer.refreshItem()
			TeamGroupLayer.createTableView()
			
			if( _isKick== true ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_3075"))
			end
			_isKick= true
		-- 自己时队员时, 自己队伍中有人离开
		elseif( TeamGroupLayer.getGroupType()==3 and teamId == _ownerTeamId and teamMemberId ~= UserModel.getUserUid()) then
			TeamGroupLayer.createTableView()
		end

		-- if( not table.isEmpty(_teamInfo)) then
		-- 	TeamGroupLayer.setGroupType(2)
		-- 	TeamGroupLayer.createTableView()
		-- end
		

	--5表示调整顺序,
	-- 玩家在 groupType ==1 的时候，其他队伍队形调整，UI不变，数据变化
	-- 玩家在 groupType ==2 or 3 的时候，a, 其他队伍队形调整，UI不变，数据变化, b, 自己队伍队形调整，UI变化，数据变化

	elseif (5== dataType) then
		print_t(teamUpdataInfo)
		print_t(_teamInfo)
		-- uid 位发起者的uid , 当和对应的teamid 相等时，修改_teamInfo 中的信息

		local actUid = tonumber(teamUpdataInfo[1])
		for i=1, table.count(_teamInfo) do
			local uid= tonumber(_teamInfo[i].members[1].uid)
			if(actUid == uid) then
				-- local teamInfo=  _teamInfo[i]
				local sourceIndex= tonumber(teamUpdataInfo[3].sourceIndex)+1
				local targetIndex= tonumber(teamUpdataInfo[3].targetIndex)+1
				local memberInfo = _teamInfo[i].members

				local tempTable= memberInfo[sourceIndex]
				memberInfo[sourceIndex]=  memberInfo[targetIndex]
				memberInfo[targetIndex]= tempTable

			end
		end

		print("after adjuesting teamInfo ")
		print_t(_teamInfo)

		if(groupType ~= 1 and actUid == _ownerTeamId) then
			TeamGroupLayer.createTableView()
		end

	end

end






