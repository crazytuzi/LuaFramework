local ShopDropMainLayer = class("ShopDropMainLayer",UFCCSNormalLayer)
local BagConst = require("app.const.BagConst")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

ShopDropMainLayer.GOOD_KNIGHT_TEN_TIMES_MONEY = 20000
ShopDropMainLayer.GODLY_KNIGHT_TWENTY_TIMES_MONEY = 200000
ShopDropMainLayer.GODLY_KNIGHT_TEN_TIMES_MONEY = 100000

function ShopDropMainLayer.create()
	return ShopDropMainLayer.new("ui_layout/shop_ShopDropMainLayer.json")
 --    if G_Me.userData.vip < 8 then
	-- else
	-- 	return ShopDropMainLayer.new("ui_layout/shop_ShopDropMainLayer.json")
	-- end
end

local ZhenYingDropButton = require("app.scenes.shop.ZhenYingDropButton")

function ShopDropMainLayer:ctor(...)
    self._zhenyingButtonList = {}

	self.super.ctor(self,...)
	self:_initTextStroke()
	self._timerHandler = G_GlobalFunc.addTimer(1, function()
        if self and self._initDropKnightStatus then
	       self:_initDropKnightStatus()
        end
        --刷新阵营抽将button
        if self and self._refreshZhenYingKnightBtn then
            self:_refreshZhenYingKnightBtn()
        end
	end)

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if  IS_HEXIE_VERSION or appstoreVersion then
        local btn = self:getButtonByName("Button_liangpin")
        if btn then 
            btn:loadTextureNormal("ui/shop/knight_drop/liangpin_hexie.png", UI_TEX_TYPE_LOCAL)
        end
    end
	--注册抽卡按钮事件
	self:_initDropButtons()
	self:_initDropKnightStatus()
	self:_initActivityWidgets()
end

--[[每个item的高度为269]]
function ShopDropMainLayer:_initScrollView()
    --scrollview上的控件数量
    local widgetNum = 0
    local scrollview = self:getScrollViewByName("ScrollView_01")
    local size = scrollview:getContentSize()
    local btn = self:getButtonByName("Button_liangpin")
    local HEIGHT = 269
    local WIDTH = 607
    local paddingBottom = 70 
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    -- 40级预览
    if G_Me.userData.level >= 40 then
        print("G_Me.shopData.dropKnightInfo.zy_cycle = " .. G_Me.shopData.dropKnightInfo.zy_cycle)
        self._zhenyingButtonList[1] = ZhenYingDropButton.new(math.ceil((G_Me.shopData.dropKnightInfo.zy_cycle+1)/2))
        local x = (640-WIDTH)/2
        local y = paddingBottom
        self._zhenyingButtonList[1]:setPositionX(x)
        self._zhenyingButtonList[1]:setPositionY(y)
        scrollview:addChild(self._zhenyingButtonList[1])
        --方便扩展，保留
        -- for i=1,4 do
        --     local x = (640-WIDTH)/2
        --     -- local x = 0
        --     local y = (i-1)*HEIGHT+paddingBottom
        -- end 
        widgetNum = widgetNum + 1
    end
    local widgetList = {
        self:getButtonByName("Button_liangpin"),
        self:getButtonByName("Button_jipin"),
    }
    if G_Me.userData.vip < 8 then
        widgetNum = widgetNum + 2
        self:showWidgetByName("Button_jipin20",false)
    else
        widgetNum = widgetNum + 3
        self:showWidgetByName("Button_jipin20",true)
        table.insert(widgetList,self:getButtonByName("Button_jipin20"))
    end

    local scrollviewHeight =  widgetNum*HEIGHT+paddingBottom

    --内容高度小于scrollview高度时
    if scrollviewHeight < size.height then
        scrollviewHeight = size.height
    end

    scrollview:setInnerContainerSize(CCSizeMake(size.width,scrollviewHeight))
    --重新定位,从顶部开始放,因为2个item的时候必须这么做
    for i=1,#widgetList do
        local widget = widgetList[i]
        local x = size.width/2
        local y = scrollviewHeight - (i-1/2)*HEIGHT
        widget:setPositionX(x)
        widget:setPositionY(y)
    
        -- 先隐藏抽将按钮，以防刚进入时画面出现闪动
        widget:setVisible(false)        
    end
    -- 先隐藏抽将按钮，以防刚进入时画面出现闪动
    for i = 1, #self._zhenyingButtonList do 
        self._zhenyingButtonList[i]:setVisible(false)
    end
