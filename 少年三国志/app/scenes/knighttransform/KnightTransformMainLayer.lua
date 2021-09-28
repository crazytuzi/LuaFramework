local function newMaskedSprite(__mask, __pic, nScale)
	nScale = nScale or 1
    local __mb = ccBlendFunc:new()
    __mb.src = GL_ONE
    __mb.dst = GL_ZERO

    local __pb = ccBlendFunc:new()
    __pb.src = GL_DST_ALPHA
    __pb.dst = GL_ZERO

    local __maskSprite = display.newSprite(__mask):align(display.LEFT_BOTTOM, 0, 0)
    __maskSprite:setBlendFunc(__mb)

    local __picSprite = display.newSprite(__pic):align(display.LEFT_BOTTOM, 0, 0)
    __picSprite:setBlendFunc(__pb)
    __picSprite:setScale(nScale)

    local __maskSize = __maskSprite:getContentSize()
    local __canva = CCRenderTexture:create(__maskSize.width,__maskSize.height)
    __canva:begin()
    __maskSprite:visit()
    __picSprite:visit()
    __canva:endToLua()

    local __resultSprite = CCSpriteExtend.extend(
        CCSprite:createWithTexture(
            __canva:getSprite():getTexture()
        ))
        :flipY(true)
    return __resultSprite
end

local function createKnightPic(resId, hasShadow)
	local picPath = G_Path.getKnightPic(resId)
    local sp = ImageView:create()
    sp:setName(name or "default_image_name")
    sp:loadTexture(picPath, UI_TEX_TYPE_LOCAL)
    local config = decodeJsonFile(G_Path.getKnightPicConfig(resId))
    
    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)    
    end

    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))

    return sp
end

function createWholeNode( resId, cutBottom, wholeBody)
    local picPath = G_Path.getKnightPic(resId)
    local config = decodeJsonFile(G_Path.getKnightPicConfig(resId))

    local sp = CCSprite:create(picPath)
    local size = sp:getContentSize()

--先校对halfw halfh, halfy, halfx
    local halfh = config.half_h
    local halfw = config.half_w
    local halfx = config.half_x
    local halfy = config.half_y
    if cutBottom == nil then
        cutBottom = 0
    end

    if cutBottom < 0 then
        cutBottom = 0
    end

    if cutBottom > 1 then
        cutBottom = 1
    end

    halfy = halfy + cutBottom*halfh/2
    halfh = halfh * (1-cutBottom)

-- 再根据wholeBody 判断是否不裁剪上面,左边,右边
    if wholeBody then
        local x = 0
        local y = 0 
        local w = size.width
        local h = size.height

        --裁剪后的图片中心点在全局坐标系的位置
        local cx = config.x
        local cy = config.y + (size.height - h )/2


        sp:setTextureRect(CCRectMake(x, y, w, h))
        sp:setPosition(ccp(  cx - halfx,  cy - halfy ))
    else 
        --判断矩形是否有超过本身图片尺寸, 做一定的调整
        local x = halfx - halfw/2 - config.x + size.width/2
        local y = size.height/2 - (halfy + halfh/2 - config.y)
        local w = halfw
        local h = halfh
        if  x + w > size.width then
            w = size.width - x  
        end
        if  y + h > size.height then
            h = size.height - y  
        end

        sp:setTextureRect(CCRectMake(x, y, w, h))
        sp:setPosition(ccp( (w -halfw)/2,  (halfh -h)/2 ))
    end

    local wrapperNode = display.newNode()
    wrapperNode:addChild(sp,1,1)

    return wrapperNode
end


require("app.cfg.knight_transform_info")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local knightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local KnightTransformMainLayer = class("KnightTransformMainLayer", UFCCSNormalLayer)


KnightTransformMainLayer.SOURCE_KNIGHT_LIST_LAYER = 1010
KnightTransformMainLayer.TARGET_KNIGHT_LIST_LAYER = 1011
KnightTransformMainLayer.PREVIEW_LAYER_TAG = 1012
KnightTransformMainLayer.TRANSFORM_CONFIRM_LAYER = 1013


