require("src/layers/newEquipment/NewEquipmentHandler")
local reloadView = function(root, params)
	-----------------------------------------------------------------------
	local MMenuButton = require "src/component/button/MenuButton"
	local Mbaseboard = require "src/functional/baseboard"
	local MpropOp = require "src/config/propOp"
	local Mprop = require "src/layers/bag/prop"
	local MequipOp = require "src/config/equipOp"
	local Mconvertor = require "src/config/convertor"
	-----------------------------------------------------------------------
	local layer = root.layer
	layer:removeAllChildren()
	local layer_size = layer:getContentSize()
	----------------------------
	local packId = params.packId
	if packId then
		root.m_bubble:setVisible(false)
	else
		root.m_bubble:setVisible(true)
	end
	local pack = MPackManager:getPack(packId)
	local grid = params.grid
	local gridId = MPackStruct.girdIdFromGird(grid)
	local protoId = MPackStruct.protoIdFromGird(grid)
	local attrCate = MequipOp.specialAttrCate(protoId)
	local isRange = Mconvertor.isRangeAttr(attrCate)
	
	local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
	local eachLayerValue = MequipOp.specialAttrEachLayerValue(protoId)
	local specialAttr = MPackStruct.specialAttrFromGird(grid) or 0
	
	local reloadData = function(gridObj)
		if gridObj ~= nil then grid = gridObj end
		specialAttr = MPackStruct.specialAttrFromGird(grid) or 0
	end
	----------------------------
	-- 被点金icon
	local srcIcon = Mprop.new(
	{
		grid = grid,
		strengthLv = strengthLv,
	})
	MpropOp.createColorName(grid, layer, cc.p(layer_size.width/2, 200), cc.p(0.5,0.5), 22)
	Mnode.addChild(
	{
		parent = layer,
		child = srcIcon,
		pos = cc.p(layer_size.width/2, 265),
	})
	
	-- 极品属性
	local build_attr = function()
		local node = layer:getChildByTag(1)
		if node ~= nil then node:removeFromParent() end
		
		if attrCate == nil then return end
		
		local str = ""
		str = str .. Mconvertor.attrName(attrCate) .. ": "
		if isRange then str = str .. "0-" end
		str = str .. tostring(eachLayerValue * specialAttr)
		local strColor=getSpecialAttrLevelColor(specialAttr)
		if specialAttr >= maxLayer then
			str = str .. " (最大值)"
		end
		if eachLayerValue * specialAttr > 0 then
			local n_attr = Mnode.createLabel(
			{
				src = str,
				size = 20,
				color = strColor,
			})
			
			Mnode.addChild(
			{
				parent = layer,
				child = n_attr,
				pos = cc.p(layer_size.width/2, 168),
				tag = 1,
			})
		end
	end
	
	build_attr()
	
	-- 点金按钮
	local gold_menu, gold_btn = MMenuButton.new(
	{
		parent = layer,
		pos = cc.p(layer_size.width/2, 60),
		src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
		label = {
			src = game.getStrByKey("gold_pointing"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			local t = {}
			t.bagIndex = packId
			t.itemIndex = gridId
			--dump(t, "t")
			g_msgHandlerInst:sendNetDataByTable(ITEM_CS_RESET_SPECIAL, "ItemResetSpecialProtocol", t)
		end,
		
		noInsane = 0.5,
	})
	--G_TUTO_NODE:setTouchNode(gold_menu, TOUCH_WISH_WISH)
	
	if specialAttr >= maxLayer then
		gold_btn:setEnabled(false)
	end
	
	
	local onPackChanged = function(pack, event, id)
		if (id == gridId) and (event == "=" or event == "+") then
			reloadData(pack:getGirdByGirdId(id))
			build_attr()
			
			if specialAttr >= maxLayer then
				gold_btn:setEnabled(false)
			end
		end
	end
	
	local tmp = cc.Node:create()
	tmp:registerScriptHandler(function(event)
		--dump({event=event }, "----------")
		if event == "enter" then
			pack:register(onPackChanged)
			
			g_msgHandlerInst:registerMsgHandler(ITEM_SC_RESET_SPECIAL_RET, function(buff)
				dump(ITEM_SC_RESET_SPECIAL_RET, "使用点金石给装备点金返回")
				
				local t = g_msgHandlerInst:convertBufferToTable("ItemResetSpecialRetProtocol", buff)
				--dump(t, "装备强化返回")
				local pid = t.bagIndex
				local gid = t.itemIndex
				local result = t.retValue
				----------------
				dump({pid=pid, gid=gid, result=result}, "使用点金石给装备点金返回")
				
				if pid ~= packId or gid ~= gridId then
					dump("what happened?!")
					return
				end
				
				if result == 1 then -- 成功
					--specialAttr = specialAttr + 1
					TIPS({ type = 1  , str = "点金成功, 属性值增加"})
					AudioEnginer.playEffect("sounds/upSuccess.mp3",false)
					local animateSpr = Effects:create(true)
					animateSpr:playActionData("equipRefine", 27, 1.9, 1)
					Mnode.addChild(
					{
						parent = root,
						child = animateSpr,
						pos = cc.p(layer_size.width/2, 265),
						zOrder = 1000,
					})
				elseif result == 2 then -- 不变
					TIPS({ type = 1  , str = "点金失败, 属性值不变"})
				elseif result == 3 then -- 失败
					--specialAttr = specialAttr - 1
					TIPS({ type = 1  , str = "点金失败, 属性值降低"})
					AudioEnginer.playEffect("sounds/upFail.mp3",false)
				else
					dump("what happened?", "使用祝福油给武器祝福返回")
				end
			end)
		elseif event == "exit" then
			pack:unregister(onPackChanged)
			g_msgHandlerInst:registerMsgHandler(ITEM_SC_RESET_SPECIAL_RET, nil)
		end
	end)
	gold_btn:addChild(tmp)
end
--极品属性层级对应显示颜色
local tSpecialAttrLevelColor = {
	[1] = MColor.green,
	[2] = MColor.green,
	[3] = MColor.blue,
	[4] = MColor.blue,
	[5] = MColor.purple,
	[6] = MColor.purple,
	[7] = MColor.orange,
}
getSpecialAttrLevelColor=function (lv)
    return tSpecialAttrLevelColor[lv] or MColor.lable_yellow
end
return { new = function(params)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
-----------------------------------------------------------------------
local res = "res/layers/equipment/strengthen/"
local bag = MPackManager:getPack(MPackStruct.eBag)
local dress = MPackManager:getPack(MPackStruct.eDress)
-----------------------------------------------------------------------
local now_item = {packId=params.packId, grid=params.grid}
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg27.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = 0, y = 3 },
	},
	title = {
		src = game.getStrByKey("gold_pointing"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})
--G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_WISH_CLOSE)

