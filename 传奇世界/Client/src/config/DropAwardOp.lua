local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------------
-- 装备表
local dropAward = getConfigItemByKeys("DropAward",{"q_id","q_item","q_group"})

dropItem = function(self, q_id, q_item,q_group)
	--dump({ school = school, level = level })
	local tdrop = dropAward[q_id]
	local items = {}
	if tdrop then
		if q_item then
			if q_group then
				return tdrop[q_item][q_group]
			else
				for k,v in pairs(tdrop[q_item])do 
					items[k] = v
				end
			end
		else
			for k,v in pairs(tdrop)do 
				for h,m in pairs(v)do
					items[k] = m
				end
			end
		end
	end
	return items
end

dropItem_ex = function(self, q_id)
	--dump({ school = school, level = level })
	local tdrop = dropAward[q_id]
	local items = {}
	if tdrop then
		for k,v in pairs(tdrop)do 
			for h,m in pairs(v)do
				table.insert(items,m)
			end
		end
	end
	return items
end

getDropNum = function( self, q_id, q_item )
	-- body
	local awardsConfig = self:dropItem_ex(q_id)
	for i=1, #awardsConfig do
        if q_item == awardsConfig[i]["q_item"] then
        	return awardsConfig[i]
		end
    end
end

--获取可用道具（同职业同性别)
getUsadble = function( self, q_id, q_item )
	-- body
	local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
	local MpropOp = require "src/config/propOp"

	local items = {}
	local cfg = self:dropItem_ex(q_id)
	for i , v in ipairs( cfg ) do
		local propSex = MpropOp.sexLimits( v.q_item )
		local propSch = MpropOp.schoolLimits( v.q_item )

		local isPass = false 
		if propSch ~= 0 and propSex ~= 0 then
			print( v.q_item , propSch , propSex , school , sex )
			if propSch == school and propSex == sex then
				isPass = true
			end
		else
			if propSch == 0 and propSex == 0 then
				isPass = true				
			else
				if propSch == 0 then
					isPass = ( propSex == sex )
				else
					isPass = ( propSch == school )
				end
			end
		end
        if isPass then
          	items[ #items + 1 ] = { 
                                      id = v["q_item"] ,                          --奖励ID
                                      binding = v["bdlx"] ,                       --绑定(1绑定0不绑定)
                                      streng = v["q_strength"] ,                  --强化等级
                                      quality = v["q_quality"] ,                  --品质等级
                                      upStar = v["q_star"] ,                      --升星等级
                                      time = v["q_time"] ,                        --限时时间
                                      showBind = true ,                           --掉落表数据里边的数据  就必须设置当前这个字段存在且为true
                                      isBind = tonumber(v["bdlx"] or 0) == 1,     --绑定表现
                                  }
        end
		
    end

    return items
end



--获取可用道具（同职业同性别)
getItemBySexAndSchool = function( self, q_id)
	-- body
	local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
	local MpropOp = require "src/config/propOp"

	local tempSchoolSexCfg = {700, 800, 900, 400 , 500 , 600}
	local startGroup = tempSchoolSexCfg[school + (sex - 1)* 3]

	local items = {}
	local cfg = self:dropItem_ex(q_id)
	for i , v in ipairs( cfg ) do
		local isPass = false 
		if v.q_group < 400 or (v.q_group >= startGroup and v.q_group <= startGroup + 99) then
			items[ #items + 1 ] = { 
                                      q_item = v["q_item"] ,                          --奖励ID
                                      bdlx = v["bdlx"] ,                       --绑定(1绑定0不绑定)
                                      q_strength = v["q_strength"] ,                  --强化等级
                                      q_quality = v["q_quality"] ,                  --品质等级
                                      q_star = v["q_star"] ,                      --升星等级
                                      q_time = v["q_time"] ,                        --限时时间
                                      showBind = true ,                           --掉落表数据里边的数据  就必须设置当前这个字段存在且为true
                                      q_isBind = tonumber(v["bdlx"] or 0) == 1,     --绑定表现
                                      q_group = v["q_group"]
                                  }
		end
    end

    return items
end