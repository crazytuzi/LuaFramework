--[[
 --
 -- add by vicky
 -- 2014.10.08
 --
 --]]


local data_item_item = require("data.data_item_item") 
local data_card_card = require("data.data_card_card") 
 require("data.data_error_error") 


 local LimitHeroLayer = class("LimitHeroLayer", function()
 		return display.newNode()
 	end)


function LimitHeroLayer:adjustHero()
   
    local adjOffX = (self.curPage-1) * - display.width
    -- self.heroTableList:unscheduleAllSelectors()
    self:updateHeroName()

    self.heroTableList:setContentOffset(ccp(adjOffX,0), true)


    self._rootnode["left_arrow"]:setVisible(true)
    self._rootnode["right_arrow"]:setVisible(true)
    if self.curPage == 1 then
        self._rootnode["left_arrow"]:setVisible(false)
    elseif self.curPage == #self.heroList then
        self._rootnode["right_arrow"]:setVisible(false)
    else
        self._rootnode["left_arrow"]:setVisible(true)
        self._rootnode["right_arrow"]:setVisible(true)
    end

    if #self.heroList == 1 then
        self._rootnode["left_arrow"]:setVisible(false)
        self._rootnode["right_arrow"]:setVisible(false)
    end

    local heroId = self.heroList[self.curPage]
    local starNum  = ResMgr.getCardData(heroId).star[1]

    for i = 1,5 do
        if i == starNum then
            self._rootnode["star_"..i.."_node"]:setVisible(true)
        else
            self._rootnode["star_"..i.."_node"]:setVisible(false)
        end
    end

