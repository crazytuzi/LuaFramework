
local HeroFriendLayer = class("HeroFriendLayer", UFCCSNormalLayer)
local MergeEquipment = require("app.data.MergeEquipment")

require("app.cfg.team_target_info")

function HeroFriendLayer.create(container,scrollOffset)
    return require("app.scenes.hero.HeroFriendLayer").new("ui_layout/knight_friend.json", container,scrollOffset)
end

function HeroFriendLayer:ctor(json,container,scrollOffset)
    self.super.ctor(self, json)
    self._container = container
    self._scrollOffset = scrollOffset

    self._targetType = 5
    self._btns = {}
    self._inputRichText = {}
    self._lastLevel = -1
    self:createRichTxt()

    self._scrollView = self:getScrollViewByName("ScrollView_list")
    self:initScrollView()
    self._scrollPos = 0

    self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
    self._tabs:add("CheckBox_level", nil,"Label_level")
    self._tabs:add("CheckBox_tupo", nil,"Label_tupo")
    self._tabs:add("CheckBox_other", nil,"Label_other")

    self:getCheckBoxByName("CheckBox_tupo"):setVisible(false)
    self:getCheckBoxByName("CheckBox_other"):setVisible(false)

    self._tabs:checked("CheckBox_level")

    self:registerBtnClickEvent("Button_close", function(widget) 
        self._container:showZhuWei(false)
    end)
    self:registerWidgetTouchEvent("Button_left", function(widget, eventType) 
        self:move(widget,eventType,-1)
    end)
    self:registerWidgetTouchEvent("Button_right", function(widget, eventType) 
        self:move(widget,eventType,1)
    end)
end

function HeroFriendLayer:getType()
    return self._targetType
end

function HeroFriendLayer:move(widget,eventType,right)
    if eventType == TOUCH_EVENT_BEGAN then 
        self._timer = GlobalFunc.addTimer(0.05, function() 
                local container = self._scrollView:getInnerContainer()
                local x = container:getPositionX()
                local baseWidth = self._scrollView:getContentSize().width
                local width = container:getContentSize().width
                x = math.max(math.min(x+right*25,0),baseWidth-width)
                container:setPositionX(x)
        end)
    elseif eventType == TOUCH_EVENT_MOVED then 
        if not widget then 
            self:_stopSchedule()
        end
        local curPt = widget:getTouchMovePos()
        if not widget:hitTest(curPt) then 
            self:_stopSchedule()
        end
    elseif eventType == TOUCH_EVENT_ENDED then 
        self:_stopSchedule()
    elseif eventType == TOUCH_EVENT_CANCELED then 
        self:_stopSchedule()
    end
end

function HeroFriendLayer:_stopSchedule()
    GlobalFunc.removeTimer(self._timer)
end

function HeroFriendLayer:onBackKeyEvent( ... )
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())

    return true
end

--选中了某个tab
function HeroFriendLayer:onCheckCallback(btnName)
    self:updateView()
end

function HeroFriendLayer:createRichTxt()
    for i = 1 , 2 do
            local label = self:getLabelByName("Label_title"..i)
            if label then 
                local size = label:getSize()
                local posx,posy = label:getPosition()
                self._inputRichText[i] = CCSRichText:create(size.width+50, size.height+15)
                self._inputRichText[i]:setFontSize(label:getFontSize())
                self._inputRichText[i]:setFontName(label:getFontName())
                self._inputRichText[i]:enableStroke(Colors.strokeBrown)
                local color = label:getColor()
                self._defaultColor = ccc3(color.r, color.g, color.b)
                self._inputRichText[i]:setShowTextFromTop(true)
                self._inputRichText[i]:setPositionXY(posx,posy+10)
                label:getParent():addChild(self._inputRichText[i],20)
                label:setVisible(false)
            end
    end
end

function HeroFriendLayer:updateView()
    local friendTarget, lastTargetLevel, nextTargetLevel = G_Me.formationData:getKnightFriendTarget(1)
    self:updateAttr(lastTargetLevel, nextTargetLevel)
    self:updateScrollView(nextTargetLevel)
    self._lastLevel = lastTargetLevel
end

