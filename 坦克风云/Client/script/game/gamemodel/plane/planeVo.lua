planeVo={}

function planeVo:new(cfg)
	local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.cfg=cfg
	return nc
end

function planeVo:initWithData(pData,idx)
	self.pid=pData[1] --飞机id
	self.aSkillTb=pData[2] or {}
	self.pSkillTb=pData[3] or {}
	self.idx=idx
end

function planeVo:addSkill(idx,sid,activeFlag)
	local skills=self:getSkills(activeFlag)
	skills[idx]=sid
end

function planeVo:replaceSkill(idx,sid,activeFlag)
	local skills=self:getSkills(activeFlag)
	skills[idx]=sid
end

function planeVo:removeSkill(idx,sid,activeFlag)
	local skills=self:getSkills(activeFlag)
	skills[idx]=0
end

function planeVo:getSkills(activeFlag)
	if activeFlag and activeFlag==true then
		return self.aSkillTb
	end
	return self.pSkillTb
end

function planeVo:isSkillSlotEquiped(pos,activeFlag)
	local skills=self:getSkills(activeFlag)
	local sid=skills[pos]
	-- print("pos,sid---------->",pos,sid)
	if sid and tonumber(sid)~=0 then
		return true,sid
	end
	return false,sid
end

function planeVo:getName()
	return getlocal("plane_name_"..self.pid)
end

function planeVo:getDesc()
	local addBuffTb=planeVoApi:getPlaneAddBuffByPlaneId(self.pid) --战机革新各个技能加成buff
	local atkStr=((self.cfg.restrainQue+(addBuffTb.restrain or 0))*100).."%%"
	if addBuffTb.restrain then
		atkStr=atkStr.."("..(self.cfg.restrainQue*100).."%%".."<rayimg>+"..(addBuffTb.restrain*100).."%%".."<rayimg>)"
	end
	return getlocal("plane_desc_"..self.pid,{atkStr})
end

function planeVo:getPic()
	return "plane_icon_"..self.pid..".png"
end

function planeVo:getASkills()
	return self.aSkillTb
end

function planeVo:getPSkills()
	return self.pSkillTb
end

--noSkill 是否包含技能
function planeVo:getStrength(noSkill)
	local value=0
	if self.cfg then
		value=self.cfg.strength or 0
	end
	if noSkill==true then
	else
		local aSkills=self.aSkillTb
		local pSkills=self.pSkillTb
		if aSkills then
			for m,sid in pairs(aSkills) do
				if sid and sid~=0 then
					local gcfg=planeGrowCfg.grow[sid]
					if gcfg and gcfg.skillStrength then
						value=value+gcfg.skillStrength
					end
				end
			end
		end
		if pSkills then
			for m,sid in pairs(pSkills) do
				if sid and sid~=0 then
					local gcfg=planeGrowCfg.grow[sid]
					if gcfg and gcfg.skillStrength then
						local strong = gcfg.skillStrength
						if m == 5 then --战机改装中新增的5号位技能槽
							local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(self.pid)
					        if isUnlockSlot == true then
					        	strong = math.floor(strong * unlockAttrValue)
					        end
						end
						value=value+strong
					end
				end
			end
		end
	end
	--战机革新各个技能威力加成
	local add=planeVoApi:getAddStrengthByPlaneId(self.pid)
	value=value+add

	--战机改装的威力加成
	if planeRefitVoApi then
		value = value + planeRefitVoApi:getStrength(self.pid)
	end
	
	return value
end
