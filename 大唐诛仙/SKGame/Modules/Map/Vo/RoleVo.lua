
RoleVo =BaseClass(PuppetVo)

function RoleVo:__init()
	self.type = PuppetVo.Type.PLAYER
	self.player_add_prop_ = {}  --玩家附加属性
	self.sex = 2 -- 性别
	self.career = 2 -- 职业id
	self.guidId = 0 -- 帮会id
	self.severNo = 0 -- 服务器编号
	self.playerId = 0 -- 玩家id eid
	self.actorLevelMax = 0 -- 等级上限
	self.mapId = 0 -- 所处场景id
	self.isCompleted = true
	self.cengShu = 1 --玩家当前大荒塔层数
	
	self.pkModel = 0 --PK模式 1:和平 2:善恶 3:组队 4:氏族 5:全体 
	self.pkValue = 0 --PK值
	self.nameColor = 0 --名字颜色  1：白色 2：灰色 3：红色
	self.fbTransPos = false

	self.stage = 0 -- 段位
	self.weekTaskNum = 0 --当前环任务数

	self.weaponStyle = 0 -- 武器外形
	self.weaponEquipmentId = 0 --武器外形(装备基础ID)
	self.guildId = 0 -- 帮会id
	self.guildName = "" -- 帮会名
	self.teamId = 0 -- 队伍id
	self.familyName = "" -- 家族名称
	self.familySortId = 0 -- 家族排序
	self.vipLevel = 0 -- VIP等级

	self.exp = 0 -- 经验
	self.gold = 0 -- 金币
	self.diamond = 0 -- 钻石
	self.bindDiamond = 0 -- 代金券
	self.contribution = 0 -- 贡献
	self.honor = 0 -- 荣誉
	self.stone = 0 -- 宝玉
	self.bagGrid = 0 -- 背包的最大格子数量
	self.relifeType = -1 --复活类型(1.免费 2.道具复活 3.钻石复活)
	self.die = false

	self.dressStyle = 0 -- 外形
	self.wingStyle = 0 -- 翅膀
	self.battleValue = 0 -- 战力
	self.buffVoList = {}
end

-- 是否存在队伍
function RoleVo:HasTeam()
	return self.teamId ~= 0
end
-- 是否存在帮会
function RoleVo:HasGuild()
	return self.guildId ~= 0
end


-- 初始
function RoleVo:InitVo( attrs, isMainRole)
	self.isMainRole = isMainRole -- 是否为主角
	for k, v in pairs(attrs) do
		if type(v) ~= "function" and k ~= "_class_type"  then
			if k == "moveSpeed" and v~=0 then
				v = v*0.01
			end
			if k == "hp" then --伤害加深
				self.die = v <= 0
			elseif k == "dmgDeepPer" or k == "dmgCritPer" or k == "dmgReductPer" then
   				v = string.format("%.1f", v*0.01)
			end
			self[k] = v
		end
	end
	self.buffVoList = attrs.buffVoList
	self:UsedDispatchChange(true)

	local data = TiantiModel:GetInstance():GetTTPlayerData() or {}--TiantiModel:GetInstance():GetPkPlayerGuid()
	local playerGuid = data.guid
	if self.guid and playerGuid and self.guid == playerGuid and SceneModel:GetInstance():IsTianti() then
		GlobalDispatcher:DispatchEvent(EventName.TiantiRoleEnter, attrs)
	end
end

-- 更新数据
function RoleVo:UpateVo( info )
	for k, v in pairs(info) do
		if type(v) ~= "function" and k ~= "_class_type" then
			if self[k] then
				if k == "pkModel" then
				else
					self:SetValue( k, v, self[k] )
				end
			end
		end
	end
end
-- 设置数值
function RoleVo:SetValue( k, v, old, dataTab )
	if not self.isCompleted then return end
	if self[k] ~= v then
		if k == "hp" then
			self:SetValue( "die", v <= 0, old, dataTab )
		elseif k == "moveSpeed" then
			if v~=0 then
	  			v = v*0.01
   			end
   		elseif k == "dmgDeepPer" or k == "dmgCritPer" or k == "dmgReductPer" then
   			local integer , decimals = math.modf(v)
   			if decimals == 0 then
   				v = string.format("%.1f", v*0.01)
   			end
   		end
   		if k ~= "relifeType" then
			self[k] = v
   		end
		
		if self.isMainRole then
			if k == "level" then
				if isSDKPlat then
					LoginController:GetInstance():UploadRoleInfo(2)
				end
			end
			LoginModel:GetInstance():UpdateLoginData(k, v)
		end
		self:OnChange(k, v, old, dataTab)
	end
end
-- 不发布属性变化事件
function RoleVo:UsedDispatchChange( bool )
	self.isUsedispatchchange = bool
end
function RoleVo:OnChange( key, value, pre, dataTab )
	if self.isUsedispatchchange then
		self:DispatchEvent(SceneConst.OBJ_UPDATE, key, value, pre, dataTab)
		if self.isMainRole then --如果是自己，就广播自己的属性变化
			GlobalDispatcher:DispatchEvent(EventName.MAINPLAYER_UPDATE, key, value, pre)
		end
		local data = TiantiModel:GetInstance():GetTTPlayerData() or {}--TiantiModel:GetInstance():GetPkPlayerGuid()
		local playerGuid = data.guid
		if self.guid and playerGuid and self.guid == playerGuid then
			GlobalDispatcher:DispatchEvent(EventName.TiantiRoleAttrUpdate, key, value, pre)
		end
	end
end
-- 当前等级升级所需经验
function RoleVo:GetLevelExp()
	local cfg = self:GetPropertyVo( self.career, self.level )
	if cfg then
		return cfg.needexp
	end
	return 0
end
-- 获取等级所需总经验
function RoleVo:GetLevelTotalExp(lv)
	local totalExp = 0
	if lv > 0 then
		for i=1,lv do
			local cfg = self:GetPropertyVo( self.career, i )
			if cfg then
				totalExp = totalExp + cfg.needexp
			end
		end
	end
	return totalExp  
end
-- 获得属性数据单元
function RoleVo:GetPropertyVo( career, level )
	local cfg = GetCfgData( "property" )
	return cfg[career*1000 + level]
end
--获取属性定义
function RoleVo.GetPropDefine(id)
	local cfg = GetCfgData("proDefine")
	return cfg[id]
end
function RoleVo:__delete()
	self.die=true
	self.isCompleted = false
	self.isUsedispatchchange = nil
end
-- 获取资产数据
function RoleVo:GetAssets(type)
	if type == 3 then
		return self.gold or 0
	elseif type == 4 then
		return self.diamond or 0
	elseif type == 5 then
		return self.bindDiamond or 0
	elseif type == 6 then
		return self.contribution or 0
	elseif type == 7 then
		return self.honor or 0
	elseif type == 9 then
		return self.stone or 0
	else
		return 0
	end
end

--设置 pkModel
function RoleVo:SetPkModel(pkModel)
	if pkModel then
		if self.pkModel then
			self.pkModel = pkModel
		end 
	end
end