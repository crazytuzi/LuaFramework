return { new = function(params)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local Mcheckbox = require "src/component/checkbox/view"
-----------------------------------------------------------------------
local res1 = "res/layers/equipment/strengthen/"
local res2 = "res/layers/equipment/inheritance/"
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local now_item = {packId=params.packId, grid=params.grid}
local now_item_b = {}
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 4 },
	},
	title = {
		src = game.getStrByKey("lineage"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_EQUIPMENT_TRANSMIT_CLOSE)

local rootSize = root:getContentSize()
-----------------------------------------------------------------------------------
local checkbox1, checkbox2 = nil, nil
local srcIcon, dstIcon = nil, nil
local onChangeSrc = nil
local n_click_menu, n_click_btn = nil, nil
-----------------------------------------------------------------------------------
local refreshVsData = function()
	if now_item.grid == nil or now_item_b.grid == nil or dstIcon == nil then return end
	
	local srcProtoId = MPackStruct.protoIdFromGird(now_item.grid)
	local srcSLV = MPackStruct.attrFromGird(now_item.grid, MPackStruct.eAttrStrengthLevel)
	-- 免费传承掉级
	local loseLv = MequipOp.upStrengthInheritLoseLv(srcProtoId, srcSLV)
	
	local dstProtoId = MPackStruct.protoIdFromGird(now_item_b.grid)
	local quality = MpropOp.quality(dstProtoId, now_item_b.grid)
	local sLvMax = MequipOp.upStrengthRUL(dstProtoId, quality)
	
	local ret = nil
	if checkbox1:value() then
		ret = srcSLV
	else
		ret = math.max(srcSLV - loseLv, 0)
	end
	local next_slv = math.min(sLvMax, ret)
	
	dstIcon:setStrengthLv(next_slv)
	if next_slv < srcSLV then dstIcon:setStrengthLvColor(MColor.red) end
end
-----------------------------------------------------------------------------------
-- 底板
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg44-6.png",
	pos = cc.p(rootSize.width/2, rootSize.height/2-20),
})

-- n_icon_now_bg
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg3.png",
	pos = cc.p(175, 340),
})

Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg3-1.png",
	pos = cc.p(175, 340),
})

-- 箭头
Mnode.createSprite(
{
	parent = root,
	src = "res/group/arrows/17.png",
	pos = cc.p(400, 340),
})

-- n_icon_next_bg
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg3.png",
	pos = cc.p(620, 340),
})

Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg3-1.png",
	pos = cc.p(620, 340),
})

-- 下底板
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg18-8.png",
	pos = cc.p(rootSize.width/2, 85),
})

-- 帮助按钮
local help_prompt = __createHelp(
{
	parent = root,
	str = require("src/config/PromptOp"):content(54),
	pos = cc.p(70, 175),
})

help_prompt:setScale(0.8)
---------------------------------------------------------------------
-- 加号
Mnode.createSprite(
{
	parent = root,
	src = "res/layers/equipment/jia.png",
	pos = cc.p(175, 340),
})

local placeholder = Mnode.createNode(
{
	parent = root,
	cSize = cc.size(80, 80),
	pos = cc.p(175, 340),
})

-- 提示信息
local n_jia_tips = Mnode.createLabel(
{
	parent = root,
	src = "选择传承的装备",
	pos = cc.p(175, 221),
	size = 20,
	color = MColor.lable_yellow,
})

n_jia_tips:setVisible(now_item.packId == nil)

-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = placeholder,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			
			local Mreloading = require "src/layers/equipment/equip_select"
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				node = Mreloading.new(
				{
					now = now_item,
					filtrate = function(packId, grid, now)
						local MequipOp = require "src/config/equipOp"
						local MpropOp = require "src/config/propOp"
						local Mconvertor = require "src/config/convertor"
						
						local protoId = MPackStruct.protoIdFromGird(grid)
						-- 是否是勋章
						local isMedal = protoId >= 30004 and protoId <= 30006
						if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
							return false
						end
						
						local gridId = MPackStruct.girdIdFromGird(grid)
						local now_gridId = MPackStruct.girdIdFromGird(now.grid)
						if packId == now.packId and gridId == now_gridId then return false end
						
						local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
						if strengthLv < 1 then return false end

						local quality = MpropOp.quality(protoId)
						if quality < 3 then return false end -- 蓝色品质以上才可传承
						
						return true
					end,
					handler = function(item)
						now_item = item
						onChangeSrc()
					end,
					
					act_src = "放入",
				}),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
		end
	end,
})
--------------------------
-- 加号
Mnode.createSprite(
{
	parent = root,
	src = "res/layers/equipment/jia.png",
	pos = cc.p(620, 340),
})

