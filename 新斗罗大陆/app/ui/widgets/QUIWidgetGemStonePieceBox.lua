--
-- Author: xurui
-- Date: 2016-07-22 17:23:58
--
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemStonePieceBox = class("QUIWidgetGemStonePieceBox", QUIWidgetItemsBox)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetGemStonePieceBox:ctor(options)
	QUIWidgetGemStonePieceBox.super.ctor(self, options)
end

function QUIWidgetGemStonePieceBox:setInfo(param)
	if param then
		self:setGoodsInfo(param.pieceInfo.id, ITEM_TYPE.GEMSTONE_PIECE, param.count)
		self:setIndex(param.index)

		self:showGrayState(param.graryState)
		self:showRedTips(param.redTips)
		if self._selectPosition ~= nil and self._selectPosition ~= 0 then
			self:selected(self._selectPosition == param.index)
		end
		if param.addLine ~= nil then
			self:setBackPackLine(param.addLine)
		end
	end
end 

function QUIWidgetGemStonePieceBox:setGoodsInfo(itemID, itemType, goodsNum, froceShow, isShowNeedNum)
	self._itemID = itemID
	self._itemType = remote.items:getItemType(itemType)
	self:resetAll()
	self._name = ""
	if self._itemType == ITEM_TYPE.GEMSTONE_PIECE then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
		if itemInfo == nil then return end
		self._name = itemInfo.name

		local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemInfo.gemstone_quality)
		self:setColor(sabcInfo.color, QUIWidgetItemsBox.SCRAP)
		self:showSabc(sabcInfo.lower)
		self:_setItemIconAndCount(self._itemID, itemInfo.icon, goodsNum, froceShow, isShowNeedNum)
	end
end

function QUIWidgetGemStonePieceBox:_setItemIconAndCount(itemId, respath, goodsNum, froceShow, isShowNeedNum)
	if goodsNum == nil then goodsNum = 0 end
  	if respath ~= nil then
  		self:setItemIcon(respath)
  	end
  	if froceShow == nil then froceShow = true end
  	if isShowNeedNum == nil then isShowNeedNum = true end

  	local stoneInfo = remote.gemstone:getStoneCraftInfoByPieceId(itemId) or {}
  	local needNum = stoneInfo.component_num_1 or 0

  	local wordContent = isShowNeedNum and goodsNum.."/"..needNum or goodsNum
	self:setTFText(self._ccbOwner.tf_goods_num, wordContent)
	-- Scale the number if its size exceeds the box size @qinyuanji
	local numSize = self._ccbOwner.tf_goods_num:getContentSize()
	local boxSize = self._ccbOwner.node_scrap_normal:getContentSize()
	local scale = (boxSize.width - 20)/numSize.width
	if scale < 1 then
		self._ccbOwner.tf_goods_num:setScale(scale)
	end

	self._ccbOwner.node_gray_state:setVisible(false)
	if froceShow == false then
		self._ccbOwner.tf_goods_num:setVisible(false)
	end 
end

function QUIWidgetGemStonePieceBox:showGrayState(state)
	if state == nil then state = false end
	self._ccbOwner.node_gray_state:setVisible(state)
end

function QUIWidgetGemStonePieceBox:showRedTips(state)
	self._ccbOwner.red_tip:setVisible(state)
end 

function QUIWidgetGemStonePieceBox:setScaleNum(scale)
	self:getCCBView():setScale(scale)
end

-- 设置奖励界面的名字
function QUIWidgetGemStonePieceBox:showItemName()
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemID)
	local name = itemInfo.name or ""
	self._ccbOwner.tf_goods_name:setScale(1)
	local nameCount = #name
	local i = 1
	local pos = 0
	local halfPos = 0
	local sixPos = 0
	local specialPos = 0
	local specialStr = "("
    while true do 
        local c = string.sub(name,i,i)
        local b = string.byte(c)
        if b > 128 then
        	if specialStr == string.sub(name,i,i+3) then
        		specialPos = i-1
        	end
            i = i + 3
        	pos = pos + 1
        else
        	if specialStr == c then
        		specialPos = i-1
        	end
            i = i + 1
        	pos = pos + 0.5
        end
        if pos >= 5 and sixPos == 0 then
        	sixPos = i-1
        end
        if i >= nameCount/2 and halfPos == 0 then
        	halfPos = i-1
        end
        if i > nameCount then
        	break
        end
    end
    local autoWarpPos = nil
    if pos > 5 then
    	if pos > 10 then
			autoWarpPos = halfPos
		else
			autoWarpPos = sixPos
		end
	end
    if specialPos ~= 0 and specialPos < autoWarpPos then
    	autoWarpPos = specialPos
	end
	self._ccbOwner.tf_goods_name:setHorizontalAlignment(kCCTextAlignmentLeft)
	if autoWarpPos ~= nil then
		name = string.sub(name, 1, autoWarpPos).."\n"..string.sub(name, autoWarpPos+1)
		if autoWarpPos < nameCount/2 then
			self._ccbOwner.tf_goods_name:setHorizontalAlignment(kCCTextAlignmentCenter)
		end
	end
	self:setTFText(self._ccbOwner.tf_goods_name, name)
	local widthNum = self._ccbOwner.tf_goods_name:getContentSize().width
	if widthNum > self._nameWidth then
		self._ccbOwner.tf_goods_name:setScale(self._nameWidth/widthNum)
	end
	self._ccbOwner.tf_goods_name:setColor(BREAKTHROUGH_COLOR_LIGHT[remote.gemstone:getSABC(itemInfo.gemstone_quality).color])
end

-- 添加背包中的线
function QUIWidgetGemStonePieceBox:setBackPackLine(state)
	if state == false and self._line ~= nil then
		self._line:removeFromParent()
		self._line = nil
	elseif state and self._line == nil then
	    self._line = CCBuilderReaderLoad("ccb/Widget_Baoshi_Packsack_xian.ccbi", CCBProxy:create(), {})
	    local contentSize = self:getContentSize()
	    self._line:setPosition(ccp(contentSize.width*2 - 10, -contentSize.height+23))
		self:getView():addChild(self._line)
	end
end

return QUIWidgetGemStonePieceBox