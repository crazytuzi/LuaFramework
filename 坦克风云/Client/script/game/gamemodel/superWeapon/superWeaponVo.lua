--超级武器的武器数据
superWeaponVo={}
function superWeaponVo:new(id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.id=id 					--武器的id, 就是配置文件里面的id
	return nc
end

function superWeaponVo:initWithData(param)
	self.lv=tonumber(param[1]) or 1		--武器的阶位等级
	self.exp=tonumber(param[2]) or 0 	--武器的阶位经验, 经验满了进行升级
	self.upgradeList=param[3]	 		--武器的属性强化列表
	if(self.upgradeList==nil or type(self.upgradeList)~="table")then
		self.upgradeList={}
	end
	self.slots=param[4]--武器镶嵌的结晶
	if(self.slots==nil or type(self.slots)~="table")then
		self.slots={}
	end
end

--获取武器提供的属性加成, 是一个table
function superWeaponVo:getAtt()
	local default=self:getAttDefault()
	local result={}
	for k,v in pairs(default) do
		local attKey=self:getConfigData("att")[k]
		local lvAdd=superWeaponCfg.weaponCfg[self.id]["lvGrow"][attKey]*self.lv
		local upgradeAdd
		if(self.upgradeList[k])then
			upgradeAdd=superWeaponCfg.weaponCfg[self.id]["upgradeGrow"][attKey]*tonumber(self.upgradeList[k])
		else
			upgradeAdd=0
		end
		result[attKey]=v + lvAdd + upgradeAdd
	end
	--结晶加成
	if self.slots then
		for k,v in pairs(self.slots) do
			local crystalCfg=superWeaponCfg.crystalCfg[v]
			if crystalCfg and crystalCfg["att"] then
				for attKey,addValue in pairs(crystalCfg["att"]) do
					if(result[attKey])then
						result[attKey]=result[attKey] + addValue
					else
						result[attKey]=addValue
					end
				end
			end
		end
	end
	return result
end

--获取武器的强化属性
function superWeaponVo:getUpgradeAtt()
	local default=self:getAttDefault()
	local result={}
	for k,v in pairs(default) do
		local attKey=self:getConfigData("att")[k]
		local upgradeAdd
		if(self.upgradeList[k])then
			upgradeAdd=superWeaponCfg.weaponCfg[self.id]["upgradeGrow"][attKey]*tonumber(self.upgradeList[k])
		else
			upgradeAdd=0
		end
		result[k]=upgradeAdd
	end
	return result
end

--获取武器的强化属性上限
function superWeaponVo:getUpgradeLimit()
	local default=self:getAttDefault()
	local result={}
	for k,v in pairs(default) do
		local attKey=self:getConfigData("att")[k]
		local upgradeAdd=superWeaponCfg.weaponCfg[self.id]["limitGrow"][attKey]*self.lv*superWeaponCfg.weaponCfg[self.id]["upgradeGrow"][attKey]
		result[k]=upgradeAdd
	end
	return result
end

--获取配件的属性初始值, 是一个table
function superWeaponVo:getAttDefault()
	return superWeaponCfg.weaponCfg[self.id]["default"]
end

--获取存在配置文件中的属性值
--param key: 要获取的是哪个属性
function superWeaponVo:getConfigData(key)
	return superWeaponCfg.weaponCfg[self.id][key]
end