end

function ShopDropMainLayer:onLayerEnter()
    self:_initScrollView()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_KNIGHT_INFO, self._getShopDropKnightInfo, self) 
    --良品抽卡结果，需要刷新一些控件
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, self._getDropGoodKnightResult, self) 
    --极品抽卡结果，需要刷新一些控件
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, self._getDropGodlyKnightResult, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT_20, self._getDropGodlyKnightResult20, self)

    --阵营抽将
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_ZHEN_YING, self._getDropZhenYingKnightResult, self)


    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagDataChange, self)
    --角色信息发生变化了
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._onRoleInfoChange, self)

    --第一次获取抽卡信息
    if not G_Me.shopData:checkDropInfo() then
        G_HandlersManager.shopHandler:sendDropKnightInfo()  
    else
        self:_getShopDropKnightInfo()
    end
    self:callAfterFrameCount(1, function ( ... )
        self:playEnterAnimation()
    end)

    -- 限时抽将
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) then
        G_HandlersManager.themeDropHandler:sendThemeDropZY()
    end
end

function ShopDropMainLayer:playEnterAnimation( ... )

    self:getWidgetByName("Button_liangpin"):setVisible(true)
    self:getWidgetByName("Button_jipin"):setVisible(true)
    -- 先隐藏抽将按钮，以防刚进入时画面出现闪动
    for i = 1, #self._zhenyingButtonList do 
        self._zhenyingButtonList[i]:setVisible(true)
    end

    if G_Me.userData.vip < 8 then
        G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_liangpin"),self._zhenyingButtonList[1],self._zhenyingButtonList[3]}, true, 0.2, 2, 50, nil)
        G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_jipin"),self._zhenyingButtonList[2],self._zhenyingButtonList[4]}, false, 0.2, 2, 50, nil)  
    else
        self:getWidgetByName("Button_jipin20"):setVisible(true)
        G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_liangpin"),self:getWidgetByName("Button_jipin20"),self._zhenyingButtonList[2],self._zhenyingButtonList[4]}, true, 0.2, 2, 50, nil)
        G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_jipin"),self._zhenyingButtonList[1],self._zhenyingButtonList[3]}, false, 0.2, 2, 50, nil)  
    end
end

