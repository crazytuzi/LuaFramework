-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
local ITEM_WIDGET = "ui/widgets/wuhunt1"
local PROP_WIDGET = "ui/widgets/wuhunt2"

wnd_martial_soul = i3k_class("wnd_martial_soul",ui.wnd_base)

function wnd_martial_soul:ctor()
	self._partWidgets = {}
	self._upLvlWidgets = {}
	self._selectPos = 1 -- 默认选中第一个部位
	self._nextLvlCfg = {} -- 选中的，下级部位等级配置
	self._isChange = false
	self._poptick = 0
end

function wnd_martial_soul:configure()
	local widgets = self._layout.vars
	self:initPartWidget(widgets)
	self.battle_power = widgets.battle_power
	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
	self.soulModule = widgets.soulModule
	self.rankRed	= widgets.rankRed
	self.addRed		= widgets.addRed
	self.rankDesc	= widgets.rankDesc
	self.soulRed	= widgets.soulRed
	self.starRed	= widgets.starRed
	self.shenDouRed = widgets.shenDouRed
	self._upLvlWidgets = {
		partName 	= widgets.partName,
		propScroll	= widgets.propScroll,
		itemScroll	= widgets.itemScroll,
		promptDesc1	= widgets.promptDesc1,
		promptDesc2 = widgets.promptDesc2,
		upLvlBtn	= widgets.upLvlBtn,
		max			= widgets.max,
		consumeRoot = widgets.consumeRoot,
	}
	widgets.soulBtn:stateToPressed()
	widgets.starBtn:stateToNormal()

	widgets.changeBtn:onClick(self, self.onChange)
	widgets.upRankBtn:onClick(self, self.onUpRank)
	widgets.checkPropBtn:onClick(self, self.onCheckProp)
	widgets.upLvlBtn:onClick(self, self.OnUpLvl)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.starBtn:onClick(self, self.onStarDish)
	widgets.shenDouBtn:onClick(self, self.onShenDouBtn)
	widgets.shenDouBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_martial_soul_cfg.shenDouShowLvl)
end

function wnd_martial_soul:initPartWidget(widgets)
	for i=1, 8 do
		local partBtn = "part"..i.."Btn"
		local partIcon = "partIcon"..i
		local partLvl = "partLvl"..i
		local redPoint = "redPoint"..i
		local is_select = "is_select"..i

		self._partWidgets[i] = {
			partBtn		= widgets[partBtn],
			partIcon	= widgets[partIcon],
			partLvl		= widgets[partLvl],
			redPoint	= widgets[redPoint],
			is_select	= widgets[is_select],
		}
	end
end

function wnd_martial_soul:refresh()
	self:updateAddSkinPoint()
	self:updateGradePoint()
	self:loadPartData()
	self:updateLeftSelect()
	self:updateUpData()
	self:updateSoulModel()
	self:loadBattlePower()
	self:updateMartialSoulRed()
end

function wnd_martial_soul:loadPartData()
	local partsInfo = g_i3k_game_context:GetWeaponSoulParts()
	for i, e in ipairs(i3k_db_martial_soul_part) do
		local widget = self._partWidgets[i]
		local lvl = partsInfo[i].level
		widget.partIcon:setImage(g_i3k_db.i3k_db_get_icon_path(e.partIcon))
		widget.partLvl:setText(lvl)
		widget.redPoint:setVisible(g_i3k_game_context:IsWeaponSoulCanUpLvl(i))
		widget.partBtn:onClick(self, self.onSelectPart, i)
	end
end

