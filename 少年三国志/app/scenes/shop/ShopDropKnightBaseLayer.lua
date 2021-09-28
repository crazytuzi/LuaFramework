--抽卡时，弹出提示Layer
local ShopDropKnightBaseLayer = class("ShopDropKnightLayer",UFCCSModelLayer)
require("app.cfg.knight_pack_info")

function ShopDropKnightBaseLayer.create()
    local layer = ShopDropKnightBaseLayer.new("ui_layout/shop_ShopDropKnightLayer.json",require("app.setting.Colors").modelColor)
    return layer
end

function ShopDropKnightBaseLayer.create02()
    local layer = ShopDropKnightBaseLayer.new("ui_layout/shop_ShopDropKnightLayer_2.json",require("app.setting.Colors").modelColor)
    return layer
end


function ShopDropKnightBaseLayer:ctor(...)
    self.super.ctor(self,...)
    __LogTag(TAG,"ShopDropKnightBaseLayer:ctor(...)")
    self._oneTimeFunc = nil;
    self._moreTimeFunc = nil;
    self:_initWidgets()
    self:_createStroke()
    self:_initButtonEvent()
    self:showAtCenter(true)
end



function ShopDropKnightBaseLayer:_initWidgets()
    
    --标题  再招8次后，必出五星神将
    self.LabelTitleNote =self:getLabelByName("Label_jipinlefttime")
    
    --小图标,不同抽卡类型，图标不同
    self.ImgNowMoneyTag = self:getImageViewByName("ImageView_nowMoneyTag")
    self.ImgShuaXinToken = self:getImageViewByName("ImageView_shuaxinToken")
    self.ImgOneTimeTag = self:getImageViewByName("ImageView_onetimeTag")
    self.ImgMoreTimeTag = self:getImageViewByName("ImageView_moretimeTag")
    
    --抽卡类型,良品 or 神将
    self.ImgDropType = self:getImageViewByName("ImageView_dropType")
    --当前money
    self.LabelNowMoney = self:getLabelByName("Label_money")
    --当前刷新令
    self.LabelShuaxinToken = self:getLabelByName("Label_shuaxinToken")
    --  一次消耗
    self.LabelOneTimeMoney = self:getLabelByName("Label_onetimeMoney")
    --  多次消耗
    self.LabelMoreTimeMoney = self:getLabelByName("Label_moretimeMoney")
    
    --良将令或神将令文字
    self.tokenTagLabel = self:getLabelByName("Label_shuaxinTokenTag")
    --  招一次Button
    self.ButtonOneTime = self:getButtonByName("Button_onetime")
    -- 招十次 button
    self.ButtonMoreTime = self:getButtonByName("Button_moretime")

    --title
    self.titleImage = self:getImageViewByName("ImageView_title")

    self:attachImageTextForBtn("Button_moretime","ImageView_3885")
    
end


