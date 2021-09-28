return { new = function(protoId)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local Mprop = require "src/layers/bag/prop"
-----------------------------------------------------------------------
local res = "res/layers/equipment/"
local MpropOp = require "src/config/propOp"
local equipinfo = getConfigItemByKey("equipCfg","q_id",protoId)
-----------------------------------------------------------------------
local protoId = protoId or 5010101
-----------------------------------------------------------------------
local return_node = cc.Layer:create()
local root = Mbaseboard.new(
{
	src = "res/common/2.jpg",
	
	close = {
		src = "res/component/button/6.png",
	},
	parent = return_node,
})

local rootSize = root:getContentSize()
-----------------------------------------------------------------------
-- 装备描述
-- 左边
local des_bg = Mnode.createSprite(
{
	src = res .. "14.jpg",
	parent = root,
	pos = cc.p(310, 352),
})

local des_bg_size = des_bg:getContentSize()

-- 装备图标
local equip_icon = Mprop.new(
{
	protoId = protoId,
	quality = 10
})

Mnode.addChild(
{
	parent = des_bg,
	child = equip_icon,
	pos = cc.p(des_bg_size.width/2+13, 298),
})

-- 装备名字
Mnode.createLabel(
{
	src = MpropOp.name(protoId),
	size = 23,
	color = MColor.yellow,
	parent = des_bg,
	pos = cc.p(des_bg_size.width/2+13, 240),
})

-- 描述
Mnode.createLabel(
{
	src = MpropOp.description1(protoId),
	size = 22,
	color = MColor.yellow,
	parent = des_bg,
	pos = cc.p(des_bg_size.width/2+13, 144),
	bound = cc.size(525, 0),
})

-- 装备类型
local type_map = {game.getStrByKey("weapon"),game.getStrByKey("ring"),game.getStrByKey("necklace"),game.getStrByKey("shoe"),game.getStrByKey("clothing"),game.getStrByKey("cuff"),game.getStrByKey("helmet"),game.getStrByKey("eBelt")}
Mnode.createLabel(
{
	src = type_map[equipinfo.q_kind],
	size = 25,
	color = MColor.yellow,
	parent = des_bg,
	pos = cc.p(des_bg_size.width/2+13, 55),
})
-----------------------------------------------------------------------
local src_config = {
	{
		title = game.getStrByKey("monster")..game.getStrByKey("drop_out"),
	},
	
	{
		title = game.getStrByKey("shop")..game.getStrByKey("buy"),
	},
	
	{
		title = game.getStrByKey("activity")..game.getStrByKey("output"),
	},
	
	{
		title = game.getStrByKey("fuben")..game.getStrByKey("output"),
	},
	
	{
		title = game.getStrByKey("other")..game.getStrByKey("way"),
	},
}
-- 来源一级列表
local src1_bg = Mnode.createSprite(
{
	src = res .. "16.png",
	parent = root,
	pos = cc.p(312, 85),
})
-- 来源二级列表
local src2_bg = Mnode.createSprite(
{
	src = res .. "15.png",
	parent = root,
	pos = cc.p(775, 285),
})

local src2_bg_size = src2_bg:getContentSize()
-- 标题
local src2_title = Mnode.createLabel(
{
	src = src_config[1].title,
	size = 25,
	color = MColor.lable_yellow,
	pos = cc.p(src2_bg_size.width/2, src2_bg_size.height-30),
	parent = src2_bg,
})
-----------------------------------------------------------------------

-- TabView
local vSize = cc.size(335, 482)
local cSize = cc.size(335, 98)

local tableView = cc.TableView:create(vSize)
local load_data = {}
local info_data = {}
local active_tab = {}
local select_index = 0
local getLoadDateByFlag = function(flag)
	if select_index ~= flag then
		load_data = {}
		local map_flag = {"gwly1","hdjm","hdjm1","dyjm21","dyjm31"}
		local load_strs = equipinfo[map_flag[flag]]
		select_index = flag
		if load_strs then
			load_data = stringsplit(load_strs, ";")
			local sub_map_flag = {"dyzb","dyjm","dyjm2","dyjm3","dyjm4"}
			local go_strs = equipinfo[sub_map_flag[select_index]]
			if go_strs then
				local temp_data = stringsplit(go_strs, ";")
				for k,v in pairs(temp_data)do
					info_data[k] = stringsplit(v, ",")
				end
			end
		end
		src2_title:setString(src_config[flag].title)
	end
end
--TabView end

local src1_bg_size = src1_bg:getContentSize()
local dumy_pos = cc.p(0, 0)
local getbtns = {}
-- 怪物掉落
getbtns[#getbtns+1] = createTouchItem(nil, res .. "17.png", dumy_pos, function()
	getLoadDateByFlag(1)
	tableView:reloadData()
end, true)

--monster_drop:addColorGray()

-- 商店购买
getbtns[#getbtns+1] = createTouchItem(nil, res .. "18.png", dumy_pos, function()
	getLoadDateByFlag(2)
	tableView:reloadData()
end, true)

--shop_buy:addColorGray()

-- 活动产出
getbtns[#getbtns+1] = createTouchItem(nil, res .. "19.png", dumy_pos, function()
	getLoadDateByFlag(3)
	tableView:reloadData()
end, true)

--activity_output:addColorGray()

-- 副本产出
getbtns[#getbtns+1] = createTouchItem(nil, res .. "20.png", dumy_pos, function()
	getLoadDateByFlag(4)
	tableView:reloadData()
end, true)

--fuben_output:addColorGray()

-- 其他途径
getbtns[#getbtns+1] = createTouchItem(nil, res .. "21.png", dumy_pos, function()
	getLoadDateByFlag(5)
	tableView:reloadData()
end, true)


--other_way:addColorGray()

Mnode.addChild(
{
	parent = src1_bg,
	child = Mnode.combineNode(
	{
		nodes = {
			getbtns[1],
			getbtns[2],
			getbtns[3],
			getbtns[4],
			getbtns[5],
		},
		margins = 20,
	}),
	pos = cc.p(src1_bg_size.width/2, src1_bg_size.height/2),
})
local select_id = nil
for k,v in ipairs(getbtns)do 
	getLoadDateByFlag(k)
	if #load_data == 0 then
		v:setEnable(false)
	elseif not select_id then
		select_id = k
	end
end

-- TabView

tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
tableView:setDelegate()

tableView:registerScriptHandler(function(tv)
	return #load_data
end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

tableView:registerScriptHandler(function(tv, idx)
	return cSize.height, cSize.width
end, cc.TABLECELL_SIZE_FOR_INDEX)

tableView:registerScriptHandler(function(tv, cell)
	cell:removeAllChildren()
end, cc.TABLECELL_WILL_RECYCLE)

tableView:registerScriptHandler(function(tv,cell) 
	local index = cell:getIdx()
	if active_tab[index] then
		if select_index == 1 then
			--dump(info_data[index+1])
			local data = info_data[index+1]
			require("src/layers/spiritring/TransmitNode").new(tonumber(data[1]),tonumber(data[2]),tonumber(data[3]))
		else
			local data = info_data[index+1]
			if data then
				if data[2] then
					__GotoTarget( { ru = data[2] } )
				else
					MessageBox(tostring(equipinfo.dyjmtsjj), "")
				end
			else
				MessageBox(tostring(equipinfo.dyjmtsjj), "")
			end
		end
	end
end,cc.TABLECELL_TOUCHED)

local MRoleStruct = require("src/layers/role/RoleStruct")
local m_lv = MRoleStruct:getAttr(ROLE_LEVEL)

tableView:registerScriptHandler(function(tv, idx)
	local cell = tv:dequeueCell()
    if not cell then cell = cc.TableViewCell:new() end
	
	local entrance = GraySprite:create("res/component/button/33.png")
	if entrance then
		entrance:setPosition(cc.p(cSize.width/2, cSize.height/2))
		cell:addChild(entrance)
		local q_lv = 0
		if info_data[idx+1] then
			q_lv = tonumber(info_data[idx+1][1]) or 0
			if q_lv >= 1000 then
				q_lv = getConfigItemByKey("MapInfo","q_map_id",q_lv,"q_map_min_level") or 0
			end
		end
		local mcolor = MColor.gray
		if q_lv > m_lv then
			active_tab[idx] = nil
			entrance:addColorGray()
		else
			mcolor = MColor.yellow
			active_tab[idx] = true
		end
		local entrance_size = entrance:getContentSize()
		Mnode.createLabel(
		{
			src = tostring(load_data[idx+1]),
			size = 22,
			color = mcolor,
			parent = entrance,
			pos = cc.p(entrance_size.width/2, entrance_size.height/2),
		})
	end
	
    return cell
end, cc.TABLECELL_SIZE_AT_INDEX)

getLoadDateByFlag(select_id or 1)
tableView:reloadData()

Mnode.addChild(
{
	parent = src2_bg,
	child = tableView,
	pos = cc.p(src2_bg_size.width/2, src2_bg_size.height/2-30),
})
-----------------------------------------------------------------------
-----------------------------------------------------------------------
return return_node
end }