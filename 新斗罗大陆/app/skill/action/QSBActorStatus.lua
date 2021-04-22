local QSBAction = import(".QSBAction")
local QSBActorStatus = class("QSBActorStatus", QSBAction)
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")
--[==[

	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)
	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)
	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)
	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)
	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)
	注意:这个脚本只能给有目标的技能用(群体技能有概率会报没目标的错)


	--写了一个比较万能的action
	--功能是根据格式来判断对方或者自己的状态 并做一些操作
	--其实这里判断自己的状态的操作有一部分可以直接通过量表来完成，但是这个action可以让判断的条件更随意一些而不需要在actor里添加代码(比如自己血量比对方血量多 自己血量比对方血量百分比多，自己血量比对方的怒气的百分比多之类)
	--在数值的判断中 可以直接使用> < == != 来比较
	--options的格式为
	{
		{"状态(默认为自己如果是对方则以target:开头)","操作(默认为自己(self)，如果是对方则以target:开头)","条件类型(在状态下under_status(默认),不在状态下not_under_status)"}
	}
	--举例
	{
		{"target:hp_percent>0.5","apply_buff:buff_abc"}
		{"target:hp_percent>0.5","remove_buff:buff_abc","not_under_status"}
		--[[
			这样就是一个如果目标血量高于50%则添加一个id为buff_abc的buff 如果目标血量低于50%则移除
		]]
		{"target:hp_percent<0.5","target:hp_add:maxHp*0.5+20+1*2","not_under_status"} --可以做到像这样的连续的相加 但是没有优先级 只能从左往右 支持百分号 百分号是相对于calcValue的第三个参数

		判断条件可以自由添加比如
		{"hp>target:hp","target:add_hp:50%+100"} --这样就是如果自身的血量比目标血量高就给目标回复最大生命值的50%+100的血量
		{"freeze","add_hp:1000*2"} --自己如果被冰冻了就回1000*2点血
		{"freeze","apply_buff:冰冻状态的buff","not_under_status"} --自己如果没冰冻就把自己冻起来
		{"target:freeze","add_hp:1000"} --对方如果被冰冻了就回复自己1000点血量

		{"target:has_buff == buffid","add_hp:1000"} 有某个buff就回血
		{"target:has_buff != buffid","add_hp:1000"} 没有某个buff就回血
	}

	--下面是触发条件的解释
	除以下字段之外的都视为Actor的Status会从Actor的Status列表里找 用法就是{target/self:status_name,命令,条件类型}
	特殊字段:
	actor_is_dead 对方是否死亡 {"target/self:actor_is_dead",命令,条件类型}这样就行
	has_buff 对方是否拥有某个buff {"target/self:has_buff==buffID",命令,条件类型} {"target/self:has_buff!=buffID",命令,条件类型} ==有 !=没有

	--下面是命令的解释

	apply_buff 给目标添加一个buff 支持多个buff 可以用分号分开 每次调用此脚本，同一个buff只会被添加一次 用法 {条件,"target/self:apply_buff:buffID1;buffID2",条件类型} 
	remove_buff 给目标移除指定buff 支持多个buff 可以用分号分开 用法 {条件,"target/self:remove_buff:buffID;buffID",条件类型}
	increase_hp 回血 给目标回血 {条件,"target/self:hp_add:血量值",条件类型}
	decrease_hp 扣血 同上 考虑到魔免与物免
	trigger_skill 触发技能 {条件,"target/self:trigger_skill:技能id",条件类型} 触发的技能的等级与EnhanceValue会继承上一个技能
	remove_status 移除状态 多个状态可以用分号分开 {条件,"target/self:remove_status:status1;status2"} 会移除所有带有这个状态的buff

	--下面是一些数值字段 在一些需要数值的命令或者条件里可以使用
	maxHp:最大血量值 用法(以回血为例):{状态,"hp_add:target:maxHp*0.5",条件类型} 回复目标最大生命值50%的血量 
	hp:当前血量值 用法(以回血为例):{状态,"hp_add:target:hp*0.5",条件类型} 回复当前生命值50%的血量 
	hp_percent:当前血量的百分比:{self:hp_percent>target:hp_percent,"target:hp_add:50%",条件类型} 当自己的血量百分比 比对方的血量百分比高的时候 回复对方最大生命值50%的血量
	magic_armor:法术防御
	physical_armor:物理防御
	total_armor:物理防御+魔法防御
	
	扩展的时候只需要在hp里添加条件判断的函数(除非有特殊需求),commands里添加命令函数,status_values_function里添加一些获取值的函数就可以
--]==]
local operates = {"+","-","*","/"} -- 运算符
local comparisons = {">"--[[大于]],"<"--[[小于]],"=="--[[等于]],"!="--[[不等于]]} -- 比较符没有大于等于跟小于等于 

