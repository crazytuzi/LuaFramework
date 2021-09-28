local DungeonNpcLayer = class("DungeonNpcLayer", UFCCSModelLayer)

function DungeonNpcLayer.create(bgTexture, ...)
    return DungeonNpcLayer.new("ui_layout/dungeon_DungeonNpc.json",nil, bgTexture, ...)
end

function DungeonNpcLayer:ctor(json,color,bgTexture,...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    self:setBackColor(ccc4(0,0,0,200))
    self:getLabelByName("Label_BottomText"):setText(G_lang:get("LANG_DUNGEON_GRILTALK"))
    
    local bottomPanel = self:getPanelByName("Panel_KnightBottom")
    -- 蔡文姬
    local _info = knight_info.get(40040)
    --self:getLabelByName("Label_BottomName"):setText(_info.name)
    local head = require("app.scenes.common.KnightPic").getHalfNode(_info.res_id,0, true)
    bottomPanel:addNode(head)
    head:setPositionX(bottomPanel:getContentSize().width*0.35)
    head:setPositionY(bottomPanel:getContentSize().height*0.4)
    --self:registerBtnClickEvent("Button_Leave",handler(self, self._onLeave))
    --self:registerBtnClickEvent("Button_Back",handler(self, self._onBack))
    
--    local data = dungeon_chapter_info.get(G_Me.dungeonData:getCurrChapterId())
--    local _storydata = story_dungeon_info.get(data.story_id)
--    if _data then
--        local labelTTF = self:getLabelByName("Label_OpenStoryDungeon")
--        labelTTF:setText(G_lang:get("LANG_DUNGEON_OPNESTORYDUNGEON",{name=_storydata.name}))
--        labelTTF:setVisible(true)
--    end
    self:getLabelByName("Label_GoToNext"):setText(G_lang:get("LANG_DUNGEON_GOTONEXTCHAPTER"))
    self:getImageViewByName("Image_Bg"):loadTexture(bgTexture)
end

function DungeonNpcLayer:onLayerEnter(...)
    self:playAnimation("show",function(name,_status)
        if name == "show" and  _status == kAnimationFinish then
            self:registerTouchEvent(false,true,0)
            self:getLabelByName("Label_GoToNext"):setVisible(true)
        end

    end)
end

function DungeonNpcLayer:onTouchEnd()
    uf_sceneManager:popToRootScene()
    uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
    self:unregisterTouchEvent()
end

function DungeonNpcLayer:_onBack(widget)
    if widget:getOpacity() > 0 then

    end
end

function DungeonNpcLayer:_onLeave(widget)
    if widget:getOpacity() > 0 then
     self:close()
    end
end

function DungeonNpcLayer:onLayerExit()
end

return DungeonNpcLayer

