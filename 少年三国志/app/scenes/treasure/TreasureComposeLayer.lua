

local TreasureComposeLayer = class("TreasureComposeLayer", UFCCSNormalLayer)
local CheckFunc = require("app.scenes.common.CheckFunc")

function TreasureComposeLayer.create(functionValue, chapterId, scenePack, ...)
    return require("app.scenes.treasure.TreasureComposeLayer").new("ui_layout/treasure_TreasureCompose.json", nil, functionValue,chapterId, scenePack, ...)
end
require("app.cfg.treasure_info")
require("app.cfg.treasure_compose_info")
require("app.cfg.treasure_fragment_info")
require("app.cfg.treasure_fragment_smelt_info")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")
local MergeEquipment = require("app.data.MergeEquipment")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
local TreasureComposeItem = require("app.scenes.treasure.cell.TreasureComposeItem")
local TreasureItem = require("app.scenes.treasure.cell.TreasureComposeTreasureItem")
local ItemConst = require("app.const.ItemConst")
local EffectNode = require "app.common.effects.EffectNode"
local TreasureSelectLayer = require("app.scenes.recycle.RecycleSelectTreasureRebornLayer")

function TreasureComposeLayer:ctor(jsonFile, fun, functionValue, chapterId, scenePack, ...)
    self._isFirstTimeEnter  = true          -- 是否第一次进入界面
    self._currentComposeId  = functionValue -- 外部传进来，指定要合成的宝物ID
    self._currentSmeltId    = chapterId     -- 外部传进来，熔炼界面显示的ID（1=孟德新书2=鬼谷子3=猛虎印4=麒麟印）
    self._curSelIndex       = 1             -- 当前选中的合成项的索引

    self._composeList       = {}            -- 可合成的info列表（composeId为key，compose_info为value）
    self._composeListIndex  = {}            -- 排过序的合成info的索引列表（self._composeList里的key）

    self._panelCompose      = self:getPanelByName("Panel_Compose")  -- 合成子界面panel
    self._panelSmelt        = self:getPanelByName("Panel_Smelt")    -- 熔炼子界面panel
    self._pageView          = nil                                   -- 可合成的宝物信息pageView
    self._scrollView        = nil                                   -- 可合成的宝物图标scrollView
    self._scrollViewButtons = {}                                    -- scrollView里的图标按钮列表

    if type(self._currentSmeltId) == "number" and self._currentSmeltId ~= 0 then
        self._currentComposeId = nil
    end

    self._animationFlag = false
    if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
        self._animationFlag = true
    end
    
    self.super.ctor(self,...)
    G_GlobalFunc.savePack(self, scenePack)
end

function TreasureComposeLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
    self:setClickEnabled(false)

    -- 初始化合成信息
    self:_initComposeList()

    -- 初始化pageView和scrollView
    self:_initWidgets()

    -- 初始化描边
    self:_createStroke()

    -- 初始化按钮点击事件
    self:_initBtnEvents()

    -- 刷新一次免战相关的UI
    self:_onRefreshMianZhanTime()

    -- 是否需要显示熔炼相关的UI
    self:_checkShowSmelt()

    -- 是否需要显示一键夺宝
    local canPreviewModule = G_moduleUnlock:canPreviewModule(FunctionLevelConst.ONE_KEY_ROB_TREASURE)
    self:showWidgetByName("Button_RobAll", canPreviewModule)
end

function TreasureComposeLayer:onLayerEnter()
    if self._currentComposeId ~= nil then
        -- 从抢夺界面返回，回到之前所选的宝物
        self:_showScrollViewSelectedAndTips(self._pageView:getCurPageIndex()+1, false, true)
    elseif self:_jumpToFirstComposable() then
        -- 如果有可合成的宝物，自动跳转至该宝物处
        -- 在上述函数中已经跳了
    else
        -- 正常进来，UI飞入
        self:_showScrollViewSelectedAndTips(1)
        GlobalFunc.flyIntoScreenLR({self._scrollView}, false, 0.2, 2, 100,function()
            self:setClickEnabled(true)
        end)
    end

    if self._currentSmeltId ~= nil and self._currentSmeltId ~= 0 then
        self:_showSmeltUI()
    end

    -- 开启免战时间Timer
    self._timerHandler = G_GlobalFunc.addTimer(1, function()
        self:_onRefreshMianZhanTime()    
    end)

    -- register event listeners
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_ROB_RESULT, self._onRobResult, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_COMPOSE, self._onCompose, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._useBagItem, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_SMELT, self._onRcvSmelt, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_COMPOSE_BTN_ANIMATION, self._playAnimation, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_TREASURE_FRAGMENT_SUCCESS, self._playFragmentAnimation, self)

    self._isFirstTimeEnter = false
end

function TreasureComposeLayer:onLayerExit()
    local pages = self._pageView:getPages()
    if pages ~= nil then
        for i=1,pages:count() do
            if pages:objectAtIndex(i-1) ~= nil then
                pages:objectAtIndex(i-1):clearAll()
            end
        end
    end

    if self._timerHandler ~= nil then
        G_GlobalFunc.removeTimer(self._timerHandler)
    end

    uf_eventManager:removeListenerWithTarget(self)
