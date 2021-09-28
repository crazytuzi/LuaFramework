-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_star = i3k_class("wnd_steed_star", ui.wnd_base)

function wnd_steed_star:ctor()
	self._id = nil
	self._star = nil
	self._starCfg = nil
end

function wnd_steed_star:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	
	local widgets = self._layout.vars
	local root = {}
	root.starImgTable = {
		[1] = widgets.star1,
		[2] = widgets.star2,
		[3] = widgets.star3,
		[4] = widgets.star4,
		[5] = widgets.star5,
		[6] = widgets.star6,
		[7] = widgets.star7,
		[8] = widgets.star8,
		[9] = widgets.star9,
	}
	
	root.needItem1 = {}
	root.needItem1.nameLabel = widgets.itemNameLabel1
	root.needItem1.countLabel = widgets.itemCountLabel1
	root.needItem1.gradeIcon = widgets.itemGradeIcon1
	root.needItem1.icon = widgets.itemIcon1
	root.needItem1.lock = widgets.itemLock1
	root.needItem1.btn = widgets.itemBtn1
	
	root.needItem2 = {}
	root.needItem2.nameLabel = widgets.itemNameLabel2
	root.needItem2.countLabel = widgets.itemCountLabel2
	root.needItem2.gradeIcon = widgets.itemGradeIcon2
	root.needItem2.icon = widgets.itemIcon2
	root.needItem2.lock = widgets.itemLock2
	root.needItem2.btn = widgets.itemBtn2
	
	root.scroll = widgets.scroll
	root.riseBtn = widgets.starBtn
	
	self._widgets = root
end

function wnd_steed_star:refresh(info, starAttr)
	local starLvl = info.star
	self._layout.vars.descLabel:setText(i3k_db_steed_star[info.id][starLvl].starTips)
	
	for i,v in ipairs(self._widgets.starImgTable) do
		if i>starLvl then
			v:disable()
		else
			v:enable()
		end
	end
	
	local starCfg = i3k_db_steed_star[info.id][starLvl+1]
	local nextStarAttr = {
		[starCfg.attrId1] = {attrId = starCfg.attrId1, attrValue = starCfg.attrValue1, sortId = 1},
		[starCfg.attrId2] = {attrId = starCfg.attrId2, attrValue = starCfg.attrValue2, sortId = 2},
		[starCfg.attrId3] = {attrId = starCfg.attrId3, attrValue = starCfg.attrValue3, sortId = 3},
		[starCfg.attrId4] = {attrId = starCfg.attrId4, attrValue = starCfg.attrValue4, sortId = 4},
		[starCfg.attrId5] = {attrId = starCfg.attrId5, attrValue = starCfg.attrValue5, sortId = 5},
		[starCfg.attrId6] = {attrId = starCfg.attrId6, attrValue = starCfg.attrValue6, sortId = 6},
		[starCfg.attrId7] = {attrId = starCfg.attrId7, attrValue = starCfg.attrValue7, sortId = 7},
		[starCfg.attrId8] = {attrId = starCfg.attrId8, attrValue = starCfg.attrValue8, sortId = 8},
		[starCfg.attrId9] = {attrId = starCfg.attrId9, attrValue = starCfg.attrValue9, sortId = 9},
	}
	nextStarAttr[0] = nil
	local sortTable = {}
	for i,v in pairs(nextStarAttr) do
		table.insert(sortTable, v)
	end
	table.sort(sortTable, function (a, b)
		return a.sortId<b.sortId
	end)
	
	local starCfgNow = i3k_db_steed_star[info.id][starLvl]
	local nowStarAttr = {
		[starCfgNow.attrId1] = {attrId = starCfgNow.attrId1, attrValue = starCfgNow.attrValue1, sortId = 1},
		[starCfgNow.attrId2] = {attrId = starCfgNow.attrId2, attrValue = starCfgNow.attrValue2, sortId = 2},
		[starCfgNow.attrId3] = {attrId = starCfgNow.attrId3, attrValue = starCfgNow.attrValue3, sortId = 3},
		[starCfgNow.attrId4] = {attrId = starCfgNow.attrId4, attrValue = starCfgNow.attrValue4, sortId = 4},
		[starCfgNow.attrId5] = {attrId = starCfgNow.attrId5, attrValue = starCfgNow.attrValue5, sortId = 5},
		[starCfgNow.attrId6] = {attrId = starCfgNow.attrId6, attrValue = starCfgNow.attrValue6, sortId = 6},
		[starCfgNow.attrId7] = {attrId = starCfgNow.attrId7, attrValue = starCfgNow.attrValue7, sortId = 7},
		[starCfgNow.attrId8] = {attrId = starCfgNow.attrId8, attrValue = starCfgNow.attrValue8, sortId = 8},
		[starCfgNow.attrId9] = {attrId = starCfgNow.attrId9, attrValue = starCfgNow.attrValue9, sortId = 9},
	}
	nowStarAttr[0] = nil
	local nowSortTable = {}
	for i,v in pairs(nowStarAttr) do
		table.insert(nowSortTable, v)
	end
	table.sort(nowSortTable, function (a, b)
		return a.sortId<b.sortId
	end)
	
	self._widgets.scroll:removeAllChildren()
	for i,v in ipairs(sortTable) do
		local node = require("ui/widgets/zqsxt")()
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.attrId))
		node.vars.nameLabel:setText(i3k_db_prop_id[v.attrId].desc.."：")
		local value = v.attrValue - (nowSortTable[i] and nowSortTable[i].attrValue or 0)
		node.vars.valueLabel:setText("+"..i3k_get_prop_show(v.attrId, value))
		node.vars.backImg1:setVisible(i%2==0)
		node.vars.backImg2:setVisible(not node.vars.backImg1:isVisible())
		self._widgets.scroll:addItem(node)
	end
	self._id = info.id
	self._star = info.star
	self._starCfg = starCfg
	self:setNeedItemData()
