-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_chess_task_rank = i3k_class("wnd_chess_task_rank", ui.wnd_base)

local RANK = "ui/widgets/zhenlongqijupht"
--local DESC = "ui/widgets/zhenlongqijuphgzt1"
local LXJLT = "ui/widgets/zhenlongqijuphgzt2"
local rankIcon = {2718, 2719, 2720}
--local rankTitle = {17275, 17276, 17277}

function wnd_chess_task_rank:ctor()
	self.state = 1
	self.rankData = {}
end

function wnd_chess_task_rank:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_chess_task_rank:refresh(rankData)
	self.rankData = rankData
	self._layout.vars.rankPage:onClick(self, self.changePage, 2)
	self._layout.vars.descPage:onClick(self, self.changePage, 1)
	self:setScrollInfo()
end

function wnd_chess_task_rank:changePage(sender, state)
	if self.state == state then
		return
	else
		self.state = state
		self:setScrollInfo()
	end
end

function wnd_chess_task_rank:setScrollInfo()
	if self.state == 2 then
		self._layout.vars.rankNode:show()
		self._layout.vars.descNode:hide()
		self._layout.vars.rankPage:stateToPressed()
		self._layout.vars.descPage:stateToNormal()
		local chess = g_i3k_game_context:getChessTask()
		local chessValue = 0
		if chess and chess.chessValue then
			chessValue = chess.chessValue
		end
		self._layout.vars.leftChessValue:setText(chessValue)
		self._layout.vars.allChessValue:setText(self.rankData.selfChessValue)
		self._layout.vars.myRank:setText(self.rankData.selfRank)
		self._layout.vars.scroll:removeAllChildren()
		for k, v in ipairs(self.rankData.ranks) do
			local node = require(RANK)()
			if v.rank <= 3 then
				node.vars.rankImg:setImage(i3k_db_icons[rankIcon[v.rank]].path)
				node.vars.rankLabel:hide()
			else
				node.vars.rankImg:hide()
				node.vars.rankLabel:show()
				node.vars.rankLabel:setText(v.rank)
			end
			--node.vars.rankLabel:setText(v.rank)
			node.vars.name:setText(v.role.name)
			node.vars.lvlLabel:setText(v.loopLvl)
			node.vars.chessValue:setText(v.chessValue)
			self._layout.vars.scroll:addItem(node)
		end
	else
		self._layout.vars.rankNode:hide()
		self._layout.vars.descNode:show()
		self._layout.vars.rankPage:stateToNormal()
		self._layout.vars.descPage:stateToPressed()
		self._layout.vars.scroll2:removeAllChildren()
		local addWidgets = function()
			--[[local descLabel = require(DESC)()
			descLabel.vars.des:setText(i3k_get_string(17273))
			self._layout.vars.scroll2:addItem(descLabel)--]]
			local rank = 1
			for k, v in ipairs(i3k_db_chess_board_awards) do
				local node = require(LXJLT)()
				if rank <= 3 then
					node.vars.rankImg:show()
					node.vars.rankLabel:hide()
					node.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankIcon[rank]))
					--node.vars.rankLabel:setText(i3k_get_string(rankTitle[rank]))
				else
					node.vars.rankLabel:show()
					node.vars.rankImg:hide()
					if rank == v.rank then
						node.vars.rankLabel:setText(string.format(rank))
					else
						node.vars.rankLabel:setText(string.format("%s~%s", rank, v.rank))
					end
				end
				rank = v.rank + 1
				for i = 1, 4 do
					if v.award[i] and v.award[i].itemId ~= 0 then
						local awardItem = v.award[i]
						node.vars["root"..i]:show()
						node.vars["root"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardItem.itemId))
						node.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardItem.itemId))
						node.vars["lock"..i]:setVisible(awardItem.itemId > 0)
						node.vars["btn"..i]:onClick(self, self.onItemInfo, awardItem.itemId)
						if math.abs(awardItem.itemId) == g_BASE_ITEM_COIN then
							if awardItem.itemCount >= 10000 then
								node.vars["countLabel"..i]:setText(string.format("x%s万", math.floor(awardItem.itemCount/10000)))
							else
								node.vars["countLabel"..i]:setText(string.format("x%s", awardItem.itemCount))
							end
						else
							node.vars["countLabel"..i]:setText(string.format("x%s", awardItem.itemCount))
						end
					else
						node.vars["root"..i]:hide()
					end
				end
				self._layout.vars.scroll2:addItem(node)
			end
		end
		local text = i3k_get_string(17273)
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = require("ui/widgets/ggt1")()
			gzText.vars.text:setText(text)
			ui._layout.vars.scroll2:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(ui._layout.vars.scroll2, width, height, true)
				addWidgets()
			end, 1)
		end, 1)
	end
end

function wnd_chess_task_rank:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_chess_task_rank.new()
	wnd:create(layout)
	return wnd
end
