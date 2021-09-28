-- CrossWarScoreRankLayer
-- This Layer shows the score rank of all the groups.

local CrossWarScoreRankLayer = class("CrossWarScoreRankLayer", UFCCSModelLayer)

require("app.cfg.contest_rank_award_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local Goods = require("app.setting.Goods")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")
local RankItem = require("app.scenes.crosswar.CrossWarRankItem")
local AwardItem = require("app.scenes.crosswar.CrossWarRankAwardItem")

function CrossWarScoreRankLayer.create(...)
	return CrossWarScoreRankLayer.new("ui_layout/crosswar_ScoreRankLayer.json",
		Colors.modelColor, caller, ...)
end

function CrossWarScoreRankLayer:ctor(jsonFile, color, ...)
	self._selGroup = 1
	self._prevSelectGroupBtn = nil
	self._rankPanel = self:getPanelByName("Panel_Rank")
	self._awardPanel = self:getPanelByName("Panel_RankAwards")
	self._rankListView = nil
	self._awardListView = nil
	self._itemInfo = nil
	self._titleID = 0

	self.super.ctor(self, ...)
end

function CrossWarScoreRankLayer:onLayerLoad(...)
	-- create strokes for some labels
	self:enableLabelStroke("Label_GroupDesc", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CurTitle", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_GiveTime", Colors.strokeBlack, 1)
	self:enableLabelStroke("Label_GiveAward", Colors.strokeBlack, 1)

	-- initialize my info, and rank and award list view
	self:_initRankListView()
	self:_initAwardListView()
	self:_initMyInfo()

	-- register button events
	self:registerBtnClickEvent("Button_Group_1", handler(self, self._onClickGroup))
	self:registerBtnClickEvent("Button_Group_2", handler(self, self._onClickGroup))
	self:registerBtnClickEvent("Button_Group_3", handler(self, self._onClickGroup))
	self:registerBtnClickEvent("Button_Group_4", handler(self, self._onClickGroup))
	self:registerBtnClickEvent("Button_RankAward", handler(self, self._onClickAwardList))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_CurTitle", handler(self, self._onClickTitle))
	self:registerBtnClickEvent("Button_CurQualityFrame", handler(self, self._onClickAwardInfo))

	-- select the group I belong to
	local myGroup = G_Me.crossWarData:getGroup()
	if myGroup == 0 then
		myGroup = 1
	end
	self:_onClickGroup(self:getWidgetByName("Button_Group_" .. myGroup))
end

function CrossWarScoreRankLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_RANK, self._reloadRankList, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE_MATCH_RANK, self._updateRankAndAward, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)	
end

function CrossWarScoreRankLayer:onBackKeyEvent(...)
	self:_onClickClose()
	return true
end

-- initialize the ranking list view
function CrossWarScoreRankLayer:_initRankListView()
	if not self._rankListView then
		local panel = self:getPanelByName("Panel_RankList")
		self._rankListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		
		self._rankListView:setCreateCellHandler(function(list, index)
			return RankItem.new(CrossWarCommon.RANK_SCORE)
		end)

		self._rankListView:setUpdateCellHandler(function(list, index, cell)
			local data = G_Me.crossWarData:getScoreRankItem(self._selGroup, index + 1)
			cell:update(index + 1, data)
		end)
	end

	-- hide the rank list view by default
	self._rankListView:setVisible(false)
end

-- initialize the award list view
function CrossWarScoreRankLayer:_initAwardListView()
	if not self._awardListView then
		local panel = self:getPanelByName("Panel_AwardList")
		self._awardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._awardListView:setCreateCellHandler(function(list, index)
			return AwardItem.new(CrossWarCommon.MODE_SCORE_MATCH)
		end)

		self._awardListView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	local num = 0
	for i = 1, contest_rank_award_info.getLength() do
		if contest_rank_award_info.get(i).type == CrossWarCommon.MODE_SCORE_MATCH then
			num = num + 1
		end
	end
	self._awardListView:reloadWithLength(num, self._awardListView:getShowStart())