function KnightTransformMainLayer.create(...)
	return KnightTransformMainLayer.new("ui_layout/KnightTransform_MainLayer.json", nil, ...)
end

function KnightTransformMainLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self._nSourceKnightId = 0
	self._nTargetKnightBaseId = 0

	-- 变身过程中，按钮点击是没有效果的
	self._onTransforming = false
	-- 镜子中加号的渐隐渐显的动效
	self._tInOutAction = nil
	-- “稀有+箭头”的原来位置
	self._ptRareOrig = ccp(0, 0)

	self:_initWidgets()
	self:_addSceneEffect()
end

function KnightTransformMainLayer:onLayerEnter()
	self:registerKeypadEvent(true)

	self:adapterWidgetHeight("Panel_heros", "Panel_Top", "", -20, 0)
	self:adapterWidgetHeight("Button_Transform", "Panel_heros", "", -170, 0)
	self:adapterWidgetHeight("Button_Preview", "Panel_heros", "", -150, 0)

	-- 成功选择了一个源武将
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_SELECT_SOURCE_KINGHT_SUCC, self._onSelectSourceKnightSucc, self)
	-- 成功选择了一个目标武将
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_SELECT_TARGET_KINGHT_SUCC, self._onSelectTargetKnightSucc, self)
	-- 变身成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_TRANSFORM_SUCC, self._onTransformSucc, self)
	-- 充值成功，元宝到账
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._onUpdateTransformCost, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_FLUSH_DATA, self._onUpdateTransformCost, self)

end

function KnightTransformMainLayer:onLayerExit()
	self:_clearStage()
end

function KnightTransformMainLayer:onBackKeyEvent()
    self:_onClickBack()
    return true
end

function KnightTransformMainLayer:_initWidgets()
	self:_showTransformCost(false)
	self:_showPreviewButton(false)
	self:_showAddTargetSign(false)
	self:_showAddSourceButtonAction()
	CommonFunc._updateLabel(self, "Label_TransfromDesc1", {text=G_lang:get("LANG_KNIGHT_TRANSFORM_TRANSFORM_DESC1"), stroke=Colors.strokeBrown})

	self:getLabelByName("Label_Rare"):createStroke(Colors.strokeBrown, 1)
	self._ptRareOrig = self:getPanelByName("Panel_Rare"):getPositionInCCPoint()

---	self:registerBtnClickEvent("Button_SelectBefore", handler(self, self._onSelectSourceKnight))
	self:registerBtnClickEvent("Button_Transform", handler(self, self._onTransform))
	self:registerBtnClickEvent("Button_Preview", handler(self, self._onPreview))
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickBack))

	self:registerWidgetTouchEvent("Image_Mirror", handler(self, self._onSelectTargetKnight1))
	self:registerWidgetTouchEvent("Panel_AddSource", handler(self, self._onSelectSourceKnight1))
end


function KnightTransformMainLayer:_onSelectSourceKnight(sender)
	if self._onTransforming then
		return
	end

	local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.SOURCE_KNIGHT_LIST_LAYER)
	if not tLayer then
		tLayer = require("app.scenes.knighttransform.KnightTransformSourceLayer").create()
	end
	uf_sceneManager:getCurScene():addChild(tLayer, 1, KnightTransformMainLayer.SOURCE_KNIGHT_LIST_LAYER)
end

function KnightTransformMainLayer:_onSelectSourceKnight1(sender, eventType)
	if self._onTransforming then
		return
	end

	if eventType == TOUCH_EVENT_ENDED then
		local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.SOURCE_KNIGHT_LIST_LAYER)
		if not tLayer then
			tLayer = require("app.scenes.knighttransform.KnightTransformSourceLayer").create()
		end
		uf_sceneManager:getCurScene():addChild(tLayer, 1, KnightTransformMainLayer.SOURCE_KNIGHT_LIST_LAYER)
	end
