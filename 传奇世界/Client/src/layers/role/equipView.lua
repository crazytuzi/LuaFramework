return { new = function(dressLocation)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MProcessBar = require "src/layers/role/ProcessBar"
local MObserver = require "src/young/observer"
local Mbaseboard = require "src/functional/baseboard"
local Mtips = require "src/layers/bag/tips"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	
	close = {
		src = "res/component/button/7.png",
	},
})
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_EQUIPMENT_CLOSE)

local M = Mnode.beginNode(root)
-----------------------------------------------------------------------
local dress = MPackManager:getPack(MPackStruct.eDress)
local grid = dress:getGirdByGirdId(dressLocation)

local info = dress:girdInfo(dressLocation, {
	MPackStruct.eAttrQuality,
	MPackStruct.eAttrStrengthLevel,
	MPackStruct.eAttrStrengthExp,
	MPackStruct.eAttrStarLevel,
	MPackStruct.eAttrBind,
	MPackStruct.eAttrCombatPower,
})

info.oldGrid = grid
info.grid = grid
-----------------------------------------------------------------------
local buildTitle = function(title)
	return Mnode.overlayNode(
	{
		parent = cc.Sprite:create(res .. "55.png"),
		{
			node = cc.Sprite:create(title),
		}
	})
end
-----------------------------------------------------------------------
local add_red_dot = function(node, cond)
	local red_dot = cc.Sprite:create("res/component/flag/red.png")
	Mnode.overlayNode(
	{
		parent = node,
		{
			node = red_dot,
			origin = "rt",
			zOrder = 15,
		}
	})
	node.red_dot = red_dot
	
	node.refresh = function(node)
		local Mred_dot = require "src/layers/role/red_dot"
		local info = Mred_dot:query(dressLocation)
		node.red_dot:setVisible(not not (info and (info[cond])))
	end
	
	node:refresh()
end

-----------------------------------------------------------------------
-- 装备强化
-- 底板
local UpStrengthBg = cc.Sprite:create(res .. "53.png")

-- 强化等级和上限
local strengthLevel = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "强化上限：",
		size = 22,
		color = MColor.yellow,
	}),
	
	v = {
		src = "100/100",
		size = 22,
		color = MColor.yellow,
	},
	
	margin = 5,
})

local strengthExp = MProcessBar.new(
{
	bg = res .. "58.png",
	bar = res .. "59.png",
})

local upStrengthBtn = MMenuButton.new(
{
	src = "res/component/button/4.png",
	label = {
		src = "强化",
		size = 20,
	},
	cb = function()
		local protoId = info.protoId
		local level =  info.attrs[MPackStruct.eAttrStrengthLevel]
		local exp = info.attrs[MPackStruct.eAttrStrengthExp]
		local upgradeExp = MequipOp.upStrengthExpNeed(protoId, level)
		local quality = info.attrs[MPackStruct.eAttrQuality]
		local strengthLvUpper = MequipOp.upQualityStrengthUL(protoId, quality)
		
		if level >= strengthLvUpper and exp >= upgradeExp then
			TIPS( { type = 1 , str = "^c(green)已经达到强化极限, 请先提升装备品质^" } )
			return
		end
		
		local MupStrength = require "src/layers/role/upStrength"
		local parent = root:getParent()
		local pos = parent:convertToNodeSpace(g_scrCenter)
		Mnode.addChild(
		{
			parent = parent,
			child = MupStrength.new(root, info),
			swallow = true,
			pos = pos,
		})
	end,
})
G_TUTO_NODE:setTouchNode(upStrengthBtn, TOUCH_EQUIPMENT_STRENGTHEN)

Mnode.overlayNode(
{
	parent = UpStrengthBg,
	nodes = {
		{
			node = strengthLevel,
			origin = "l",
			offset = { x = 0, y = 20, },
		},
		
		{
			node = strengthExp,
			origin = "l",
			offset = { x = 0, y = -20, },
		},
		
		{
			node = upStrengthBtn,
			origin = "r",
			offset = { x = 0, y = 0, },
		},
	}
})

local updateUpStrengthArea = function(info)
	local attrs = info.attrs
	
	local level = attrs[MPackStruct.eAttrStrengthLevel]
	local exp = attrs[MPackStruct.eAttrStrengthExp]
	local protoId = info.protoId
	local upgradeExp = MequipOp.upStrengthExpNeed(protoId, level)
	local quality = attrs[MPackStruct.eAttrQuality]
	local strengthLvUpper = MequipOp.upQualityStrengthUL(protoId, quality)

	strengthLevel:setValue(level .. "/" .. strengthLvUpper)
	
	strengthExp:setProgress(
	{
		cur = exp,
		max = MequipOp.isStrengthRUL(protoId, level) and 1 or upgradeExp,
	})
