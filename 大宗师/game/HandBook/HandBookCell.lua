

local HandBookCell = class("HandBookCell", function (data)
    return display.newNode()
end)

function HandBookCell:ctor(param)
    local cellData = param.cellData
    local cellStar = param.cellStar

    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local bgNode = CCBuilderReaderLoad("handbook/handbook_cell.ccbi", self._proxy, self._rootnode)
    self:addChild(bgNode) 

    local orX = -self._rootnode["cell_bg"]:getContentSize().width/2 + 75
    local orY = -45-self._rootnode["star_bg"]:getContentSize().height/2 - 40

    local curX = orX
    local curY = orY

    local arrId = cellData.data.arr_id
    local star = cellData.data.star

    for i = 1,5 do
        if i > star then
            self._rootnode["star_"..i]:setVisible(false)
        end
    end

    local resType = ResMgr.HERO
    local itemType = 8
    local item_hero_type = 8
    local item_equip_type = 1
    local item_wugong_type = 4

    if cellData.data.mainTab == 1 then
        resType = ResMgr.HERO
        itemType = item_hero_type
    elseif cellData.data.mainTab == 2 then
        resType = ResMgr.EQUIP
        itemType = item_equip_type
    elseif cellData.data.mainTab == 3 then
        resType = ResMgr.EQUIP
        itemType = item_wugong_type
    end

    local iconHeight = 105
    local iconCount = 1
    local exNum = 0 
    for i = 1,#arrId do
        local headIcon = display.newSprite()
        local isIconGray = true

        if (cellData.isExist)[i] == 1 then
            isIconGray = false
            exNum = exNum + 1
        end

        ResMgr.refreshItemWithTagNumName({
            id = arrId[i],
            itemBg = headIcon,
            resType = resType,
            isShowIconNum = 0,
            isGray = isIconGray,
            cls = 0
            })
        headIcon:setPosition(curX,curY)
        self:addChild(headIcon)

        if isIconGray ~= true then
            local touchNode = display.newNode()
            local iconWidth = headIcon:getContentSize().width
            local iconHeight = headIcon:getContentSize().height
            touchNode:setContentSize(iconWidth,iconHeight)
            headIcon:addChild(touchNode)

            touchNode:setTouchEnabled(true)
            touchNode:setTouchSwallowEnabled(false)
            local isMoved = false

            local viewBg = HandBookModel.viewBg
            local viewWidth = viewBg:getContentSize().width
            local viewHeight = viewBg:getContentSize().height

            local viewWorldPos = viewBg:getParent():convertToWorldSpace(ccp(viewBg:getPositionX(),viewBg:getPositionY()))


            local viewRect = CCRect(viewWorldPos.x - viewWidth/2, viewWorldPos.y, viewWidth, viewHeight)

            touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                local touchPos =  ccp(event.x,event.y)
                local isInViewBg =  viewRect:containsPoint(touchPos)
                if isInViewBg == true then
                    if event.name == "began" then 
                        touchNode:setTouchEnabled(false)

                        return true
                    elseif event.name == "moved" then
                        if math.abs(event.y - event.prevY) > 5 then
                           isMoved = true
                        end
                    elseif event.name == "ended" then                        
                        ResMgr.delayFunc(0.8,function()
                            touchNode:setTouchEnabled(true)
                            isMoved = false
                            end,self)
                        if isMoved ~= true then
                            local itemInfo = require("game.Huodong.ItemInformation").new({
                                        id = arrId[i],
                                        type = itemType                       
                                        })
                            display.getRunningScene():addChild(itemInfo, 100000)
                        end
                    end
                end
            end)
        end

        curX = curX + headIcon:getContentSize().height + 20

        if i % 5 == 0 then
            curY = curY - headIcon:getContentSize().height - 32
            curX = orX
            -- 
        end

        if i >1 and (i -1) % 5 == 0 then
            iconCount = iconCount + 1
        end
        iconHeight = headIcon:getContentSize().height + 32

    end
    iconHeight = iconHeight 

    


    self._rootnode["cell_bg"]:setContentSize(CCSize(self._rootnode["cell_bg"]:getContentSize().width,iconCount * iconHeight  +self._rootnode["star_bg"]:getContentSize().height+20))

    local totalNum = #arrId
    local totalTTF = ui.newTTFLabelWithShadow({
        text = "/"..totalNum,
        size = 24,
        -- color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_RIGHT 
        })
    self._rootnode["cell_bg"]:addChild(totalTTF)
    totalTTF:setPosition(self._rootnode["cell_bg"]:getContentSize().width-20, self._rootnode["cell_bg"]:getContentSize().height-25)
    
    local exTTF = ui.newTTFLabelWithShadow({
        text = exNum,
        size = 24,
        color = ccc3(36,255,0),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_RIGHT 
        })
    self._rootnode["cell_bg"]:addChild(exTTF)
    exTTF:setPosition(totalTTF:getPositionX()-totalTTF:getContentSize().width,totalTTF:getPositionY())

end

function HandBookCell:getHeight()
    return self._rootnode["cell_bg"]:getContentSize().height + self._rootnode["star_bg"]:getContentSize().height/2
end

return HandBookCell
