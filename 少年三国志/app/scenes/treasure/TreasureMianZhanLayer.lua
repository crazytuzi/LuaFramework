local TreasureMianZhanLayer = class("TreasureMianZhanLayer",UFCCSModelLayer)
local  ItemConst = require("app.const.ItemConst")
require("app.const.ShopType")
require("app.cfg.item_info")
function TreasureMianZhanLayer.create(...)
	return TreasureMianZhanLayer.new("ui_layout/treasure_MianZhanLayer.json",Colors.modelColor,...)
end

function TreasureMianZhanLayer:ctor(...)
	self._bigNumLabel = nil   --大免战牌数量
	self._smallNumLabel = nil --小免战牌数量
	self._mianzhanBigButton = nil 
	self._mianzhanSmallButton = nil
	self.super.ctor(self,...)
	self:_initWidget()
	self:_createStroke()
	self:_initEvent()
	self:showAtCenter(true)
end

function TreasureMianZhanLayer:_initWidget()
	self._bigNumLabel = self:getLabelByName("Label_bigNum")
	self._smallNumLabel = self:getLabelByName("Label_smallNum")
	self._mianzhanBigButton = self:getButtonByName("Button_mianzhanbig")
	self._mianzhanSmallButton = self:getButtonByName("Button_mianzhansmall")

	self._smallNameLabel = self:getLabelByName("Label_small")
	self._bigNameLabel = self:getLabelByName("Label_big")

	local smallNum = G_Me.bagData:getPropCount(ItemConst.ITEM_ID.MIANZHAN_SMALL)
	local bigNum = G_Me.bagData:getPropCount(ItemConst.ITEM_ID.MIANZHAN_BIG)
	self._smallNumLabel:setText("x"..smallNum)
	self._bigNumLabel:setText("x"..bigNum)
	local itemSmall = item_info.get(ItemConst.ITEM_ID.MIANZHAN_SMALL)
	local itemBig = item_info.get(ItemConst.ITEM_ID.MIANZHAN_BIG)

	self._smallNameLabel:setColor(Colors.qualityColors[itemSmall.quality])
	self._smallNameLabel:setText(G_lang:get("LANG_MIANZHAN_ITEM_VALUE",{hour=itemSmall.item_value/3600}))
	-- self._bigNameLabel:setText(itemBig.name)
	self._bigNameLabel:setColor(Colors.qualityColors[itemBig.quality])
	self._bigNameLabel:setText(G_lang:get("LANG_MIANZHAN_ITEM_VALUE",{hour=itemBig.item_value/3600}))

	self._mianzhanBigButton:loadTextureNormal(G_Path.getItemIcon(itemBig.res_id),UI_TEX_TYPE_LOCAL)
	self._mianzhanBigButton:loadTexturePressed(G_Path.getItemIcon(itemBig.res_id),UI_TEX_TYPE_LOCAL)
	self._mianzhanSmallButton:loadTextureNormal(G_Path.getItemIcon(itemSmall.res_id),UI_TEX_TYPE_LOCAL)
	self._mianzhanSmallButton:loadTexturePressed(G_Path.getItemIcon(itemSmall.res_id),UI_TEX_TYPE_LOCAL)

	self:getImageViewByName("Image_big"):loadTexture(G_Path.getEquipColorImage(itemBig.quality,G_Goods.ITEM) )
	self:getImageViewByName("Image_small"):loadTexture(G_Path.getEquipColorImage(itemSmall.quality,G_Goods.ITEM) )
end

function TreasureMianZhanLayer:_createStroke()
	self._bigNumLabel:createStroke(Colors.strokeBrown,1)
	self._smallNumLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_tips_bottom"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_tip01"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_tip02"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_tip03"):createStroke(Colors.strokeBrown,1)

	self._smallNameLabel:createStroke(Colors.strokeBrown,1)
	self._bigNameLabel:createStroke(Colors.strokeBrown,1)
end

function TreasureMianZhanLayer:_initEvent()
	self:enableAudioEffectByName("Button_close", false)
	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		local soundConst = require("app.const.SoundConst")
	   	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
		end)
	self:registerBtnClickEvent("Button_mianzhanbig",function()
		local bigNum = G_Me.bagData:getPropCount(ItemConst.ITEM_ID.MIANZHAN_BIG)
		local itemBig = item_info.get(ItemConst.ITEM_ID.MIANZHAN_BIG)
		if bigNum == 0 then
			-- require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, ItemConst.ITEM_ID.MIANZHAN_BIG,GlobalFunc.sceneToPack("app.scenes.treasure.TreasureComposeScene", {}))
			-- self:animationToClose()
			G_GlobalFunc.showPurchasePowerDialog(4)
			return
		end
		-- G_HandlersManager.treasureRobHandler:sendForbidBattle(ItemConst.ITEM_ID.MIANZHAN_BIG)
		G_HandlersManager.bagHandler:sendUseItemInfo(ItemConst.ITEM_ID.MIANZHAN_BIG)
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_mianzhansmall",function()
		local smallNum = G_Me.bagData:getPropCount(ItemConst.ITEM_ID.MIANZHAN_SMALL)
		local itemSmall = item_info.get(ItemConst.ITEM_ID.MIANZHAN_SMALL)
		if smallNum == 0 then
			-- require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, ItemConst.ITEM_ID.MIANZHAN_SMALL,GlobalFunc.sceneToPack("app.scenes.treasure.TreasureComposeScene", {}))
			-- self:animationToClose()
			G_GlobalFunc.showPurchasePowerDialog(5)
			return
		end
		-- G_HandlersManager.treasureRobHandler:sendForbidBattle(ItemConst.ITEM_ID.MIANZHAN_SMALL)
		G_HandlersManager.bagHandler:sendUseItemInfo(ItemConst.ITEM_ID.MIANZHAN_SMALL)
		self:animationToClose()
		end)
end

function TreasureMianZhanLayer:_getShopInfo()
	if self and self._initWidget then
		self:_initWidget()
	end
end

function TreasureMianZhanLayer:_bagDataChange()
	if self and self._initWidget then
		self:_initWidget()
	end
end

function TreasureMianZhanLayer:onLayerEnter()
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, self._getShopInfo, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagDataChange, self)
	--如果没进过商城,此处进入商城
	if not G_Me.shopData:checkEnterScoreShop() then
	    G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
	end
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end
function  TreasureMianZhanLayer:onLayerExit( ... )
	uf_eventManager:removeListenerWithTarget(self)
end

return TreasureMianZhanLayer