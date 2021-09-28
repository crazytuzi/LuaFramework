return { new = function(params)
local MPropOutput = require "src/config/PropOutputWayOp"
-----------------------------------------------------------------------
local way = params.way or {}
--dump(way, "way")

table.insert(way, 1, -1)
local root = params.root
-----------------------------------------------------------------------
local itemBg = "res/common/shadow-1.png"

local grid = Mnode.createListView(
{
	iSize = params.iSize or itemBg,
	iPadding = 0,
	row = 3,
	marginUD = 0,
})

local NUMS_IN_GIRD = function(gv)
	return #way
end

grid.onCreateCell = function(gv, idx, cell)
	local finx = tonumber(way[idx+1])
	local isTitle = finx == -1
	
	local iSize = cell:getContentSize()
	local bg = Mnode.createScale9Sprite(
	{
		parent = cell,
		src = isTitle and "res/common/shadow.png" or itemBg,
		cSize = iSize,
		pos = cc.p(iSize.width/2, iSize.height/2),
	})
	
	if isTitle then
		Mnode.createLabel(
		{
			parent = bg,
			src = game.getStrByKey("get_path"),
			size = 22,
			color = MColor.green,
			pos = cc.p(iSize.width/2, iSize.height/2),
		})
		return
	end
	
	--dump(finx, "finx")
	if finx then
		local record = MPropOutput:record(finx)
		if not record then return end
		
		--dump(record, "record")
		
		local status = true
		
		if finx == 99 then
			status = false
			cell.msg = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 19000 , -2 }).msg
		elseif finx == 98 then
			local id = MRoleStruct:getAttr(PLAYER_FACTIONID)
			if id == 0 then
				status = false
				cell.msg = game.getStrByKey("join_faction_tips")
			end
		elseif finx == 2 then -- 神秘商店
			local limit = MPropOutput:lvLimit(record)
			local lv = G_VIP_INFO and G_VIP_INFO.vipLevel or 0
			if lv < limit then
				status = false
				cell.msg = "VIP" .. limit .. game.getStrByKey("open")
			end
		else
			local lv = MRoleStruct:getAttr(ROLE_LEVEL)
			local limit = MPropOutput:lvLimit(record)
			if lv < limit then
				status = false
				cell.msg = limit .. game.getStrByKey("rngd")..game.getStrByKey("open")
			end
		end
		
		cell.status = status
		cell.goto = MPropOutput:goto(record)
		
		Mnode.overlayNode(
		{
			parent = bg,
			nodes = {
				{
					node = Mnode.createLabel(
					{
						src = MPropOutput:name(record),
						size = 20,
						color = MColor.yellow,
					}),
					
					origin = "l",
					offset = { x = 15 },
				},
				
				--[[
				{
					node = cc.Sprite:create(status and "res/group/arrows/5.png" or "res/group/lock/5.png"),
					origin = "r",
					offset = { x = -15 },
				},
				--]]
			},
		})
	end
end

local CELL_TOUCHED = function(gv, cell)
	local idx = cell:getIdx()
	local finx = tonumber(way[idx+1])
	local isTitle = finx == -1
	if isTitle then return end
	
	local x, y = cell:getPosition()
	local size = cell:getContentSize()
	local newX, newY = (x + size.width/2), (y + size.height/2)
	
	if cell.status then
		-- 直接调用会崩溃，尚未明确是何原因
		performWithDelay(root, function()
			removeFromParent(root)
			if G_MAINSCENE.map_layer:isHideMode() then 
				TIPS( {str = game.getStrByKey("current_map"), type = 1})
				return 
			end
			__GotoTarget({ ru = cell.goto })
		end, 0.0)
	else
		if cell.msg then
			TIPS({ type = 1  , str = cell.msg })
		end
	end
end


grid:registerEventHandler(CELL_TOUCHED, YGirdView.CELL_TOUCHED)
grid:registerEventHandler(NUMS_IN_GIRD, YGirdView.NUMS_IN_GIRD)
grid:reloadData()

-----------------------------------------------------------------------
-----------------------------------------------------------------------
return grid
end }