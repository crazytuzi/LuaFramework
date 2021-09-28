
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/steedBase");

-------------------------------------------------------
wnd_steedSprite = i3k_class("wnd_steedSprite", ui.wnd_steedBase)

local WIDGET_ZQQZT2 = "ui/widgets/zqqzt2"
local WIDGET_ZQQZT3 = "ui/widgets/zqqzt3"


function wnd_steedSprite:ctor()
	self._item = {}
	self._lvl = nil;
	self._exp = nil;
	self._needExp = nil;
	self._upLvlItem = {}
	self._canUse = true
	self._showType = 0
end

function wnd_steedSprite:configure()
	-- 重写父类
	ui.wnd_steedBase.configure(self)

	self._showType = STEED_SPIRIT_STATE
	local widgets 		= self._layout.vars;

	widgets.spiritBtn:stateToPressed(true)
	widgets.moreShowBtn:onClick(self, self.onMoreShowBtn)
	widgets.upStarBtn:onClick(self, self.onSpiritUpStar)

	self.steed_point 	= widgets.steed_point
	self.steedSkinPoint = widgets.steedSkinPoint
	self.fightRedPoint	= widgets.fightRedPoint
	self.enhanceRed		= widgets.enhanceRed
	self.spiritRed		= widgets.spiritRed
	self.newSpiritRed   = widgets.newSpiritRed

	-- 良驹
	self.spiritWidgets = {}
	self.spiritWidgets.spiritModule = widgets.spiritModule
	self.spiritWidgets.starIcons = self:initSpiritStar(widgets)
	self.spiritWidgets.spiritShowName = widgets.spiritShowName
	self.spiritWidgets.spiritRankIcon = widgets.spiritRankIcon
	self.spiritWidgets.upStarScroll = widgets.upStarScroll
	self.spiritWidgets.spiritPower = widgets.spiritPower
	self.spiritWidgets.spiritPropScroll = widgets.spiritPropScroll
	self.spiritWidgets.sucessRate = widgets.sucessRate
	self.spiritWidgets.sucessTimes = widgets.sucessTimes
	self.spiritWidgets.upStarBtn = widgets.upStarBtn
	self.spiritWidgets.moreShowBtn = widgets.moreShowBtn
	self.spiritWidgets.spiritMaxStarRoot = widgets.spiritMaxStarRoot
	self.spiritWidgets.spiritNormalStarRoot = widgets.spiritNormalStarRoot

	self.spiritWidgets.skillWidgets = self:initSpiritSkillWidget(widgets)
end

function wnd_steedSprite:refresh()
    self:loadSteedSpiritInfo()
    self:UpdateSteedRed()
end

function wnd_steedSprite:initSpiritStar(widgets)
	local starNodes = {}
	for i = 1, i3k_db_steed_fight_base.rankStarCount do
		starNodes[i] = widgets["starIcon"..i]
	end
	return starNodes
end

function wnd_steedSprite:initSpiritSkillWidget(widgets)
	local skillNodes = {}
	for i = 1, 2 do
		skillNodes[i] = {
			skillIcon = widgets["skillIcon"..i],
			skillBtn = widgets["skillBtn"..i],
			skillName = widgets["skillName"..i],
			skillLvl = widgets["skillLvl"..i],
			skillFlicker = widgets["skillFlicker"..i], -- 闪烁
			skillRed = widgets["skillRed"..i],
			skillMaxIcon = widgets["skillMaxIcon"..i],
		}
	end
	return skillNodes
end

-------- 良驹之灵 began --------
function wnd_steedSprite:loadSteedSpiritInfo()
	self:loadSpiritModel()
	self:loadSpiritStarInfo()
	self:loadSpiritPropScroll()
	self:loadSpiritSkillsInfo()
end

-- 锤炼
function wnd_steedSprite:loadSpiritStarInfo()
	local rank = g_i3k_game_context:getSteedSpiritRank()
	local rankIconID = i3k_db_steed_fight_spirit_rank[rank + 1].rankIcon
	self.spiritWidgets.spiritRankIcon:setImage(g_i3k_db.g_i3k_db.i3k_db_get_icon_path(rankIconID))
	self:loadUpSpiritStarScroll()
end

