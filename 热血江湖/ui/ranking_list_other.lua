-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local rankListTbl 		= nil
local faction_rank 		= 1
local TABLE_LENGHT 		= 20

local HUIWUTYPE 		= 5
local XIANHUATYPE		= 6
local FORCEWARTYPE		= 7

local TYPE_FACTION		= 1 -- 帮派（帮派周活跃，帮战） 定义两种类型，具体的值无意义
local TYPE_FENTANG		= 2 -- 分堂（分堂）
local TYPE_Fightteam	= 3 -- 武道会海选
-------------------------------------------------------
wnd_ranking_list_other = i3k_class("wnd_ranking_list_other", ui.wnd_base)
--排行榜
local f_rankImg = {2718, 2719, 2720}

--排行榜tips 跳表
local rankListTbl =
{
	[faction_rank] = {sync = i3k_sbean.query_rolefeature,index = 'faction',id = 1},--帮派排行榜
}

local headerName =
{
	[1] = {sectName = "帮派名称", chief = "帮主", sort_name2 = "七日活跃"},
	[2] = {sectName = "帮派名称", chief = "帮主", sort_name2 = "帮战积分"},
	[3] = {sectName = "帮派名称", chief = "帮主", sort_name2 = "龙穴积分"},
	[4] = {sectName = "分堂名称", chief = "堂主", sort_name2 = "帮战积分"},
	[5] = {sectName = "战队名称", chief = "队长", sort_name2 = "海选积分"},
}

function wnd_ranking_list_other:setHeaderName(index)
	local cfg = headerName[index]
	self._layout.vars.sectName:setText(cfg.sectName)
	self._layout.vars.chief:setText(cfg.chief)
	self._layout.vars.sort_name2:setText(cfg.sort_name2)
end

function wnd_ranking_list_other:ctor()
	self._color = {"FF1f5b44","FF745226"}  --选中，默认
	self._type = 0
	self._createTime = 0
	self._page = 0
	self._tag = false
	self._factionType = TYPE_FACTION
	-- self.roleRankTb = {}
end

function wnd_ranking_list_other:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.personal_btn = widgets.personal_btn  --个人
	self.personal_btn:stateToNormal()
	self.personal_btn:onClick(self, self.onPersonalBtn)

	self.other_btn = widgets.other_btn  --其他
	self.other_btn:stateToPressed()

	self.otherUI = widgets.otherUI  --其他排行榜ui
	self.otherUI:show()

	self.PersonlUI = widgets.PersonlUI  --	个人排行榜ui
	self.PersonlUI:hide()
	--分页处理start
	self.subBtn = widgets.subBtn
	self.subBtn:onClick(self, self.subPage)
	self.addBtn = widgets.addBtn
	self.addBtn:onClick(self, self.addPage)
	self.pageNum =widgets.pageNum
	--分页处理end
	widgets.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_ranking_list_other:refresh(info, index, fentang, fightteam)
	local firstNode = self:updateActivitiesList(info, index, fentang, fightteam) --显示左侧排行榜名称数据
	if firstNode then
		self:updateSelectedListItem(firstNode.vars.btn) -- 设置跳转过来的左侧按钮状态
	end
end

-- 先添加帮派相关排行榜，在添加分堂相关排行榜，二者是独立出来的。