function HeroFriendLayer:shortUpdate()
    local friendTarget, lastTargetLevel, nextTargetLevel = G_Me.formationData:getKnightFriendTarget(1)
    -- self:updateAttr(lastTargetLevel, nextTargetLevel)
    self:updateScrollView(nextTargetLevel)
end

function HeroFriendLayer:updateAttr(lastTargetLevel, nextTargetLevel)
    local target = {team_target_info.get(self._targetType, lastTargetLevel),team_target_info.get(self._targetType, nextTargetLevel)}
    for i = 1 , 2 do 
        local data = target[i]
        if data then
            -- local title = self:getLabelByName("Label_title"..i)
            -- title:createStroke(Colors.strokeBrown, 1)
            local color = (i==1 and 16777215 or 10092339)
            local txt = G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level=data.value,color=color})
            -- title:setText(G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level=data.value,color=16777215}))
            self._inputRichText[i]:clearRichElement()
            self._inputRichText[i]:appendContent(txt, self._defaultColor)
            self._inputRichText[i]:reloadData()

            for j = 1 , 4 do 
                if data["att_type_"..j] > 0 then
                    local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(data["att_type_"..j], data["att_value_"..j])
                    self:getLabelByName("Label_attrType"..i.."_"..j):setText(strtype)
                    self:getLabelByName("Label_attrValue"..i.."_"..j):setText("+"..strvalue)
                    self:getLabelByName("Label_attrType"..i.."_"..j):setVisible(true)
                    self:getLabelByName("Label_attrValue"..i.."_"..j):setVisible(true)
                    self:getLabelByName("Label_attrValue"..i.."_"..j):setColor(i==1 and Colors.lightColors.DESCRIPTION or Colors.lightColors.ATTRIBUTE)
                else
                    self:getLabelByName("Label_attrType"..i.."_"..j):setText("")
                    self:getLabelByName("Label_attrValue"..i.."_"..j):setText("")
                    self:getLabelByName("Label_attrType"..i.."_"..j):setVisible(false)
                    self:getLabelByName("Label_attrValue"..i.."_"..j):setVisible(false)
                end
            end
            if i == 2 then
                self:getPanelByName("Panel_data"):setVisible(true)
                self:getLabelByName("Label_future"):setVisible(false)
            end
        else
            if i == 1 then
                -- local title = self:getLabelByName("Label_title"..i)
                -- title:createStroke(Colors.strokeBrown, 1)
                -- title:setText(G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level=0}))
                local color = (i==1 and 16777215 or 10092339)
                local txt = G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level=0,color=color})
                self._inputRichText[i]:clearRichElement()
                self._inputRichText[i]:appendContent(txt, self._defaultColor)
                self._inputRichText[i]:reloadData()

                local data = target[i+1]
                for j = 1 , 4 do 
                    if data["att_type_"..j] > 0 then
                        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(data["att_type_"..j], data["att_value_"..j])
                        self:getLabelByName("Label_attrType"..i.."_"..j):setText(strtype)
                        self:getLabelByName("Label_attrValue"..i.."_"..j):setText("+"..0)
                        self:getLabelByName("Label_attrType"..i.."_"..j):setVisible(true)
                        self:getLabelByName("Label_attrValue"..i.."_"..j):setVisible(true)
                    else
                        self:getLabelByName("Label_attrType"..i.."_"..j):setText("")
                        self:getLabelByName("Label_attrValue"..i.."_"..j):setText("")
                        self:getLabelByName("Label_attrType"..i.."_"..j):setVisible(false)
                        self:getLabelByName("Label_attrValue"..i.."_"..j):setVisible(false)
                    end
                end
            else
                -- local title = self:getLabelByName("Label_title"..i)
                -- title:createStroke(Colors.strokeBrown, 1)
                -- title:setText(G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level="?"}))
                local color = (i==1 and 16777215 or 10092339)
                local txt = G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH",{level="?",color=color})
                self._inputRichText[i]:clearRichElement()
                self._inputRichText[i]:appendContent(txt, self._defaultColor)
                self._inputRichText[i]:reloadData()

                self:getPanelByName("Panel_data"):setVisible(false)
                self:getLabelByName("Label_future"):setVisible(true)
                self:getLabelByName("Label_future"):setText(G_lang:get("LANG_KNIGHT_FRIEND_NO"))
                self:getLabelByName("Label_future"):createStroke(Colors.strokeBrown, 1)
            end
        end
    end
