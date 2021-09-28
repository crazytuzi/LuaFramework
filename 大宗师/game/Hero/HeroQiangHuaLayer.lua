--


local QIANGHUA_VIEW = 1
local XIAHUN_VIEW = 2

local HeroQiangHuaLayer = class("HeroQiangHuaLayer", function (param)

    return require("utility.ShadeLayer").new()
end)



function HeroQiangHuaLayer:init()


end

function HeroQiangHuaLayer:setUpBottomVisible(isVis)
    self.top:setVisible(isVis)
    self.bottom:setVisible(isVis)
end

function HeroQiangHuaLayer:setUpSilver(num)
    self.top:setSilver(num)
end

function HeroQiangHuaLayer:setUpGoldNum(num)
    self.top:setGodNum(num)
end

function HeroQiangHuaLayer:playQiangHuaAnim(cardBg)
    local effect = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "zhuangbeiqianghua",
        isRetain = false,
        finishFunc = function()

        end})

    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakeqianghua))
    if cardBg then
        local efPos = ResMgr:getPosInScene(cardBg)
        effect:setPosition(efPos)
        display.getRunningScene():addChild(effect,10000)
    end
end

function HeroQiangHuaLayer:updateQiangHua(param)


    self:setUpSilver(self.updateQiangHuaData["2"])

    self._rootnode["xiahunPage"]:setVisible(false)
    self._rootnode["qianghua_btn_node"]:setVisible(true)
    self._rootnode["qianghuaPage"]:setVisible(true)
    self._rootnode["xiahun_btn_node"]:setVisible(false)

    local baseStates = self.updateQiangHuaData["1"]["base"]
    for i = 1,#baseStates do
        self._rootnode["baseState"..i]:setString(baseStates[i])
    end

    local addStates = self.updateQiangHuaData["1"]["add"]
    local cost = self.updateQiangHuaData["1"]["cost"]
    
    self.cost = cost
    local getExp = self.updateQiangHuaData["1"]["curExp"]

    if self.costNumWithShadow == nil then
        self.costNumWithShadow =ui.newTTFLabelWithShadow({
            text = "0",
            size = 22,
            -- color = nameColor,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT 
            })
        self.costNumWithShadow:setAnchorPoint(ccp(0,0.5))
        -- self.costNumWithShadow:setPosition(self._rootnode["cost_icon"]:getPositionX()+self._rootnode["cost_icon"]:getContentSize().width,self._rootnode["cost_icon"]:getPositionY())
        self.costNumWithShadow:setPosition(self._rootnode["cost_icon"]:getContentSize().width+self.costNumWithShadow:getContentSize().width/2,self._rootnode["exp_label"]:getContentSize().height*0.6)
        self._rootnode["cost_icon"]:addChild(self.costNumWithShadow)

        self.expNumWithShadow =ui.newTTFLabelWithShadow({
            text = "0",
            size = 22,
            color = ccc3(132,234,50),
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT 
            })
        self.expNumWithShadow:setAnchorPoint(ccp(0,0.5))
        -- self.expNumWithShadow:setPosition(self._rootnode["exp_label"]:getPositionX()+self._rootnode["exp_label"]:getContentSize().width,self._rootnode["exp_label"]:getPositionY())
        self.expNumWithShadow:setPosition(self._rootnode["exp_label"]:getContentSize().width+self.expNumWithShadow:getContentSize().width/2,self._rootnode["exp_label"]:getContentSize().height*0.6)
        self._rootnode["exp_label"]:addChild(self.expNumWithShadow)

    end

    if param.op == 2 then --如果是2的话表示强化完了 把这些值设为0
        -- self._rootnode["costNum"]:setString("")
        self.costNumWithShadow:setString(0)
        -- self.costNumWithShadow:setPosition(self.costNumWithShadow:getContentSize().width/2,0)

        -- self._rootnode["expNum"]:setString("")
        self.expNumWithShadow:setString(0)
        -- self.expNumWithShadow:setPosition(self.expNumWithShadow:getContentSize().width/2,0)

        self:playQiangHuaAnim(self._rootnode["qh_card_bg"])

        for i = 1,#addStates do
            self._rootnode["addState"..i]:setVisible(false)
        end
    else
        -- cost = 9999999
        -- self._rootnode["costNum"]:setString("")
        self.costNumWithShadow:setString(cost)
        -- self.costNumWithShadow:setPosition(self.costNumWithShadow:getContentSize().width/2,0)

        -- self._rootnode["expNum"]:setString("")
        self.expNumWithShadow:setString(cost)
        -- self.expNumWithShadow:setPosition(self.expNumWithShadow:getContentSize().width/2,0)
        self.expNumWithShadow:setPosition(self._rootnode["exp_label"]:getContentSize().width+self.expNumWithShadow:getContentSize().width/2,self._rootnode["exp_label"]:getContentSize().height*0.6)
    self.costNumWithShadow:setPosition(self._rootnode["cost_icon"]:getContentSize().width+self.costNumWithShadow:getContentSize().width/2,self._rootnode["exp_label"]:getContentSize().height*0.6)


        for i = 1,#addStates do
            self._rootnode["addState"..i]:stopAllActions()
            if addStates[i] ~= 0 then
                self._rootnode["addState"..i]:setVisible(true)
                self._rootnode["addState"..i]:setString("+"..addStates[i])
                local fadeTime = 1
                self._rootnode["addState"..i]:runAction(CCRepeatForever:create(transition.sequence({
                    CCFadeTo:create(fadeTime, 0),
                    CCFadeTo:create(fadeTime, 250)
                 
            
        })))
            else
                self._rootnode["addState"..i]:setVisible(false)
                self._rootnode["addState"..i]:setString(addStates[i])
            end
        end

    end


    local curLv = self.updateQiangHuaData["1"]["curLv"]
    local nextLv = self.updateQiangHuaData["1"]["lv"]

    local limit = self.updateQiangHuaData["1"]["limit"]
    local normalBarSprite = self._rootnode["empty"]

    if self.addBar == nil then
        self.addBar =  display.newProgressTimer("#shine_green_bar.png", display.PROGRESS_TIMER_BAR)
        self.addBar:setMidpoint(ccp(0,0.5))
        self.addBar:setBarChangeRate(ccp(1,0))
        self.addBar:setAnchorPoint(ccp(0,0.5))
        self.addBar:setPosition(0,self._rootnode["empty"]:getContentSize().height/2)
        self._rootnode["empty"]:addChild(self.addBar)
        self.addBar:setPercentage(80)

        self.normalBar =  display.newProgressTimer("#blue_bar.png", display.PROGRESS_TIMER_BAR)
        self.normalBar:setMidpoint(ccp(0,0.5))
        self.normalBar:setAnchorPoint(ccp(0,0.5))
        self.normalBar:setBarChangeRate(ccp(1,0))
        self._rootnode["empty"]:addChild(self.normalBar)
        self.normalBar:setPosition(0,self._rootnode["empty"]:getContentSize().height/2)
        self.normalBar:setPercentage(60)
    end



    local fadeTime = 1
    if param.op == 1 then
        self.addBar:stopAllActions()
        self.addBar:runAction(CCRepeatForever:create(
            transition.sequence({ 
                CCFadeOut:create(fadeTime),
                CCFadeIn:create(fadeTime)     
            })
            ))
    else
        self.addBar:stopAllActions()
    end   


    local level = self.updateQiangHuaData["1"]["lv"]
    self._rootnode["lvNum"]:setString(level)
    self.level = level
    self._rootnode["lvNum"]:stopAllActions()
    -- self._rootnode["lvNum"]:getParent():removeChildByTag(1111, true)
    self._rootnode["orLvNum"]:setOpacity(0)

    self._rootnode["orLvNum"]:stopAllActions()
    self._rootnode["orLvNum"]:setString(curLv)

    self._rootnode["lvNum"]:setOpacity(255)
    self._rootnode["lvNum"]:stopAllActions()
    if curLv ~= nextLv then

                self.addBar:setPercentage(100)
        self:shineLvl(curLv,nextLv)

    else
        local curExp = self.updateQiangHuaData["1"]["curExp"]
        local addExp = self.updateQiangHuaData["1"]["exp"]
        self.addBar:setPercentage(addExp/limit * 100)
        self.normalBar:setPercentage(curExp/limit * 100)
    
    end

    if param.op == 2 or self.curLevel == 0 then
        self.curLevel = level
    end

    local starNum = self.updateQiangHuaData["1"]["star"]
    self._rootnode["qh_card_bg"]:setDisplayFrame(display.newSprite("#card_ui_bg_" .. starNum .. ".png"):getDisplayFrame())
    --    dump(starNum)
    for i = 1,5 do
        self._rootnode["star"..i]:setVisible(i <= starNum)
    end

    local resId = self.updateQiangHuaData["1"]["resId"]
    local cls   = self.updateQiangHuaData["1"]["cls"]

    self._rootnode["image"]:setDisplayFrame(ResMgr.getHeroFrame(resId, cls))
    local heroStaticData = ResMgr.getCardData(resId)
    local job = heroStaticData["job"]
    ResMgr.refreshJobIcon(self._rootnode["qianghua_job_icon"],job) 

    --根据choseTable 更新各个icon
    local choseNum = #self.choseTable
    for i = 1,5 do
        if i > choseNum then
            --设置为+号
            local cellSprite = display.newSprite("#zhenrong_add.png")
            self._rootnode["iconSprite"..i]:setDisplayFrame(cellSprite:getDisplayFrame())
            self._rootnode["iconSprite"..i]:removeAllChildren()
        else
            --设置为
            local resId = self.sellAbleList[self.choseTable[i]]["resId"]
            local cls   = self.sellAbleList[self.choseTable[i]]["cls"]
            ResMgr.refreshIcon({itemBg = self._rootnode["iconSprite"..i],id = resId,resType = ResMgr.HERO,cls = cls})
        end
    end

    TutoMgr.active()
