local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(display.width, 180)
end

function Item:ctor()
end

function Item:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("chuangdang/chuangdang_hero_cell.ccbi", proxy, self._rootnode)
	node:setPosition(Item:getContentSize().width / 2, Item:getContentSize().height / 2)
	self:addChild(node)
	self._callBack = param.callBack
	self:refresh(param)
	return self
end

function Item:touchItemBy(index)
	if self._itemData[index] and not self._itemData[index].hero.isChuangDang then
		self._callBack(self._itemData[index].hero)
	end
end

function Item:refresh(param)
	local _itemData = param.itemData
	self._itemData = _itemData
	for i = 1, 5 do
		if _itemData[i] then
			self._rootnode["base_node_" .. i]:setVisible(true)
			self._rootnode["iconSprite_" .. i]:removeAllChildren()
			local heroInfo = _itemData[i].hero
			ResMgr.refreshItemWithTagNumName({
			itemBg = self._rootnode["iconSprite_" .. i],
			itemType = ITEM_TYPE.xiake,
			id = heroInfo.resId,
			cls = heroInfo.cls,
			namePosY = -15,
			itemNum = "+" .. heroInfo.cls,
			isShowIconNum = heroInfo.cls
			})
			self._rootnode["special_sign_" .. i]:setVisible(_itemData[i].isSpecial)
			self._rootnode["hero_state_lbl_" .. i]:setVisible(heroInfo.isChuangDang)
		else
			self._rootnode["base_node_" .. i]:setVisible(false)
		end
	end
end

function Item:tableCellTouched(x, y)
	for i = 1, 5 do
		if self._itemData[i] then
			local icon = self._rootnode["base_node_" .. i]
			local size = icon:getContentSize()
			if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
				self:touchItemBy(i)
				return
			end
		end
	end
end

function Item:getHeroByIdx(index)
	return self._itemData[index]
end

local ChuangDangSelectHeroLayer = class("ChuangDangSelectHeroLayer", function()
	return require("utility.ShadeLayer").new()
end)

function ChuangDangSelectHeroLayer:ctor(param)
	local viewSize = param.viewSize
	self._callBackFunc = param.callBackFunc
	self._mapInfo = param.mapInfo
	self._specialMapTbl = param.specialMapTbl
	self:setContentSize(viewSize)
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("formation/formation_hero_sub_top.ccbi", proxy, self._rootnode, self, viewSize)
	node:setPosition(0, viewSize.height)
	self:addChild(node)
	local contentHight = viewSize.height - node:getContentSize().height
	local contentWidth = viewSize.width
	local bg = display.newScale9Sprite("ui_common/common_bg.png")
	self._heroListSize = CCSizeMake(contentWidth, contentHight)
	bg:setContentSize(self._heroListSize)
	bg:setPosition(0, contentHight * 0.5)
	self:addChild(bg)
	local huawen = display.newSprite("jpg_bg/list_bg_hua.png")
	huawen:setAnchorPoint(0.5, 1)
	huawen:setPosition(0, contentHight)
	self:addChild(huawen)
	local listView = display.newNode()
	listView:setContentSize(self._heroListSize)
	listView:setPosition(-contentWidth * 0.5, 0)
	self:addChild(listView)
	self._listView = listView
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		local func = self._callBackFunc
		self:removeSelf()
		func()
	end,
	CCControlEventTouchUpInside)
	
	local curResId = self._mapInfo.selectHero and self._mapInfo.selectHero.resId or 0
	self.sortHeroList = {}
	local heroList = {}
	for key, hero in pairs(param.heroList) do
		if hero.resId ~= curResId then
			local weight = hero.level + 100 * hero.cls + 1000 * hero.star
			local special = false
			if self._specialMapTbl[hero.resId] and hero.cls >= self._specialMapTbl[hero.resId] then
				weight = weight + 10000
				special = true
			end
			if hero.isChuangDang then
				weight = weight - 100000
			end
			table.insert(heroList, {
			weight = weight,
			special = special,
			hero = hero
			})
		end
	end
	table.sort(heroList, function(a, b)
		if a.weight == b.weight then
			return a.hero.resId < b.hero.resId
		else
			return a.weight > b.weight
		end
	end)
	local t = {}
	for key, heroTbl in ipairs(heroList) do
		if key % 5 == 1 then
			table.insert(t, {})
		end
		table.insert(t[#t], {
		hero = heroTbl.hero,
		isSpecial = heroTbl.special
		})
	end
	self.sortHeroList = t
	self:heroListInit()
	
	local function update(dt)
		if self.close == true then
			self:removeFromParent(true)
		end
	end
	self:schedule(update, 0.1)
end

function ChuangDangSelectHeroLayer:heroListInit()
	local cellSize = Item.new():getContentSize()
	self._scrollItemList = require("utility.TableViewExt").new({
	size = self._heroListSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = Item.new()
		idx = idx + 1
		return item:create({
		itemData = self.sortHeroList[idx],
		idx = idx,
		callBack = function(hero)
			local func = self._callBackFunc
			--self:removeFromParent(true)
			self.close = true
			func(hero)
		end
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self.sortHeroList[idx]
		})
	end,
	cellNum = #self.sortHeroList,
	cellSize = cellSize
	})
	self._scrollItemList:setPosition(0, 0)
	self._listView:addChild(self._scrollItemList)
end

function ChuangDangSelectHeroLayer:onEnter()
end

function ChuangDangSelectHeroLayer:onExit()
end

return ChuangDangSelectHeroLayer