end

function TreasureComposeLayer:adapterLayer(...)
    self:adapterWidgetHeight("Panel_Compose","Panel_head","",-30,0)
    self:adapterWidgetHeight("Panel_Smelt","Panel_head","",40,0)
end

function TreasureComposeLayer:__prepareDataForGuide__( ... )
    return self:getFragmentIconRectForGuide()
end

--该类型所有 宝物
function TreasureComposeLayer:_initComposeList()
    self._composeList,self._composeListIndex = G_Me.bagData:getTreasureComposeList()
end

function TreasureComposeLayer:_initBtnEvents()
    self:registerBtnClickEvent("Button_back",function() 
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_mianzhan",function() 
        local layer = require("app.scenes.treasure.TreasureMianZhanLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)

    self:registerBtnClickEvent("Button_RobAll", function()
        local isUnlock = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ONE_KEY_ROB_TREASURE)
        if isUnlock then
            local fragmentEnough = self:_checkFragment()
            if fragmentEnough then
                G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_FRAGMENT_ENOUGH"))
            else
                local treasureID = self._composeListIndex[self._curSelIndex]
                require("app.scenes.treasure.TreasureRobAllHint").show(treasureID)
            end
        end
    end)
    
    self:registerBtnClickEvent("Button_compose",function() 
        if not self:_checkFragment() then
            --刷新
            self:_refreshWidgets()

            G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_FRAGMENT_NOT_ENOUGH"))
            return 
        end 
    
        local scenePack = G_GlobalFunc.sceneToPack("app.scenes.treasure.TreasureComposeScene", {})        
        if CheckFunc.checkTreasureFull(scenePack) then
            return
        end

        local canComposeTimes = self:calFragComposeTimes()
        if canComposeTimes >= 2 then
            local index = self._pageView:getCurPageIndex()
            local compose = self._composeList[self._composeListIndex[index+1]]
            local maxNum = G_Me.bagData:getMaxTreasureNum()
            local num = G_Me.bagData.treasureList:getCount()
            require("app.scenes.treasure.TreasureMultiComposeLayer").show(compose, canComposeTimes, maxNum, num, function (  )
                self:setClickEnabled(false)
            end)
        else
            --开始发送合成消息，设置为不可点击，必须等动画播放完
            self:setClickEnabled(false)
            G_HandlersManager.treasureRobHandler:sendComposeTreasure(self:_getCurrentTreasure())
        end
    end)
end

function TreasureComposeLayer:_initWidgets()
    --剩余免战时间
    self:getLabelByName("Label_mianzhanTimeTag"):setText(G_lang:get("LANG_MIANZHAN_LEFT_TIME_TAG"))

    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")

    self:_initPageView()
    self:_initScrollView()

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        if not self._bgEffect then
            local bgImage = self:getImageViewByName("ImageView_bg")
            self._bgEffect = EffectNode.new("effect_duobao", function(event, frameIndex)
                    end)  
            self._bgEffect:setPosition(ccp(0,0))
            bgImage:addNode(self._bgEffect)
            self._bgEffect:play()
        end
    end
end

function TreasureComposeLayer:_initPageView()
    if self._pageView ~= nil then
        self._pageView:removeAllChildrenWithCleanup(true)
        self._pageView = nil
    end
    if self._pageView == nil then
        local panel = self:getPanelByName("Panel_pageView")
        self._pageView = CCSNewPageViewEx:createWithLayout(panel)
        self._pageView:setPageCreateHandler(function ( page, index )
            local cell = TreasureComposeItem.new(self,self._composeListIndex[index+1])
            return cell
        end)
        self._pageView:setPageTurnHandler(function ( page, index, cell )
            self:_showScrollViewSelectedAndTips(index+1)
            --抛出 是否播放合成按钮 呼吸消息
            self:setClickEnabled(true)
            cell:updatePage(nil,self._composeListIndex[index+1])
            -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_COMPOSE_BTN_ANIMATION, nil, false,cell:checkFragmentEnough())
            self:_playAnimation(cell:checkFragmentEnough())

            -- 修改合成按钮上的文字为“一键合成”
            local composeBtnText = self:getImageViewByName("ImageView_618")
            if cell:checkFragmentComposeTwiceEnough() then
                composeBtnText:loadTexture("ui/text/txt-small-btn/yijianhecheng.png", UI_TEX_TYPE_LOCAL)
            else
                composeBtnText:loadTexture("ui/text/txt-middle-btn/m_hecheng.png", UI_TEX_TYPE_LOCAL)
            end

        end)
        self._pageView:setPageUpdateHandler(function ( page, index, cell )
            if index == 0 then 
                cell:updatePage(not self._animationFlag)
                self._animationFlag = true
            else
                cell:updatePage(nil,self._composeListIndex[index+1])
            end
            -- self:_playAnimation(cell:checkFragmentEnough())
        end)
        self._pageView:showPageWithCount(#self._composeListIndex)
    end

    if self._currentComposeId ~= nil and self._isFirstTimeEnter then
        self._curSelIndex = self:_getIndexByTreasureId(self._currentComposeId)
        self._pageView:scrollToPage(self._curSelIndex > 0 and self._curSelIndex-1 or 0)
    end
end

--刷新Scroview
function TreasureComposeLayer:_initScrollView()
    if self._scrollView == nil then
        self._scrollView = self:getScrollViewByName("ScrollView_top")
        -- self._scrollView:setBounceEnabled(false)
    end
    self._scrollView:removeAllChildrenWithCleanup(true)
    self._scrollViewButtons = {}
    local space = 0 --间隙
    local size = self._scrollView:getContentSize()
    local _treasureItemWidth = 0
    for i,v in ipairs(self._composeListIndex) do
        --TreasureComposeTreasureItem:ctor(layer,_id,buttonName,...)
        --buttonName "buttonName_" .. self._composeList[i].id 为了差异性
        self._scrollViewButtons[i] = TreasureItem.new(self._composeList[v].id,"buttonName_" .. self._composeList[v].id)
        _treasureItemWidth = self._scrollViewButtons[i]:getWidth()
        self._scrollViewButtons[i]:setPosition(ccp(_treasureItemWidth*(i-1)+i*space,(size.height-_treasureItemWidth)/2))
        --self:addChild(widget)
        self._scrollView:addChild(self._scrollViewButtons[i])
        self:registerBtnClickEvent(self._scrollViewButtons[i]:getButtonName(),function(widget) 

            -- 如果之前是在熔炼界面，那么切换回来
            if not self._panelCompose:isVisible() then
                self._panelCompose:setVisible(true)
                self._panelSmelt:setVisible(false)
            end

            -- 切换页面
            self._pageView:scrollToPage(i - 1)
            self._curSelIndex = i
        end )
    end
    local _scrollViewWidth = _treasureItemWidth*#self._composeListIndex+space*(#self._composeListIndex+1)
    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

function TreasureComposeLayer:_refreshScrollButtonEvents()
    for i, v in ipairs(self._scrollViewButtons) do
        self:registerBtnClickEvent(self._scrollViewButtons[i]:getButtonName(),function(widget) 
            -- 如果之前是在熔炼界面，那么切换回来
            if not self._panelCompose:isVisible() then
                self._panelCompose:setVisible(true)
                self._panelSmelt:setVisible(false)
            end
            -- 点击事件
            self._pageView:scrollToPage(i - 1)
        end )
    end
end

function TreasureComposeLayer:_playAnimation(isPlay)
    if self._animation== nil then 
        self._animation = self:playAnimation("scaleChange",function() end) 
    end
    if isPlay == true then
        local button = self:getButtonByName("Button_compose")
        if self.effectNode ~= nil then
            self.effectNode:removeFromParentAndCleanup(true)
            self.effectNode = nil
        end
        self.effectNode = EffectNode.new("effect_around2", function(event, frameIndex)
                end)     
        self.effectNode:setScale(1.5) 
        self.effectNode:play()
        local pt = self.effectNode:getPositionInCCPoint()
        self.effectNode:setPosition(ccp(pt.x, pt.y))
        button:addNode(self.effectNode)
        if self._animation then
            self._animation:play()
        end
    else 
        if self._animation then
            self._animation:stop()
        end
        if self.effectNode ~= nil then
            self.effectNode:removeFromParentAndCleanup(true)
            self.effectNode = nil
        end
    end 
end

function TreasureComposeLayer:getCurrentPage( ... )
    if self._pageView == nil then
        return nil
    end
    return self._pageView:getPage(self._pageView:getCurPageIndex())
end


function TreasureComposeLayer:_getShowIndexById(_treasureId)
    for i,v in ipairs(self._composeListIndex) do
        local compose =  treasure_compose_info.get(v)
        if compose.treasure_id == _treasureId then
            return i
        end
    end
    --默认第一个
    return 1
end

--使用免战
function TreasureComposeLayer:_useBagItem(data)
    if data.ret == 1 then
        require("app.cfg.item_info")
        local item = item_info.get(data.id)
        if item then
            G_MovingTip:showMovingTip(item.tips)
        end
    end 
end


function TreasureComposeLayer:_onCompose(data)
    if data.ret == 1 then
        local page = self._pageView:getPage(self._pageView:getCurPageIndex())
        if page == nil then
            return
        end
        local callback = function()
            if self.__EFFECT_FINISH_CALLBACK__ then 
                self.__EFFECT_FINISH_CALLBACK__()
                self.__EFFECT_FINISH_CALLBACK__ = nil
            end

            local treasure = treasure_info.get(data.treasure_id)
            G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_FRAGMENT_COMPOSE_SUCCESS",{name=treasure.name, num=data.num}))
            require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE, treasure.id)
            self:setClickEnabled(true)
            --检查该宝物是否还有碎片
            if CheckFunc.checkTreasureFragmentExist(treasure.id) or treasure.is_basic == 1 then
                local page = self:getCurrentPage()
                if page then
                    page:updatePage()
                    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_COMPOSE_BTN_ANIMATION, nil, false,page:checkFragmentEnough())
                    self:_playAnimation(page:checkFragmentEnough())
                end
                if  self._scrollView ~= nil and self._scrollViewButtons ~= nil and #self._scrollViewButtons ~= 0 then
                    for i,v in ipairs(self._scrollViewButtons) do
                        self._scrollViewButtons[i]:showTips()
                    end
                end
            else
                self:_initComposeList()
                self:_initWidgets()
                self:_showScrollViewSelectedAndTips(1)
            end
        end
        -- 修改合成按钮上的文字为“一键合成”
        local composeBtnText = self:getImageViewByName("ImageView_618")
        if page:checkFragmentComposeTwiceEnough() then
            composeBtnText:loadTexture("ui/text/txt-small-btn/yijianhecheng.png", UI_TEX_TYPE_LOCAL)
        else
            composeBtnText:loadTexture("ui/text/txt-middle-btn/m_hecheng.png", UI_TEX_TYPE_LOCAL)
        end
        page:playFragmentLightAnimation(callback)
    else
        self:setClickEnabled(true)
    end
