require("app.cfg.story_dialogue")
require("app.cfg.knight_info")
require("app.cfg.monster_info")
local _knightPic = require("app.scenes.common.KnightPic")
local HardDungeonStoryTalkLayer = class("HardDungeonStoryTalkLayer", UFCCSModelLayer)


local delayTime = 0.5

local MoveStatus = 
{
    STATUS_SHOW = 1,     --出现
    STATUS_HIDE = 2,    --隐藏    
    STATUS_STAND = 3,   --站立
    STATUS_JUMP = 4,
}

local RolePosList = 
{
    [1] = {startPos = ccp(-200,120),endPos=ccp(140,120)},
    [2] = {startPos = ccp(320,-100),endPos=ccp(320,120)},
    [3] = {startPos = ccp(640,120),endPos=ccp(500,120)},
}

local FacePosList = 
{
  [1] = 140,
  [2] = 320,
  [3] = 500,
}

function HardDungeonStoryTalkLayer:ctor(json,obj,data,...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    
    self._storyId = data.storyId
--    self._storyId = 2021
    self._callback = nil 
    if data and data.func  then
        self._callback = data.func
    end
    self._moveY = 0
    self._step = 1
    self.talkitemPanel = require("app.scenes.harddungeon.HardDungeonStoryTalkItemPanel").new()
    self.clippPanel = self:getPanelByName("Panel_Clipp")
    self.clippPanel:addChild(self.talkitemPanel)
    self.talkitemPanel:setSize(self.clippPanel:getSize())
    self.talkitemPanel:setPosition(ccp(0,self.clippPanel:getSize().height))

    self:registerTouchEvent(false,true,0)
    
    self.Role = {}
    self.lastTalkId = 0
    -- 表情符号列表
    self.Face = {}
    local data = story_dialogue.get(self._storyId,self._step)
    self.SceneBg = self:getImageViewByName("Image_Bg")
    self.SceneBg:setScale(2)
    if data then
        self.SceneBg:loadTexture(data["background"])
    end
    
    self.RolePanel = self:getPanelByName("Panel_Role")

    local array = CCArray:create()
    array:addObject(CCRotateTo:create(100,180))
    array:addObject(CCRotateTo:create(100,360))
    self:getImageViewByName("Image_Circle"):runAction(CCRepeatForever:create(CCSequence:create(array)))
end



function HardDungeonStoryTalkLayer:onLayerEnter( ... )
    self:showBgAction(true)
    __Log("HardDungeonStoryTalkLayer:onLayerEnter isRunnint:%d", self:isRunning() and 1 or 0)
end

-- 背景动画
function HardDungeonStoryTalkLayer:showBgAction(isUp)
    local baseBg = self:getImageViewByName("Image_Base")  
    local arr = CCArray:create()
    if baseBg then
        local startposY  
        local endPosY
        local size = baseBg:getSize()
        if isUp== true then
            startposY = -size.height
            endPosY = 0
        else
             startposY = 0
             endPosY = -size.height
            arr:addObject(CCCallFunc:create(function()
                for i=1,3 do
                    if self.Face[i] and self.Face[i]:getOpacity() == 255 then
                        self:showFaceAction(self.Face[i],MoveStatus.STATUS_HIDE)
                    end
                    if self.Role[i] then
                        self:move(self.Role[i], i, MoveStatus.STATUS_HIDE,ccc3(255,255,255),false)
                    end
                end
                end))
                arr:addObject(CCDelayTime:create(delayTime))
        end
    
        baseBg:setPositionY(startposY)
        arr:addObject(CCMoveTo:create(0.3,ccp(0,endPosY)))
        arr:addObject(CCCallFunc:create(function()
            if isUp== true then
                self:_showTalk()
            else
                if self._callback then
                        self._callback()
                end
               self:close() 
            end
        end
            ))
        baseBg:runAction(CCSequence:create(arr))
    end
end

function HardDungeonStoryTalkLayer.create(data)
    return require("app.scenes.common.StoryTalkLayer").create(data)
    -- uf_sceneManager:getCurScene():addChild(require("app.scenes.common.StoryTalkLayer").create(
    --                 {storyId = 2028, func = function ( ... )
    --                 __Log("_onEquipment")
    --         end }))
    --return HardDungeonStoryTalkLayer.new("ui_layout/dungeon_DungeonStoryTalkLayer.json",Colors.modelColor,data)
end



-- @desc 显示对话
function HardDungeonStoryTalkLayer:_showTalk()
    local data = story_dialogue.get(self._storyId,self._step)
    if data then
        if data.res_id == "0" then
            local name,pos = self:showRole({data["monster_id_1"],data["monster_id_2"],data["monster_id_3"]},
            {data["toward_1"],data["toward_2"],data["toward_3"]},data["monster_id_0"])
            self.talkitemPanel:createItem(name,data["substance"],pos,data["dialogue_type"])
            self:showFace({data["face_1"],data["face_2"],data["face_3"]})
        else
            self:_showProp(data)
        end

    else
        self:callAfterFrameCount(1, function ( ... )
            --self:setVisible(false
            self:unregisterTouchEvent()
            --self:registerTouchEvent(false,false,0)
            if self:getPanelByName("Panel_Prop"):isVisible() == true then
                self:_jumpProp()
            else
                self:showBgAction(false)
            end
         end)
    end
    self._step = self._step + 1
end

-- 显示道具特效
function HardDungeonStoryTalkLayer:_showProp(data)
    self.talkitemPanel:setClick(false)
    local panl_Prop = self:getPanelByName("Panel_Prop")
    panl_Prop:setVisible(true)
    local prop = self:getImageViewByName("Image_Prop")
    prop:loadTexture(data.res_id)
    prop:setScale(0)
    self:getLabelByName("Label_PropDesc"):setText(data.txt)
    self:getLabelByName("Label_PropDesc"):setVisible(true)
    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5,1),CCRotateTo:create(0.5,3600)))
    --array:addObject(CCDelayTime:create(1))
    array:addObject(CCCallFunc:create(function()
        self.talkitemPanel:setClick(true)
    end))
    prop:runAction(CCSequence:create(array))
    
    if data.effect ~= "0" then
        local img = self:getImageViewByName("Image_Effect")
        local lightEffect = require("app.common.effects.EffectNode").new(data.effect)
        --lightEffect:setPosition(prop:getPositionInCCPoint())
        img:addNode(lightEffect,0,10)
        lightEffect:play()
    end

             
