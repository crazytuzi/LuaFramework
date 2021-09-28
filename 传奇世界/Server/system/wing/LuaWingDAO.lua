--LuaWingDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaWingDAO.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: 光翼数据池
 -------------------------------------------------------------------*/
--]]
require "data.WingDB"

--------------------------------------------------------------------------------
LuaWingDAO = class(nil, Singleton)

function LuaWingDAO:__init()
	self._staticWings = {}
    self._staticSkills = {}

	--加载所有的光翼原型
	local wingDBs = require "data.WingDB"
	for _, record in pairs(wingDBs or table.empty) do
		self._staticWings[record.q_ID] = record
	end

	--加载所有的光翼技能原型
	local skillDBs = require "data.WingSkillDB"
	for _, record in pairs(skillDBs or table.empty) do
		table.insert(self._staticSkills, record)
	end
end


--根据光翼ID取数据
function LuaWingDAO:getPrototype(sID)
	if sID then
		return self._staticWings[sID]
	end
end

--根据光翼ID取数据
function LuaWingDAO:getSkillDB(pos, level)
	for _, v in pairs(self._staticSkills) do
		if tonumber(v.q_pos) == pos and tonumber(v.q_level) == level then
			return v
		end
	end
end

function LuaWingDAO.getInstance()
	return LuaWingDAO()
end