end

function KnightTransformMainLayer:_onSelectTargetKnight(sender)
	if self._onTransforming then
		return
	end

	if self._nSourceKnightId ~= 0 then
		local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.TARGET_KNIGHT_LIST_LAYER)
		if not tLayer then
			tLayer = require("app.scenes.knighttransform.KnightTransformTargetLayer").create(self._nSourceKnightId)
		end
		uf_sceneManager:getCurScene():addChild(tLayer, 1, KnightTransformMainLayer.TARGET_KNIGHT_LIST_LAYER)
	end
end

function KnightTransformMainLayer:_onSelectTargetKnight1(sender, eventType)
	if self._onTransforming then
		return
	end

	if eventType == TOUCH_EVENT_ENDED then
		if self._nSourceKnightId ~= 0 then
			local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.TARGET_KNIGHT_LIST_LAYER)
			if not tLayer then
				tLayer = require("app.scenes.knighttransform.KnightTransformTargetLayer").create(self._nSourceKnightId)
			end
			uf_sceneManager:getCurScene():addChild(tLayer, 1, KnightTransformMainLayer.TARGET_KNIGHT_LIST_LAYER)
		end
	end
end

function KnightTransformMainLayer:_onTransform(sender)
	if self._onTransforming then
		return
	end

	if self._nSourceKnightId == 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRANSFORM_CHOOSE_SOURCE_KNIGHT_FIRST"))
		return
	end
	if self._nTargetKnightBaseId == 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRANSFORM_CHOOSE_TARGET_KNIGHT_FIRST"))
		return
	end
	-- 先判断钱钱够不够
	local nCost, nJingHua = G_GlobalFunc.getKnightTransformCost(self._nSourceKnightId, self._nTargetKnightBaseId)
	local nJiangHunCost = nCost
	if G_Me.userData.gold >= nCost then
		-- 再判断将魂够不够
		if G_Me.userData.essence >= nJiangHunCost then
			-- 再再判断武将精华够不够
		--	__Log("-- 拥有红色武将精华数量 = %d, 消耗数量为 = %d", G_Me.bagData:getNumByTypeAndValue(3, 3), nJingHua)
			if G_Me.bagData:getNumByTypeAndValue(3, 3) >= nJingHua then
				local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.TRANSFORM_CONFIRM_LAYER)
				if not tLayer then
					tLayer = require("app.scenes.knighttransform.KnightTransformConfirmLayer").create(self._nSourceKnightId, self._nTargetKnightBaseId)
					uf_sceneManager:getCurScene():addChild(tLayer, 1, KnightTransformMainLayer.TRANSFORM_CONFIRM_LAYER)
				end
			else
				-- 提示红色武将精华不足
				require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 3,
                    GlobalFunc.sceneToPack("app.scenes.knighttransform.KnightTransformMainScene") )
			end
		else
			-- 提示将魂不足
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_WUHUN, 0,
                    GlobalFunc.sceneToPack("app.scenes.knighttransform.KnightTransformMainScene") )
		end
	else
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	end
end

function KnightTransformMainLayer:_onPreview(sender)
	if self._onTransforming then
		return
	end

	local tLayer = uf_sceneManager:getCurScene():getChildByTag(KnightTransformMainLayer.PREVIEW_LAYER_TAG)
	if not tLayer then
		if self._nSourceKnightId == 0 then
			-- 提示选择源武将
			G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRANSFORM_CHOOSE_SOURCE_KNIGHT_FIRST"))
		elseif self._nTargetKnightBaseId == 0 then
			-- 提示选择目标武将
			G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRANSFORM_CHOOSE_TARGET_KNIGHT_FIRST"))
		else
			uf_sceneManager:getCurScene():addChild(require("app.scenes.knighttransform.KnightTransformPreviewLayer").create(self._nSourceKnightId, self._nTargetKnightBaseId))
		end
	end