local placeholder_b = Mnode.createNode(
{
	parent = root,
	cSize = cc.size(80, 80),
	pos = cc.p(620, 340),
})

-- 提示信息
local n_jia_tips_b = Mnode.createLabel(
{
	parent = root,
	src = "选择被传承的装备",
	pos = cc.p(620, 221),
	size = 20,
	color = MColor.lable_yellow,
})
G_TUTO_NODE:setTouchNode(placeholder_b, TOUCH_EQUIPMENT_TRANSMIT_CHOSE)

-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = placeholder_b,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			
			if now_item.packId == nil then
				TIPS({ type = 1  , str = "请先选定传承装备"})
				return
			end
			
			local srcProtoId = MPackStruct.protoIdFromGird(now_item.grid)
			local srcSLV = MPackStruct.attrFromGird(now_item.grid, MPackStruct.eAttrStrengthLevel)
			
			local Mreloading = require "src/layers/equipment/equip_select"
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				node = Mreloading.new(
				{
					now = now_item,
					filtrate = function(packId, grid, now)
						local MequipOp = require "src/config/equipOp"
						local MpropOp = require "src/config/propOp"
						local Mconvertor = require "src/config/convertor"
						
						local protoId = MPackStruct.protoIdFromGird(grid)
						-- 是否是勋章
						local isMedal = protoId >= 30004 and protoId <= 30006
						if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
							return false
						end
						
						local gridId = MPackStruct.girdIdFromGird(grid)
						local now_gridId = MPackStruct.girdIdFromGird(now.grid)
						if packId == now.packId and gridId == now_gridId then return false end
						
						local quality = MpropOp.quality(protoId)
						if quality < 3 then return false end -- 蓝色品质以上才可传承
						
						-- 物品等级
						local  srcReal = MpropOp.levelLimits(srcProtoId)
						local real = MpropOp.levelLimits(protoId)
						if real < srcReal then return false end
						
						local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
						if MequipOp.kind(protoId) == MequipOp.kind(srcProtoId) and strengthLv < srcSLV then
							return true
						end
						
						return false
					end,
					handler = function(item)
						now_item_b = item
						n_jia_tips_b:setVisible(false)
						
						if dstIcon ~= nil then dstIcon:removeFromParent() end
						dstIcon = Mprop.new(
						{
							grid = item.grid,
							strengthLv = MPackStruct.attrFromGird(item.grid, MPackStruct.eAttrStrengthLevel),
						})
						
						local packId = now_item_b.packId
						local gridId = MPackStruct.girdIdFromGird(now_item_b.grid)
						local pack = MPackManager:getPack(packId)
						
						local tmp_func = function(pack, event, id)
							if (pack:packId() == packId) and (id == gridId) and (event == "=" or event == "+") then
								local new_grid = pack:getGirdByGirdId(id)
								now_item_b = {packId=packId, grid=new_grid}
							end
						end

						dstIcon:registerScriptHandler(function(event)
							if event == "enter" then
								pack:register(tmp_func)
							elseif event == "exit" then
								pack:unregister(tmp_func)
							end
						end)

						Mnode.addChild(
						{
							parent = root,
							child = dstIcon,
							pos = cc.p(620, 340),
							zOrder = 1,
						})
						
						n_click_btn:setEnabled(true)
						
						refreshVsData()
					end,
					
					act_src = "放入",
				}),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
		end
	end,
})
------------------------------------------------------------------------
-- 增加成功几率的道具
local id, num = 9001, 1
local own_num = bag:countByProtoId(id)
local bc_name = MpropOp.name(id)

