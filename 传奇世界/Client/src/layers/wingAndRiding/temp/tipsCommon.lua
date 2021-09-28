--Author:		bishaoqing
--DateTime:		2016-05-11 16:48:36
--Region:		道具tip

local EquipCompare = require("src/layers/bag/EquipCompare")

local tLabel = {
	dress = game.getStrByKey("equipment"),
	undress = game.getStrByKey("remove_equipment"),
	put = game.getStrByKey("put_warehouse"),
	get = game.getStrByKey("get"),
	sell = game.getStrByKey("sell"),
	use = game.getStrByKey("use"),
	compound = game.getStrByKey("compound"),
	batch_use = game.getStrByKey("batch")..game.getStrByKey("use"),
	share = game.getStrByKey("share"),
	drop_out = game.getStrByKey("drop_out"),
	strengthen = game.getStrByKey("strengthen"),
	lineage = game.getStrByKey("lineage"),
	change = game.getStrByKey("change"),
	refine = game.getStrByKey("refine"),
	blessing = game.getStrByKey("blessing"),
	go_use = game.getStrByKey("use"),
	go_npc = game.getStrByKey("use"),
	gold_pointing = game.getStrByKey("gold_pointing"),
	texturePic = game.getStrByKey("texturePic"),
	update = game.getStrByKey("my_upgrade"),
}

local tSpecialItem = {
	[333333] = true, -- 荣誉
	[444444] = true, -- 经验
	[999998] = true, -- 金币
	[999999] = true, -- 绑定金币
	[777777] = true, -- 真气
	[888888] = true, -- 礼金
	[222222] = true, -- 元宝
	[111111] = true, -- 帮贡
	[2001] = true, -- 金砖
	[2002] = true, -- 金条
}

local isSpecialItem = function(protoId)
	return tSpecialItem[protoId]
end

local tAction = {
	-- 上装
	dress = function(params, self)
		AudioEnginer.playEffect("sounds/uiMusic/ui_weapon.mp3",false)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		local dressId = nil
		if self and self.stCurComparedGrid_ and self.stCurComparedGrid_.grid then
			--dressId = self.stCurComparedGrid_.grid.mGirdSlot
		end
		local  desBag = nil
		local MpropOp = require "src/config/propOp"
		local protoId = MPackStruct.protoIdFromGird(grid)
		if MpropOp.category(protoId) == MPackStruct.eRideEquipment then
			desBag = (MPackStruct.eRideDress1 - 1) + G_RIDING_INFO.index
			if not (desBag >= MPackStruct.eRideDress1 and desBag <= MPackStruct.eRideDress10) then
				TIPS( { type = 1 , str = game.getStrByKey("wr_equipment_error") }  )
				return
			end
		end
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
			MPackManager:dress(girdId, dressId, desBag)
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 下装
	undress = function(params, self)
		AudioEnginer.playEffect("sounds/uiMusic/ui_weapon.mp3",false)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
			MPackManager:undress(girdId,packId)
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 从背包放入仓库
	put = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
			MPackManager:swapBetweenGird(MPackStruct.eBag, girdId, MPackStruct.eBank)
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 从仓库放入背包
	get = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
			MPackManager:swapBetweenGird(MPackStruct.eBank, girdId, MPackStruct.eBag)
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 出售背包中的物品
	sell = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
			MPackManager:sell(girdId, MPackStruct.overlayFromGird(grid))
			getRunScene():addChild(require("src/layers/bag/SellView").new(),200)
			-- local Manimation = require "src/young/animation"
			-- Manimation:transit(
			-- {
			-- 	node = require("src/layers/bag/SellView").new(),
			-- 	sp = g_scrCenter,
			-- 	curve = "-",
			-- 	zOrder = 200,
			-- 	swallow = true,
			-- })
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 使用背包中的物品
	use = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local girdId = MPackStruct.girdIdFromGird(grid)
		if girdId then
		
			local protoId = MPackStruct.protoIdFromGird(grid)
			local MpropOp = require "src/config/propOp"
			local cate = MpropOp.category(protoId)
			dump(MpropOp.category(protoId))
			
			-- 使用(坐骑、光翼、战刃、战甲)类技能书道具
			if protoId >= 4000 and protoId <= 4095 then
				local useFunc = function()
					MPackManager:useByGirdId(girdId)
				end
				local text_str = "^c(red)"..game.getStrByKey("learn_skill_book_warn") .. "^\n"..game.getStrByKey("learn_skill_book_tips")
				--MessageBoxYesNoEx(nil,text_str,fbFunc,lotteryFunc,nil,nil,true)
				MessageBoxYesNoEx(nil,text_str,useFunc,nil)
            elseif protoId == 6200024 then  --神仙醉
                g_msgHandlerInst:sendNetDataByTableExEx(GIVEWINE_CS_DRINK, "DrinkWineProtocol", {slotIndex=girdId})
			elseif protoId == 1080 then
				--穿支箭
				MessageBoxYesNo(nil,game.getStrByKey("arrow_text1"),
					function() 
						g_msgHandlerInst:sendNetDataByTableExEx( SPILLFLOWER_CS_CALLMEMBER , "CallFactionMemProtocol", { slotIndex = girdId } )
					end,
					function() 
					end ,
					game.getStrByKey("sure"),game.getStrByKey("cancel") )	
			elseif cate == 21 then
				local t = {}
				t.dwBagSlot = girdId
				g_msgHandlerInst:sendNetDataByTable(ITEM_CS_MOVE_TO_MOUNT_BAG, "ItemMountMoveToMountBagProtocol", t)
				dump(t)
			else
				MPackManager:useByGirdId(girdId)
			end
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 合成物品
	compound = function(params)
		local root = params.root
		local grid = params.grid
        __GotoTarget({ ru = "a201", protoId = grid.mPropProtoId })
		removeFromParent(root:getParent())
	end,
	
	-- 批量使用
	batch_use = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local Mprop = require "src/layers/bag/prop"
		local MpropOp = require "src/config/propOp"
		
		local protoId = MPackStruct.protoIdFromGird(grid)
		local gridId = MPackStruct.girdIdFromGird(grid)
		local num = MPackStruct.overlayFromGird(grid)
		-------------------------------------------------
		local MChoose = require("src/functional/ChooseQuantity")
		MChoose.new(
		{
			title = game.getStrByKey("batch")..game.getStrByKey("use"),
			config = { sp = 1, ep = num, cur = num },
			builder = function(box, parent)
				local cSize = parent:getContentSize()
				
				box:buildPropName(MPackStruct:buildGirdFromProtoId(protoId))
				
				-- 物品图标
				local icon = Mprop.new(
				{
					protoId = protoId,
					--cb = "tips",
				})
				
				Mnode.addChild(
				{
					parent = parent,
					child = icon,
					pos = cc.p(70, 264),
				})
				
				box.icon = icon
			end,
			
			handler = function(box, value)
				MPackManager:useByGirdId(gridId, value)
				if box then removeFromParent(box) box = nil end
			end,
			
			onValueChanged = function(box, value)
				box.icon:setOverlay(value)
			end,
		})
		-------------------------------------------------
		removeFromParent(root:getParent())
	end,
	
	-- 装备分享
	share = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		removeFromParent(root:getParent())
		
		local MpropOp = require "src/config/propOp"
		
		local protoId = MPackStruct.protoIdFromGird(grid)
		local globalGirdId = MPackStruct.girdIdFromGird(grid)
		local isSpecial = MPackStruct.isSpecialFromGird(grid)
		local name = MpropOp.name(protoId)
		local qualityId = MpropOp.quality(protoId, grid)

		--cclog("protoId"..protoId.."name"..name.."globalGirdId"..globalGirdId.."isSpecial"..tostring(isSpecial))
		local str="^l("..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(globalGirdId).."~"..tostring(userInfo.currRoleStaticId).."~"..os.time().."~"..tostring(packId)..")^"
		__removeAllLayers()

		local runScene
		runScene = G_MAINSCENE

        runScene.chatLayer =runScene.base_node:getChildByTag(305)
        if runScene.chatLayer == nil or tolua.cast(runScene.chatLayer, "cc.Node") == nil then
	   		local chatLayer = require("src/layers/chat/Chat").new()
	   		runScene.chatLayer = chatLayer
	   		runScene.base_node:addChild(chatLayer)
	   		chatLayer:setLocalZOrder(200)
	   		chatLayer:setTag(305)
	   		-- chatLayer:setAnchorPoint(cc.p(0, 0))
	   		-- chatLayer:setPosition(cc.p(0, 0))
		else
			runScene.chatLayer:show()
		end
        runScene.chatLayer:selectTab(2)
		runScene.chatLayer:sendLinkData(str)
	end,
	
	-- 装备掉落
	drop_out = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local protoId = MPackStruct.protoIdFromGird(grid)
		local MquipSource = require "src/layers/equipment/equipSource"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			ref = getRunScene(),
			node = MquipSource.new(protoId),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
	end,
	
	-- 装备强化
	strengthen = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local MequipStrengthen = require "src/layers/equipment/equipStrengthen"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			node = MequipStrengthen.new({ packId = packId, grid = grid, }),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
	end,
	
	-- 装备传承
	lineage = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		-- 装备强化等级
		local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	
		if strengthLv < 1 then
			TIPS({ type = 1  , str = game.getStrByKey("lineage_tips") })
			return
		end
		
		local MequipInherit = require "src/layers/equipment/equipInherit"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			node = MequipInherit.new(
			{
				packId = packId,
				grid = grid,
			}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
		
		removeFromParent(root:getParent())
	end,
	
	-- 装备换装
	change = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local Mreloading = require "src/layers/role/reloading"
		local Manimation = require "src/young/animation"
		local girdId = MPackStruct.girdIdFromGird(grid)
		Manimation:transit(
		{
			node = Mreloading.new(girdId),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
		
		performWithDelay(root, function()
			removeFromParent(root:getParent())
		end, 0.0)
		
	end,
	
	-- 装备洗练
	refine = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		Mrefine = require "src/layers/equipment/equipRefine"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			ref = getRunScene(),
			node = Mrefine.new({packId=packId, grid=grid}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			maskTouch = true,
		})
		
		removeFromParent(root:getParent())
	end,
	
	-- 装备祝福
	blessing = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		MequipWish = require "src/layers/equipment/equipWish"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			ref = getRunScene(),
			node = MequipWish.new({packId=packId, grid=grid}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
		
		removeFromParent(root:getParent())
	end,
	
	-- 前往使用
	go_use = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local MpropOp = require "src/config/propOp"
		local protoId = MPackStruct.protoIdFromGird(grid)
		local goUse = MpropOp.goUse(protoId)
		-- dump(goUse, "goUse")
		if not goUse or goUse == "" then
			TIPS({ str = "不能前往", type = 1 })
		else
			__GotoTarget({ ru = goUse })
		end
		
		removeFromParent(root:getParent())
	end,
	
	-- 前往npc使用
	go_npc = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		local MpropOp = require "src/config/propOp"
		local protoId = MPackStruct.protoIdFromGird(grid)
		local goNpcUse = MpropOp.goToNPC(protoId)
		dump(goNpcUse, "goNpcUse")
		if goNpcUse then
			__removeAllLayers()
			local endNpc = goNpcUse
			local targetAddr = __NpcAddr( endNpc )
			targetAddr.targetType = 1
			targetAddr.q_endnpc = endNpc
			__TASK:findPath( targetAddr )
		else
			removeFromParent(root:getParent())
		end
	end,
	
	-- 装备点金
	gold_pointing = function(params)
		local root = params.root
		local grid = params.grid
		local packId = params.packId
		
		MequipGold = require "src/layers/equipment/equipGold"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			ref = getRunScene(),
			node = MequipGold.new({packId=packId, grid=grid}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
		
		removeFromParent(root:getParent())
	end,

	--勋章纹理
	texturePic = function(params)
		local root = params.root
		local layer = require("src/layers/honour/honourSet").new(params)
		Manimation:transit(
		{
			ref = getRunScene(),
			node = layer,
			curve = "-",
			sp = cc.p(0, 0),
			zOrder = 200,
			swallow = true,
		})
		removeFromParent(root:getParent())
	end,

	--勋章升级
	update = function(params)
		local root = params.root
		local grid = params.grid
		local MpropOp = require "src/config/propOp"
		local proId = MPackStruct.protoIdFromGird(grid)
		local school = MpropOp.schoolLimits(proId)
		local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		local layer = require("src/layers/role/honourLayer").new(strengthLv,school,true,grid)
		Manimation:transit(
		{
			ref = getRunScene(),
			node = layer,
			curve = "-",
			sp = cc.p(0, 0),
			zOrder = 200,
			swallow = true,
		})
		removeFromParent(root:getParent())
	end,
}

local buildActBtn = function(record, act_params, self)
	if record == nil then return end
	
	local MMenuButton = require "src/component/button/MenuButton"
	
	local btn = nil
	local action = tAction[record]
	if action then
		btn = MMenuButton.new(
		{
			--src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
			src = {"res/component/button/50.png", "res/component/button/50_sel.png", },
			label = {
				src = tLabel[record],
				size = 22,
				color = MColor.lable_yellow,
			},
			
			cb = function(tag, node)
				action(act_params, self)
			end,
		})
		if record == "use" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_USE)
		elseif record == "strengthen" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_STRENGTHEN)
		elseif record == "compound" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_COMPOUND)
		elseif record == "refine" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_WASH)
		elseif record == "blessing" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_WISH)
		elseif record == "dress" then
			G_TUTO_NODE:setTouchNode(btn ,TOUCH_TIP_DRESS)
		end
	elseif type(record) == "table" then
		btn = MMenuButton.new(
		{
			--src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
			src = {"res/component/button/50.png", "res/component/button/50_sel.png", },
			label = {
				src = record.label or "未设置",
				size = 22,
				color = MColor.lable_yellow,
			},
			
			cb = function()
				if type(record.cb) == "function" then record.cb(act_params) end
				removeFromParent(act_params.root:getParent())
			end,
		})
	end
	
	return btn