end

function KnightTransformMainLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_KNIGHT_TRANSFORM_HELP_TITLE1"), content=G_lang:get("LANG_KNIGHT_TRANSFORM_HELP_CONTENT1")},
    } )
end

function KnightTransformMainLayer:_onClickBack()
	uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
end

function KnightTransformMainLayer:_onSelectSourceKnightSucc(nId)
	--[[
	self:showWidgetByName("ImageView_knight_dizou_before", false)
	self:getButtonByName("Button_SelectBefore"):stopAllActions()
	]]

	if self._tRareAction then
		local panelRare = self:getPanelByName("Panel_Rare")
		if panelRare then
			panelRare:stopAllActions()
			panelRare:setPosition(self._ptRareOrig)
			panelRare:setVisible(false)
			self._tRareAction = nil
		end
	end

	if self._addSourceEffect then
		self._addSourceEffect:removeFromParentAndCleanup(true)
		self._addSourceEffect = nil
		self:getPanelByName("Panel_AddSource"):setVisible(false)
	end

	self:_clearStage()

	self._nSourceKnightId = nId or 0
	-- 把武将的形象放到台上
	self:_showAddTargetSign(true)
	if self._nSourceKnightId and self._nSourceKnightId ~= 0 then
		local nBaseId = G_Me.bagData.knightsData:getBaseIdByKnightId(self._nSourceKnightId)
		local tKnightTmpl = knight_info.get(nBaseId)
		if tKnightTmpl then
			local panelBefore = self:getPanelByName("Panel_icon_before")
			local knightPanel = self:getWidgetByName("Panel_icon_before")
			local knightDizuo = self:getPanelByName("Panel_dizuo_before")

			if not knightPanel or not knightDizuo or nBaseId < 1 then 
				return 
			end

			if not self._imgSourceKnight then
				self._imgSourceKnight = knightPic.createKnightButton(tKnightTmpl.res_id, self:getPanelByName("Panel_icon_before"), "source_knight", self, function ( ... )
					self:_onSelectSourceKnight()
				end, true)
        		EffectSingleMoving.run(self._imgSourceKnight, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
		
				local callback = nil
				self:showWidgetByName("Panel_icon_before", false)
				local centerPtx, centerPty = knightPanel:convertToWorldSpaceXY(0, 0)
				centerPtx, centerPty = knightDizuo:convertToNodeSpaceXY(centerPtx, centerPty)
				local KnightAppearEffect = require("app.scenes.hero.KnightAppearEffect")
				local ani = nil 
			    ani = KnightAppearEffect.new(nBaseId, function()
			        local soundConst = require("app.const.SoundConst")
			        G_SoundManager:playSound(soundConst.GameSound.KNIGHT_DOWN)
			    	if callback then 
			    		callback() 
			    	end
			    	if ani then
			    		ani:removeFromParentAndCleanup(true)
			    	end
			    	self:showWidgetByName("Panel_icon_before", true)
			    end, 0)
			    ani:setPositionXY(centerPtx, centerPty)
			    ani:play()
			    ani:setScale(knightPanel:getScale())
			    knightDizuo:addNode(ani)
		
			end
		end
	end
end


local function createPicButton(resId, hasShadow, name, layer, func)
	local picPath = G_Path.getKnightPic(resId)
    local sp = Button:create()
    sp:setName(name or "default_image_name")
    sp:loadTextureNormal(picPath, UI_TEX_TYPE_LOCAL)
    local config = decodeJsonFile(G_Path.getKnightPicConfig(resId))
    
    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)    
    end

    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))

    if layer and type(func) == "function" then
        layer:registerBtnClickEvent(name or "default_image_name", func)
    end

    return sp
end

