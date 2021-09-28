return { new = function()
local MpropOp = require "src/config/propOp"
local Mnumber = require "src/component/number/view"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local dress = MPackManager:getPack(MPackStruct.eDress)
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local root = Mnode.createColorLayer(
{
	src = cc.c4b(0 ,0 ,0, 0),
	--src = cc.c4b(244 ,164 ,96, 255*0.5),
	cSize = cc.size(492, 499),
})
local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
mDressSlot = {}
mNumberBuilder = Mnumber.new("res/component/number/10.png")
-----------------------------------------------------------------------

local roleModel = createRoleNode(MRoleStruct:getAttr(ROLE_SCHOOL),g_normal_close_id, nil, nil,1.0,MRoleStruct:getAttr(PLAYER_SEX))
--local wingModel = buildRoleNode(PLAYER_EQUIP_WING)
--local headModel = buildRoleNode(1)
--local weaponModel = buildRoleNode(PLAYER_EQUIP_WEAPON)
-----------------------------------------------------------------------
local refreshRoleModel = function(id, grid)
	--dump("refreshRoleModel")
	--dump(id, "dressId")
	--dump(grid, "dressItem")
	
	local dressSlot = root.mDressSlot[id]
	local grid = dress:getGirdByGirdId(id)
	if not roleModel then
		return 
	end
	local r_size = roleModel:getContentSize()
	--local close_effect_tab = {[5010508]=true}
	if grid then
		assert(id == grid.mGirdSlot)
		local sex = MRoleStruct:getAttr(PLAYER_SEX)
		local protoId = MPackStruct.protoIdFromGird(grid)
		if id == MPackStruct.eClothing then
			local dress = roleModel:getChildByTag(PLAYER_EQUIP_UPPERBODY)
			if dress then
				local w_resId = MpropOp.equipResId(protoId)
				dress:setTexture("res/showplist/role/"..w_resId.."/"..sex..".png")

-----------------------------------------------------------------------
				local futil = cc.FileUtils:getInstance()
				local bCurFilePopupNotify = false
				if isWindows() then
					bCurFilePopupNotify = futil:isPopupNotify()
					futil:setPopupNotify(false)
				end
				local close_effect = roleModel:getChildByTag(1234)
				local effect_str = "myifu_"..w_resId
				if sex == 2 then
					effect_str = "fyifu_"..w_resId
				end
				if futil:isFileExist("res/effectsplist/"..effect_str .. "@0.plist") then
					if not close_effect then
						close_effect =  Effects:create(false)
						close_effect:setPosition(cc.p(1,-7))
			            roleModel:addChild(close_effect,1,1234)
			            addEffectWithMode(close_effect,2)
					end
					close_effect:playActionData2(effect_str,180,-1,0)
				elseif close_effect then
					roleModel:removeChildByTag(1234)
				end

				if isWindows() then
					futil:setPopupNotify(bCurFilePopupNotify)
				end
-----------------------------------------------------------------------
			end
		elseif id == MPackStruct.eWeapon then
			local w_resId = MpropOp.equipResId(protoId)
			local weapon = roleModel:getChildByTag(PLAYER_EQUIP_WEAPON)
			if weapon then
				weapon:setTexture("res/showplist/weapon/"..w_resId..".png")
			else
				local weapon = createSprite(roleModel,"res/showplist/weapon/"..w_resId..".png",cc.p(-70,50))
				if weapon then weapon:setTag(PLAYER_EQUIP_WEAPON) end
			end
		-----------------------------------------------------------------------
			local futil = cc.FileUtils:getInstance()
			local bCurFilePopupNotify = false
			if isWindows() then
				bCurFilePopupNotify = futil:isPopupNotify()
				futil:setPopupNotify(false)
			end
			local wuqi_effect = roleModel:getChildByTag(1235)
			local effect_str = "wuqi_"..w_resId
			if futil:isFileExist("res/effectsplist/"..effect_str .. "@0.plist") then
				if not wuqi_effect then
					wuqi_effect =  Effects:create(false)
					wuqi_effect:setPosition(cc.p(-70,50))
		            roleModel:addChild(wuqi_effect,1,1235)
		            addEffectWithMode(wuqi_effect,1)
				end
				wuqi_effect:playActionData2(effect_str,180,-1,0)
			elseif wuqi_effect then
				roleModel:removeChildByTag(1235)
			end

			if isWindows() then
				futil:setPopupNotify(bCurFilePopupNotify)
			end
-----------------------------------------------------------------------
		else 
			if G_WING_INFO.id and (G_WING_INFO.id > 0) and G_WING_INFO.state == 1 then 
				local wing = roleModel:getChildByTag(PLAYER_EQUIP_WING)
				local wing_id = getConfigItemByKey("WingCfg","q_ID",G_WING_INFO.id,"q_senceSouceID") or 1
				if wing then
					wing:setTexture("res/showplist/wing/"..(wing_id%10)..".png")
				else
					local wing_posx = 20
					--if sex == 2 then wing_posx = 0 end
					local wing = createSprite(roleModel,"res/showplist/wing/"..(wing_id%10)..".png",cc.p(wing_posx,50))
					if wing then 
						wing:setTag(PLAYER_EQUIP_WING)
						wing:setLocalZOrder(-1) 
					end
				end
			end
		end
	else
		if id == MPackStruct.eClothing then
			local dress = roleModel:getChildByTag(PLAYER_EQUIP_UPPERBODY)
			if dress then
				local w_resId = g_normal_close_id -- MpropOp.equipResId(protoId)
				local sex = MRoleStruct:getAttr(PLAYER_SEX)
				dress:setTexture("res/showplist/role/"..w_resId.."/"..sex..".png")
				if roleModel:getChildByTag(1234) then
					roleModel:removeChildByTag(1234)
				end
			end
		elseif id == MPackStruct.eWeapon then
			roleModel:removeChildByTag(PLAYER_EQUIP_WEAPON)
			if roleModel:getChildByTag(1235) then
				roleModel:removeChildByTag(1235)
			end
		end
	end
end

local buildDressSlot = function(id)
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
				if id == MPackStruct.eMedal then -- 勋章做特殊处理
					local onlyMedalUpdate = true  --勋章开关
					if onlyMedalUpdate then
						local proId = MPackStruct.protoIdFromGird(grid)
						local school = MpropOp.schoolLimits(proId)
						local layer = require("src/layers/role/honourLayer").new(strengthLv,school,true,grid)
						Manimation:transit(
						{
							ref = getRunScene(),
							node = layer,
							curve = "-",
							sp = cc.p(0, 0),
							zOrder = 200,
							--tag = 100+i,
							swallow = true,
						})
					else
						local Mtips = require "src/layers/bag/tips"
						Mtips.new(
						{
							packId = MPackStruct.eDress,
							grid = grid,
							hadEquipMedal = true,
						})
					end
				else
					local Mtips = require "src/layers/bag/tips"
					Mtips.new(
					{
						packId = MPackStruct.eDress,
						grid = grid,
					})
				end
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
							node = Mreloading.new(id),
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
	root.mDressSlot[id] = bound
	
	-- 更新人物模型
	refreshRoleModel(id)
	
	return bound
end

local tSpecialSlot = {
	[MPackStruct.eCuffLeft] = MPackStruct.eCuffRight,
	[MPackStruct.eCuffRight] = MPackStruct.eCuffLeft,
	[MPackStruct.eRingLeft] = MPackStruct.eRingRight,
	[MPackStruct.eRingRight] = MPackStruct.eRingLeft,
}

local refreshSingleDressSlot = function(id)
	local bound = root.mDressSlot[id]
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
	
	if event == "+" and tSpecialSlot[id] then
		refreshSingleDressSlot(tSpecialSlot[id])
	end
end
-----------------------------------------------------------------------
Mnode.overlayNode(
{
	parent = root,
	nodes = {
		-- 角色名
		{
			node = Mnode.overlayNode(
			{
				parent = cc.Sprite:create(res .. "24.png"),
				{
					node = Mnode.createLabel(
					{
						src = MRoleStruct:getAttr(ROLE_NAME),
						size = 20,
						color = MColor.lable_yellow,
					}),
					
					origin = "b",
					offset = { y = 6, },
				}
			}),
			origin = "t",
			offset = { y = -5, },
		},
		-- 人物模型
		{
			node = roleModel,
			origin = "c",
			offset = { x = 0, y = 10, },
		},				
		-- 左列装备
		{
			node = Mnode.combineNode(
			{
				nodes = 
				{
					--buildDressSlot(10),
					buildDressSlot(7),
					buildDressSlot(5),
					--buildDressSlot(2),
					--buildDressSlot(1),
				},
				
				ori = "|",
				margins = 20,
			}),
			
			origin = "l",
			offset = { x = 10, y = -48, },
		},

		-- 右列装备
		{
			node = Mnode.combineNode(
			{
				nodes = 
				{
					buildDressSlot(11),
					buildDressSlot(8),
					buildDressSlot(6),
					buildDressSlot(4),
					buildDressSlot(3),
				},
				
				ori = "|",
				margins = 20,
			}),
			
			origin = "r",
			offset = { x = -5, y = 4, },
		},
		
		{
			node = Mnode.combineNode({
				nodes = 
				{
					buildDressSlot(1),
					buildDressSlot(2),
					buildDressSlot(12),
					buildDressSlot(10),
					--buildDressSlot(9),
				},

				margins = 20,
			}),
			
			origin = "b",
			offset = { x = -47, y = 13, },
		},
	},
})
-----------------------------------------------------------------------
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
		for i = MPackStruct.eWeapon, MPackStruct.eMedal do
			refreshSingleDressSlot(i)
		end
	end
end

local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if not isMe or attrId ~= PLAYER_BATTLE then return end
	
	-- 更新战斗力
	--power:refresh()
end

local toAchievement = function()
	local layer = require("src/layers/achievement/AchievementAndTitleLayer").new()
	Manimation:transit(
	{
		ref = G_MAINSCENE,
		node = layer,
		curve = "-",
		sp = cc.p(0, 0),
		zOrder = 200,
		--tag = 100+i,
		swallow = true,
	})
end
---local achievementBtn = createMenuItem(root, "res/achievement/1.png", cc.p(90, 45), toAchievement)
--G_TUTO_NODE:setTouchNode(achievementBtn, TOUCH_ROLE_ACHIEVEMENT)

local on_event_arrive = function(m, dress, pos, info)
	local bound = root.mDressSlot[pos]
	if bound and bound.red_dot then
		bound.red_dot:setVisible(info and true or false)
	end
end

root:registerScriptHandler(function(event)
	local pack = MPackManager:getPack(MPackStruct.eDress)
	--local Mred_dot = require "src/layers/role/red_dot"
	if event == "enter" then
		pack:register(onDressChanged)
		bag:register(onItemChanged)
		--Mred_dot:register(on_event_arrive)
		MRoleStruct:register(onDataSourceChanged)
		G_TUTO_NODE:setShowNode(root, SHOW_ROLE)
	elseif event == "exit" then
		pack:unregister(onDressChanged)
		bag:unregister(onItemChanged)
		--Mred_dot:unregister(on_event_arrive)
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)
-----------------------------------------------------------------------
G_TUTO_NODE:setTouchNode(root, TOUCH_ROLE_EQUIPMENT)
G_TUTO_NODE:setTouchNode(root, TOUCH_ROLE_WEAPON)
G_TUTO_NODE:setTouchNode(root, TOUCH_ROLE_MEDAL)
G_TUTO_NODE:setTouchNode(root, TOUCH_ROLE_SHOES)
return root
end }