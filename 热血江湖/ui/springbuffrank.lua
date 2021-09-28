module(...,package.seeall)

local require = require

local ui = require("ui/base")

wnd_springBuffRank = i3k_class("springBuffRank",ui.wnd_base)

local rankImg = {2718, 2719, 2720} -- 前三名图片ID

function wnd_springBuffRank:ctor()
	self._rankType = 1 --排行榜类型: 1 全体祝福，2 帮派祝福
end

function wnd_springBuffRank:configure()
	local vars = self._layout.vars
	self._typeButton = {vars.all_wish_btn, vars.group_wish_btn}
	for i, v in ipairs(self._typeButton) do
		v:onClick(self, self.onTypeChanged, i)
	end
	vars.rankName:setText(i3k_get_string(18084))
	vars.close_btn:onClick(self,self.onCloseUI)
end


function wnd_springBuffRank:refresh(data)
	self._rankType = data.rankType
	self:loadBtnState()
	self:showRank(data.rank)
end

function wnd_springBuffRank:loadBtnState()
	for i, v in ipairs(self._typeButton) do
		if self._rankType == i then
			v:stateToPressed()
		else
			v:stateToNormal()
		end
	end
end

function wnd_springBuffRank:showRank(rank)
	local label = self._layout.vars.NobodyWish
	label:setVisible(#rank == 0)
	local scroll = self._layout.vars.wish_rank
	scroll:removeAllChildren()
	if #rank == 0 then
		label:setText(i3k_get_string(18083))
		label:setTextColor("FF228B22")
	else
		self:loadRankScroll(scroll,rank)
	end
end

function wnd_springBuffRank:loadRankScroll(scroll,rank)
	for i, v in ipairs(rank) do
		local pht = require("ui/widgets/wenquanpht")()
		local isShowRankImg = i <= 3
		if isShowRankImg then
			pht.vars.rank_img:setImage(g_i3k_db.i3k_db_get_icon_path(rankImg[i]))
		else
			pht.vars.rank:setText(i)
		end
		pht.vars.rank:setVisible(not isShowRankImg)
		pht.vars.rank_img:setVisible(isShowRankImg)
		pht.vars.name:setText(v.name)
		pht.vars.group:setText(v.sectName ~= "" and v.sectName or "暂无")
		pht.vars.count:setText(v.cnt)
		scroll:addItem(pht)
	end
end

function wnd_springBuffRank:onTypeChanged(sender, rankType)
	if self._rankType ~= rankType then
		self._rankType = rankType
		i3k_sbean.query_spring_buff_rank(rankType)
	end
end

function wnd_create(layout)
	local wnd = wnd_springBuffRank.new()
	wnd:create(layout)
	return wnd
end
