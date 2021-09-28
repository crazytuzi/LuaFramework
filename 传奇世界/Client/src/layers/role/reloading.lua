return { new = function(dressId,dstBag)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
--local res = "res/rolebag/role/"
local bag = MPackManager:getPack(MPackStruct.eBag)
local dress = MPackManager:getPack(MPackStruct.eDress)
-----------------------------------------------------------------------
local scrollViewBgWidth, scrollViewBgHeight = 370, 374
local tag_cellBg, tag_bgSel = 123, 456
-----------------------------------------------------------------------
local root = Mbaseboard.new( 
{
	src = "res/common/bg/bg27.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 3 },
	},
	title = {
		src = game.getStrByKey("reloading"),
		size = 24,
		color = MColor.lable_yellow,
		offset = { y = -27 },
	},
})
local rootSize = root:getContentSize()

createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(rootSize.width/2,rootSize.height/2+20),
        cc.size(scrollViewBgWidth + 2, scrollViewBgHeight + 2),--实际宽高比scrollViewBgWidth, scrollViewBgHeight小2了个像素
        4,
        cc.p(0.5,0.5)
    )

-----------------------------------------------------------------------
local buildList = function()
	
	local equips = MPackManager:getEquipList(dressId,dstBag)
	
	table.sort(equips, function(a, b)
		return MPackStruct.attrFromGird(a, MPackStruct.eAttrCombatPower) > 
		       MPackStruct.attrFromGird(b, MPackStruct.eAttrCombatPower)
	end)
	
	return equips
end
local list = buildList()
--dump(list, "list")

local equip = dress:getGirdByGirdId(dressId)
local curCombatPower = equip and MPackStruct.attrFromGird(equip, MPackStruct.eAttrCombatPower) or 0
-----------------------------------------------------------------------
-- 数据
local focused = #list > 0 and 0 or nil
-----------------------------------------------------------------------
-- TableView
local padding = 4
local iSize = cc.size(scrollViewBgWidth - padding * 2, 102)
local vSize = cc.size(scrollViewBgWidth - padding * 2, scrollViewBgHeight - padding - 4)
local tableView = cc.TableView:create(vSize)
tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
tableView:setDelegate()

local reloadData = function()
	tableView:reloadData()
end