local status_values = {} -- status是用来获取状态的值的使用时将这个表来当做索引使用就可以比如获取自己最大血量值就是status_values["target:max"]

local status_values_function = {
	maxHp = function(actor) 
			return actor:getMaxHp() 
		end,
	hp = function (actor)
			return actor:getHp()
		end,
	hp_percent = function (actor)
			return actor:getHp()/actor:getMaxHp()
		end,
	magic_armor = function(actor)
			return actor:getMagicArmor()
		end,
	physical_armor = function (actor)
			return actor:getPhysicalArmor()
		end,
	total_armor = function (actor)
			return actor:getMagicArmor() + actor:getPhysicalArmor()
		end,
	maxAttack = function(actor) 
			return actor:getMaxAttack() 
		end,
}

local status = {} --这个表用来获取角色是否在某个状态下的 status[状态名] 就可以 值为true跟false  这个函数可以在status_functions里进行扩展

local function compare(k,v1,v2) --比较
	if v1 == true then return true end
	if v1 == false then return false end
	if v1 == nil or v2 == nil then return false end
	if type(v1) ~= "number" or type(v2) ~= "number" then return false end
	if k == ">" then
		return v1>v2
	elseif k == "<" then
		return v1<v2
	elseif k == "==" then
		return v1 == v2
	elseif k == "!=" then
		return v1~=v2
	else return false end
end
local status_functions = {   --这个是status里来判断角色是否在某个状态下的表  返回两个number类型的比较值v1与v2,也可以直接返回布尔值
	--这里可以添加一些状态的条件 下面是一个判断对方是否死亡的例子
	actor_is_dead = function(self,target_1,compare_value1,target_2,compare_value2,comparison) --self是action对象 ,target_1 目标1(如果是两者比较的话target_1就是比较符左边的目标) target_2 目标2(如果是两者比较的话那么就是比较符右边的目标) 
			return target_1 and target_1:isDead()   --返回值可以是布尔值代表是否成立 也可以是两个数值类型 后面会自动根据比较符来返回比较两个数值的结果         -- compare_value1比较符左边的字符串(完整字符串) compare_value2 比较符右边的字符串
		end,

	is_pvp = function(self,target_1,compare_value1,target_2,compare_value2,comparison)		
			if comparison ~= "==" and comparison ~= "!=" then
				return false
			end
			local compareValue = compare_value2 == "true" and true or false
			local result = app.battle:isPVPMode() == compareValue
			if comparison == "==" then
				return result
			elseif comparison == "!=" then
				return not result
			end
			return false
		end,
	has_buff = function(self,target_1,compare_value1,target_2,compare_value2,comparison)
			if comparison ~= "==" and comparison ~= "!=" then
				return false
			end
			if not target_1 then return false end
			for _,buff in pairs(target_1:getBuffs()) do
				if buff:getId() == compare_value2 then
					if comparison == "==" then
						return true
					elseif comparison == "!=" then
						return false
					end
				end
			end

			if comparison == "==" then
				return false
			elseif comparison == "!=" then
				return true
			end
			return false
		end,
	---------新增判断职业 包括BOSS或小BOSS-----------tdy
	role = function(self,target_1,compare_value1,target_2,compare_value2,comparison)
			if comparison ~= "==" and comparison ~= "!=" then
				return false
			end
			if not target_1 then return false end
			local result = false
			
			if compare_value2 == "elite_boss" then
				result = target_1:isEliteBoss()
			elseif compare_value2 == "boss" then
				result = target_1:isBoss()
			elseif compare_value2 == "boss_or_elite_boss" then
				result = target_1:isBoss() or target_1:isEliteBoss()
			else
				result = compare_value2 == target_1:getTalentFunc()
			end

			if comparison == "==" then
				return result
			elseif comparison == "!=" then
				return not result
			end
			return false
		end,
	--------------------------------------------------tdy
}

