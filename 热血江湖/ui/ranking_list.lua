-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local rankListTbl = nil
local level_rank = 1
local fightPower_rank = 2
local petPower_rank = 3
local weaponPower_rank = 4
local superArena_rank = 5
local superArena_weekrank = 6
local femaleCharm_rank = 7
local maleCharm_rank = 8
local curWhiteSide_rank = 9
local curblackSide_rank = 10
local WhiteSide_rank = 11
local blackSide_rank = 12
local chengjiu_rank = 13
local levelDao_rank = 14
local levelJian_rank = 15
local levelQiang_rank = 16
local levelGong_rank = 17
local levelYi_rank = 18
local powerDao_rank = 19
local powerJian_rank = 20
local powerQiang_rank = 21
local powerGong_rank = 22
local powerYi_rank = 23
local underWear_rank = 25
local steedPower_rank = 26
local levelCike_rank = 27
local powerCike_rank = 28
local weaponSoul_rank = 29
local fightTeam_rank = 30
local dragon_man = 31
local dragon_woman = 32
local levelFushi_rank = 33
local powerFushi_rank = 34
local popularity_rank = 35
local homeland_popularity_rank = 36
local hideWeaponPower_rank = 37
local factionDonate_rank = 38
local homelandRelease_rank = 39
local race_rank = 41
local battle_personal = 42
local battle_team = 43
local wujue_rank = 44
local array_stone_rank = 45
local level_fist_rank = 46
local power_fist_rank = 47

local SHENBING_ATTACK = 1015
local SHENBING_DEFENSE = 1016
local CRIT = 1006
local TOUGHNESS = 1007
local HP = 1001

local MANXING = 365
local TABLE_LENGHT = 20

local DENGJI = 1
local ZHANLI = 2
local HUIWUTYPE = 5
local XIANHUATYPE = 6
local FORCEWARTYPE = 7
local DRAGONTASK = 14
local JUEZHAN = 22

local decoration = {5201, 5202, 5203}
local SHARDER = 5213

