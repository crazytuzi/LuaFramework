local _knightPic = require("app.scenes.common.KnightPic")
local TurnNode = require("app.scenes.common.turnplate.TurnNode")
local KnightTurnNode = class("KnightTurnNode", TurnNode)

require("app.cfg.title_info")

function KnightTurnNode.create(...)
    return KnightTurnNode.new("ui_layout/mainscene_Pedestal.json", ...)
end

function KnightTurnNode:ctor(...)
    self.super.ctor(self,...)
    self._resId = 0
    self._slotTag = 0 -- 阵容位
    self._image = nil
end

function KnightTurnNode:setData(knightId, baseId, slotIndex)

    self._slotTag = slotIndex
    self._baseId = baseId
    self._knightId = knightId

    local name = ""
    local quality = 0
    local resId = 0 
    local knightInfo = knight_info.get(baseId)
    if knightInfo then
        quality = knightInfo.quality
        resId = knightInfo.res_id
        name = knightInfo.name

    end
    --self:getImageViewByName("ImageView_Pedestal"):setVisible(false)
    local effectEnable = require("app.scenes.mainscene.SettingLayer").showEffectEnable()
    local _pedestal = self:getImageViewByName("ImageView_Pedestal")
    _pedestal:setVisible(not effectEnable)
    if resId == 0  then 
        -- _pedestal = tolua.cast(_pedestal,"ImageView")
        -- _pedestal:setTag(index)
        
        -- 显示是否可以上阵
        
        local levelArr = G_Me.userData:getTeamSlotOpenLevel()
        if G_Me.userData.level >= levelArr[self._slotTag] then
            local imgJia = self:getImageViewByName("ImageView_Jia")
            imgJia:setVisible(not effectEnable)
            local panel = self:getPanelByName("Panel_Light")
            if panel and effectEnable then
                 local secretShine = require("app.common.effects.EffectNode").new("effect_szts")
                 local size = _pedestal:getContentSize()
                panel:addNode(secretShine, 10)
                secretShine:setPosition(ccp(size.width/2,size.height/2))
                secretShine:play()
            end
        else
            _pedestal:loadTexture(G_Path.MainPage.PEDESTAL_LOCK)
            _pedestal:setVisible(true)
        end
        return
    end

    local _knightNode = self:getPanelByName("Panel_Knight")
    _knightNode:setVisible(true)

    -- 称号背景图片
    local titleBg = nil

    if knightId == G_Me.formationData:getMainKnightId() then 
        resId = G_Me.dressData:getDressedPic()

        -- 主角头顶添加称号
        if G_Me.userData:getTitleId() > 0 then
            local titleInfo = title_info.get(G_Me.userData.title_id)
            titleBg = ImageView:create()
            titleBg:loadTexture(titleInfo.picture, UI_TEX_TYPE_LOCAL)
            titleBg:setPosition(ccp(-20, 380))

            local titleLabel = Label:create()
            titleLabel:setFontName("ui/font/FZYiHei-M20S.ttf")
            titleLabel:setFontSize(32)
            titleLabel:setText(titleInfo.name)
            titleLabel:setColor(Colors.getColor(titleInfo.quality))
            titleLabel:createStroke(Colors.strokeBrown, 3)
            titleLabel:setPosition(ccp(0, 0))

            titleBg:addChild(titleLabel) 
            titleBg:setScale(1.3) 
        elseif G_Me.bagData:isTitleOutOfDate(G_Me.userData.title_id) then
            -- 称号过期，刷新战力
            G_HandlersManager.titleHandler:sendUpdateFightValue()
        end
    end
    self._image = _knightPic.createKnightNode(resId, "sprite_" .. self._slotTag, true)
    --pSprite:setTag(index)
    self._image:setScale(0.8)
    _knightNode:addNode(self._image)
    -- 在这里添加使称号不被人物遮挡
    if titleBg then        
        -- 加特效
        local starEffect = require("app.common.effects.EffectNode").new("effect_chenhao_star")
        titleBg:addNode(starEffect)
        starEffect:setScale(1.5)
        starEffect:play()
        
        self._image:addChild(titleBg)
    end

    -- --侠客呼吸动作
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    EffectSingleMoving.run(self._image, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))



    --    将名字转换成单个字符
    local _listChar = self:convertKnightName(name)

    local Panel_Name = self:getPanelByName("Panel_Name")
    local _height = 0
    local _panelHeight = Panel_Name:getContentSize().height
    -- 设置名字
    for i=1,6 do
        local _nameLabel = self:getLabelByName("Label_Name" .. i)
        -- _nameLabel = tolua.cast(_nameLabel,"Label")
        if _nameLabel and _listChar[i] then
            -- 这里-6使字间距变小了
            _nameLabel:setPositionY(_panelHeight - _height - 6)
            if quality ~= nil then
                _nameLabel:setColor(Colors.qualityColors[quality])
            end
            _nameLabel:setText(_listChar[i])
            -- 这里-6使字间距变小了
            _height = _height + _nameLabel:getContentSize().height - 6
            --_nameLabel:createStroke(Colors.strokeBrown,1)
        end
    end

    local lenth = #_listChar> 6 and 6 or #_listChar
    local y = -((6-lenth)/6*_panelHeight)/2 -_panelHeight/2
    Panel_Name:setPositionY(y)