end

function TreasureComposeLayer:_onRobResult(data)
    --靠,夺宝消息到达,但碎片并未先到
    if data.ret == 1 then
        self:_initComposeList()
        self:_initWidgets()
    end 
end

function TreasureComposeLayer:_playFragmentAnimation(data)
    -- body
    if not self or (not self._pageView) then
        return
    end
    local _index = self._pageView:getCurPageIndex()
    local _page = self._pageView:getPageCell(_index)
    if _page ~= nil then
        _page:playFragmentEffect(data)
    end
end

--检查碎片是否足够合成
function TreasureComposeLayer:_checkFragment()
    local _index = self._pageView:getCurPageIndex()
    local _page = self._pageView:getPage(_index);
    return _page:checkFragmentEnough()
end

-- 检查碎片是否可以合成两次以上
function TreasureComposeLayer:_checkCanComposeTwice(  )
    local _index = self._pageView:getCurPageIndex()
    local _page = self._pageView:getPage(_index);
    return _page:checkFragmentComposeTwiceEnough()
 end 

 function TreasureComposeLayer:calFragComposeTimes(  )
    local _index = self._pageView:getCurPageIndex()
    local _page = self._pageView:getPage(_index);
    return _page:calFragComposeTimes()
 end

--获取当前要合成的宝物
function TreasureComposeLayer:_getCurrentTreasure()
    local index = self._pageView:getCurPageIndex()
    -- local compose = treasure_compose_info.get(self._composeList[index+1])
    local compose = self._composeList[self._composeListIndex[index+1]]
    return compose.treasure_id
