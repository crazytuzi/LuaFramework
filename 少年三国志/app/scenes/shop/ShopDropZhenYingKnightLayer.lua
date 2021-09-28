local ShopDropKnightBaseLayer = require("app.scenes.shop.ShopDropKnightBaseLayer")
local BagConst = require("app.const.BagConst")
local ShopDropZhenYingKnightLayer = class("ShopDropZhenYingKnightLayer",function()
    return ShopDropKnightBaseLayer:create02()
end)

require("app.cfg.camp_drop_info")

function ShopDropZhenYingKnightLayer:ctor(group)
	self._group = group or 1
    self.super.ctor(self)
    self:_initWidget()
    self:_createStroke()
    self:_initEvent()
    self:_createRichText()
    --[[
		展示类型4,5,6,7表示魏蜀吴群,group 1,2,3,4表示魏蜀吴群
    ]]
    self:setAutoScrollView(group+3)
end

function ShopDropZhenYingKnightLayer:_initWidget()
	self:attachImageTextForBtn("Button_onetime","ImageView_3884")
	self:getImageViewByName("ImageView_title"):loadTexture(G_Path.getZhenYingDropTitleImage(self._group))
	self:getLabelByName("Label_gold"):setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.gold))
	local curTimes = G_Me.shopData.dropKnightInfo.zy_recruited_times
	if curTimes == 15 then
		self:showWidgetByName("Label_finish",true)  --今日阵营抽将已结束
		self:showWidgetByName("Panel_gailv",false)
		self:showWidgetByName("Panel_bichucheng",false)
		self:showWidgetByName("Panel_normal_status",false)
		self:showWidgetByName("Panel_15ci",true)
		self:getLabelByName("Label_finish"):setText(G_lang:get("LANG_ZHEN_YING_CHOU_JIANG_FINISH"))
		--已招募15次
		self:getLabelByName("Label_yizhaomu15ci"):setText(G_lang:get("LANG_ZHEN_YING_YI_ZHAO_JIANG",{times=15}))
		self:getButtonByName("Button_onetime"):setTouchEnabled(false)
	else
		if curTimes == 14 then
			--本次必出橙
			self:showWidgetByName("Label_finish",false)  --今日阵营抽将已结束
			self:showWidgetByName("Panel_gailv",false)
			self:showWidgetByName("Panel_bichucheng",true)
		else
			self:showWidgetByName("Label_finish",false)  --今日阵营抽将已结束
			self:showWidgetByName("Panel_gailv",true)
			self:showWidgetByName("Panel_bichucheng",false)
		end
		self:showWidgetByName("Panel_normal_status",true)
		self:showWidgetByName("Panel_15ci",false)
		self:getLabelByName("Label_yizhaomucishu"):setText(G_lang:get("LANG_ZHEN_YING_YI_ZHAO_JIANG",{times=curTimes}))
		self:getButtonByName("Button_onetime"):setTouchEnabled(true)
		
		local price,probability = G_Me.shopData:getZhenYingDropPrice()
		if price ~= -1 then
			self:getLabelByName("Label_gailv"):setText("x" .. probability)
			self:getLabelByName("Label_price"):setText(tostring(price))
		else
			self:getLabelByName("Label_gailv"):setText("x0")
			self:getLabelByName("Label_price"):setText("0")
		end
	end
end

function ShopDropZhenYingKnightLayer:_createStroke()
	self:getLabelByName("Label_gold"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_tishi01"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_2_0"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_gailv"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_6_0"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_yizhaomucishu"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_price"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_yizhaomu15ci"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_finish"):createStroke(Colors.strokeBrown,1)

	self:getLabelByName("Label_2_0"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_chengjiang"):createStroke(Colors.strokeBrown,1)
	
end

function ShopDropZhenYingKnightLayer:_initEvent()
	self:registerBtnClickEvent("Button_onetime",function()
		require("app.scenes.shop.ShopTools").sendZhenYingKnightDrop()
		self:animationToClose()
		end)
end

--可招募xxxx提示文字
function ShopDropZhenYingKnightLayer:_createRichText()
	local tipsLabel = self:getLabelByName("Label_kezhaomu")
	local panel = self:getPanelByName("Panel_kezhaomu")
	tipsLabel:setVisible(false)
	local size = tipsLabel:getContentSize()
	print("---size.width = " .. size.width)
	self._richText = CCSRichText:create(size.width+50, size.height+30)
	self._richText:setFontSize(tipsLabel:getFontSize())
	self._richText:setFontName(tipsLabel:getFontName())
	local x,y = tipsLabel:getPosition()
	local groupString = ""

	if self._group == 1 then
		groupString = G_lang:get("LANG_STORYDUNGEON_WEI")
	elseif self._group == 2 then
		groupString = G_lang:get("LANG_STORYDUNGEON_SHU")
	elseif self._group == 3 then
		groupString = G_lang:get("LANG_STORYDUNGEON_WU")
	else
		groupString = G_lang:get("LANG_STORYDUNGEON_QUN")
	end

	local text = G_lang:get("LANG_ZHEN_YING_KE_ZHAO_MU",{group=groupString})
    self._richText:setPosition(ccp(panel:getContentSize().width/2,panel:getContentSize().height/2))
	self._richText:appendXmlContent(text)
	self._richText:enableStroke(Colors.strokeBrown)
	self._richText:reloadData()
	panel:addChild(self._richText)
end


return ShopDropZhenYingKnightLayer

