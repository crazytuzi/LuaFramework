local BoxType = require("app.const.BoxType")
local BoxStateConst = require("app.const.BoxStateConst")
local ExpansionDungeonBoxLayer = class("ExpansionDungeonBoxLayer", UFCCSModelLayer)

local LAYER_STATE = {
	OPEN = 1,
	CLOSE = 2,
}

function ExpansionDungeonBoxLayer.create(nChapterId, tStartPos, nBoxState, claimCallback, ...)
	return ExpansionDungeonBoxLayer.new("ui_layout/dungeon_DungeonBoxLayer.json", Colors.modelColor, nChapterId, tStartPos, nBoxState, claimCallback, ...)
end


-- @param json json文件
-- @param tColor
-- @param tStartPos 界面播放动画的开始位置
-- @param nBoxState 宝箱状态
function ExpansionDungeonBoxLayer:ctor(json, tColor, nChapterId, tStartPos, nBoxState, claimCallback, ...)
	-- 成员变量
	self._tColor = tColor
	self._nChapterId = nChapterId
	self._tStartPos = tStartPos
	self._nBoxState = nBoxState
	self._claimCallback = claimCallback
	self._tChapterTmpl = expansion_dungeon_chapter_info.get(self._nChapterId)
	assert(self._tChapterTmpl)

	self._nLayerState = LAYER_STATE.OPEN

	self.super.ctor(self, json, tColor, ...)
end

function ExpansionDungeonBoxLayer:onLayerLoad()
	self:_initWidgets()
	self:_initGoodList()
	self:_udpateWithBoxState()
end

function ExpansionDungeonBoxLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	self:_playAnimation(LAYER_STATE.OPEN)
end

function ExpansionDungeonBoxLayer:onLayerExit()
	
end

function ExpansionDungeonBoxLayer:onLayerUnload()
	
end

function ExpansionDungeonBoxLayer:onBackKeyEvent()
    self:_playAnimation(LAYER_STATE.CLOSE)
    return true
end

function ExpansionDungeonBoxLayer:_initWidgets(nChapterId, nBoxState)
--	self:showWidgetByName("ImageView_GateBox", true)

	self:registerBtnClickEvent("closebtn", function (sender)
		self:_playAnimation(LAYER_STATE.CLOSE)
	end)
	self:registerBtnClickEvent("getbounsbtn", handler(self, self._claim))

	G_GlobalFunc.updateLabel(self, "Label_Desc", {text=self._tChapterTmpl.talk})
	G_GlobalFunc.updateImageView(self, "ImageView_GateBox", {texture="ui/text/txt/zhangjiebaoxiang.png", visible=true})
end

function ExpansionDungeonBoxLayer:_initGoodList()
	for i=1, 3 do
		local imgBg = self:getImageViewByName("ImageView_bouns"..i)
		assert(imgBg)
		local nType = self._tChapterTmpl["type_"..i]
		local nValue = self._tChapterTmpl["value_"..i]
		local nSize = self._tChapterTmpl["size_"..i]
		local tGoods = G_Goods.convert(nType, nValue, nSize)
		if tGoods then
			imgBg:setVisible(true)
			self:_initGoods(i, tGoods)
		else
			imgBg:setVisible(false)
		end
	end
	self:showWidgetByName("ImageView_bouns4", false)
end