end

-- initialize my info
function CrossWarScoreRankLayer:_initMyInfo()
	local myGroup = G_Me.crossWarData:getGroup()
	local groupLabel = self:getLabelByName("Label_Group")
	groupLabel:setVisible(myGroup > 0)

	-- set my group name
	if myGroup > 0 then
		local groupName = contest_points_buff_info.get(myGroup).name
		groupLabel:setText(groupName)
	end

	-- set my score
	self:_updateScore()

	-- set my rank and award
	self:_updateRankAndAward()

	-- show the award countdown if match is in progress
	local isInMatch = G_Me.crossWarData:isInScoreMatch()
	self:showWidgetByName("Panel_GiveAward_Tip", isInMatch)
end

-- the click handler of the group buttons
function CrossWarScoreRankLayer:_onClickGroup(widget)
	-- show rank panel and hide award panel
	self._rankPanel:setVisible(true)
	self._awardPanel:setVisible(false)

	-- enable previous selected button
	if self._prevSelectGroupBtn then
		self._prevSelectGroupBtn:setTouchEnabled(true)
	end

	-- disable current selected button
	if widget then
		widget:setTouchEnabled(false)
	end

	-- record this widget as previous selected
	self._prevSelectGroupBtn = widget
	self._selGroup = widget:getTag()

	-- update group description label
	local groupDesc = contest_points_buff_info.get(self._selGroup).tips
	self:getLabelByName("Label_GroupDesc"):setText(groupDesc)

	-- request rank list if needed
	if G_Me.crossWarData:hasFinalScoreRank(self._selGroup) then
		self:_reloadRankList()
	else
		G_HandlersManager.crossWarHandler:sendGetBattleRank(self._selGroup)
	end
end

-- the click handler of the award button
function CrossWarScoreRankLayer:_onClickAwardList()
	-- show award panel and hide rank panel
	self._awardPanel:setVisible(true)
	self._rankPanel:setVisible(false)

	-- enable previous selected group button
	if self._prevSelectGroupBtn then
		self._prevSelectGroupBtn:setTouchEnabled(true)
		self._prevSelectGroupBtn = nil
	end
end

function CrossWarScoreRankLayer:_onClickTitle()
	local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(self._titleID)
	uf_sceneManager:getCurScene():addChild(dialog)
end

-- the click handler of the award icon
function CrossWarScoreRankLayer:_onClickAwardInfo()
	local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(self._itemInfo)
    uf_sceneManager:getCurScene():addChild(layer)
end

-- the click handler of the close button
function CrossWarScoreRankLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

-- reload rank list
function CrossWarScoreRankLayer:_reloadRankList()
	-- reload the list
	local len = G_Me.crossWarData:getScoreRankNum(self._selGroup)
	self._rankListView:setVisible(true)
	self._rankListView:reloadWithLength(len)

	-- no one in the rank list, show a tip
	self:showWidgetByName("Label_NoRankList", len == 0)
	if len == 0 then
		local groupName = contest_points_buff_info.get(self._selGroup).name
		local tip = G_lang:get("LANG_CROSS_WAR_NO_RANK_LIST", {group = groupName})
		self:showTextWithLabel("Label_NoRankList", tip)
	end
end

-- update my score
function CrossWarScoreRankLayer:_updateScore()
	local score = G_Me.crossWarData:getScore()
	self:getLabelByName("Label_MyScore_Num"):setText(tostring(score))
end

