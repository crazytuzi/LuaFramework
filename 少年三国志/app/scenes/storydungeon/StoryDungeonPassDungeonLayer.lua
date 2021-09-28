local StoryDungeonPassDungeonLayer = class("StoryDungeonPassDungeonLayer",UFCCSModelLayer)

function StoryDungeonPassDungeonLayer:ctor(...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
    
    self:getLabelByName("Label_Desc"):setText(G_lang:get("LANG_STORYDUNGEON_PASSBOUNSDESC"))
    self:getLabelByName("Label_Desc"):createStroke(Colors.strokeBrown,1)
        
    local bottomPanel = self:getPanelByName("Panel_Knight")
    
    local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    -- 小乔
    local head = require("app.scenes.common.KnightPic").getHalfNode(_barrierInfo.res_id,0, true)
    bottomPanel:addNode(head)
    head:setPositionX(bottomPanel:getContentSize().width*0.4)
    head:setPositionY(bottomPanel:getContentSize().height*0.57)

    self:getLabelByName("Label_Name"):setColor(Colors.getColor(_barrierInfo and _barrierInfo.quality or 1))

    self:getLabelByName("Label_Name"):setText(_barrierInfo.name)
    --self:getLabelByName("Label_Name"):createStroke(Colors.strokeBrown,1)
    self:getImageViewByName("Image_YuanBao"):loadTexture(G_Path.getBasicIconGold())
    -- 元宝
    self:getLabelByName("Label_Money"):setText(_barrierInfo.first_down_money .. G_lang:get("LANG_STORYDUNGEON_YUANBAO"))
    
    self:getImageViewByName("Image_Continue"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
end

function StoryDungeonPassDungeonLayer.create()
    return StoryDungeonPassDungeonLayer.new("ui_layout/storydungeon_StoryDungeonPassDungeonLayer.json",Colors.modelColor)
end

function StoryDungeonPassDungeonLayer:onTouchEnd(xPos,yPos)
    self:animationToClose()
end

return StoryDungeonPassDungeonLayer