end 

function TreasureComposeLayer:_refreshWidgets()
    local _index = self._pageView:getCurPageIndex()
    local _page = self._pageView:getPage(_index)
    _page:updatePage()
    self:_showScrollViewSelectedAndTips(_index+1)
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_COMPOSE_BTN_ANIMATION, nil, false,_page:checkFragmentEnough())
    self:_playAnimation(_page:checkFragmentEnough())
end


--获取id在当前位置的索引
function TreasureComposeLayer:_getIndexById(_id)
    for i,v in ipairs(self._composeListIndex) do
        if v == _id then
            return i
        end
    end
    return -1
end

function TreasureComposeLayer:_getIndexByTreasureId(_id)
    for i,v in ipairs(self._composeListIndex) do
        if self._composeList[v].treasure_id == _id then
            return i
        end
    end
    return -1
end

-- 检查是否要显示熔炼UI
function TreasureComposeLayer:_checkShowSmelt()
    -- 如果到了熔炼预览的等级，显示熔炼按钮
    local canPreviewSmelt = G_moduleUnlock:canPreviewModule(FunctionLevelConst.TREASURE_SMELT)
    local btnSmelt = self:getButtonByName("Button_Smelt_Top")
    btnSmelt:setVisible(canPreviewSmelt)

    -- 并缩短宝物列表
    if canPreviewSmelt then
        local scrollView = self:getScrollViewByName("ScrollView_top")
        local btnSpace = btnSmelt:getSize().width * 1.2
        local oldSize = scrollView:getSize()
        scrollView:setSize(CCSize(oldSize.width - btnSpace, oldSize.height))

        local arrowR = self:getImageViewByName("Image_Arrow_R")
        arrowR:setPositionX(arrowR:getPositionX() - btnSpace)

        -- 注册熔炼按钮的点击事件
        self:registerBtnClickEvent("Button_Smelt_Top", function()
            local isUnlock = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_SMELT)
            if isUnlock then
                self:_showSmeltUI()
            end
        end)
    end
end

--设置是否可以点击了
function TreasureComposeLayer:setClickEnabled(enabled)
    self:setTouchEnabled(enabled)
end