end

function wnd_steed_star:setNeedItemData()
	local steedId = self._id
	local starLvl = self._star
	local starCfg = self._starCfg
	local needId1 = starCfg.starNeedId1
	local needCount1 = starCfg.starNeedCount1
	local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needId1)
	local needId2 = starCfg.starNeedId2
	local needCount2 = starCfg.starNeedCount2
	local itemCount2 = g_i3k_game_context:GetCommonItemCanUseCount(needId2)
	
	self._widgets.needItem1.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(needId1))
	local rank = g_i3k_db.i3k_db_get_common_item_rank(needId1)
	self._widgets.needItem1.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
	self._widgets.needItem1.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId1))
	self._widgets.needItem1.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId1,i3k_game_context:IsFemaleRole()))
	self._widgets.needItem1.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needId1))
	if math.abs(needId1) == g_BASE_ITEM_COIN then
		self._widgets.needItem1.countLabel:setText(needCount1)
	else
		self._widgets.needItem1.countLabel:setText(itemCount1.."/"..needCount1)
	end
	self._widgets.needItem1.countLabel:setTextColor(g_i3k_get_cond_color(needCount1<=itemCount1))
	self._widgets.needItem1.btn:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needId1)
	end)
	
	self._widgets.needItem2.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(needId2))
	local rank2 = g_i3k_db.i3k_db_get_common_item_rank(needId2)
	self._widgets.needItem2.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank2))
	self._widgets.needItem2.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId2))
	self._widgets.needItem2.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId2,i3k_game_context:IsFemaleRole()))
	self._widgets.needItem2.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needId2))
	if math.abs(needId2) == g_BASE_ITEM_COIN then
		self._widgets.needItem2.countLabel:setText(needCount2)
	else
		self._widgets.needItem2.countLabel:setText(itemCount2.."/"..needCount2)
	end
	self._widgets.needItem2.countLabel:setTextColor(g_i3k_get_cond_color(needCount2<=itemCount2))
	self._widgets.needItem2.btn:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needId2)
	end)
	local needValue = {steedId = steedId, starLvl = starLvl+1, needItem = {[needId1] = needCount1, [needId2] = needCount2}, canRise = needCount1<=itemCount1 and needCount2<=itemCount2}
	self._widgets.riseBtn:onClick(self, self.onRiseStar, needValue)
end

function wnd_steed_star:onRiseStar(sender, needValue)
	if needValue.canRise then
		local callback = function ()
			for i,v in pairs(needValue.needItem) do
				g_i3k_game_context:UseCommonItem(i, v,AT_UP_STAR_HORSE)
			end
		end
		i3k_sbean.rise_star(needValue.steedId, needValue.starLvl, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(201))
	end
end

function wnd_steed_star:updateNextNeedItems(steedId, starLvl)
	local starCfg = i3k_db_steed_star[steedId][starLvl+1]
	if starCfg then
		self._id = steedId
		self._star = starLvl
		self._starCfg = starCfg
		self:setNeedItemData()
	end
end

function wnd_steed_star:riseSuccessed(steedId, info)
	info.star = info.star + 1
	local starCfg = i3k_db_steed_star[info.id][info.star+1]
	if starCfg then
		self._layout.vars.starAnis:setPosition(self._widgets.starImgTable[info.star]:getPosition())
		self._layout.vars.starAnis:show()
		self._layout.anis.c_zqsx.play()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(202))
		local starAttr = {
			[starCfg.attrId1] = {attrId = starCfg.attrId1, attrValue = starCfg.attrValue1},
			[starCfg.attrId2] = {attrId = starCfg.attrId2, attrValue = starCfg.attrValue2},
			[starCfg.attrId3] = {attrId = starCfg.attrId3, attrValue = starCfg.attrValue3},
			[starCfg.attrId4] = {attrId = starCfg.attrId4, attrValue = starCfg.attrValue4},
			[starCfg.attrId5] = {attrId = starCfg.attrId5, attrValue = starCfg.attrValue5},
			[starCfg.attrId6] = {attrId = starCfg.attrId6, attrValue = starCfg.attrValue6},
			[starCfg.attrId7] = {attrId = starCfg.attrId7, attrValue = starCfg.attrValue7},
			[starCfg.attrId8] = {attrId = starCfg.attrId8, attrValue = starCfg.attrValue8},
			[starCfg.attrId9] = {attrId = starCfg.attrId9, attrValue = starCfg.attrValue9},
		}
		starAttr[0] = nil
		g_i3k_game_context:setSteedStarAttr(steedId, starAttr)
		
		self:refresh(info, starAttr)
		g_i3k_game_context:setSteedInfo(info)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(203))
		g_i3k_ui_mgr:CloseUI(eUIID_SteedStar)
	end
	g_i3k_game_context:RefreshRideProps()
end

function wnd_create(layout, ...)
	local wnd = wnd_steed_star.new()
	wnd:create(layout, ...)
	return wnd;
end