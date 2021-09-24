local TabUpView=classGc(function(self)
    self.m_tabArray={}
    self.istrue=true
end)
-- CONST_COLOR_YELLOWISH
local P_SecondSize=cc.size(847,492)
local P_SecondPosY=265
local COLOR_MAIN_NORMAL=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PBLUE)
local COLOR_MAIN_SELECT=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LBLUE)
local COLOR_OUTLINE_SELECT=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_OSTROKE)
local COLOR_OUTLINE_NORMAL={r=150,  g=50,   b=7  ,  a=200}

function TabUpView.create(self,_szName,_hideSecondSpr)
    self.m_normalView=require("mod.general.NormalView")()
    self.m_rootLayer=self.m_normalView:create()

    self:__initView(_hideSecondSpr)
    self:setTitle(_szName)

    return self.m_rootLayer
end

function TabUpView.__initView(self,_hideSecondSpr)
    local winSize=cc.Director:getInstance():getWinSize()

    -- local lineSpr=cc.Sprite:createWithSpriteFrameName("general_rightline.png")
    -- lineSpr:setPosition(winSize.width/2+415,winSize.height/2-25)
    -- self.m_rootLayer:addChild(lineSpr)

    if _hideSecondSpr==nil then
        local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
        secondSpr:setPreferredSize(P_SecondSize)
        secondSpr:setPosition(winSize.width/2+2,P_SecondPosY)
        self.m_rootLayer:addChild(secondSpr)
        self.m_secondSpr=secondSpr
    end
    --[[
    local titleHightSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_title_hight.png",cc.rect(37,3,1,1))
    titleHightSpr:setPreferredSize(cc.size(760,6))
    titleHightSpr:setPosition(winSize.width/2,487)
    self.m_rootLayer:addChild(titleHightSpr,2)
    ]]--
end
function TabUpView.getCloseBtn(self)
    return self.m_normalView:getCloseBtn()
end
function TabUpView.setSecondSize(self,_nSize)
    self.m_secondSize=_nSize

    if self.m_secondSpr then
        local nPosY=(self.m_secondSize.height-P_SecondSize.height)/2
        self.m_secondSpr:setPreferredSize(_nSize)
        self.m_secondSpr:setPositionY(P_SecondPosY-nPosY)
    end
end
function TabUpView.setSecondVisible(self,_visible)
    if self.m_secondSpr~=nil then
        self.m_secondSpr:setVisible(_visible)
    end
end
function TabUpView.getFrameSize(self)
    return self.m_normalView:getFrameSize()
end
function TabUpView.getSecondSize(self)
    return P_SecondSize
end
function TabUpView.setTitle(self,_szName)
    self.m_normalView:setTitle(_szName)
end
function TabUpView.showUpRightSpr(self,_width)
    self.m_normalView:showUpRightSpr(_width)
end
function TabUpView.getUpRightSpr(self)
    return self.m_normalView:getUpRightSpr()
end
function TabUpView.hideCloseBtn(self)
    self.m_normalView:hideCloseBtn()
end
function TabUpView.showCloseBtn(self)
    self.m_normalView:showCloseBtn()
end
function TabUpView.addCloseFun(self,_fun)
    self.m_normalView:addCloseFun(_fun)
end
function TabUpView.addTabFun(self,_fun)
    self.m_tabFun=_fun
