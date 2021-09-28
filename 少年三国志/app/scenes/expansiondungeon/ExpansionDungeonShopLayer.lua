local ExpansionDungeonConst = require("app.const.ExpansionDungeonConst")
local ExpansionDungeonShopLayer = class("ExpansionDungeonShopLayer", UFCCSModelLayer)

function ExpansionDungeonShopLayer.create(nChapterId, fnCloseWindow, ...)
	return ExpansionDungeonShopLayer.new("ui_layout/expansiondungeon_ShopLayer.json", Colors.modelColor, nChapterId, fnCloseWindow, ...)
end

function ExpansionDungeonShopLayer:ctor(json, param, nChapterId, fnCloseWindow, ...)
	self._nChapterId = nChapterId or 1
	self._tChapterTmpl = expansion_dungeon_chapter_info.get(self._nChapterId)
	assert(self._tChapterTmpl)

	self._fnCloseWindow = fnCloseWindow

	self._tListView = nil
	self._tItemTmplList = nil
	
	self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonShopLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
end

function ExpansionDungeonShopLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self:_prepareData()
	self:_initListView()

	-- 购买成功事件监听
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EX_DUNGEON_BUY_ITEM_SUCC, self._onReloadListView, self)
	

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_bg"), "smoving_bounce")
end

function ExpansionDungeonShopLayer:onLayerExit()
	
end

function ExpansionDungeonShopLayer:onLayerUnload()
	
end

function ExpansionDungeonShopLayer:_initView()
	
end

function ExpansionDungeonShopLayer:_initWidgets()
	self:registerBtnClickEvent("Button_close", handler(self, self._onCloseWindow))
	self:registerBtnClickEvent("Button_close02", handler(self, self._onCloseWindow))
end

function ExpansionDungeonShopLayer:_onCloseWindow()
	if self._fnCloseWindow then
		self._fnCloseWindow()
	end
	self:animationToClose()
end

function ExpansionDungeonShopLayer:_prepareData()
	if not self._tItemTmplList then
		self._tItemTmplList = {}
		for i=1, expansion_dungeon_shop_info.getLength() do
			local tItemTmpl = expansion_dungeon_shop_info.indexOf(i)
			if tItemTmpl and tItemTmpl.chapter_id == self._tChapterTmpl.id then
				table.insert(self._tItemTmplList, #self._tItemTmplList + 1, tItemTmpl)
			end
		end
	end
	self:_sortData()
end

function ExpansionDungeonShopLayer:_sortData()
	local function sortFunc(tTmpl1, tTmpl2)
		local nSoldOut1 = G_Me.expansionDungeonData:isItemSoldOut(self._nChapterId, tTmpl1.id) and 0 or 1
		local nSoldOut2 = G_Me.expansionDungeonData:isItemSoldOut(self._nChapterId, tTmpl2.id) and 0 or 1
		if nSoldOut1 ~= nSoldOut2 then
			return nSoldOut1 > nSoldOut2
		end
		return tTmpl1.id < tTmpl2.id
	end

	table.sort(self._tItemTmplList, sortFunc)
end

function ExpansionDungeonShopLayer:_initListView()
	if not self._tListView then
		local panel = self:getPanelByName("Panel_awardList")
		if panel then
			self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

			self._tListView:setCreateCellHandler(function(list, index)
				return require("app.scenes.expansiondungeon.ExpansionDungeonShopItem").new(self._nChapterId, handler(self, self._onBuyItem))
			end)

			self._tListView:setUpdateCellHandler(function(list, index, cell)
				local tItemTmpl = self._tItemTmplList[index + 1]
				if tItemTmpl then
					cell:update(tItemTmpl)
				end
			end)

			self._tListView:initChildWithDataLength(#self._tItemTmplList)
		end
	end
end

function ExpansionDungeonShopLayer:_onReloadListView(tData)
	self:_sortData()
	self._tListView:refreshAllCell()
	self:_flyDropItem(tData.awards)
end

function ExpansionDungeonShopLayer:_onBuyItem(nItemId, nAlreadyBuyCount)
	local tItemTmpl = expansion_dungeon_shop_info.get(nItemId)
	if not tItemTmpl then
		return
	end

	-- 弹出购买提示框
	local nLeftBuyCount = tItemTmpl.time - nAlreadyBuyCount
	local RichShopItemSellLayer = require "app.scenes.dafuweng.RichShopItemSellLayer"
	local layer = RichShopItemSellLayer.create(
        tItemTmpl.item_type, 
        tItemTmpl.item_value,
        tItemTmpl.item_size,
        tItemTmpl.price_type, 
        tItemTmpl.discount_price, 
        math.min(nLeftBuyCount, math.floor(G_Me.userData.gold/tItemTmpl.discount_price)), 
        function(nBuyCount, layer)   
           	G_HandlersManager.expansionDungeonHandler:sendPurchaseExpansiveDungeonShopItem(nItemId, nBuyCount)     
            layer:animationToClose()         
        end)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ExpansionDungeonShopLayer:_flyDropItem(tAwards)
    local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(tAwards, function() end)
    self:addChild(tGoodsPopWindowsLayer)
end

return ExpansionDungeonShopLayer