-- update my current rank and award
function CrossWarScoreRankLayer:_updateRankAndAward()
	-- rank image: 前三名显示图片， rank label: 其他名次显示数字， not in rank: 未上榜
	local myRankImage_1	= self:getImageViewByName("Image_MyRank_1")
	local myRankLabel_1 = self:getLabelBMFontByName("BitmapLabel_MyRank_1")
	local meNotInRank_1	= self:getLabelByName("Label_NotInRank_1")
	local myRankImage_2	= self:getImageViewByName("Image_MyRank_2")
	local myRankLabel_2 = self:getLabelBMFontByName("BitmapLabel_MyRank_2")
	local meNotInRank_2	= self:getLabelByName("Label_NotInRank_2")
	local titleButton	= self:getButtonByName("Button_CurTitle")
	local titleText		= self:getLabelByName("Label_CurTitle")
	local award 		= self:getImageViewByName("Image_CurAward")

	local rank 			= G_Me.crossWarData:getRank()
	local notInRank 	= rank <= 0
	local isTop3		= rank > 0 and rank <= 3

	-- show or hide rank UI
	myRankImage_1:setVisible(isTop3)
	myRankLabel_1:setVisible(not notInRank and not isTop3)
	meNotInRank_1:setVisible(notInRank)
	myRankImage_2:setVisible(isTop3)
	myRankLabel_2:setVisible(not notInRank and not isTop3)
	meNotInRank_2:setVisible(notInRank)
	titleButton:setVisible(not notInRank)
	titleText:setVisible(not notInRank)
	award:setVisible(not notInRank)


	-- if not in rank, return
	if notInRank then
		return
	end

	-- top3, set the rank texture
	if isTop3 then
		myRankImage_1:loadTexture("ui/text/txt/phb_" .. rank .. "st.png")
		myRankImage_2:loadTexture("ui/text/txt/phb_" .. rank .. "st.png")
	else
		myRankLabel_1:setText(tostring(rank))
		myRankLabel_2:setText(tostring(rank))
	end

	-- set title

	-- awards the player can get by current rank
	local awardInfo = nil
	local awardTableLen = contest_rank_award_info.getLength()
	for i = 1, awardTableLen do
		local v = contest_rank_award_info.get(i)
		if rank >= v.rank_min and rank <= v.rank_max then
			awardInfo = v
			break
		end
	end

	if awardInfo then
		self._itemInfo = item_info.get(awardInfo.award_value1)
		self._titleID = awardInfo.title_id

		-- update title
		local titleInfo = title_info.get(awardInfo.title_id)
		titleText:setText(titleInfo.name)
		titleText:setColor(Colors.qualityColors[titleInfo.quality])
		titleButton:loadTextureNormal(titleInfo.picture)

		-- update award
		local goodsInfo = Goods.convert(awardInfo.award_type1, awardInfo.award_value1)
		self:_updateAwardInfo(goodsInfo, awardInfo.award_size1)
	end
end

-- update the awards info that the player can get
function CrossWarScoreRankLayer:_updateAwardInfo(goodsInfo, num)
	-- icon
	local icon = self:getImageViewByName("Image_CurAwardIcon")
	icon:loadTexture(goodsInfo.icon)

	-- quality frame
	local btnQualityFrame = self:getButtonByName("Button_CurQualityFrame")
	local qualityTexture = G_Path.getEquipColorImage(goodsInfo.quality, goodsInfo.type)
	btnQualityFrame:loadTextureNormal(qualityTexture, UI_TEX_TYPE_PLIST)
	btnQualityFrame:loadTexturePressed(qualityTexture, UI_TEX_TYPE_PLIST)

	-- number
	local numLabel = self:getLabelByName("Label_CurAwardNum")
	numLabel:setText("x" .. num)
end

-- match state has changed
function CrossWarScoreRankLayer:_updateMatchState()
	self:showWidgetByName("Panel_GiveAward_Tip", G_Me.crossWarData:isInScoreMatch())
end

-- update the remaining time to give the award
function CrossWarScoreRankLayer:_updateCD(strCD)
	-- set the time
	self:showTextWithLabel("Label_GiveTime", strCD)

	-- adjust the position of the labels
	local panel = self:getPanelByName("Panel_GiveAward_Tip")
	CrossWarCommon.centerContent(panel)
end

return CrossWarScoreRankLayer