-- 右侧升级数据
function wnd_martial_soul:updateUpData()
	local lvl = g_i3k_game_context:GetWeaponSoulPartLvl(self._selectPos)
	if i3k_db_martial_soul_level[self._selectPos] then
		local partCfg = i3k_db_martial_soul_part[self._selectPos]
		self._upLvlWidgets.partName:setText(i3k_get_string(1067, partCfg.partName, lvl))
		self._upLvlWidgets.partName:setTextColor(partCfg.textColor)
		self._upLvlWidgets.partName:enableOutline(partCfg.textOutLine)
		self:updatePropScroll(i3k_db_martial_soul_level[self._selectPos][lvl])
		local nextCfg = i3k_db_martial_soul_level[self._selectPos][lvl+1]
		local isMax = nextCfg == nil and true or false
		self._upLvlWidgets.upLvlBtn:setVisible(not isMax)
		self._upLvlWidgets.promptDesc1:setVisible(not isMax)
		self._upLvlWidgets.consumeRoot:setVisible(not isMax)
		self._upLvlWidgets.max:setVisible(isMax)
		if i3k_db_martial_soul_level[self._selectPos][lvl + 1] then
			self._nextLvlCfg = i3k_db_martial_soul_level[self._selectPos][lvl+1]
			self:updatePropScroll(i3k_db_martial_soul_level[self._selectPos][lvl])
			self:updateItemScroll()
			self._upLvlWidgets.promptDesc1:setText(i3k_get_string(1061, i3k_db_martial_soul_rank[self._nextLvlCfg.needRank].rankName))
			self._upLvlWidgets.promptDesc1:setVisible(g_i3k_game_context:GetWeaponSoulGrade() < self._nextLvlCfg.needRank)
			if g_i3k_game_context:GetWeaponSoulGrade() >= self._nextLvlCfg.needRank then
				self._upLvlWidgets.upLvlBtn:enableWithChildren()
			else
				self._upLvlWidgets.upLvlBtn:disableWithChildren()
			end
		else
			self._layout.anis.max.play()
		end
	end
end

function wnd_martial_soul:updatePropScroll(nowLvlcfg)
	self._upLvlWidgets.propScroll:removeAllChildren()
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_MARTIAL_ID)
	for i, e in ipairs(nowLvlcfg.propTb) do
		if e.propID ~= 0 then
			local node = require(PROP_WIDGET)()
			local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
			node.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			node.vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
			node.vars.propertyValue:setText(i3k_get_prop_show(e.propID, math.modf(e.propValue * (1 + ratio))))
			self._upLvlWidgets.propScroll:addItem(node)
		end
	end
end

function wnd_martial_soul:updateItemScroll()
	if self._upLvlWidgets.consumeRoot:isVisible() then
		self._upLvlWidgets.itemScroll:removeAllChildren()
		for i, e in ipairs(self._nextLvlCfg.needItems) do
			if e.itemID ~= 0 then
				local node = require(ITEM_WIDGET)()
				node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
				if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
					node.vars.item_count:setText(e.itemCount)
				else
					node.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
				end
				node.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
				node.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
				node.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemID))
				node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemID)))
				node.vars.bt:onClick(self, self.onItemTips, e.itemID)
				node.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
				self._upLvlWidgets.itemScroll:addItem(node)
			end
		end
	end
end

function wnd_martial_soul:updateLeftSelect()
	for i, e in ipairs(self._partWidgets) do
		e.is_select:setVisible(i == self._selectPos)
	end
end

function wnd_martial_soul:onSelectPart(sender, pos)
	-- 刷新选中，刷新右边描述
	if self._selectPos ~= pos then
		self._selectPos = pos
		self:updateUpData()
		self:updateLeftSelect()
	end
end

function wnd_martial_soul:updateSoulModel()
	local curShowID = g_i3k_game_context:GetWeaponSoulCurShow()
	local cfg = i3k_db_martial_soul_display[curShowID]
	local mcfg = i3k_db_models[cfg.modelID];
	if mcfg then
		self.soulModule:setSprite(mcfg.path);
		self.soulModule:setSprSize(mcfg.uiscale);
		self.soulModule:playAction("show");
		self.soulModule:setColor( tonumber(mcfg.color, 16) or 0xFFFFFFF);
	end