-- 复选框
checkbox1 = Mcheckbox.new(
{
	label = {
		src = game.getStrByKey("use") .. bc_name .. game.getStrByKey("ensure")..game.getStrByKey("perfect")..game.getStrByKey("lineage"),
		size = 18,
		color = MColor.lable_black,
	},
	
	margin = 5,
	
	cb = function(value)
		if not value and checkbox2:value() then
			checkbox2:setValue(false)
		end
		
		refreshVsData()
	end
})
	
Mnode.addChild(
{
	parent = root,
	child = checkbox1,
	anchor = cc.p(0, 0.5),
	pos = cc.p(56, 103),
})
	
checkbox2 = Mcheckbox.new(
{
	label = {
		src = bc_name .. game.getStrByKey("strengthen_cost_num_tips"),
		size = 18,
		color = MColor.lable_black,
	},
	
	margin = 5,
	
	cb = function(value)
		if value and not checkbox1:value() then
			checkbox1:setValue(true)
			refreshVsData()
		end
	end
})

Mnode.addChild(
{
	parent = root,
	child = checkbox2,
	anchor = cc.p(0, 0.5),
	pos = cc.p(56, 60),
})

local nodes = {}

nodes[#nodes+1] = Mnode.createLabel(
{
	src = "消耗",
	size = 18,
	color = MColor.white,
})

local n_probability = Mnode.createLabel(
{
	src = bc_name,
	size = 20,
	color = MpropOp.nameColor(id),
	--anchor = cc.p(0, 0.5),
	--pos = cc.p(350, 103),
})

nodes[#nodes+1] = n_probability

-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = n_probability,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{
				protoId = id,
			})
		end
	end,
})

nodes[#nodes+1] = Mnode.createLabel(
{
	src = "      个",
	size = 18,
	color = MColor.lable_black,
})

Mnode.addChild(
{
	parent = root,
	child = Mnode.combineNode(
	{
		nodes = nodes,
	}),
	anchor = cc.p(0, 0.5),
	pos = cc.p(325, 103),
})

local cost_material = Mnode.createLabel(
{
	parent = root,
	src = "--",
	size = 18,
	color = MColor.lable_black,
	pos = cc.p(462, 103),
})

-- 拥有材料数目
local own_material = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("own").."：",
		size = 18,
		color = MColor.white,
	}),
	
	v = {
		src = own_num .. game.getStrByKey("entry"),
		size = 18,
		color = own_num < num and MColor.red or MColor.green,
	},
})

local tmp_func = function(observable, event, pos, pos1, new_grid)
	if event == "-" or event == "+" or event == "=" then
		own_num = bag:countByProtoId(id)
		own_material:setValue(
		{
			text = own_num .. game.getStrByKey("entry"),
			color = own_num < num and MColor.red or MColor.green,
		})
	end
end

own_material:registerScriptHandler(function(event)
	if event == "enter" then
		bag:register(tmp_func)
	elseif event == "exit" then
		bag:unregister(tmp_func)
	end
end)

Mnode.addChild(
{
	parent = root,
	child = own_material,
	anchor = cc.p(0, 0.5),
	pos = cc.p(510, 103),
})

-- 消耗金币
local bind_coin = MRoleStruct:getAttr(PLAYER_MONEY)
local coin_node = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "消耗金币：",
		size = 18,
		color = MColor.white,
	}),
	
	v = {
		src = "--",
		size = 18,
		color = MColor.lable_black,
	}
})

Mnode.addChild(
{
	parent = root,
	child = coin_node,
	anchor = cc.p(0, 0.5),
	pos = cc.p(360, 60),
})

-- 拥有金币数目
local own_coin = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("own").."：",
		size = 18,
		color = MColor.white,
	}),
	
	v = {
		src = numToFatString(bind_coin),
		size = 18,
		color = MColor.lable_yellow,
	},
})

-- 货币数值发生了变化
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if not isMe then return end
	if attrId == PLAYER_MONEY then
		bind_coin = MRoleStruct:getAttr(PLAYER_MONEY)
		own_coin:setValue(
		{
			text = numToFatString(bind_coin),
			color = MColor.lable_yellow,
		})
	end
end

own_coin:registerScriptHandler(function(event)
	if event == "enter" then
		MRoleStruct:register(onDataSourceChanged)
	elseif event == "exit" then
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)

