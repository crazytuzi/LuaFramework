--MemberInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  MemberInfo.lua
 --* Author:  Wang Lin
 --* Modified: 2014年4月3日 15:49:14
 --* Purpose: Implementation of the class MemberInfo
 -------------------------------------------------------------------*/

MemberInfo = class()

local prop = Property(MemberInfo)
prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("autoInvited", false) --自动允许组队
prop:accessor("teamID", 0)
prop:accessor("activeState", false) --如果为true表示玩家下线了
prop:accessor("name")
prop:accessor("level")
prop:accessor("sex")				--添加性别 20150319
prop:accessor("school")
prop:accessor("wingID", 0)
prop:accessor("weapon", 0)
prop:accessor("upperBody", 0)
prop:accessor("posMapID", 0)		--当需要同步队友位置时自己当前所在的地图ID
prop:accessor("prevPosNum", 0)		--保存的上一次记录的在同一场景的队员数量
prop:accessor("autoApply", false) 	--如果为true表示 如果玩家是队长将自动同意别人入队

function MemberInfo:__init()
	prop(self, "posMapID", 0)
	self._applyInfo = {} 			--记录自己申请加入别的队伍的记录
	self._inviteInfo = {} 			--记录自己被邀请的记录
	self._switchOut = false 		--是否切地图
end

function MemberInfo:getApplyInfo()
	return self._applyInfo
end

function MemberInfo:addApply(teamID)
	table.insert(self._applyInfo, teamID)
end

function MemberInfo:isApply(teamID)
	return table.contains(self._applyInfo, teamID)
end

function MemberInfo:removeApplyID(teamID)
	table.removeValue(self._applyInfo, teamID)
end

function MemberInfo:getInviteInfo()
	return self._inviteInfo
end

function MemberInfo:addInvite(roleSID)
	local invite = {}
	invite.roleSID = roleSID
	invite.time = os.time()

	table.insert(self._inviteInfo, invite)
end

function MemberInfo:isInvited(roleSID)
	for i, v in pairs(self._inviteInfo) do
		if v.roleSID == roleSID then
			return true
		end
	end
	return false
end

function MemberInfo:updateInviteTime(roleSID)
	for i, v in pairs(self._inviteInfo) do
		if v.roleSID == roleSID then
			v.time = os.time()
			break
		end
	end
end

function MemberInfo:getInviteCnt()
	return  table.size(self._inviteInfo)
end

function MemberInfo:updateInvite()
	for i, v in pairs(self._inviteInfo) do
		if os.time() - v.time > TEAM_MAX_INVITE_SAVE_TIME then
			table.remove(self._inviteInfo, i)
		end
	end
end

function MemberInfo:removeInviteID(roleSID)
	for i, v in pairs(self._inviteInfo) do
		if v.roleSID == roleSID then
			table.remove(self._inviteInfo, i)
		end
	end
end

--清除数据,当玩家加入某一队伍时使用
function MemberInfo:clear()
	self._applyInfo = {}
	self._inviteInfo = {}
end