--显示选中的背景
function TreasureComposeLayer:_showScrollViewSelectedAndTips(index, notMove, jump)
    if  self._scrollView== nil or self._scrollViewButtons == nil or #self._scrollViewButtons == 0 then
        return
    end
    for i,v in ipairs(self._scrollViewButtons) do
        self._scrollViewButtons[i]:showBackgroundImage(index == i)
        self._scrollViewButtons[i]:showTips()
    end
    if self._scrollView == nil or notMove then 
        return
    end
    --按钮的宽度
    local buttonWidth = self._scrollViewButtons[index]:getContentSize().width
    local innerContainer = self._scrollView:getInnerContainer()
    --计算选中按钮的位置是否超出了
    local position = innerContainer:convertToWorldSpace(ccp(self._scrollViewButtons[index]:getPosition()))
    --滑动区域宽度
    local scrollAreaWidth = innerContainer:getContentSize().width- self._scrollView:getContentSize().width
    if position.x < 0 then
        --需要位移
        local percent = self._scrollViewButtons[index]:getPositionX()/scrollAreaWidth
        local time = jump and 0 or 0.3
        self._scrollView:scrollToPercentHorizontal(percent*100, time ,false)
        --因为position是世界坐标
    elseif math.abs(position.x) > self._scrollView:getContentSize().width + self._scrollView:getPositionX() - buttonWidth then
        --需要位移
        local percent = (math.abs(self._scrollViewButtons[index]:getPositionX())-self._scrollView:getContentSize().width + buttonWidth)/scrollAreaWidth
        local time = jump and 0 or 0.3
        self._scrollView:scrollToPercentHorizontal(percent*100, time ,false)
    end

    self._curSelIndex = index
end

function TreasureComposeLayer:onBackKeyEvent()
    local packScene = G_GlobalFunc.createPackScene(self)
    if not packScene then 
        packScene = require("app.scenes.mainscene.PlayingScene").new()
    end
    uf_sceneManager:replaceScene(packScene)
    return true
end


--获取新手引导圆盘的坐标
function TreasureComposeLayer:getFragmentIconRectForGuide()
    local page = self:getCurrentPage()
    if not page then
        return CCRectMake(0,0,0,0)
    end
    if not page.getFragmentIconRectForGuide then
        return CCRectMake(0,0,0,0)
    end
    return page:getFragmentIconRectForGuide()
end

--自动跳转到第一个能合成的宝物
function TreasureComposeLayer:_jumpToFirstComposable()
    if self._pageView then
        for i = 1, #self._composeListIndex do
            local item = self._scrollViewButtons[i]
            if item and item:checkFragment() then
                self._pageView:jumpToPage(i - 1)
                self:_showScrollViewSelectedAndTips(i)
                return true
            end
        end
    end

    return false
end

-- 显示熔炼UI
function TreasureComposeLayer:_showSmeltUI()
    if self._panelSmelt:isVisible() then
        return
    end

    self._panelSmelt:setVisible(true)
    self._panelCompose:setVisible(false)

    -- 第一次显示熔炼UI，初始化一些控件
    if not self._smeltUIInited then
        -- 初始化四个红宝碎片
        local numOfKinds = treasure_fragment_smelt_info.getLength()
        local parent = self:getImageViewByName("Image_LeftBoard")
        local parentSize = parent:getSize()
        local gap = parentSize.height / numOfKinds * 0.9
        self._pieceBtns = {}

        for i = 1, numOfKinds do
            -- 底下的圆框
            local btnFrame = Button:create()
            btnFrame:loadTextureNormal("ui/treasure/duobao/suipian_kuang.png")
            btnFrame:setTouchEnabled(true)
            btnFrame:setName("smelt_piece_" .. i)
            btnFrame:setTag(i)
            parent:addChild(btnFrame)
            self._pieceBtns[i] = btnFrame

            local fragmentID = treasure_fragment_smelt_info.get(i).fragment_id
            local fragmentInfo = treasure_fragment_info.get(fragmentID)

            -- 背景底图
            local bg = ImageView:create()
            bg:loadTexture(G_Path.getTreasureFragmentBack(fragmentInfo.quality))
            btnFrame:addChild(bg)

            -- 碎片资源图
            local icon = ImageView:create()
            icon:loadTexture(G_Path.getTreasureFragmentIcon(fragmentInfo.res_id))
            btnFrame:addChild(icon)

            -- 宝物名字
            local treasureInfo = treasure_info.get(fragmentInfo.treasure_id)
            local treasureName = treasureInfo.name
            local labelName = Label:create()
            labelName:setText(treasureName)
            labelName:setFontName("ui/font/FZYiHei-M20S.ttf")
            labelName:setFontSize(24)
            labelName:setColor(Colors.qualityColors[treasureInfo.quality])
            labelName:createStroke(Colors.strokeBrown,1)
            labelName:setPositionY(btnFrame:getPositionY() - btnFrame:getContentSize().height * 0.4)
            btnFrame:addChild(labelName)

            -- 设置一下位置和缩放
            local y = (0.5 + numOfKinds - i - 2) * gap
            btnFrame:setPositionY(y)
            btnFrame:setScale(0.8)

            -- 注册点击事件
            self:registerBtnClickEvent(btnFrame:getName(), handler(self, self._onClickSmeltPiece))
        end

        -- 注册其他按钮的点击事件
        self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickSmeltTarget))
        self:registerBtnClickEvent("Button_Add", handler(self, self._onClickAdd))
        self:registerBtnClickEvent("Button_AutoAdd", handler(self, self._onClickAutoAdd))
        self:registerBtnClickEvent("Button_Smelt", handler(self, self._onClickSmelt))

        -- +号按钮闪烁
        local fadeIn = CCFadeIn:create(0.5)
        local fadeOut = CCFadeOut:create(0.5)
        local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
        self:getWidgetByName("Button_Add"):runAction(CCRepeatForever:create(seq))

        self._smeltUIInited = true
    end

    -- 初始化一些数据
    self._curSmeltInfo = nil
    self._selSmeltMaterial = nil

    -- 默认选中第一个熔炼碎片
    local selectIdx = 1
    if type(self._currentSmeltId) == "number" and self._currentSmeltId ~= 0 then
        selectIdx = self._currentSmeltId
    end
    self:_onClickSmeltPiece(self._pieceBtns[selectIdx])
    self:_showSmeltBtnLight(false)

    -- 隐藏选中宝物图片
    self:showWidgetByName("Image_SelTreasure_Bg", false)
    self:showWidgetByName("Image_SelTreasure", false)