-- 添加左侧页签
function wnd_ranking_list_other:updateActivitiesList(info, index, fentang, fightteam)
	--显示左侧排行榜名称数据
	local activitiesList = self._layout.vars.dungeon_scroll
	activitiesList:removeAllChildren()
	local firstNode = nil
	local l_rankType = 1
	local t = {}
	-- 添加帮派相关左侧列表
	for i,v in ipairs (info) do -- v.rankSize
		local LAYER_SBLBT = require("ui/widgets/rxphblbt")()
		LAYER_SBLBT.vars.btn.actID = v.id
		LAYER_SBLBT.vars.btn.factionType = TYPE_FACTION -- 区分帮派还是分堂
		table.insert(t, {id = v.id, factionType = TYPE_FACTION, createTime = v.createTime, rankSize = v.rankSize})
		l_rankType = i3k_db_rank_list_other[v.id].rankType
		local l_listName = i3k_db_rank_list_name_other[l_rankType].name
		LAYER_SBLBT.vars.btn.actType = l_rankType
		LAYER_SBLBT.vars.name:setText(l_listName)
		LAYER_SBLBT.vars.btn:onClick(self, self.updateSelectedListItem)
		if index and index == i then
			firstNode = LAYER_SBLBT
		elseif i == 1 then
			firstNode = LAYER_SBLBT
		end
		activitiesList:addItem(LAYER_SBLBT)
	end

	-- 添加分堂相关左侧列表
	for i, v in ipairs(fentang) do
		local LAYER_SBLBT = require("ui/widgets/rxphblbt")()
		LAYER_SBLBT.vars.btn.actID = v.id
		LAYER_SBLBT.vars.btn.factionType = TYPE_FENTANG -- 区分帮派还是分堂
		table.insert(t, {id = v.id, factionType = TYPE_FENTANG, createTime = v.createTime, rankSize = v.rankSize})
		l_rankType = i3k_db_rank_list_fentang[v.id].rankType
		local l_listName = i3k_db_rank_list_name_fentang[l_rankType].name
		LAYER_SBLBT.vars.btn.actType = l_rankType
		LAYER_SBLBT.vars.name:setText(l_listName)
		LAYER_SBLBT.vars.btn:onClick(self, self.updateSelectedListItem)
		activitiesList:addItem(LAYER_SBLBT)
	end
	
	-- 添加武道会相关左侧列表
	for i, v in ipairs(fightteam) do
		local LAYER_SBLBT = require("ui/widgets/rxphblbt")()
		LAYER_SBLBT.vars.btn.actID = v.id
		LAYER_SBLBT.vars.btn.factionType = TYPE_Fightteam
		table.insert(t, {id = v.id, factionType = TYPE_Fightteam, createTime = v.createTime, rankSize = v.rankSize})
		l_rankType = i3k_db_rank_list_fightteam[v.id].rankType
		local l_listName = i3k_db_rank_list_fightteam[l_rankType].name
		LAYER_SBLBT.vars.btn.actType = l_rankType
		LAYER_SBLBT.vars.name:setText(l_listName)
		LAYER_SBLBT.vars.btn:onClick(self, self.updateSelectedListItem)
		activitiesList:addItem(LAYER_SBLBT)
	end
	
	self._info = t
	return firstNode
end

--获取排名信息
function wnd_ranking_list_other:reloadRankList(ranks,id,rankSize)
	self._layout.vars.scroll2:cancelLoadEvent()---关闭上拉刷新
	local scroll2 = self._layout.vars.scroll2
	self._layout.vars.scroll2:removeAllChildren()
	self:setHeaderName(id)
	local gender
	local bwtype = 0
	local cur_index = 0
	if next(ranks) == nil then
		self._layout.vars.self_info:hide()
	else
		self._layout.vars.self_info:show()
	end
	local num = self._page + 1
	self.pageNum:setText(string.format("第%d%s",num,"页"))
	for i,v in ipairs(ranks) do
		local pht = require("ui/widgets/rxphbt3")()
		if self._page ~= 0 then
			cur_index = self._page * 20 + i
		else
			cur_index =  i
		end
		self:setShowAttributeInfo(cur_index, pht)
		local data = id == 1 and math.floor( v.rankKey/(2^10)) or v.rankKey
		--local data = math.floor( v.rankKey/(2^10)) --add by jxw 服务器返回值变化
		pht.vars.lvlLabel3:setText(data) --活跃度
		pht.vars.factionName:setText(v.sect.name)					--帮派名称
		pht.vars.wangName:setText(v.sect.chiefName)		--帮主的名称
		scroll2:addItem(pht)
	end
	self:setShowListLayout()-----设置列表显示格式
	self.rankSize = rankSize
	self:setBtnState(true)

	local newTotalSize = TABLE_LENGHT * self._page + #ranks
	if newTotalSize == self.rankSize then
		self.maxPage = true	--最大了 不用请求了
	else
		self.maxPage = false
	end