local TIME_FORMAT_SURPLUS = 7200
-------------------------------------------------------
wnd_ranking_list = i3k_class("wnd_ranking_list", ui.wnd_base)
--排行榜
local f_rankImg = {2718, 2719, 2720}
function wnd_ranking_list:ctor()
	self._color = {"FF1f5b44","FF745226"}  --选中，默认
	self._state = 1
	self._count = 0
	self._canhave = true
	self._rolename = g_i3k_game_context:GetRoleName()
	self._roletype = g_i3k_game_context:GetRoleType()

	self._type = 0
	self._createTime = 0
	self._page = 0
	self._tag = false

	self._insertCount = 0
	self._insert = false
	self.isPickUp = false
	self.dragonTaskScore = 0
	--排行榜tips 跳表
	rankListTbl =
	{
	[level_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 1},

	[fightPower_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 2},

	[petPower_rank] = {sync = i3k_sbean.get_petoverviews,index = 'petPower',id = 3},        		--佣兵
	[weaponPower_rank] = {sync = i3k_sbean.get_weaponoverviews,index = 'weaponPower',id = 4},		--神兵

	[superArena_rank] = {sync = i3k_sbean.query_rolefeature,index = 'superArena',id = 5},        	--会武历史荣誉
	[superArena_weekrank] = {sync = i3k_sbean.query_rolefeature,index = 'superArenaWeek',id = 6},	--会武周荣誉

	[femaleCharm_rank] = {sync = i3k_sbean.query_rolefeature,index = 'femaleCharm',id = 7},       	--魅力
	[maleCharm_rank] = {sync = i3k_sbean.query_rolefeature,index = 'maleCharm',id = 8},				--守护榜

	[curWhiteSide_rank] = {sync = i3k_sbean.query_rolefeature,index = 'curWhiteSide',id = 9},       --本服正派势力战周榜
	[curblackSide_rank] = {sync = i3k_sbean.query_rolefeature,index = 'curblackSide',id = 10},		--本服邪派势力战周榜

	[WhiteSide_rank] = {sync = i3k_sbean.query_rolefeature,index = 'whiteSide',id = 11},       		--跨服正派势力战周榜
	[blackSide_rank] = {sync = i3k_sbean.query_rolefeature,index = 'blackSide',id = 12}	,			--跨服邪派势力战周榜


	--等级
	[levelDao_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 14},
	[levelJian_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 15},
	[levelQiang_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 16},
	[levelGong_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 17},
	[levelYi_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 18},
	[levelCike_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 27},
	[levelFushi_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 33},
	[level_fist_rank] = {sync = i3k_sbean.query_rolefeature,index = 'level',id = 46},

	--战力
	[powerDao_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 19},
	[powerJian_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 20},
	[powerQiang_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 21},
	[powerGong_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 22},
	[powerYi_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 23},
	[powerCike_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 28},
	[powerFushi_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 34},
	[power_fist_rank] = {sync = i3k_sbean.query_rolefeature,index = 'fightPower',id = 47},

	[underWear_rank] = {sync = i3k_sbean.get_underwearoverviews,index = 'underWear',id = 25},       --内甲战力排行
	[steedPower_rank] = {sync = i3k_sbean.get_steedoverviews,index = 'steedPower',id = 26},         --坐骑战力排行
	[weaponSoul_rank] = {sync = i3k_sbean.get_weaponsouloverview, index = 'weaponSoulPower', id = 29},	--武魂战力排行
	[fightTeam_rank] = {sync = i3k_sbean.query_rolefeature, index = 'fightTeamWeek', id = 30},	--武道会排行
	[dragon_man] = {sync = i3k_sbean.query_rolefeature, index = 'dragonTaskScore', id = 31}, --龙穴积分男性排行
	[dragon_woman] = {sync = i3k_sbean.query_rolefeature, index = 'dragonTaskScore', id = 32}, --龙穴积分女性排行
	[popularity_rank] = {sync = i3k_sbean.mood_diary_open_main_page, index = 'popularity', id = 35}, --人气排行榜
	[homeland_popularity_rank] = {sync = i3k_sbean.query_rolefeature, index = 'homeland_popularity_rank', id = 36}, --家园人气排行榜
	[hideWeaponPower_rank] = {sync = i3k_sbean.get_hideWeapon_overviews, index = 'hideWeaponPower', id = 37}, --暗器排行
	[factionDonate_rank] = {sync = i3k_sbean.query_rolefeature, index = 'factionDonate', id = 38}, --帮派捐赠
	[homelandRelease_rank] = {sync = i3k_sbean.query_rolefeature, index = 'homelandRelease', id = 39}, --家园善缘值值
	[race_rank] = {sync = i3k_sbean.query_rolefeature, index = 'fightPower', id = 41},
	-- TODO
	[battle_personal] = {sync = i3k_sbean.query_rolefeature,index = 'curDesertScore',id = 42}, --个人积分榜
	[battle_team] = {sync = i3k_sbean.query_rolefeature,index = 'curChampion',id = 43},	--夺魁次数榜
	[wujue_rank] = {sync = i3k_sbean.sync_wujue_rank,index = 'wujuePower',id = 44},	--夺魁次数榜
	[array_stone_rank] = {sync = i3k_sbean.query_arraystoneoverviews, index = 'arrayStonePower', id = 45}, -- 阵法石排行榜
	}

	self.roleRankTb = {}
end
function wnd_ranking_list:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._layout.vars.ShareBtn:onClick(self,self.onShare)
	self.personal_btn = widgets.personal_btn  --个人
	self.personal_btn:stateToPressed()
	self.other_btn = widgets.other_btn  --其他
	self.other_btn:stateToNormal()
	self.other_btn:onClick(self, self.onOtherBtn)
	self.otherUI = widgets.otherUI  --其他排行榜ui
	self.otherUI:hide()
	self.PersonlUI = widgets.PersonlUI  --个人排行榜ui
	self.PersonlUI:show()
	self._layout.vars.self_info:hide()
	--分页处理start
	self.subBtn = widgets.subBtn
	self.subBtn:onClick(self, self.subPage)
	self.addBtn = widgets.addBtn
	self.addBtn:onClick(self, self.addPage)
	self.pageNum =widgets.pageNum
	--分页处理end
	widgets.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_ranking_list:onShow()
	local ShareBtn = self._layout.vars.ShareBtn
	ShareBtn:setVisible(false)
	if i3k_game_get_os_type() ~= eOS_TYPE_IOS then
	    if	g_i3k_game_handler:IsSupportShareSDK() then
	 	     ShareBtn:setVisible(true)
	     end
	else
	  	ShareBtn:setVisible(true)
	end
	ShareBtn:setVisible(false)