end

-- 点击了某个熔炼碎片
function TreasureComposeLayer:_onClickSmeltPiece(widget)
    local index = widget:getTag()
    local smeltInfo = treasure_fragment_smelt_info.get(index)
    local fragmentID = smeltInfo.fragment_id
    local fragmentInfo = treasure_fragment_info.get(fragmentID)
    local treasureInfo = treasure_info.get(fragmentInfo.treasure_id)

    -- 记录一下当前所选熔炼信息和可合成的宝物ID
    self._curSmeltInfo = smeltInfo
    self._composableTreasure = treasureInfo.id

    -- 更新碎片信息
    local iconPath = G_Path.getTreasureFragmentIcon(fragmentInfo.res_id)
    self:getImageViewByName("Image_Piece"):loadTexture(iconPath)
    self:showTextWithLabel("Label_Piece", fragmentInfo.name)

    -- 更新可合成的宝物信息
    iconPath = G_Path.getTreasureIcon(treasureInfo.res_id)
    self:getImageViewByName("Image_Treasure"):loadTexture(iconPath)

    local treasureDesc = G_lang:get("LANG_AWAKEN_EQUIPMENT_STATE_COMPOSE_DESC") .. treasureInfo.name .. ":"
    self:showTextWithLabel("Label_TreasureDesc", treasureDesc)

    -- 宝物属性
    local _, _, type1, value1 = MergeEquipment.convertAttrTypeAndValue(treasureInfo.strength_type_1, treasureInfo.strength_value_1)
    local _, _, type2, value2 = MergeEquipment.convertAttrTypeAndValue(treasureInfo.strength_type_2, treasureInfo.strength_value_2)
    self:showTextWithLabel("Label_Attribute", type1 .. " +" .. value1 .. "      " .. type2 .. " +" .. value2)

    -- 熔炼价格
    local cost = smeltInfo.smelt_price
    local canPay = G_Me.userData.gold >= cost
    local labelCost = self:getLabelByName("Label_SmeltCost")
    labelCost:setText(tostring(cost))
    labelCost:setColor(canPay and Colors.darkColors.TITLE_01 or Colors.darkColors.TIPS_01)

    -- 设置一下小箭头的位置，然后弹出细节框
    local smallArrow = self:getImageViewByName("Image_SmallArrow")
    local y = widget:getPositionY()
    smallArrow:setPositionY(y)

    local board = self:getImageViewByName("Image_RightBoard")
    board:stopAllActions()
    board:setScale(0)
    board:runAction(CCScaleTo:create(0.2, 1))
end

-- 点击当前熔炼碎片可合成的宝物的图标
function TreasureComposeLayer:_onClickSmeltTarget()
    if self._composableTreasure and self._composableTreasure > 0 then
        DropInfo.show(G_Goods.TYPE_TREASURE, self._composableTreasure)
    end
end

-- 点击添加可熔炼宝物的按钮
function TreasureComposeLayer:_onClickAdd()
    local materialList = G_Me.bagData:getTreasureSmeltMaterials()
    if not materialList or #materialList <= 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_NO_SMELT_MATERIAL"))
    else
        -- 显示宝物选择界面，并传入回调函数
        local layer = nil
        layer = TreasureSelectLayer.create(materialList, nil, function()
            local selected = layer:getSelecteds()
            if selected and #selected > 0 then
                -- 显示宝物图片
                self:showWidgetByName("Image_SelTreasure_Bg", true)
                self:showWidgetByName("Image_SelTreasure", true)
                local treasureInfo = treasure_info.get(selected[1].base_id)
                local iconPath = G_Path.getTreasureIcon(treasureInfo.res_id)
                self:getImageViewByName("Image_SelTreasure"):loadTexture(iconPath)

                -- 记录下所选择的材料
                self._selSmeltMaterial = selected[1]

                -- 在熔炼按钮上显示溜光效果
                self:_showSmeltBtnLight(true)
            end

            -- 移除宝物选择界面
            layer:removeFromParentAndCleanup(true)
        end, true)

        layer:registerBtnClickEvent("Button_back", function() layer:removeFromParentAndCleanup(true) end)
        uf_sceneManager:getCurScene():addChild(layer)
    end