end; updateUpStrengthArea(info)
-----------------------------------------------------------------------
-- 品质进阶
-- 底板
local UpQualityBg = cc.Sprite:create(res .. "53.png")

local isUpQualityMaterialEnough = nil

local upQualityBtn = MMenuButton.new(
{
	src = "res/component/button/4.png",
	label = {
		src = "进阶",
		size = 20,
	},
	
	cb = function()
		-- 在此判断是否能够进阶
		local quality = info.attrs[MPackStruct.eAttrQuality]
		if MequipOp.isQualityRUL(quality) then
			TIPS( { type = 1 , str = "^c(green)品质等级已经达到上限^" } )
			return
		elseif not isUpQualityMaterialEnough then
			TIPS( { type = 1 , str = "^c(green)材料不足^" } )
			return
		end
		
		local MConfirmBox = require "src/functional/ConfirmBox"
		local box = MConfirmBox.new(
		{
			handler = function(box)
				MPackManager:upQualityEquip(dressLocation)
				if box then box:removeFromParent() box = nil end
			end,
			
			builder = function(box)
				local quality = info.attrs[MPackStruct.eAttrQuality]
				local cost = MequipOp.upQualityCoinNeed(info.protoId, quality)
				return Mnode.createLabel(
				{
					src = "是否花费" .. cost .. "游戏币提升品质？",
					color = MColor.white,
					size = 20,
				})
			end,
		})
	end,
})
add_red_dot(upQualityBtn:getButton(), "canUpQuality")
G_TUTO_NODE:setTouchNode(upQualityBtn, TOUCH_EQUIPMENT_ADVANCE)

Mnode.overlayNode(
{
	parent = UpQualityBg,
	nodes = {
		{
			node = upQualityBtn,
			origin = "r",
			offset = { x = 0, y = 0, },
		},
	}
})

local buildUpQualityNode = function(info)
	
	local qualityLevel = info.attrs[MPackStruct.eAttrQuality]
	
	if MequipOp.isQualityRUL(qualityLevel) then
		return Mnode.createLabel(
		{
			src = "品质等级已经达到上限",
			size = 22,
			color = MColor.green,
		})
	end
	
	-- 消耗材料
	local upgradeCost = MequipOp.upQualityMaterialNeed(info.protoId, qualityLevel)
	
	local qualityCostNodes = {}
	
	isUpQualityMaterialEnough = true
	
	for i = 1, #upgradeCost do
		local material = upgradeCost[i]
		
		local protoId = material.protoId

		local pack = MPackManager:getPack(MPackStruct.eBag)
		local num = pack:countByProtoId(protoId)
		
		local enough = num >= material.num
		isUpQualityMaterialEnough = isUpQualityMaterialEnough and enough
		
		local icon = Mnode.combineNode(
		{
			nodes = {
				Mprop.new(
				{
					protoId = protoId,
					bg = "res/common/23.png",
					cb = "tips",
				}),
				
				Mnode.combineNode(
				{
					nodes = {
						Mnode.createKVP(
						{
							k = Mnode.createLabel(
							{
								src = num .. "/" .. material.num,
								color = MColor.white,
								size = 18,
							}),
							
							v = cc.Sprite:create( res .. (enough and "g.png" or "x.png") ),
							
							margin = 10,
						}),
						
						Mnode.createLabel(
						{
							src = MpropOp.name(protoId),
							color = MpropOp.nameColor(protoId),
							size = 18,
						}),
					},
					
					ori = "|",
					align = "l",
					margins = 15,
				}),
			},
			
			margins = 5,
		})
		
		qualityCostNodes[i] = icon
	end
	
	return Mnode.combineNode(
	{
		nodes = qualityCostNodes,
		margins = 5,
	})
end

local updateUpQualityArea = function(info)
	local node = UpQualityBg:getChildByTag(1)
	if node then node:removeFromParent() end
	
	Mnode.overlayNode(
	{
		parent = UpQualityBg,
		{
			node = buildUpQualityNode(info),
			origin = "l",
			tag = 1,
		}
	})
	
end; updateUpQualityArea(info)
-----------------------------------------------------------------------
-- 装备晋级
-- 底板
local UpLevelBg = cc.Sprite:create(res .. "54.png")

--local UpLevelStrengthCondition = { result = nil, threshold = nil, }
local UpLevelMaterialCondition = { result = nil, threshold = nil, }
local UpLevelQualityCondition = { result = nil, threshold = nil, }
local UpLevelRoleLevelCondition = { result = nil, threshold = nil, }