end

function wnd_ranking_list:onShare(sender)
	g_i3k_game_handler:ShareScreenSnapshotAndText(i3k_get_string(15371), true)
end

function wnd_ranking_list:refresh(info,index)
	--这里调整一下排列顺序
	self._info = {}
	for i,v in ipairs (info) do---v.rankSize
		local l_rankType = i3k_db_rank_list[v.id].rankType
		local l_listName = i3k_db_rank_list_name[l_rankType].sort
	end
	self._info = info
	local firstNode = self:updateActivitiesList(info,index) --显示左侧排行榜名称数据
	if firstNode then
		self:updateSelectedListItem(firstNode.vars.btn)
	end

end

function wnd_ranking_list:updateActivitiesList(info,index)
	--显示左侧排行榜名称数据
	self.roleRankTb = {}
	local activitiesList = self._layout.vars.dungeon_scroll
	self._layout.vars.dungeon_scroll:removeAllChildren()
	local firstNode
	local l_rankType = 1
	
	for i,v in ipairs (info) do---v.rankSize
		local caninsert = true
		local LAYER_SBLBT = require("ui/widgets/rxphblbt")()
		LAYER_SBLBT.vars.btn.actID = v.id
		
		if index then
			if index ==  v.id then
				firstNode = LAYER_SBLBT
			end
		else
			if i == 1 then
				firstNode = LAYER_SBLBT
			end
		end
		l_rankType = i3k_db_rank_list[v.id].rankType
		local l_listName = i3k_db_rank_list_name[l_rankType].name
		local l_listSort = i3k_db_rank_list_name[l_rankType].sort
		LAYER_SBLBT.vars.btn.actType = l_rankType
		LAYER_SBLBT.vars.btn.Sort = l_listSort
		LAYER_SBLBT.vars.name:setText(l_listName)
		LAYER_SBLBT.vars.btn:onClick(self, self.updateSelectedListItem)
		if next(self.roleRankTb) == nil then--
			table.insert(self.roleRankTb, {id = l_rankType , name = l_listName,layer = LAYER_SBLBT,Sort = l_listSort} )
		else
			for _,e in ipairs(self.roleRankTb) do
				if e.id == l_rankType  then---
					caninsert = false

				end
			end
			if caninsert then
				table.insert(self.roleRankTb, {id =l_rankType, name = l_listName ,layer = LAYER_SBLBT,Sort = l_listSort} )
			end
		end
		--activitiesList:addItem(LAYER_SBLBT)
	end
	table.sort(self.roleRankTb,function (a,b)
		return a.Sort < b.Sort
	end)
	for _,e in ipairs(self.roleRankTb) do
		activitiesList:addItem(e.layer)
	end
	if next(info) == nil then
		self._layout.vars.rankLabel:hide()
		self._layout.vars.rankImg:hide()
		self._layout.vars.iconbackground:hide()
		self._layout.vars.icon:hide()
		self._layout.vars.lvlLabel:hide()--战力或等级
		self._layout.vars.name:setText(self._rolename)
		self._layout.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[self._roletype].classImg))
	end

	return firstNode
end
function wnd_ranking_list:selectItemType(sender)
	local firstNode
	--加等级和战力
	if sender.actType == DENGJI or sender.actType == ZHANLI or sender.actType == HUIWUTYPE or sender.actType == XIANHUATYPE or sender.actType == FORCEWARTYPE or sender.actType == DRAGONTASK or sender.actType == JUEZHAN then


			for _,e in ipairs(i3k_db_rank_list) do

				if sender.actType == e.rankType  then
					local LAYER_SBLBT = require("ui/widgets/rxphblbt2")()

					self._insertCount = self._insertCount+1
					local l_listName = i3k_db_rank_list_name[e.rankType].name
					local l_listSort = i3k_db_rank_list_name[e.rankType].sort

					--{id =l_rankType, name = l_listName ,layer = LAYER_SBLBT,Sort = l_listSort}
					local sort = l_listSort
					for i,v in ipairs(self.roleRankTb) do
						if 	v.id ==	e.rankType	then
							sort = i
							break
						end
					end

					LAYER_SBLBT.vars.btn.actID = e.id
					LAYER_SBLBT.vars.btn.actType = e.rankType
					LAYER_SBLBT.vars.btn.Sort = sort+self._insertCount
					if self._insertCount == 1  then
						firstNode = LAYER_SBLBT
					end
					LAYER_SBLBT.vars.nameLabel:setText(e.name)
					LAYER_SBLBT.vars.btn:onClick(self, self.SelectedListItem,{actID = e.id,actType = e.rankType ,Sort =sort+self._insertCount, layer = LAYER_SBLBT})
					self._layout.vars.dungeon_scroll:insertChildToIndex(LAYER_SBLBT, sort+self._insertCount)--:addItem(LAYER_SBLBT)

					local children = self._layout.vars.dungeon_scroll:getAllChildren()
					for i, e in ipairs(children) do
						if e.vars.nameLabel then
							self._insert = i
						end
					end
				end
			end

	end
	return firstNode