end

-- 道具跳动动画
function HardDungeonStoryTalkLayer:_jumpProp()
    self:getLabelByName("Label_PropDesc"):setVisible(false)
   local img = self:getImageViewByName("Image_Effect")
    local lightEffect = img:getNodeByTag(10)
    if lightEffect then
        lightEffect:setVisible(false)
    end
    local prop = self:getImageViewByName("Image_Prop")
    local pt = prop:getPositionInCCPoint()
    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5,0),CCSpawn:createWithTwoActions(CCRotateTo:create(0.5,3600),CCJumpTo:create(0.5, ccp(pt.x-180,pt.y - 300), 100, 1))))
    array:addObject(CCCallFunc:create(function()
        self:getPanelByName("Panel_Prop"):setVisible(false)
        self:showBgAction(false)
    end))
    prop:runAction(CCSequence:create(array))
end

function HardDungeonStoryTalkLayer:onLayerLoad( ... )
end

function HardDungeonStoryTalkLayer:onTouchEnd(x,y)
    if math.abs(self._moveY-y) < 5 then
        if self.talkitemPanel:isClick() == true then
                self:_showTalk()
        else
            if self.talkitemPanel:isSkip() == false then
                self.talkitemPanel:setIsSkip(true)
            end
        end
    end
    self._moveY = 0
end

function HardDungeonStoryTalkLayer:onTouchBegin(x,y)
    self._moveY = y
end

function HardDungeonStoryTalkLayer:onTouchMove(x,y)
    local pt = ccp(x,y)
    if  G_WP8.CCRectContainPt(self.clippPanel:getCascadeBoundingBox(), pt) then
    --if self.clippPanel:getCascadeBoundingBox():containsPoint(pt) then
        if math.abs(pt.y - self._moveY) > 10 then
            self.talkitemPanel:touchMovePanel(math.abs(pt.y -self._moveY)/(pt.y - self._moveY))
        end
    end
end

function HardDungeonStoryTalkLayer:onLayerExit()
    self._callback  = nil
end

function HardDungeonStoryTalkLayer:showFace(resId)
    for i=1,3 do
        if resId[i] ~= 0 then
            if self.Face[i] == nil then
                self.Face[i] = ImageView:create()
                self.RolePanel:addChild(self.Face[i],4)
                --self.Face[i]:setPosition(FacePosList[i])
            end
            self.Face[i]:loadTexture(G_Path.getFaceIco(resId[i]))
             self:showFaceAction(self.Face[i],MoveStatus.STATUS_SHOW)
             self.Face[i]:setTag(resId[i])
        else
            if self.Face[i] and self.Face[i]:getTag() ~= 0 then
                self:showFaceAction(self.Face[i],MoveStatus.STATUS_HIDE)
                self.Face[i]:setTag(0)
            end
        end
        
        -- 设置笑脸位置
        if self.Face[i] and self.Role[i] then
            local sprite = self.Role[i]:getChildByTag(1)
            if sprite then
                local rect = sprite:getCascadeBoundingBox()
                self.Face[i]:setPosition(ccp(FacePosList[i], 230))
            end
        end

    end