local upLevelBtn = MMenuButton.new(
{
	src = "res/component/button/4.png",
	label = {
		src = "晋级",
		size = 20,
	},
	cb = function()
		-- 在此判断能否升级
		local reachUpperLimit = MequipOp.isLevelRUL(info.protoId)
	
		if reachUpperLimit or not MequipOp.upLevelMaterialNeed(info.protoId)[1] then
			TIPS({ type = 1 , str = "已达最大等级" })
			return
		end
		
		--if UpLevelStrengthCondition.result then
			--TIPS( { type = 1 , str = "^c(green)装备强化等级需要达到" .. UpLevelStrengthCondition.threshold .. "级^" } )
		if UpLevelMaterialCondition.result then
			TIPS( { type = 1 , str = "^c(green)材料不足^" } )
		elseif UpLevelQualityCondition.result then
			TIPS( { type = 1 , str = "^c(green)装备品质等级需要达到" .. UpLevelQualityCondition.threshold .. "^" } )
		elseif UpLevelRoleLevelCondition.result then
			TIPS( { type = 1 , str = "^c(green)角色等级需要达到" .. UpLevelRoleLevelCondition.threshold .. "级^" } )
		else
			local MConfirmBox = require "src/functional/ConfirmBox"
			local box = MConfirmBox.new(
			{
				handler = function(box)
					MPackManager:upLevelEquip(dressLocation)
					if box then box:removeFromParent() box = nil end
				end,
				
				builder = function(box)
					local cost = MequipOp.upLevelCoinNeed(info.protoId)
					return Mnode.createLabel(
					{
						src = "是否花费" .. cost .. "游戏币升级装备？",
						color = MColor.white,
						size = 20,
					})
				end,
			})
		end
	end,
})
add_red_dot(upLevelBtn:getButton(), "canUpLevel")
G_TUTO_NODE:setTouchNode(upLevelBtn, TOUCH_EQUIPMENT_LEVELUP)

Mnode.overlayNode(
{
	parent = UpLevelBg,
	nodes = {
		{
			node = upLevelBtn,
			origin = "r",
			offset = { x = 0, y = 0, },
		},
	}
})

