local m_bDirect = false
local m_oDirect = nil

local bagItemChanged = function(observable, event, pos, pos1, gird)
	log("bagItemChanged")
	
	if observable then
		--背包已满
		if observable:numOfGirdRemain() == 0 then
			if G_MAINSCENE then
				G_MAINSCENE:createBagNoticeNode()
			end

			local pack = MPackManager:getPack(MPackStruct.eBag)
			--dump(pack:numOfGirdOpened())
			--dump(pack:maxNumOfGirdCanOpen())
			if pack:numOfGirdOpened() < pack:maxNumOfGirdCanOpen() then
				--开启扩展背包的引导
				-- if G_TUTO_DATA then
				-- 	for k,v in pairs(G_TUTO_DATA) do
				-- 		if v.q_id == 47 then
				-- 			if v.q_state == TUTO_STATE_HIDE then
				-- 				v.q_state = TUTO_STATE_OFF
				-- 			end
				-- 		end
				-- 	end
				-- end
				tutoShow(47,true)
			end
		else
			if G_MAINSCENE then
				G_MAINSCENE:removeBagNoticeNode()
			end
		end
	end

	--startTimerAction(G_MAINSCENE, 0.0, false, function() 
	if event == "+" or event == "=" then
		if MPackStruct.categoryFromGird(gird) == MPackStruct.eEquipment then
			local Mconvertor = require "src/config/convertor"
			-- --当前新装备战斗力
			local battleNew = MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower)
			print("battleNew = "..battleNew)
			-- --新装备类型
			local protoId = MPackStruct.protoIdFromGird(gird)
			local girdId = MPackStruct.girdIdFromGird(gird)
			-- local kind = require("src/config/equipOp").kind(protoId)
			-- print("0000000000000000000000000000000000000000000000000000")
			--是否职业可用
			local school = require("src/config/propOp").schoolLimits(protoId)
			local level = require("src/config/propOp").levelLimits(protoId)
			local sex = require("src/config/propOp").sexLimits(protoId)
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local selfSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
			local selfLevel = MRoleStruct:getAttr(ROLE_LEVEL)
			local selfSex = MRoleStruct:getAttr(PLAYER_SEX)

			if school ~= selfSchool then
				log("school error")
				return
			end

			if selfLevel < level then
				log("level error")
				return
			end

			if selfSex ~= sex and sex ~= 0 then
				log("sex error")
				return
			end
			local isgoon = true
			for k,v in pairs(G_SETPOSTEMPE) do
				local girdId1 = MPackStruct.girdIdFromGird(v[1])
				local newKind = require("src/config/equipOp").kind(protoId)
				local oldProtoid=MPackStruct.protoIdFromGird(v[1])
				local oldKind = require("src/config/equipOp").kind(oldProtoid)
				if newKind==oldKind then
					--相同类型的装备，把战斗力高的放在前面
					local battleOld = MPackStruct.attrFromGird(v[1], MPackStruct.eAttrCombatPower)
					if battleNew>battleOld then
						local old=v
						G_SETPOSTEMPE[k]={gird,false}
						isgoon = false
						if Mconvertor.eCuff==newKind or newKind==Mconvertor.eRing then
							table.insert(G_SETPOSTEMPE,old)
						end
						break
					end
				end
				if girdId == girdId1 then
					isgoon = false
					break
				end
			end
			if isgoon and G_MAINSCENE then
				--print("加入立即装备")
				table.insert(G_SETPOSTEMPE,{gird,false})
				if #G_SETPOSTEMPE <= 1 then
					local func = function()
						-- if G_SETPOSTEMPE[1][1] and G_SETPOSTEMPE[1][2] then
							equipTip(G_SETPOSTEMPE[1][1],G_SETPOSTEMPE[1][2])
						-- end
					end
					performWithDelay( G_MAINSCENE , func , 0.03 )
				end 
			end
		end
	end

	--end)
end

function equipTip(gird,specialForEquip)
	local dressPack = MPackManager:getPack(MPackStruct.eDress)
	local bagPack = MPackManager:getPack(MPackStruct.eBag)
	local replaceGirdId = nil
	local replaceGirdBattle = nil
	--当前新装备战斗力
	local battleNew = MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower)
	--print("equipTips当前新装备战斗力"..battleNew)
	--新装备类型
	local protoId = MPackStruct.protoIdFromGird(gird)
	local kind = require("src/config/equipOp").kind(protoId)
	local suitTemp = true
	for i=MPackStruct.eWeapon, MPackStruct.eMedal do
		log("i = "..i)
		--如果是同一装备位置
		if MPackStruct.equipId(i) == kind then
			suitTemp = true
			log("test 1")
			local dressGird = dressPack:getGirdByGirdId(i)
			local battleOld

			--dressGird = nil 表明该格子没装备任何东西
			if dressGird == nil then
				log("dressGird = nil")
				battleOld = 0
			else
				--套装检测
				local MequipOp = require "src/config/equipOp"
				local Mconvertor = require "src/config/convertor"
				local protoIdOld = MPackStruct.protoIdFromGird(dressGird)
				local isSuit = MequipOp.isSuit(protoIdOld)
				-- print(isSuit,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
				if isSuit then
					if kind ~= Mconvertor.eRing and kind ~= Mconvertor.eCuff then
					-- 	table.remove(G_SETPOSTEMPE,1)
					-- 	G_MAINSCENE:setEquip()
					-- 	return
						break													
					else
						suitTemp = false
					-- 	break
					end
				end

				battleOld = MPackStruct.attrFromGird(dressGird, MPackStruct.eAttrCombatPower)
			end
			-- print(battle,battleOld,"bbbbbbbbbbbbbbbbbbbbbbbbbbbb")
			--如果新装备战斗力比老装备战斗力高
			if battleNew > battleOld and suitTemp then
				--如果有几个老装备对应同一个位置则选择战斗力最低的替换
				if replaceGirdId == nil then
					log("test 7")
					replaceGirdId = i
					replaceGirdBattle = battleOld
				else
					if battleOld < replaceGirdBattle then
						log("test 8")
						replaceGirdId = i
						replaceGirdBattle = battleOld
					end
				end
			end
		end
	end
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local girdId = MPackStruct.girdIdFromGird(gird)
	local girdTemp1 = pack:getGirdByGirdId(girdId)
	if girdTemp1 ~= gird then
		replaceGirdId = nil
	end 
	if replaceGirdId ~= nil then
		local addBattle = battleNew - replaceGirdBattle
		if m_bDirect then
			m_oDirect = {0,2,6,nil,{gird=gird, replaceGirdId = replaceGirdId, addBattle=addBattle, battle=battleNew}}
		else
			require("src/layers/tuto/AutoConfigNode").new(0,2,6,nil,{gird=gird, replaceGirdId = replaceGirdId, addBattle=addBattle, battle=battleNew},nil,specialForEquip)
		end
	else
		table.remove(G_SETPOSTEMPE,1)
		-- removeFromParent(self)
		G_MAINSCENE:setEquip()		
	end
end

--清空缓存
function clearDirect( ... )
	-- body
	m_oDirect = nil
end

--设置提示立即装备tip重定向
function setEquipRedirect( bDirect )
	-- body
	m_bDirect = bDirect
end

--处罚存储的tip
function trigEquipRedirect( ... )
	-- body
	m_bDirect = false
	print("trigEquipRedirect", m_oDirect)
	if m_oDirect then
		require("src/layers/tuto/AutoConfigNode").new(m_oDirect[1],m_oDirect[2],m_oDirect[3],m_oDirect[4],m_oDirect[5])
	end
end

return bagItemChanged