end

--打开
function wnd_ranking_list:updateSelectedListItem(sender)

	--根据排序好的表 去找相应的位置
	local sort = sender.Sort
	for i,v in ipairs(self.roleRankTb) do
		if 	v.id ==	sender.actType	then
			sort = i
			break
		end
	end

	if self.sender ==sender and not self.isPickUp then
		self._insert = false
		self:updatePickUpListItem(sort)
		return
	else
		self.sender = sender
		self.isPickUp = false
		if self._insert  then
			self:pickUpList()
		end
	end
	self._insertCount = 0

	-- 判断是否包含子目录
	self:selectItemType(sender)

	self._layout.vars.dungeon_scroll:jumpToChildWithIndex(sort+1)
	for i, e in ipairs(self._layout.vars.dungeon_scroll:getAllChildren()) do

		if  e.vars.btn.actID == sender.actID  then

			self._layout.vars.sort_name:setText(i3k_db_rank_list[sender.actID].sortKeyName)
			if e.vars.jiantou then

				e.vars.jiantou:show()
				e.vars.name:setTextColor(self._color[1])
			end

			e.vars.btn:stateToPressed()
			for i,v in ipairs (self._info) do
				if sender.actID == v.id then
					self._tag = false
					self._page = 0
					self._type = v.id
					self._createTime = v.createTime
					local callback = function ()
						i3k_sbean.get_rankList(v.id,v.createTime,0,TABLE_LENGHT,v.rankSize)
					end
					
					if sender.actID == popularity_rank then
						i3k_sbean.mood_diary_get_self_popularity(function ()
							i3k_sbean.get_selfRank(v.id,callback)
						end)
					else
						i3k_sbean.get_selfRank(v.id,callback)
					end
					
				end
			end
		else
			if e.vars.jiantou then
				e.vars.btn:stateToNormal()
				e.vars.jiantou:hide()
				e.vars.name:setTextColor(self._color[2])
			end
		end
	end
end

--收起
function wnd_ranking_list:updatePickUpListItem(sort)
	local totalNum = 0
	for i,v  in ipairs(i3k_db_rank_list) do
		 if self.roleRankTb[sort].id  == v.rankType then
			totalNum = totalNum +1
		end
	end
	--删除这几个
	if totalNum>1 then
		for i=1,totalNum do
			self._layout.vars.dungeon_scroll:removeChildAtIndex(sort + 1)
		end
	end
	self.isPickUp = true
end

function wnd_ranking_list:pickUpList()
	local children = self._layout.vars.dungeon_scroll:getAllChildren()
	for i=0,self._insertCount-1 do
		self._layout.vars.dungeon_scroll:removeChildAtIndex(self._insert-i)
		local children = self._layout.vars.dungeon_scroll:getAllChildren()
	end
	self._insert = false
end

function wnd_ranking_list:SelectedListItem(sender,needValue)
	local children = self._layout.vars.dungeon_scroll:getAllChildren()
	for i, e in ipairs(children) do
		if e.vars.nameLabel then
			e.vars.btn:stateToNormal()
		end
	end

	for i, e in ipairs(self._layout.vars.dungeon_scroll:getAllChildren()) do
		--根据id和排序判断 add by jxw 2016-12-5
		if  e.vars.btn.actID == needValue.actID and  e.vars.btn.Sort == needValue.Sort  then
			self._layout.vars.sort_name:setText(i3k_db_rank_list[needValue.actID].sortKeyName)
			if e.vars.jiantou then
				e.vars.jiantou:show()
				e.vars.name:setTextColor(self._color[1])
			end
			e.vars.btn:stateToPressedAndDisable()
			for i,v in ipairs (self._info) do
				if needValue.actID == v.id then
					needValue.layer.vars.btn:stateToPressed()
					self._tag = false
					self._page = 0
					self._type = v.id
					self._createTime = v.createTime
					local callback = function ()
						i3k_sbean.get_rankList(v.id,v.createTime,0,TABLE_LENGHT,v.rankSize)
					end
					i3k_sbean.get_selfRank(v.id,callback)

				end
			end
		end
	end