end

function HeroFriendLayer:initScrollView()
    self._scrollView:removeAllChildren();
    local space = 5 --间隙
    local size = self._scrollView:getContentSize()
    local _knightItemWidth = 0
    local maxLength = 6

    for i = 1, maxLength do
          local widget = require("app.scenes.hero.HeroFriendItem").new()

          -- widget:updateView(i, self._targetType, nextTargetLevel)
          self._btns[i] = widget

          -- _knightItemWidth = widget:getWidth()
          _knightItemWidth = 150

          widget:setPosition(ccp(_knightItemWidth*(i-1)+i*space,0))
          self._scrollView:addChild(widget)
    end

    local _scrollViewWidth = _knightItemWidth*maxLength+space*(maxLength+1)
    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

function HeroFriendLayer:updateScrollView(nextTargetLevel)
    for k , v in pairs(self._btns) do 
        v:updateView(k, self._targetType, nextTargetLevel,function ( )
            self._scrollPos = self._scrollView:getInnerContainer():getPositionX()
            local friendTarget, lastTargetLevel, nextTargetLevel = G_Me.formationData:getKnightFriendTarget(1)
            self._lastLevel = lastTargetLevel
        end)
    end
    self._scrollView:getInnerContainer():setPositionX(self._scrollPos)
    
    --加上有白将的显示
    local has = false
    for loopi = 1, 6 do 
        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(2, loopi)
        local info = knight_info.get(baseId)
        if info and info.quality < 3 then 
            has = true
        end
    end
    if has then
        if self._whiteLabel then
            self._whiteLabel:setVisible(true)
        else
            self._whiteLabel =  GlobalFunc.createGameLabel(G_lang:get("LANG_KNIGHT_FRIEND_WHITE"), 24, Colors.qualityColors[6], Colors.strokeBrown)
            self:getImageViewByName("Image_bg"):addChild(self._whiteLabel)
            self._whiteLabel:setPosition(ccp(0,-150))
        end
    else
        if self._whiteLabel then
            self._whiteLabel:setVisible(false)
        end
    end
end

function HeroFriendLayer:onLayerEnter()
    self.super:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_TEAM_FORMATION, self._onChangeTeamFormation, self)

    -- self:updateView()
    self:shortUpdate()
    -- self:checkChange()
end

function HeroFriendLayer:checkChange()
    if self._lastLevel >= 0 then
        local friendTarget, lastTargetLevel, nextTargetLevel = G_Me.formationData:getKnightFriendTarget(1)
        if lastTargetLevel ~= self._lastLevel then
            -- self:_doFlyAttributes(lastTargetLevel)
            return lastTargetLevel
        else
            self:updateView()
        end
    else
        self:updateView()
    end
    return 0
end

function HeroFriendLayer:addFlyAttributes()
    local level = self:checkChange()
    if level <= 0 then
        self._lastLevel = level
        return false
    end
    local info = team_target_info.get(self._targetType, level)

    local desc = G_lang:get("LANG_KNIGHT_FRIEND_STRENGTH_TITLE", {level = level})
    G_flyAttribute.doAddRichtext(desc, nil, nil, nil, self:getWidgetByName("Label_title1"))
    for i = 1 , 4 do 
        if info["att_type_"..i] > 0 then
            local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(info["att_type_"..i], info["att_value_"..i])
            G_flyAttribute.doAddRichtext(strtype.."  +"..strvalue, nil, nil, nil, self:getLabelByName("Label_attrValue1_"..i))
        end
    end
    return true
end

function HeroFriendLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function HeroFriendLayer:_onChangeTeamFormation( ret, teamId, pos, oldKnightId, newKnightId )
    if ret ~= NetMsg_ERROR.RET_OK then
        return 
    end
    self._scrollPos = self._scrollView:getInnerContainer():getPositionX()
    -- self:updateView()
    self:shortUpdate()
    -- self:checkChange()

    -- self:_loadKnightYuanfen()
    -- if teamId == 1 then 
    --     self:_doLoadMainKnightTeam(pos)
    -- else
    --     self:_doLoadKnight(newKnightId, pos)
    --     self:_checkNewAssociation(newKnightId)
    -- end
end

return HeroFriendLayer