Mnode.addChild(
{
	parent = root,
	child = own_coin,
	anchor = cc.p(0, 0.5),
	pos = cc.p(510, 60),
})
-----------------------------------------------------------------------
-- 传承按钮
n_click_menu, n_click_btn = MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
	label = {
		src = game.getStrByKey("start")..game.getStrByKey("lineage"),
		size = 25,
		color = MColor.lable_yellow,
	},
	
	pos = cc.p(720, 85),
	
	cb = function(tag, node)
		if now_item.grid ~= nil and now_item_b.grid ~= nil then
			MPackManager:inheritEquip(now_item.packId, MPackStruct.girdIdFromGird(now_item.grid), now_item_b.packId, MPackStruct.girdIdFromGird(now_item_b.grid), checkbox1:value(), checkbox2:value())
		else
			TIPS({ type = 1  , str = game.getStrByKey("lineage_select_tips") })
		end
	end,
})

n_click_btn:setEnabled(false)

G_TUTO_NODE:setTouchNode(n_click_menu, TOUCH_EQUIPMENT_TRANSMIT_CONFIRM)


onChangeSrc = function()
	n_click_btn:setEnabled(false)
	n_jia_tips:setVisible(false)
						
	if srcIcon ~= nil then
		srcIcon:removeFromParent()
		srcIcon = nil
	end
	
	if now_item.packId == nil then
		n_jia_tips:setVisible(true)
		return
	end
	
	srcIcon = Mprop.new(
	{
		grid = now_item.grid,
		strengthLv = MPackStruct.attrFromGird(now_item.grid, MPackStruct.eAttrStrengthLevel),
	})
	
	local packId = now_item.packId
	local gridId = MPackStruct.girdIdFromGird(now_item.grid)
	local pack = MPackManager:getPack(packId)
	
	local tmp_func = function(pack, event, id)
		if (pack:packId() == packId) and (id == gridId) and (event == "=" or event == "+") then
			local new_grid = pack:getGirdByGirdId(id)
			now_item = {packId=packId, grid=new_grid}
		end
	end

	srcIcon:registerScriptHandler(function(event)
		if event == "enter" then
			pack:register(tmp_func)
		elseif event == "exit" then
			pack:unregister(tmp_func)
		end
	end)

	Mnode.addChild(
	{
		parent = root,
		child = srcIcon,
		pos = cc.p(175, 340),
		zOrder = 1,
	})
	
	n_jia_tips_b:setVisible(true)
	if dstIcon ~= nil then
		dstIcon:removeFromParent()
		dstIcon = nil
	end
	now_item_b = {}
	
	
	local srcProtoId = MPackStruct.protoIdFromGird(now_item.grid)
	local srcSLV = MPackStruct.attrFromGird(now_item.grid, MPackStruct.eAttrStrengthLevel)
	local id, num = MequipOp.upStrengthInheritMaterialNeed(srcProtoId, srcSLV)
	cost_material:setString(tostring(num))
			
	local cost_coin = MequipOp.upStrengthInheritCoinNeed(srcProtoId, srcSLV)
	coin_node:setValue(
	{
		text = numToFatString(cost_coin),
		color = bind_coin < cost_coin and MColor.red or MColor.green,
	})
end

if now_item.packId ~= nil then onChangeSrc() end
-----------------------------------------------------------------------
local onDressChanged = function(dress, event, id, new_grid)
	if event == "inherit" then
		now_item = {}
		onChangeSrc()
		
		TIPS({ type = 1  , str = game.getStrByKey("lineage")..game.getStrByKey("success") })
		AudioEnginer.playEffect("sounds/upSuccess.mp3",false)
		local animateSpr = Effects:create(false)
		performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,2)
		animateSpr:playActionData("equipInherit", 29, 2, 1)
		Mnode.addChild(
		{
			parent = root,
			child = animateSpr,
			pos = cc.p(400, 300),
			zOrder = 1000,
		})
	end
end

root:registerScriptHandler(function(event)
	local dress = MPackManager:getPack(MPackStruct.eDress)
	if event == "enter" then
		dress:register(onDressChanged)
	elseif event == "exit" then
		dress:unregister(onDressChanged)
	end
end)
-----------------------------------------------------------------------
return root
end }