end



 
function LimitHeroLayer:ctor(param)

	local viewSize = param.viewSize 
    self.viewSize = viewSize
	self:setNodeEventEnabled(true) 

    local proxy = CCBProxy:create()
    self._rootnode = {}

	-- 创建UI 
    local contentNode = CCBuilderReaderLoad("nbhuodong/limit_hero_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(contentNode) 

    LimitHeroModel.sendInitRes({
        callback = function()
           self:init()
           self:update()
        end
        })
end 

function LimitHeroLayer:init()
    local function createFunc(idx)
        local item = require("game.nbactivity.LimitHero.LimitHeroCell").new()
        return item:create(idx,self.viewSize)
    end

    local function refreshFunc(cell,id)
        
        cell:refresh(id)
    end

    self.heroList = LimitHeroModel.getHeroList()




    self.heroTableList = require("utility.TableViewExt").new({
        size        = self.viewSize, 
        direction   = kCCScrollViewDirectionHorizontal,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self.heroList,
        cellSize    = CCSizeMake(display.width, self.viewSize.height),
    })

    self.heroTableList:setBounceable(true)
    self.heroTableList:setTouchEnabled(false)

    local LIST_HEIGHT = 295

    self.heroTableList:setPosition(0,LIST_HEIGHT)

    self._rootnode["limit_bg"]:addChild(self.heroTableList)



    self.touchLayer = display.newColorLayer(ccc4(100,50,50,0))
    self.touchLayer:setPosition(ccp(0,LIST_HEIGHT))
    self.touchLayer:setContentSize(CCSize(display.width,self.viewSize.height-LIST_HEIGHT))
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setTouchSwallowEnabled(false)

    self.curPage = 1
    self._rootnode["left_arrow"]:setVisible(false)

    if #self.heroList == 1 then
        self._rootnode["left_arrow"]:setVisible(false)
        self._rootnode["right_arrow"]:setVisible(false)
    end

    self._rootnode["limit_bg"]:addChild(self.touchLayer)

    local isTouching = false
    local preX = 0
    local aftX = 0

    self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)


        if event.name == "began" then

            preX = event.x
            local touchPos = ccp(event.x,event.y)
            local layPos = self.touchLayer:getParent():convertToWorldSpace(ccp(self.touchLayer:getPositionX(),self.touchLayer:getPositionY()))
            local layRect = CCRect(layPos.x, layPos.y, self.touchLayer:getContentSize().width, self.touchLayer:getContentSize().height)
            local isInLayer = layRect:containsPoint(ccp(event.x,event.y))


            if isInLayer then
                return true
            else
                return false
            end
            -- return true
        elseif event.name == "moved" then
            -- dump(event)
            if math.abs(event.x - event.prevX) > 5 then
                local touchOffx = event.x - event.prevX
                local curOff = self.heroTableList:getContentOffset()
                curOff.x = curOff.x + touchOffx
                self.heroTableList:setContentOffset(curOff, false)
            end
        elseif event.name == "ended" then    
             aftX = event.x
            if aftX - preX < -50 then
                if self.curPage < #self.heroList then
                    self.curPage = self.curPage + 1
                end
            elseif aftX - preX > 50 then
                if self.curPage > 1 then
                    self.curPage = self.curPage - 1
                end
            end
            -- ResMgr.delayFunc(0.1,function()
                 self:adjustHero()
                -- end)                          
           
        end
                
    end)

    self._rootnode["left_arrow"]:setZOrder(1000)
    self._rootnode["right_arrow"]:setZOrder(1000)

    ResMgr.setControlBtnEvent(self._rootnode["desc_btn"],function()
        local layer = require("game.nbactivity.LimitHero.LimitHeroDescLayer").new()
        display.getRunningScene():addChild(layer, 100)
    end)

    ResMgr.setControlBtnEvent(self._rootnode["free_btn"],function()
        self:onFreeDraw()
    end)

    ResMgr.setControlBtnEvent(self._rootnode["gold_btn"],function()
        self:onGoldDraw()
    end)

    self._rootnode["up_node"]:setScale(0.8)
    self._rootnode["up_bg"]:setScaleY(0.8)






    local startTimeStr = LimitHeroModel.actStartTime()
    local endTimeStr = LimitHeroModel.actEndTime()
    local actTimePeriod = "活动时间："..startTimeStr.." 至 "..endTimeStr

    local timePeriodTTF = ui.newTTFLabelWithShadow({
        text = actTimePeriod,
        size = 26,
        color = ccc3(36,255,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    })

    timePeriodTTF:setPosition(self._rootnode["hero_ttf"]:getPositionX(),self._rootnode["hero_ttf"]:getPositionY()+self._rootnode["hero_ttf"]:getContentSize().height/2+timePeriodTTF:getContentSize().height/2)
    self._rootnode["up_node"]:addChild(timePeriodTTF)

    self:initActTimeSchedule()


    local costGoldTTF  = ui.newTTFLabelWithShadow({
        text = LimitHeroModel.costGold(),
        size = 24,
        color = ccc3(255,210,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })
    costGoldTTF:setPosition(self._rootnode["gold_icon"]:getContentSize().width,self._rootnode["gold_icon"]:getContentSize().height/2)
    self._rootnode["gold_icon"]:addChild(costGoldTTF)

    self:updateHeroName()

    self.luckBar =  display.newProgressTimer("#herolimit_bar.png", display.PROGRESS_TIMER_BAR)
    self.luckBar:setMidpoint(ccp(0,0.5))
    self.luckBar:setBarChangeRate(ccp(1,0))
    self.luckBar:setAnchorPoint(ccp(0,0.5))
    self.luckBar:setPosition(0,self._rootnode["luck_bg"]:getContentSize().height/2)
    self._rootnode["luck_bg"]:addChild(self.luckBar)

    self.luckBarTTF =  ui.newTTFLabelWithShadow({
        text = LimitHeroModel.luckNum().."/"..LimitHeroModel.maxLuckNum(),
        size = 26,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
        })
    self.luckBarTTF:setPosition( self._rootnode["luck_bg"]:getContentSize().width/2, self._rootnode["luck_bg"]:getContentSize().height/2)
    self._rootnode["luck_bg"]:addChild(self.luckBarTTF)

    self.luckEffect = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "xianshihaojie_xingyunzhiman",
            isRetain = true
        })

    self.luckEffect:setPosition( self._rootnode["luck_bg"]:getContentSize().width/2, self._rootnode["luck_bg"]:getContentSize().height/2)
    self._rootnode["luck_bg"]:addChild(self.luckEffect)
    self.luckEffect:setVisible(false)



    self.goldDrawEff = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "xianshihaojie_yuanbaochouqu",
        isRetain = true
    })
    self.goldDrawEff:setPosition( self._rootnode["gold_btn"]:getContentSize().width/2, self._rootnode["gold_btn"]:getContentSize().height/2)
    self._rootnode["gold_btn"]:addChild(self.goldDrawEff)


    self.freeDrawLabel = ui.newTTFLabelWithShadow({
        text = "剩余时间",
        size = 22,
        color = ccc3(36,255,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.freeDrawLabel:setPosition(self._rootnode["free_btn"]:getPositionX(),self._rootnode["free_btn"]:getPositionY()-self._rootnode["free_btn"]:getContentSize().height/2-self.freeDrawLabel:getContentSize().height/2)

    self._rootnode["down_node"]:addChild(self.freeDrawLabel)

end


function LimitHeroLayer:updateDownTableView()
    self._rootnode["table_bg"]:removeAllChildren()


    local function createFunc(idx)
        local item = require("game.nbactivity.LimitHero.LimitRankCell").new()
        return item:create(idx,self._rootnode["table_bg"]:getContentSize().width)
    end

    local function refreshFunc(cell,id)        
        cell:refresh(id)
    end

    self.curList = LimitHeroModel.rankList()


    self.rankList = require("utility.TableViewExt").new({
        size        = self._rootnode["table_bg"]:getContentSize(), 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self.curList,
        cellSize    = CCSizeMake(self._rootnode["table_bg"]:getContentSize().width, 22)
    })
    self.rankList:setTouchEnabled(true)
    self._rootnode["table_bg"]:addChild(self.rankList)
end



function LimitHeroLayer:updateRightDesc()
    self._rootnode["ttf_node"]:removeAllChildren()

    local function arrPos(ttf,node)
        ttf:setPosition(node:getPositionX()+node:getContentSize().width/2,node:getPositionY()-3)
    end

    local curText,fontSize = LimitHeroModel.getModifiedPlayerRank()


    local rankNum = ui.newTTFLabelWithShadow({
        text = curText,
        size = fontSize,
        color = ccc3(36, 255, 0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    })
    arrPos(rankNum,self._rootnode["rank"])
    self._rootnode["ttf_node"]:addChild(rankNum)


    local scoreNum = ui.newTTFLabelWithShadow({
        text = LimitHeroModel.playerScore(),
        size = 20,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    })
    arrPos(scoreNum,self._rootnode["score"])
    self._rootnode["ttf_node"]:addChild(scoreNum)

    local yuanbaoNum = ui.newTTFLabelWithShadow({
        text = game.player.m_gold,
        size = 20,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    })
    arrPos(yuanbaoNum,self._rootnode["yuanbao"])
    self._rootnode["ttf_node"]:addChild(yuanbaoNum)


    local times = LimitHeroModel.restLuckNum()

    local textLabel = ui.newBMFontLabel({
            text = "",
            font = FONTS_NAME.font_zhaojiang,

        })
    textLabel:setAnchorPoint(ccp(0,1))
    textLabel:setScale(0.8)

    textLabel:setPosition(self._rootnode["table_bg"]:getContentSize().width+20,self._rootnode["ttf_node"]:getContentSize().height-20)
    
    
    if times > 0 then
        textLabel:setString(tostring(string.format("再招 %d 次后,下次招募必得五星侠客！", times)))
    else
        textLabel:setString("             下次招募必得五星侠客！")
    end


     self._rootnode["ttf_node"]:addChild(textLabel)

     local ttfColor = {ccc3(255, 210, 0),ccc3(36, 255, 0),ccc3(255, 255, 255)}
     local textContent = {"排名",
                        {" 第1"," 2-3"," 4-20"," 21-50"},
                        " 可获得"}

     local orX = self._rootnode["table_bg"]:getContentSize().width+32
     local orY = 97
     local curOffsetY = 25
     local curX = orX
     local curY = orY


     for i = 1,4 do


        for j = 1, 4 do
            local curColor = nil
            if j ~= 4  then
                curColor = ttfColor[j]
                local content = ""
                if j == 2 then
                    content = textContent[j][i]
                else
                    content = textContent[j]
                end


                local shadowTTF = ui.newTTFLabelWithShadow({
                    text = content,
                    size = 20,
                    color = curColor,
                    font = FONTS_NAME.font_fzcy,
                    align = ui.TEXT_ALIGN_LEFT
                })
                 
                shadowTTF:setPosition(curX,curY)
                curX = curX + shadowTTF:getContentSize().width
                self._rootnode["ttf_node"]:addChild(shadowTTF)
            else
                local rewardData = LimitHeroModel.rewardList[i]
                if i == 4 then

                        local heroNameTTF = ui.newTTFLabelWithShadow({
                            text =rewardData[1].."资质五星侠客",
                            size = 20,
                            color = NAME_COLOR[5],
                            font = FONTS_NAME.font_fzcy,
                            align = ui.TEXT_ALIGN_LEFT
                        })
                        heroNameTTF:setPosition(curX,curY)
                        curX = curX + heroNameTTF:getContentSize().width
                        self._rootnode["ttf_node"]:addChild(heroNameTTF)

                else
                    for k = 1,#rewardData do


                        local heroData = ResMgr.getCardData(rewardData[k])
                        local heroNameTTF = ui.newTTFLabelWithShadow({
                            text = heroData.name,
                            size = 20,
                            color = NAME_COLOR[heroData.star[1]],
                            font = FONTS_NAME.font_fzcy,
                            align = ui.TEXT_ALIGN_LEFT
                        })
                        heroNameTTF:setPosition(curX,curY)
                        curX = curX + heroNameTTF:getContentSize().width
                        self._rootnode["ttf_node"]:addChild(heroNameTTF)

                        if k ~= #rewardData then
                            local heroNameSym = ui.newTTFLabelWithShadow({
                                text = ",",
                                size = 20,
                                color = NAME_COLOR[heroData.star[1]],
                                font = FONTS_NAME.font_fzcy,
                                align = ui.TEXT_ALIGN_LEFT
                            })
                            heroNameSym:setPosition(curX,curY)
                            curX = curX + heroNameSym:getContentSize().width
                            self._rootnode["ttf_node"]:addChild(heroNameSym)
                        end


                    end
                end

            end
        end
        curX = orX
        curY = curY - curOffsetY
     end

end

function LimitHeroLayer:updateDownNode()

    self:updateDownTableView()
    self:updateRightDesc()

end


function LimitHeroLayer:updateHeroName()
    local heroResId = self.heroList[self.curPage]
    local heroData = ResMgr.getCardData(heroResId)
    self._rootnode["cur_hero_name"]:setString(heroData.name)
    self._rootnode["cur_hero_name"]:setColor(NAME_COLOR[heroData.star[1]])
   
end

function LimitHeroLayer:updateLuckBar()
    local maxNum = 1
    if LimitHeroModel.maxLuckNum() > 0 then
        maxNum =LimitHeroModel.maxLuckNum()
    end

    local per = checkint((LimitHeroModel.luckNum()/maxNum)*100)
    self.luckBar:setPercentage(per)
      self.luckBarTTF:setString(LimitHeroModel.luckNum().."/"..LimitHeroModel.maxLuckNum())
    if per < 100 then
        self.luckEffect:setVisible(false)
    else
        self.luckEffect:setVisible(true)
    end
end

function LimitHeroLayer:updateFreeDrawSchedule()

    self.freeDrawTime = LimitHeroModel.freeRestTime()


    self.freeDrawLabel:stopAllActions()
    
    local function freeDrawUpdate()
        local updateStr = ""
        if self.freeDrawTime > 0 then
            self.freeDrawTime = self.freeDrawTime - 1
            updateStr = format_time(self.freeDrawTime)
            LimitHeroModel.isFreeAllowFreeDraw = false
        else
            updateStr = "本次抽取免费"
            LimitHeroModel.isFreeAllowFreeDraw = true
            self.freeDrawLabel:stopAllActions()
        end 
        self.freeDrawLabel:setString(updateStr)
    end
    freeDrawUpdate()
    self.freeDrawLabel:schedule(freeDrawUpdate,1)

end



function LimitHeroLayer:initActTimeSchedule()

    self.actRestTime = LimitHeroModel.actRestTime()

    self.actTimeLabel = ui.newTTFLabelWithShadow({
        text = "剩余时间",
        size = 26,
        color = ccc3(36,255,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.actTimeLabel:setPosition(self._rootnode["rest_time_ttf"]:getPositionX(),self._rootnode["rest_time_ttf"]:getPositionY()-self._rootnode["rest_time_ttf"]:getContentSize().height)

    self._rootnode["up_node"]:addChild(self.actTimeLabel)


    local function actUpdate()
        local updateStr = ""
        if self.actRestTime > 0 then
            -- self.actRestTime = self.actRestTime - 1
           
            self.actRestTime = GameModel.getRestTimeInSec(LimitHeroModel.actEndTime_inMS()/1000)
            updateStr = format_time(self.actRestTime)
        else
            updateStr = "活动结束"
            -- self.actTimeLabel:stopAllActions()
            self.scheduler.unscheduleGlobal(self.timeData)
            self:stopAct()

        end 
        self.actTimeLabel:setString(updateStr)
    end
    actUpdate()
    -- self.actTimeLabel:schedule(actUpdate,1)
    self.scheduler = require("framework.scheduler")
    
    if self.timeData ~= nil then
        self.scheduler.unscheduleGlobal(self.timeData)
    end

    self.timeData = self.scheduler.scheduleGlobal(actUpdate, 1, false )

end

function LimitHeroLayer:stopAct()
    self.isActStop = true
end



function LimitHeroLayer:createDrawSuccessLayer(param)

    local drawedHero =  LimitHeroModel.drawedHero()
    local herolist = {}
    herolist[1] = drawedHero
    dump(drawedHero)
    local heroName = ""
    -- for k,v in pairs(herolist) do
    --     local heroId = v.id
    --     local heroInfo = ResMgr.getCardData(heroId)
    --     if heroInfo.star[1] >= 5 then 
    --         -- 广播 玩家招募5星级侠客成功
    --         Broad_getHeroData.heroName = heroInfo.name
    --         Broad_getHeroData.type = heroInfo.type
    --         Broad_getHeroData.star = heroInfo.star[1] 

    --         game.broadcast:showPlayerGetHero()
    --     end 
    -- end

    local rankNum,fontSize = LimitHeroModel.getModifiedPlayerRank()


    local zhaojiangLayer = require("game.shop.ZhaojiangResultNormal").new({
        type     = 4,
        herolist      = herolist,
        leftTime = LimitHeroModel.restLuckNum(),
        scoreTable = {
                        LimitHeroModel.getScore(),
                        LimitHeroModel.playerScore(),
                        rankNum
                        },
        buyListener   = function()
        --无论如何，下一次招将必然是收费招将
            self:onGoldDraw()
        end,
        cost = LimitHeroModel.costGold(),
        removeListener = function()
            --更新当前界面
            self:update()
        end,
        -- luck
    })

    self:showTip()

    if param.isFree == 1 then
        --需要提示玩家下一次抽限时神将是收费抽取
        ResMgr.showMsg(20,1.5)
    end



    local ZHAOJIANG_LAYER_TAG = 102222

    zhaojiangLayer:setTag(ZHAOJIANG_LAYER_TAG)
    display.getRunningScene():removeChildByTag(ZHAOJIANG_LAYER_TAG, true)

    display.getRunningScene():addChild(zhaojiangLayer, 50)
    
end

function LimitHeroLayer:showTip()
    if LimitHeroModel.luckNum() >= 100 then
        local firstResId =  self.heroList[1]
        local heroData = ResMgr.getCardData(firstResId)

        show_tip_label(ResMgr.getMsg(19)..heroData.name)

    elseif LimitHeroModel.getLuckNumThisTime() > 0 then
        show_tip_label("幸运加"..LimitHeroModel.getLuckNumThisTime())
    end    
end

function LimitHeroLayer:onFreeDraw()
    if self.isActStop == true then
        show_tip_label("活动结束")
        return
    end

    if LimitHeroModel.getIsAllowFreeDraw() then
        LimitHeroModel.sendFreeDraw({callback = function() 
            self:createDrawSuccessLayer({isFree = 1})
            end})
    else
        -- show_tip_label("时间未到")
        ResMgr.showMsg(18)
    end
end

function LimitHeroLayer:onGoldDraw()
    if self.isActStop == true then
        show_tip_label("活动结束")
        return
    end

    if LimitHeroModel.isAllowGoldDraw() then
        LimitHeroModel.sendGoldDraw({callback = function()
            self:createDrawSuccessLayer({isFree = 0})
            end})
    else
        show_tip_label("元宝不足")
    end
end

function LimitHeroLayer:update()
    self:updateFreeDrawSchedule()
    self:updateLuckBar()
    self:updateDownNode()
end

function  LimitHeroLayer:onExit()
   
     self.scheduler.unscheduleGlobal(self.timeData)
end


 return LimitHeroLayer 