end
function TabUpView.addTabButton(self,_szName,_tag,_isGray,_isHideBg)
    local function c(sender,eventType)
        if eventType==ccui.TouchEventType.began then
            local tag=sender:getTag()
            self:selectTagByTag(tag)
        elseif eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            local isOk=true
            if self.m_tabFun~=nil then
                local ret=self.m_tabFun(tag)
                isOk=ret==nil and true or ret
            end
            if isOk then
                self:selectTagByTag(tag)
                if self.oldTag~=tag then
                    self.oldTag=tag
                end
            else
                print("self.oldTag1111",self.oldTag)
                if self.oldTag==nil then self.oldTag=self.newTag end
                print("self.oldTag2222",self.oldTag)
                self:selectTagByTag(self.oldTag)
            end
        end
    end

    local winSize=cc.Director:getInstance():getWinSize()
    local nnnnnnn=winSize.width/2-250
    local curCount=#self.m_tabArray
    local button_x=nnnnnnn+curCount*150
    _szName=_szName or ""
    _tag=_tag or curCount+1

    local szNormal="general_btn_weixuan.png"
    local szPress="general_btn_selected.png"
    local button=gc.CButton:create()
    if _isGray then
        button:loadTextures(szNormal)
        button:setEnabled(false)
        button:setBright(false)
    else
        button:loadTextures(szNormal,szPress,szPress)
    end
    button:setAnchorPoint(cc.p(1,0.5))
    button:setPosition(button_x,527)
    button:addTouchEventListener(c)
    button:setTag(_tag)
    -- button:enableSound()
    self.m_rootLayer:addChild(button,10)

    local btnSize=button:getContentSize()
    local label1=_G.Util:createBorderLabel(_szName,20,COLOR_OUTLINE_SELECT)
    -- label1:setDimensions(22, 60)
    label1:setTextColor(COLOR_MAIN_NORMAL)
    -- label1:setColor(COLOR_MAIN_NORMAL)
    label1:setPosition(cc.p(btnSize.width/2+2,btnSize.height/2-1))
    button:addChild(label1)
    local label2=_G.Util:createBorderLabel(_szName,20,COLOR_OUTLINE_SELECT)
    -- label2:setDimensions(22, 60)
    label2:setTextColor(COLOR_MAIN_SELECT)
    label2:setPosition(cc.p(btnSize.width/2+2,btnSize.height/2-1))
    label2:setVisible(false)
    button:addChild(label2)

    local tabTable={["button"]=button,["label1"]=label1,["label2"]=label2,isGray=_isGray,isHideBg=_isHideBg}
    table.insert(self.m_tabArray,tabTable)
end

function TabUpView.setTabStringByTag(self,_tag,_string)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            value.label1:setString(_string)
            value.label2:setString(_string)
        end
    end
end
function TabUpView.getTabBtnByTag(self,_tag)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            return value.button
        end
    end
end

function TabUpView.setTagIconNum(self,_tag,_num)
    if _tag==nil or _num==nil then return end
    print("setTagIconNum",_tag,_num)
    local tempBtn=self:getTabBtnByTag(_tag)
    if tempBtn==nil then return end

    local iconSpr=tempBtn:getChildByTag(18888)
    if _num<=0 then
        if iconSpr~=nil then
            iconSpr:removeFromParent(true)
        end
    else
        if iconSpr~=nil then
            local Count = _num>9 and "N" or _num
            iconSpr:getChildByTag(520):setString(tostring(Count))
        else
            local btnSize=tempBtn:getContentSize()
            iconSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
            iconSpr:setPosition(btnSize.width-10,btnSize.height-10)
            tempBtn:addChild(iconSpr,10,18888)

            local iconSize=iconSpr:getContentSize()
            local Count = _num>9 and "N" or _num
            local tempLabel=_G.Util:createLabel(tostring(Count),18)
            tempLabel:setPosition(iconSize.width*0.5+1.5,iconSize.height*0.5-2)
            iconSpr:addChild(tempLabel,0,520)
        end
    end
end

function TabUpView.selectTagByTag(self,_tag)
    for i,value in ipairs(self.m_tabArray) do
        if not value.isGray then
            if value.button:getTag()==_tag then
                value.button:setEnabled(false)
                value.button:setBright(false)
                value.button:setPositionY(530)
                value.label1:setVisible(false)
                value.label2:setVisible(true)

                if value.isHideBg then
                    self:setSecondVisible(false)
                else
                    self:setSecondVisible(true)
                end

                if value.signSpr~=nil then
                    value.signSpr:removeFromParent(true)
                    value.signSpr=nil

                    _G.GOpenProxy:delSysSign(value.signId)
                    value.signId=nil
                end
            else
                value.button:setEnabled(true)
                value.button:setBright(true)
                value.button:setPositionY(527)
                value.label1:setVisible(true)
                value.label2:setVisible(false)
            end
        end
    end
    if self.istrue==true then
        self.newTag=_tag
    end
    self.istrue=false
end

function TabUpView.addSignSprite(self,_tag,_sysId)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            if not value.signSpr then
                local btnSize=value.button:getContentSize()
                local tempSpr=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
                tempSpr:setPosition(btnSize.width-10,btnSize.height-10)
                value.button:addChild(tempSpr,5)

                value.signSpr=tempSpr
                value.signId=_sysId
            end
            return
        end
    end
end

return TabUpView