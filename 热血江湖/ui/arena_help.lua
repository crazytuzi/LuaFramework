-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arena_help = i3k_class("wnd_arena_help", ui.wnd_base)

local MONEY = 2
local ARENA = 4
local DIAMOND = 1

function wnd_arena_help:ctor()

end

function wnd_arena_help:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)	
	
	
	
	
end

function wnd_arena_help:refresh(info)
	local rewardTable = {}
	
	for i,v in pairs(i3k_db_rank_reward) do
		table.insert(rewardTable, v)
end

	table.sort(rewardTable, function (a, b)
		return a.minRank < b.minRank
	end)
	
	self:setNotScroll(info, rewardTable)
	self:setScroll(rewardTable)
				end

function wnd_arena_help:getItemPathAndCount(i, v, rewardTable, rewardIndex)
	local path, count, frame, id
	local femal = g_i3k_game_context:IsFemaleRole()
	
	if i == 1 then
		path = g_i3k_db.i3k_db_get_common_item_icon_path(MONEY, femal)
		frame = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(MONEY)
		count = v
		id = MONEY
	elseif i == 2 then
		path = g_i3k_db.i3k_db_get_common_item_icon_path(ARENA, femal)
		frame = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(ARENA)
		count = v
		id = ARENA
	elseif i == 3 then
		path = g_i3k_db.i3k_db_get_common_item_icon_path(DIAMOND, femal)
		frame = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(DIAMOND)
		count = v
		id = DIAMOND
	elseif i == 4 then
		path = g_i3k_db.i3k_db_get_common_item_icon_path(v, femal)
		frame = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v)
		count = rewardTable[rewardIndex].itemCount1
		id = v
	else
		path = g_i3k_db.i3k_db_get_common_item_icon_path(v, femal)
		frame = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v)
		count = rewardTable[rewardIndex].itemCount2
		id = v
	end
	
	return path, count, frame, id
				end

function wnd_arena_help:getWidget(widget)
	local myWidget = {}
	
	for i = 1, 5 do
		myWidget[i] = {}
		myWidget[i].root = widget["reward" .. i]
		myWidget[i].icon = widget["rewardIcon" .. i]
		myWidget[i].count = widget["rewardCount" .. i]
		myWidget[i].bt = widget["bt" .. i]
		end
	
	return myWidget
	end
	
function wnd_arena_help:setNotScroll(info, rewardTable)
	local widget = self._layout.vars
	local myWidget = self:getWidget(widget)
	-----设置排名显示	
	widget.rankText:setText(info.rankNow)
	widget.history:setText(g_i3k_game_context:GetArenaRankBest())
	--------设置可获得奖励
	local rewardIndex = 1
	
	for i,v in ipairs(rewardTable) do
		if info.rankNow<=v.minRank then
			rewardIndex = i
			break
		end
	end
	local reward = {rewardTable[rewardIndex].bindMoney, rewardTable[rewardIndex].arenaPoint, rewardTable[rewardIndex].bindDiamond, rewardTable[rewardIndex].itemId1, rewardTable[rewardIndex].itemId2}
	local index = 0
	local rewardNum = #reward
	for i,v in ipairs(reward) do
		if v~=0 then
			index = index+1
			local path, count, frame, id = self:getItemPathAndCount(i, v, rewardTable, rewardIndex)					
			myWidget[index].icon:setImage(path)
			myWidget[index].count:setText("x" .. i3k_get_num_to_show(count))
			myWidget[index].root:setImage(frame)
			myWidget[index].bt:onClick(self, self.clickItem, id)
			end
	end
	if index + 1 <= rewardNum then
		for	i = index + 1, rewardNum do		
			myWidget[i].root:hide()
		end
	end
end

function wnd_arena_help:setScroll(rewardTable)
	local widget = self._layout.vars
	local scroll = widget.scroll
	scroll:removeAllChildren()
	table.insert(rewardTable, 2, rewardTable[2])--策划要求显示23配置里只有3
	local rankTable = {[1] = 2718, [2] = 2719, [3] = 2720}
	
		
		for i,t in ipairs(rewardTable) do
		local rewardBar = require("ui/widgets/jjgz2t1")()
		local node = rewardBar.vars
					local reward = {t.bindMoney, t.arenaPoint, t.bindDiamond, t.itemId1, t.itemId2}
					local index = 0
		local myWidget = self:getWidget(node)
		local rewardNum = #reward
				
		for j, v in ipairs(reward) do
			if v ~= 0 then
				index = index + 1
				local path, count, frame, id = self:getItemPathAndCount(j, v, rewardTable, i)									
				myWidget[index].icon:setImage(path)
				myWidget[index].count:setText("x" .. i3k_get_num_to_show(count))
				myWidget[index].root:setImage(frame)
				myWidget[index].bt:onClick(self, self.clickItem, id)				
			end
		end
				
		if index + 1 <= rewardNum then
			for	j = index + 1, rewardNum do		
				myWidget[j].root:hide()
			end
		end
			
		if i <=3 then
			node.rankImage:setVisible(true)
			node.rank:setVisible(false)
			node.rankImage:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[i])) 
		else
			node.rankImage:setVisible(false)
			node.rank:setVisible(true)
			local num = rewardTable[i - 1].minRank + 1
			node.rank:setText(num .. "-" .. t.minRank)
		end
		
		node.bg:setVisible(i % 2 == 1)		
		scroll:addItem(rewardBar)				
	end
	
	widget.scroll2:removeAllChildren()
	local layer = require("ui/widgets/jjgz2t2")()
	layer.vars.text:setText(i3k_get_string(15172))
	widget.scroll2:addItem(layer)

	g_i3k_ui_mgr:AddTask(self, {layer}, function(ui)
		local size = layer.rootVar:getContentSize()
		local height = layer.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		layer.rootVar:changeSizeInScroll(ui._layout.vars.scroll2, width, height, true)
	end, 1)
end

function wnd_arena_help:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_arena_help.new();
	wnd:create(layout, ...);
	return wnd;
end