function ExpansionDungeonBoxLayer:_initGoods(nIndex, tGoods)
	local imgQualityFrame = self:getImageViewByName("bouns" .. nIndex)
	local nQuality = tGoods.quality
	local nType = tGoods.type
	local nValue = tGoods.value
	local szName = tGoods.name 
	local nItemNum = tGoods.size 
	local szIcon = tGoods.icon

	-- 物品品质框
	imgQualityFrame:loadTexture(G_Path.getEquipColorImage(nQuality, nType))
	-- 物品名称
	local labelName = tolua.cast(imgQualityFrame:getChildByName("bounsname"), "Label")
	labelName:setText(szName)
	labelName:createStroke(Colors.strokeBrown, 1)
	labelName:setColor(Colors.getColor(nQuality))
	-- 物品图片
	local imgIcon = tolua.cast(imgQualityFrame:getChildByName("ico"), "ImageView")
	imgIcon:loadTexture(szIcon)
	-- 物品数量
	local labelNum = tolua.cast(imgQualityFrame:getChildByName("bounsnum"), "Label")
	labelNum:setText("x" .. G_GlobalFunc.ConvertNumToCharacter2(nItemNum))
	labelNum:createStroke(Colors.strokeBrown, 1)
	-- 品质背景
	local imgColorBg = ImageView:create()
	imgColorBg:loadTexture(G_Path.getEquipIconBack(nQuality))
	imgQualityFrame:addChild(imgColorBg)

	self:registerWidgetClickEvent("bouns"..nIndex, function()
		if type(nType) == "number" and type(nValue) == "number" then
	    	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
		end
	end)
end

-- 领取奖励
function ExpansionDungeonBoxLayer:_claim()
	if self._claimCallback then
		self._claimCallback()
	end
    self:_playAnimation(LAYER_STATE.CLOSE)	
end

-- 创建富文本
function ExpansionDungeonBoxLayer:_createRichText()
    local label = self:getLabelByName("Label_Desc")
    local labelRichText  = CCSRichText:createSingleRow()
    labelRichText:setPosition(label:getPositionInCCPoint())
    labelRichText:setFontSize(label:getFontSize())
    labelRichText:setVerticalSpacing(10)
    labelRichText:setMaxRowCount(30)
    label:getParent():addChild(labelRichText,5)
    labelRichText:clearRichElement()
    labelRichText:setFontName(label:getFontName())
    label:setVisible(false)
    return labelRichText
end

function ExpansionDungeonBoxLayer:_appendRichText(txt,color)
    local str = "<text value='" .. txt .. "'color='" .. color .. "'/>" 
    return str
end

function ExpansionDungeonBoxLayer:_playAnimation(nLayerState)
	self._nLayerState = nLayerState
    local nDuring = 0.2
    local nStartScale = 1
    local nEndScale = 1
    local tStartPos = ccp(0, 0)
    local tEndPos = ccp(0, 0)
    local tSize = self:getContentSize()
    if nLayerState == LAYER_STATE.OPEN then
    	nStartScale = 0.2
    	nEndScale = 1
    	tStartPos = self._tStartPos
    	tEndPos = ccp(tSize.width/2, tSize.height/2)
    else
    	nStartScale = 1
    	nEndScale = 0.2
    	tStartPos = ccp(tSize.width/2, tSize.height/2)
    	tEndPos = self._tStartPos
    end
    local img = self:getImageViewByName("ImageView_762")
    img:setScale(nStartScale)
    img:setPosition(tStartPos)
    -- 动作
    local tArray = CCArray:create()
    tArray:addObject(CCMoveTo:create(nDuring, tEndPos))
    tArray:addObject(CCScaleTo:create(nDuring, nEndScale))
    local actSpawn = CCSpawn:create(tArray)
    local actCallback = CCCallFunc:create(function ()
    	if self._nLayerState == LAYER_STATE.OPEN then
    		self:setBackColor(self._tColor)
    	else
    		self:_close()
    	end
    end)
    local actSeq = transition.sequence( {actSpawn, actCallback} )
    img:runAction(actSeq)
end

function ExpansionDungeonBoxLayer:_close()
	self:close()
end

function ExpansionDungeonBoxLayer:_udpateWithBoxState( ... )
	-- 领取按钮状态
	if self._nBoxState == BoxStateConst.CLOSE then
		self:enableWidgetByName("getbounsbtn", false)
		self:attachImageTextForBtn("getbounsbtn", "ImageView_Light")
	elseif self._nBoxState == BoxStateConst.OPEN then
		self:enableWidgetByName("getbounsbtn", true)
		self:attachImageTextForBtn("getbounsbtn", "ImageView_Light")
	elseif self._nBoxState == BoxStateConst.CLAIMED then
		self:showWidgetByName("getbounsbtn", false)
		self:showWidgetByName("ImageView_AleadyGet", true)
	end
end

return ExpansionDungeonBoxLayer