end

-- 点击自动添加可熔炼的宝物
function TreasureComposeLayer:_onClickAutoAdd()
    if self._selSmeltMaterial then return end

    local material = G_Me.bagData:getTreasureSmeltMaterial()
    if not material then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_NO_SMELT_MATERIAL"))
    else
        -- 显示宝物图片
        self:showWidgetByName("Image_SelTreasure_Bg", true)
        self:showWidgetByName("Image_SelTreasure", true)
        local treasureInfo = treasure_info.get(material.base_id)
        local iconPath = G_Path.getTreasureIcon(treasureInfo.res_id)
        self:getImageViewByName("Image_SelTreasure"):loadTexture(iconPath)

        -- 记录下所选择的材料
        self._selSmeltMaterial = material

        -- 在熔炼按钮上显示溜光效果
        self:_showSmeltBtnLight(true)
    end
end

-- 点击熔炼按钮
function TreasureComposeLayer:_onClickSmelt()
    if not self._selSmeltMaterial then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_SELECT_SMELT_MATERIAL"))
    elseif G_Me.userData.gold < self._curSmeltInfo.smelt_price then
        require("app.scenes.shop.GoldNotEnoughDialog").show()
    else
        G_HandlersManager.treasureHandler:sendSmeltTreasure(self._curSmeltInfo.id, {self._selSmeltMaterial.id})
    end
end

-- 显示或隐藏熔炼按钮上的溜光效果
function TreasureComposeLayer:_showSmeltBtnLight(isShow)
    if isShow then
        if not self._smeltBtnLight then
            self._smeltBtnLight = EffectNode.new("effect_around2")
            self._smeltBtnLight:setScale(1.55)
            self._smeltBtnLight:play()
            self:getButtonByName("Button_Smelt"):addNode(self._smeltBtnLight)
        end
        self._smeltBtnLight:setVisible(true)
    elseif self._smeltBtnLight then
        self._smeltBtnLight:setVisible(false)
    end
end

-- 接收到熔炼成功的消息
function TreasureComposeLayer:_onRcvSmelt()
    -- 禁掉触摸
    self:setClickEnabled(false)

    -- 创建特效
    local effect = nil
    effect = EffectNode.new("effect_jingjie", function(event)
        if event == "fullscreen" then
            -- 显示奖励
            local award = { type = G_Goods.TYPE_TREASURE_FRAGMENT, 
                            value = self._curSmeltInfo.fragment_id,
                            size = 1}
            local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({award}, function()
                local curSceneName = G_SceneObserver:getSceneName()
                if not self or curSceneName ~= "TreasureComposeScene" then
                    return
                end
                
                -- 刷新列表
                self:_updateListAfterSmelt()
            end)
            uf_notifyLayer:getModelNode():addChild(layer)

            -- 删掉特效
            effect:removeFromParentAndCleanup(true)
        end
    end)

    -- 设置特效的位置缩放并播放
    local x, y = self:getWidgetByName("Image_SelectFrame"):convertToWorldSpaceXY(0, 0)
    y = y - self:getWidgetByName("Image_SelectFrame"):getContentSize().height / 2
    x, y = self:convertToNodeSpaceXY(x, y)
    effect:setPositionXY(x, y)
    effect:setScale(0.9)
    effect:play()
    self:addChild(effect)
end

