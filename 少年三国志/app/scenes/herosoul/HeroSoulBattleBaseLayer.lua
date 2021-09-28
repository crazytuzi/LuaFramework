local HeroSoulBattleBaseLayer = class("HeroSoulBattleBaseLayer", UFCCSModelLayer)

require("app.cfg.ksoul_fight_base_info")
local KnightPic 		= require("app.scenes.common.KnightPic")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local HeroSoulBattleBaseItem = require("app.scenes.herosoul.HeroSoulBattleBaseItem")

function HeroSoulBattleBaseLayer.show()
	local layer = HeroSoulBattleBaseLayer.new("ui_layout/herosoul_BattleBaseLayer.json", Colors.modelColor)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulBattleBaseLayer:ctor(jsonFile, color)
	self._listView 	= nil
	self._curCell	= nil
	self._curSelId 	= 0
	self._unlockStates = {}
	self.super.ctor(self, jsonFile, color)
end

function HeroSoulBattleBaseLayer:onLayerLoad()
	-- initialize base unlock states
	self:_initUnlockStates()

	-- initialize hero picture
	self:_initHeroPic()

	-- initialize base list view
	self:_initListView()

	-- label stroke
	self:enableLabelStroke("Label_BaseName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_UnlockCond", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CurProgress", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Progress", Colors.strokeBrown, 1)
	
	-- button click events
	self:registerBtnClickEvent("Button_Use", handler(self, self._onClickUse))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
end

function HeroSoulBattleBaseLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_SET_FIGHT_BASE, self._onRcvSetBase, self)
end

-- initialize the unlock states of each battle-base
function HeroSoulBattleBaseLayer:_initUnlockStates()
	local num = ksoul_fight_base_info.getLength()
	for i = 1, num do
		local info = ksoul_fight_base_info.get(i)
		local reqChapter 	= info.chapter_id
		local reqChartNum	= info.group_num
		local curActivated	= G_Me.heroSoulData:getActivatedChartsNumByChap(reqChapter)
		self._unlockStates[i] = curActivated >= reqChartNum
	end
end

-- initialize the hero picture
function HeroSoulBattleBaseLayer:_initHeroPic()
	local parent = self:getPanelByName("Panel_Hero")
	local resID  = G_Me.dressData:getDressedPic()
	local heroPic = KnightPic.createBattleKnightPic(resID, parent, "Knight_Pic", false)
end

function HeroSoulBattleBaseLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)

		self._listView:setCreateCellHandler(function(list, index)
			return HeroSoulBattleBaseItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1, self._unlockStates[index + 1])
		end)

		self._listView:setClickCellHandler(function(list, index, cell)
			self:_selectBaseCell(index, cell)
		end)
	end

	self._listView:reloadWithLength(ksoul_fight_base_info.getLength())

	-- default base
	local curIndex  = G_Me.userData.fight_base - 1
	self:_selectBaseCell(curIndex, self._listView:getCellByIndex(curIndex))
end

-- select a battle-base
function HeroSoulBattleBaseLayer:_selectBaseCell(index, cell)
	if self._curCell == cell then
		return
	end

	-- deselect the previous selected cell
	if self._curCell then
		self._curCell:Deselect()
	end

	-- select current
	cell:onSelect()
	self._curCell = cell

	-- scroll to this cell
	self._listView:scrollToShowCell(index)

	-- update info
	self._curSelId = index + 1
	self:_updatePreview(self._curSelId)
	self:_updateUsageState(self._curSelId)
end

-- update the preview info of current selected battle-base
function HeroSoulBattleBaseLayer:_updatePreview(baseId)
	local info = ksoul_fight_base_info.get(baseId)

	-- battle-base image
	local imgPath = "battle/base/base_" .. info.own_image .. ".png"
	self:getImageViewByName("Image_Base"):loadTexture(imgPath)

	-- battle-base name
	local nameLabel = self:getLabelByName("Label_BaseName")
	nameLabel:setText(info.name)
	nameLabel:setColor(Colors.qualityColors[info.quality])

	-- battle-base description
	self:showTextWithLabel("Label_BaseDesc", info.directions)
end

-- update the usage state of current selected battle-base
function HeroSoulBattleBaseLayer:_updateUsageState(baseId)
	local isInUse = baseId == G_Me.userData.fight_base
	local isUnlocked = self._unlockStates[baseId]

	self:showWidgetByName("Button_Use", isUnlocked and not isInUse)
	self:showWidgetByName("Image_Used", isInUse)
	self:showWidgetByName("Panel_UnlockCond", not isUnlocked)

	if not isUnlocked then
		local info = ksoul_fight_base_info.get(baseId)
		local reqChapter = info.chapter_id
		local reqCharts  = info.group_num
		local curCharts  = G_Me.heroSoulData:getActivatedChartsNumByChap(reqChapter)
		local condition  = G_lang:get("LANG_HERO_SOUL_BATTLE_BASE_COND", {chapter = reqChapter, num = reqCharts})
		local progress 	 = "（" .. curCharts .. "/" .. reqCharts .. "）"
		self:showTextWithLabel("Label_UnlockCond", condition)
		self:showTextWithLabel("Label_Progress", progress)
	end
end

-- set the battle-base successfully
function HeroSoulBattleBaseLayer:_onRcvSetBase(baseId)
	self:_updateUsageState(baseId)
	G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_USE_SUCCESS"))
end

function HeroSoulBattleBaseLayer:_onClickUse()
	G_HandlersManager.heroSoulHandler:sendSetFightBase(self._curSelId)
end

function HeroSoulBattleBaseLayer:_onClickClose()
	self:animationToClose()
end

return HeroSoulBattleBaseLayer