end

function HeroQiangHuaLayer:shineFont(shineObj,endFunc)
        local fadeTime = 1
        shineObj:stopAllActions()
        shineObj:runAction(CCRepeatForever:create(
            transition.sequence({ 
                CCFadeIn:create(fadeTime),
                CCFadeOut:create(fadeTime),
                CCCallFunc:create(function ()
                    if endFunc ~= nil then
                        endFunc()
                    end
                end)     
            })
            ))    
end

function HeroQiangHuaLayer:shineLvl(curLv,nextLv)
    self._rootnode["lvNum"]:stopAllActions()
    self._rootnode["orLvNum"]:stopAllActions()

    self._rootnode["lvNum"]:setOpacity(0)
    self._rootnode["orLvNum"]:setOpacity(255)

    if curLv ~= nil then 
        self._rootnode["orLvNum"]:setString(curLv)
    end

    if nextLv ~= nil then
        self._rootnode["lvNum"]:setString(nextLv)
    end



    local fadeTime = 1
    if self.orNumFadeIn == nil then

        self._rootnode["lvNum"]:setOpacity(0)
        self.lvNumFadeIn = function ()
            self._rootnode["lvNum"]:runAction(
            transition.sequence({ 
                CCFadeIn:create(fadeTime),
                CCFadeOut:create(fadeTime),
                CCCallFunc:create(function ()
                    self.orNumFadeIn()
               end)
            })
            )
        end


        self.orNumFadeIn = function ( )
            self._rootnode["orLvNum"]:runAction(
            transition.sequence({ 
                CCFadeIn:create(fadeTime),
                CCFadeOut:create(fadeTime),
                CCCallFunc:create(function ()
                     self.lvNumFadeIn()
                end)
                    
            })
            )
        end
    end       
    self.orNumFadeIn()
