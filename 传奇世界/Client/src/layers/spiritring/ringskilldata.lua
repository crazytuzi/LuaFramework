local ringskilldata = {}
-- require("src/layers/task/parseStr")
local skilllist = {}
local function get_sdata()
	local function StrSplit(str, split)
		local strTab={}
		local sp=split or "&"
		local tb = {}
		while type(str)=="string" and string.len(str)>0 do
			local f=string.find(str,sp)
			local ele
			if f then
				ele=string.sub(str,1,f-1)
				str=string.sub(str,f+1)
			else
				ele=str
			end
			table.insert(tb, ele)
			if not f then break	end
		end
		return tb
	end
	local function parseSkillProp( str )
	-- body
		local props = {}
		local propstr = StrSplit(str,",")
		for _,v in pairs(propstr) do
			local prop = StrSplit(v, "_")
			table.insert(props, prop)
		end
		return props
	end
	local sdata = require("src/config/spiritringSkillDB")
	-- body q_skillID
	local num = #sdata

	for i = 1, num do
		ringskilldata[sdata[i].q_id] = {}
		ringskilldata[sdata[i].q_id].skillid = sdata[i].q_skillID
		ringskilldata[sdata[i].q_id].name = sdata[i].q_name
		ringskilldata[sdata[i].q_id].skilllevel = sdata[i].q_level
		ringskilldata[sdata[i].q_id].starlevel = sdata[i].q_starlevel
		ringskilldata[sdata[i].q_id].luckymax = sdata[i].q_luckycap
		ringskilldata[sdata[i].q_id].updateneed = sdata[i].q_res
		ringskilldata[sdata[i].q_id].skilldes = sdata[i].q_describe
		ringskilldata[sdata[i].q_id].soldier_prop = parseSkillProp(sdata[i].q_soldier_prop)
		ringskilldata[sdata[i].q_id].master_prop = parseSkillProp(sdata[i].q_master_prop)
		ringskilldata[sdata[i].q_id].taoist_prop = parseSkillProp(sdata[i].q_taoist_prop)
	end
	package.loaded["src/config/spiritringSkillDB"] = nil
end
function ringskilldata:init()
	-- body
	get_sdata()
end
function ringskilldata:getList( list )
	-- body
	skilllist = list
end
function ringskilldata:getServerData()
	-- body
	return skilllist
end

return ringskilldata