end

--获取排名信息
function wnd_ranking_list_other:reloadFentangRankList(ranks, id, rankSize)
	self._layout.vars.scroll2:cancelLoadEvent()---关闭上拉刷新
	local scroll2 = self._layout.vars.scroll2
	self._layout.vars.scroll2:removeAllChildren()
	self:setHeaderName(4)
	local gender
	local bwtype = 0
	local cur_index = 0
	if next(ranks) == nil then
		self._layout.vars.self_info:hide()
	else
		self._layout.vars.self_info:show()
	end
	local num = self._page + 1
	self.pageNum:setText(string.format("第%d%s",num,"页"))
	for i,v in ipairs(ranks) do
		local pht = require("ui/widgets/rxphbt3")()
		if self._page ~= 0 then
			cur_index = self._page * 20 + i
		else
			cur_index =  i
		end
		self:setShowAttributeInfo(cur_index, pht)
		local data = math.floor( v.rankKey ) --add by jxw 服务器返回值变化
		pht.vars.lvlLabel3:setText(data) --活跃度
		pht.vars.factionName:setText(v.group.group.groupName)					--帮派名称
		pht.vars.wangName:setText(v.group.leaderName)		--帮主的名称
		scroll2:addItem(pht)
	end
	self:setShowListLayout()-----设置列表显示格式
	self.rankSize = rankSize
	self:setBtnState(true)

	local newTotalSize = TABLE_LENGHT * self._page + #ranks
	if newTotalSize == self.rankSize then
		self.maxPage = true	--最大了 不用请求了
	else
		self.maxPage = false
	end
end

--获取武道会排名信息
function wnd_ranking_list_other:reloadFightteamRankList(ranks,id,rankSize)
	self._layout.vars.scroll2:cancelLoadEvent()---关闭上拉刷新
	local scroll2 = self._layout.vars.scroll2
	self._layout.vars.scroll2:removeAllChildren()
	self:setHeaderName(5)
	local gender
	local bwtype = 0
	local cur_index = 0
	if next(ranks) == nil then
		self._layout.vars.self_info:hide()
	else
		self._layout.vars.self_info:show()
	end
	local num = self._page + 1
	self.pageNum:setText(string.format("第%d%s",num,"页"))
	for i,v in ipairs(ranks) do
		local pht = require("ui/widgets/rxphbt3")()
		if self._page ~= 0 then
			cur_index = self._page * 20 + i
		else
			cur_index =  i
		end
		self:setShowAttributeInfo(cur_index, pht)
		pht.vars.lvlLabel3:setText(v.rankKey)
		pht.vars.factionName:setText(v.team.name)
		pht.vars.wangName:setText(v.team.leader.name)
		scroll2:addItem(pht)
	end
	self:setShowListLayout()-----设置列表显示格式
	self.rankSize = rankSize
	self:setBtnState(true)

	local newTotalSize = TABLE_LENGHT * self._page + #ranks
	if newTotalSize == self.rankSize then
		self.maxPage = true	--最大了 不用请求了
	else
		self.maxPage = false
	end
end

---设置每条信息显示
function wnd_ranking_list_other:setShowAttributeInfo(index, item)
	if index <= 3 then
		item.vars.rankImg3:show()
		item.vars.rankImg3:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[index]))
		item.vars.rankLabel3:hide()
	else
		item.vars.rankImg3:hide()
		item.vars.rankLabel3:show()
		item.vars.rankLabel3:setText(index..".")
	end
end

