local honourData = {}
local propFun = function(v,kind,k,num)
	local tab = {}
	local MPropOp = require "src/config/propOp" 
	local src = ""

	local color = "white"
	if kind == 1 then
		local src = "^c(red)"..game.getStrByKey("notActived").."^"
		if v.q_activeType == 1 then
			src = "^c(green)"..game.getStrByKey("actived").."^"
		end
		tab[#tab+1] = MPropOp.name(v.q_id,k)..src
	elseif kind == 2 and k and num then
		if k == 1001 then
			src = game.getStrByKey("pojun")
		elseif k == 1002 then
			src = game.getStrByKey("rongyao")
		elseif k == 1003 then
			src = game.getStrByKey("wangzhe")
		end

		tab[#tab+1] = "^c(lable_black)"..src.."^".." ".."^c(lable_yellow)"..num.."/3".."^"

		if num < 3 then
			color = "gray"
		end
	end



	if v.q_max_hp then
		src = game.getStrByKey("prop_hp").."^c("..color.. ")"..v.q_max_hp.."^"
		tab[#tab+1] = src
	end
	if v.q_attack_min and v.q_attack_max then
		src = game.getStrByKey("prop_attack1").."^c("..color.. ")"..v.q_attack_min.."~"..v.q_attack_max.."^"
		tab[#tab+1] = src
	end
	if v.q_magic_attack_min and v.q_magic_attack_max then
		src = game.getStrByKey("prop_magicAttack1").."^c("..color.. ")"..v.q_magic_attack_min.."~"..v.q_magic_attack_max.."^"
		tab[#tab+1] = src
	end
	if v.q_sc_attack_min and v.q_sc_attack_max then
		src = game.getStrByKey("prop_scAttack1").."^c("..color.. ")"..v.q_sc_attack_min.."~"..v.q_sc_attack_max.."^"
		tab[#tab+1] = src
	end
	if v.q_defence_min and v.q_defence_max then
		src = game.getStrByKey("prop_defence1").."^c("..color.. ")"..v.q_defence_min.."~"..v.q_defence_max.."^"
		tab[#tab+1] = src
	end
	if v.q_magic_defence_min and v.q_magic_defence_max then
		src = game.getStrByKey("prop_magicDefence1").."^c("..color.. ")"..v.q_magic_defence_min.."~"..v.q_magic_defence_max.."^"
		tab[#tab+1] = src
	end
	if v.q_hit then
		src = game.getStrByKey("prop_hit").."^c("..color.. ")"..v.q_hit.."^"
		tab[#tab+1] = src
	end
	if v.q_dodge then
		src = game.getStrByKey("prop_dodge").."^c("..color.. ")"..v.q_dodge.."^"
		tab[#tab+1] = src
	end
	if v.q_crit then
		src = game.getStrByKey("prop_cirt").."^c("..color.. ")"..v.q_crit.."^"
		tab[#tab+1] = src
	end
	if v.q_tenacity then
		src = game.getStrByKey("prop_tenacity").."^c("..color.. ")"..v.q_tenacity.."^"
		tab[#tab+1] = src
	end
	if v.q_luck then
		src = game.getStrByKey("prop_luck").."^c("..color.. ")"..v.q_luck.."^"
		tab[#tab+1] = src
	end
	if v.q_project then
		src = game.getStrByKey("prop_project").."^c("..color.. ")"..v.q_project.."^"
		tab[#tab+1] = src
	end
	if v.q_projectDef then
		src = game.getStrByKey("prop_projectDef").."^c("..color.. ")"..v.q_projectDef.."^"
		tab[#tab+1] = src
	end
	if v.q_max_mp then
		src = game.getStrByKey("prop_mp").."^c("..color.. ")"..v.q_max_mp.."^"
		tab[#tab+1] = src
	end
	return tab
end


function honourData:init(wenTab,opType)
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	local data = require("src/config/EmblazonryDB")
	honourData.info = {}	
	honourData.suitNum  = {
		[1001] = {{},0},
		[1002] = {{},0},
		[1003] = {{},0},
	}
	for k,v in pairs(data) do
		for m,n in pairs(wenTab) do
			if n[1][2] then
				local act = n[1][2] > 0 and 1 or 0
				if v.q_id == n[1][1] and v.q_job == school and (v.q_activeType == act or (opType and opType == 2 and v.q_activeType == 1)) then
					table.insert(honourData.info,v)
					honourData.suitNum[v.q_suitID][2] = honourData.suitNum[v.q_suitID][2] + 1
				end		
			end			
		end
		if v.q_activeType == 3 and v.q_job == school then
			table.insert(honourData.suitNum[v.q_suitID][1],v)
		end 
	end
	if opType == 3 then
		return honourData.info
	end
	-- dump(honourData.info,"00000000000000000")
	-- dump(honourData.suitNum,"+++++++++++++++++")
	-- honourData:getGoodProp()
	-- honourData:getSuitProp()
end

function honourData:getGoodProp()
	local tab = {}
	for k,v in pairs(honourData.info) do
		local src = propFun(v,1)
		tab[#tab+1] = src
	end
	-- dump(tab,"88888888888888888888888888888")
	return tab
end

function honourData:getSuitProp()
	local tab = {}
	for k,v in pairs(honourData.suitNum) do
		if v[2] > 0 then
			local src = propFun(v[1][1],2,k,v[2])
			tab[#tab+1] = src
		end
	end
	-- dump(tab,"99999999999999999999999999")
	return tab
end

function honourData:getCurProp()
	local tab = {}
	local jihuoNum = 0
	for k,v in pairs(honourData.info) do
		if v.q_activeType == 0 then
			local src = propFun(v,1)
			tab[#tab+1] = src
			jihuoNum = v.q_activeNum
		end
	end
	-- dump(tab,"99999999999999999999999999")
	return tab,jihuoNum
end

function honourData:getActProp()
	local tab = {}
	for k,v in pairs(honourData.info) do
		if v.q_activeType == 1 then
			local src = propFun(v,1)
			tab[#tab+1] = src
		end
	end
	-- dump(tab,"00000000000000000000")
	return tab
end


return honourData