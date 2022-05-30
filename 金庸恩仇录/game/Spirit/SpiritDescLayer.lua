local data_juyuan_juyuan = require("data.data_juyuan_juyuan")
local data_item_item = require("data.data_item_item")
require("utility.richtext.richText")

local SpiritDescLayer = class("SpiritDescLayer", function ()
	return require("utility.ShadeLayer").new()
end)

local Item = class("Item", function ()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(163, 62)
end

function Item:ctor()
end

function Item:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _idx = param.idx
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_type_btn.ccbi", proxy, self._rootnode)
	node:setPosition(node:getContentSize().width / 2, _viewSize.height / 2)
	self:addChild(node)
	self:refresh(param)
	return self
end

function Item:refresh(param)
	local _itemData = param.itemData
	local _bSelect = param.selected
	self._rootnode.tag_name:setDisplayFrame(display.newSpriteFrame(param.nameSprite))
	if _bSelect then
		self._rootnode.highlightBoard:setVisible(true)
	else
		self._rootnode.highlightBoard:setVisible(false)
	end
end

function Item:selected()
	self._rootnode.highlightBoard:setVisible(true)
end

function SpiritDescLayer:ctor(closeListener)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_info.ccbi", proxy, rootnode)
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addChild(node, 100)
	
	rootnode.closeBtn:addHandleOfControlEvent(function ()
		if closeListener then
			closeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.titleLabel:setString(common:getLanguageString("@zhenqijs"))
	self.iconImageSprites = {
	"spirit_p_1.png",
	"spirit_p_2.png",
	"spirit_p_3.png",
	"spirit_p_4.png",
	"spirit_p_5.png"
	}
	local _data = {}
	local selectId = 1
	local refreshInfo
	
	local function onTouch(cell)
		local nameArr = {
		"spirit_desc_nsjq.png",
		"spirit_desc_dyjf.png",
		"spirit_desc_jzrx.png",
		"spirit_desc_shjd.png",
		"spirit_desc_wqcy.png"
		}
		local function refreshItem()
			self._scrollItemList:reloadCell(selectId - 1, {
			itemData = _data[selectId],
			selected = false,
			nameSprite = nameArr[selectId]
			})
			selectId = cell:getIdx() + 1
			cell:selected()
			rootnode.iconImageSprite:setDisplayFrame(display.newSpriteFrame("spirit_p_" .. selectId .. ".png"))
		end
		refreshItem()
		refreshInfo()
	end
	
	local function initSpiritTypeView()
		local nameArr = {
		"spirit_desc_nsjq.png",
		"spirit_desc_dyjf.png",
		"spirit_desc_jzrx.png",
		"spirit_desc_shjd.png",
		"spirit_desc_wqcy.png"
		}
		local _listBtnViewSize = rootnode.listBtnView:getContentSize()
		for k, v in ipairs(data_juyuan_juyuan) do
			table.insert(_data, v)
		end
		self.desctext = getRichText(_data[selectId].explain, 480, nil, 10)
		self.desctext:align(display.CENTER, 0, 0)
		rootnode.spiritDescLabel:addChild(self.desctext)
		local function createFunc(idx)
			local item = Item.new()
			idx = idx + 1
			local selected = false
			if idx == selectId then
				selected = true
			end
			return item:create({
			viewSize = _listBtnViewSize,
			itemData = _data[idx],
			idx = idx,
			nameSprite = nameArr[idx],
			selected = selected
			})
		end
		local function refreshFunc(cell, idx)
			idx = idx + 1
			local selected = false
			if idx == selectId then
				selected = true
			end
			cell:refresh({
			idx = idx,
			itemData = _data[idx],
			selected = selected,
			nameSprite = nameArr[idx]
			})
		end
		local function createScrollView()
			self._scrollItemList = require("utility.TableViewExt").new({
			size = cc.size(_listBtnViewSize.width, _listBtnViewSize.height),
			createFunc = createFunc,
			refreshFunc = refreshFunc,
			cellNum = #_data,
			cellSize = Item.new():getContentSize(),
			touchFunc = onTouch
			})
			self._scrollItemList:setPosition(0, 0)
			rootnode.listBtnView:addChild(self._scrollItemList)
		end
		createScrollView()
	end
	
	local function sort(l, r)
		return data_item_item[l].quality > data_item_item[r].quality
	end
	
	local function getSelectedTypeSpirit()
		local _spiritData = {}
		for _, v in ipairs(_data[selectId].arr_quality) do
			for k, vv in pairs(data_item_item) do
				if vv.type == 6 and vv.quality == v then
					table.insert(_spiritData, k)
				end
			end
		end
		table.sort(_spiritData, sort)
		return _spiritData
	end
	
	local function refreshSpiritList()
		self._tableLayout = require("utility.TableLayout").new({
		width = rootnode.spiritListView:getContentSize().width,
		height = rootnode.spiritListView:getContentSize().height,
		rowNum = 3
		})
		for k, v in ipairs(self._selectTypeSpirits) do
			self._tableLayout:addChildEx(require("game.Spirit.SpiritIcon").new({
			id = 0,
			resId = v,
			lv = 0,
			exp = 0,
			bShowName = true,
			bShowNameBg = true
			}))
		end
		self._scrollView:setContainer(self._tableLayout)
		self._scrollView:updateInset()
		self._scrollView:setContentOffset(cc.p(0, -self._tableLayout:getContentSize().height + rootnode.spiritListView:getContentSize().height), false)
		local maxOffsetY = self._scrollView:maxContainerOffset().y
		local minOffsetY = self._scrollView:minContainerOffset().y
		if maxOffsetY ~= minOffsetY then
			rootnode.upArrow:setVisible(false)
			rootnode.downArrow:setVisible(true)
		else
			rootnode.upArrow:setVisible(false)
			rootnode.downArrow:setVisible(false)
		end
	end
	
	local function initSpiritListView()
		self._scrollView = CCScrollView:create()
		self._scrollView:setViewSize(cc.size(rootnode.spiritListView:getContentSize().width, rootnode.spiritListView:getContentSize().height))
		self._scrollView:setPosition(cc.p(0, 0))
		self._scrollView:setDirection(kCCScrollViewDirectionVertical)
		self._scrollView:setClippingToBounds(true)
		self._scrollView:setBounceable(true)
		self._selectTypeSpirits = getSelectedTypeSpirit()
		refreshSpiritList()
		rootnode.spiritListView:addChild(self._scrollView)
		self.selectedSpiritNameLabel = ui.newTTFLabelWithOutline({
		text = _data[1].name,
		font = FONTS_NAME.font_haibao,
		size = 24,
		color = display.COLOR_WHITE,
		outlineColor = FONT_COLOR.BLACK,
		x = rootnode.selectedSpiritNameBg:getContentSize().width / 2,
		y = rootnode.selectedSpiritNameBg:getContentSize().height / 2,
		align = ui.TEXT_ALIGN_CENTER
		})
		rootnode.selectedSpiritNameBg:addChild(self.selectedSpiritNameLabel)
		
		local bTouch
		local function onTouchMove(event)
			if math.abs(event.y - event.prevY) > 5 or 5 < math.abs(event.x - event.prevX) then
				bTouch = false
			end
		end
		
		local function onTouchEnded(event)
			if bTouch then
				local nodes = self._tableLayout:getNodes()
				for k, v in ipairs(nodes) do
					local pos = v:convertToNodeSpace(cc.p(event.x, event.y))
					if cc.rectContainsPoint(cc.rect(0, 0, v:getContentSize().width, v:getContentSize().height), pos) then
						dump(self._selectTypeSpirits[k])
						local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
						resId = self._selectTypeSpirits[k]
						})
						game.runningScene:addChild(descLayer, 5)
					end
				end
			end
			self:performWithDelay(function ()
				local posY = self._scrollView:getContentOffset().y
				local maxOffsetY = self._scrollView:maxContainerOffset().y
				local minOffsetY = self._scrollView:minContainerOffset().y
				if maxOffsetY ~= minOffsetY then
					if posY >= maxOffsetY then
						rootnode.upArrow:setVisible(true)
						rootnode.downArrow:setVisible(false)
					elseif posY <= minOffsetY then
						rootnode.upArrow:setVisible(false)
						rootnode.downArrow:setVisible(true)
					else
						rootnode.upArrow:setVisible(true)
						rootnode.downArrow:setVisible(true)
					end
				end
			end,
			0.5)
		end
		
		local touchLayer = require("utility.MyLayer").new({
		name = "",
		size = self._scrollView:getContentSize(),
		swallow = false,
		parent = self._scrollView:getParent(),
		touchHandler = function (event)
			if event.name == "began" then
				bTouch = true
				return true
			elseif event.name == "moved" then
				onTouchMove(event)
			elseif event.name == "ended" then
				onTouchEnded(event)
			end
		end
		})
		self._scrollView:setPosition(self._scrollView:getPosition())
	end
	
	function refreshInfo()
		self.selectedSpiritNameLabel:setString(_data[selectId].name)
		self.selectedSpiritNameLabel:setColor(NAME_COLOR[selectId])
		if self.desctext ~= nil then
			self.desctext:removeSelf()
		end
		self.desctext = getRichText(_data[selectId].explain, 480)
		self.desctext:align(display.CENTER, 0, 0)
		rootnode.spiritDescLabel:addChild(self.desctext)
		self._selectTypeSpirits = getSelectedTypeSpirit()
		refreshSpiritList()
	end
	
	initSpiritTypeView()
	initSpiritListView()
end

return SpiritDescLayer