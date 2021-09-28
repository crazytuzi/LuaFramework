require "SKGame/Modules/Property/PropertyConst"

PropertyModel =BaseClass(LuaModel)

function PropertyModel:__init()
   self:initData()
   self:Config()
end

function PropertyModel:initData()

 	-- 总战力
 	self.fightPower = 0

 	-- 战力变化差值
 	self.powerDiff = 0

 	self.basicProList = {
 		[1] = {
 			name = "昵称",
 			value = ""
 		},
 		[2] = {
 			name = "等级",
 			value = 0
 		},
 		[3] = {
 			name =  "职业",
 			value = ""
 		},
 		[4] = {
 			name = "公会",
 			value = "",	 
 		}
 	}
end

function PropertyModel:Config()
	
end


--单例模式
function PropertyModel:GetInstance()
	if PropertyModel.Instacne == nil then
		PropertyModel.Instacne = PropertyModel.New()
	end
	return PropertyModel.Instacne
end


function PropertyModel:GetPowerDiff()
	return self.powerDiff
end

function PropertyModel:GetFightPower()
	return self.fightPower
end

function PropertyModel:GetBasicProList()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if playerVo then
		self.basicProList[1].value = playerVo.name
		self.basicProList[2].value = playerVo.level
		self.basicProList[3].value = PropertyConst.JobName[playerVo.career]
		self.basicProList[4].value = ""
	end
 	return self.basicProList
end

function PropertyModel:GetPropList1()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local propList1 = {}
	if not playerVo then
		return propList1
	end
	local temp_teble = SceneModel:GetInstance():GetMainPlayer().player_add_prop_
	local add_prop_value = 0
	for i= 11,16 do
		if temp_teble[i] then
			add_prop_value = temp_teble[i]
		end
	  	local  str = "0"
	  	if add_prop_value == 0 then
	  		str = playerVo[ self:GetPropertyTypeByKey(i) ]
		else
			str = StringFormat("{0}+{1}",playerVo[ self:GetPropertyTypeByKey(i)],add_prop_value)
		end

		table.insert( propList1 , {name = self:GetPropertyNameByKey(i) , value = str} )
	end
	return propList1
end

function PropertyModel:GetPropList2()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local propList2 = {}
	if not propList2 then
		return propList2
	end
	local temp_teble = SceneModel:GetInstance():GetMainPlayer().player_add_prop_
	local add_prop_value = 0
	for i= 11,24 do
		if temp_teble[i] then
			add_prop_value = temp_teble[i]
		end
	  	local  str = "0"
	  	str = StringFormat("{0}+{1}",playerVo[ self:GetPropertyTypeByKey(i)],add_prop_value)
		table.insert( propList2 , {name = self:GetPropertyNameByKey(i) ,  value = str	} )
	end
	return propList2
end

function PropertyModel:__delete()
	self.propList = nil
	PropertyModel.Instacne = nil
end

-- 通过属性键得到解析名
function PropertyModel:GetPropertyNameByKey( key )
	if self:GetCfg(key) then
		return self:GetCfg(key).name or ""
	end
	return ""
end
-- 通过属性键得到属性名
function PropertyModel:GetPropertyTypeByKey( key )
	if self:GetCfg(key) then
		return self:GetCfg(key).type or ""
	end
	return ""
end
-- 配置
function PropertyModel:GetCfg(key)
	return GetCfgData( "proDefine" ):Get(key)
end

function PropertyModel:IsMaxLevel()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	return playerVo and playerVo.level == 100
end