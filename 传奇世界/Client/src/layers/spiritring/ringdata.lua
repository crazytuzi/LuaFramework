local ringdata = {}
local ringlist = {}

function ringdata:init()
	-- body
	local parseSkillProp =  function( str )
		-- body
		local props = {}
		local propstr = stringsplit(str,",")
		for _,v in pairs(propstr) do
			local prop = stringsplit(v, "_")
			table.insert(props, prop)
		end
		return props
	end
	local sdata = require("src/config/spiritring")
	ringdata.rdata = {}
	local num = #sdata
	ringdata.ringnum = num/9
	for i = 1, num do
		ringdata.rdata[sdata[i].q_id] = {}
		ringdata.rdata[sdata[i].q_id].id = sdata[i].q_id
		ringdata.rdata[sdata[i].q_id].name = sdata[i].q_name
		ringdata.rdata[sdata[i].q_id].level = sdata[i].q_level
		ringdata.rdata[sdata[i].q_id].text = sdata[i].q_describe
		ringdata.rdata[sdata[i].q_id].need1 = sdata[i].q_plan
		ringdata.rdata[sdata[i].q_id].need2 = sdata[i].q_item
		ringdata.rdata[sdata[i].q_id].need3 = sdata[i].q_item_two
		ringdata.rdata[sdata[i].q_id].soldier_prop = parseSkillProp(sdata[i].q_soldier_prop)
		ringdata.rdata[sdata[i].q_id].master_prop = parseSkillProp(sdata[i].q_master_prop)
		ringdata.rdata[sdata[i].q_id].taoist_prop = parseSkillProp(sdata[i].q_taoist_prop)
	end
	package.loaded["src/config/spiritring"] = nil
end

function ringdata:setRingList( data )
	-- body getConfigItemByKey
	ringlist = data
end

function ringdata:getServerData( ... )
	-- body
	return ringlist
end

function ringdata:getNeedDayData(id)
	--神戒解锁签到天数
	local needday = {
			   [1]="1",
			   [2]="2",
			   [3]="7",
			   [4]="15",
			   [5]="25"
			 }

	if id and needday[id] then
		return tonumber(needday[id])
	end

	return needday
end

return ringdata