end

function HardDungeonStoryTalkLayer:showFaceAction(face,_status)
    if _status == MoveStatus.STATUS_SHOW then
        face:setScale(0.2)
        face:runAction(CCSpawn:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(delayTime,1)),CCFadeIn:create(delayTime)))
    else
        face:runAction(CCFadeOut:create(delayTime))
    end
end

-- 人物创建
function HardDungeonStoryTalkLayer:showRole(monsterId,toward,talkRoleId)
    local name = "" 
    local pos = 0
    for i=1,3 do
       
       local  resId = 0
       if monsterId[i] == 1 then -- 主角
            local knight_id ,baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
            local _info  = knight_info.get(baseId)
            if _info then
                -- resId = _info.res_id
                resId = G_Me.dressData:getDressedPic()
                name = _info.name
            end
            if talkRoleId == monsterId[i] then
                pos = i
            end
       else
           if monsterId[i] > 0 then --怪物
                local _info = monster_info.get(monsterId[i])
                resId = _info.res_id
                if talkRoleId == monsterId[i] then
                    name = _info.name
                    pos = i
                end
           end
       end
        local color = talkRoleId == monsterId[i] and ccc3(255,255,255) or ccc3(100,100,100)
        if  resId ~= 0 then
             -- 创建一个新人物
            if self.Role[i] == nil then
                self.Role[i] = require("app.scenes.common.KnightPic").getHalfNode(resId,0, true)
                self.RolePanel:addNode(self.Role[i])
                self:move(self.Role[i], i, MoveStatus.STATUS_SHOW,color,talkRoleId == monsterId[i])
                self.Role[i]:setTag(monsterId[i])
            else
                --不是同一个角色
                if self.Role[i]:getTag() ~= monsterId[i] then
                    self.Role[i]:removeFromParentAndCleanup(true)
                    self.Role[i]= nil
                    self.Role[i] = require("app.scenes.common.KnightPic").getHalfNode(resId,0, true)
                    self.RolePanel:addNode(self.Role[i])
                    self:move(self.Role[i], i, MoveStatus.STATUS_SHOW,color,talkRoleId == monsterId[i])
                    self.Role[i]:setTag(monsterId[i])
                else
                    -- 同一个角色
                    if talkRoleId == monsterId[i] and self.lastTalkId ~= talkRoleId then
                        self:move(self.Role[i], i, MoveStatus.STATUS_JUMP,color)
                    else
                        self:move(self.Role[i], i, MoveStatus.STATUS_STAND,color)
                    end
                end
            end
            if toward[i] ~= 0 then
                self.Role[i]:setScaleX(-1)
            end
            self.Role[i]:setZOrder(talkRoleId == monsterId[i] and 2 or 1)

        else
            if self.Role[i] and self.Role[i]:getTag() ~= 0 then
                self.Role[i]:setTag(0) 
                self:move(self.Role[i], i, MoveStatus.STATUS_HIDE,color)
                --角色消失
            end
        end
    end
    self.lastTalkId = talkRoleId
    return name,pos
end

-- 角色移动
function HardDungeonStoryTalkLayer:move(role,_posType,_status,color,isJump)
    local startPos = ccp(0,100)

    local sprite = role:getChildByTag(1)
    if sprite then
       sprite = tolua.cast(sprite, CCSPRITE)
        role:setColor(color)
    end
    if _status == MoveStatus.STATUS_SHOW then
        --出现
        role:setPosition(RolePosList[_posType].startPos)
        
        role:setScale(0.8)
        role:setCascadeOpacityEnabled(true)
        startPos = role:getPositionInCCPoint()
        local jumpUp = CCJumpBy:create(0.2,ccp(0,0) , 15, 1)
        local arr = CCArray:create()
        arr:addObject(CCEaseBackOut:create(CCMoveTo:create(delayTime,RolePosList[_posType].endPos)))
        if isJump == true then
            arr:addObject(jumpUp)
        end
        role:runAction(CCSequence:create(arr))
    elseif _status == MoveStatus.STATUS_HIDE then
        -- 隐藏
        role:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(delayTime,RolePosList[_posType].startPos),CCFadeOut:create(delayTime)))
    elseif _status == MoveStatus.STATUS_JUMP then 
        -- 原地跳
        local arr = CCArray:create()
        local jumpUp = CCJumpBy:create(0.2,ccp(0,0) , 15, 1)
        arr:addObject(jumpUp)
        role:runAction(CCSequence:create(arr))
    end
end

return HardDungeonStoryTalkLayer