local updateUpLevelArea = function(info)
	local node = UpLevelBg:getChildByTag(1)
	if node then node:removeFromParent() end

	local upLevelArea = nil
	
	local level = MpropOp.levelLimits(info.protoId)
	local reachUpperLimit = MequipOp.isLevelRUL(info.protoId)
	
	if reachUpperLimit or not MequipOp.upLevelMaterialNeed(info.protoId)[1] then
		upLevelArea = Mnode.createLabel(
		{
			src = "已达最大等级",
			size = 20,
			color = MColor.red,
		})
	else
		local upLevelQualityNeed = MequipOp.upLevelQualityNeed(info.protoId)
		local qualityInfo = MequipOp.qualityInfo(upLevelQualityNeed)
		local isUpLevelQualityNeedFail = info.attrs[MPackStruct.eAttrQuality] < upLevelQualityNeed
		UpLevelQualityCondition.result = isUpLevelQualityNeedFail
		UpLevelQualityCondition.threshold = qualityInfo.name .. qualityInfo.level
		
		--[[
		local upLevelStrengthNeed = MequipOp.upLevelStrengthNeed(info.protoId)
		local isUpLevelStrengthNeedFail = info.attrs[MPackStruct.eAttrStrengthLevel] < upLevelStrengthNeed
		UpLevelStrengthCondition.result = isUpLevelStrengthNeedFail
		UpLevelStrengthCondition.threshold = upLevelStrengthNeed
		]]
		
		local upLevelMaterialNeed = MequipOp.upLevelMaterialNeed(info.protoId)[1]
		local bag = MPackManager:getPack(MPackStruct.eBag)
		local isUpLevelMaterialNeedFail = bag:countByProtoId(upLevelMaterialNeed.protoId) < upLevelMaterialNeed.num
		UpLevelMaterialCondition.result = isUpLevelMaterialNeedFail
		UpLevelMaterialCondition.threshold = nil
		
		local evolveId = MequipOp.evolve(info.protoId)
		local evolveIdLv =  MpropOp.levelLimits(evolveId)
		local isRoleLevelNeedFail = evolveIdLv > MRoleStruct:getAttr(ROLE_LEVEL)
		UpLevelRoleLevelCondition.result = isRoleLevelNeedFail
		UpLevelRoleLevelCondition.threshold = evolveIdLv
		
		
		local obj, line = nil, nil
		obj, line = createLinkLabel(nil, MpropOp.name(upLevelMaterialNeed.protoId) .. "x" .. upLevelMaterialNeed.num,
		cc.p(0, 0), cc.p(0.5, 0.5), 20, nil, nil,
		MpropOp.nameColor(upLevelMaterialNeed.protoId), nil,
		function()
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{
				protoId = upLevelMaterialNeed.protoId,
				pos = obj:getParent():convertToWorldSpace( cc.p(obj:getPosition()) ),
			})
		end, true)
		
		upLevelArea = Mnode.combineNode(
		{
			nodes = 
			{
				Mnode.combineNode(
				{
					nodes = 
					{
						Mnode.createLabel(
						{
							src = "(3) 角色等级达到" .. evolveIdLv .. "级",
							size = 20,
							color = MColor.white,
						}),
						
						cc.Sprite:create( res .. (isRoleLevelNeedFail and "x.png" or "g.png") ),
					},
					margins = 10,
				}),
				
				Mnode.combineNode(
				{
					nodes = 
					{
						Mnode.createLabel(
						{
							src = "(2) 装备品质达到" .. qualityInfo.name .. qualityInfo.level,
							size = 20,
							color = MColor.white,
						}),
						
						cc.Sprite:create( res .. (isUpLevelQualityNeedFail and "x.png" or "g.png") ),
					},
					
					margins = 10,
				}),
				
				--[[
				Mnode.combineNode(
				{
					nodes = 
					{
						Mnode.createLabel(
						{
							src = "(1) 强化等级达到" .. upLevelStrengthNeed .. "级",
							size = 20,
							color = MColor.white,
						}),
						
						cc.Sprite:create( res .. (isUpLevelStrengthNeedFail and "x.png" or "g.png") ),
					},
					
					margins = 10,
				}),
				]]
				
				Mnode.combineNode(
				{
					nodes = 
					{
						Mnode.combineNode(
						{
							nodes = 
							{
								Mnode.createLabel(
								{
									src = "(1) ",
									size = 20,
									color = MColor.white,
								}),
								
								Mnode.combineNode(
								{
									nodes = 
									{
										line,
										obj,
									},
									
									ori = "|",
									margins = -15,
								}),
							},

							margins = 0,
						}),
						
						cc.Sprite:create( res .. (isUpLevelMaterialNeedFail and "x.png" or "g.png") ),
					},
					
					margins = 10,
				}),
				
				
			},
			
			ori = "|",
			margins = 0,
			align = "l",
		})
	end
	
	Mnode.overlayNode(
	{
		parent = UpLevelBg,
		{
			node = upLevelArea,
			origin = "l",
			tag = 1,
		}
	})
end; updateUpLevelArea(info)
-----------------------------------------------------------------------
-- 更换|附魔|升星
-- 底板
local ButtonBg = cc.Sprite:create(res .. "56.png")

local upStarBtn = MMenuButton.new(
{
	src = "res/component/button/9.png",
	label = {
		src = "升星",
		size = 20,
	},
	cb = function()
		-- 在此判断是否已经达到最大星级
		if info.attrs[MPackStruct.eAttrStarLevel] < 5 then
			local MupStar = require "src/layers/role/upStar"
			local parent = root:getParent()
			local pos = parent:convertToNodeSpace(g_scrCenter)
			Mnode.addChild(
			{
				parent = parent,
				child = MupStar.new(root, info),
				swallow = true,
				pos = pos,
			})
		else
			TIPS( { type = 1 , str = "^c(green)已经达到最大星级^" } )
		end
	end,
})
add_red_dot(upStarBtn:getButton(), "canUpStar")

Mnode.overlayNode(
{
	parent = ButtonBg,
	{
		node = Mnode.combineNode(
		{
			nodes = 
			{
				[1] = MMenuButton.new(
				{
					src = "res/component/button/10.png",
					label = {
						src = "更换",
						size = 20,
					},
					cb = function()
						
						local Mreloading = require "src/layers/role/reloading"
						local parent = root:getParent()
						local pos = parent:convertToNodeSpace(g_scrCenter)
						Mnode.addChild({
							parent = parent,
							child = Mreloading.new(info.girdId),
							swallow = true,
							pos = pos,
						})
						
						if root then root:removeFromParent() root = nil end
					end,
				}),
				
				[2] = MMenuButton.new(
				{
					src = "res/component/button/9.png",
					label = {
						src = "附魔",
						size = 20,
					},
					cb = function()
						TIPS({ type = 1  , str = "功能开发中" })
					end,
				}),
				
				[3] = upStarBtn,
			},
			
			margins = 20,
		}),
		
		offset = { x = 0, y = -5 },
	}
})
-----------------------------------------------------------------------
Mnode.overlayNode(
{
	parent = root,
	nodes = 
	{
		{
			-- 装备tips
			node = Mtips.new(
			{
				grid = grid,
				static = true,
			}),
			
			origin = "l",
			offset = { x = 10, y = -35 },
		},
		
		{
			-- 分隔线
			node = cc.Sprite:create(res .. "57.png"),
			origin = "c",
			offset = { x = -83, y = -35 },
		},
		
		{
			-- 功能区
			node = Mnode.combineNode(
			{
				nodes = {
					ButtonBg,
					UpLevelBg,
					buildTitle(res .. "36.png"),
					UpQualityBg,
					buildTitle(res .. "35.png"),
					UpStrengthBg,
					buildTitle(res .. "34.png"),
				},
				
				ori = "|",
			}),
			
			origin = "r",
			offset = { x = -10, y = -35 },
		},
	}
})
-----------------------------------------------------------------------
local tObservable = MObserver.new()
-- 监听[着装属性数据]
listen = function(self, observer)
	tObservable:register(observer)
