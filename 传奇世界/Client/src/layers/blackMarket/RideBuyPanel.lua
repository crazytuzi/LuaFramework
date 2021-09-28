--tips:		本文件由'csd2lua'工具自动生成
--author:	bishaoqing.berg
local RideBuyPanel = class("RideBuyPanel", require("src/layers/base/BasePanel"))
local RideObj = require("src/layers/blackMarket/RideObj")
local BlackMarketCfg = require("src/layers/blackMarket/BlackMarketCfg")
function RideBuyPanel:ctor( oItem )
	-- body
	self.m_oItem = oItem;
	RideBuyPanel.super.ctor(self)
	
end

function RideBuyPanel:InitUI(...)
	RideBuyPanel.super.InitUI(self, ...)
	if not self.m_oItem then
		return
	end
	self.m_pRoot:retain()
	self.m_pRoot:removeFromParent()
	Manimation:transit(
	{
		node = self.m_pRoot,
		zOrder = 200,
		swallow = true,
		ep = cc.p(display.cx, display.cy),
	})
	self.m_pRoot:release()
	--这个是propid
	local nItemId = self.m_oItem:GetItemID()
	local stDB = DB.get("RidingCfg", "q_propID", nItemId) 
	print("nItemId",nItemId,stDB)
	if not stDB then
		return
	end
	local oItem = self.m_oItem
	local nPrice = oItem:GetPrice() or 1
	local nLeft = oItem:GetItemLeft() or 0
	local nMoneyType = oItem:GetMoneyType()

	local oRide = RideObj.new(stDB.q_ID)
	local nBattle = oRide:getBattle()
	local strName = oRide:getName()
	local nPictureId = oRide:getPictureId()
	local vAllAttr = oRide:getAllAttr()

	local stWinSize = cc.Director:getInstance():getWinSize()

	-- local uiBlackBg = cc.LayerColor:create( cc.c4b( 0 , 0 , 0 , 125 ) )
	-- uiBlackBg:setContentSize(stWinSize)
	-- self.m_uiRoot:addChild(uiBlackBg)
	-- GetUIHelper():AddTouchEventListener(true, uiBlackBg, nil, handler(self, self.Close))
	local bg = createSprite(self.m_uiRoot, "res/common/bg/bg18.png", cc.p(0, 0), cc.p(0.5, 0.5))

	GetUIHelper():AddTouchEventListener(true, bg, nil, nil)
	local sContent = [[灵兽详情 ]]
	local tf_title = createLabel(bg, sContent, cc.p(421, 502), cc.p(0.5, 0.5), 24)
	tf_title:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	local stSize = cc.size(790, 454)
	local _bg = GetUIHelper():WrapImg(cc.Sprite:create("res/common/scalable/panel_outer_base.png"), stSize)
    _bg:setAnchorPoint(cc.p(0.5, 0.5))
    _bg:setPosition(cc.p(427.92, 242.97))
    _bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    bg:addChild(_bg)

    local right_bg_size = cc.size(282, 436)
	local right_bg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(674, 243.18),
        right_bg_size,
        5,
        cc.p(0.5, 0.5)
    )

    local btn_close = createMenuItem(bg, "res/component/button/X.png", cc.p(812, 502), handler(self, self.Close))



    local left_bg_size = cc.size(482, 436)
	local left_bg_black = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(283, 243.18),
        left_bg_size,
        5,
        cc.p(0.5, 0.5)
    )
	local left_bg = createSprite(bg, "res/blackmarket/lingshougoumai_bg.jpg", cc.p(283, 243.18), cc.p(0.5, 0.5))
	

	local sContent = strName
	local tf_lingshou_name = createLabel(left_bg, sContent, cc.p(240, 405), cc.p(0.5, 0.5), 20)
	tf_lingshou_name:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	self.m_tfLingshouName = tf_lingshou_name;

	local stLeftSize = left_bg:getContentSize()
	local img_icon = createSprite(left_bg, "res/showplist/ride/"..nPictureId..".png", cc.p(stLeftSize.width/2 + 20, stLeftSize.height/2 + 40), cc.p(0.5, 0.5))

	local createRideEffect = function(parent, effect_str, pos, times, mode)
		local futil = cc.FileUtils:getInstance()
		local bCurFilePopupNotify = false
		if isWindows() then
			bCurFilePopupNotify = futil:isPopupNotify()
			futil:setPopupNotify(false)
		end
		local c_effect = nil
		if futil:isFileExist("res/effectsplist/" .. effect_str .. "@0.plist") then
			c_effect = Effects:create(false)
			c_effect:setPosition(pos)
			parent:addChild(c_effect)
			c_effect:playActionData2(effect_str, times, -1, 0)
			addEffectWithMode(c_effect, mode or 2)
		end

		if isWindows() then
			futil:setPopupNotify(bCurFilePopupNotify)
		end
		return c_effect
	end

	createRideEffect(left_bg, "ride_" .. nPictureId, cc.p(stLeftSize.width/2 + 20, stLeftSize.height/2 + 40), 260, 1)

	GetUIHelper():createBattleLabel( bg, nBattle, cc.p(680, 430), cc.p(0.5, 0.5) )

	local sContent = [[提升角色属性]]
	local Text_4 = createLabel(bg, sContent, cc.p(670, 387), cc.p(0.5, 0.5), 22)
	Text_4:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	local Image_5 = createSprite(bg, "res/common/bg/infoBg11-2.png", cc.p(668, 387), cc.p(0.5, 0.5))


	local scl_info = GetWidgetFactory():CreateScrollView(cc.size(300, 180), false)
	scl_info:setAnchorPoint(cc.p(0.5, 1))
	scl_info:setPosition(cc.p(697, 370))
	bg:addChild(scl_info)

	-- for i=1,10 do
	-- 	scl_info:addChild(cc.Sprite:create("res/common/misc/powerbg_1.png"))
	-- end

	for _,oRideAttr in pairs(vAllAttr) do
		local strTitle = oRideAttr:getTitle()
		local strValueTxt = oRideAttr:getValueTxt()
		local uiNode = self:createCate(strTitle, strValueTxt)
		scl_info:addChild(uiNode)
	end
	scl_info:addChild(self:createCate("百分比属性不可叠加","",MColor.red))
	GetUIHelper():FixScrollView(scl_info, 0, false, 10)

	--btn_buy按钮的回调函数写在这里：
	local function func_btn_buy( ... )
		--body
		local nLeft = oItem:GetItemLeft() or 0
		if nLeft < 1 then
			TIPS({ type = 1  , str = "该物品没有库存了!" })
			return
		end
		GetBlackMarketCtr():Buy(oItem, 1)
		self:Close()
	end
	local btn_buy = createMenuItem(bg, "res/component/button/2.png", cc.p(680, 58), func_btn_buy)

	local sContent = [[购 买]]
	local Text_5 = createLabel(btn_buy, sContent, cc.p(68, 29), cc.p(0.5, 0.5), 20)
	Text_5:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)


	local Image_6 = createSprite(bg, "res/common/bg/bg27-2.png", cc.p(675, 180), cc.p(0.5, 0.5))
	Image_6:setScaleX(0.8)

	local uiBottomNode = cc.Node:create()
	bg:addChild(uiBottomNode)
	
	
	local uiTotalPrice = self:createCate("购买总价 : ", nPrice..BlackMarketCfg.GetMoneyName(nMoneyType), nil, cc.c4b(217, 203, 104, 255))
	uiBottomNode:addChild(uiTotalPrice)

	local uiTotalPrice = self:createCate("剩余数量 : ", nLeft)
	uiBottomNode:addChild(uiTotalPrice)

	GetUIHelper():FixNode(uiBottomNode, 1, false)
	uiBottomNode:setPosition(cc.p(544, 150 - uiBottomNode:getContentSize().height))
end

function RideBuyPanel:createCate( strKey, strValue, stKeyColor, stValueColor )
	-- body
	local uiNode = cc.Node:create();
	uiNode:setAnchorPoint(cc.p(0,0));

	-- local uiKey = createLabel(uiNode, strKey or "", cc.p(0, 0), cc.p(0, 0), 20)
	-- uiKey:setColor(stKeyColor or GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- local uiValue = createLabel(uiNode, strValue or "", cc.p(0, 0), cc.p(0, 0), 20)
	-- uiValue:setColor(stValueColor or GetUiCfg().FontColor.NumberColor)
	GetUIHelper():createRichText( uiNode, strKey or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 20, stKeyColor or GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	GetUIHelper():createRichText( uiNode, strValue or "", cc.p(0, 0), nil, cc.p(0, 0), nil, 20, stValueColor or GetUiCfg().FontColor.NumberColor)
	local nColPadding = 1;
	GetUIHelper():FixNode(uiNode, nColPadding, true)
	return uiNode;
end

function RideBuyPanel:Dispose( ... )
	-- body
	RideBuyPanel.super.Dispose(self, ...)
end

return RideBuyPanel