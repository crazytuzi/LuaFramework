-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_national_cheer_rank = i3k_class("wnd_national_cheer_rank", ui.wnd_base)

local LAYER_JIAYOUPHT = "ui/widgets/jiayoupht"
local REWARDS_COUNT = 4  --奖励物品的数量
local rankImgTb = {2718, 2719, 2720} --前三名等级图标
local bgImgTb = {3793, 3794, 3795}  --底板，[1-3]前三名  [4]其他
local txtColorTb = {'fff87719', 'ff616775', 'ff4f4b1b', 'ff897459'}  --字体颜色，[1-3]前三名  [4]其他

function wnd_national_cheer_rank:ctor()
	self.selfScore = 0    		--我的加油数
	self.selfRank = 0   		--玩家个人名次
	self.ranks = {}	    		--前20名玩家数据
end

function wnd_national_cheer_rank:configure()
	self.rank_scroll = self._layout.vars.scroll
	self.oil_num = self._layout.vars.oil_num
	self.name = self._layout.vars.name
	self.rankLabel = self._layout.vars.rankLabel
	self.rankImg = self._layout.vars.rankImg

	self._layout.vars.help_btn:onClick(self, self.onShowHelp)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_national_cheer_rank:refresh(info)
	self.selfRank = info.selfRank
	self.selfScore = info.selfScore
	self.ranks = info.ranks
	
	self:setData()
end

function wnd_national_cheer_rank:setData()
	self:setMyData()
	self:setRankListData()
end

function wnd_national_cheer_rank:setMyData()
	local myRank = self.selfRank
	local rank_max_num = i3k_db_national_activity_cfg.rank_max_num  --排行榜最大记录人数

	if myRank <= 3 and myRank > 0 then  --前三名
		self.rankImg:show()
		self.rankLabel:hide()
		self.rankImg:setImage(i3k_db_icons[rankImgTb[myRank]].path)
	elseif myRank > rank_max_num or myRank == 0 then
		self.rankImg:hide()
		self.rankLabel:show()
		self.rankLabel:setText("榜外")
	else
		self.rankImg:hide()
		self.rankLabel:show()
		self.rankLabel:setText(string.format("%s.", myRank))
	end

	self.name:setText(g_i3k_game_context:GetRoleName())
	self:setRewardsData(self._layout, myRank)
	
	self.oil_num:setText(string.format("%s", self.selfScore))
end

function wnd_national_cheer_rank:setRankListData()
	self.rank_scroll:removeAllChildren()
	local ranks = self.ranks
	for rank, v in ipairs(ranks or {}) do
		local item = require(LAYER_JIAYOUPHT)()
		local count = math.floor(v.rankKey/(2^10)) --加油数
		local roleName = v.role.name or " "
		if rank <= 3 then
			item.vars.rankLabel:hide()
			item.vars.rankImg:show()
			item.vars.rankImg:setImage(i3k_db_icons[rankImgTb[rank]].path)
			item.vars.sharder:setImage(i3k_db_icons[bgImgTb[rank]].path)
			item.vars.nameLabel:setTextColor(txtColorTb[rank])
			item.vars.oilLabel:setTextColor(txtColorTb[rank])
		else
			item.vars.rankImg:hide()
			item.vars.rankLabel:show()
			item.vars.rankLabel:setTextColor(txtColorTb[4])
			item.vars.nameLabel:setTextColor(txtColorTb[4])
			item.vars.oilLabel:setTextColor(txtColorTb[4])
		end
		item.vars.rankLabel:setText(string.format("%s", rank))
		item.vars.nameLabel:setText(roleName)
		item.vars.oilLabel:setText(count)

		self:setRewardsData(item, rank)

		self.rank_scroll:addItem(item)
	end
end

function wnd_national_cheer_rank:setRewardsData(item, rank)
	local gifts = {}
	local cfg = i3k_db_national_cheer_rank

	for i = 1, #cfg do
		if rank > 0 and rank <= i3k_db_national_activity_cfg.rank_max_num then
			if cfg[i + 1] and rank < cfg[i + 1].rank then
				gifts = cfg[i].reward
				break
			end
		end
	end
	for i = 1, REWARDS_COUNT do
		item.vars["item_"..i]:hide()
	end
	for k = 1, #gifts do
		local id = gifts[k].id
		local count = gifts[k].count

		item.vars["item_"..k]:show()
		item.vars["item_"..k]:setImage(g_i3k_db.g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		item.vars["item_icon_"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
		item.vars["item_btn_"..k]:onClick(self, self.showItemInfo, id)
		item.vars["item_count_"..k]:setText("x"..count)	
	end
end

function wnd_national_cheer_rank:showItemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_national_cheer_rank:onShowHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16386))
end

function wnd_create(layout, ...)
	local wnd = wnd_national_cheer_rank.new();
		wnd:create(layout, ...);
	return wnd;
end