-- 熔炼成功后刷新列表
function TreasureComposeLayer:_updateListAfterSmelt()
    local newComposeList, newComposeListIndex = G_Me.bagData:getTreasureComposeList()

    -- 新的合成项是否在原来的列表中
    local isComposeItemExist = false
    local index = 0
    for i, v in ipairs(self._composeListIndex) do
        if v == self._composableTreasure then
            isComposeItemExist = true
            index = i
            break
        end
    end

    local lightDuration = 2
    if isComposeItemExist then
        local callback = function()
            self:setClickEnabled(true)
            self:_showScrollViewSelectedAndTips(index, true)

            local curIndex = self._pageView:getCurPageIndex()
            self._pageView:getPage(curIndex):updatePage(_, self._composeListIndex[curIndex + 1])
            self._pageView:jumpToPage(index - 1)
            self._scrollViewButtons[index]:playLightEffect(lightDuration)
        end

        local isOut, percent = self:_isScrollItemOutside(index)
        if isOut then
            self._scrollView:scrollToPercentHorizontal(100*percent,0.3,false)
            uf_funcCallHelper:callAfterDelayTimeOnObj(self, 0.3, nil, function()
                callback()
            end)
        else
            callback()
        end
    else
        -- 如果是新的合成项，计算插入位置
        local insertPos = self:_getInsertPosOfNewItem(self._composableTreasure)

        local callback = function()
            self:setClickEnabled(true)
            self._pageView:showPageWithCount(#self._composeListIndex)
            self:_refreshScrollButtonEvents()
            self:_showScrollViewSelectedAndTips(insertPos, true)

            local curIndex = self._pageView:getCurPageIndex()
            self._pageView:getPage(curIndex):updatePage(_, self._composeListIndex[curIndex + 1])
            self._pageView:jumpToPage(insertPos - 1)

            self._scrollViewButtons[insertPos]:playLightEffect(lightDuration)
        end

        -- 先将列表滑至可见区域, 再播放插入动画
        local isOut, percent = self:_isScrollItemOutside(insertPos)
        local insertDelay = isOut and 0.3 or 0.01

        if isOut then
            self._scrollView:scrollToPercentHorizontal(100*percent,0.3,false)
        end

        uf_funcCallHelper:callAfterDelayTimeOnObj(self, insertDelay, nil, function()
                self:_insertNewComposeItem(self._composableTreasure, insertPos, callback)
        end)
    end    

    -- 重置一些东西
    self._selSmeltMaterial = nil
    self:showWidgetByName("Image_SelTreasure_Bg", false)
    self:showWidgetByName("Image_SelTreasure", false)
    self:_showSmeltBtnLight(false)
end

function TreasureComposeLayer:_getInsertPosOfNewItem(composeId)
    local insertInfo = treasure_info.get(composeId)    
    for i, v in ipairs(self._composeListIndex) do
        local treasureInfo = treasure_info.get(v)
        if treasureInfo.type ~= 3 then
            if treasureInfo.quality < insertInfo.quality then
                return i
            elseif treasureInfo.quality == insertInfo.quality then
                if treasureInfo.id > insertInfo.id then
                    return i
                end
            end
        end
    end

    return 1
end

-- 在scrollview指定位置插入一个新item
function TreasureComposeLayer:_insertNewComposeItem(composeId, insertPos, callback)
    self._composeList[composeId] = treasure_compose_info.get(composeId)
    table.insert(self._composeListIndex, insertPos, composeId)

    local oldItem = self._scrollViewButtons[insertPos]
    local newItem = TreasureItem.new(composeId, "buttonName_" .. composeId)
    local itemSize = newItem:getContentSize()
    local posX, posY = oldItem:getPosition()
    newItem:setPosition(ccp(posX, posY + itemSize.height))
    newItem:setOpacity(0)
    self._scrollView:addChild(newItem)

    -- 后面的button往后移
    for i = #self._scrollViewButtons, insertPos, -1 do
        self._scrollViewButtons[i + 1] = self._scrollViewButtons[i]
    end
    self._scrollViewButtons[insertPos] = newItem

    for i = insertPos + 1, #self._scrollViewButtons do
        local item = self._scrollViewButtons[i]
        item:runAction(CCMoveBy:create(0.2, ccp(itemSize.width, 0)))
    end

    self._scrollView:setInnerContainerSize(CCSizeMake(itemSize.width * #self._scrollViewButtons, itemSize.height))
    
    local arr1 = CCArray:create()
    arr1:addObject(CCDelayTime:create(0.2))
    arr1:addObject(CCMoveTo:create(0.2, ccp(posX, posY)))

    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(0.2))
    arr2:addObject(CCFadeTo:create(0.2, 255))
    arr2:addObject(CCCallFunc:create(function () if callback then callback() end end))

    newItem:runAction(CCSequence:create(arr1))
    newItem:runAction(CCSequence:create(arr2))
end

function TreasureComposeLayer:_isScrollItemOutside(index)
    local btnWidth = self._scrollViewButtons[index]:getContentSize().width
    local container = self._scrollView:getInnerContainer()
    local pos = container:convertToWorldSpace(ccp(self._scrollViewButtons[index]:getPosition()))
    local scrollWidth = container:getContentSize().width - self._scrollView:getContentSize().width
    if pos.x < 0 then
        local percent = self._scrollViewButtons[index]:getPositionX()/scrollWidth
        return true, percent
    elseif math.abs(pos.x) > self._scrollView:getContentSize().width + self._scrollView:getPositionX() - btnWidth then
        local percent = (math.abs(self._scrollViewButtons[index]:getPositionX())-self._scrollView:getContentSize().width + btnWidth)/scrollWidth
        return true, percent
    end

    return false
end

function TreasureComposeLayer:_createStroke()
    self:getLabelByName("Label_mianzhanTimeTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_mianzhanTime"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_SmeltDesc"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_Piece"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_SmeltCost"):createStroke(Colors.strokeBrown,1)
    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):createStroke(Colors.strokeBrown,1)
end

--刷新免战时间
function TreasureComposeLayer:_onRefreshMianZhanTime()
    if self._mianzhanLabel == nil then
        self._mianzhanLabel = self:getLabelByName("Label_mianzhanTime")
    end 
    if G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time) > 0 then
        self:showWidgetByName("Button_mianzhan",false)
        self:showWidgetByName("Label_mianzhanTimeTag",true)
        self:showWidgetByName("Label_mianzhanTime",true)
        local timeString = G_ServerTime:getLeftSecondsString(G_Me.userData.forbid_battle_time)
        self._mianzhanLabel:setText(timeString)
    else
        self:showWidgetByName("Button_mianzhan",true)
        self:showWidgetByName("Label_mianzhanTimeTag",false)
        self:showWidgetByName("Label_mianzhanTime",false)
    end
end

return TreasureComposeLayer