end

-----
function wnd_ranking_list:changeContentSize(control)

	local size = self._layout.vars.RightView:getContentSize()
	control.rootVar:setContentSize(size.width, size.height)
end

--获取自己的排名信息
function wnd_ranking_list:reloadselfRank(ranks,actId)
	self._roleid = g_i3k_game_context:GetRoleId()

	--i3k_log("----- reloadselfRank  = : ",ranks)
	self.level = g_i3k_game_context:GetLevel()
	self.fightPower = g_i3k_game_context:GetRolePower()
	self.dragonTaskScore = g_i3k_game_context:getDragonTaskScore()
	local charmValue = g_i3k_game_context:GetCharm()---魅力值
	local x = g_i3k_game_context:getTournamentHistoryHonor()
	local y = g_i3k_game_context:getTournamentWeekHonor()
	self.superArena = g_i3k_game_context:getTournamentHistoryHonor()--会武荣誉值
	self.superArenaWeek = g_i3k_game_context:getTournamentWeekHonor()--会武周排行
	self.fightTeamWeek = g_i3k_game_context:getFightTeamHonor();--战队荣誉值
	self.hideWeaponPower = g_i3k_game_context:getAllHideWeaponFightPower() -- 暗器战力
	self.femaleCharm = charmValue
	self.maleCharm = charmValue


	local l_WeekFeats = g_i3k_game_context:getForceWarAddWeekFeats()--获得玩家的周武勋
	self.curWhiteSide = l_WeekFeats--本服正派势力战周榜
	self.curblackSide = l_WeekFeats--本服邪派势力战周榜
	self.whiteSide = l_WeekFeats--跨服正派势力战周榜
	self.blackSide = l_WeekFeats--跨服邪派势力战周榜

	self.wujuePower = g_i3k_game_context:getWujueForce()--武诀战力
	self.arrayStonePower = g_i3k_game_context:getArrayStonePower()
	--决战排行
	local battleDesertInfo = i3k_game_context:GetDesertBattleTotalScore()
	self.curDesertScore = battleDesertInfo and battleDesertInfo.score or 0
	self.curChampion = battleDesertInfo and battleDesertInfo.champion or 0
	
	self.petPower = g_i3k_game_context:getAllPetPower()
	self.steedPower = g_i3k_game_context:getAllSteedPower()
	self.weaponPower = g_i3k_game_context:getAllWeaponPower()
	
	self.underWear = 0
	
	local _, allArmorData =  g_i3k_game_context:getUnderWearData()  --获得所有内甲信息
	for i,v in ipairs(allArmorData) do
		if v.unlocked ~= 0 then  --只计算已解锁的内甲
			self.underWear = self.underWear + g_i3k_game_context:getArmorFightPower(v)
		end
	end

	
	self.weaponSoulPower = g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetWeaponSoulPropData()) + g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetStarPropData()) + g_i3k_db.i3k_db_get_battle_power(g_i3k_db.i3k_db_get_shen_dou_prop())
	self.popularity = g_i3k_game_context:getPopularity()
	self.factionDonate = g_i3k_game_context:getFactionDonate()
	self.homelandRelease = g_i3k_game_context:gethomelandRelease()
	
	local index = self:setAttribute(actId)
	for k,v in ipairs(i3k_db_rank_list) do
		if v.id == actId  then
			self._name = v.sortKeyName
		end

	end
	if  i3k_db_rank_list[actId] then --add by jxw 16.9.10 报错，暂未定位到具体位置 so加拦截判断
		local tmpCount = 0
		for key, value in ipairs(i3k_db_rank_list[actId].rank) do
			if value.ranklimit ~= 0 then
				tmpCount = value.ranklimit
			end
		end
		self._count = tmpCount --i3k_db_rank_list[actId].rank[6].ranklimit --称号数量
	end
	if ranks ~= 0  then
		self._rank = ranks
		self:setShowAttributeInfo(ranks, self._layout)
		if ranks <= self._count then
			local iconId,iconbackground = self:setGetTitle(ranks,actId)
			---称号位置
			self._layout.vars.iconbackground:show()
			self._layout.vars.icon:show()
			self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))--(i3k_db_icons[iconId].path)
			self._layout.vars.iconbackground:setImage(g_i3k_db.i3k_db_get_icon_path(iconbackground))
			if not iconId or not iconbackground then
				self._layout.vars.iconbackground:hide()---隐藏称号
				self._layout.vars.icon:hide()
			end
		else
			self._layout.vars.iconbackground:hide()---隐藏称号
			self._layout.vars.icon:hide()
		end
		if ranks > 3 then
			self._layout.vars.sharder:setImage(g_i3k_db.i3k_db_get_icon_path(SHARDER))
		end
	else
		self._layout.vars.rankLabel:show()
		self._layout.vars.rankLabel:setText("榜外")
		self._layout.vars.rankImg:hide()
		self._layout.vars.iconbackground:hide()---我的称号位置
		self._layout.vars.icon:hide()
		self._layout.vars.sharder:setImage(g_i3k_db.i3k_db_get_icon_path(SHARDER))
	end
	self._layout.vars.lvlLabel:setText(self:getSelfRankVale(index))--战力或等级   
	self._layout.vars.name:setText(self._rolename)
	self._layout.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[self._roletype].classImg))
