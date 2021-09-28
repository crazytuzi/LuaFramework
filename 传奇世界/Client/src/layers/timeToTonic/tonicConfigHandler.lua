local tonicConfigHandler = {}
local remindTonic1,remindTonic3,remindTonic5 = 0,0,0
local remindTonic2,remindTonic4,remindTonic6 = 0,0,0

local messageBox = nil

local function tonicConfig(temp,npc_node)
	 -- 1 与 2 
		remindTonic2 = os.time()
		remindTonic4 = os.time()
		remindTonic6 = os.time()
		-- print(remindTonic1,remindTonic2,"11111111111111111111111")
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local MRoleStruct = require("src/layers/role/RoleStruct")
		local lv = MRoleStruct:getAttr(ROLE_LEVEL)
		local pack = MPackManager:getPack(MPackStruct.eBag)
		local mpTab = {}
		local hpTab = {}
		local hpTabShort = {}
		-------------------------------------- 锄 ---点击矿洞使用，不检测背包的-------------------------------------------------
		if temp == 2 and npc_node then
			local propName = 0
			local buffTemp = 0
			local num4 = pack:countByProtoId(1129)	  --银锄
			local levelLimit4 = getConfigItemByKey("propCfg","q_id",1129,"q_level")

			if g_buffs_ex[G_ROLE_MAIN.obj_id] then
				for key,v in pairs(g_buffs_ex[G_ROLE_MAIN.obj_id]) do       --查看是否有该锄buff
					if key == 32 then --or key == 33 or key == 109
						buffTemp = 2
						break
					end
				end
			end
			if buffTemp ~= 2 and lv >= levelLimit4 and num4 == 0 then
				if G_MAINSCENE:getChildByTag(9933) == nil then
					local messageBox = MessageBoxYesNoEx(nil, game.getStrByKey("digmineTip"), function() 
						__GotoTarget( { ru = "a12" } )
					end, nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
					messageBox:setTag(9933)
				end
			end
		end


		----------------------------------------1是蓝补，10是红补--------------------------------------------------

		local function eatDrug(isDrug,drugNum)
			if (not getRunScene():getChildByTag(517)) and isDrug then
				-- require("src/layers/tuto/AutoConfigNode").new(drugNum,1,0,517)
				if G_MAINSCENE and not G_MAINSCENE.prop_cds[drugNum] then
					require("src/layers/tuto/AutoConfigNode").new(drugNum,1,0,517)
					G_MAINSCENE:doPropAction(drugNum,true)
				end
			end
		end
		local function callFun(drugNum,idex)
			local isDrug = true
			-- if getGameSetById(GAME_SET_ID_AUTO_USE_ITEM) == 0 then
			-- 	if temp == 10 and 3 ~= tonumber(G_DRUG_HP[idex][1]) then
			-- 		isDrug = false
			-- 	elseif temp == 1 and 3 ~= tonumber(G_DRUG_MP[idex][1]) then
			-- 		isDrug = false
			-- 	end
			-- end
			eatDrug(isDrug,drugNum)
		end
		local function isType(idex)
			if g_buffs_ex[G_ROLE_MAIN.obj_id] then
				for key,v in pairs(g_buffs_ex[G_ROLE_MAIN.obj_id]) do       --查看是否有该药buff
					if temp == 1 and key == tonumber(mpTab[idex][3]) then
						return false
					elseif temp == 10 and key == tonumber(hpTab[idex][3]) then
						return false
					elseif temp == 100 and key == tonumber(hpTabShort[idex][3]) then
						return false
					end
				end
			end
			return true
		end
		local function callEatDrug(num)
			local tempTab = {}
			for k,v in pairs(num) do
				local temp = v					
				while temp > 9 do
					table.insert(tempTab,math.floor(temp%100))
					temp = temp/100
				end
			end
			return tempTab
		end
		if temp == 1 and remindTonic2 - remindTonic1 >= 3 then
			remindTonic1 = remindTonic2
			local propName = 0
			local idex = 0
			if not G_DRUG_MP then
				haveDrug()--1
			end
			-- local mpTab = {}
			local setDrug = {}

			table.insert(setDrug,getGameSetById(GAME_DEFAULT_DRUG_LONG_MP))
			local setDrug1 = callEatDrug(setDrug)
			for k,v in pairs(G_DRUG_MP) do
				for i,j in pairs(setDrug1) do
					if v[4] == (j+20000) then
						table.insert(mpTab,v)
						break
					end
				end
			end

			local mpDrugNum = {}
			for i=1,#mpTab do
				table.insert(mpDrugNum,{pack:countByProtoId(mpTab[i][4]),getConfigItemByKey("propCfg","q_id",mpTab[i][4],"q_level")})		
			end

			if #mpDrugNum == #mpTab then
				for i = 1,#mpTab do
					if mpDrugNum[i][1] == 0 and lv >= mpDrugNum[i][2] then
						G_MAINSCENE:buyDrug(mpTab[i][4],true)
					end
					if mpDrugNum[i][1] > 0 and lv >= mpDrugNum[i][2] then
						local checkType = isType(i)
						if checkType then
							propName = mpTab[i][4]
							idex = i
							break
						end
					end					
				end 
				if propName ~= 0 and idex ~= 0 then
					callFun(propName,idex)
				end
			end
		end
		if temp == 10 and remindTonic4 - remindTonic3 >= 3 then
			remindTonic3 = remindTonic4
			local propName = 0
			local idex = 0
			if not G_DRUG_HP then
				haveDrug()--1
			end
			-- local hpTab = {}
			local setDrug = {}

			table.insert(setDrug,getGameSetById(GAME_DEFAULT_DRUG_LONG_HP))
			local setDrug1 = callEatDrug(setDrug)
			for k,v in pairs(G_DRUG_HP) do
				for i,j in pairs(setDrug1) do
					if v[4] == (j+20000) then
						table.insert(hpTab,v)
						break
					end
				end
			end

			local mpDrugNum = {}
			for i=1,#hpTab do
				table.insert(mpDrugNum,{pack:countByProtoId(hpTab[i][4]),getConfigItemByKey("propCfg","q_id",hpTab[i][4],"q_level")})		
			end

			if #mpDrugNum == #hpTab then
				for i = 1,#hpTab do
					if mpDrugNum[i][1] == 0 and lv >= mpDrugNum[i][2] then
						G_MAINSCENE:buyDrug(hpTab[i][4],true)
					end
					if mpDrugNum[i][1] > 0 and lv >= mpDrugNum[i][2] then
						local checkType = isType(i)
						if checkType then
							propName = hpTab[i][4]
							idex = i
							break
						end
					end
				end 
				if propName ~= 0 and idex ~= 0 then
					callFun(propName,idex)
				end
			end
		end
		if temp == 100 and remindTonic6 - remindTonic5 >= 3 then
			remindTonic5 = remindTonic6
			local propName = 0
			local idex = 0
			if not G_DRUG_HP_SHORT then
				haveDrug()--1
			end
			-- local hpTabShort = {}
			local setDrug = {}

			table.insert(setDrug,getGameSetById(GAME_DEFAULT_DRUG_SHORT_HP))
			local setDrug1 = callEatDrug(setDrug)
			for k,v in pairs(G_DRUG_HP_SHORT) do
				for i,j in pairs(setDrug1) do
					if v[4] == (j+20000) then
						table.insert(hpTabShort,v)
						break
					end
				end
			end

			local mpDrugNum = {}
			for i=1,#hpTabShort do
				table.insert(mpDrugNum,{pack:countByProtoId(hpTabShort[i][4]),getConfigItemByKey("propCfg","q_id",hpTabShort[i][4],"q_level")})		
			end

			if #mpDrugNum == #hpTabShort then
				for i = 1,#hpTabShort do
					if mpDrugNum[i][1] == 0 and lv >= mpDrugNum[i][2] then
						G_MAINSCENE:buyDrug(hpTabShort[i][4],true)
					end
					if mpDrugNum[i][1] > 0 and lv >= mpDrugNum[i][2] then
						local checkType = isType(i)
						if checkType then
							propName = hpTabShort[i][4]
							idex = i
							break
						end
					end
				end 
				if propName ~= 0 and idex ~= 0 then
					callFun(propName,idex)
				end
			end
		end
end

function tonicConfigHandler:tonicInit(theNum,npc_node)
	tonicConfig(theNum,npc_node)
end

return tonicConfigHandler