end

local tipsCommon = class("tipsCommon", function( ... )
	-- body
	return cc.Sprite:create()
end)
local Mmisc = require "src/young/util/misc"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local MMenuButton = require "src/component/button/MenuButton"
function tipsCommon:ctor(params)
	
	--------------------------------------------------------
	if type(params) ~= "table" then return end
	--------------------------------------------------------
	local dress = MPackManager:getPack(MPackStruct.eDress)
	--------------------------------------------------------
	local size = 20
	local color = MColor.lable_yellow
	--------------------------------------------------------
	local root = self
	local sFilePath = "res/common/bg/tips1.png"
	GetUIHelper():LoadSprTexture(root, sFilePath)
	local rootSize = root:getContentSize()
	--------------------------------------------------------
	self.params_ = params

	-- 包裹id
	local packId = params.packId
	
	local grid = Mmisc:getValue(params, "grid", MPackStruct:buildGirdFromProtoId(params.protoId))
	
	local gridId = MPackStruct.girdIdFromGird(grid)
	
	-- 原型ID
	local protoId = MPackStruct.protoIdFromGird(grid)
	
	-- 是否是勋章
	local isMedal = protoId >= 30004 and protoId <= 30006
	-- 类型
	local cate = MPackStruct.categoryFromGird(grid)

	local isRideEquip=MpropOp.category(protoId)==MPackStruct.eRideEquipment
	-- 是否是装备类型
	local isEquip =not isRideEquip and not isMedal and cate == MPackStruct.eEquipment
	


	local isWeapon = isEquip and MequipOp.kind(protoId) == MPackStruct.eWeapon

	local isRide = cate == MPackStruct.eRide
	
	-- 是否是套装
	local isSuit = MequipOp.isSuit(protoId)
	local isRide =  MpropOp.category(protoId)==21
	-- 是否绑定
	local isBind = nil
	if params.isBind ~= nil then
		isBind = params.isBind
	else
		isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	end
	
	-- 使用职业
	local school = MpropOp.schoolLimits(protoId)
	
	-- 使用性别
	local sex = MpropOp.sexLimits(protoId)
	
	-- 物品等级
	local level = MpropOp.levelLimits(protoId)
	
	-- 过期时间
	local expiration = MPackStruct.attrFromGird(grid, MPackStruct.eAttrExpiration)
	
	-- 装备强化等级
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	
	-- 装备战斗力
	local power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)
	
	-- 物品品质
	local quality = MpropOp.quality(protoId, grid)
	
	--------------------------------------------------------
	-- 更新数据
	local act_params = { root = root, grid = grid, packId = packId }
	local reloadData = function(gridObj)
		if gridObj == nil then return end
		
		grid = gridObj
		act_params.grid = grid
		
		--local new_gridId = MPackStruct.girdIdFromGird(grid)
		--if new_gridId ~= gridId then return end
		
		strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)
	end
	--------------------------------------------------------
	-- 物品名字
	Mnode.createLabel(
	{
		parent = root,
		src = MpropOp.name(protoId),
		color = color,
		anchor = cc.p(0, 0.5),
		pos = cc.p(26, 496),
		size = size,
	})
	
	-- 是否绑定
	Mnode.createLabel(
	{
		parent = root,
		-- src = isBind and (game.getStrByKey("already")..game.getStrByKey("theBind")) or (game.getStrByKey("not")..game.getStrByKey("theBind")),
		src = isBind and (game.getStrByKey("already")..game.getStrByKey("theBind")) or "",
		color = isBind and MColor.red or MColor.green,
		anchor = cc.p(0, 0.5),
		pos = cc.p(215, 496),
		size = size,
	})
	
	-- 物品等级
	local n_level = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = "LV.",
			size = size,
			color = color,
		}),
		
		v = {
			src = tostring(level),
			size = size,
			color = (MRoleStruct:getAttr(ROLE_LEVEL) or 1) >= level and MColor.green or MColor.red,
		},
	})
	
	Mnode.addChild(
	{
		parent = root,
		child = n_level,
		anchor = cc.p(0, 0.5),
		pos = cc.p(290, 496),
	})
	
	-- 物品图标
	local icon = Mprop.new(
	{
		grid = grid,
		strengthLv = strengthLv,
	})

	Mnode.addChild(
	{
		parent = root,
		child = icon,
		pos = cc.p(68, 428),
	})
	
	-- 使用职业
	local n_school = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("school").."：",
			size = size,
			color = color,
		}),
		
		v = {
			src = Mconvertor:school(school),
			size = size,
			color = (school~= Mconvertor.eWhole and school ~= MRoleStruct:getAttr(ROLE_SCHOOL)) and  MColor.red or MColor.green,
		},
	})

	-- 使用性别
	local n_sex = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("sex").."：",
			size = size,
			color = color,
		}),
		
		v = {
			src = Mconvertor:sexName(sex),
			size = size,
			color = (sex ~= Mconvertor.eSexWhole and sex ~= MRoleStruct:getAttr(PLAYER_SEX)) and  MColor.red or MColor.green,
		},
	})

	local n_school_pos = cc.p(136, 445)
	local n_sex_pos = cc.p(136, 410)
	
	local n_power = nil
	if isEquip or isMedal or isRideEquip then
		n_school_pos = cc.p(116, 455)
		n_sex_pos = cc.p(116, 430)
		-- 装备类型
		Mnode.createLabel(
		{
			parent = root,
			src = game.getStrByKey("cate").."："..Mconvertor:equipName(MequipOp.kind(protoId)),
			color = color,
			size = size,
			anchor = cc.p(0, 0.5),
			pos = cc.p(116, 405),
		})
		
		-- 装备战斗力
		local n_power_bg = Mnode.createSprite(
		{
			parent = root,
			src = "res/tips/tipsFightBg.png",
			child = n_power_bg,
			pos = cc.p(290, 424),
		})
		
		local n_power_bg_size = n_power_bg:getContentSize()
		
		n_power = Mnode.createKVP(
		{
			k = Mnode.createLabel(
			{
				src = game.getStrByKey("combat_power"),
				size = 25,
				color = color,
			}),
			
			v = {
				src = tostring(power), -- 10000000
				color = MColor.white,
				size = 22,
			},
			
			ori = "|",
			margin = 5,
		})
		
		Mnode.addChild(
		{
			parent = n_power_bg,
			child = n_power,
			pos = cc.p(n_power_bg_size.width/2, n_power_bg_size.height/2+10),
		})
	end
	
	Mnode.addChild(
	{
		parent = root,
		child = n_school,
		anchor = cc.p(0, 0.5),
		pos = n_school_pos,
	})
	
	Mnode.addChild(
	{
		parent = root,
		child = n_sex,
		anchor = cc.p(0, 0.5),
		pos = n_sex_pos,
	})
	
	--------------------------------------------------------
	-- 售价和叠加数量
	if not isSpecialItem(protoId) then
        self.uiPriceBg_ = createSprite(root, "res/tips/tipsBg.png", cc.p(root:getContentSize().width / 2, 110))
		-- 出售价格
		local n_price = Mnode.createKVP(
		{
			k = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = game.getStrByKey("single_price") .. ": ",
						color = color,
						size = size,
					}),
					
					Mnode.createSprite(
					{
						src = "res/group/currency/1.png",
						scale = 0.55,
					}),
				},
			}),
			
			v = {
				src = MpropOp.recyclePrice(protoId),
				color = color,
				size = size,
			},
			
			margin = 10,
		})
		
		Mnode.addChild(
		{
			parent = root,
			child = n_price,
			anchor = cc.p(0, 0.5),
			pos = cc.p(25, 110),
		})


		self.uiPrice_ = n_price
		-- 堆叠上限
		self.uiMaxNum_ = Mnode.createLabel(
		{
			parent = root,
			src = game.getStrByKey("overlay_upper_limit")..": "..tostring(MpropOp.maxOverlay(protoId)),
			color = color,
			size = size,
			anchor = cc.p(1, 0.5),
			pos = cc.p(350, 110),
		})
	end
	--------------------------------------------------------
	-- 滚动区域
	local vSize = cc.size(338, 240)
	local cSize = cc.size(vSize.width, vSize.height) -- 不能写成 cSize = vSize
	
	local n_placeholder = Mnode.createColorLayer(
	{
		--src = cc.c4b(244 ,164 ,96, 255*0.5),
		src = cc.c4b(244 ,164 ,96, 255*0),
		cSize = cSize,
	})
	
	-- ScrollView
	local n_scroll = cc.ScrollView:create()
	n_scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	n_scroll:setClippingToBounds(true)
	--n_scroll:setBounceable(true)
	n_scroll:setViewSize(vSize)
	n_scroll:setContainer(n_placeholder)
	n_scroll:updateInset()
	--n_scroll:setContentOffset(cc.p(0, vSize.height - cSize.height))
	Mnode.addChild(
	{
		parent = root,
		child = n_scroll,
		anchor = cc.p(0, 1),
		pos = cc.p(20, 367),
	})
	
	-- local refresh_content = function(parent, child) -- n_placeholder-n_content
	-- 	local content_tag = 1
	-- 	local n_content = parent:getChildByTag(content_tag)
	-- 	if n_content then removeFromParent(n_content) end
		
	-- 	local child_size = child:getContentSize()
	-- 	cSize.height = child_size.height
	-- 	parent:setContentSize(cSize)
		
	-- 	local parent_size = parent:getContentSize()
	-- 	n_content = Mnode.addChild(
	-- 	{
	-- 		parent = parent,
	-- 		child = child,
	-- 		anchor = cc.p(0, 1),
	-- 		pos = cc.p(0, parent_size.height), -- 对齐左上角
	-- 		tag = content_tag,
	-- 	})
	-- end
	--------------------------------------------------------
	-- 滚动区域内容
	local buildScrollContent = function()
		local nodes = {}
		----------------------------------
		-- 限时道具
		if expiration then
			local dt = os.date("*t", expiration)
			--dump(dt, "expiration")
			local readable = string.format(game.getStrByKey("full_date_format"), dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
			--dump(readable, "readable")
			local n_expiration = Mnode.createLabel(
			{
				src = game.getStrByKey("expiration").."："..tostring(readable),
				color = MColor.lable_black,
				size = size,
			})
			
			table.insert(nodes, 1, n_expiration)
		end

		
		if isEquip or isRide or isRideEquip then
			-- 构建装备滚动区域的内容
			
			-- 构建基础属性节点
			local buildInfoNode = function(key, base, added, vs)
				local isRange = type(base) == "table"
				local now_see = vs.now_see
				local vs2 = vs.vs2
				local vs = vs.vs
				
				-- 这些情况对比持平
				if vs ~= nil and ((isRange and vs["["] == 0 and vs["]"] == 0) or (not isRange and vs == 0)) then vs = nil end
				if vs2 ~= nil and ((isRange and vs2["["] == 0 and vs2["]"] == 0) or (not isRange and vs2 == 0)) then vs2 = nil end
				local hasBase = (isRange and base["]"] > 0) or (not isRange and base > 0)
				
				-- if vs ~= nil or vs2 ~= nil or hasBase then
				if hasBase then
					local nodes = {}
					-- nodes[#nodes+1] = Mnode.createLabel(
					-- {
					-- 	src = key,
					-- 	size = 18,
					-- 	color = MColor.lable_black,
					-- 	outline = false,
					-- })
					local strValue = key
					nodes[#nodes+1] = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.lable_black)

					local where = hasBase and now_see or base
					-- nodes[#nodes+1] = Mnode.createLabel(
					-- { 
					-- 	src = isRange and (where["["] .. "-" .. where["]"]) or where,
					-- 	size = 18,
					-- 	color = MColor.white,
					-- 	outline = false,
					-- })
					local strValue = isRange and (where["["] .. "-" .. where["]"]) or where
					nodes[#nodes+1] = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.white)

                    --src = game.getStrByKey("strengthen").."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added),
					nodes[#nodes+1] =
                    ((isRange and added["]"] > 0) or (not isRange and added > 0))
                    and GetUIHelper():createRichText( nil, "强".."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added), cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.white)
                    or nil
					
			--[[		if vs ~= nil then
						local isGreen = (isRange and vs["]"] > 0) or (not isRange and vs > 0)
						nodes[#nodes+1] = Mnode.combineNode(
						{
							nodes = {
								Mnode.createSprite(
								{
									src = "res/group/arrows/" .. (isGreen and "1.png" or "2.png"),
								}),
								
								Mnode.createLabel(
								{
									src = isRange and (math.abs(vs["["]) .. "-" .. math.abs(vs["]"])) or math.abs(vs),
									size = 18,
									color = isGreen and MColor.green or MColor.red,
									outline = false,
								}),
							},
							
							margins = 0,
						})
					end
				]]	
					return Mnode.combineNode(
					{
						nodes = nodes,
						margins = {0, 5, 2},
					})
				end
			end
			
			-- 构建对比节点
			local calc_vs = function(grid, attr_name)
				if packId == MPackStruct.eDress then
					return { now_see = MPackStruct.attrFromGird(grid, attr_name) }
				end
				
				local protoId = MPackStruct.protoIdFromGird(grid)
				local now_dress_grid = nil
				local now_dress_grid2 = nil

				local kind = MequipOp.kind(protoId)
				if kind == Mconvertor.eCuff then -- 护腕
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.eCuffLeft)
				elseif kind == Mconvertor.eRing then -- 戒指
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.eRingLeft)
					now_dress_grid2 = dress:getGirdByGirdId(MPackStruct.eRingRight)
				else
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.dressId(kind))
				end
				
				local now_see = MPackStruct.attrFromGird(grid, attr_name)
				local now_dress = MPackStruct.attrFromGird(now_dress_grid, attr_name)

				local ret = {}
				ret.now_see = now_see
				if type(now_see) == "table" then
					ret.vs = { ["["]= now_see["["]-now_dress["["], ["]"]= now_see["]"]-now_dress["]"] }
				else
					ret.vs = now_see-now_dress
				end

				if now_dress_grid2 then
					local now_dress2 = MPackStruct.attrFromGird(now_dress_grid2, attr_name)
					if type(now_see) == "table" then
						ret.vs2 = { ["["]= now_see["["]-now_dress2["["], ["]"]= now_see["]"]-now_dress2["]"] }
					else
						ret.vs2 = now_see-now_dress2
					end
				end

				return ret
			end
			--------------------------------------------------------------------------------------------------------------------------------
			---[[
			-- 基础属性
			-- 标题
			local n_attr_title = Mnode.createLabel(
			{
				src = game.getStrByKey("attr").."：",
				size = size,
				color = color,
				outline = false,
			})
			
			table.insert(nodes, 1, n_attr_title)
			-------------------------------------
			local addAttrNode = function(title, attr_name1, attr_name2, base_func, grow_func)
				if attr_name2 then
					local n_tmp = buildInfoNode(title, MequipOp.combatAttr(protoId, attr_name2),
									            MequipOp.upStrengthCombatAttr(attr_name2, protoId, strengthLv), calc_vs(grid, attr_name1))
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				else
					local n_tmp = buildInfoNode(title, base_func(protoId), grow_func(protoId, strengthLv), calc_vs(grid, attr_name1))
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			end
			
			addAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, Mconvertor.ePAttack)
			addAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, Mconvertor.eMAttack)
			addAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, Mconvertor.eTAttack)
			addAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, Mconvertor.ePDefense)
			addAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, Mconvertor.eMDefense)
			addAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, nil, MequipOp.maxHP, MequipOp.upStrengthMaxHP)
			addAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, nil, MequipOp.maxMP, MequipOp.upStrengthMaxMP)
			addAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, nil, MequipOp.luck, MequipOp.upStrengthLuck)
			addAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, nil, MequipOp.hit, MequipOp.upStrengthHit)
			addAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, nil, MequipOp.dodge, MequipOp.upStrengthDodge)
			addAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, nil, MequipOp.strike, MequipOp.upStrengthStrike)
			addAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, nil, MequipOp.tenacity, MequipOp.upStrengthTenacity)
			addAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, nil, MequipOp.huShenRift, MequipOp.upStrengthHuShenRift)
			addAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, nil, MequipOp.huShen, MequipOp.upStrengthHuShen)
			addAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, nil, MequipOp.freeze, MequipOp.upStrengthFreeze)
			addAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, nil, MequipOp.freezeOppose, MequipOp.upStrengthFreezeOppose)
			
			------------------------------------------------------------------------------------------------------------------
			-- 极品属性
			local attrCate = MequipOp.specialAttrCate(protoId)
			local isRange = Mconvertor.isRangeAttr(attrCate)
			local specialAttr = MPackStruct.specialAttrFromGird(grid)
			--dump({attrCate=attrCate, isRange=isRange, specialAttr=specialAttr}, "极品属性")
			if attrCate ~= nil and specialAttr ~= nil then
				local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
				local eachLayerValue = MequipOp.specialAttrEachLayerValue(protoId)
				local str = ""
				if isRange then str = str .. "0-" end
				str = str .. tostring(specialAttr * eachLayerValue)
				
				if specialAttr >= maxLayer then
					str = str .. " (最大值)"
				end
                --极品属性颜色
                require("src/layers/equipment/equipGold")
			    local specialVlaueColor=getSpecialAttrLevelColor(specialAttr)
				-- 标题
				local n_attr_title = Mnode.createLabel(
				{
					src = "极品属性".."：",
					size = size,
					color = color,
					outline = false,
				})
				
				table.insert(nodes, 1, n_attr_title)
				
				local n_special = Mnode.createKVP(
				{
					-- k = Mnode.createLabel(
					-- {
					-- 	src = Mconvertor.attrName(attrCate) .. ":",
					-- 	size = 18,
					-- 	color = MColor.lable_black,
					-- 	outline = false,
					-- }),
					k = GetUIHelper():createRichText( nil, Mconvertor.attrName(attrCate) .. ":", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.lable_black),
					v = GetUIHelper():createRichText( nil, str, cc.p(0, 0), nil, cc.p(0, 0), nil, 18, specialVlaueColor),
					-- local strValue = str
					-- v = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, specialVlaueColor)
					margin = 0,
				})
				
				table.insert(nodes, 1, n_special)
				---------------------------------
			end
			------------------------------------------------------------------------------------------------------------------
			-- 随机属性
			local randomAttr = MPackStruct.attrFromGird(grid, MPackStruct.eAttrRandom)
			--dump(randomAttr, "randomAttr")
			--[[
[LUA-print] - "randomAttr" = {
[LUA-print] -     6 = {
[LUA-print] -         1 = {
[LUA-print] -             "id"    = 6
[LUA-print] -             "order" = 1
[LUA-print] -             "value" = 0
[LUA-print] -         }
[LUA-print] -     }
[LUA-print] - }
			]]
			local bHasRandom = false
			if randomAttr then
				for k,v in pairs(randomAttr) do
					for k1,v1 in pairs(v) do
						if v1.value > 0 then
							bHasRandom = true
							break
						end
					end
				end
			end
			if quality > 2 or bHasRandom then
				-- 标题
				local n_attr_title = Mnode.createLabel(
				{
					src = "洗炼属性" .. "：",
					size = size,
					color = color,
					outline = false,
				})
				
				table.insert(nodes, 1, n_attr_title)
				---------------------------------
			end
			
			if randomAttr and bHasRandom then
				-- 构建随机属性节点
				local buildRandomAttrNode = function(nLevel, key, value1, value2)
					--dump({value1=value1, value2=value2})
					local isRange = value2 ~= nil
					if value1 and ((isRange and value2 > 0) or (not isRange and value1 > 0)) then
						return Mnode.createKVP(
						{
							-- k = Mnode.createLabel(
							-- {
							-- 	src = key,
							-- 	size = 18,
							-- 	color = MColor.lable_black,
							-- 	outline = false,
							-- }),
							k = GetUIHelper():createRichText( nil, key, cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.lable_black),
							v = GetUIHelper():createRichText( nil, isRange and (value1 .. "-" .. value2) or value1, cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MPackStruct.getRandomAttrColor(nLevel) or MColor.white),
							-- local strValue = isRange and (value1 .. "-" .. value2) or value1
							-- v = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MPackStruct.getRandomAttrColor(nLevel) or MColor.white)
							margin = 0,
						})
					end
				end
				
				local addRandomAttrNode = function(title, attr_name, isRange)
					if isRange then
						local sum_l, sum_r, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
						-- print("ids")
						-- dump(ids)
						-- print("list")
						-- dump(list)
						for i = 1, #list do
							local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i]["["], list[i]["]"])
							local n_tmp = buildRandomAttrNode(nLevel,title, list[i]["["], list[i]["]"])
							if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
						end
					else
						local sum, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
						-- print("ids")
						-- dump(ids)
						-- print("list")
						-- dump(list)
						for i = 1, #list do
							local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i])
							local n_tmp = buildRandomAttrNode(nLevel, title, list[i])
							if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
						end
					end
				end
				
				addRandomAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, true)
				addRandomAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, true)
				addRandomAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, true)
				addRandomAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, true)
				addRandomAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, true)
				addRandomAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, false)
				addRandomAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, false)
				addRandomAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, false)
				addRandomAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, false)
				addRandomAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, false)
				addRandomAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, false)
				addRandomAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, false)
				addRandomAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, false)
				addRandomAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, false)
				addRandomAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, false)
				addRandomAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, false)
			elseif not randomAttr and quality > 2 and  MpropOp.category(protoId)~=21  then
				
				local nNum = math.ceil(quality/2)
				if quality==3 then
					nNum=1
				end
				-- print("quality", quality, nNum)
				for i = 1, nNum do
					local dummy = Mnode.createKVP(
					{
						k = Mnode.createLabel(
						{
							src = "??：",
							size = 18,
							color = MColor.lable_black,
							outline = false,
						}),
						
						v = {
							src = "??-??",
							size = 18,
							color = MColor.white,
						},
						
						margin = 0,
					})
					
					table.insert(nodes, 1, dummy)
				end
			end
			-- 祝福属性
			if isWeapon then
				local blessing = MPackStruct.attrValue(grid, MPackStruct.eAttrLuck) or 0
				if blessing ~= 0 then
					-- 标题
					local n_attr_title = Mnode.createLabel(
					{
						src = game.getStrByKey("blessing")..game.getStrByKey("attr").."：",
						size = size,
						color = color,
						outline = false,
					})
					
					table.insert(nodes, 1, n_attr_title)
				
					local isBlessing = blessing > 0
					local c = isBlessing and MColor.green or MColor.red
					local k = isBlessing and (game.getStrByKey("luck")..":") or (game.getStrByKey("curse")..":")
					local v = isBlessing and blessing or -blessing
					
					local n_blessing = Mnode.createKVP(
					{
						-- k = Mnode.createLabel(
						-- {
						-- 	src = k,
						-- 	size = 18,
						-- 	color = c,
						-- 	outline = false,
						-- }),
						k = GetUIHelper():createRichText( nil, k, cc.p(0, 0), nil, cc.p(0, 0), nil, 18, c),
						v = GetUIHelper():createRichText( nil, v, cc.p(0, 0), nil, cc.p(0, 0), nil, 18, c),
						-- local strValue = v
						-- v = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, c)
						margin = 0,
					})
					
					table.insert(nodes, 1, n_blessing)
				end
				---------------------------------
			end
			
			-- 强化附加属性
			local tJihuo = MequipOp.qiangHuaJiHuo(protoId)
			--dump(tJihuo, "tJihuo")
			if type(tJihuo) == "table" then
				local tJihuo_s = {}
				for lv, record in pairs(tJihuo) do
					if type(record) ~= "table" then break end
					
					local k, v = nil, nil
					for kk, vv in pairs(record) do
						k = kk
						v = vv
					end
					tJihuo_s[#tJihuo_s+1] = {lv=lv, k=k, v=v}
				end
				table.sort(tJihuo_s, function(a, b)
					return a.lv < b.lv
				end)
				--dump(tJihuo_s, "tJihuo_s")
				
				if #tJihuo_s > 0 then
					-- 标题
					local n_attr_title = Mnode.createLabel(
					{
						src = "强化附加属性" .. "：",
						size = size,
						color = color,
						outline = false,
					})
					
					table.insert(nodes, 1, n_attr_title)
				end
				
				for i = 1, #tJihuo_s do
					local cur = tJihuo_s[i]
					local lv, k, v = cur.lv, cur.k, cur.v
					--dump(cur, "cur")
					if type(v) ~= "table" then
						-- dump(tJihuo, "强化附加属性配置表出错")
					else
						local str = ""
						str = str .. Mconvertor.attrName(k) .. ":"
						str = str .. tostring(v[1])
					
						if v[2] ~= nil then 
							str = str .. "-" .. tostring(v[2])
						end
						
						str = str .. "  强+" .. tostring(lv) .. "激活"
						
						-- local n_tmp = Mnode.createLabel(
						-- {
						-- 	src = str,
						-- 	size = 18,
						-- 	color = strengthLv >= lv and MColor.green or MColor.gray,
						-- })
						local strValue = str
						local n_tmp = GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, strengthLv >= lv and MColor.green or MColor.gray)
						table.insert(nodes, 1, n_tmp)
					end
				end
			end
			--]]
			-----------------------------------------------------------------------------------------------
			---[[
			-- 套装
			if isSuit then
				local groupId = MequipOp.group(protoId)
				--dump(groupId, "groupId")
				
				local suit_set = MequipOp.suitSet(protoId)
				--dump(suit_set, "suit_set")
	
				-- 套装名字
				local n_suit_name = Mnode.createLabel(
				{
					src = MequipOp.suitName(protoId),
					size = size,
					color = color,
					outline = false,
				})
					
				local n_suit_num = Mnode.createLabel(
				{
					src = "( 0/8)",
					size = size,
					color = color,
					outline = false,
				})
				
				local n_title = Mnode.combineNode(
				{
					nodes = {
						n_suit_name,
						n_suit_num,
					},
					
					margins = 5,
				})
				
				table.insert(nodes, 1, n_title)
				
	

				local search_suit_set = function(kind)
					for i, v in pairs(suit_set) do
						if kind == MequipOp.kind(v) then
							return v
						end
					end
				end
				
				local num_of_suit_dressed = 0

				-- 套装集合
				local build_suit_set = function()
					local tDressId = 
					{
						MPackStruct.eHelmet, MPackStruct.eNecklace, MPackStruct.eCuffLeft, MPackStruct.eCuffRight, 
						MPackStruct.eRingLeft, MPackStruct.eRingRight, MPackStruct.eBelt, MPackStruct.eShoe,
					}
					
					local cfg = tDressId
					local tmp = {}
					for i = 1, #cfg do
						local dress_id = cfg[i]
						
						local pos = ""
						if dress_id == MPackStruct.eCuffLeft or dress_id == MPackStruct.eRingLeft then
							pos = game.getStrByKey("left")
						elseif dress_id == MPackStruct.eCuffRight or dress_id == MPackStruct.eRingRight then
							pos = game.getStrByKey("right")
						end
						
						local dress_kind = MPackStruct.equipId(dress_id)
						
						local suit_protoId = search_suit_set(dress_kind)
						--dump(suit_protoId, "suit_protoId")
						
						local cur_dressed_protoId = dress:protoId(dress_id)
						--dump(cur_dressed_protoId, "cur_dressed_protoId")
						
						local c = MColor.gray
						
						if cur_dressed_protoId and suit_protoId and suit_protoId == cur_dressed_protoId then
							num_of_suit_dressed = num_of_suit_dressed+1
							c = MColor.green
						else
							--c = c = MColor.gray
						end
						
						local n_name = Mnode.createLabel(
						{
							src = MpropOp.name(suit_protoId).."("..tostring(Mconvertor:equipName(MequipOp.kind(suit_protoId)))..pos..")",
							size = size,
							color = c,
							outline = false,
						})
						
						table.insert(tmp, 1, n_name)
					end
					
					return Mnode.combineNode(
					{
						nodes = tmp,
						ori = "|",
						align = "l",
						margins = 5,
					})
				end
				
				table.insert(nodes, 1, build_suit_set())
				
				-- local stSuitDB = getConfigItemByKey("EquipSuitDB", "q_suidId", groupId)
				local stSuitDB = DB.get("EquipSuitDB", "q_suidId", groupId)

				local sSuitDes =  "套装效果："..stSuitDB["Discript"]
				local nSuitNum = stSuitDB["q_suitNum"]
				n_suit_num:setString("(" .. num_of_suit_dressed .. "/"..nSuitNum..")")



				local c = MColor.gray
						
				if num_of_suit_dressed >= nSuitNum then
					c = MColor.green
				end

				local uiSuitDes = Mnode.createLabel(
				{
					src = sSuitDes,
					size = size,
					color = c,
					outline = false,
					bound = cc.size(320,100),
				})

				table.insert(nodes, 2, uiSuitDes)
				-- 套装属性加成
				--dump(num_of_suit_dressed, "num_of_suit_dressed")
				local buildSuitPropNode = function(key, value, color)
					local isRange = type(value) == "table"
					if value and ((isRange and value["]"] > 0) or (not isRange and value > 0)) then
						-- return Mnode.createLabel(
						-- {
						-- 	src = key .. "+" .. (isRange and (value["["] .. "-" .. value["]"]) or value),
						-- 	size = 18,
						-- 	color = MColor.lable_black,
						-- 	outline = false,
						-- })
						local strValue = key .. "+" .. (isRange and (value["["] .. "-" .. value["]"]) or value)
						return GetUIHelper():createRichText( nil, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 18, MColor.lable_black)
					end
				end
				
				repeat
					local suit_num = 8
					local ok = num_of_suit_dressed >= 8
					
					if not ok then break end
					
					local c = ok and MColor.green or MColor.gray
					local prop_nodes = {}
				
				
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("freeze_oppose"), MequipOp.suitFreezeOppose(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("freeze"), MequipOp.suitFreeze(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("hu_shen"), MequipOp.suitHuShen(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("hu_shen_rift"), MequipOp.suitHuShenRift(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("my_tenacity"), MequipOp.suitTenacity(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("strike"), MequipOp.suitStrike(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("dodge"), MequipOp.suitDodge(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("my_hit"), MequipOp.suitHit(groupId, suit_num), c)						  
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("luck"), MequipOp.suitLuck(groupId, suit_num), c)					  
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("mp"), MequipOp.suitMaxMP(groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("hp"), MequipOp.suitMaxHP(groupId, suit_num), c)				  
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("magic_defense_s"), MequipOp.suitCombatAttr(Mconvertor.eMDefense, groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("physical_defense_s"), MequipOp.suitCombatAttr(Mconvertor.ePDefense, groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("taoism_attack_s"), MequipOp.suitCombatAttr(Mconvertor.eTAttack, groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("magic_attack_s"), MequipOp.suitCombatAttr(Mconvertor.eMAttack, groupId, suit_num), c)
					prop_nodes[#prop_nodes+1] = buildSuitPropNode(game.getStrByKey("physical_attack_s"), MequipOp.suitCombatAttr(Mconvertor.ePAttack, groupId, suit_num), c)
				
					-- 套装所有属性
					local n_propAdded = Mnode.combineNode(
					{
						nodes = prop_nodes,
						ori = "|",
						align = "l",
						margins = 5,
					})
					
					table.insert(nodes, 1, n_propAdded)
				until true
			end -- end套装
			--]]
			----------------------------------------------------
		end

		if isMedal then
			local s_name, s_data, s_lv = require("src/layers/role/honourLayer"):getProp(false, strengthLv+school*1000, school)
			local n_medal = Mnode.createColorLayer(
			{
				src = cc.c4b(0 ,0 ,0, 0),
				cSize = cc.size(250,(#s_name+1)*31),
			})

			createLabel(n_medal,s_lv,cc.p(0,(#s_name+1)*31-16),cc.p(0,0.5),22,true,nil,nil,MColor.lable_yellow)
			local posy,posySub = (#s_name+1)*31-16,30
			for i = 1,#s_name do
				local propt = ""
				if type(s_data[i]) == "table" then
					propt = " "..s_data[i][1].."~"..s_data[i][2]
				else
					propt = " "..s_data[i]
				end
				createLabel(n_medal,game.getStrByKey(s_name[i]),cc.p(0,posy-posySub),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
				createLabel(n_medal,propt,cc.p(65,posy-posySub),cc.p(0,0.5),20,true,nil,nil,MColor.white)
				posySub = posySub + 30
			end
			table.insert(nodes, 1, n_medal)

			local inlay = require("src/layers/honour/inlay")
			local wenshiTab = inlay:adjust(grid,true)
			if #wenshiTab > 0 then
				local wenshiNode,tempY = inlay:reloadProp(true,wenshiTab)

				local n_medal1 = Mnode.createColorLayer({
					src = cc.c4b(0,0,0,0),
					cSize = cc.size(250,tempY*25),				
				})
				wenshiNode:setPosition(cc.p(0,tempY*25))
				n_medal1:addChild(wenshiNode)
				table.insert(nodes, 1, n_medal1)
			end
		end

		-- 获得途径
		local way = MpropOp.outputWay(protoId)
		if #way > 0 then
			local MPropOutput = require "src/config/PropOutputWayOp"
			local build_outputWayNode = function()
				local nodes = {}
				
				local texture = TextureCache:addImage("res/common/shadow-1.png")
				local texture_size = texture:getContentSize()
				local cell_size = cc.size(cSize.width, texture_size.height)
				
				local n_title = cc.Sprite:create("res/common/shadow.png")
				local n_title_size = n_title:getContentSize()
				table.insert(nodes, 1, n_title)
				
				Mnode.createLabel(
				{
					parent = n_title,
					src = game.getStrByKey("get_path"),
					size = size,
					color = color,
					pos = cc.p(n_title_size.width/2, n_title_size.height/2),
				})
				
				for i, v in ipairs(way) do
					local finx = tonumber(way[i])
					if finx then
						local record = MPropOutput:record(finx)
						if not record then break end
						--dump(record, "record")
						
						local cell = Mnode.createNode({ cSize = cell_size })
						Mnode.addChild(
						{
							parent = cell,
							child = cc.Sprite:createWithTexture(texture),
							pos = cc.p(cell_size.width/2, cell_size.height/2),
						})
						
						local status = true
						
						if finx == 99 then -- 运营活动
							status = false
							cell.msg = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 19000 , -2 }).msg
						elseif finx == 98 or finx == 31 then -- 行会商店 or 行会BOSS
							local id = MRoleStruct:getAttr(PLAYER_FACTIONID)
							if id == 0 then
								status = false
								cell.msg = game.getStrByKey("join_faction_tips")
							end
						elseif finx == 2 then -- 神秘商店
							
						else
							local lv = MRoleStruct:getAttr(ROLE_LEVEL)
							local limit = MPropOutput:lvLimit(record)
							if limit and lv < limit then
								status = false
								cell.msg = limit .. game.getStrByKey("rngd")..game.getStrByKey("open")
							end
						end
						
						cell.status = status
						cell.goto = MPropOutput:goto(record)
						
						local n_label = Mnode.createLabel(
						{
							parent = cell,
							src = MPropOutput:name(record),
							size = size,
							color = MColor.lable_black,
							pos = cc.p(cell_size.width/2, cell_size.height/2),
						})
						
						-- 监听触摸事件
						Mnode.listenTouchEvent(
						{
							swallow = false,
							node = cell,
							begin = function(touch, event)
								local node = event:getCurrentTarget()
								if node.catch then return false end
							
								local inside = Mnode.isTouchInNodeAABB(node, touch)
								if inside then
									local point = n_scroll:convertTouchToNodeSpace(touch)
									if not Mnode.isPointInNodeAABB(n_scroll, point, n_scroll:getViewSize()) then return false end
								
									node.catch = true
									return true
								end
								
								return false
							end,
							
							ended = function(touch, event)
								local node = event:getCurrentTarget()
								node.catch = false
								
								if Mnode.isTouchInNodeAABB(node, touch) then
									local startPos = touch:getStartLocation()
									local currPos  = touch:getLocation()
									if cc.pGetDistance(startPos,currPos) < 30 then
										AudioEnginer.playTouchPointEffect()
										
										local cell = node
										if cell.status then
											-- 直接调用会崩溃，尚未明确是何原因
											performWithDelay(root, function()
												removeFromParent(root:getParent())
												if G_MAINSCENE.map_layer:isHideMode() then 
													TIPS( {str = game.getStrByKey("current_map"), type = 1})
													return 
												end
												__GotoTarget({ ru = cell.goto, protoId = protoId })
											end, 0.0)
										else
											if cell.msg then
												TIPS({ type = 1  , str = cell.msg })
											end
										end
									end
								end
							end,
						})
						
						table.insert(nodes, 1, cell)
					end
				end
				
				return Mnode.combineNode(
				{
					nodes = nodes,
					ori = "|",
					--align = "l",
					margins = 2,
				})
			end
				
			local n_outputWay = build_outputWayNode()
			table.insert(nodes, 1, n_outputWay)
		end

		local n_des_k = Mnode.createLabel(
		{
			src = "描述",
			color = color,
			size = size,
		})
		
		-- 物品描述
		local lableBound = cc.size(cSize.width, 0)
		-- local n_des_v = Mnode.createLabel(
		-- {
		-- 	src = MpropOp.description1(protoId),
		-- 	color = MColor.lable_black,
		-- 	size = size,
		-- 	bound = lableBound,
		-- })
		local n_des_v = GetUIHelper():createRichText( nil, MpropOp.description1(protoId), cc.p(0, 0), nil, cc.p(0, 0), nil, size, MColor.lable_black)
		if isEquip or isMedal or isRideEquip then
			table.insert(nodes, 1, n_des_k)
			table.insert(nodes, 1, n_des_v)
		elseif not isMedal then
			nodes[#nodes+1] = n_des_v
			nodes[#nodes+1] = n_des_k
		end
		
		

		local n_content = Mnode.combineNode(
		{
			nodes = nodes,
			ori = "|",
			align = "l",
			margins = 10,
		})
		
		
		self.params_ = params
		self.n_placeholder = n_placeholder
		self.vSize = vSize
		self.n_scroll = n_scroll
		self.cSize = cSize

		self.n_content = n_content
		self.n_content:retain()
		self:refresh_content(n_placeholder, n_content, self.cSize)


		

		-- if packId ~= MPackStruct.eDress and isEquip then
		-- 	self.bCompare_ = true
		-- end
		
	end
	
	if isSuit then
		--performWithDelay(root, function()
			buildScrollContent()
		--end, 0.25)
	else
		buildScrollContent()
	end
	
	
	local reloadView = function()
		buildScrollContent()
		icon:setStrengthLv(strengthLv)
		if n_power ~= nil then
			n_power:setValue({text = tostring(power)})
		end
		self:RefreshUI()
	end
	--------------------------------------------------------
	-- 添加 tips 的操作
	local actions = params.actions or {}
	if (packId == MPackStruct.eBag or packId == MPackStruct.eDress) and #actions == 0 then
		-- 是否可以出售
		local sellAct = nil
		-- 是否可以放入仓库
		local putAct = nil
		
		if packId == MPackStruct.eBag then
			sellAct = MpropOp.recyclable(protoId) and "sell" or nil
			putAct = bankOpenStatus() and MpropOp.accessible(protoId) and "put" or nil
		end
		
		-- 是否可以使用或穿戴
		local isLimitToMe = MpropOp.isLimitToMe(protoId)
	
		if isEquip then
			local rightAct = false
			-- 上装
			local dressAct = packId == MPackStruct.eBag and not isLimitToMe and "dress" or nil
			if dressAct then
				actions[#actions + 1] = dressAct
				rightAct = dressAct
			end
			
			-- 装备强化
			local isRUL = MequipOp.isStrengthRUL(protoId, strengthLv, quality)
			local strengthAct = (not isRUL and G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_STRENGTHEN)) and "strengthen" or nil
			
			if rightAct ~= "dress" and strengthAct then
				actions[#actions + 1] = strengthAct
				rightAct = strengthAct
			end
			
			local undressAct = packId == MPackStruct.eDress and "undress" or nil
			
			if not rightAct and undressAct then
				actions[#actions + 1] = undressAct
				rightAct = undressAct
			end
			
			if not rightAct then
				actions[#actions + 1] = "share"
				rightAct = "share"
			else
				actions[#actions + 1] = "share"
			end
			
			if packId == MPackStruct.eBag then
				actions[#actions + 1] = sellAct
				actions[#actions + 1] = putAct
			end
			
			if rightAct ~= "undress" and undressAct then
				actions[#actions + 1] = undressAct
			end
			
			-- 更换
			local changeAct = nil
			if packId == MPackStruct.eDress then
				local available = MPackManager:getEquipList(gridId)
				changeAct = #available > 0 and "change" or nil
			end
			actions[#actions + 1] = changeAct
			
			-- 装备传承
			local lineageAct = (strengthLv > 0 and quality >= 3 and not G_NO_OPEN_INHERIT) and "lineage" or nil
			actions[#actions + 1] = lineageAct
			
			-- 装备祝福
			-- 幸运值
			local luck = MPackStruct.attrFromGird(grid, MPackStruct.eAttrLuck)
			local blessingAct = isWeapon and luck < 7 and G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_BLESS) and "blessing"  or nil
			actions[#actions + 1] = blessingAct
			
			-- 装备洗练
			---[[
			local randomAttrSet = MPackStruct.attrFromGird(grid, MPackStruct.eAttrRandom)
			local refineAct = randomAttrSet ~= nil and G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_WASH) and "refine" or nil
			actions[#actions + 1] = refineAct
			--]]
			
			-- 装备点金
			local specialAttr = MPackStruct.specialAttrFromGird(grid) or 0
			local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
			local goldAct = specialAttr < maxLayer and G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_GOLD) and  "gold_pointing" or nil
			actions[#actions + 1] = goldAct
			
			-- 强化
			if rightAct == "dress" and strengthAct then
				actions[#actions + 1] = "strengthen"
			end
			
		else -- 背包的普通物品
			if isMedal then   --勋章脱离了装备(不存在对比 等等)
				if params.hadEquipMedal then
					actions[#actions + 1] = not isLimitToMe and "update" or nil
					actions[#actions + 1] = not isLimitToMe and "texturePic" or nil
				else
					actions[#actions + 1] = not isLimitToMe and "dress" or nil
				end
			elseif isRideEquip then
				if packId == MPackStruct.eBag then
					actions[#actions + 1] = "dress"
				elseif packId >= MPackStruct.eRideDress1 and packId<=MPackStruct.eRideDress10 then
					actions[#actions + 1] = "undress"
				end
			else
				local useAct = MpropOp.canUse(protoId) and "use" or nil
				actions[#actions + 1] = useAct
			end
			
			-- 前往使用
			local goUse = MpropOp.goUse(protoId)
			local goUseAct = (goUse and goUse ~= "") and "go_use" or nil
			actions[#actions + 1] = goUseAct
			
			-- 前往npc使用
			local goNpcUse = MpropOp.goToNPC(protoId)
			local goNpcUseAct = goNpcUse and "go_npc" or nil
			actions[#actions + 1] = goNpcUseAct
			
			actions[#actions + 1] = sellAct
			actions[#actions + 1] = putAct
            local table_forge = require("src/config/Forge")
            local bool_exist_in_forge = false
            for k_forge, v_forge in pairs(table_forge) do
                while true do
                    if v_forge.q_sort ~= 2 then--q_menu:代表1.打造 2.合成
                        break
                    end
                    local table_item = assert(loadstring("return " .. v_forge.q_itemID))()
                    local bool_item_more_than_one = false
                    for k_forgable_item, v_forgable_item in pairs(table_item) do
                        if table.size(v_forgable_item) > 1 then
                            bool_item_more_than_one = true
                            break
                        end
                    end
                    for k_forgable_item, v_forgable_item in pairs(bool_item_more_than_one and table_item[school] or table_item[1]) do
                        if protoId == k_forgable_item then
                            bool_exist_in_forge = true
                            break
                        end
                    end
                    break
                end
            end
			local compoundAct = bool_exist_in_forge and "compound" or nil
			actions[#actions + 1] = compoundAct
			
			local num = MPackStruct.overlayFromGird(grid)
			local batchUseAct = num > 1 and MpropOp.canUsedInBatch(protoId) and "batch_use" or nil
			actions[#actions + 1] = batchUseAct
			actions[#actions + 1] = "share"
		end
	end
	
	--dump(actions, "actions")
	local map = {}
	for i, v in ipairs(actions) do map[v] = i end
	
	--------------------------------------------------------
	local pos_left = cc.p(100, 50)
	local pos_right = cc.p(276, 50)
	local pos_center = cc.p(rootSize.width/2, 50)
	
	local count_act = #actions
	--如果是对比装备的，那就把这些按钮隐藏
	if params.extraTip == true then
		count_act = 0
	end
	if count_act < 1 then --count_act == 0
	elseif count_act < 2 then --count_act == 1
		Mnode.addChild(
		{
			parent = root,
			child = buildActBtn(actions[1], act_params, self),
			pos = pos_center,
		})
	elseif count_act < 3 then --count_act == 2
		local pos_1 = pos_right
		local pos_2 = pos_left
		
		local record = actions[2]
		if record == "use" or record == "dress" then
			pos_2 = pos_right
			pos_1 = pos_left
		end
		Mnode.addChild(
		{
			parent = root,
			child = buildActBtn(actions[1], act_params, self),
			pos = pos_1,
		})
		
		Mnode.addChild(
		{
			parent = root,
			child = buildActBtn(actions[2], act_params, self),
			pos = pos_2,
		})
	else --count_act >= 3
		--dump(actions, "actions")
		--dump(map, "map")
		local right = nil
		if map.use == nil and map.dress == nil then
			right = 1
		else
			right = map.use or map.dress
		end
		
		if right ~= nil then
			Mnode.addChild(
			{
				parent = root,
				child = buildActBtn(actions[right], act_params, self),
				pos = pos_right,
			})
		end
		
		local moreMenu, moreBtn = MMenuButton.new(
		{
			parent = root,
			src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
			pos = pos_left,
			zOrder = 1,
			label = {
				src = game.getStrByKey("more"),
				size = 22,
				color = MColor.lable_yellow,
			},
			
			effect = "none",
			
			cb = function(tag, node)
				node:setEnabled(false)
				local clip_tag = 748
				local clip = node:getChildByTag(clip_tag)
				
				if node.status then
					node.touch_switch(false)
					local btns_bg = node.btns_bg
					local ep = node.sp
					local MoveTo = Manimation:buffer(
					{
						action = cc.MoveTo:create(node.duration, ep),
						stage = "<-",
					})
					local CallFunc = cc.CallFunc:create(function(btns_bg)
						node:setLabel(
						{
							src = game.getStrByKey("more"),
							size = 22,
							color = MColor.lable_yellow,
						})
						node:setEnabled(true)
						node.status = false
					end)
					local action = cc.Sequence:create(MoveTo, CallFunc)
					btns_bg:runAction(action)
				else
					local execute_action = function(node)
						node.touch_switch(false)
						local btns_bg = node.btns_bg
						local ep = node.ep
						
						local MoveTo = Manimation:buffer(
						{
							action = cc.MoveTo:create(node.duration, ep),
							stage = "->",
						})
					
						local CallFunc = cc.CallFunc:create(function(btns_bg)
							node:setLabel(
							{
								src = game.getStrByKey("hide"),
								size = 22,
								color = MColor.lable_yellow,
							})
							node:setEnabled(true)
							node.status = true
							node.touch_switch(true)
						end)
						local action = cc.Sequence:create(MoveTo, CallFunc)
						
						btns_bg:runAction(action)
					end
					
					if clip then
						execute_action(node)
					else
						local actionBtn = {}
						for i, v in ipairs(actions) do
							if i ~= right then
								local btn = buildActBtn(v, act_params, self)
								table.insert(actionBtn, 1, btn)
							end
						end
						
						node.touch_switch = function(value)
							for i, v in ipairs(actionBtn) do
								v:getButton():setEnabled(value)
							end
						end
				
						local binding = Mnode.combineNode(
						{
							nodes = actionBtn,
							ori = "|",
							margins = -1,
						})
						--dump(binding, "binding")
						local binding_size = binding:getContentSize()
						local btns_bg_size = cc.size(binding_size.width+10, binding_size.height+5)
						
						local btns_bg = Mnode.createColorLayer(
						{
							src = cc.c4b(0 ,0 ,0, 0),
							--cc.c4b(244 ,164 ,96, 255*0.5),
							cSize = btns_bg_size,
						})
						
						Mnode.addChild(
						{
							parent = btns_bg,
							child = binding,
							pos = cc.p(btns_bg_size.width/2, btns_bg_size.height/2),
						})
						
						local baseboard_size = cc.size(btns_bg_size.width, btns_bg_size.height*2)
						local baseboard = Mnode.createColorLayer(
						{
							src = cc.c4b(0, 0, 0, 0),
							cSize = baseboard_size,
						})
						
						local template_size = btns_bg_size
						local template = Mnode.createColorLayer(
						{
							src = cc.c4b(0, 0, 0, 0),
							cSize = template_size,
						})
						
						local sp = cc.p(baseboard_size.width/2, btns_bg_size.height/2)
						local ep = cc.p(baseboard_size.width/2, baseboard_size.height/2+btns_bg_size.height/2)
						Mnode.addChild(
						{
							parent = baseboard,
							child = btns_bg,
							pos = sp,
						})
						-------------------------------------------------------
						node.btns_bg = btns_bg
						node.sp = sp
						node.ep = ep
						node.duration = 0.25
						execute_action(node)
						-------------------------------------------------------
						
						clip = cc.ClippingNode:create(template)
						local clip_size = baseboard_size
						clip:setContentSize(clip_size)
						--clip:setInverted(true);
						--clip:setAlphaThreshold(0);
						
						template:setPosition(clip_size.width/2, clip_size.height-template_size.height/2)
						
						Mnode.addChild(
						{
							parent = clip,
							child = baseboard,
							pos = cc.p(clip_size.width/2, clip_size.height/2),
						})
						
						local node_size = node:getContentSize()
						Mnode.addChild(
						{
							parent = node,
							child = clip,
							pos = cc.p(node_size.width/2, node_size.height),
							tag = clip_tag,
						})
					end
				end
			end,
		})
		
		moreBtn.status = false
		G_TUTO_NODE:setTouchNode(moreBtn, TOUCH_TIP_MORE)
	end

    root.registerScriptHandler(root, function(event)
			if event == "exit" then
				self:dispose()
			end
		end)
	--------------------------------------------------------
	-- tips 的刷新
	if (packId == MPackStruct.eBag or packId == MPackStruct.eDress) and isEquip then
		local dataSourceChanged = function(pack, event, id)
			if (id == gridId) and (event == "=" or event == "+") then
				local new_grid = pack:getGirdByGirdId(id)
				reloadData(new_grid)
				Event.Dispatch(EventName.RefreshGridData, grid)
				reloadView()
			end
		end
		
		-- 用root:registerScriptHandler方式调用 ios debug 版本不知什么原因会报错
		root.registerScriptHandler(root, function(event)
			local pack = MPackManager:getPack(packId)
			if event == "enter" then
				pack:register(dataSourceChanged)
			elseif event == "exit" then
				pack:unregister(dataSourceChanged)
				self:dispose()
			end
		end)
	end   

	self.stRootSize_ = root:getContentSize()
	self.uiSwitch_ = createMenuItem(root, "res/component/button/38.png", cc.p(self.stRootSize_.width/2, 50), handler(self, self.OnSwitchClick))
	-- self.uiSwitch_ = GetWidgetFactory():CreateButton()
	-- root:addChild(self.uiSwitch_)
	self.uiSwitch_:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.uiSwitch_:setPosition(cc.p(self.stRootSize_.width/2, 50))
	-- GetUIHelper():LoadButtonTextures(self.uiSwitch_, "res/component/button/38.png", "res/component/button/38_sel.png", "res/component/button/38_gray.png")
	-- self.uiSwitch_:addTouchEventListener(handler(self, self.OnSwitchClick))
	self.uiSwitch_:setVisible(false)

	local stSwitchSize = self.uiSwitch_:getContentSize()
	-- local imgSwith = GetWidgetFactory():CreateImage("res/tips/tipsSwitch.png")
	-- self.uiSwitch_:addChild(imgSwith)
	-- imgSwith:setAnchorPoint(cc.p(0, 0.5))
	-- imgSwith:setPosition(cc.p(30, stSwitchSize.height/2))
	local imgSwith = createSprite(self.uiSwitch_, "res/tips/tipsSwitch.png", cc.p(30, stSwitchSize.height/2), cc.p(0, 0.5))

	-- local tfSwitch = GetWidgetFactory():CreateText()
	-- tfSwitch:setFontSize(GetUiCfg().stFontSize.SecondTabsSize)
	-- tfSwitch:setTextColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	-- tfSwitch:setAnchorPoint(cc.p(0.5, 0.5))
	-- tfSwitch:setPosition(cc.p(stSwitchSize.width/2 + 10, stSwitchSize.height/2))
	-- GetUIHelper():SetString(tfSwitch, "切换装备")
	-- self.uiSwitch_:addChild(tfSwitch)
	local tfSwitch = createLabel(self.uiSwitch_, "切换装备", cc.p(stSwitchSize.width/2 + 10, stSwitchSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.SecondTabsSize)
	tfSwitch:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- self.uiCompareOrDetail_ = GetWidgetFactory():CreateButton()
	-- root:addChild(self.uiCompareOrDetail_)
	-- self.uiCompareOrDetail_:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.uiCompareOrDetail_:setPosition(cc.p(self.stRootSize_.width/2, 110))
	-- GetUIHelper():LoadButtonTextures(self.uiCompareOrDetail_, "res/tips/tipsBg.png")
	-- self.uiCompareOrDetail_:addTouchEventListener(handler(self, self.OnCompareOrDetailClick))
	-- self.uiCompareOrDetail_:setVisible(false)

	self.uiCompareOrDetail_ = createMenuItem(root, "res/tips/tipsBg.png", cc.p(self.stRootSize_.width/2, 110), handler(self, self.OnCompareOrDetailClick))
	self.uiCompareOrDetail_:setVisible(false)
	self.uiCompareOrDetail_:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_plCompareOrDetail1 = cc.Node:create()
	self.m_plCompareOrDetail2 = cc.Node:create()

	self.uiCompareOrDetail_:addChild(self.m_plCompareOrDetail1)
	self.uiCompareOrDetail_:addChild(self.m_plCompareOrDetail2)

	local stCompareOrDetailSize = self.uiCompareOrDetail_:getContentSize()
	-- local tfCompareOrDetail = GetWidgetFactory():CreateText()
	-- tfCompareOrDetail:setFontSize(GetUiCfg().stFontSize.SecondTabsSize)
	-- tfCompareOrDetail:setTextColor(GetUiCfg().FontColor.NameAndMoneyColor)
	
	-- tfCompareOrDetail:setAnchorPoint(cc.p(0.5, 0.5))
	-- tfCompareOrDetail:setPosition(cc.p(stCompareOrDetailSize.width/2, stCompareOrDetailSize.height/2))
	local tfCompareOrDetail = createLabel(self.m_plCompareOrDetail1, "点查看更多属性", cc.p(stCompareOrDetailSize.width/2, stCompareOrDetailSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.SecondTabsSize)
	tfCompareOrDetail:setColor(GetUiCfg().FontColor.NameAndMoneyColor)
	local tfCompareOrDetail2 = createLabel(self.m_plCompareOrDetail2, "点查看装备后属性", cc.p(stCompareOrDetailSize.width/2, stCompareOrDetailSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.SecondTabsSize)
	tfCompareOrDetail2:setColor(GetUiCfg().FontColor.NameAndMoneyColor)
	
	-- local tfCompareOrDetail2 = tfCompareOrDetail:clone()
	-- GetUIHelper():SetString(tfCompareOrDetail, "点查看更多属性")
	-- GetUIHelper():SetString(tfCompareOrDetail2, "点查看装备后属性")

	

	-- self.m_plCompareOrDetail1:addChild(tfCompareOrDetail)
	-- self.m_plCompareOrDetail2:addChild(tfCompareOrDetail2)

	

	local imgRightArrow = createSprite(self.m_plCompareOrDetail1, "res/tips/tipsArrow.png", cc.p(stCompareOrDetailSize.width/2 + tfCompareOrDetail:getContentSize().width/2, stCompareOrDetailSize.height/2), cc.p(0, 0.5))

	local imgLeftArrow = createSprite(self.m_plCompareOrDetail2, "res/tips/tipsArrow.png", cc.p(stCompareOrDetailSize.width/2 - tfCompareOrDetail2:getContentSize().width/2, stCompareOrDetailSize.height/2), cc.p(1, 0.5))
	-- local imgRightArrow = GetWidgetFactory():CreateImage("res/tips/tipsArrow.png")
	-- local imgLeftArrow = imgRightArrow:clone()
	imgLeftArrow:setFlippedX(true)

	-- imgRightArrow:setAnchorPoint(cc.p(0, 0.5))
	-- imgLeftArrow:setAnchorPoint(cc.p(0, 0.5))
	-- imgRightArrow:setPosition(cc.p(stCompareOrDetailSize.width/2 + tfCompareOrDetail:getContentSize().width/2, stCompareOrDetailSize.height/2))
	-- imgLeftArrow:setPosition(cc.p(stCompareOrDetailSize.width/2 - tfCompareOrDetail2:getContentSize().width/2, stCompareOrDetailSize.height/2))

	-- self.m_plCompareOrDetail1:addChild(imgRightArrow)
	-- self.m_plCompareOrDetail2:addChild(imgLeftArrow)

	self.eShowState_ = {
	ShowCommon = 1,
	ShowCompare = 2,
}
	
	self:ShowCommon()


	self.m_imgTitle = createSprite(root, "res/tips/tipTitleBg.png", cc.p(self.stRootSize_.width/2, self.stRootSize_.height - 5))

	-- self.m_imgTitle = GetWidgetFactory():CreateImage("res/tips/tipTitleBg.png")
	
	-- root:addChild(self.m_imgTitle)
	-- self.m_imgTitle:setPosition(cc.p(self.stRootSize_.width/2, self.stRootSize_.height - 5))
	self.m_imgTitle:setVisible(false)

	local stImgSize = self.m_imgTitle:getContentSize()

	local tfEquiped = createLabel(self.m_imgTitle, game.getStrByKey("already")..game.getStrByKey("equip_book"), cc.p(stImgSize.width/2, stImgSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfEquiped:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- local tfEquiped = GetWidgetFactory():CreateText()
	-- tfEquiped:setFontSize(GetUiCfg().stFontSize.FirstTabsSize)

	-- tfEquiped:setTextColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	-- GetUIHelper():SetString(tfEquiped, game.getStrByKey("already")..game.getStrByKey("equip_book"))
	-- self.m_imgTitle:addChild(tfEquiped)
	
	-- tfEquiped:setPosition(stImgSize.width/2, stImgSize.height/2)

	Event.Add(EventName.RefreshGridData, self, self.OnRefreshGridData)
end

function tipsCommon:OnRefreshGridData( grid )
	-- body
	if self.stCurComparedGrid_ and self.stCurComparedGrid_.grid and self.stCurComparedGrid_.grid.mGirdSlot == grid.mGirdSlot then
		self.stCurComparedGrid_.grid = grid
		self:RefreshUI()
	end
	if self.stCurComparedGrid_ and self.stCurComparedGrid_.compareGrid and self.stCurComparedGrid_.compareGrid.mGirdSlot == grid.mGirdSlot then
		self.stCurComparedGrid_.compareGrid = grid
		self:RefreshUI()
	end
end

function tipsCommon:ShowEquiped( bShow )
	-- body
	self.m_imgTitle:setVisible(bShow)
end

function tipsCommon:setCompareGrid( t )
	-- body
	self.stCurComparedGrid_ = t
	self:RefreshUI()
end

function tipsCommon:RefreshUI( ... )
	-- body
	if self.iCurShowState_ == self.eShowState_.ShowCommon then
		self:ShowCommon()
	else
		self:ShowCompare()
	end
end

function tipsCommon:ShowCompare( ... )
	-- body
	if self.bCompare_ and self.stCurComparedGrid_ then
		local oEquipCompare = EquipCompare.new(self.stCurComparedGrid_)
		self:refresh_content(self.n_placeholder, oEquipCompare:buildScrollContent(), self.cSize)

		self:SetShowState(self.eShowState_.ShowCompare)
	end
end

function tipsCommon:ShowCommon( ... )
	-- body
	if self.n_content then
		self:SetShowState(self.eShowState_.ShowCommon)
		self:refresh_content(self.n_placeholder, self.n_content, self.cSize)
	end
end

function tipsCommon:SetShowState( iState )
	-- body
	self.iCurShowState_ = iState
	if iState == self.eShowState_.ShowCommon then
		self.m_plCompareOrDetail2:setVisible(true)
		self.m_plCompareOrDetail1:setVisible(false)
	else
		self.m_plCompareOrDetail2:setVisible(false)
		self.m_plCompareOrDetail1:setVisible(true)
	end
end

function tipsCommon:GetShowState( ... )
	-- body
	return self.iCurShowState_
end

function tipsCommon:refresh_content(parent, child, cSize)
	local content_tag = 1
	local n_content = parent:getChildByTag(content_tag)
	if n_content then removeFromParent(n_content) end

	local child_size = child:getContentSize()
	cSize.height = child_size.height
	parent:setContentSize(cSize)

	local parent_size = parent:getContentSize()
	n_content = Mnode.addChild(
	{
		parent = parent,
		child = child,
		anchor = cc.p(0, 1),
		pos = cc.p(0, parent_size.height),
		tag = content_tag,
	})

	self.n_scroll:updateInset() -- 调用它，否则滑动无动画
	self.n_scroll:setContentOffset(cc.p(0, self.vSize.height - cSize.height))
end

function tipsCommon:SetIsCompare( bCompare )
	-- body
	self.bCompare_ = bCompare
    self:SetPriceTagBgVisible(not bCompare)
end

function tipsCommon:SetPriceTagBgVisible(isVisible)
    if IsNodeValid(self.uiPrice_) then
		self.uiPrice_:setVisible(isVisible)
	end
	if IsNodeValid(self.uiMaxNum_) then
		self.uiMaxNum_:setVisible(isVisible)
	end
    if IsNodeValid(self.uiPriceBg_) then
		self.uiPriceBg_:setVisible(isVisible)
	end
end

function tipsCommon:ShowSwitchButton( bShow )
	-- body
	self.uiSwitch_:setVisible(bShow)
end

function tipsCommon:OnSwitchClick( sender, eventType )
	-- body
	-- GetUIHelper():ButtonEffect(sender, eventType)
	-- if eventType == ccui.TouchEventType.ended then
		Event.Dispatch(EventName.ReplaceCompare, self.iIndex_)
	-- end
end

function tipsCommon:SetIndex( iIndex )
	-- body
	self.iIndex_ = iIndex
end

function tipsCommon:GetIndex( ... )
	-- body
	return self.iIndex_
end

function tipsCommon:OnCompareOrDetailClick( sender, eventType )
	-- body
	-- GetUIHelper():ButtonEffect(sender, eventType)
	-- if eventType == ccui.TouchEventType.ended then
		if self.iCurShowState_ == self.eShowState_.ShowCommon then
			self:ShowCompare()
		else
			self:ShowCommon()
		end
	-- end
end

function tipsCommon:ShowCompareOrDetail( bShow )
	-- body
	self.uiCompareOrDetail_:setVisible(bShow)
end

function tipsCommon:dispose( ... )
	-- body
	if self.n_content then
		self.n_content:release()
		self.n_content = nil
	end
	Event.Remove(EventName.RefreshGridData, self)
end

return tipsCommon