end

-- 取消监听[着装属性数据]
nolisten = function(self, observer)
	tObservable:unregister(observer)
end

local update_grid = function()
	info.oldGrid = grid
	grid = dress:getGirdByGirdId(dressLocation)
	info.grid = grid
end

local update = function(observable, event, girdId, item)
	
	if girdId ~= dressLocation then return end
	
	if event == "upStrength" then
		update_grid()
		
		MPackStruct.attrsFromGird(grid, {
			MPackStruct.eAttrStrengthLevel,
			MPackStruct.eAttrStrengthExp,
			MPackStruct.eAttrCombatPower,
		}, info.attrs)
		
		updateUpStrengthArea(info)
		updateUpLevelArea(info)
		
		tObservable:broadcast(root, event)
	elseif event == "upQuality" then
		update_grid()
		
		-- 保存原来的战斗力
		info.oldPower = info.attrs[MPackStruct.eAttrCombatPower]
		
		MPackStruct.attrsFromGird(grid, {
			MPackStruct.eAttrQuality,
			MPackStruct.eAttrCombatPower,
		}, info.attrs)
		
		updateUpStrengthArea(info)
		updateUpQualityArea(info)
		updateUpLevelArea(info)
		
		local MupQuality = require "src/layers/role/upQuality"
		local parent = root:getParent()
		local pos = parent:convertToNodeSpace(g_scrCenter)
		Mnode.addChild(
		{
			parent = parent,
			child = MupQuality.new(root, info),
			swallow = true,
			pos = pos,
		})
		
		tObservable:broadcast(root, event)
	elseif event == "upStar" then
		update_grid()
		
		-- 保存原来的战斗力
		info.oldPower = info.attrs[MPackStruct.eAttrCombatPower]
		
		MPackStruct.attrsFromGird(grid, {
			MPackStruct.eAttrStarLevel,
			MPackStruct.eAttrCombatPower,
		}, info.attrs)
		
		tObservable:broadcast(root, event)
	elseif event == "upLevel" then
		update_grid()
		
		-- 更新装备原型
		info.oldProtoId = info.protoId
		info.protoId = MPackStruct.protoIdFromGird(grid)
		
		-- 保存原来的战斗力
		info.oldPower = info.attrs[MPackStruct.eAttrCombatPower]
		
		MPackStruct.attrsFromGird(grid, {
			MPackStruct.eAttrCombatPower,
		}, info.attrs)
		
		updateUpQualityArea(info)
		updateUpLevelArea(info)
		
		local MupLevelSucceed = require "src/layers/role/upLevelSucceed"
		local parent = root:getParent()
		local pos = parent:convertToNodeSpace(g_scrCenter)
		Mnode.addChild(
		{
			parent = parent,
			child = MupLevelSucceed.new(root, info),
			swallow = true,
			pos = pos,
		})
		
		tObservable:broadcast(root, event)
	end
	
end

local on_event_arrive = function(m, dress, pos, info)
	if pos == dressLocation then
		upQualityBtn:getButton():refresh()
		upStarBtn:getButton():refresh()
		upLevelBtn:getButton():refresh()
	end
end

root:registerScriptHandler(function(event)
	local Mred_dot = require "src/layers/role/red_dot"
	if event == "enter" then
		dress:register(update)
		Mred_dot:register(on_event_arrive)
		G_TUTO_NODE:setShowNode(root, SHOW_EQUIPMENT)
	elseif event == "exit" then
		dress:unregister(update)
		Mred_dot:unregister(on_event_arrive)
	end
end)
-----------------------------------------------------------------------
return root
end }