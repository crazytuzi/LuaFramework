-- GroupBuyRankLayer.lua

require("app.scenes.groupbuy.GroupBuyCommon")
local GroupBuyCount = require("app.const.GroupBuyConst")
local GroupBuyRankAwardCell = require("app.scenes.groupbuy.GroupBuyRankAwardCell")

local string = string

local GroupBuyRankLayer = class("GroupBuyRankLayer", UFCCSModelLayer)

function GroupBuyRankLayer.show(...)
	local layer = GroupBuyRankLayer.new("ui_layout/groupbuy_RankLayer.json", Colors.modelColor, ...)
	if layer then 
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

function GroupBuyRankLayer:ctor( ... )
    self._awardList     = self:getPanelByName("Panel_Award_List")
    self._tipLabel      = self:getLabelByName("Label_tip")
    self._myRankLabel   = self:getLabelByName("Label_myLeveljy")
    self._myRankBMLabel = self:getLabelBMFontByName("BitmapLabel_rankjy")
    self._unInRankImage = self:getImageViewByName("Image_rankjy")
    self._awardLabel    = self:getLabelByName("Label_awardjy")
    self._awardPanel    = self:getPanelByName("Panel_myjyRankAward")
    self._unInDescLabel = self:getLabelByName("Label_norankjy")

    self._tabType    = GroupBuyCount.RANK_AWARD_TYPE.NORMAL
    self._awardCells = {}
    self._data       = G_Me.groupBuyData

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCancelClick))

    self._tipLabel:setText(G_lang:get("LANG_GROUP_BUY_RANK_TIP"))

    self._myRankLabel:setText(G_lang:get("LANG_GROUP_BUY_RANK_SELF_RANK"))
    self._myRankLabel:createStroke(Colors.strokeBrown, 1)
    self._myRankBMLabel:setText("")
    self._unInRankImage:setVisible(false)
    self._awardLabel:setVisible(false)
    self._awardPanel:setVisible(false)
    self._unInDescLabel:setVisible(false)

	self:_initScrollView()
	self:_initAwardList()

	self.super.ctor(self, ...)
end

function GroupBuyRankLayer:onLayerLoad()
	self:addCheckBoxGroupItem(1, "CheckBox_Normal")
    self:addCheckBoxGroupItem(1, "CheckBox_Luxury")
    self:addCheckBoxGroupItem(1, "CheckBox_Award")

    self:enableLabelStroke("Label_Normal_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_Luxury_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_Award_check", Colors.strokeBrown, 2 )

    self:addCheckNodeWithStatus("CheckBox_Normal", "Label_Normal_check", true)
    self:addCheckNodeWithStatus("CheckBox_Normal", "Label_Normal_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_Luxury", "Label_Luxury_check", true)
    self:addCheckNodeWithStatus("CheckBox_Luxury", "Label_Luxury_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_Award", "Label_Award_check", true)
    self:addCheckNodeWithStatus("CheckBox_Award", "Label_Award_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_Award", "Image_Self_Info", false)
    self:addCheckNodeWithStatus("CheckBox_Award", "Panel_Award_List", true)
    self:addCheckNodeWithStatus("CheckBox_Award", "Panel_Rank_List", false)
    self:addCheckNodeWithStatus("CheckBox_Award", "Image_Normal", false)

    self:registerCheckboxEvent("CheckBox_Normal", handler(self, self._onNormalCheck))
    self:registerCheckboxEvent("CheckBox_Luxury", handler(self, self._onLuxuryCheck))
    self:registerCheckboxEvent("CheckBox_Award", handler(self, self._onAwardCheck))

    self:setCheckStatus(1, "CheckBox_Normal")
end

function GroupBuyRankLayer:_initAwardList()
	self._awardCells = {}
    local types = {GroupBuyCount.RANK_AWARD_TYPE.LUXURY, GroupBuyCount.RANK_AWARD_TYPE.NORMAL}
	for i = 1, #types do
		local cell = GroupBuyRankAwardCell.create(types[i])
		cell:setPosition(ccp(0, (i - 1) * 280))
		self._awardCells[i] = cell
		self._awardList:addNode(cell)
	end
end