end
-- 显示自己的战力或者其它值（本地存在game_context计算出来的）
function wnd_ranking_list:getSelfRankVale(key)
	-- self.level 其中index是个字符串
	-- 每次新加一种类型的排行榜，需要初始化类似 self.hideWeaponPower 字段，否则就会显示为空字符串
	if not self[key] then 
		return ""
	end
	return self[key]
end
--获取排名信息
function wnd_ranking_list:reloadRankList(ranks,id,rankSize)

	self._layout.vars.scroll:cancelLoadEvent()---关闭上拉刷新
	local scroll = self._layout.vars.scroll
	local hero_name =  g_i3k_game_context:GetRoleName()
	self:setRankScroll(id)
	local children = self._layout.vars.scroll:getAllChildren()
	if i3k_db_rank_list[id] then --add by jxw 16.9.10 报错，暂未定位到具体位置 so加拦截判断
		self._name = i3k_db_rank_list[id].rank
	end
	local gender
	local bwtype = 0
	local cur_index = 0
	if next(ranks) == nil then
		self._layout.vars.self_info:hide()
	else
		self._layout.vars.self_info:show()
	end
	local num = self._page+1
	self.pageNum:setText(string.format("第%d%s",num,"页"))
	for i,v in ipairs(ranks) do
		gender = v.role.gender
		bwtype = v.role.bwType
		local pht = require("ui/widgets/rxphbt")()
		--获取表中称号数量
		if self._page ~= 0 then
			cur_index = self._page*20+i
		else
			cur_index =  i
		end
		self:setShowAttributeInfo(cur_index, pht)
		if i <= self._count then
			local iconId,iconbackground = self:setGetTitle(cur_index,id)
			---称号位置
			pht.vars.iconbackground:show()
			pht.vars.icon:show()
			pht.vars.iconbackground:setImage(g_i3k_db.i3k_db_get_icon_path(iconbackground))--(i3k_db_icons[iconId].path)
			pht.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
			if not iconId or not iconbackground then
				pht.vars.iconbackground:hide()---隐藏称号
				pht.vars.icon:hide()
			end
		else
			pht.vars.iconbackground:hide()---隐藏称号
			pht.vars.icon:hide()
		end
		pht.vars.btn:setTag(v.role.id)
		pht.vars.btn:onClick(self, self.checkRoleInfo, {index = id, roleId = v.role.id, rank = cur_index})
		pht.vars.name:setText(v.role.name)
		pht.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.role.type].classImg))
		if v.role.id<0 then
			local robot = i3k_db_arenaRobot[math.abs(v.role.id)]
			v.role.fightPower = robot.power
		end
		local index = self:setAttribute(id)
		if i3k_db_rank_list[id].rankType ==1 then
			local data =math.floor( v.rankKey/(2^24)) --add by jxw 服务器返回值变化
			pht.vars.lvlLabel:setText(data)--战力或等级v.role[index]
		elseif i3k_db_rank_list[id].rankType == 14 then
			local data =math.floor( v.rankKey/(2^14))
			pht.vars.lvlLabel:setText(data)
		elseif i3k_db_rank_list[id].rankType == 21 then
			local data =TIME_FORMAT_SURPLUS - math.floor(v.rankKey/(2^14))--用7200减去时间 才是花费的时间
			pht.vars.lvlLabel:setText(data)
		else
			pht.vars.lvlLabel:setText(v.rankKey)--战力或等级v.role[index]
		end
		scroll:addItem(pht)
		if self._roleid == v.role.id and hero_name == v.role.name then
			if i3k_db_rank_list[id].rankType ==1 then
				local data =math.floor( v.rankKey/(2^24)) --add by jxw 服务器返回值变化
				self._layout.vars.lvlLabel:setText(data)
			elseif i3k_db_rank_list[id].rankType == 14 then
				self._layout.vars.lvlLabel:setText(math.floor(v.rankKey/(2^14)))
			elseif i3k_db_rank_list[id].rankType == 21 then
				self._layout.vars.lvlLabel:setText(TIME_FORMAT_SURPLUS - math.floor(v.rankKey/(2^14)))--用7200减去时间 才是花费的时间
			elseif i3k_db_rank_list[id].rankType == 19 then
				self._layout.vars.lvlLabel:setText(self.homelandRelease)
			else
				if i3k_db_rank_list[id].rankType ~= 2 and i3k_db_rank_list[id].rankType ~= 4 and v.rankKey then -- (神兵、战力)战力显示自己当前的战力
					self._layout.vars.lvlLabel:setText(v.rankKey)--自身的战力或等级
				end
			end
		end
	end
	--魅力/守护榜
	if id == 7 or id == 8 then
		self:setselfAttribute(id,gender,ranks)
	elseif id == 9 or id == 10 or id == 11 or id == 12 then
		self:setselfAttributeIsInForceWar(id,bwtype,ranks)
	end

	self:setShowListLayout()-----设置列表显示格式

	self.rankSize = rankSize
	self:setBtnState(true)

	local newTotalSize = TABLE_LENGHT*self._page +#ranks
	if newTotalSize == self.rankSize then
		self.maxPage = true	--最大了 不用请求了
	else
		self.maxPage = false
	end
