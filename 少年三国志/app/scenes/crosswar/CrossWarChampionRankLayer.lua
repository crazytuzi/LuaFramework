local CrossWarChampionRankLayer = class("CrossWarChampionRankLayer", UFCCSModelLayer)

require("app.cfg.contest_rank_award_info")
local Goods = require("app.setting.Goods")
local RankItem = require("app.scenes.crosswar.CrossWarRankItem")
local RankAwardItem = require("app.scenes.crosswar.CrossWarRankAwardItem")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarChampionRankLayer.create(...)
	return CrossWarChampionRankLayer.new("ui_layout/crosswar_ChampionRankLayer.json", Colors.modelColor, ...)
end

function CrossWarChampionRankLayer:ctor(jsonFile, fun, ...)

	self.super.ctor(self, ...)
end

function CrossWarChampionRankLayer:onLayerLoad(...)
	-- create strokes
	self:enableLabelStroke("Label_MyRank_Text", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_CurRank_Text", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_MyRank", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_End", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Time", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_CurTitle", Colors.strokeBrown, 2)

	-- initialize tabs
	self:_initTabs()

	-- initialize list views
	self:_initRankListView()
	self:_initAwardListView()

	-- initialize my rank info
	self:_initMyRank()

	-- register button events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_CurTitle", handler(self, self._onClickTitle))
	self:registerBtnClickEvent("Button_CurQualityFrame", handler(self, self._onClickAward))
end

function CrossWarChampionRankLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listners
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)

	-- 
	self:_updateMatchState()
end

function CrossWarChampionRankLayer:onBackKeyEvent(...)
	self:_onClickClose()
	return true
end

function CrossWarChampionRankLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(2, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Rank", self:getPanelByName("Panel_Rank"), "Label_Rank")
	self._tabs:add("CheckBox_RankAward", self:getPanelByName("Panel_RankAward"), "Label_RankAward")

	-- check the "rank" tab in default
	self._tabs:checked("CheckBox_Rank")
end

function CrossWarChampionRankLayer:_initRankListView()
	if not self._rankListView then
		local panel = self:getPanelByName("Panel_ListView_Rank")
		self._rankListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._rankListView:setCreateCellHandler(function(list, index)
			return RankItem.new(CrossWarCommon.RANK_CHAMPIONSHIP)
		end)

		self._rankListView:setUpdateCellHandler(function(list, index, cell)
			local data = G_Me.crossWarData:getTopRankUser(index + 1)
			cell:update(index + 1, data)
		end)
	end

	local num = G_Me.crossWarData:getTopRankNum()
	self._rankListView:reloadWithLength(num)
end

function CrossWarChampionRankLayer:_initAwardListView()
	if not self._awardListView then
		local panel = self:getPanelByName("Panel_ListView_RankAward")
		self._awardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._awardListView:setCreateCellHandler(function(list, index)
			return RankAwardItem.new(CrossWarCommon.MODE_CHAMPIONSHIP)
		end)

		self._awardListView:setUpdateCellHandler(function(list, index, cell)
			cell:update(index + 1)
		end)
	end

	local num = 0
	for i = 1, contest_rank_award_info.getLength() do
		if contest_rank_award_info.get(i).type == CrossWarCommon.MODE_CHAMPIONSHIP then
			num = num + 1
		end
	end
	self._awardListView:reloadWithLength(num)
end

function CrossWarChampionRankLayer:_initMyRank()
	local myRank = G_Me.crossWarData:getRankInChampionship()

	-- 排行榜下的我的排名
	local strRank = myRank == 0 and G_lang:get("LANG_WHEEL_NORANK") or tostring(myRank)
	self:showTextWithLabel("Label_MyRank", strRank)

	-- 排行奖励下的我的排名
	strRank = myRank == 0 and G_lang:get("LANG_WHEEL_NORANK") or G_lang:get("LANG_ARENA_RANKING", {rank = myRank})
	self:showTextWithLabel("Label_CurRank", strRank)

	-- 当前排名是否有奖励
	local awardInfo = nil
	for i = 1, contest_rank_award_info.getLength() do
		local v = contest_rank_award_info.get(i)
		if v.type == CrossWarCommon.MODE_CHAMPIONSHIP then
			if myRank >= v.rank_min and myRank <= v.rank_max then

				awardInfo = v
				break
			end
		end
	end

	-- 有奖励则显示称号和奖励
	self:showWidgetByName("Button_CurTitle", awardInfo ~= nil)
	self:showWidgetByName("Label_CurTitle", awardInfo ~= nil)
	self:showWidgetByName("Image_CurAward", awardInfo ~= nil)
	if awardInfo then
		self._itemInfo = item_info.get(awardInfo.award_value1)
		self._titleID  = awardInfo.title_id

		-- 称号
		local titleLabel = self:getLabelByName("Label_CurTitle")

		if tostring(self._titleID) == '0' then
			titleLabel:setVisible(false)
		else
			titleLabel:setVisible(true)
			local titleInfo = title_info.get(awardInfo.title_id)
			titleLabel:setText(titleInfo.name)
			titleLabel:setColor(Colors.qualityColors[titleInfo.quality])

			self:getButtonByName("Button_CurTitle"):loadTextureNormal(titleInfo.picture)
		end
		

		-- 奖励
		local goodsInfo = Goods.convert(awardInfo.award_type1, awardInfo.award_value1)
		self:_initAwardInfo(goodsInfo, awardInfo.award_size1)
	end
end

function CrossWarChampionRankLayer:_initAwardInfo(goodsInfo, num)
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

function CrossWarChampionRankLayer:_onTabChecked(btnName)
	
end

function CrossWarChampionRankLayer:_onTabUnchecked()
	
end

function CrossWarChampionRankLayer:_onClickTitle()
	local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(self._titleID)
	uf_sceneManager:getCurScene():addChild(dialog)
end

function CrossWarChampionRankLayer:_onClickAward()
	local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(self._itemInfo)
    uf_sceneManager:getCurScene():addChild(layer)
end

function CrossWarChampionRankLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function CrossWarChampionRankLayer:_updateMatchState()
	local isInChampionship = G_Me.crossWarData:isInChampionship()

	-- 如果争霸赛已结束，则不再监听倒计时，并隐藏时间label
	if not isInChampionship then
		self:showWidgetByName("Label_Time", false)
		uf_eventManager:removeListenerWithEvent(self, CrossWarCommon.EVENT_UPDATE_COUNTDOWN)

		-- 提示争霸赛已结束
		local endTip = self:getLabelByName("Label_End")
		endTip:setText(G_lang:get("LANG_CROSS_WAR_CHAMPIONSHIP_IS_OVER"))
		endTip:setColor(Colors.darkColors.TIPS_01)
		CrossWarCommon.centerContent(self:getPanelByName("Panel_CD"))
	end
end

function CrossWarChampionRankLayer:_updateCD(strCD)
	self:showTextWithLabel("Label_Time", strCD)
	CrossWarCommon.centerContent(self:getPanelByName("Panel_CD"))
end

return CrossWarChampionRankLayer