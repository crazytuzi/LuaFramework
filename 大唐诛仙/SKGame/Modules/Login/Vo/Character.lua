Character =BaseClass()

--角色信息
function Character:__init( data )
	self.playerId = 0 -- 实例id
	self.eid = 0 --> playerId
	self.playerName = ""
	self.name = ""
	self.career = 0
	self.level = 0
	self.weaponEquipmentId = 0
	self.weaponStyle = 0 -- 武器样式
	self.dressStyle = 0 -- 服装样式
	self.severNo = 0 -- 服务器编号
	self.guid = "" -- 玩家唯一编号2(包括全局场景信息的)
	self.exp = 0
	self.gold = 0
	self.diamond = 0
	self.stone = 0
	self.bagGrid = 0 -- 背包最大格子数
	self.playerPropertyMsg = {} -- 玩家属性消息
	self.mapId = 0
	self.serverTime = 0
	self.loginTime = 0
	self.createTime = 0

	self:SetData(data)
end
-- 获取资产数据
function Character:GetAssets(t)
	if t == 3 then
		return self.gold or 0
	elseif t == 4 then
		return self.diamond or 0
	elseif t == 5 then
		return self.bindDiamond or 0
	elseif t == 6 then
		return self.contribution or 0
	elseif t == 7 then
		return self.honor or 0
	elseif t == 9 then
		return self.stone or 0
	else
		return 0
	end
end

function Character:SetData( data )
	if not data then return end
	self.playerId = data.playerId or self.playerId
	self.eid = self.playerId
	self.playerName = data.playerName or self.playerName
	self.name = self.playerName
	self.career = data.career or self.career
	self.level = data.level or self.level
	self.loginTime = toLong(data.loginTime or self.loginTime)
	self.createTime = toLong(data.createTime or self.createTime)

	if data.weaponStyle then
		self.weaponStyle = data.weaponStyle
	else
		local roleDefaultVal = GetCfgData("newroleDefaultvalue"):Get(self.career)
		if roleDefaultVal then
			local cfg = GetCfgData("equipment"):Get(roleDefaultVal.weaponStyle)
			if cfg then
				self.weaponStyle = cfg.weaponStyle
			end	
		end
	end

	self.weaponEquipmentId = data.weaponEquipmentId

	if data.dressStyle == nil or data.dressStyle == 0 then
		local roleDefaultVal = GetCfgData("newroleDefaultvalue"):Get(self.career)
		if roleDefaultVal then
			self.dressStyle = roleDefaultVal.dressStyle
		end
	else
		self.dressStyle = data.dressStyle
	end

	self.wingStyle = data.wingStyle
	self.severNo = data.severNo or self.severNo
	self.guid = data.guid or self.guid
	self.id = self.guid
	self.exp = data.exp or self.exp
	self.gold = data.gold or self.gold
	self.diamond = data.diamond or self.diamond
	self.stone = data.stone or self.stone
	self.playerPropertyMsg = data.playerPropertyMsg or {} -- 玩家属性消息
	if self.playerPropertyMsg then
		for i=1,#self.playerPropertyMsg do
			local propId = self.playerPropertyMsg[i].propertyId
			local propValue = self.playerPropertyMsg[i].propertyValue
			local propNameStr = nil
			if RoleVo.GetPropDefine(propId) then
				propNameStr = RoleVo.GetPropDefine(propId).type
			else
				logError(propId.." 属性id不存在！")
			end
			if propNameStr ~= "" and propNameStr ~= nil then
				self[propNameStr] = propValue
			end
		end
	end
end

function Character:SetKV( k, v )
	if self[k] then
		self[k] = v
	end
end

function Character:SetPlayerCommonMsg( msg )
	if not msg then return end
	self:SetData(msg)
	
end

function Character:SetMapId( mapId )
	self.mapId = mapId or 0
end

function Character:SetServerTime( serverTime )
	self.serverTime = toLong(serverTime or self.serverTime)
end

function Character:SetLoginTime(serverTime)
	self.serverTime = toLong(serverTime or self.serverTime)
end

function Character:ToString()
	local info = ""
	info = info..">> playerId(eid):" .. self.playerId
	info = info..">> playerName:" .. self.playerName
	info = info..">> career:" .. self.career
	info = info..">> level:" .. self.level
	info = info..">> weaponStyle:" .. self.weaponStyle
	info = info..">> dressStyle:" .. self.dressStyle
	info = info..">> severNo:" .. self.severNo
	info = info..">> guid:" .. self.guid
	info = info..">> exp:" .. self.exp
	info = info..">> gold:" .. self.gold
	info = info..">> diamond:" .. self.diamond
	info = info..">> mapId:" .. self.mapId
	info = info..">> serverTime:" .. self.serverTime

	return info
end

function Character.GetDefaultCfg(career)
	return GetCfgData("newroleDefaultvalue"):Get(career)
end