end

--------------------------
function wnd_ranking_list:addPage(sender)
	if self._page ==30 or self.maxPage then
		g_i3k_ui_mgr:PopupTipMessage("已经是最大页了")
		return
	end
	self._page = self._page +1
	self:setBtnState(false)
	i3k_sbean.get_rankList(self._type,self._createTime,self._page*20,TABLE_LENGHT,self.rankSize)--20
end
function wnd_ranking_list:subPage(sender)
	if self._page ==0 then
		g_i3k_ui_mgr:PopupTipMessage("已经是最小页了")
		return
	end
	self._page = self._page  - 1
	self:setBtnState(false)
	i3k_sbean.get_rankList(self._type,self._createTime,self._page*20,TABLE_LENGHT,self.rankSize)--20
end


function wnd_ranking_list:setBtnState(able)
	self.addBtn:setTouchEnabled(able)
	self.subBtn:setTouchEnabled(able)
end














----------------------------

function wnd_ranking_list:setRankScroll(index)
	if not self._tag then
		self._layout.vars.scroll:removeAllChildren()

	end
end
---设置每条信息显示
function wnd_ranking_list:setShowAttributeInfo(index, item)
	if index <= 3 then
		item.vars.rankImg:show()
		item.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[index]))
		item.vars.rankLabel:hide()
		item.vars.sharder:setImage(g_i3k_db.i3k_db_get_icon_path(decoration[index]))
	else
		item.vars.rankImg:hide()
		item.vars.rankLabel:show()
		item.vars.rankLabel:setText(index..".")
	end
end
---设置列表显示格式
function wnd_ranking_list:setShowListLayout()
	local children = self._layout.vars.scroll:getAllChildren()

	for i, e in ipairs( self._layout.vars.scroll:getAllChildren()) do
		if e.vars.sharder then
			if (self._page == 0 and i <= 3) or i%2==1 then
				e.vars.sharder:show()
			else
				e.vars.sharder:hide()
			end
		end

	end
