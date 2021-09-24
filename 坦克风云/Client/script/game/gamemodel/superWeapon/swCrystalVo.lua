--超级武器能量结晶数据
swCrystalVo={}
function swCrystalVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function swCrystalVo:initWithData(id,num)
	self.id=id
	self.num=num
	return self
end

function swCrystalVo:getCfg()
	if self.id=="c200" then
		return superWeaponCfg.addcrystalRate.c200
	elseif self.id=="c201" then
		-- 保级齿轮
		return superWeaponCfg.stillLevel.c201
	elseif superWeaponCfg and superWeaponCfg.crystalCfg and superWeaponCfg.crystalCfg[tostring(self.id)] then
		return superWeaponCfg.crystalCfg[tostring(self.id)]
	end
	return nil
end

function swCrystalVo:getSortId()
	return RemoveFirstChar(self.id)
end


-- 获取当前等级下一级的id
function swCrystalVo:getNextLevelId()
	-- local nextid = tonumber(RemoveFirstChar(self.id))+1
	local currentId = tonumber(RemoveFirstChar(self.id))
	local nextid = 0
	-- 判断当前ID是否是 <=1000 且
	if currentId < 1000 and currentId%10 == 0 then
		-- 正好10级的
		nextid = currentId/10*1000 + 1
	else
		nextid = currentId + 1
	end
	return "c"..nextid
end

-- 获取当前等级前一级的id
function swCrystalVo:getPreviousLevelId(isUseProtect)
	local previousid
	if isUseProtect == 1 then
		 previousid = tonumber(RemoveFirstChar(self.id))
	else
		--  previousid = tonumber(RemoveFirstChar(self.id))-1
		-- if previousid<=0 then
		-- 	previousid=1
		-- end
		local currentId = tonumber(RemoveFirstChar(self.id))
		if currentId > 1000 and currentId%1000 == 1 then
			-- 11级的前一级是10的倍数
			previousid = math.floor(currentId/1000) * 10
		else
			previousid = currentId - 1
		end

		if previousid <= 0 then
			previousid = 1
		end
	end
	return "c"..previousid
end

-- 获取本地描述
function swCrystalVo:getLocalName()
	if self:getCfg() then
		return getlocal(self:getCfg().name)
	end
	return ""
end

function swCrystalVo:getIcon()
	if self:getCfg() then
		return self:getCfg().icon
	end
	return ""
end

-- 获取iconSp
function swCrystalVo:getIconSp(callback)
	local bgName = ""
	if self:getColorType()==1 then
		bgName="crystalIconRedBg.png"
	elseif self:getColorType()==2 then
		bgName="crystalIconYellowBg.png"
	elseif self:getColorType()==3 then
		bgName="crystalIconBlueBg.png"
	elseif self.id == "c201" then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
		bgName="orangeBg.png"
	else
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
		bgName="purpleBg.png"
	end
	local iconName = self:getIcon()
	local bgSp
	if(callback)then
		bgSp=LuaCCSprite:createWithSpriteFrameName(bgName,callback)
	else
		bgSp=CCSprite:createWithSpriteFrameName(bgName)
	end
	local iconSp = CCSprite:createWithSpriteFrameName(iconName)
	-- iconSp:setAnchorPoint(ccp(0,0))
	iconSp:setPosition(getCenterPoint(bgSp))
	bgSp:addChild(iconSp)
	return bgSp
end

-- 获取结晶的颜色，红,黄，蓝对应1，2，3
function swCrystalVo:getColorType()
	if self:getCfg() then
		return self:getCfg().type
	end
	return nil
end

-- 获取结晶的等级
function swCrystalVo:getLevel()
	if self:getCfg() then
		return self:getCfg().lvl
	end
	return 0
end
function swCrystalVo:getLevelStr()
	if self:getCfg() then
		return getlocal("fightLevel",{self:getCfg().lvl})
	end
	return ""
end

function swCrystalVo:getNumStr( ... )
	return "X"..self.num
end

function swCrystalVo:getNameAndLevel()
	return self:getLocalName()..getlocal("fightLevel",{self:getLevel()})
end

-- 获取结晶的类型，
function swCrystalVo:getForm()
	if self:getCfg() then
		return self:getCfg().form
	end
	return nil
end

-- 获取结晶的属性加成
function swCrystalVo:getAtt()
	if self:getCfg() then
		return self:getCfg().att
	end
	return nil
end







