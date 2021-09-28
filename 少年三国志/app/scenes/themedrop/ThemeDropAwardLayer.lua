local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require("app.common.effects.EffectNode")
local ThemeDropAwardLayer = class("ThemeDropAwardLayer", UFCCSModelLayer)

function ThemeDropAwardLayer.create(tAwardList, endCallback, ...)
	return ThemeDropAwardLayer.new("ui_layout/themedrop_AwardLayer.json", Colors.modelColor, tAwardList, endCallback, ...)
end

function ThemeDropAwardLayer:ctor(json, param, tAwardList, endCallback, ...)
	self.super.ctor(self, json, param, ...)

    self._tAwardList = tAwardList or {}
    self._endCallback = endCallback

    -- 2个红将碎片在tAward中的index
    self._tRedKnightIndexList = {}

    for i=1, #self._tAwardList do
        local tAward = self._tAwardList[i]
        if tAward and tAward.type ~= nil and tAward.type ~= 0 then
            local tGoods = G_Goods.convert(tAward.type, tAward.value, tAward.size)
            if tGoods then
                if tGoods.quality == 6 then
                    table.insert(self._tRedKnightIndexList, #self._tRedKnightIndexList+1, i)
                end
            end
        end
    end
--    dump(self._tRedKnightIndexList)

	self:_initWidgets()

	self:setAward(self._tAwardList)
end

function ThemeDropAwardLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

    EffectSingleMoving.run(self, "smoving_bounce")
end

function ThemeDropAwardLayer:onLayerExit( ... )
	-- body
end

function ThemeDropAwardLayer:_initWidgets( ... )
    self._listPanel = self:getPanelByName("Panel_list")
    self._scrollView = self:getScrollViewByName("ScrollView_list")

    self:getLabelByName("Label_desc"):setText(G_lang:get("LANG_THEME_DROP_AWART_DESC"))

	self:registerBtnClickEvent("Button_get", function()
		if self._endCallback then
			self._endCallback()
		end
		self:animationToClose()
	end)
end

function ThemeDropAwardLayer:setAward(award)
    local count = #award
    local height = math.floor((count-1)/4)+1
    height = height * 155 + (height-1)*10
    local size = self._scrollView:getContentSize()
    if height > size.height then
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,0)
        self._scrollView:setTouchEnabled(true)
    else
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,size.height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,size.height-height)
        self._scrollView:setTouchEnabled(false)
    end
    local tIconList = GlobalFunc.createIconInPanel2({panel=self._listPanel,award=award,click=true,name=true,offset=5,maxX=4})

    for i=1, #tIconList do
        for k=1, #self._tRedKnightIndexList do
            if i == self._tRedKnightIndexList[k] then
                local tIcon = tIconList[i]
                local eff = EffectNode.new("effect_around1", function(event, frameIndex) end)
                local tParent = tIcon:getButtonByName("Button_board")
                if eff and tParent then
                    tParent:addNode(eff)
                    eff:setScale(1.5)
                    local x = eff:getPositionX()
                    eff:setPositionX(x+4)
                    eff:play()
                end
            end
        end
    end
end

function ThemeDropAwardLayer:onClickClose()
    if self._endCallback then
        self._endCallback()
    end
end

return ThemeDropAwardLayer