--设置描边
function ShopDropMainLayer:_initTextStroke()
    self:getLabelByName("Label_lpFree"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_freeTime"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_17"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_status_no_free"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_jpTime"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_17_01"):createStroke(Colors.strokeBrown,1)  
    self:getLabelByName("Label_jpFree"):createStroke(Colors.strokeBrown,1)
    ------------------------------------------------------------------
    
    self:getLabelByName("Label_23"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_23_1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_21"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_21_1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_18"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_18_1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_shenjiangnum"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_liangjiangnum"):createStroke(Colors.strokeBrown,1)

    --vip>8的时候
    if self:getLabelByName("Label_21_2") ~= nil then
        self:getLabelByName("Label_21_2"):createStroke(Colors.strokeBrown,1)
        self:getLabelByName("Label_21_3"):createStroke(Colors.strokeBrown,1)
    end
end

function ShopDropMainLayer:_initActivityWidgets()
    --Label_liangjiangnum 良将令个数
    local Label_liangjiangnum = self:getLabelByName("Label_liangjiangnum")
    Label_liangjiangnum:setText(G_Me.bagData:getGoodKnightTokenCount())
    local Label_shenjiangnum = self:getLabelByName("Label_shenjiangnum")

    local godlyTokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    Label_shenjiangnum:setText(godlyTokenCount)
    if godlyTokenCount == 0 then
        self:getImageViewByName("Image_22_1"):loadTexture("icon_mini_yuanbao.png",UI_TEX_TYPE_PLIST)
        --判断是否活动期间
        local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
        local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME
        if isDiscount then
            price = math.ceil(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME * discount / 1000)
        end
        self:getLabelByName("Label_23_1"):setText(price)

        if G_Me.userData.gold < BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME then
            self:getLabelByName("Label_23_1"):setColor(Colors.darkColors.TIPS_01)
        else
            self:getLabelByName("Label_23_1"):setColor(Colors.darkColors.DESCRIPTION)
        end
    else
        self:getImageViewByName("Image_22_1"):loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)
        self:getLabelByName("Label_23_1"):setText("x 1")
    end

    local goodTokenCount = G_Me.bagData:getGoodKnightTokenCount()
    if goodTokenCount == 0 then
        self:getLabelByName("Label_23"):setColor(Colors.darkColors.TIPS_01)
    else
        self:getLabelByName("Label_23"):setColor(Colors.darkColors.DESCRIPTION)
    end

    local image20 = self:getImageViewByName("Image_22_3")
    local label20 = self:getLabelByName("Label_21_3")
    if image20 ~= nil then
        if godlyTokenCount >= 20 then
            image20:loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)
            label20:setText("x 20")
        else
            image20:loadTexture("icon_mini_yuanbao.png",UI_TEX_TYPE_PLIST)
            local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_20_TIME
            local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
            if isDiscount then
                price = math.ceil(price *discount / 1000)
            end
            label20:setText(price)
            if G_Me.userData.gold < price then
                self:getLabelByName("Label_21_3"):setColor(Colors.darkColors.TIPS_01)
            else
                self:getLabelByName("Label_21_3"):setColor(Colors.darkColors.DESCRIPTION)
            end
        end
    end



end