---设置列表显示格式
function wnd_ranking_list_other:setShowListLayout()
	local children = self._layout.vars.scroll2:getAllChildren()
	for i, e in ipairs( self._layout.vars.scroll2:getAllChildren()) do
		if e.vars.sharder then
			if i%2 == 1 then
				e.vars.sharder:show()
			else
				e.vars.sharder:hide()
			end
		end
	end
end

---------------------------------------------

-- 点击左侧大标签
function wnd_ranking_list_other:updateSelectedListItem(sender)
	local children = self._layout.vars.dungeon_scroll:getAllChildren()
	-- self._layout.vars.dungeon_scroll:jumpToChildWithIndex(sender.actType + 1)
	self._factionType = sender.factionType
	for i, e in ipairs(children) do
		if e.vars.btn.actID == sender.actID and e.vars.btn.factionType == sender.factionType then
			self._layout.vars.sort_name:setText(i3k_db_rank_list_other[sender.actID].sortKeyName)
			if e.vars.jiantou then
				e.vars.jiantou:show()
				e.vars.name:setTextColor(self._color[1]) -- 选中
			end
			e.vars.btn:stateToPressedAndDisable()

			for i,v in ipairs (self._info) do
				if sender.actID == v.id and sender.factionType == v.factionType then
					self._tag = false
					self._page = 0 -- 清空默认页数
					self._type = v.id
					self._createTime = v.createTime
					if v.factionType == TYPE_FACTION then
						i3k_sbean.get_OtherRankList(v.id, v.createTime, 0, TABLE_LENGHT, v.rankSize)
					elseif v.factionType == TYPE_Fightteam  then
						i3k_sbean.getFightteamRankList(v.id, v.createTime, 0, TABLE_LENGHT, v.rankSize)
					else
						i3k_sbean.getFactionFentangRankList(v.id, v.createTime, 0, TABLE_LENGHT, v.rankSize)
					end
				end
			end
		else
			if e.vars.jiantou then
				e.vars.btn:stateToNormal()
				e.vars.jiantou:hide()
				e.vars.name:setTextColor(self._color[2]) -- 默认
			end
		end
	end
end


--------------------------
function wnd_ranking_list_other:addPage(sender)
	if self._page == 30 or self.maxPage then
		g_i3k_ui_mgr:PopupTipMessage("已经是最大页了")
		return
	end
	self._page = self._page + 1
	self:setBtnState(false)
	if self._factionType == TYPE_FACTION then
		i3k_sbean.get_OtherRankList(self._type,self._createTime, self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)--20
	elseif self._factionType == TYPE_Fightteam  then
		i3k_sbean.getFightteamRankList(self._type, self._createTime,  self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)
	else
		i3k_sbean.getFactionFentangRankList(self._type,self._createTime, self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)
	end
end

function wnd_ranking_list_other:subPage(sender)
	if self._page == 0 then
		g_i3k_ui_mgr:PopupTipMessage("已经是最小页了")
		return
	end
	self._page = self._page  - 1
	self:setBtnState(false)
	if self._factionType == TYPE_FACTION then
		i3k_sbean.get_OtherRankList(self._type, self._createTime, self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)--20
	elseif self._factionType == TYPE_Fightteam  then
		i3k_sbean.getFightteamRankList(self._type, self._createTime, self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)
	else
		i3k_sbean.getFactionFentangRankList(self._type, self._createTime, self._page * TABLE_LENGHT, TABLE_LENGHT, self.rankSize)
	end
end


function wnd_ranking_list_other:setBtnState(able)
	self.addBtn:setTouchEnabled(able)
	self.subBtn:setTouchEnabled(able)
end
----------------------------

function wnd_ranking_list_other:onPersonalBtn()
	g_i3k_logic:OpenRankListUI()
end

function wnd_ranking_list_other:onHelpBtn(sender)
	local msg = i3k_get_string(883)
	g_i3k_ui_mgr:ShowHelp(msg)
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_other.new();
	wnd:create(layout);
	return wnd;
end
