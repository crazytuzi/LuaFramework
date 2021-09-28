-- 
require("app.cfg.dress_info")
require("app.cfg.dress_compose_info")
require("app.cfg.knight_info")
require "app.cfg.passive_skill_info"
require("app.cfg.item_cloth_info")
local DressData = class("DressData")

function DressData:ctor()
	self._dressList = {}
	self._dressedId = 0
	self._showDressList = {}
	self._showDressList2 = {}
end

function DressData:setDress(data)
	if data then
		self._dressList = data.dresses 
		self._dressedId = data.dress_id
		self:updateShowDressList()
	end
end

function DressData:getDressed()
	for k,v in pairs(self._dressList) do 
		if v. id == self._dressedId then
			return v
		end
	end
	return nil
end

function DressData:getDressInfo(id)
	return dress_info.get(id)
end

function DressData:getDressCanStrength()
	return true
end

function DressData:getDressList()
	return self._dressList
end

function DressData:getDressByBaseId(baseId)
	for k,v in pairs(self._dressList) do 
		if v. base_id == baseId then
			return v
		end
	end
	return nil
end

function DressData:getDressById(Id)
	for k,v in pairs(self._dressList) do 
		if v. id == Id then
			return v
		end
	end
	return nil
end

function DressData:updateShowDressList()
	if #self._dressList == 0 then
		return
	end
	local list = {}
	local list2 = {}
	table.insert(list, #list + 1, {id=0})
	-- for key, value in pairs(self._dressList) do 
	--      	table.insert(list, #list + 1, value)
	-- end
	for i = 1, dress_info.getLength() do 
		table.insert(list, #list + 1, dress_info.indexOf(i))
		table.insert(list2, #list2 + 1, dress_info.indexOf(i))
	end
	for i = 1,2 do 
		table.insert(list, #list + 1, {id=-1})
	end
	self._showDressList = list
	self._showDressList2 = list2
end

function DressData:getShowDressList()
	return self._showDressList
end
function DressData:getShowDressList2()
	return self._showDressList2
end

function DressData:hasDress()
	return #self._dressList > 0
end

function DressData:getCurSex()
	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	local info = knight_info.get(baseId)
	return info.sex
end

function DressData:hasDressId(id)
	for k,v in pairs(self._dressList) do 
		if v. base_id == id then
			return true
		end
	end
	return false
end

function DressData:updateDress(dressId)
	self._dressedId = dressId
end

function DressData:getDressedPic()
	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	if G_Me.userData:getClothTime() > 0 and G_Me.userData:getClothOpen() then 
		return item_cloth_info.get(G_Me.userData.cloth_id).res_id
	end 
	local dress = self:getDressed()
	if dress then
		return self:getDressedResidWithDress(baseId,dress.base_id)
	else
		return self:getDressedResidWithDress(baseId,0)
	end	
end

-- 只根据id来取，默认cltm和clop都是ok的  主要是为了战斗之类的地方少传参数 
-- function DressData:getClothWithClothIdAndDressId(knightid,dressid,_clid)
-- 	if _clid and _clid > 0 then 
-- 		return item_cloth_info.get(_clid).res_id
-- 	end 
-- 	return self:getDressedResidWithDress(knightid,dressid)
-- end

-- isself表示是不是自己
function DressData:getDressedResidWithDress(knightid,dressid,isself)
	-- print("get!!!!getDressedResidWithDress")
	if isself and G_Me.userData:getClothTime() > 0 and G_Me.userData:getClothOpen() then 
		return item_cloth_info.get(G_Me.userData.cloth_id).res_id
	end 
	local knightInfo = knight_info.get(knightid)
	if dressid == 0 then
		return knightInfo.res_id
	end
	if knightInfo.sex == 1 then
		return dress_info.get(dressid).man_res_id
	elseif knightInfo.sex == 0 then
		return dress_info.get(dressid).woman_res_id
	else
		return 0
	end
end

--  根据cloth id time 来判断时装显示 
function DressData:getDressedResidWithClidAndCltm(knightid,dressid,clid,cltm,clop)
	-- print("get!!!!getDressedResidWithClidAndCltm")
	if clid and clid > 0 and G_Me.userData:checkCltm(cltm) and clop then   
		return item_cloth_info.get(clid).res_id
	end 
	local knightInfo = knight_info.get(knightid)
	if not dressid or dressid == 0 then
		return knightInfo.res_id
	end
	if knightInfo.sex == 1 then
		return dress_info.get(dressid).man_res_id
	elseif knightInfo.sex == 0 then
		return dress_info.get(dressid).woman_res_id
	else
		return 0
	end
end

function DressData:getCurDressedResidWithDress(dressid)
	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	return self:getDressedResidWithDress(baseId,dressid)
end

function DressData:addToDressList(dress)
	table.insert(self._dressList, #self._dressList + 1, dress)
	self:updateShowDressList()
end

function DressData:updateDressList(dress)
	for k,v in pairs(self._dressList) do 
		if v. id == dress.id then
			v.level = dress.level
			break
		end
	end
	self:updateShowDressList()
end

function DressData:removeFromDressList(dressId)
	for k,v in pairs(self._dressList) do 
		if v. id == dressId then
			table.remove(self._dressList, k)
			break
		end
	end
	self:updateShowDressList()
end

function DressData:hasDressId(id)
	for k,v in pairs(self._dressList) do 
		if v. base_id == id then
			return true
		end
	end
	return false
end

function DressData:getComposeAttr()
	local data = {}
	for i = 1, dress_compose_info.getLength() do 
		local info = dress_compose_info.indexOf(i)
		local status = true
		for j = 1, 3 do 
			if info["dress_"..j] > 0 and not self:hasDressId(info["dress_"..j]) then
				status = false
			end
		end
		if status then
			for k = 1, 3 do 
				local _type = info["attribute_type_"..k]
				local _value = info["attribute_value_"..k]
				if _type > 0 then
					if data[_type] then
						data[_type] = data[_type] + _value
					else
						data[_type] = _value
					end	
				end
			end
		end
	end
	return data
end

function DressData:getCurrentAttr()
	local data = {}
	local dress = self:getDressed()
	if not dress then
		return data
	end
	local info = self:getDressInfo(dress.base_id)
	for i = 1 ,2 do 
		local _type = info["basic_type_"..i]
		local _value = info["basic_value_"..i]
		if _type > 0 then
			if data[_type] then
				data[_type] = data[_type] + _value
			else
				data[_type] = _value
			end
		end
	end
	for i = 1 ,4 do 
		local _type = info["strength_type_"..i]
		local _value = info["strength_value_"..i]
		if _type > 0 then
			if data[_type] then
				data[_type] = data[_type] + _value*(dress.level - 1)
			else
				data[_type] = _value*(dress.level - 1)
			end
		end
	end
	return data
end

function DressData:getDressSkill()
	local data = {}
	local dress = self:getDressed()
	if not dress then
		return data
	end
	local info = self:getDressInfo(dress.base_id)
	--时装技能加成
	for i = 1, 7 do 
	        local skillId = info["passive_skill_"..i]
	        if skillId > 0 and dress.level >= info["strength_level_"..i] then
		table.insert(data,#data+1,skillId)
	        end
	end
	return data
end

function DressData:getAttrs()
	return self:getCurrentAttr(),self:getComposeAttr()
end

function DressData:getTotalAttr()
	local data = {}
	local data1 = self:getComposeAttr()
	local data2 = self:getCurrentAttr()
	for k,v in pairs(data1) do 
		if data[k] then
			data[k] = data[k] + v
		else
			data[k] = v
		end
	end
	for k,v in pairs(data2) do 
		if data[k] then
			data[k] = data[k] + v
		else
			data[k] = v
		end
	end
	return data
end

-- function DressData:getMaxStrengthLevel()
-- 	return G_Me.userData.level * 2
-- end

function DressData:getCostMoney(dress)
	local level = dress.level
	local info = self:getDressInfo(dress.base_id)
	return math.ceil(info.cost_money * level^1.6)
end

function DressData:getCostItem(dress)
	local level = dress.level
	local info = self:getDressInfo(dress.base_id)
	return info.cost_item * math.floor(level/10 +1)
end

function DressData:getMaxLevel()
	local data = role_info.get(G_Me.userData.level)
	return data.max_dress_level
end


function DressData:getSkillTxt(dress)
	local list = {}
	local info = dress_info.get(dress.base_id)
	for i = 1, 20 do 
	    if dress_info.hasKey("passive_skill_"..i) then
	        local skillId = info["passive_skill_"..i]
	        if skillId > 0 then
	        	local skillInfo = passive_skill_info.get(skillId)
	        	local str = "["..skillInfo.name.."]  "..skillInfo.directions
	            local color = dress.level >= info["strength_level_"..i] and Colors.activeSkill or Colors.inActiveSkill
	            table.insert(list,#list+1,{content=str,color=color})
	        end
	    end
	end
	return list
end

function DressData:getAttackTypeTxt()
	local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	local knightInfo = knight_info.get(baseId)
	if knightInfo then
		return G_lang:get("LANG_DRESS_ATTACK_TYPE"..knightInfo.damage_type)
	end
end

return DressData
