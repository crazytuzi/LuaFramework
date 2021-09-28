local HardDungeonSubtitleLayer = class("HardDungeonSubtitleLayer", UFCCSModelLayer)

function HardDungeonSubtitleLayer.create(bgTexture, ...)
    return HardDungeonSubtitleLayer.new("ui_layout/dungeon_DungeonSubtitleLayer.json", nil, bgTexture, ...)
end


function HardDungeonSubtitleLayer:ctor(json,color,bgTexture,...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    self.strList = {}
    self._timer  = nil
    self._isFirstEnter = G_Me.hardDungeonData:isFirstEnter(G_Me.hardDungeonData:getCurrChapterId())

    local data = hard_dungeon_chapter_info.get(G_Me.hardDungeonData:getCurrChapterId())
    self.desc = data.direction or ""
    local nameLabel = self:getLabelByName(self._isFirstEnter == true and "Label_CaptionEnd" or "Label_Caption")
    self.title = G_lang:get("LANG_DUNGEON_CHAPTERCAPTION",{num=GlobalFunc.numberToChinese(data.id or 1),name = data.name or ""})
    
    -- 通关不需要标题做动画
    if self._isFirstEnter == true then
        nameLabel:setText(self.title)
        self:splitStr(self.desc)
    else
        self:splitStr(self.title)
    end
    nameLabel:createStroke(Colors.strokeBrown, 1)
    
    self:getImageViewByName("Image_32"):setVisible(not self._isFirstEnter)
    
    local sanguozhiLabel = self:getLabelByName("Label_Name")
    sanguozhiLabel:setText(GAME_PACKAGE_NAME)
    sanguozhiLabel:createStroke(Colors.strokeBrown, 1)   

--    local seq = transition.sequence({CCDelayTime:create(0.2),
--    CCShow:create(),
--    CCDelayTime:create(0.2),
--    CCCallFunc:create(handler(self, self.startShowDesc))})
--    nameLabel:runAction(seq)
    self:startShowDesc()
    
    self._finishPlayText = false
    self._finishClick = false
    self:registerTouchEvent(false,true,0)
    if bgTexture then
        self:getImageViewByName("Image_Bg"):loadTexture(bgTexture)
    else
        self:getImageViewByName("Image_Bg"):setVisible(false)
    end
    
    self:getLabelByName("Label_GoToNext"):setText(G_lang:get("LANG_DUNGEON_GOTONEXTCHAPTER"))
    
end

function HardDungeonSubtitleLayer:onLayerExit()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function HardDungeonSubtitleLayer:startShowDesc()
    -- 打完最后一个怪才显示对话
    if  self._isFirstEnter == true then 
        local desc = self.strList[1] or ""
        local num = 1
        local descLabel = self:getLabelByName("Label_Txt")
        descLabel:setVisible(true)
        descLabel:setText(desc)
        descLabel:createStroke(Colors.strokeBrown, 1)
        self._timer = G_GlobalFunc.addTimer(0.05,function()
            --descLabel:sets
            num = num + 1
            desc =desc  .. (self.strList[num] or "")
            descLabel:setText(desc)

            if num == #self.strList then
                if self._timer then
                        G_GlobalFunc.removeTimer(self._timer)
                        self._timer = nil
                end
                self:showPassAction()
            end
        end
            )
    else
        -- 首次进入章节
        local num = 1
        local nameLabel = self:getLabelByName("Label_Caption")
        local desc = self.strList[1] or ""
        self._timer = G_GlobalFunc.addTimer(0.05,function()
            num = num + 1
            desc =desc  .. (self.strList[num] or "")
            nameLabel:setText(desc)

            if num == #self.strList then
                if self._timer then
                     G_GlobalFunc.removeTimer(self._timer)
                    self._timer = nil
                end

                self._finishPlayText = true
                local imgContinue = self:getImageViewByName("Image_Continue")
                imgContinue:setVisible(true)
                imgContinue:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
            end
        end
            )

    end
end

-- 显示通关动画
function HardDungeonSubtitleLayer:showPassAction()
    local img = self:getImageViewByName("Image_Pass")
    img:setScale(5.0)
    img:setVisible(true)
    local scaleAction = CCScaleTo:create(0.3,1)
    local arr = CCArray:create()
    arr:addObject(CCEaseBackOut:create(scaleAction))
    
    arr:addObject(CCCallFunc:create(function() 
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.STAR_SOUND)
        local GoToNext = self:getLabelByName("Label_GoToNext")
        GoToNext:setVisible(true)
        GoToNext:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))

        self._finishPlayText = true

--        if self._finishClick then
--            self:_doExitLayer()
--        end
    end))
    
    img:runAction(CCSequence:create(arr))
end

function HardDungeonSubtitleLayer:splitStr(str)
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        self.strList[#self.strList+1] = uchar 
    end
end

function HardDungeonSubtitleLayer:onTouchEnd()
    self._finishClick = true
    if not self._finishPlayText then 
        return 
    end
    
    if self._isFirstEnter == true then -- 前往主线副本主页面
        uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
    end
    self:_doExitLayer()
end

function HardDungeonSubtitleLayer:_doExitLayer( ... )
    if self.__EFFECT_FINISH_CALLBACK__ then 
        self.__EFFECT_FINISH_CALLBACK__()
        self.__EFFECT_FINISH_CALLBACK__ = nil 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_CLOSESUBTITLElAYER, nil, false,nil)
    self:unregisterTouchEvent()
    self:close()
end

return HardDungeonSubtitleLayer

