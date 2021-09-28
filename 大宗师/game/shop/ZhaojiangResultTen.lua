
--[[
 --
 -- add by vicky
 -- 2014.08.25
 --
 --]]

 --

 local ZhaojiangResultTen = class("ZhaojiangResultTen", function()
 		return require("utility.ShadeLayer").new()
 end)
--
-- function ZhaojiangResultTen:getOneHero(num)
-- 	if num ~= 1 and num ~= 10 then
-- 		CCMessageBox("购买数量，必须为1或10", "Tip")
-- 		return
-- 	end
--
-- 	RequestHelper.recrute({
--        callback = function(data)
--            dump(data)
--            if string.len(data["0"]) > 0 then
--                CCMessageBox(data["0"], "Tip")
--            else
--            	self._buyHeroCallback({
--            		type = self._type,
--            		num = num,
--            		herolist = data["1"],
--                    delayTime = data["2"],
--                    gold = data["3"]
--            		})
--            	self:removeFromParentAndCleanup(true)
--            end
--        end,
--        t = self._type,
--        n = num
--    })
-- end


 -- 卡牌背面
 function ZhaojiangResultTen:createCard()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shilianchouchuxian))
    local time = 0.1
    for i, v in ipairs(self._heroList) do 
        local key = "hero_" .. i .. "_icon"
        local card = self._rootnode[key]
        card:setVisible(false)
        card:setScale(1.3)
        card:setDisplayFrame(display.newSprite("#card_back.png"):getDisplayFrame())

        card:runAction(transition.sequence({
            CCDelayTime:create((i - 1) * time), 
            CCCallFuncN:create(function(node)
                    node:setVisible(true)
                end), 
            CCScaleTo:create(time, 0.8)
            }))
    end

    self:runAction(transition.sequence({
        CCDelayTime:create(#self._heroList * time), 
        CCCallFunc:create(function()
                self:refreshCardInfo()
            end)
        }))
 end


 -- 翻转卡牌
 function ZhaojiangResultTen:refreshCardInfo()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shilianchoufanzhuan))
    
    local time = 0.1
    local toScale = 0.37

    local function resetFrame(node)
        local tag = node:getTag()
        local id = self._heroList[tag].id
        local heroInfo = ResMgr.getCardData(id)
        local star = heroInfo.star[1]

        local namekey = "hero_" .. tag .. "_name"
        local nameBgKey = "hero_" .. tag .. "_namebg"
        local starKey = "hero_" .. tag .. "_star_" .. star

        ResMgr.refreshCardBg({ sprite = node, star = star, resType = ResMgr.HERO_BG_UI })
        node:setScale(toScale)

        local heroImg = heroInfo["arr_image"][1]
        local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getMidImage(heroImg, ResMgr.HERO))

        local icon = display.newSprite(heroPath)
        icon:setScale(2.5)
--        icon:setDisplayFrame(ResMgr.getMidImage(heroInfo.name, ResMgr.HERO):getDisplayFrame())
--        icon:setScale(0.7)
        icon:setPosition(node:getContentSize().width/2, node:getContentSize().height * 0.55 - 1)
        node:addChild(icon)

        node:runAction(CCScaleTo:create(time, toScale, toScale))

        self._rootnode[starKey]:setVisible(true)

        self._rootnode[namekey]:setString(heroInfo.name)
        self._rootnode[namekey]:setColor(NAME_COLOR[star])
        self._rootnode[nameBgKey]:setVisible(true)

        if star == 5 then
            local effectNode = self._rootnode["hero_" .. tag .. "_effect"]
            local effect = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT, 
                    armaName = "shilianchou_xunhuan", 
                    isRetain = true
                })
            
            local cntSize = effectNode:getContentSize()
            effect:setPosition(cntSize.width/2,cntSize.height/2)
            effectNode:addChild(effect)
        end
    end

    local delayTime = 0

    for i, v in ipairs(self._heroList) do
        local heroInfo = ResMgr.getCardData(v.id)
        local star = heroInfo.star[1]

        local iconKey = "hero_" .. i .. "_icon"
        local iconItem = self._rootnode[iconKey]
        iconItem:setTag(i)

        if star == 5 then 
            iconItem:runAction(transition.sequence({
                    CCDelayTime:create(delayTime), 
                    CCCallFuncN:create(function(node)
                            local effect = ResMgr.createArma({
                                resType = ResMgr.UI_EFFECT, 
                                armaName = "shilianchou_baoguang", 
                                isRetain = false
                                })
                            local cntSize = node:getContentSize()
                            effect:setPosition(cntSize.width/2,cntSize.height/2)
                            node:addChild(effect)
                        end), 
                    CCScaleTo:create(time/2, 1.1), 
                    CCScaleTo:create(time/2, 0.8), 
                    CCScaleTo:create(time, 0.01, 0.8), 
                    CCCallFuncN:create(resetFrame)
                }))

            delayTime = delayTime + 2 * time
        else
            iconItem:runAction(transition.sequence({
                    CCDelayTime:create(delayTime), 
                    CCScaleTo:create(time, 0.01, 0.8), 
                    CCCallFuncN:create(resetFrame)
                }))
            delayTime = delayTime + time
        end
    end
    self._rootnode["buyTenBtn"]:setEnabled(true)

 end

 function ZhaojiangResultTen:onExit()

    ResMgr.ReleaseUIArmature("shilianchou_xunhuan")
    ResMgr.ReleaseUIArmature("shilianchou_baoguang")

    if self.removeListener ~= nil then
        self.removeListener()
    end
 end


 function ZhaojiangResultTen:ctor(param) 
    self.removeListener = param.removeListener

     local bg = display.newSprite("ui/jpg_bg/zhaojiang_bg.jpg")
     bg:setScaleX(display.width / bg:getContentSize().width)
     bg:setScaleY(display.height / bg:getContentSize().height)
     bg:setPosition(display.cx, display.cy)
     self:addChild(bg)

     self:setNodeEventEnabled(true)

     local _type = param.type
     self._heroList = param.herolist
     self._buyHeroCallback = param.buyHeroCallback
     local _buyListener = param.buyListener

     self._rootnode = {}
     local proxy = CCBProxy:create()
     display.addSpriteFramesWithFile("ui/ui_zhaojiangResult.plist", "ui/ui_zhaojiangResult.png")

     local node = CCBuilderReaderLoad("shop/zhaojiang_ten.ccbi", proxy, self._rootnode)
     node:setPosition(display.width/2, display.height/2)
     self:addChild(node)

     self._rootnode["leftTimeLbl"]:setString(param.leftTime or 10)

     -- 退出
     self._rootnode["exitBtn"]:addHandleOfControlEvent(
         function(eventName,sender)
             GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
             self:removeFromParentAndCleanup(true)
             PostNotice(NoticeKey.CommonUpdate_Label_Gold)
         end,
         CCControlEventTouchUpInside)

     -- 购买1个
     self._rootnode["buyOneBtn"]:addHandleOfControlEvent(
         function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
         --            self:getOneHero(1)
             if _buyListener then
                 _buyListener(_type, _, 1, self)
             end
             -- self:removeSelf()
         end,
         CCControlEventTouchUpInside)

     -- 购买10个
     self._rootnode["buyTenBtn"]:setEnabled(false)
     self._rootnode["buyTenBtn"]:addHandleOfControlEvent(
         function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
         --            self:getOneHero(10)
             if _buyListener then
                 _buyListener(_type, _, 10, self)
             end

             -- self:removeSelf()
         end,
         CCControlEventTouchUpInside)

     self:createCard()

 end


 return ZhaojiangResultTen