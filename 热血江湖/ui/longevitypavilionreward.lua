
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_longevityPavilionReward = i3k_class("wnd_longevityPavilionReward", ui.wnd_base)

local rankTable = {[1] = 2718, [2] = 2719, [3] = 2720}

local BOSS_DESC = {
	[1] = 18588,
	[2] = 18589,
	[3] = 18590,
}

function wnd_longevityPavilionReward:ctor()

end

function wnd_longevityPavilionReward:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.bossBtn:show()
	self.tabs = {
		widgets.personBtn,
		widgets.teamBtn,
		widgets.bossBtn,
	}
	self.cfg = {
		[1] = i3k_db_longevity_pavilion_win_reward,
		[2] = i3k_db_longevity_pavilion_fail_reward,
		[3] = i3k_db_longevity_pavilion_special_reward,
	}


	for i, v in ipairs(self.tabs) do
		v:onClick(self, function()
			 self:showTab(i)
		end)
	end
end

function wnd_longevityPavilionReward:refresh()
	self:showTab(1)
end

function wnd_longevityPavilionReward:showTab(index)
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

    local cfg = self.cfg[index]--index == 1 and i3k_db_longevity_pavilion_win_reward or i3k_db_longevity_pavilion_fail_reward
    local lastRank = 1
	
	if index == 3 then
		widgets.desc:setText(i3k_get_string(18587))
		for k,v in ipairs(cfg) do
			local nodeIndex = 1
			local node = require("ui/widgets/gongzhuchujiajlt")()
			local wid = node.vars
			wid.rankImg:hide()
			wid.rankLabel:setText(i3k_get_string(BOSS_DESC[k]))
			for _, j in ipairs(v) do
				if j.id ~= 0 and j.count ~= 0 then
					setItem(nodeIndex, j.id, j.count, wid)
					nodeIndex = nodeIndex + 1
				end
	        end
	         for i = nodeIndex, 5, 1 do
	            wid["root" .. i]:setVisible(false)
	        end
	        widgets.scroll:addItem(node)
		end
	else
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
    
end

function wnd_create(layout, ...)
	local wnd = wnd_longevityPavilionReward.new()
	wnd:create(layout, ...)
	return wnd;
end