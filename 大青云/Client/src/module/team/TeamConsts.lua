--[[
队伍：相关常量
郝户
2014年9月26日10:31:09
]]

_G.TeamConsts = {}


------------队伍面板标签页名称---------------
--我的队伍
TeamConsts.TabTeamMine = "TabTeamMine";
--附近队伍
TeamConsts.TabTeamNearby = "TabTeamNearby";
--附近玩家
TeamConsts.TabPlayerNearby = "TabPlayerNearby";


---------------队员人数上限------------------
TeamConsts.MemberCeiling = 4;


------------职位------------------------------
--职位：队长
TeamConsts.PosCaptain = 1;
--职位：队员
TeamConsts.PosMember = 0;


----------------玩家在线状态------------------
--在线
TeamConsts.Online = 1;
--离线
TeamConsts.Offline = 0;


----------入队反馈结果-----------------------
--同意
TeamConsts.Agree = 1;
--拒绝
TeamConsts.Refuse = 0;


----------时间----------------
--刷新列表冷却时间(秒)
TeamConsts.RefreshCD = 30;
--申请邀请入队不处理，自动拒绝时间(毫秒)
TeamConsts.AutoRefuseTime = 30000;


-------------玩家组队状态-------------------
--已组队
TeamConsts.InTeam = 1;
--未组队
TeamConsts.OutTeam = 0;


------------组队加持类型-------------------
--金钱加持
TeamConsts.BonusType_Money = 1;
--经验加持
TeamConsts.BonusType_Exp = 2;


------------组队加持对应表---------------
--[人数] = bonusStr加持百分比
TeamConsts.BonusMap = {
	[1] = "0%",
	[2] = "2%",
	[3] = "5%",
	[4] = "8%"
}


--对主界面队友头像的菜单操作
TeamConsts.ROper_ShowInfo    = 1;--查看资料
TeamConsts.ROper_Deal        = 2;--邀请交易
TeamConsts.ROper_AddFriend   = 3;--加为好友
TeamConsts.ROper_AddBlack    = 4;--加入黑名单
TeamConsts.ROper_GuildInvite = 5;--邀请入帮
TeamConsts.ROper_CopyName    = 6;--复制名字
TeamConsts.ROper_Chat        = 7;--私聊
TeamConsts.ROper_Apoint      = 8;--转让队长
TeamConsts.ROper_Kick        = 9;--请离队伍
TeamConsts.ROper_Quit        = 10;--退出队伍

--所有操作
TeamConsts.AllROper = {
	TeamConsts.ROper_ShowInfo,
	TeamConsts.ROper_Deal,
	TeamConsts.ROper_AddFriend,
	TeamConsts.ROper_AddBlack,
	TeamConsts.ROper_GuildInvite,
	TeamConsts.ROper_CopyName,
	TeamConsts.ROper_Chat,
	TeamConsts.ROper_Apoint,
	TeamConsts.ROper_Kick,
	TeamConsts.ROper_Quit,
}

--获取操作名
function TeamConsts:GetOperName(oper)
	if oper == TeamConsts.ROper_Chat then
		return StrConfig['chat400'];
	elseif oper == TeamConsts.ROper_ShowInfo then
		return StrConfig['chat401'];
	elseif oper == TeamConsts.ROper_AddFriend then
		return StrConfig['chat402'];
	elseif oper == TeamConsts.ROper_AddBlack then
		return StrConfig['chat403'];
	elseif oper == TeamConsts.ROper_GuildInvite then
		return StrConfig['chat404'];
	elseif oper == TeamConsts.ROper_CopyName then
		return StrConfig['chat409'];
	elseif oper == TeamConsts.ROper_Deal then
		return StrConfig['team106'];
	elseif oper == TeamConsts.ROper_Apoint then
		return StrConfig['team107'];
	elseif oper == TeamConsts.ROper_Kick then
		return StrConfig['team108'];
	elseif oper == TeamConsts.ROper_Quit then
		return StrConfig['team109'];
	end
