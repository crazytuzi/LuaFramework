local DungeonOpenNewChapterLayer = class("DungeonOpenNewChapterLayer", UFCCSModelLayer)

function DungeonOpenNewChapterLayer.create(...)
    return DungeonOpenNewChapterLayer.new("ui_layout/dungeon_DungeonOpenNewChpater.json",Colors.modelColor, ...)
end

function DungeonOpenNewChapterLayer:ctor(json, color, ...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    local data = dungeon_chapter_info.get(G_Me.dungeonData:getOpenNewChapterId())
    self:getLabelByName("Label_ChapterName"):setText(data.name)

    data = dungeon_chapter_info.get(G_Me.dungeonData:getCurrChapterId())
     self:getLabelByName("Label_OldChpaterName"):setText(data.name)

     local size = CCDirector:sharedDirector():getWinSize()
     self:getImageViewByName("ImageView_NewChpater"):setVisible(false)
     self:getImageViewByName("ImageView_NewChpater"):setPositionY(853-size.height)
     self:getImageViewByName("ImageView_NewChpater"):setPositionX(size.width/2)
     
    local array = CCArray:create()
    array:addObject(CCFadeTo:create(1,150))
    array:addObject(CCFadeTo:create(1,255))
    array:addObject(CCDelayTime:create(1))
    self:getImageViewByName("Image_10"):runAction(CCRepeatForever:create(CCSequence:create(array)))
     
     self:getImageViewByName("Image_Star5"):runAction(
     CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
     
     self:getImageViewByName("Image_Star2"):runAction(
     CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.4), CCFadeOut:create(0.4))))
     
     self:getImageViewByName("Image_Star7"):runAction(
     CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6))))
     
     self:getImageViewByName("Image_Star10"):runAction(
     CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
     
     self:getImageViewByName("Image_Continue"):setVisible(false)
end

function DungeonOpenNewChapterLayer:onLayerEnter(...)
    local oldChpater = self:getImageViewByName("Image_ChapterName")
    oldChpater:setOpacity(0)
    local sequence = transition.sequence({CCDelayTime:create(0.6),CCFadeIn:create(0.5),
    CCCallFunc:create(handler(self,self.showEffect))})
    oldChpater:runAction(sequence)    
end

function DungeonOpenNewChapterLayer:showEffect()
        self:_playEffect()
end

-- 播放盖章
function DungeonOpenNewChapterLayer:_playEffect()
    
    local EffectNode = require "app.common.effects.EffectNode"
    
    self.sealEffectNode = EffectNode.new("effect_tongguan", function(event, frameIndex)
        if event == "finish" then
            --self.sealEffectNode:removeFromParentAndCleanup(true)
            self:playAnimation()
        elseif event == "appear" then
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.STAR_SOUND)
            self:sendShake()
        end
            end)           
    self.sealEffectNode:play()
    self:getPanelByName("Panel_Seal"):addNode(self.sealEffectNode,10)
end

-- 显示新章节动画
function DungeonOpenNewChapterLayer:playAnimation()
        -- 旧章节消失
        local oldChpater = self:getImageViewByName("Image_ChapterName")
        oldChpater:runAction(transition.sequence({CCDelayTime:create(1.5),CCFadeOut:create(0.5)}))
        
        local sequence = transition.sequence({CCDelayTime:create(1),
        CCCallFunc:create(handler(self,self.showNewChpaterAnimation)),CCFadeOut:create(0.5)})
        self.sealEffectNode:runAction(sequence)    
end

-- 新章节动画
function DungeonOpenNewChapterLayer:showNewChpaterAnimation()
    
    self:getImageViewByName("ImageView_NewChpater"):setVisible(true)
    self:getImageViewByName("ImageView_NewChpater"):setScale(6)
    -- 新章节动画
    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.3,0.8))
    array:addObject(CCCallFunc:create(handler(self,self.sendShake)))
    array:addObject(CCScaleTo:create(0.1,1))
    array:addObject(CCCallFunc:create(handler(self,self._showTalk)))
    local seqAction = CCSequence:create(array)
    self:getImageViewByName("ImageView_NewChpater"):runAction(seqAction)  
    -- 旧章节动画
end

function DungeonOpenNewChapterLayer:sendShake()
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.STAR_SOUND)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_SHOWSHAKE, nil, false,nil)
end
function DungeonOpenNewChapterLayer:_showTalk()
    self:getImageViewByName("Image_Continue"):setVisible(true)
    self:getImageViewByName("Image_Continue"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
    self:registerTouchEvent(false,true,0)
end

function DungeonOpenNewChapterLayer:onTouchEnd(xPos,yPos)
    local _parent = self:getParent()
    if G_Me.dungeonData:getCurrChapterId() == 3 or G_Me.dungeonData:getCurrChapterId() == 12 then
        local HeroQualityResult = require("app.scenes.common.HeroQualityResult")
        HeroQualityResult.showHeroQualityResult(
            function ( ... )
               _parent:addChild(require("app.scenes.dungeon.DungeonNpcLayer").create(),5)
            end
        )
    else
        self:getParent():addChild(require("app.scenes.dungeon.DungeonNpcLayer").create(),5)
    end
    self:close()
end

function DungeonOpenNewChapterLayer:onLayerExit( ... )
end

return DungeonOpenNewChapterLayer

