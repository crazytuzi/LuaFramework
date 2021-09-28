-- 队伍单元
ZDVo = BaseClass()
function ZDVo:__init( data )
	self.teamId = 0 -- 队伍唯一编号
	self.playerId = 0 -- 队长编号
	self.playerName = "" -- 队长名称
	self.level = 0 -- 队长等级
	self.career = 0 -- 队长职业	
	self.playerNum = 0 -- 队伍当前人数
	self.activityId = 0 -- 活动编号	
	self.minLevel = 0 -- 最低等级
	self.createTime = 0 -- 队伍创建时间
	self:Update(data)
end
function ZDVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			if k =="createTime" then
				self[k] = toLong(data[k])
			else
				self[k] = data[k]
			end
		end
	end
end

-- 队员信息
ZDMemberVo = BaseClass(InnerEvent)
function ZDMemberVo:__init( data )
	self.playerId = 0 -- 角色编号
	self.playerName = "" -- 角色名称
	self.teamIndex = 0 -- 位置下标 从1开始
	self.captain = false -- 是否队长
	self.level = 0 -- 角色等级
	self.online = 0 -- 角色在线状态
	self.career = 0 -- 职业
	self.mapId = 0 -- 所在地图
	self.battleValue = 0 -- 战力
	self.dressStyle = 0 -- 外形
	self.weaponStyle = 0 -- 武器外形(装备基础ID)
	self.hp = 0 -- 当前血量
	self.maxHp = 0 -- 最大血量
	self:Update(data)
end
function ZDMemberVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			self[k] = data[k]
		end
	end
end

-- 邀请单元
InviteVo = BaseClass()
function InviteVo:__init( data )
	self.playerId = 0 -- 角色编号
	self.playerName = "" -- 角色名称
	self.level = 0 -- 角色等级
	self.career = 0 -- 职业	
	self.guildName = "" -- 公会名称
	self:Update(data)
end
function InviteVo:Update( data )
	if not data then return end
	for k,v in pairs(self) do
		if data[k] and self[k] ~= data[k] then
			self[k] = data[k]
		end
	end
end