end

-- 队伍成员属性类型
TeamConsts.AttrTypeId            = "roleID" -- 角色ID
TeamConsts.AttrTypeName          = "roleName"  -- 角色名字
TeamConsts.AttrTypeLine          = "line" -- 线
TeamConsts.AttrTypeMapId         = "mapId" -- 地图
TeamConsts.AttrTypeProf          = "prof" -- 职业
TeamConsts.AttrTypeLevel         = "level" -- 等级
TeamConsts.AttrTypeHp            = "hp" -- hp
TeamConsts.AttrTypeMaxHp         = "maxHp" -- maxHP
TeamConsts.AttrTypeMp            = "mp" -- mp
TeamConsts.AttrTypeMaxMp         = "maxMp" -- maxMp
TeamConsts.AttrTypeFight         = "fight" -- 战斗力
TeamConsts.AttrTypeTeamPos       = "teamPos" -- 职位,0成员,1队长
TeamConsts.AttrTypeOnline        = "online" -- 在线状态
TeamConsts.AttrTypeIconID        = "iconID" -- 玩家头像
TeamConsts.AttrTypeArms          = "arms" -- 武器
TeamConsts.AttrTypeDress         = "dress" -- 衣服
TeamConsts.AttrTypeFashionshead  = "fashionshead" -- 时装头
TeamConsts.AttrTypeFashionsarms  = "fashionsarms" -- 时装武器
TeamConsts.AttrTypeFashionsdress = "fashionsdress" -- 时装衣服
TeamConsts.AttrTypeVipLevel      = "vipLevel" -- vip等级
TeamConsts.AttrTypeRoomType      = "roomType" -- 房间准备状态 0:已准备
TeamConsts.AttrTypeTeamId        = "teamId" -- 房间准备状态 0:已准备
TeamConsts.AttrTypeIndex         = "index" -- 房间准备状态 0:已准备

------------队员3d形象相关属性----------
TeamConsts.AppearanceAttrs = {
	[ TeamConsts.AttrTypeArms ]          = true,
	[ TeamConsts.AttrTypeDress ]         = true,
	[ TeamConsts.AttrTypeFashionshead ]  = true,
	[ TeamConsts.AttrTypeFashionsarms ]  = true,
	[ TeamConsts.AttrTypeFashionsdress ] = true,
	[ TeamConsts.AttrTypeOnline ]        = true,
}

------------主界面队伍列表相关属性----------
TeamConsts.MainPageTeamAttrs = {
	[ TeamConsts.AttrTypeIndex ]   = true,
	[ TeamConsts.AttrTypeName ]    = true,
	[ TeamConsts.AttrTypeLevel ]   = true,
	[ TeamConsts.AttrTypeHp ]      = true,
	[ TeamConsts.AttrTypeMaxHp ]   = true,
	[ TeamConsts.AttrTypeTeamPos ] = true,
	[ TeamConsts.AttrTypeOnline ]  = true,
}

------------灵光封魔相关属性-------------
TeamConsts.TimeDungeonAttrs = {
	[ TeamConsts.AttrTypeName ]				= true,
	[ TeamConsts.AttrTypeLevel ]			= true,
	[ TeamConsts.AttrTypeFight ]			= true,
	[ TeamConsts.AttrTypeRoomType ]			= true,
	[ TeamConsts.AttrTypeLine ]				= true,
	[ TeamConsts.AttrTypeTeamPos ] 			= true,
}

------------爬塔副本相关属性-------------
TeamConsts.PataDungeonAttrs = {
	[ TeamConsts.AttrTypeName ]				= true,
	[ TeamConsts.AttrTypeLevel ]			= true,
	[ TeamConsts.AttrTypeFight ]			= true,
	[ TeamConsts.AttrTypeRoomType ]			= true,
	[ TeamConsts.AttrTypeLine ]				= true,
	[ TeamConsts.AttrTypeTeamPos ] 			= true,
}