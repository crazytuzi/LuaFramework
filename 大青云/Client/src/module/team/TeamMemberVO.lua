--[[
队伍成员VO
郝户
2014年9月25日10:11:28
]]

_G.TeamMemberVO = {}

TeamMemberVO.roleID        = 0; -- 角色ID
TeamMemberVO.roleName      = ""; -- 角色名字
TeamMemberVO.line          = 0; -- 线
TeamMemberVO.mapId         = 0; -- 地图
TeamMemberVO.prof          = 0; -- 职业
TeamMemberVO.level         = 0; -- 等级
TeamMemberVO.hp            = 0; -- hp
TeamMemberVO.maxHp         = 0; -- maxHP
TeamMemberVO.mp            = 0; -- mp
TeamMemberVO.maxMp         = 0; -- maxMp
TeamMemberVO.fight         = 0; -- 战斗力-----不需要显示队员的战斗力,去掉-2014年10月10日22:02:05.又加上了-2014年10月17日11:59:33
TeamMemberVO.guildName     = ""; -- 帮会名
TeamMemberVO.teamPos       = 0; -- 职位,0成员,1队长
TeamMemberVO.online        = 0; -- 在线状态
TeamMemberVO.iconID        = 0; -- 玩家头像
TeamMemberVO.arms          = 0; -- 武器
TeamMemberVO.dress         = 0; -- 衣服
TeamMemberVO.shoulder	   = 0;	-- 肩甲
TeamMemberVO.fashionshead  = 0; -- 时装头
TeamMemberVO.fashionsarms  = 0; -- 时装武器
TeamMemberVO.fashionsdress = 0; -- 时装衣服
TeamMemberVO.vipLevel      = 0; -- vip等级
TeamMemberVO.roomType      = 1; -- 房间准备状态 0:已准备

--所在队伍id
TeamMemberVO.teamId = nil;
--在队伍中的索引
TeamMemberVO.index = nil;

function TeamMemberVO:new()
	local obj = {};
	for k,v in pairs(TeamMemberVO) do
		obj[k] = v;
	end
	return obj;
end

function TeamMemberVO:IsCaptain()
	return self.teamPos == TeamConsts.PosCaptain
end

function TeamMemberVO:IsMainPlayer()
	return self.roleID == MainPlayerController:GetRoleID()
end

function TeamMemberVO:GetNameColor()
	if self.online == TeamConsts.Offline then
		return 0x6e6e6e
	elseif self:IsMainPlayer() then
		return 0xe1a200
	else
		return 0xffffff
	end
end

function TeamMemberVO:Precede( memberVO )
	if self:IsCaptain() then
		return true
	end
	if memberVO:IsCaptain() then
		return false
	end
	if self:IsMainPlayer() then
		return true
	end
	if memberVO:IsMainPlayer() then
		return false
	end
	return self.level > memberVO.level
end