end



function HeroQiangHuaLayer:updateXiaHun(param)

    self._rootnode["xiahunPage"]:setVisible(true)
    self._rootnode["qianghuaPage"]:setVisible(false)
    self._rootnode["qianghua_btn_node"]:setVisible(false)
    self._rootnode["xiahun_btn_node"]:setVisible(true)

    self.addBar:stopAllActions()
    local baseNums = self.xiahunData["1"]["base"]
    local addNums = self.xiahunData["1"]["add"]




    for i = 1,4 do
        self._rootnode["baseState"..i]:setString(baseNums[i])
        self._rootnode["addState"..i]:setString("+"..addNums[i])
        self._rootnode["addState"..i]:setVisible(true)
        if param.op == 1 then
            self:shineFont(self._rootnode["addState"..i])            
        else
            self._rootnode["addState"..i]:stopAllActions()
        end
    end

    local costNum = self.xiahunData["1"]["cost"]
    self._rootnode["cost_silver_num"]:setString(costNum)

    self.xiahunCostNum = costNum

    local getExp =self.xiahunData["1"]["exp"]

    self._rootnode["get_exp_num"]:setString(getExp)

    self.curXiaHunNum = self.xiahunData["1"]["hun"][1]
    self.needXiaHunNum = self.xiahunData["1"]["hun"][2]

    self._rootnode["cur_xiahun_num"]:setString(self.curXiaHunNum)
    self._rootnode["need_xiahun_num"]:setString(self.needXiaHunNum)

    local curLevelNum = self.xiahunData["1"]["lv"]
    -- self._rootnode["lvNum"]:setString(curLevelNum )
    -- self._rootnode["orLvNum"]:setString(curLevelNum +1)
    self:shineLvl(curLevelNum,curLevelNum +1)
    self.xiahunLv = curLevelNum
    self.level = curLevelNum



    if self.addBar == nil then
        self.addBar =  display.newProgressTimer("#shine_green_bar.png", display.PROGRESS_TIMER_BAR)
        self.addBar:setMidpoint(ccp(0,0.5))
        self.addBar:setBarChangeRate(ccp(1,0))
        self.addBar:setAnchorPoint(ccp(0,0.5))
        self.addBar:setPosition(0,self._rootnode["empty"]:getContentSize().height/2)
        self._rootnode["empty"]:addChild(self.addBar)
        self.addBar:setPercentage(80)

        self.normalBar =  display.newProgressTimer("#blue_bar.png", display.PROGRESS_TIMER_BAR)
        self.normalBar:setMidpoint(ccp(0,0.5))
        self.normalBar:setAnchorPoint(ccp(0,0.5))
        self.normalBar:setBarChangeRate(ccp(1,0))
        self._rootnode["empty"]:addChild(self.normalBar)
        self.normalBar:setPosition(0,self._rootnode["empty"]:getContentSize().height/2)
        self.normalBar:setPercentage(60)
    end

    if param.op == 2 then
        --侠魂强化以后 经验值置空
        self.normalBar:setPercentage(0)
    end
    self.addBar:setPercentage(100)


    self:shineFont(self.addBar)


    local resId = self.xiahunData["1"]["resId"]
    local cls   = self.xiahunData["1"]["cls"]
    local starNum = self.xiahunData["1"].star

    local heroStaticData = ResMgr.getCardData(resId)
    local job = heroStaticData["job"]
    ResMgr.refreshJobIcon(self._rootnode["qianghua_job_icon"],job) 


    for i = 1,5 do
        self._rootnode["star"..i]:setVisible(i <= starNum)
    end

    self._rootnode["qh_card_bg"]:setDisplayFrame(display.newSprite("#card_ui_bg_" .. starNum .. ".png"):getDisplayFrame())
    self._rootnode["image"]:setDisplayFrame(ResMgr.getHeroFrame(resId, cls))