end
---设置显示属性字段
function wnd_ranking_list:setAttribute(actId)

	local attr
	local rankFunctions = rankListTbl[actId]
	if rankFunctions then
		attr = rankFunctions.index
	end
	return attr
end

---设置显示自身是否在男/女性榜
function wnd_ranking_list:setselfAttribute(actId,gender,ranks)
	self._rolegender = g_i3k_game_context:GetRoleGender()--角色性别

	if self._rolegender ~=  gender and next(ranks) then
		self._layout.vars.self_info:show()
		self._layout.vars.rankLabel:show()
		self._layout.vars.rankLabel:setText("榜外")
	end

end

---设置显示自身是否在正/邪势力榜
function wnd_ranking_list:setselfAttributeIsInForceWar(actId,bwtype,ranks)
	self._rolebwtype = g_i3k_game_context:GetTransformBWtype()--角色正邪

	if self._rolebwtype ~=  bwtype and next(ranks) then
		self._layout.vars.rankImg:hide()
		self._layout.vars.self_info:show()
		self._layout.vars.rankLabel:show()
		self._layout.vars.rankLabel:setText("榜外")
	end

end

function wnd_ranking_list:syncActivity(actId, roleId, rank)
	local activityFunctions = rankListTbl[actId]

	if activityFunctions then
		activityFunctions.sync(roleId, actId, rank)
	end
end

--排行榜弹出tips界面 jsxx
function wnd_ranking_list:checkRoleInfo(sender, needValue)
	if needValue.index == popularity_rank then
		i3k_sbean.mood_diary_open_main_page(needValue.roleId == g_i3k_game_context:GetRoleId() and 1 or 2, needValue.roleId)
	elseif needValue.index <= 6 then
		local myId = g_i3k_game_context:GetRoleId()
		local targetId = sender:getTag()
		--if targetId~=myId then
			if targetId > 0 then
				--i3k_sbean.query_rolebrief(targetId, { arena = true, })查询玩家信息
				self:syncActivity(needValue.index, needValue.roleId, needValue.rank)
			else
				--i3k_sbean.query_robot(targetId, rank)查询机器人信息响应
			end
		--end
	elseif needValue.index >= 14 and needValue.index <= power_fist_rank then--改自己的
		local myId = g_i3k_game_context:GetRoleId()
		local targetId = sender:getTag()
		if targetId > 0 then
			self:syncActivity(needValue.index, needValue.roleId, needValue.rank)
		end
	end




end

--预留接口：排行榜预留手动清除/刷新排行数据功能
--清除的输入范围[1,index]
function wnd_ranking_list:onclearRankList(itemId)

	local children = self._layout.vars.dungeon_scroll:getAddChild()
	--[[
	for i,v in pairs(children) do
		if itemId == v.vars.btn.actID then
			self._layout.vars.dungeon_scroll:removeChild(v)
		end

	end
	]]
	if itemId then
		self._layout.vars.dungeon_scroll:removeChildAtIndex(itemId)--清除
	else
		i3k_sbean.sync_rankList_info()--刷新
	end

end
--关联功能-称号系统
function wnd_ranking_list:setGetTitle(ranks,actId)
	self._nameid = 1
	for i,v in ipairs(i3k_db_rank_list[actId].rank) do
		if ranks <= v.ranklimit then
			self._nameid = v.nameid
			break
		end
		self._nameid = v.nameid
	end
	local cfg = nil
	if i3k_db_title_base[self._nameid] and i3k_db_title_base[self._nameid].name then
		 cfg= i3k_db_title_base[self._nameid].name
	end
	local iconbackground  = nil
	if i3k_db_title_base[self._nameid] and i3k_db_title_base[self._nameid].iconbackground then
		iconbackground = i3k_db_title_base[self._nameid].iconbackground
	end
	return cfg,iconbackground
end
function wnd_ranking_list:onOtherBtn()
	g_i3k_logic:OpenOtherRankListUI()
end

function wnd_ranking_list:onHelpBtn(sender)
	local msg = i3k_get_string(883)
	g_i3k_ui_mgr:ShowHelp(msg)
end

function wnd_create(layout)
	local wnd = wnd_ranking_list.new();
	wnd:create(layout);
	return wnd;
end