end

function wnd_martial_soul:loadBattlePower()
	self.battle_power:setText(g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetWeaponSoulPropData()))
end

function wnd_martial_soul:onStarDish(sender)
	if g_i3k_game_context:GetLevel() >= i3k_db_martial_soul_cfg.starOpenLvl  then
		if not g_i3k_ui_mgr:GetUI(eUIID_StarDish) then
			g_i3k_ui_mgr:CloseUI(eUIID_MartialSoul)
			g_i3k_ui_mgr:OpenUI(eUIID_StarDish)
			g_i3k_ui_mgr:RefreshUI(eUIID_StarDish)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("星耀系统%d级开启", i3k_db_martial_soul_cfg.starOpenLvl ))
	end
end
function wnd_martial_soul:onShenDouBtn()
	g_i3k_logic:OpenShenDouUI(eUIID_MartialSoul)
end

function wnd_martial_soul:onChange(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MartialSoulSkin)
	g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoulSkin)
end

function wnd_martial_soul:onUpRank(sender)
	if not g_i3k_game_context:isMaxGrade() then
		g_i3k_ui_mgr:OpenUI(eUIID_MartialSoulStage)
		g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoulStage)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1071));
	end
end

function wnd_martial_soul:onCheckProp(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MartialSoulProp)
	g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoulProp)
end

function wnd_martial_soul:OnUpLvl(sender)
	local isCanUpLvl, needItems = g_i3k_game_context:IsWeaponSoulCanUpLvl(self._selectPos)
	if not isCanUpLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1066))
	end
	local curLvl = g_i3k_game_context:GetWeaponSoulPartLvl(self._selectPos)
	i3k_sbean.weaponSoulLvlup(self._selectPos, curLvl + 1, needItems)
end

function wnd_martial_soul:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1068))
end

function wnd_martial_soul:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_martial_soul:changeBattlePower(newBattlePower, oldBattlePower) --战力变化动画
	self._isChange = true
	self._poptick = 0
	self._target = newBattlePower
	self._base = oldBattlePower
end

function wnd_martial_soul:onUpdate(dTime)
	if self._isChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self.battle_power:setText(text)
			self.addIcon:show()
			self.powerValue:show()
			if self._target >= self._base then
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				self.powerValue:setText("+"..self._target - self._base)
			else
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				self.powerValue:setText(self._target - self._base)
			end
			self.powerValue:setTextColor(g_i3k_get_cond_color(self._target >= self._base))
		elseif self._poptick >= 1 and self._poptick < 2 then
			self.battle_power:setText(self._target)
			self.addIcon:hide()
			self.powerValue:hide()
		elseif self._poptick > 2 then
			self.addIcon:hide()
			self.powerValue:hide()
			self._isChange = false
		end
	end
end

function wnd_martial_soul:updateAddSkinPoint()
	self.addRed:setVisible(g_i3k_game_context:isShowAddSkinRed());
end

function wnd_martial_soul:updateGradePoint()
	local Grade =  g_i3k_game_context:GetWeaponSoulGrade();
	local soul =  i3k_db_martial_soul_rank[Grade];
	self.rankDesc:setText(i3k_get_string(1081,soul.rankName));
	self.rankRed:setVisible(g_i3k_game_context:isShowGradeRed());
end

function wnd_martial_soul:updateMartialSoulRed()
	self.soulRed:setVisible(g_i3k_game_context:IsWeaponSoulCanUp())
	self.shenDouRed:setVisible(g_i3k_db.i3k_db_get_shen_dou_red())
end

function wnd_martial_soul:updatePartPoint()
	for i=1, 8 do
		self._partWidgets[i].redPoint:setVisible(g_i3k_game_context:IsWeaponSoulCanUpLvl(i))
	end
end

function wnd_create(layout)
	local wnd = wnd_martial_soul.new()
	wnd:create(layout)
	return wnd
end
