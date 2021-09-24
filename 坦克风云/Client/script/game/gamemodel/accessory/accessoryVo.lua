accessoryVo={}
function accessoryVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function accessoryVo:initWithData(param)
	self.id=param.id or 0 				--配件的唯一ID
	self.type=param[1]					--配件的配置ID，是哪种配件
	self.lv=tonumber(param[2]) 			--配件的强化等级,number
	self.rank=tonumber(param[3]) 		--配件的改造等级,number
	--精炼属性
	if param[4] then
		self.succinct=param[4]
	end
	if(self.succinct==nil or #self.succinct==0)then
		self.succinct={0,0,0,0}
	end
	--是否绑定
	if param[5] then
		self.bind=tonumber(param[5]) or 0
	end
	--配件科技，格式[科技类型, 科技等级]
	if param[6] then
		self.techID=tonumber(param[6][1])
		self.techLv=tonumber(param[6][2])
	end
	self.promoteLv = tonumber(param[7]) or 0 --配件的晋升等级
end

--获取配件提供的属性加成, 是一个table
function accessoryVo:getAtt()
	local default=self:getAttDefault()
	local result={}
	for k,v in pairs(default) do
		local lAdd=tonumber(accessoryCfg.aCfg[self.type]["lvGrow"][k])*self.lv
		local rAdd=tonumber(accessoryCfg.aCfg[self.type]["rankGrow"][k])*self.rank
		result[k]=tonumber(v)+lAdd+rAdd
	end
	return result
end

--获取配件提供的属性加成, 是一个table
-- 攻击 生命 防护 击破 暴伤 韧性 对坦克伤害加成  对歼击车伤害加成 对火炮伤害加成 对火箭车伤害加成 减少 坦克，歼击车 ，火炮，火箭车 伤害
function accessoryVo:getAttWithSuccinct()
	local default=self:getAttDefault()
	local resultByLR={}
	for k,v in pairs(default) do
		local lAdd=tonumber(accessoryCfg.aCfg[self.type]["lvGrow"][k])*self.lv
		local rAdd=tonumber(accessoryCfg.aCfg[self.type]["rankGrow"][k])*self.rank
		resultByLR[k]=tonumber(v)+lAdd+rAdd
	end
	local result={}
	for i=1,14 do
		result[i]=0
	end
	for k,attType in pairs(self:getConfigData("attType")) do
		result[attType]=resultByLR[k]
	end
	local succinct = self:getSuccinct()
	local sinct = {succinct[1]*100,succinct[2]*100,succinct[4],succinct[3]}
	for i=1,4 do
		result[i]=result[i]+sinct[i]
	end

	local desType = self.type
    local refineId = accessoryCfg.aCfg[desType].refineId
    if refineId~=0 then
        local bounsAtt = succinctCfg.bounsAtt[refineId]
        local tb = {108,100,202,201}
        local suc = {succinct[2],succinct[1],succinct[3],succinct[4]}
        for p,q in pairs(bounsAtt) do
            local value=q[1][tb[p]]
            if suc[p]>=value then
                for m,n in pairs(q[2]) do
                    if m==110 then
                        result[5]=result[5]+n
                    elseif m==111 then
                        result[6]=result[6]+n
                    elseif m==211 then
                        result[7]=result[7]+n
                    elseif m==212 then
                        result[8]=result[8]+n
                    elseif m==213 then
                        result[9]=result[9]+n
                    elseif m==214 then
                        result[10]=result[10]+n
                    elseif m==221 then
                        result[11]=result[11]+n
                    elseif m==222 then
                        result[12]=result[12]+n
                    elseif m==223 then
                        result[13]=result[13]+n
                    elseif m==224 then
                        result[14]=result[14]+n
                    end
                end
            end
           
        end
    end
	if(self.bind==1)then
		local bindAtt=self:getBindAtt()
		for attType,attValue in pairs(bindAtt) do
			result[attType]=result[attType] + attValue
		end
	end
	if(self.techID and self.techLv)then
		local techAtt=self:getTechAttByIDAndLv(self.techID,self.techLv)
		if(techAtt)then
			for attType,attValue in pairs(techAtt) do
				result[attType]=result[attType] + attValue
			end
		end
	end
	if self.bind == 1 and base.redAccessoryPromote == 1 then
		local attrTb = accessoryVoApi:getPromoteAttrTb(self.type, self.promoteLv)
		if attrTb then
			for attrType, attrValue in pairs(attrTb) do
				result[attrType] = result[attrType] + attrValue
			end
		end
	end
	return result
end

--获取该配件在指定强化等级和精炼等级的属性
--param lv: 等级; rank: 精炼等级
function accessoryVo:getAttByLvAndRank(lv,rank)
	local default=self:getAttDefault()
	local resultByLR={}
	for k,v in pairs(default) do
		local lAdd=tonumber(accessoryCfg.aCfg[self.type]["lvGrow"][k])*lv
		local rAdd=tonumber(accessoryCfg.aCfg[self.type]["rankGrow"][k])*rank
		resultByLR[k]=tonumber(v)+lAdd+rAdd
	end
	local result={}
	for i=1,14 do
		result[i]=0
	end
	for k,attType in pairs(self:getConfigData("attType")) do
		result[attType]=resultByLR[k]
	end
	local succinct = self:getSuccinct()
	local sinct = {succinct[1]*100,succinct[2]*100,succinct[4],succinct[3]}
	for i=1,4 do
		result[i]=result[i]+sinct[i]
	end

	local desType = self.type
    local refineId = accessoryCfg.aCfg[desType].refineId
    if refineId~=0 then
        local bounsAtt = succinctCfg.bounsAtt[refineId]
        local tb = {108,100,202,201}
        local suc = {succinct[2],succinct[1],succinct[3],succinct[4]}
        for p,q in pairs(bounsAtt) do
            local value=q[1][tb[p]]
            if suc[p]>=value then
                for m,n in pairs(q[2]) do
                    if m==110 then
                        result[5]=result[5]+n
                    elseif m==111 then
                        result[6]=result[6]+n
                    elseif m==211 then
                        result[7]=result[7]+n
                    elseif m==212 then
                        result[8]=result[8]+n
                    elseif m==213 then
                        result[9]=result[9]+n
                    elseif m==214 then
                        result[10]=result[10]+n
                    elseif m==221 then
                        result[11]=result[11]+n
                    elseif m==222 then
                        result[12]=result[12]+n
                    elseif m==223 then
                        result[13]=result[13]+n
                    elseif m==224 then
                        result[14]=result[14]+n
                    end
                end
            end
           
        end
    end
	if(self.bind==1)then
		local bindAtt=self:getBindAtt()
		for attType,attValue in pairs(bindAtt) do
			result[attType]=result[attType] + attValue
		end
	end
	if(self.techID and self.techLv)then
		local techAtt=self:getTechAttByIDAndLv(self.techID,self.techLv)
		if(techAtt)then
			for attType,attValue in pairs(techAtt) do
				result[attType]=result[attType] + attValue
			end
		end
	end
	if self.bind == 1 and base.redAccessoryPromote == 1 then
		local attrTb = accessoryVoApi:getPromoteAttrTb(self.type, self.promoteLv)
		if attrTb then
			for attrType, attrValue in pairs(attrTb) do
				result[attrType] = result[attrType] + attrValue
			end
		end
	end
	return result
end

--获取配件的属性初始值, 是一个table
function accessoryVo:getAttDefault()
	return accessoryCfg.aCfg[self.type]["att"]
end

--根据改造和强化等级获取获取配件的战斗力评分
--paramLv,paramRank: 不传的话默认是配件当前的改造强化等级
function accessoryVo:getGS(paramLv,paramRank,promoteLv)
	local lv,rank
	if(paramLv)then
		lv=paramLv
	else
		lv=self.lv
	end
	if(paramRank)then
		rank=paramRank
	else
		rank=self.rank
	end
	local part=self:getConfigData("part")
	local quality=tonumber(self:getConfigData("quality"))
	local cfg=accessoryCfg.fightingValue["p"..part]
	local lvAddGs=(lv + 1)*cfg[1][quality]
	local rankAddGs=rank*cfg[2][quality]
	-- 配件绑定之后增加强度计算
	local bindAddGs = 0
	if self.bind==1 then
		bindAddGs = cfg[3]
	end
	-- 红配晋升的强度计算
	local promoteGs = 0
	if base.redAccessoryPromote == 1 then
		promoteGs = accessoryVoApi:getPromoteStrength(self.type, promoteLv or self.promoteLv)
	end
	return lvAddGs+rankAddGs+bindAddGs+promoteGs
end

--获取存在配置文件中的属性值
--param key: 要获取的是哪个属性
function accessoryVo:getConfigData(key)
	return accessoryCfg.aCfg[self.type][key]
end

-- 获取强化属性
function accessoryVo:getSuccinct()
	if(self.succinct==nil or #self.succinct==0)then
		self.succinct={0,0,0,0}
	end
	return self.succinct
end

-- 获取精炼强度
function accessoryVo:getGsAdd()
	local succinct=self:getSuccinct()
	local gsAdd = math.ceil((succinct[1]+succinct[2])*800+(succinct[3]+succinct[4])*20)
	return gsAdd
end

--获取绑定后可以增加的额外属性
function accessoryVo:getBindAtt()
	local bindAttType=self:getConfigData("btype")
	local bindAttValue=self:getConfigData("bValue")
	local result={}
	for k,attType in pairs(bindAttType) do
		result[attType]=bindAttValue[k]
	end
	return result
end

--根据科技ID和等级获取配件科技增加的属性
--param techID,techLv: 科技的ID和等级
function accessoryVo:getTechAttByIDAndLv(techID,techLv)
	if(techID==nil)then
		techID=self.techID
	end
	if(techLv==nil)then
		techLv=self.techLv
	end
	if(techID and techLv)then
		local tankID="t"..self:getConfigData("tankID")
		local partID=self:getConfigData("part")
		local attCfg=accessorytechCfg.tankType[tankID][techID].ability[techLv]
		if(attCfg)then
			local result={}
			for k,v in pairs(attCfg.attType) do
				result[v]=attCfg.value[k]
			end
			return result
		end
	end
end

--根据科技ID和等级获取给科技技能贡献的点数
--param techID,techLv: 科技的ID和等级
function accessoryVo:getTechSkillPointByIDAndLv(techID,techLv)
	if(techID==nil)then
		techID=self.techID
	end
	if(techLv==nil)then
		techLv=self.techLv
	end
	if(techID and techLv and techLv>0)then
		local tankID="t"..self:getConfigData("tankID")
		local partID=self:getConfigData("part")
		local attCfg=accessorytechCfg.tankType[tankID][techID].ability[techLv]
		if(attCfg)then
			return tonumber(attCfg.addTechValue) or 0
		end
	end
	return 0
end

--配件科技是否达到最大等级
function accessoryVo:techLvMax()
	if(self.techLv and self.techLv>=accessoryVoApi:getTechMaxLv())then
		return true
	else
		return false
	end
end