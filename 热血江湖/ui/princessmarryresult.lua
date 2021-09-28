
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_princessMarryResult = i3k_class("wnd_princessMarryResult", ui.wnd_base)

local rankTable = {[1] = 2718, [2] = 2719, [3] = 2720}
local rankBottom = {[1] = 8574, [2] = 8575, [3] = 8576}
local IMGAEID = 8577
local WIDGHT1 = "ui/widgets/gongzhuchujiajgt1"
local WIDGHT2 = "ui/widgets/gongzhuchujiajgt2"
local WINICON = 8572
local LOSEICON = 8573

function wnd_princessMarryResult:ctor()

end

function wnd_princessMarryResult:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.leave)
	widgets.closeBtn:onClick(self, self.leave)
	self._countDown = widgets.countDown
	self._time = i3k_db_princess_marry.countdownTime
end

function wnd_princessMarryResult:refresh(info)
	local widgets = self._layout.vars
	widgets.selfRanking:setText(info.selfRank)
	local id = info.win == 1 and WINICON or LOSEICON
	widgets.image:setImage(g_i3k_db.i3k_db_get_icon_path(id))
	widgets.rankingScroll:removeAllChildren()
		
	for	k, v in ipairs(info.ranks) do
		local node = require(WIDGHT1)()
		local wid = node.vars
		wid.rankTxt:setText(i3k_get_string(17340, k)) 
		wid.name:setText(v.role.name) 
		wid.score:setText(i3k_get_string(18051, v.rankKey)) 
		
		if k <=3 then
			wid.rankImg:setVisible(true)
			wid.rankTxt:setVisible(false)
			wid.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankTable[k]))
			wid.bottom:setImage(g_i3k_db.i3k_db_get_icon_path(rankBottom[k]))
			--wid.sharder:setVisible(true)
		else
			wid.rankImg:setVisible(false)
			wid.rankTxt:setVisible(true)			
            wid.rankTxt:setText(k)
			wid.bottom:setImage(g_i3k_db.i3k_db_get_icon_path(IMGAEID))
			--wid.sharder:setVisible(i % 2 == 1)
        end
		
		widgets.rankingScroll:addItem(node)	
	end
	
	local cfg = info.win == 1 and i3k_db_princess_win_reward or i3k_db_princess_fail_reward
	local rank = cfg[#cfg].rank
	widgets.rewardScroll:removeAllChildren()
	
	if cfg[#cfg].rank <= info.selfRank or info.selfRank <= 0 then
		rank = cfg[#cfg].rank
	else
		for k, v in ipairs(cfg) do		
			if v.rank >= info.selfRank then
				rank = v.rank
				break
			end
		end 
	end
	
	local reward = g_i3k_db.i3k_db_get_princess_marry_reward(rank, cfg)
	
	for	k, v in ipairs(reward) do
		if v.id ~= 0 and v.count ~= 0 then
			local node = require(WIDGHT2)()
			local wid = node.vars
			wid.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			wid.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
			wid.item_count:setText("x" .. i3k_get_num_to_show(v.count))  
			wid.suo:setVisible(v.id > 0)
			wid.bt:onClick(self, function()
				g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
			end)
			widgets.rewardScroll:addItem(node)
		end	
	end
	
	self:refreshCountDown()
end

function wnd_princessMarryResult:refreshCountDown()
	self._countDown:setText(i3k_get_show_rest_time(math.ceil(self._time)))
end

function wnd_princessMarryResult:onUpdate(dTime)
	self._time = self._time - dTime
	
	if self._time >= 0 then
		self:refreshCountDown()
	else
		self._time = 1000
 
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			self:leave()
		end, 1)		
	end
end

function wnd_princessMarryResult:leave()
	i3k_sbean.mapcopy_leave()
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_princessMarryResult.new()
	wnd:create(layout, ...)
	return wnd;
end