tableView:registerScriptHandler(function(tv)
	return #list
end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

tableView:registerScriptHandler(function(tv, idx)
	return iSize.height, iSize.width
end, cc.TABLECELL_SIZE_FOR_INDEX)

local buildCellContent = nil
tableView:registerScriptHandler(function(tv, idx)
	local cell = tv:dequeueCell()
	if not cell then
		cell = cc.TableViewCell:new()
		cell:setContentSize(iSize)
		buildCellContent(tv, idx, cell)
	else
		buildCellContent(tv, idx, cell)
	end
	return cell
end, cc.TABLECELL_SIZE_AT_INDEX)

tableView:registerScriptHandler(function(tv, cell)
	cell:removeAllChildren()
end, cc.TABLECELL_WILL_RECYCLE)

tableView:registerScriptHandler(function(tv, cell)
	
	--dump("TABLECELL_HIGH_LIGHT")
end, cc.TABLECELL_HIGH_LIGHT)

tableView:registerScriptHandler(function(tv, cell)
	
	--dump("TABLECELL_UNHIGH_LIGHT")
end, cc.TABLECELL_UNHIGH_LIGHT)

local TABLECELL_TOUCHED = function(tv, cell)
	local idx = cell:getIdx()
	--dump("idx="..idx, "---------")
	
	if idx ~= focused then focused = idx end
	
	local x, y = cell:getPosition()
	local size = cell:getContentSize()
	local newX, newY = (x + size.width/2), (y + size.height/2)
    for k, cell in pairs(tableView:getContainer():getChildren()) do
        cell:getChildByTag(tag_cellBg):getChildByTag(tag_bgSel):setVisible(focused == cell:getIdx())
    end
end

tableView:registerScriptHandler(TABLECELL_TOUCHED, cc.TABLECELL_TOUCHED)

buildCellContent = function(tv, idx, cell)
	local item = list[idx+1]
	local grid = item
	local protoId = MPackStruct.protoIdFromGird(grid)
	local gridId = MPackStruct.girdIdFromGird(grid)
	
	local strength = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	local power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)

	local incCombatPower = power - curCombatPower
	local isInc = incCombatPower > 0
	local isRecommend = idx == 0 and isInc
	
	local cellSize = cell:getContentSize()
	local bgSize = cc.size(cellSize.width, cellSize.height - padding)
	
	local bg = Mnode.createScale9Sprite(
	{
		src = "res/common/scalable/item.png",
		cSize = bgSize,
	})
    bg:setTag(tag_cellBg)
    local bg_sel = Mnode.createScale9Sprite(
	{
		src = "res/common/scalable/item_sel.png",
		cSize = bgSize,
	})
    bg_sel:setTag(tag_bgSel)
    bg_sel:setPosition(getCenterPos(bg))
    bg_sel:setVisible(false)
    bg:addChild(bg_sel)
	Mnode.overlayNode(
	{
		parent = bg,
		nodes = 
		{
			[1] = {
				node = Mprop.new(
				{
					grid = grid,
					cb = "tips",
				}),
				
				origin = "l",
				offset = { x = 10, },
			},
			
			[2] = isRecommend and {
				node = Mnode.overlayNode(
				{
					parent = cc.Sprite:create("res/layers/shop/label/1.png"),
					{
						node = Mnode.createLabel(
						{
							src = game.getStrByKey("recommend_v"),
							size = 20,
							color = MColor.lable_yellow,
						}),
						
						offset = { y = 12, },
					}
				}),
				
				origin = "rt",
				offset = { x = -5, },
			} or nil,
		}
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = Mnode.createLabel(
		{
			src = MpropOp.name(protoId),
			size = 20,
			color = MpropOp.nameColor(protoId),
		}),
		anchor = cc.p(0, 0.5),
		pos = cc.p(100, 71),
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = Mnode.combineNode(
		{
			nodes = {
				Mnode.createLabel(
				{
					src = game.getStrByKey("combat_power").." :",
					size = 20,
					color = MColor.lable_black,
				}),

                Mnode.createLabel(
				{
					src = power,
					size = 20,
					color = MColor.drop_white,
				}),

				Mnode.createLabel(
				{
					src = math.abs(incCombatPower),
					size = 20,
					color = isInc and MColor.green or MColor.red,
				}),

                cc.Sprite:create("res/group/arrows/" .. (isInc and "1" or "2") .. ".png"),
			},
			
			margins = { 5, 25, 5 },
		}),
		
		anchor = cc.p(0, 0.5),
		pos = cc.p(100, 30),
	})
	
	if idx == focused then
		bg:registerScriptHandler(function(event)
			if event == "enter" then
				TABLECELL_TOUCHED(tv, cell)
			elseif event == "exit" then
				
			end
		end)
	end
	
	Mnode.overlayNode({ parent = cell, { node = bg, } })
end

reloadData()

Mnode.addChild(
{
	parent = root,
	child = tableView,
	anchor = cc.p(0.5, 1),
	pos = cc.p(rootSize.width / 2, rootSize.height - 61),
})

-- 换装按钮
local n_click_menu, n_click_btn = MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	label = {
		src = game.getStrByKey("reloading"),
		size = 22,
		color = MColor.lable_yellow,
	},
	pos = cc.p(rootSize.width/2, 50),
	nodefaultMus = true,
	cb = function(tag, node)
		local touchIdx = focused
		AudioEnginer.playEffect("sounds/uiMusic/ui_weapon.mp3",false)
		if touchIdx ~= nil then
			local item = list[touchIdx+1]
			--dump(item, "item")
			local gridId = MPackStruct.girdIdFromGird(item)
			--dump(gridId, "gridId")
			MPackManager:dress(gridId, dressId)
			if root then removeFromParent(root) root = nil end
		end
	end,
})

if #list < 1 then n_click_btn:setEnabled(false) end
-----------------------------------------------------------------------
return root
end }