function KnightTransformMainLayer:_onSelectTargetKnightSucc(nBaseId)
	self:_clearTargetKnight()

	self._nTargetKnightBaseId = nBaseId or 0
	if self._nTargetKnightBaseId == 0 then
		return
	end

	local tKnightTmpl = knight_info.get(nBaseId)
	if tKnightTmpl then

		if not self._imgTargetKnight then
			if not self._clippingNode then
				local imgMirror = self:getImageViewByName("Image_Mirror")
				local x, y = imgMirror:convertToWorldSpaceXY(0, 0)
				x, y = self:getPanelByName("Panel_dizuo_after"):convertToNodeSpaceXY(x, y)

				self._imgTargetKnight = createWholeNode(tKnightTmpl.res_id, 0, true)
				self._imgTargetKnight:setScale(0.8)
				self._imgTargetKnight:setPositionY(self._imgTargetKnight:getPositionY() + 45)

				local stencilA = CCSprite:create("ui/knighttransform/zhezhao.png")
				self._clippingNode = CCClippingNode:create()
				self._clippingNode:setStencil(stencilA)
				self._clippingNode:addChild(self._imgTargetKnight)
				 
				self._clippingNode:setAnchorPoint(ccp(0, 0))
				self._clippingNode:setPosition(ccp(x, y))
				self:getPanelByName("Panel_dizuo_after"):addNode(self._clippingNode)

				local function breath()
				--	EffectSingleMoving.run(self._imgTargetKnight, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
				end

				local actFaceIn = CCFadeIn:create(0.8)
				local funcCallback = CCCallFunc:create(breath)
				local actSeq = CCSequence:createWithTwoActions(actFaceIn, funcCallback)
				self._imgTargetKnight:setCascadeOpacityEnabled(true)
				self._imgTargetKnight:runAction(actSeq)
			end
		end
	end

	self:_showAddTargetSign(false)
	self:_showTransformCost(true)
	self:_showPreviewButton(true)

	-- 价格系数
	local nSourcePriceFactor = 0
	local nTargetPriceFactor = 0 

	local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
	local tSourceKnightTmpl = knight_info.get(tSourceKnight["base_id"])
    for i=1, knight_transform_info.getLength() do
        local tTransformTmpl = knight_transform_info.indexOf(i)
        if tTransformTmpl and tSourceKnightTmpl and tTransformTmpl.advanced_code == tSourceKnightTmpl.advance_code then
            nSourcePriceFactor = tTransformTmpl.cost
        end
        if tTransformTmpl and tKnightTmpl and tTransformTmpl.advanced_code == tKnightTmpl.advance_code then
          	nTargetPriceFactor = tTransformTmpl.cost
        end
    end
--    __Log("-- nSourcePriceFactor = %d, nTargetPriceFactor = %d", nSourcePriceFactor, nTargetPriceFactor)

    local panelRare = self:getPanelByName("Panel_Rare")
    if panelRare then
	    if nTargetPriceFactor > nSourcePriceFactor then
	    	panelRare:setVisible(true)
	    	-- 要动作
	    	if not self._tRareAction then
	    		-- 没有动作，就加一个动作
	    		panelRare:stopAllActions()
	    		panelRare:setPosition(self._ptRareOrig)
	    		local actMoveUp = CCMoveBy:create(0.5, ccp(0, 10))
	    		local actMoveDown = CCMoveBy:create(0.5, ccp(0, -10))
	    		local actSeq = CCSequence:createWithTwoActions(actMoveDown, actMoveUp)
	    		local actRep = CCRepeatForever:create(actSeq)
	    		panelRare:runAction(actRep)
	    		self._tRareAction = actRep
	    	end
	    else
	    	panelRare:setVisible(false)
	    	if self._tRareAction then
	    		panelRare:stopAllActions()
	    		panelRare:setPosition(self._ptRareOrig)
	    		self._tRareAction = nil
	    	end
	    end
	end

end

function KnightTransformMainLayer:_showTransformCost(isShow)
	isShow = isShow or false

	if isShow then
		self:showWidgetByName("Panel_TransformCost", true)
		self:_updateCost()
	else
		self:showWidgetByName("Panel_TransformCost", false)
	end
end
function KnightTransformMainLayer:_showPreviewButton(isShow)
	isShow = isShow or false
	self:showWidgetByName("Button_Preview", isShow)
end

function KnightTransformMainLayer:_onUpdateTransformCost()
	if self._nSourceKnightId ~= 0 and self._nTargetKnightBaseId ~= 0 then
		self:_updateCost()
	end
end

function KnightTransformMainLayer:_updateCost()
	local nCost, nJingHua = G_GlobalFunc.getKnightTransformCost(self._nSourceKnightId, self._nTargetKnightBaseId)
	local nJiangHunCost = nCost
	-- 花费元宝
	CommonFunc._updateLabel(self, "Label_Cost", {text=nCost, color=G_Me.userData.gold >= nCost and Colors.lightColors.TITLE_01 or Colors.lightColors.TIPS_01, stroke=Colors.strokeBrown})
	-- 花费将魂
	CommonFunc._updateLabel(self, "Label_Cost_JiangHun", {text=nJiangHunCost, color=G_Me.userData.essence >= nJiangHunCost and Colors.lightColors.TITLE_01 or Colors.lightColors.TIPS_01, stroke=Colors.strokeBrown})
	-- 花费武将精华（真红转真红）
	CommonFunc._updateLabel(self, "Label_Cost_JingHua", {text=nJingHua, color=G_Me.bagData:getNumByTypeAndValue(3, 3) >= nJingHua and Colors.lightColors.TITLE_01 or Colors.lightColors.TIPS_01, stroke=Colors.strokeBrown})

	self:_alignCost(nJingHua)
end

function KnightTransformMainLayer:_alignCost(nJingHua)
	nJingHua = nJingHua or 0
	if nJingHua > 0 then
		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 100), {
	        self:getImageViewByName('Image_Gold'),
	        self:getLabelByName('Label_Cost'),
	        self:getLabelByName('Label_Space'),
	        self:getImageViewByName('Image_JiangHun'),
	        self:getLabelByName('Label_Cost_JiangHun'),

	        self:getLabelByName('Label_Space_1'),
	        self:getImageViewByName('Image_JingHua'),
	        self:getLabelByName('Label_Cost_JingHua'),
	    }, "C")
	    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_Cost'):setPositionXY(alignFunc(2))
	    self:getLabelByName('Label_Space'):setPositionXY(alignFunc(3))
	    self:getImageViewByName('Image_JiangHun'):setPositionXY(alignFunc(4))
	    self:getLabelByName('Label_Cost_JiangHun'):setPositionXY(alignFunc(5))
	    self:getLabelByName('Label_Space_1'):setPositionXY(alignFunc(6))
	    self:getImageViewByName('Image_JingHua'):setPositionXY(alignFunc(7))
	    self:getLabelByName('Label_Cost_JingHua'):setPositionXY(alignFunc(8))

	    self:showWidgetByName("Label_Space_1", true)
	    self:showWidgetByName("Image_JingHua", true)
	    self:showWidgetByName("Label_Cost_JingHua", true)
	else
		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 100), {
	        self:getImageViewByName('Image_Gold'),
	        self:getLabelByName('Label_Cost'),
	        self:getLabelByName('Label_Space'),
	        self:getImageViewByName('Image_JiangHun'),
	        self:getLabelByName('Label_Cost_JiangHun'),
	    }, "C")
	    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_Cost'):setPositionXY(alignFunc(2))
	    self:getLabelByName('Label_Space'):setPositionXY(alignFunc(3))
	    self:getImageViewByName('Image_JiangHun'):setPositionXY(alignFunc(4))
	    self:getLabelByName('Label_Cost_JiangHun'):setPositionXY(alignFunc(5))

	    self:showWidgetByName("Label_Space_1", false)
	    self:showWidgetByName("Image_JingHua", false)
	    self:showWidgetByName("Label_Cost_JingHua", false)
	end