local commands = { --命令列表  使用时将这个表当做函数使用 格式为commands(str) str会被分割成需要的数据
	apply_buff = function (self,target,values,...) --values是拆分 options并除掉开头target与命令部分后的部分 比如target:apply_buff:buff_id 则结果是 {"buff_id"}
		if not target then return end
		if #values == 1 then
			local buffs  = string.split(values[1],",")
			for k,v in pairs(buffs) do 
				if not self._buff_cache[v] then
	                local buffId = v
	                local buffTargetType = "self"
	                if target == self._target then
	                	buffTargetType = "target"
	                end
	                local newBuff = self._attacker:_doTriggerBuff(buffId, buffTargetType, target, self._skill)
	                self._buff_cache[v] = true
                end
	        end
		end
	end,
	remove_buff = function (self,target,values,...)
		if not target then return end
		if #values == 1 then
			local buffs = string.split(values[1],";")
			for k,v in pairs(buffs) do 
				target:removeBuffByID(v)
	        end
		end
	end,
	increase_hp = function(self,target,values,...)
		if not target then return end
		local damage = self:calcValue(target,values,target:getMaxHp())
		local _, dHp = target:increaseHp(damage,self._attacker,self._skill)
		if dHp and dHp > 0 then
			target:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
	            isCritical = false, tip = "", rawTip = {
	                isHero = target:getType() ~= ACTOR_TYPES.NPC,
	                isDodge = false,
	                isBlock = false,
	                isCritical = false,
	                isTreat = true,
	                isAbsorb = false,
	                number = math.ceil(dHp),
	            }})
		end
	end,
	decrease_hp = function(self,target,values,...)
		if not target then return end
		if not self._skill then return end
		
		if self:isDeflection(self._attacker, target) then
			return
		end

		local damage_type = self._skill:getDamageType()
		local is_immuned = false
        if damage_type == QSkill.PHYSICAL and target:isImmunePhysicalDamage() then
            is_immuned = true
        elseif damage_type == QSkill.MAGIC and target:isImmuneMagicDamage() then
            is_immuned = true
        end

        if is_immuned then return end

		local total_damage = self:calcValue(target,values,target:getMaxHp())
		total_damage = total_damage * self:getDragonModifier()
	    if not target:isBoss() and not target:isEliteBoss() then
        	self._attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, target, total_damage)
    	end
		local _, damage, absorb = target:decreaseHp( total_damage, self._attacker, self._skill)
        if absorb > 0 then
            local absorb_tip = "吸收 "
            target:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                isHero = target:getType() ~= ACTOR_TYPES.NPC, 
                isDodge = false, 
                isBlock = false, 
                isCritical = false, 
                isTreat = false,
                isAbsorb = true, 
                number = math.ceil(absorb),
            }})
        end
        target:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip_modifiers = {},
            isCritical = false, tip = "", rawTip = {
                isHero = target:getType() ~= ACTOR_TYPES.NPC,
                isDodge = false,
                isBlock = false,
                isCritical = false,
                isTreat = false,
                isAbsorb = false,
                number = math.ceil(damage),
            }})
	end,
	trigger_skill = function(self,target,values,...)
		if not target then return end
		local owner_skill = self._skill
		local default_level = owner_skill and owner_skill:getSkillLevel() or 1
		local skill_id, level = q.parseIDAndLevel(values[1],default_level)
		local actor = target
		skill_id = tonumber(skill_id)
		local triggerSkill = actor._skills[skill_id]
		if triggerSkill == nil then
			triggerSkill = QSkill.new(skill_id, {}, actor, level)
			triggerSkill:setEnhanceValue(self._skill:getEnhanceValue())
			triggerSkill:setIsTriggeredSkill(true)
			actor._skills[skill_id] = triggerSkill
		end
		triggerSkill:setDamager(self._skill:getDamager())
		actor:triggerAttack(triggerSkill)
	end,
	trigger_skill_as_target = function(self,target,values,...)
		if not target then return end
		local owner_skill = self._skill
		local default_level = owner_skill and owner_skill:getSkillLevel() or 1
		local skill_id, level = q.parseIDAndLevel(values[1],default_level)
		local actor = self._attacker
		skill_id = tonumber(skill_id)
		local triggerSkill = actor._skills[skill_id]
		if triggerSkill == nil then
			triggerSkill = QSkill.new(skill_id, {}, actor, level)
			triggerSkill:setEnhanceValue(self._skill:getEnhanceValue())
			triggerSkill:setIsTriggeredSkill(true)
			actor._skills[skill_id] = triggerSkill
		end
		triggerSkill:setDamager(self._skill:getDamager())
		actor:triggerAttack(triggerSkill, target)
	end,
	remove_status = function(self,target,values,...)
		if not target then return end
		local status_list = string.split(values[1],";")
		for i,v in ipairs(status_list) do
			for _, buff in ipairs(target._buffs) do
				if not buff:isImmuned() then
					if buff.effects.can_be_removed_with_skill == false or self._skill:canRemoveBuff() == false then
						if buff:hasStatus(v) then
							target:removeBuffByID(buff:getId())
						end
					end
				end
			end
		end
	end,
}
function QSBActorStatus:calcValue(target,values,percent_100_value) --根据_operate函数的结果来计算数值
	local result = 0
	local initValue = percent_100_value or 1
	local operate = nil
	for k,v in pairs(values) do
		if v == "+" then
			operate = "+"
		elseif v == "-" then
			operate = "-"
		elseif v == "*" then
			operate = "*"
		elseif v == "/" then
			operate = "/"
		else
			local num = tonumber(v)
			if not num then
				if string.sub(v,#v,#v) == "%" then
					num = tonumber(string.sub(v,1,-2))/100 * initValue
				else
					num = self.status_values[v]
				end
			end
			assert(num,string.format("can't get value:%s",v))
			if operate == "+" then
				result = result + num
			elseif operate == "-" then
				result = result - num
			elseif operate == "*" then
				result = result * num
			elseif operate == "/" then
				result = result / num
			else
				result = num
			end
			operate = nil
		end
	end
	return result
end

local function _operate(status_str)--将命令的字符串分割成数组
	string.gsub(status_str, " ", "")
	for k,v in pairs(operates) do 
		local strs = string.split(status_str,v)
		if #strs >1 then
			local str = ""
			for i = 2,#strs do 
				str = str..strs[i]..v
			end
			str = string.sub(str,1,-2)
			return strs[1],v,_operate(str)
		end
	end
	return status_str,nil,nil
end

local function _comparison(compare_str)--将条件字符串分割成数组
	string.gsub(compare_str, " ", "")
	for k,v in pairs(comparisons) do 
		local strs = string.split(compare_str,v)
		if #strs >1 then
			local str = ""
			for i = 2,#strs do 
				str = str..strs[i]..v
			end
			str = string.sub(str,1,(string.len(v) + 1) * -1)
			return strs[1],v,str
		end
	end
	return compare_str or ""
end

local function underOtherStatus(self,key,target_1,compare_value1,target_2,compare_value2)
	if compare_value2 ~= nil and target_2 ~= nil then
		local v1 = tonumber(compare_value1) or tonumber(self.status_values[compare_value1])
		local v2 = tonumber(compare_value2) or tonumber(self.status_values[compare_value2])
		return v1,v2
	elseif target_1 ~= nil then
		return target_1:isUnderStatus(key)
	else
		return false
	end
end

local function doOther(self,target,values,...) --找不到命令后会执行这里
	
end

function QSBActorStatus:ctor(director, attacker, target, skill, options)
    QSBActorStatus.super.ctor(self, director, attacker, target, skill, options)
    local function getTarget(v)
    	local strs = string.split(v,":")
    	local _target = attacker
    	if #strs > 1 then
    		if strs[1] == "self" then
    			_target = attacker
    		elseif strs[1] == "target" then
    			_target = target or attacker:getTarget()
    		end
    	end
    	local str = "" 
    	if #strs == 1 then
	    	str = v
	    else
	    	local _i = 1
	    	if strs[1] == "self" or strs[1] == "target" then
	    		_i = 2
	    	end
	    	for i = _i,#strs do
	    		str = str..strs[i]..":"
	    	end
	    	str = string.sub(str,1,-2)
	    end
    	return _target,str
    end
    local mt = {
    		__index = function(t,k)
					local compare_value1,comparison,compare_value2 = _comparison(k)
					local target_1,key = getTarget(compare_value1)
					local target_2 = getTarget(compare_value2)
					if status_functions[key] then
						return compare(comparison,status_functions[key](self,target_1,compare_value1,target_2,compare_value2,comparison))
					else
						return compare(comparison,underOtherStatus(self,key,target_1,compare_value1,target_2,compare_value2,comparison))
					end

    			end
    }
    local mt2 = {
    	__index = function(t,status_key)
    				local _target,str = getTarget(status_key)
    				if not _target then
    					return nil
    				end
    				if status_values_function[str] then
    					return status_values_function[str](_target)
    				else
    					return nil
    				end
    			end
	}
	local mt3 = {
		__call = function (t,key,...)
					local _target,str = getTarget(key)
					if not _target then return end
					local values = {_operate(str)}
					local _arr = string.split(values[1],":")
					local _command = _arr[1]
					local _s = ""
					if #_arr > 1 then
						for i = 2,#_arr do
		    				_s = _s.._arr[i]..":"
		    			end
						_s = string.sub(_s,1,-2)
					else
						_s = _arr[1]
					end
					values[1] = _s

					if t[_command] then
						t[_command](self,_target,values,...)
					else
						doOther(self,_target,values,...)
					end

				end
	}
    self.status = setmetatable(clone(status),mt)
	self.status_values = setmetatable(clone(status_values),mt2)
	self.commands = setmetatable(clone(commands),mt3)

end

local function replaceSpace(tab)
	if type(tab) ~= "table" then return end
	for k,v in pairs(tab) do 
		if type(v) == "string" then
			tab[k] = string.trim(v)
		end
	end
end

function QSBActorStatus:_execute(dt)
	self._buff_cache = {} --每次调用该脚本都会清空buff缓存
	for i,v in ipairs(self._options) do
		v[3] = v[3] or "under_status"
		replaceSpace(v)
		if #v == 3 then 
			if v[3] == "under_status" then
				if self.status[v[1]] then
					self.commands(v[2])
				end
			elseif v[3] == "not_under_status" then
				if not self.status[v[1]] then
					self.commands(v[2])
				end
			end
		end
	end
	
	self:finished()
end

return QSBActorStatus