function ShopDropKnightBaseLayer:_createStroke()
    self:enableLabelStroke("Label_shuaxinTokenTag", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_shuaxinToken", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_money", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_free", Colors.strokeBrown,1)

    self:enableLabelStroke("Label_onetimeMoney", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_moretimeMoney", Colors.strokeBrown,1)

    self:enableLabelStroke("Label_jipinlefttime", Colors.strokeBrown,1)

    self:enableLabelStroke("Label_must_shenjiang", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_must_shenjiang_0", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_must_chengjiang", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_must_chengjiang_0", Colors.strokeBrown,1)

    
    self:enableLabelStroke("Label_2", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_2_0", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_6", Colors.strokeBrown,1)

    --可招募字样
    self:enableLabelStroke("Label_availableTag01", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_availableTag02", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_43", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_43_1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_43_3", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_43_4", Colors.strokeBrown,1)

    self:enableLabelStroke("Label_43_0", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_43_2", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_44_0", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_44_2", Colors.strokeBrown,1)

    self:enableLabelStroke("Label_44", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_44_1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_44_3", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_44_4", Colors.strokeBrown,1)


end 

--[[
    showType 预览类型
    1 良将
    2 神将
    4 魏
    5 蜀
    6 吴
    7 群雄
]]
function ShopDropKnightBaseLayer:setAutoScrollView(showType)
    --require("app.cfg.knight_pack_info")
    --local len = knight_pack_info.getLength()
    --显示类型
    self._showType = showType or 1
    self:_doInitScrollView()
    -- local showId = 0
    -- for i=1,len do
    --     local item = knight_pack_info.indexOf(i)
    --     if item.knight_show == showType then
    --         showId = item.id
    --     end
    -- end
    -- if showId == 0 then
    --     --没有找到,表出问题了
    --     return
    -- end
    -- --招将预览
    -- self:registerBtnClickEvent("Button_review",function() 
    --     print("---self._showType = " .. self._showType)
    --     local layer = require("app.scenes.shop.ShopDropKnightReview").create(self._showType)
    --     uf_sceneManager:getCurScene():addChild(layer)
    -- end)
    
    -- local knightIdList = {}
    -- --极品为在 knight_pack_info 中id为4
    -- local packInfo = knight_pack_info.get(showId)
    -- for i=1,20 do 
    --     local key = string.format("knight%d_id",i)
    --     if packInfo[key] > 0 then
    --         knightIdList[#knightIdList+1]= packInfo[key]
    --     end
    -- end
    
    -- if #knightIdList == 0 then
    --     return
    -- end
    -- local pageViewPanel = self:getPanelByName("Panel_pageview")
    -- local ShopPageViewKnightItem = require("app.scenes.shop.ShopPageViewKnightItem")
    -- local leftNode = ShopPageViewKnightItem:new(self)
    -- local middleNode = ShopPageViewKnightItem:new(self)
    -- local rightNode = ShopPageViewKnightItem:new(self)
    -- self._AutoScrollView = require("app.scenes.common.AutoScrollView").create(pageViewPanel:getContentSize(),knightIdList,leftNode,rightNode,middleNode)
    -- self:addMask()
end

function ShopDropKnightBaseLayer:_doInitScrollView( ... )
    require("app.cfg.knight_pack_info")
    local len = knight_pack_info.getLength()
    --显示类型
    local showId = 0
    for i=1,len do
        local item = knight_pack_info.indexOf(i)
        if item.knight_show == self._showType then
            showId = item.id
        end
    end
    if showId == 0 then
        --没有找到,表出问题了
        return
    end
    --招将预览
    self:registerBtnClickEvent("Button_review",function() 
        print("---self._showType = " .. self._showType)
        local layer = require("app.scenes.shop.ShopDropKnightReview").create(self._showType)
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    
    local knightIdList = {}
    --极品为在 knight_pack_info 中id为4
    local packInfo = knight_pack_info.get(showId)
    for i=1,20 do 
        local key = string.format("knight%d_id",i)
        if packInfo[key] > 0 then
            knightIdList[#knightIdList+1]= packInfo[key]
        end
    end
    
    if #knightIdList == 0 then
        return
    end
    local pageViewPanel = self:getPanelByName("Panel_pageview")
    local ShopPageViewKnightItem = require("app.scenes.shop.ShopPageViewKnightItem")
    local leftNode = ShopPageViewKnightItem:new(self)
    local middleNode = ShopPageViewKnightItem:new(self)
    local rightNode = ShopPageViewKnightItem:new(self)
    self._AutoScrollView = require("app.scenes.common.AutoScrollView").create(pageViewPanel:getContentSize(),knightIdList,leftNode,rightNode,middleNode)
    self:addMask()
end

function ShopDropKnightBaseLayer:addMask()
    -- local size = CCSizeMake(self._AutoScrollView:getWidth(),self._AutoScrollView:getHeight())
    local maskNode = CCDrawNode:create()
    local pointarr1 = CCPointArray:create(4)
    pointarr1:add(ccp(0, 0))
    pointarr1:add(ccp(self._AutoScrollView:getWidth(), 0))
    pointarr1:add(ccp(self._AutoScrollView:getWidth(), self._AutoScrollView:getHeight()))
    pointarr1:add(ccp(0, self._AutoScrollView:getHeight()))
    
    if device.platform == "wp8" or device.platform == "winrt" then
        G_WP8.drawPolygon(maskNode, pointarr1, 4, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(0.1, 1, 0.1, 1))
    else
        maskNode:drawPolygon(pointarr1:fetchPoints(), 4, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(0.1, 1, 0.1, 1) )
    end

    self._clippingNode = CCClippingNode:create()
    self._clippingNode:setStencil(maskNode)
    local pageViewPanel = self:getPanelByName("Panel_pageview")
    self._clippingNode:setPosition(ccp(0,0)) 
    pageViewPanel:addNode(self._clippingNode)

    self._clippingNode:addChild(self._AutoScrollView)
end


function ShopDropKnightBaseLayer:setPageView(pack_type)
    --极品为在 knight_pack_info 中id为4 ,良品为3
    if pack_type ~= 3 and pack_type ~= 4 then
        return
    end
    --招将预览
    self:registerBtnClickEvent("Button_review",function() 
        if pack_type == 3 then 
            local layer = require("app.scenes.shop.ShopDropKnightReview").create(1)
            uf_sceneManager:getCurScene():addChild(layer)
        else
            local layer = require("app.scenes.shop.ShopDropKnightReview").create(2)
            uf_sceneManager:getCurScene():addChild(layer)
        end
    end)

    require("app.cfg.knight_pack_info")
    local knightIdList = {}
    --极品为在 knight_pack_info 中id为4
    local packInfo = knight_pack_info.get(pack_type)
    for i=1,20 do 
        local key = string.format("knight%d_id",i)
        if packInfo[key] > 0 then
            knightIdList[#knightIdList+1]= packInfo[key]
        end
    end
    
    if #knightIdList == 0 then
        return
    end
    local ShopPageViewKnightItem = require("app.scenes.shop.ShopPageViewKnightItem")
    --滑动条
    local pageViewPanel = self:getPanelByName("Panel_pageview")
    self.knightPageView = CCSPageViewEx:createWithLayout(pageViewPanel)
--    local _pack_type = pack_type
    self.knightPageView:setPageCreateHandler(function ( page, index )
        local cell = ShopPageViewKnightItem:new()
        cell:updatePage(knightIdList[index+1])
    	return cell
    end)
    self.knightPageView:setPageTurnHandler(function ( page, index, cell )
        cell:updatePage(knightIdList[index+1])
    end)
    
    --固定是20
    self.knightPageView:showPageWithCount(#knightIdList)
end

function ShopDropKnightBaseLayer:_initButtonEvent()
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    --招一次
    self:registerBtnClickEvent("Button_onetime",function()
        local CheckFunc = require("app.scenes.common.CheckFunc")
        local scenePack = G_GlobalFunc.sceneToPack("app.scenes.shop.ShopScene", {})
        if CheckFunc.checkKnightFull(scenePack) then
            return
        end
        if self._oneTimeFunc ~= nil then
            self:_oneTimeFunc()
        end
    end)
    
    --招多次
    self:registerBtnClickEvent("Button_moretime",function()
        if self._moreTimeFunc ~= nil then
            self:_moreTimeFunc()
        end
    end)
    
end


--检查包裹是否满了
function ShopDropKnightBaseLayer:checkBagMoreTime(num)
    local CheckFunc = require("app.scenes.common.CheckFunc")
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.shop.ShopScene", {})
    if CheckFunc.checkDiffByType(G_Goods.TYPE_KNIGHT,num,scenePack) then 
        return true
    end
    return false
end


--当本次是免费招将时,只显示招一次 按钮,并移到中间
-- function ShopDropKnightBaseLayer:removeOneButtonToCenter(freeText)
-- isZhanJiang = true 战将
-- isZhanJiang = false 神将
function ShopDropKnightBaseLayer:removeOneButtonToCenter(isZhanJiang)
    local oneButton = self:getButtonByName("Button_onetime")
    local oneButtonY = oneButton:getPositionY()
    --移到中间
    local centerX = oneButton:getParent():getContentSize().width/2
    oneButton:setPosition(ccp(centerX,oneButtonY))

    local freeLabel = self:getLabelByName("Label_free")
    self:showWidgetByName("Button_moretime",false)
    self:showWidgetByName("Panel_moretime",false)
    if isZhanJiang == true then
        local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
        self._isFree = leftTime < 0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3
        if self._isFree == true then
            freeLabel:setText(G_lang:get("LANG_DROP_KNIGHT_FREE_TIME",{time=3-G_Me.shopData.dropKnightInfo.lp_free_count}))
            freeLabel:setVisible(true)
            self:showWidgetByName("Panel_onetime",false)
            freeLabel:setPosition(ccp(centerX,freeLabel:getPositionY()))
        else
            freeLabel:setVisible(false)
            self:showWidgetByName("Panel_onetime",true)
            local panel = self:getWidgetByName("Panel_onetime")
            local size = panel:getContentSize()
            panel:setPosition(ccp(centerX-size.width/2,freeLabel:getPositionY()-size.height/2))
        end
    else
        local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
        self._isFree = leftTime < 0 
        if self._isFree == true then
            freeLabel:setText(G_lang:get("LANG_DROP_KNIGHT_FREE"))
            freeLabel:setVisible(true)
            self:showWidgetByName("Panel_onetime",false)
            freeLabel:setPosition(ccp(centerX,freeLabel:getPositionY()))
        else
            freeLabel:setVisible(false)
            self:showWidgetByName("Panel_onetime",true)
            local panel = self:getWidgetByName("Panel_onetime")
            local size = panel:getContentSize()
            panel:setPosition(ccp(centerX-size.width/2,freeLabel:getPositionY()-size.height/2))
        end
    end

end



function ShopDropKnightBaseLayer:onLayerUnload()
    if self._AutoScrollView ~= nil then
        self._AutoScrollView:stop()
    end
end

function ShopDropKnightBaseLayer:onLayerEnter(...)
    
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_bg"), "smoving_bounce", function ( ... )
    end)
    self:closeAtReturn(true)
end

return ShopDropKnightBaseLayer