end

function KnightTransformMainLayer:_onTransformSucc(data)
	self._onTransforming = true
	self:_showTransformCost(false)
	self:_showPreviewButton(false)

	self._imgSourceKnight:setEnabled(false)

	-- source武将开始渐渐消失
	if not self._imgSourceKnight and not self._imgTargetKnight then
		assert(false, "error knight image~")
		return
	end

	local function palyMirrorEffect( ... )
		if not self._tMirrorEffect then
			if not self._tMirrorEffect then
				-- 第二步，镜子特效
			    self._tMirrorEffect = EffectNode.new("effect_mojing_b", function(event, frameIndex)
			    	if event == "b" then
			    		-- 新的武将出现,先清除所有舞台上的武将
		            	self:_clearStage()
		            	if not self._imgSourceKnight then
		            		self._nSourceKnightId = data.knight.id
		            		local tKnightTmpl = knight_info.get(data.knight["base_id"])
							self._imgSourceKnight = knightPic.createKnightButton(tKnightTmpl.res_id, self:getPanelByName("Panel_icon_before"), "source_knight", self, function ( ... )
								self:_onSelectSourceKnight()
							end, true)
							self._imgSourceKnight:getVirtualRenderer():setOpacity(0)
							self._imgSourceKnight:setEnabled(false)

			        		local function breath2()
			        			self:_showAddTargetSign(true)
					        	EffectSingleMoving.run(self._imgSourceKnight, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
			        		end

			        		-- 第三步，变身后的武将出现，配合一个特效
			        		local actFaceIn2 = CCFadeIn:create(1)
			        		local actCallback2 = CCCallFunc:create(breath2)
			        		self._imgSourceKnight:getVirtualRenderer():runAction(CCSequence:createWithTwoActions(actFaceIn2, actCallback2))
			        		-- 配合的特效
			        		if not self._tStep3Effect then
			        			self._tStep3Effect = EffectNode.new("effect_mojing_c", function(event, frameIndex)
									if event == "finish" then
										self._onTransforming = false
										self._imgSourceKnight:setEnabled(true)

									 	self._tStep3Effect:removeFromParentAndCleanup(true)
									 	self._tStep3Effect = nil
									end
								end)
								local tParent = self:getPanelByName("Panel_heros")
								if tParent then
								 	local tSize = tParent:getSize()
									tParent:addNode(self._tStep3Effect, 6)
									self._tStep3Effect:setPosition(ccp(tSize.width/2 + 20, tSize.height/2 + 50))
									self._tStep3Effect:play()
								end
			        		end
		            	end
		            elseif event == "finish" then
		            	-- 删除镜子特效
		                self._tMirrorEffect:removeFromParentAndCleanup(true)
		                self._tMirrorEffect = nil
		            end
		        end)  
		        local tParent = self:getImageViewByName("Image_Mirror")
		        if tParent then
		        	local tSize = tParent:getSize()
			        self._tMirrorEffect:setPosition(ccp(-5, 0))
			        tParent:addNode(self._tMirrorEffect)
			        self._tMirrorEffect:play()
		        end
			end
		end
	end

	-- 第1步, 源武将逐渐消失,配合一个特效
	local actFadeOut1 = CCFadeOut:create(1)
	self._imgSourceKnight:getVirtualRenderer():runAction(actFadeOut1)
	-- 配合源武将消失的特效
	if not self._tStep1Effect then
		self._tStep1Effect = EffectNode.new("effect_mojing_a", function(event, frameIndex)
			if event == "a" then
				palyMirrorEffect()
			elseif event == "finish" then
			 	self._tStep1Effect:removeFromParentAndCleanup(true)
			 	self._tStep1Effect = nil
			end
		end)
		local tParent = self:getPanelByName("Panel_heros")
		if tParent then
			local tSize = tParent:getSize()
			tParent:addNode(self._tStep1Effect, 6)
			self._tStep1Effect:setPosition(ccp(tSize.width/2 - 70, tSize.height/2 + 10))
			self._tStep1Effect:play()
		end
	end
	-- 目标武将渐隐
	self:_targetKnightFadeOut()
	-- 稀有消失
	if self._tRareAction then
		local panelRare = self:getPanelByName("Panel_Rare")
		if panelRare then
			panelRare:stopAllActions()
			panelRare:setPosition(self._ptRareOrig)
			panelRare:setVisible(false)
			self._tRareAction = nil
		end
	end
end

function KnightTransformMainLayer:_onOpenSuccLayer(knight)
	local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
	OneKnightDrop.show(1, knight["base_id"], nil)
end

function KnightTransformMainLayer:_clearStage( ... )
	self:_clearSourceKnight()
	self:_clearTargetKnight()

	self:_showTransformCost(false)
	self:_showPreviewButton(false)
end

function KnightTransformMainLayer:_clearSourceKnight()
	if self._imgSourceKnight then
		self._imgSourceKnight:removeFromParentAndCleanup(true)
		self._imgSourceKnight = nil
	end
	self._nSourceKnightId = 0
end

function KnightTransformMainLayer:_clearTargetKnight()
	if self._imgTargetKnight then
		self._imgTargetKnight:removeFromParentAndCleanup(true)
		self._imgTargetKnight = nil
	end
	if self._clippingNode then
		self._clippingNode:removeFromParentAndCleanup(true)
		self._clippingNode = nil
	end
	self._nTargetKnightBaseId = 0
end

function KnightTransformMainLayer:_showAddTargetSign(isShow)
	isShow = isShow or false
	local imgPlusSign = self:getImageViewByName("Image_PlusSign")
	if imgPlusSign then
		imgPlusSign:setVisible(isShow)
		if not isShow and self._tInOutAction then
			imgPlusSign:stopAllActions()
			self._tInOutAction = nil
		end
		if isShow and not self._tInOutAction then
			local actSeq = CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1))
			local actRepeat = CCRepeatForever:create(actSeq)
			self._tInOutAction = actRepeat
			imgPlusSign:runAction(self._tInOutAction)
		end
	end