function wnd_steedSprite:loadSpiritModel(actionName)
	local curShowID = g_i3k_game_context:getSteedSpiritCurShowID()
	local modelID = i3k_db_steed_fight_spirit_show[curShowID].UIModelID
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		self.spiritWidgets.spiritShowName:setText(i3k_db_steed_fight_spirit_show[curShowID].showName)
		self.spiritWidgets.spiritModule:setSprite(mcfg.path);
		self.spiritWidgets.spiritModule:setSprSize(mcfg.uiscale);
		if not actionName then
			self.spiritWidgets.spiritModule:playAction(i3k_db_steed_fight_base.defaultAction)
		else
			self.spiritWidgets.spiritModule:pushActionList(actionName,1)
			self.spiritWidgets.spiritModule:pushActionList(i3k_db_steed_fight_base.defaultAction, -1)
			self.spiritWidgets.spiritModule:playActionList()
		end
	end
end

function wnd_steedSprite:onMoreShowBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedSpiritShows)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritShows)
end

function wnd_steedSprite:loadUpSpiritStarScroll()
	if self._showType == STEED_SPIRIT_STATE then
		local spiritDB = i3k_db_steed_fight_spirit
		local star = g_i3k_game_context:getSteedSpiritStar()
		if star + 1 <= #spiritDB then
			self.spiritWidgets.upStarScroll:show()
			self._upSpiritStarItems = spiritDB[star + 1].consumeItems
			self.spiritWidgets.upStarScroll:removeAllChildren()
			for _, e in ipairs(self._upSpiritStarItems) do
				local widget = require(WIDGET_ZQQZT2)()
				-- widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
				if e.itemID ~= 0 then
					widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
					if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
						widget.vars.item_count:setText(e.itemCount)
					else
						widget.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
					end
					widget.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
					widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
					widget.vars.item_btn:onClick(self, self.onItemTips, e.itemID)
					self.spiritWidgets.upStarScroll:addItem(widget)
				end
			end
		else
			self.spiritWidgets.upStarScroll:hide()
		end
		self.spiritWidgets.spiritNormalStarRoot:setVisible(star + 1 <= #spiritDB)
		self.spiritWidgets.spiritMaxStarRoot:setVisible(star + 1 > #spiritDB)
		self:loadUpSpiritStarOther(star, spiritDB)
	end
end

function wnd_steedSprite:loadUpSpiritStarOther(star, spiritDB)
	for i, e in ipairs(self.spiritWidgets.starIcons) do
		e:setVisible(star == #spiritDB or i <= star % i3k_db_steed_fight_base.rankStarCount)
	end
	self.spiritWidgets.sucessRate:setVisible(star + 1 <= #spiritDB)
	self.spiritWidgets.sucessTimes:setVisible(star + 1 <= #spiritDB)
	self.spiritWidgets.upStarBtn:setVisible(star + 1 <= #spiritDB)
	if star + 1 <= #spiritDB then
		local rate = spiritDB[star + 1].successRate / 100
		local count = spiritDB[star + 1].certainSuccessTimes - g_i3k_game_context:getSteedSpiritUpStarTimes()
		self.spiritWidgets.sucessRate:setText(i3k_get_string(1283, rate))
		self.spiritWidgets.sucessTimes:setText(i3k_get_string(1284, count))
	end
end

function wnd_steedSprite:onSpiritUpStar(sender)
	if not g_i3k_db.i3k_db_get_item_is_enough_up(self._upSpiritStarItems) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1285))
	end
	local star = g_i3k_game_context:getSteedSpiritStar()
	i3k_sbean.horse_spirit_upstar_request(star + 1, self._upSpiritStarItems)
end

-- 右侧对比属性scroll 及战力
function wnd_steedSprite:loadSpiritPropScroll()
	self.spiritWidgets.spiritPower:setText(g_i3k_game_context:getSteedSpiritPower())
	local spiritDB = i3k_db_steed_fight_spirit
	local star = g_i3k_game_context:getSteedSpiritStar()
	local nowCfg = spiritDB[star] and spiritDB[star].propTb or {}
	local nextCfg = star == #spiritDB and spiritDB[#spiritDB].propTb or spiritDB[star + 1].propTb
	self.spiritWidgets.spiritPropScroll:removeAllChildren()
	for i, v in ipairs(nextCfg) do --下一级的数据
		if v.propID ~= 0 then
			local node = require(WIDGET_ZQQZT3)()
			local widget = node.vars
			local propID = g_i3k_game_context:dealXingHunPropId(v.propID)
			local icon = g_i3k_db.i3k_db_get_property_icon(propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propID))
			local nowValue = nowCfg[i] and nowCfg[i].propValue or 0
			local diffValue = v.propValue - nowValue
			local diffTxt = g_i3k_make_color_string(string.format(" +%s", i3k_get_prop_show(propID, diffValue)), g_i3k_get_green_color())
			widget.propertyValue:setText(i3k_get_prop_show(propID, nowValue))
			widget.differValue:setVisible(star ~= #spiritDB)
			widget.differValue:setText(diffTxt)
			self.spiritWidgets.spiritPropScroll:addItem(node)
		end
	end
end

-- 良驹之灵技能
function wnd_steedSprite:loadSpiritSkillsInfo()
	if self._showType == STEED_SPIRIT_STATE then
		local skills = self:sortSkills(g_i3k_game_context:getSteedSpiritSkills())
		local spiritRank = g_i3k_game_context:getSteedSpiritRank()
		for i, e in ipairs(skills) do
			local info = e.info
			local dbCfg = i3k_db_steed_fight_spirit_skill[info.id]
			local widget = self.spiritWidgets.skillWidgets[i]
			local isShowRed, needRank = g_i3k_game_context:getCanUpSteedSpiritSkillID(info.id, info)
			local showLvl = info.level == 0 and 1 or info.level
			local isNeedRank = spiritRank >= needRank
			local color, desc = self:getSpiritSkillLvlDescColor(spiritRank, isNeedRank, info, showLvl)
			widget.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(dbCfg[showLvl].skillIconID))
			widget.skillName:setText(dbCfg[showLvl].skillName)
			widget.skillLvl:setText(desc)
			widget.skillLvl:setTextColor(color)
			widget.skillLvl:setVisible(info.level ~= #dbCfg)
			widget.skillMaxIcon:setVisible(info.level == #dbCfg)
			widget.skillFlicker:setVisible(info.level ~= #dbCfg and isNeedRank)
			widget.skillRed:setVisible(isShowRed)
			widget.skillBtn:onClick(self, self.onSpiritSkillBtn, info)
		end
	end
end

function wnd_steedSprite:getSpiritSkillLvlDescColor(spiritRank, isNeedRank, info, showLvl)
	local desc = ""
	local color = ""
	if info.level <= 0 then
		desc = isNeedRank and i3k_get_string(1286) or i3k_get_string(1287, i3k_db_steed_fight_spirit_rank[showLvl+1].rankDesc)
		color = g_i3k_get_cond_color(isNeedRank)
	else
		color = g_i3k_get_white_color()
		desc = i3k_get_string(467, info.level)
	end
	return color, desc
end

-- 排序
function wnd_steedSprite:sortSkills(skillsInfo)
	local tmp = {}
	for k, v in ipairs(skillsInfo) do
		table.insert(tmp, {id = k, info = v})
	end
	table.sort(tmp, function (a,b)
		return a.id < b.id
	end)
	return tmp
end

function wnd_steedSprite:onSpiritSkillBtn(sender, info)
	if info.level <= 0 then --激活
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSpiritSkillUnlock)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritSkillUnlock, info.id, info.level)
		return
	end

	if info.level >=  #i3k_db_steed_fight_spirit_skill[info.id] then -- 满级
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSpiritSkillTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritSkillTips, info.id, info.level)
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_SteedSpiritSkillUp) -- 升级
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritSkillUp, info.id, info.level)
end

function wnd_steedSprite:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_steedSprite:UpdateSteedRed()
	local widgets = self._layout.vars
	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook())
	self.fightRedPoint:setVisible(g_i3k_game_context:getIsShowSteedFightRed())
	self.enhanceRed:setVisible(g_i3k_game_context:canfightSteedRed())
	self.spiritRed:setVisible(g_i3k_game_context:getIsShowSteedSpiritRed())
	self.newSpiritRed:setVisible(g_i3k_game_context:canUnlockNewSpirit())
	widgets.equipRed:setVisible(g_i3k_game_context:getSteedEquipRed())
	widgets.suitRed:setVisible(g_i3k_game_context:getSteedEquipSuitRed())
	widgets.stoveRed:setVisible(g_i3k_game_context:getSteedEquipStoveRed())
end
-------- 良驹之灵 end --------



function wnd_steedSprite:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1264))
end


function wnd_create(layout)
	local wnd = wnd_steedSprite.new();
		wnd:create(layout);
	return wnd;
end
