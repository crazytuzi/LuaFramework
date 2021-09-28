local RidingDressNode = class("RidingDressNode", function() return cc.Node:create() end)

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"
local bag = MPackManager:getPack(MPackStruct.eBag)
local res = "res/layers/role/"
local Mprop = require "src/layers/bag/prop"
----------------------------------------------------------------------------------------------------

function RidingDressNode:ctor(parent, index)
	self.mDressSlot = {}
	self.rideDress = (MPackStruct.eRideDress1 - 1) + index
	local dressBag = MPackManager:getPack(self.rideDress)

	local buildDressSlot = function(dress, id)
		local grid = dress:getGirdByGirdId(id)
		
		local bound = nil
		
		if grid then
			local MequipOp = require "src/config/equipOp"
			local protoId = MPackStruct.protoIdFromGird(grid)
			
			-- 是否可强化判断
			local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
			local quality = MpropOp.quality(protoId, grid)
			local isRUL = MequipOp.isStrengthRUL(protoId, strengthLv, quality)
			local strengthHint = nil
			repeat
				if isRUL then break end
				
				--[[
				-- 13级开启装备强化功能
				local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)
				if roleLv < 11 then break end
				--]]
				local bag = MPackManager:getPack(MPackStruct.eBag)
				local bag_list = bag:categoryList(MPackStruct.eOther)
				
				for i, v in ipairs(bag_list) do
					local protoId = MPackStruct.protoIdFromGird(v)
					if ((strengthLv < 10 and protoId >= 1301 and protoId <= 1310) or (strengthLv >= 10 and protoId >= 1401 and protoId <= 1410)) and G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_STRENGTHEN) then
						strengthHint = "res/layers/equipment/24.png"
						break
					end
				end
			until true
			-----------------------------------------------
			if id == MPackStruct.eMedal then -- 勋章
				local lv = MRoleStruct:getAttr(ROLE_SCHOOL)*1000+strengthLv
				local cost = getConfigItemByKey("honourCfg","q_ID",lv,"q_cost")
				local zq = MRoleStruct:getAttr(PLAYER_VITAL) or 0
				if cost and zq >= cost then
					strengthHint = "res/layers/equipment/25.png"
				end
			end
			-----------------------------------------------
			bound = Mprop.new(
			{
				grid = grid,
				strengthLv = strengthLv,
				hint = strengthHint,
				cb = function(touch, event)
					local Mtips = require "src/layers/bag/tips"
					Mtips.new(
					{
						packId = self.rideDress,
						grid = grid,
					})
				end,
			})
			bound:setContentSize(cc.size(bound:getContentSize().width,80))
		else
			--if id == MPackStruct.eMedal and MRoleStruct:getAttr(ROLE_LEVEL) < 23 then -- 勋章做特殊处理
				--bound = Mprop.new({})
				--bound:setVisible(false)
			--else
				bound = Mprop.new(
				{
					border = "res/common/bg/itemBg.png",
					cb = function(touch, event)
						if #(MPackManager:getEquipList(id)) > 0 then
							AudioEnginer.playTouchPointEffect()
							local Mreloading = require "src/layers/role/reloading"
							local Manimation = require "src/young/animation"
							Manimation:transit(
							{
								ref = getRunScene(),
								node = Mreloading.new(id,self.rideDress),
								sp = g_scrCenter,
								ep = g_scrCenter,
								--trend = "-",
								zOrder = 200,
								curve = "-",
								swallow = true,
							})
						else
							dump("没有可装备的物品")
						end
					end
				})
			--end
			
			Mnode.overlayNode(
			{
				parent = bound,
				{
					node = cc.Sprite:create(res .. "placeholder/" .. id .. ".jpg"),
					zOrder = 1,
				},
			})
			
			
			if #(MPackManager:getEquipList(id)) > 0 then
				Mnode.overlayNode(
				{
					parent = bound,
					nodes = {
						{
							node = Mnode.createLabel(
							{
								src = "+",
								size = 30,
								color = MColor.green,
							}),
							
							origin = "c",
							offset = { x = 0, y = 0 },
							zOrder = 2,
						},
						
						{
							node = Mnode.createLabel(
							{
								src = game.getStrByKey("can")..game.getStrByKey("equipment"),
								size = 16,
								color = MColor.green,
							}),
							
							origin = "lt",
							offset = { x = 7, y = -8 },
							zOrder = 2,
						},
					}
				})
			end
		end
		
		bound.mId = id
		self.mDressSlot[id] = bound
		
		-- 更新人物模型
		--refreshRoleModel(id)
		
		return bound
	end



	local refreshSingleDressSlot = function(id)
		local bound = self.mDressSlot[id]
		if bound then
			local x, y = bound:getPosition()
			local parent = bound:getParent()
			
			removeFromParent(bound)
			bound = nil
			Mnode.addChild(
			{
				parent = parent,
				child = buildDressSlot(id),
				pos = cc.p(x, y),
			})
		end
	end

	local refreshDressSlot = function(id, event)
		refreshSingleDressSlot(id)
		
		if event == "+"  then
			refreshSingleDressSlot(id)
		end
	end

	local onDressChanged = function(observable, event, id, grid)
		dump(event, "event")
		if event == "+" or event == "=" or event == "-" then
			-- 更新着装
			refreshDressSlot(id, event)
		end
	end

	local onItemChanged = function(observable, event, id, grid)
		
		if event == "+" or event == "=" or event == "-" then
			-- 更新着装
			for i = MPackStruct.eRideHead, MPackStruct.eRideTail do
				refreshSingleDressSlot(i)
			end
		end
	end

	local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
		if not isMe or attrId ~= PLAYER_BATTLE then return end
		
		-- 更新战斗力
		--power:refresh()
	end

	local centerX = 253
	local addX = 200
	local startX = centerX - addX
	local startY = 360
	local addY = -95

	for i=MPackStruct.eRideHead,MPackStruct.eRideTail do
		local node = buildDressSlot(dressBag, i)
		local x
		local y
		if i <= MPackStruct.eRideTail/2 then
			x = startX
		else
			log("i = "..i)
			x = startX + 2*addX
		end

		y = startY + (i % (MPackStruct.eRideTail/2))*addY
		self:addChild(node)
		node:setPosition(cc.p(x, y))
	end

	self:registerScriptHandler(function(event)
		local pack = MPackManager:getPack(self.rideDress)
		if event == "enter" then
			pack:register(onDressChanged)
			bag:register(onItemChanged)
			MRoleStruct:register(onDataSourceChanged)
		elseif event == "exit" then
			pack:unregister(onDressChanged)
			bag:unregister(onItemChanged)
			MRoleStruct:unregister(onDataSourceChanged)
		end
	end)
end

return RidingDressNode