end

function HeroQiangHuaLayer:updateListData(data)

    if data.op == 2 then

        -- print("self.index"..self.index)
        -- dump(self.heroList)
        local cellData = self.heroList[self.index]
        local changeData = data["1"]
        --        dump(data)
        if cellData ~= nil then
            cellData["cls"] = changeData["cls"]
            cellData["level"] = changeData["lv"]
            cellData["star"] = changeData["star"]
            self.level = changeData["lv"]
        end
    end
    self.resetList()
end


function HeroQiangHuaLayer:ctor(param)

    display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
    self.isQiangHuaAlready = false

    self.removeListener = param.removeListener
    self.heroList = param.listData
    self.index = param.index
    self.resetList = param.resetList --更新list的函数
    self.curLevel = 0

    self.objId = self.heroList[self.index]["_id"]
    printf(self.objId)
    -- dump(self.heroList)
    self.xiahunLv = 0
    --sellAbleList 过滤一下 过滤出可出售列表
    self.sellAbleList = {}
    local rawlist = self.heroList

    for i = #rawlist,1,-1  do
        local pos = rawlist[i]["pos"]
        if pos == 0 then   -- 没上阵且不是主角 主角不能下场 所以必须pos 不为0
            local cls = rawlist[i]["cls"]
            if cls == 0 then
                local resId = rawlist[i].resId 
                local cardData = ResMgr.getCardData(resId)
                if cardData.lysis == 1 then --是否可被强化吃掉
                    -- local stars = rawlist[i]["star"]
                    -- if stars < 4 then
                        --星级小于五
                        if rawlist[i].lock ~= 1 then -- 加锁的不能吃掉
                            if rawlist[i]["_id"] ~= self.objId then
                                -- dump(rawlist[i])
                                --不是要强化的主卡牌
                                self.sellAbleList[#self.sellAbleList + 1 ] = rawlist[i]

                                self.sellAbleList[#self.sellAbleList]["orIndex"] =  i --保存index在原先list中的index
                            end
                        end
                    -- end
                end
            end
        end
    end

    -- sort the hero list for qianghua

     HeroModel.sort(self.sellAbleList,true)

    --<<增加上下的框
    self.bottom = require("game.scenes.BottomLayer").new(true)
    self:addChild(self.bottom,1)

    self.top = require("game.scenes.TopLayer").new()
    self:addChild(self.top,1)
    -->

    local proxy = CCBProxy:create()
    self._rootnode = {}

    self.nextXiaHun = function() self:sendRes({viewType = XIAHUN_VIEW,op = 1,n = 1}) end

    local node = CCBuilderReaderLoad("hero/hero_qianghua.ccbi", proxy, self._rootnode,self,CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height ))
    -- local node = CCBuilderReaderLoad("hero/hero_qianghua.ccbi", proxy, self._rootnode,self,CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - 72))
    node:setAnchorPoint(ccp(0.5,0))
    node:setPosition(display.width/2,self.bottom:getContentSize().height)
    self:addChild(node)


    self._curView = QIANGHUA_VIEW

    local function onTabBtn(tag)
        if tag == 1 then
            self._rootnode["tab" .. 1]:selected()
            self._rootnode["tab" .. 2]:unselected()
            if self._curView ~= QIANGHUA_VIEW then
                self._curView = QIANGHUA_VIEW
                -- self:updateQiangHua()
                self:sendRes({viewType = QIANGHUA_VIEW,op = 1})
                print("qianghua ")
            end

        else
            self._rootnode["tab" .. 1]:unselected()
            self._rootnode["tab" .. 2]:selected()
            if self._curView ~= XIAHUN_VIEW then
                self._curView = XIAHUN_VIEW

                self:sendRes({viewType = XIAHUN_VIEW,op = 1,n = 1})
                print("xiahun ")
            end
        end

        self._curView = tag

    end
    self._rootnode["tab1"]:selected()
    self._rootnode["tab1"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
    self._rootnode["tab2"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)

    -- self:updateQiangHua()

    --选择要吃掉的侠客table 里面存放的是在sellAblelist 里的index
    self.choseTable = {}
    -- self.choseResTable = {}

    --点击任何一个槽，都会弹出同一个列表，玩家可以通过列表 选择要吃掉的侠客，更改侠客table
    for i = 1, 5 do
        local iconBtn = self._rootnode["btn"..i]
        iconBtn:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
            -- if self.level < game.player.m_level then --如果卡牌级别不高于
                
                iconBtn:setEnabled(false)
                self:setUpBottomVisible(false)
                local qiangHuaChoseLayer = require("game.Hero.HeroChoseLayer").new({
                    listData    = self.heroList,
                    sellAbleData= self.sellAbleList,
                    index       = self.index,
                    choseTable  = self.choseTable,
                    updateFunc  = handler(self, self.sendObRes),
                    setUpBottomVisible = function() self:setUpBottomVisible(true) end,
                    removeListener = function()                    
                        self._rootnode["btn"..i]:setEnabled(true)
                    end
                })
                self:addChild(qiangHuaChoseLayer)
            -- else
            --     show_tip_label("侠客等级不能超过主角等级")
            -- end

        end)
    end

    self.backBtn = self._rootnode["backBtn"]
    self.backBtn:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        for i = 1,#self.sellAbleList do
            self.sellAbleList[i]["isChosen"] = false
        end

        if self.removeListener ~= nil then
            self.removeListener(self.isQiangHuaAlready)
        end
        self:removeSelf()
    end,
        CCControlEventTouchUpInside)


    self._rootnode["xiahun_back_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        for i = 1,#self.sellAbleList do
            self.sellAbleList[i]["isChosen"] = false
        end

        if self.removeListener ~= nil then
            self.removeListener(self.isQiangHuaAlready)
        end

        self:removeSelf()
    end,
        CCControlEventTouchUpInside)

    self.cost = 0
    self.qianghuaBtn = self._rootnode["qianghuaBtn"]
    self.qianghuaBtn:addHandleOfControlEvent(function(eventName,sender)
        self.qianghuaBtn:setEnabled(false)
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

        if #self.choseTable ~= 0 then

            if self.cost < game.player.m_silver then --
                if self.curLevel < game.player.m_level then --如果卡牌级别不高于
                    ResMgr.createMaskLayer(display.getRunningScene())
                    self:sendQiangHuaRes()
                else
                    -- show_tip_label("侠客等级不能超过主角等级")
                end          

            else
                --当前银币不足
                 ResMgr.showErr(2300006)
            end
        else
            --添加侠客
            ResMgr.showErr(200021)
        end
        self:performWithDelay(function()
            self._rootnode["qianghuaBtn"]:setEnabled(true)
        end, 0.8)
    end,
        CCControlEventTouchUpInside)

    self.autoBtn = self._rootnode["autoBtn"]
    self.autoBtn:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if #self.choseTable < 5 then

            self:autoSel()
        else
            show_tip_label("侠客已满")
        end
    end,
        CCControlEventTouchUpInside)
    TutoMgr.addBtn("qianghua_btn_qianghua",self.qianghuaBtn)
    TutoMgr.addBtn("qianghua_btn_autoadd",self.autoBtn)


    self.xiahunCostNum = 0

    self._rootnode["xiahun_qianghua_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if ResMgr.isEnoughSilver(self.xiahunCostNum) then --判断银币是否足够
            if self.curXiaHunNum >= self.needXiaHunNum then
                if self.xiahunLv < game.player.m_level then
                    self:sendRes({viewType = XIAHUN_VIEW,op = 2,n = 1})
                else
                    -- show_tip_label("侠客等级不能超过主角等级")
                    ResMgr.showErr(200020)

                end
            else
                -- show_tip_label("侠魂不足，可通过副本和炼化炉获得侠魂")
                ResMgr.showErr(200022)
            end
        else
            -- show_tip_label("银币不足")
            ResMgr.showErr(2300006)
        end
    end,
        CCControlEventTouchUpInside)

    self._rootnode["xiahun_5_time_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if ResMgr.isEnoughSilver(self.xiahunCostNum) then --判断银币是否足够
            if self.curXiaHunNum >= self.needXiaHunNum then
                if self.xiahunLv < game.player.m_level then
                    self:sendRes({viewType = XIAHUN_VIEW,op = 2,n = 5})
                else
                    -- show_tip_label("侠客等级不能超过主角等级")
                    ResMgr.showErr(200020)

                end
            else
                ResMgr.showErr(200022)

                -- show_tip_label("侠魂不足，可通过副本和炼化炉获得侠魂")
            end
        else
            -- show_tip_label("银币不足")
            ResMgr.showErr(2300006)
        end
    end,
        CCControlEventTouchUpInside)






    self:sendRes({viewType = QIANGHUA_VIEW,op = 1})