end

function KnightTransformMainLayer:_showAddSourceButtonAction()
	--[[
	local actSeq = CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1))
	local actRepeat = CCRepeatForever:create(actSeq)
	self:getButtonByName("Button_SelectBefore"):setCascadeOpacityEnabled(true)
	self:getButtonByName("Button_SelectBefore"):runAction(actRepeat)
	]]

	-- 增加特效，主界面中的提示提示上阵的特效
	if not self._addSourceEffect then
		self._addSourceEffect = EffectNode.new("effect_szts")
		local tParent = self:getPanelByName("Panel_AddSource")
		self:getImageViewByName("ImageView_knight_dizou_before"):setVisible(false)
		if self._addSourceEffect and tParent then
			tParent:addNode(self._addSourceEffect)
			self._addSourceEffect:play()
			local x, y = self._addSourceEffect:getPosition()
			x = x + tParent:getSize().width/2
			y = y + 50
			self._addSourceEffect:setPositionXY(x, y)
		end
	end
end

function KnightTransformMainLayer:_addSceneEffect()
	if not self._tSceneEffect then
		self._tSceneEffect = EffectNode.new("effect_mojing_BG", function(event, frameIndex)

		end)
		local tParent = self:getImageViewByName("ImageView_4674")
		if tParent then
			tParent:addNode(self._tSceneEffect)
			self._tSceneEffect:play()
		end
	end
end

function KnightTransformMainLayer:_targetKnightFadeOut()
	if self._imgTargetKnight then
		self._imgTargetKnight:setCascadeOpacityEnabled(true)
		self._imgTargetKnight:runAction(CCFadeOut:create(2))
	end
end
return KnightTransformMainLayer