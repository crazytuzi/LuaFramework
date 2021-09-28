
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_princessMarryReward = i3k_class("wnd_princessMarryReward", ui.wnd_base)

local rankTable = {[1] = 2718, [2] = 2719, [3] = 2720}

function wnd_princessMarryReward:ctor()

end

function wnd_princessMarryReward:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	self.tabs = {
		widgets.personBtn,
		widgets.teamBtn
	}

	for i, v in ipairs(self.tabs) do
		v:onClick(self, function()
			 self:showTab(i)
		end)
	end
end

function wnd_princessMarryReward:refresh()
	self:showTab(1)
end

function wnd_princessMarryReward:showTab(index)
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(18052))
	widgets.scroll:removeAllChildren()

	for i, v in ipairs(self.tabs) do
		if i == index then
			v:stateToPressed()
		else
			v:stateToNormal()
		end
	end

    local setItem = function(i, id, count, item)
        item["root" .. i]:setImage(
            g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id)
        )
        item["icon" .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
        item["lock" .. i]:setVisible(id > 0)
        item["btn" .. i]:onClick(self, function ()
            g_i3k_ui_mgr:ShowCommonItemInfo(id)
        end)
		
		item["countLabel" .. i]:setText("x" .. i3k_get_num_to_show(count))        
    end

    local cfg = index == 1 and i3k_db_princess_win_reward or i3k_db_princess_fail_reward
    local lastRank = 1
	
    for i, v in ipairs(cfg) do
        local nodeIndex = 1
        local node = require("ui/widgets/gongzhuchujiajlt")()
        local wid = node.vars
        local rank = v.rank
		
		if rank <=3 then
			wid.rankImg:setVisible(true)
			wid.rankLabel:setVisible(false)
			wid.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[rank]))
			--wid.sharder:setVisible(true)
		else
			wid.rankImg:setVisible(false)
			wid.rankLabel:setVisible(true)			
            wid.rankLabel:setText(lastRank + 1 .. "-" .. rank)
			--wid.sharder:setVisible(i % 2 == 1)
        end
		
		lastRank = rank		
			
        for _, v in ipairs(v.reward) do
			if v.id ~= 0 and v.count ~= 0 then
				setItem(nodeIndex, v.id, v.count, wid)
				nodeIndex = nodeIndex + 1
			end
        end

        for i = nodeIndex, 5, 1 do
            wid["root" .. i]:setVisible(false)
        end
		
        widgets.scroll:addItem(node)
    end
end

function wnd_create(layout, ...)
	local wnd = wnd_princessMarryReward.new()
	wnd:create(layout, ...)
	return wnd;
end

