--军徽部队数据
emblemTroopVo={}

function emblemTroopVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function emblemTroopVo:initWithData(mId,data)
	self.id=mId--装备大师唯一ID
	self.type=data[1]--装备大师配置id
	self.posTb=data[2] or {}--对应装配位上的装备{"e1","e2","e3"}
	self.addSavedTb=data[3] or {}--已保存的加成属性{dmg=0.1,maxhp=0.2}
	if data[4] then
		self.lastWashType=data[4][1] or nil
		self.lastWashTb=data[4][2] or {}--未保存的加成属性{x1,{dmg=0.1,maxhp=0.2}}  x1洗练类型
	end
	self.washStrong=data[5] or 0--最大洗练强度
	self.washTimes=data[6] or {} --各洗练保存结果总次数    
end

--单次训练
function emblemTroopVo:updateLastWashTb(washType,washData)
	if washType and washData then
		self.lastWashType=washType
		self.lastWashTb=washData
	end
end

--是否出征
function emblemTroopVo:checkIfBattled()
	if emblemVoApi:getBattleNumById(self.id)>0 then
		return true
	end
	return false
end

--是否洗练过
function emblemTroopVo:checkIfWashed()
	if self.washTimes then
		for k,v in pairs(self.washTimes) do
			if v and v>0 then
				return true
			end
		end
	end
	return false
end

--位置装备的颜色集合（显示颜色小图标用）
function emblemTroopVo:getPosEquipColorTb()
    return emblemTroopVoApi:getTroopEquipColorTbByPosTb(self.posTb)
end

function emblemTroopVo:getWashStrength()
    return emblemTroopVoApi:getTroopStrengthByAtt(self.addSavedTb)
end

function emblemTroopVo:getMaxWashStrength()
    return self.washStrong
end

function emblemTroopVo:getWashStrengthNotSaved()
    return emblemTroopVoApi:getTroopStrengthByAtt(self.lastWashTb)
end


function emblemTroopVo:getBaseStrength()
    return emblemTroopVoApi:getTroopBaseStrength(self.type)
end

function emblemTroopVo:getTroopStrength()
    return emblemTroopVoApi:getTroopStrengthByTroopData(self.type,self.posTb,self.addSavedTb,self.washStrong)
end


function emblemTroopVo:getAttValueByType(attType)
    return emblemTroopVoApi:getTroopAttValue(attType,self.type,self.posTb,self.addSavedTb,self.washStrong)
end


function emblemTroopVo:getAttValueTb()
    local attCfg=emblemTroopVoApi:getTroopAttributeType()
    local attTb={}
    for k,v in pairs(attCfg) do
        local value=self:getAttValueByType(v)
        attTb[v]=value
    end
    return attTb
end

function emblemTroopVo:getSkillTb()
    return emblemTroopVoApi:getTroopSkillsByPosTb(self.posTb)
end

function emblemTroopVo:getName()
    return getlocal("emblem_name_"..self.type)
end

function emblemTroopVo:getIconPic()
    return emblemTroopVoApi:getTroopIconPic(self.type,self.washStrong)
end

function emblemTroopVo:getIconWithBg(callback,isBig)
    local colorTb=self:getPosEquipColorTb()
    return emblemTroopVoApi:getTroopIconWithBg(self.type,self:getTroopStrength(),self.washStrong,colorTb,callback,isBig)
end

function emblemTroopVo:getIconNoBg(callback)
    local colorTb=self:getPosEquipColorTb()
    return emblemTroopVoApi:getTroopIconNoBg(self.type,self:getTroopStrength(),self.washStrong,colorTb,callback)
end

--是否有一个提高的未保存的属性
function emblemTroopVo:checkIfOneAttUp()
    if self.lastWashTb then
        for k,v in pairs(self.lastWashTb) do
            if self.addSavedTb[k]==nil or (self.addSavedTb[k]<v) then
                return true
            end
        end
    end
    return false
end

-- 获取洗练属性(自动洗练显示用)
function emblemTroopVo:getSuccinct()
    --{hp,dmg,accuracy,evade,crit,anticrit}
    return {self.addSavedTb.hp or 0,
            self.addSavedTb.dmg or 0,
            self.addSavedTb.accuracy or 0,
            self.addSavedTb.evade or 0,
            self.addSavedTb.crit or 0,
            self.addSavedTb.anticrit or 0
        }
end