--抽卡按钮事件
function ShopDropMainLayer:_initDropButtons()
    --神将抽卡
    self:registerBtnClickEvent("Button_jipin",function() 
        if G_Me.shopData.dropKnightInfo["jp_free_time"] == nil then
            return
        end
        local layer = require("app.scenes.shop.ShopDropGodlyKnightLayer").new()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    
    --良品抽卡
    self:registerBtnClickEvent("Button_liangpin",function() 
        local layer = require("app.scenes.shop.ShopDropGoodKnightLayer").new()
        uf_sceneManager:getCurScene():addChild(layer)
    end)

    --20连抽
    self:registerBtnClickEvent("Button_jipin20",function() 
        local layer = require("app.scenes.shop.ShopDropGodlyKnight20Layer").new()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
end

function ShopDropMainLayer:onLayerUnload()
	
end

function ShopDropMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._timerHandler ~= nil then
        G_GlobalFunc.removeTimer(self._timerHandler)
    end
end


--抽卡底部的状态
function ShopDropMainLayer:_initDropKnightStatus()
    if not G_Me.shopData:checkDropInfo() then
        return
    end
    --极品
    local JPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
    local JPTokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    local LPTokenCount = G_Me.bagData:getGoodKnightTokenCount()
    local LPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
    self:showWidgetByName("Image_tips01",(LPLeftTime<=0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3) or LPTokenCount > 0 )
    self:showWidgetByName("Image_tips02",JPLeftTime<=0 or JPTokenCount > 0)
    if self and self._setLPRichText then
        self:_setLPRichText()
    end
    if self and self._setJPRichText then
        self:_setJPRichText()
    end
end


--[[
    1  免费
    2  xx:xx:xx后免费
    3  免费次数用完
]]
function ShopDropMainLayer:_showLPWidgetStatus(status)
    self:showWidgetByName("Label_lpFree",status == 1)
    self:showWidgetByName("Panel_lpFreeTime",status == 2)
    self:showWidgetByName("Label_status_no_free",status == 3)
    --不为1的时候显示消耗
    self:showWidgetByName("Panel_xiaohao",status ~= 1)
end

--[[
    1  免费
    2  xx:xx:xx后免费
]]
function ShopDropMainLayer:_showJPWidgetStatus(status)
    self:showWidgetByName("Label_jpFree",status == 1)
    self:showWidgetByName("Panel_jpFreeTime",status == 2)
    self:showWidgetByName("Panel_jpxiaohao",status == 2)
end

function ShopDropMainLayer:_setLPRichText()
    --极品和良品倒计时label
    local LabelLiangpintime = self:getLabelByName("Label_liangpintime")
    local labelLiangpinLeftTime = self:getLabelByName("Label_leftTime")
    
    --已经使用了3次免费次数

    if G_Me.shopData.dropKnightInfo.lp_free_count >= 3 then
        self:_showLPWidgetStatus(3)
        self:getLabelByName("Label_status_no_free"):setText(G_lang:get("LANG_DROP_KNIGHT_NO_FREE_TIME"))
    else
        local leftSecond = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
        local text = nil
        if leftSecond >0 then
            self:_showLPWidgetStatus(2)
            local time = G_ServerTime:getLeftSecondsString(G_Me.shopData.dropKnightInfo.lp_free_time)
            self:getLabelByName("Label_freeTime"):setText(time)
        else
            self:_showLPWidgetStatus(1)
            self:getLabelByName("Label_lpFree"):setText(string.format("本次免费(%s/3)",3-G_Me.shopData.dropKnightInfo.lp_free_count))
            local _time = 3-G_Me.shopData.dropKnightInfo.lp_free_count
            self:getLabelByName("Label_lpFree"):setText(G_lang:get("LANG_DROP_KNIGHT_FREE_TIME",{time=_time}))
        end
    end
end


function ShopDropMainLayer:_setJPRichText()
    local leftSecond = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
    if leftSecond >0 then
        self:_showJPWidgetStatus(2)
        self:getLabelByName("Label_jpTime"):setText(G_ServerTime:getLeftSecondsString(G_Me.shopData.dropKnightInfo.jp_free_time))       
    else
        self:_showJPWidgetStatus(1)
        self:getLabelByName("Label_jpFree"):setText(G_lang:get("LANG_DROP_KNIGHT_FREE"))
    end
end


function ShopDropMainLayer:_bagDataChange(data)
    if self and self._initActivityWidgets then
        self:_initActivityWidgets()
    end
end

function  ShopDropMainLayer:_onRoleInfoChange( ... )
    if self and self._initActivityWidgets then
        self:_initActivityWidgets()
    end
end


function ShopDropMainLayer:_getShopDropKnightInfo(data)
    if not self or not self.showWidgetByName then
        return
    end
    --判断是否已经使用首次抽极品
    if G_Me.shopData.dropKnightInfo.jp_recruited_times == 1 then
        --显示首次招募必得五星
        self:showWidgetByName("ImageView_shoushua",true)
    else
        self:showWidgetByName("ImageView_shoushua",false)
    end
end

--良品抽卡结果,
function ShopDropMainLayer:_getDropGoodKnightResult(data)
    --加上CD时间
    if data.ret == 1 then
        
        if #data.knight_base_id > 1 then
            if self and self._showDropTenKnights then
                self:_showDropTenKnights(ShopDropMainLayer.GOOD_KNIGHT_TEN_TIMES_MONEY, data.knight_base_id)
            end
        else
            if self and self._showOneKnightDrop then
                self:_showOneKnightDrop(1,data.knight_base_id[1])
            end
        end
    end
end
function ShopDropMainLayer:_showDropTenKnights(buyMoneyNum, knights)
    local ManyKnightDrop = require "app.scenes.shop.animation.ManyKnightDrop"
    ManyKnightDrop.show(buyMoneyNum, knights)
end

--极品抽卡结果
function ShopDropMainLayer:_getDropGodlyKnightResult(data)
    if not self and not self.getImageViewByName then
        return
    end
    local widget = self:getImageViewByName("ImageView_shoushua")
    --说明已经不在此场景了
    if not widget then
        return
    end
    --加上CD时间
    if data.ret == 1 then
        if G_Me.shopData.dropKnightInfo.jp_recruited_times == 1 then
            self:getImageViewByName("ImageView_shoushua"):setVisible(true)
        else
            self:getImageViewByName("ImageView_shoushua"):setVisible(false)
        end
        self:_initActivityWidgets()
        if #data.knight_base_id > 1 then
            self:_showDropTenKnights(ShopDropMainLayer.GODLY_KNIGHT_TEN_TIMES_MONEY, data.knight_base_id)
        else
            self:_showOneKnightDrop(2,data.knight_base_id[1])
        end
    end
end

--极品20连抽结果
function ShopDropMainLayer:_getDropGodlyKnightResult20(data)
    if not self and not self.getImageViewByName then
        return
    end
    local widget = self:getImageViewByName("ImageView_shoushua")
    --说明已经不在此场景了
    if not widget then
        return
    end
    --加上CD时间
    if data.ret == 1 then
        if G_Me.shopData.dropKnightInfo.jp_recruited_times == 1 then
            self:getImageViewByName("ImageView_shoushua"):setVisible(true)
        else
            self:getImageViewByName("ImageView_shoushua"):setVisible(false)
        end
        self:_initActivityWidgets()
        -- self:_showDropTenKnights(data.knight_base_id)
        local knights01 = {}
        local knights02 = {}
        --排序,将最后2个插入到11和12位,服务器略坑,避免出现满屏全蓝将
        if data.knight_base_id ~= nil and #data.knight_base_id == 24 then
            local tmp01 = data.knight_base_id[23]
            local tmp02 = data.knight_base_id[24]
            table.remove(data.knight_base_id,24)
            table.remove(data.knight_base_id,23)
            table.insert(data.knight_base_id,11,tmp01)
            table.insert(data.knight_base_id,12,tmp02)
            -- data.knight_base_id[23] = data.knight_base_id[11]
            -- data.knight_base_id[11] = tmp01
            -- data.knight_base_id[24] = data.knight_base_id[12]
            -- data.knight_base_id[12] = tmp02
        end
        for i,v in ipairs(data.knight_base_id)do
            if i<=12 then
                table.insert(knights01,v)
            else
                table.insert(knights02,v)
            end
        end        
        local ManyKnightDrop = require "app.scenes.shop.animation.ManyKnightDrop"
        ManyKnightDrop.show(ShopDropMainLayer.GODLY_KNIGHT_TWENTY_TIMES_MONEY, knights01,function()
            local ManyKnightDrop = require "app.scenes.shop.animation.ManyKnightDrop"
            ManyKnightDrop.show(ShopDropMainLayer.GODLY_KNIGHT_TWENTY_TIMES_MONEY, knights02)
            end)
    end
end

function ShopDropMainLayer:_getDropZhenYingKnightResult(data)
    if data and data.ret == 1 then
        if self and self._showOneKnightDrop then
            self:_showOneKnightDrop(4,data.knight_base_id[1])
        end
        self:_refreshZhenYingKnightBtn()
    end
end

function ShopDropMainLayer:_refreshZhenYingKnightBtn()
    if self and self._zhenyingButtonList and #self._zhenyingButtonList > 0 then
        for i,v in ipairs(self._zhenyingButtonList) do
            if v and v.updateButton then
                --刷新阵营抽将按钮
                v:updateButton()
            end
        end
    end
end

function ShopDropMainLayer:_showOneKnightDrop(_type,knightId)
    local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
    OneKnightDrop.show(_type, knightId, function(again, TYPE)  
    if again then
            if TYPE == 1 then   --良品
                require("app.scenes.shop.ShopTools").sendGoodKnightDrop()
            elseif TYPE == 2 then--极品
                require("app.scenes.shop.ShopTools").sendGodlyKnightDrop()
            elseif TYPE == 4 then
                require("app.scenes.shop.ShopTools").sendZhenYingKnightDrop()
            end
    end
    end)
end

return ShopDropMainLayer