function GroupBuyRankLayer:_initScrollView()
	self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Rank_List"), LISTVIEW_DIR_VERTICAL)
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.groupbuy.GroupBuyRankCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local list = self:_getRankList() or {}
        if  index < #list then
           cell:updateData(list, index, list[index + 1], self._tabType) 
        end
    end)
    self._listView:initChildWithDataLength(0)
end

function GroupBuyRankLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_BG"), "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_RANK_UPDATE, self._onUpdate, self)

    getHandler():sendGetGroupBuyRanking(GroupBuyCount.RANK_AWARD_TYPE.NORMAL, 10)
    -- getHandler():sendGetGroupBuyRanking(GroupBuyCount.RANK_AWARD_TYPE.NORMAL, 20)
    -- getHandler():sendGetGroupBuyRanking(GroupBuyCount.RANK_AWARD_TYPE.LUXURY, 10)
    -- getHandler():sendGetGroupBuyRanking(GroupBuyCount.RANK_AWARD_TYPE.LUXURY, 20)
end

function GroupBuyRankLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

function GroupBuyRankLayer:_onCancelClick()
	self:animationToClose()
end

function GroupBuyRankLayer:_onNormalCheck()
    self._tabType = GroupBuyCount.RANK_AWARD_TYPE.NORMAL
    self:_onUpdate()
end

function GroupBuyRankLayer:_onLuxuryCheck()
    self._tabType = GroupBuyCount.RANK_AWARD_TYPE.LUXURY
    self:_onUpdate()
end

function GroupBuyRankLayer:_onAwardCheck()
    self._tabType = GroupBuyCount.RANK_AWARD_TYPE.AWARD
end

function GroupBuyRankLayer:_onUpdate()
    if self._tabType == GroupBuyCount.RANK_AWARD_TYPE.NORMAL or self._tabType == GroupBuyCount.RANK_AWARD_TYPE.LUXURY then
        local length = #self:_getRankList()
        self._listView:reloadWithLength(length, 0, 0.2)
        self._tipLabel:setVisible(length > 0)
        self:_updateSelfInfo()
    end
end

function GroupBuyRankLayer:_updateSelfInfo()
    local rankInfo = self:_getSelfRankInfo() or {}
    if rankInfo.self_rank_id and rankInfo.self_rank_id <= GroupBuyCount.RANK_MAX_NUM then
        self._myRankBMLabel:setText(rankInfo.self_rank_id)
        self._myRankBMLabel:setVisible(true)
        self._awardLabel:setVisible(true)
        
        local info = getAward(rankInfo.self_rank_id, self._tabType)
        if info then
            self._awardPanel:setVisible(true)
            for i = 1, 3 do
                local label = self:getLabelByName(string.format("Label_jyAward%d", i))
                if info[string.format("type_%d", i)] > 0 then
                    local g = G_Goods.convert(info[string.format("type_%d", i)], info[string.format("value_%d", i)])
                    label:setText(g.name.."  x"..GlobalFunc.ConvertNumToCharacter2(info[string.format("size_%d", i)]))
                    label:setVisible(true)
                else
                    label:setVisible(false)
                end
            end
        end
        self._unInDescLabel:setVisible(false)
    else
        self._myRankBMLabel:setVisible(false)
        self._awardLabel:setVisible(false)
        self._awardPanel:setVisible(false)
        self._unInDescLabel:setVisible(false)
        if rankInfo.handred_score then
            self._unInDescLabel:setVisible(true)
            self._unInDescLabel:setText(G_lang:get("LANG_GROUP_BUY_RANK_DESC", rankInfo.handred_score))
        end
    end
end

function GroupBuyRankLayer:_getRankList()
    if self._tabType == GroupBuyCount.RANK_AWARD_TYPE.NORMAL then
        return self._data:getNormalRankList()
    elseif self._tabType == GroupBuyCount.RANK_AWARD_TYPE.LUXURY then
        return self._data:getLuxuryRankList()
    end
end

function GroupBuyRankLayer:_getSelfRankInfo()
    if self._tabType == GroupBuyCount.RANK_AWARD_TYPE.NORMAL then
        return self._data:getSelfNormalRankInfo()
    elseif self._tabType == GroupBuyCount.RANK_AWARD_TYPE.LUXURY then
        return self._data:getSelfLuxuryRankInfo()
    end
end

return GroupBuyRankLayer