end


-- 更改主角名
function KnightTurnNode:changeName(  )
    local knightInfo = knight_info.get(self._baseId)
    local quality = 0
    local name = ""
    if knightInfo then
        quality = knightInfo.quality
        name = knightInfo.name
    end

    for i=1,6 do
        local nameLabel = self:getLabelByName("Label_Name" .. i)
        nameLabel = tolua.cast(nameLabel,"Label")
        if nameLabel then
            nameLabel:setText("") 
        end
    end

    --    将名字转换成单个字符
    local listChar = self:convertKnightName(name)

    local panelName = self:getPanelByName("Panel_Name")
    local height = 0
    local panelHeight = panelName:getContentSize().height
    -- 设置名字
    for i=1,6 do
        local nameLabel = self:getLabelByName("Label_Name" .. i)
        nameLabel = tolua.cast(nameLabel,"Label")
        if nameLabel and listChar[i] then
            -- 这里-6使字间距变小了
            nameLabel:setPositionY(panelHeight - height - 6)
            if quality ~= nil then
                nameLabel:setColor(Colors.qualityColors[quality])
            end
            nameLabel:setText(listChar[i])
            -- 这里-6使字间距变小了
            height = height + nameLabel:getContentSize().height - 6
        end
    end

    local lenth = #listChar> 6 and 6 or #listChar
    local y = -((6-lenth)/6*panelHeight)/2 -panelHeight/2
    panelName:setPositionY(y)
end


-- @字符串转换
function KnightTurnNode:convertKnightName(strName)
   
    local name_t = {}
    for uchar in string.gfind(strName, "[%z\1-\127\194-\244][\128-\191]*") do 
        name_t[#name_t+1] = uchar 
        if #name_t >= 6 then
            break
         end
    end
    return name_t
end

function KnightTurnNode:setImageScale(s)
    self:getRootWidget():setScale(s)
end

function KnightTurnNode:hasKnight()
    return self._knightId ~= 0
end

function KnightTurnNode:getSlotTag()
    return self._slotTag
end

function KnightTurnNode:getSomethingToSay()
    local knightInfo = knight_info.get(self._baseId)
    if knightInfo then
        return knightInfo.statement
    else
        return ""
    end
end

function KnightTurnNode:playKnightCommonAudio( ... )
    local knightInfo = knight_info.get(self._baseId)
    if knightInfo and type(knightInfo.common_sound) == "string" and #knightInfo.common_sound > 3 then 
        G_SoundManager:playSound(knightInfo.common_sound)
    end
end

function KnightTurnNode:stopKnightCommonAudio( ... )
    local knightInfo = knight_info.get(self._baseId)
    if knightInfo and type(knightInfo.common_sound) == "string" and #knightInfo.common_sound > 3 then 
        G_SoundManager:stopSound(knightInfo.common_sound)
    end
end

--pt是个世界坐标, 判断Pt是否落在KnightTurnNode 上
function KnightTurnNode:containsPt(pt)
    local image 
    if self:hasKnight() then
        image = self._image.imageNode 
    else
        image = self:getPanelByName("Panel_Light")
    end



    if image == nil then
        return false
    end

 
    local imagePt = image:convertToNodeSpace(  pt  )
    --print("ptx=" .. imagePt.x .. ",pty=" .. imagePt.y)
    local size = image:getContentSize()
    local w = size.width*image:getScaleX()
    local h = size.height*image:getScaleY()

    local rect = CCRectMake(-w/2, -h/2, w, h)
    if not self:hasKnight() then
        rect = CCRectMake(0, 0, w, h)
    end
    --return rect:containsPoint(imagePt)
    return G_WP8.CCRectContainPt(rect, imagePt)
end


return KnightTurnNode
