-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_recharge_consume_rank = i3k_class("wnd_recharge_consume_rank", ui.wnd_base)

local LAYER_CZPHBT = "ui/widgets/czphbt"
local rankImgTb = {3797, 3798, 3799} --前三名等级图标
local RANK_RECORD_MAX_NUM = 100  --排行榜最大记录人数
local REWARDS_COUNT = 5  --奖励物品的数量
local titleImgTb = {3774, 3775}  --标题图片id，[1]=消费排行榜 [2]=充值排行榜
local bgImgTb = {3793, 3794, 3795, 3796}  --底板，[1-3]前三名  [4]其他
local txtColorTb = {'ffff7200', 'ff606986', 'ff5f581f', 'ff8e7057'}  --文字颜色，[1-3]前三名  [4]其他
local selfRankColor = {'ffd3580d', 'ffa98675'}  --我的排名文字颜色,[1] = 橙色 [2] = 灰色

function wnd_recharge_consume_rank:ctor()
	self.rank_type = g_Pay_Rank --g_Pay_Rank代表充值排行 g_Consume_Rank代表消费排行
	self.myCount = 0    		--充值或消费的数量
	self.selfRank = 0   		--玩家个人名次
	self.ranks = {}	    		--前20名玩家数据
	self.rank_gifts = {}		--排名奖励
end

function wnd_recharge_consume_rank:configure()
	self._layout.vars.help_btn:onClick(self, self.onHelpBtn)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)

	self.rank_title = self._layout.vars.rank_title --标题
	self.column_three_name = self._layout.vars.column_three_name --第3列列名
	self.my_money_lab = self._layout.vars.lvlLabel
	self.countLabel = self._layout.vars.countLabel
	self.my_rank = self._layout.vars.my_rank

	self.rank_scroll = self._layout.vars.scroll
end

function wnd_recharge_consume_rank:refresh(info, rank_type)
	self:updateRankInfo(info, rank_type)
end

function wnd_recharge_consume_rank:updateRankInfo(info, rank_type)
	self.selfRank = info.selfRank
	self.rank_type = rank_type
	self.ranks = info.ranks
	self.rank_gifts = info.cfg.rankList

	if rank_type == g_Pay_Rank then
		self.myCount = info.log and info.log.pay or 0
	elseif rank_type == g_Consume_Rank then
		self.myCount = info.log and info.log.consume or 0
	end

	self:setData()
end

function wnd_recharge_consume_rank:setData()
	self:setTitle()
	self:setMyData()
	self:setRankListData()
end

function wnd_recharge_consume_rank:setTitle()
	if self.rank_type == g_Pay_Rank then
		self.rank_title:setImage(i3k_db_icons[titleImgTb[2]].path)
		self.column_three_name:setText("储值金额")
		self.my_money_lab:setText("我的储值：")
	elseif self.rank_type == g_Consume_Rank then
		self.rank_title:setImage(i3k_db_icons[titleImgTb[1]].path)
		self.column_three_name:setText("消耗元宝")
		self.my_money_lab:setText("我的消耗：")
	end
end

function wnd_recharge_consume_rank:setMyData()
	local myRank = self.selfRank
	if myRank > RANK_RECORD_MAX_NUM or myRank == 0 then
		self.my_rank:setText("未上榜")
		self.my_rank:setTextColor(selfRankColor[2])
	else
		self.my_rank:setText(myRank)
		self.my_rank:setTextColor(selfRankColor[1])
	end
	
	self.countLabel:setText(self.myCount)
	if self.myCount == 0 then
		self.countLabel:setTextColor(selfRankColor[2])
	else
		self.countLabel:setTextColor(selfRankColor[1])
	end
end

function wnd_recharge_consume_rank:setRankListData()
	self.rank_scroll:removeAllChildren()
	local ranks = self.ranks
	if next(ranks) == nil then
		return
	end
	for i,v in ipairs(ranks) do
		local item = require(LAYER_CZPHBT)()
		local rank = i
		local count = v.rankKey --充值或消费的数量
		local roleName = v.role.name or " "
		if rank <= 3 then
			item.vars.rankLabel:hide()
			item.vars.rankImg:show()
			item.vars.rankImg:setImage(i3k_db_icons[rankImgTb[rank]].path)
			item.vars.sharder:setImage(i3k_db_icons[bgImgTb[rank]].path)
			item.vars.nameLabel:setTextColor(txtColorTb[rank])
			item.vars.damageLabel:setTextColor(txtColorTb[rank])
		else
			item.vars.rankImg:hide()
			item.vars.rankLabel:show()
			item.vars.sharder:setImage(i3k_db_icons[bgImgTb[4]].path)
			item.vars.nameLabel:setTextColor(txtColorTb[4])
			item.vars.damageLabel:setTextColor(txtColorTb[4])
		end
		item.vars.rankLabel:setText(string.format("%s",rank))
		item.vars.nameLabel:setText(roleName)
		item.vars.damageLabel:setText(count)

		self:setRewardsData(item, rank)

		self.rank_scroll:addItem(item)
	end
end

function wnd_recharge_consume_rank:setRewardsData(item, rank)
	local rank_gifts = self.rank_gifts
	local gifts = {}
	for i,v in ipairs(rank_gifts) do
		if rank <= v.rank then
			gifts = v.gifts
			break
		end
	end
	for i = 1, REWARDS_COUNT do
		item.vars["root"..i]:hide()
	end
	for k = 1, #gifts do
		local id = gifts[k].id
		local count = gifts[k].count

		item.vars["root"..k]:show()
		item.vars["icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
		item.vars["btn"..k]:onClick(self, self.showItemInfo, id)
		if count >= 1 then
			item.vars["countLabel"..k]:setText("x"..count)
		else
			item.vars["countLabel"..k]:hide()
		end
		if id > 0 then
			item.vars["lock"..k]:show()
		else
			item.vars["lock"..k]:hide()
		end
	end
end

function wnd_recharge_consume_rank:onHelpBtn(sender)
	local txt_id = 0
	if self.rank_type == g_Pay_Rank then
		txt_id = 15445
	elseif self.rank_type == g_Consume_Rank then
		txt_id = 15446
	end
	local msg = i3k_get_string(txt_id)
	g_i3k_ui_mgr:ShowHelp(msg)
end

function wnd_recharge_consume_rank:showItemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_recharge_consume_rank.new();
		wnd:create(layout, ...);
	return wnd;
end