local rootSize = root:getContentSize()
-----------------------------------------------------------------------------------
local right_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg44-5.png",
	pos = cc.p(rootSize.width/2, rootSize.height/2-20),
})

local right_bg_size = right_bg:getContentSize()

---[[
-- 帮助按钮
local n_prompt = __createHelp(
{
	parent = right_bg,
	str = require("src/config/PromptOp"):content(68),
	pos = cc.p(30, right_bg_size.height-30),
})

--n_prompt:setScale(1)
--]]
-----------------------------------------------------------------------
-- 点金消耗材料
function refreshRichText()
    --todo:找策划核对一下颜色
    local tag_richText = 20
    while root:getChildByTag(tag_richText) do
        root:removeChildByTag(tag_richText)
    end
    local material_id = 5018
    local pos_x_left, pos_x_right = 50, 245
    local label_font_size = 20
    local line_height = 30
    local richTextSize_width = 960
    local pos_y_target_item_line = 123
    local own_num_item = bag:countByProtoId(material_id)
    local cost_num_item = 1
    local richText_cost_item = require("src/RichText").new(root, cc.p(pos_x_left, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_cost_item:setTag(tag_richText)
    richText_cost_item:setAutoWidth()
    richText_cost_item:addText(
        "^c(lable_yellow)" .. game.getStrByKey("consume") .. ":^"
    )
    richText_cost_item:addTextItem(MpropOp.name(material_id), MpropOp.nameColor(material_id), false, false, true, function()
        local Mtips = require "src/layers/bag/tips"
		Mtips.new(
		{ 
			protoId = material_id,
			pos = cc.p(0, 0),
		})
    end)
    richText_cost_item:addText(
        (own_num_item >= cost_num_item and "^c(green)x" or "^c(red)x") .. numToFatString(cost_num_item) .. "^"
    )
    richText_cost_item:format()
    --加入超链接下方的横线
    local linkNode = richText_cost_item:getChildren()[1]:getChildren()[1]:getChildren()[3]--link item道具名

    drawUnderLine(linkNode, MpropOp.nameColor(material_id))

	-- local label = cc.Label:createWithTTF("_", g_font_path, 18)
	-- label:setAnchorPoint(cc.p(0, 0))
	-- label:setPosition(cc.p(linkNode:getPositionX(), linkNode:getPositionY() - 2))
	-- local scale = linkNode:getContentSize().width / label:getContentSize().width
	-- label:setScaleX(scale)
	-- label:setColor(MpropOp.nameColor(material_id))
 --    linkNode:getParent():addChild(label)


    local richText_own_item = require("src/RichText").new(root, cc.p(pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_own_item:setTag(tag_richText)
    richText_own_item:setAutoWidth()
    richText_own_item:addText(
        "^c(lable_yellow)" .. game.getStrByKey("own") .. ":^"
        .. numToFatString(own_num_item)
    )
    richText_own_item:format()
end
function registerFunc(observable, event, pos, pos1, new_grid)
    if not (event == "-" or event == "+" or event == "=") then return end
    refreshRichText()
end
refreshRichText()
-----------------------------------------------------------------------
-- 加号
Mnode.createSprite(
{
	parent = root,
	src = "res/layers/equipment/jia.png",
	pos = cc.p(rootSize.width/2, 265),
})
root.m_bubble = GetUIHelper():createBubble(root, cc.p(rootSize.width/2, 330), cc.p(0.5, 0.5), nil, "请添加要点金的装备", 20, false, nil, MColor.lable_yellow, true)
local placeholder = Mnode.createNode(
{
	parent = root,
	cSize = cc.size(80, 80),
	pos = cc.p(rootSize.width/2, 265),
})

-- 提示信息
local n_jia_tips = Mnode.createLabel(
{
	parent = root,
	src = "选择需要点金的装备",
	pos = cc.p(rootSize.width/2, 168),
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
						
						local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
						local specialAttr = MPackStruct.specialAttrFromGird(grid) or 0
						
						return specialAttr < maxLayer
					end,
					handler = function(item)
						now_item = item
						n_jia_tips:setVisible(false)
						reloadView(root, item)
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
-----------------------------------------------------------------------
-- 内容层
local layer = Mnode.createNode(
{
	parent = root,
	cSize = rootSize,
	pos = cc.p(rootSize.width/2, rootSize.height/2),
})

root.layer = layer

if now_item.packId ~= nil then reloadView(root, now_item) end
-----------------------------------------------------------------------
root:registerScriptHandler(function(event)
	if event == "enter" then
		--G_TUTO_NODE:setShowNode(root, SHOW_WISH)
        bag:register(registerFunc)
		clearDirect()
		setEquipRedirect(true)
	elseif event == "exit" then
        bag:unregister(registerFunc)
		trigEquipRedirect()
	end
end)
-----------------------------------------------------------------------
return root
end 
}