end

function HeroQiangHuaLayer:autoSel()
    --遍历下 然后将未选中的填满

    if self.level < game.player.m_level then --如果卡牌级别不高于
        for i = 1,5-#self.choseTable do
         
            for j = 1,#self.sellAbleList do
                local isExist = false
                local resId =  self.sellAbleList[j].resId
                local cardData = ResMgr.getCardData(resId)
                local isAuto = cardData.autoadd 
                if isAuto == 1 then
                    for k = 1,#self.choseTable do
                        if self.choseTable[k] == j then
                            isExist = true
                            break
                        end
                    end
                
                    if isExist == false then
                        self.choseTable[#self.choseTable + 1] = j
                        self.sellAbleList[j]["isChosen"] = true
                        break
                    end
                end
            end
        end
        if #self.choseTable == 0 then 
            -- show_tip_label("您没有可被强化的侠客")  
            --松鹏说不需要显示
            -- ResMgr.showErr(200023)          
        end
        self:sendRes({viewType = QIANGHUA_VIEW,op = 1})
    else
        ResMgr.showErr(200020)
        -- show_tip_label("侠客等级不能超过主角等级")
    end
    PostNotice(NoticeKey.REMOVE_TUTOLAYER)

end



function HeroQiangHuaLayer:clearData()
    --发送强化成功请求后，在回调中清除选中的数据，并且更新上一级的table
    -- dump(self.heroList)
    print("clear clear")
    local objList = {}
    for i = 1,#self.choseTable do
        local objId = self.sellAbleList[self.choseTable[i]]["_id"]
        objList[#objList + 1] = objId

        -- table.remove(self.sellAbleList,self.choseTable[i])
    end

    for i = 1,#objList do
        for j = 1,#self.sellAbleList do
            if self.sellAbleList[j]["_id"] == objList[i] then
                table.remove(self.sellAbleList,j)
                for k = 1 ,#self.heroList do
                    if self.heroList[k]["_id"] == objList[i] then
                        table.remove(self.heroList,k)
                        break
                    end
                end
                break
            end
        end
    end



    self.choseTable = {}

    self.resetList()
end

function HeroQiangHuaLayer:sendQiangHuaRes()
    self:sendRes({viewType = QIANGHUA_VIEW, op = 2})
end




function HeroQiangHuaLayer:sendRes(param)
    local viewType = param.viewType

    if viewType == QIANGHUA_VIEW then
        local idsTable = {}
        idsTable[#idsTable+1] = self.objId


        for i = 1,#self.choseTable do
            idsTable[#idsTable+1] = self.sellAbleList[self.choseTable[i]]["_id"]
        end

        local sellStr = ""
        for i =1,#idsTable do
            if #sellStr ~= 0 then
                sellStr = sellStr..","..idsTable[i]
            else
                sellStr = sellStr..idsTable[i]
            end
        end

        RequestHelper.getCardQianghuaRes({
            callback = function(data)
                ResMgr.removeMaskLayer()
                if #data["0"] > 0 then
                    show_tip_label(data["0"])
                else
                    if param.op == 2 then
                        self.isQiangHuaAlready = true
                        --清空两个表中的数据
                        self:clearData()

                        game.player.m_silver = game.player.m_silver - self.cost
                        self.top:setSilver(game.player.m_silver)
                        data.op = 2
                        
                    else
                        data.op = 1
                    end

                    self.updateQiangHuaData = data
                    
                    -- dump(data)
                    self:updateListData(data)
                    self:updateQiangHua({op = param.op})
                end

            end,
            errback = function(data)
                if param.op == 1 then
                    self.choseTable = {}
                end
            end,
            op = param.op,
            cids = sellStr
        })
    elseif viewType == XIAHUN_VIEW then
        RequestHelper.getXiaHunQianghuaRes({
            callback = function(data)
            --                dump(data)
                
                -- dump(data)
                ResMgr.removeMaskLayer()

                -- self:xiaHunUpdate(data)
                self.xiahunData = data

                local silver = data["2"]
                game.player.m_silver = silver
                PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                self.top:setSilver(game.player.m_silver)
                self:updateXiaHun({op = param.op})
                -- dump(param)
                if param.op == 2 then
                    self:playQiangHuaAnim(self._rootnode["qh_card_bg"])
                    --     local finLayer = require("game.Hero.HeroXiaHunEndLayer").new({nextXiaHun = self.nextXiaHun})
                    --     display:getRunningScene():addChild(finLayer,9999)

                end
                data.op = param.op
                self:updateListData(data)

            end,
            id = self.objId,
            op = param.op,
            n = param.n
        })


    else
        ResMgr.removeMaskLayer()

        ResMgr.debugBanner("无此查看类型")
    end


end

function HeroQiangHuaLayer:sendObRes()
    self:sendRes({viewType =QIANGHUA_VIEW,op = 1})
end


function HeroQiangHuaLayer:onEnter()
end

function HeroQiangHuaLayer:onExit()
    TutoMgr.removeBtn("qianghua_btn_qianghua")
    TutoMgr.removeBtn("qianghua_btn_autoadd")


end

return HeroQiangHuaLayer