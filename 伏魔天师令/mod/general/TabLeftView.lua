local TabLeftView=classGc(function(self,_type)
	self.m_tabArray={}
    self.m_viewType=_type or 0

    self.m_tabViewSize=cc.size(222,478)
    self.m_maxTabCount=5
    self.winSize=cc.Director:getInstance():getWinSize()
    self.m_scrollPos=cc.p(self.winSize.width*0.5-435,54)

    if self.m_viewType==0 then
        self.m_oneHeight=75
        self.m_tabViewSize=cc.size(222,505)
        self.m_scrollPos=cc.p(self.winSize.width*0.5-435,25)
        -- self.m_maxTabCount=5
    else
        self.m_oneHeight=75
        -- 
        -- self.m_maxTabCount=8
    end
    self.m_touchMinY=self.m_scrollPos.y
    self.m_touchMaxY=self.m_scrollPos.y+self.m_tabViewSize.height
end)

local m_btnNormalPng="general_title_one.png"
local m_btnEnablePng="general_title_two.png"
local P_FirstSize  = cc.size(217,517)
local P_SecondSize = cc.size(626,517)
local COLOR_MAIN=cc.c4b(255,255,255,140)
local COLOR_SELECT=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)
local COLOR_BROWN=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)

function TabLeftView.create( self,_titleName,_isBool)
    self.m_normalView=require("mod.general.NormalView")()
    self.m_rootLayer=self.m_normalView:create()

    self:__initView(_isBool)
    self:setTitle(_titleName)

    self.m_tabContainer=cc.Node:create()
    self.m_tabContainer:setPosition(self.m_scrollPos)
    self.m_rootLayer:addChild(self.m_tabContainer)

	return self.m_rootLayer
end

function TabLeftView.__initView(self,_isBool)
    if self.m_viewType==0 then
        local mainNode=self.m_normalView:getMainNode()
        local firstSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
        firstSpr:setPreferredSize(P_FirstSize)
        firstSpr:setPosition(-315,278)
        mainNode:addChild(firstSpr)
    end

    if _isBool==nil then
        local mainNode=self.m_normalView:getMainNode()
        local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
        secondSpr:setPreferredSize(P_SecondSize)
        secondSpr:setPosition(110,278)
        mainNode:addChild(secondSpr)
    end
end

function TabLeftView.addTabButton(self,_szName,_tag)
    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            local worldPos=sender:getWorldPosition()
            if worldPos.y<self.m_touchMinY or worldPos.y>self.m_touchMaxY then
                return
            end
            
            local isOk=true
            if self.m_tabFun~=nil then
                local ret=self.m_tabFun(tag)
                isOk=ret==nil and true or ret
            end
            if isOk then
                self:selectTagByTag(tag)
            end
        end
    end

    local curCount=#self.m_tabArray
    local buttonPost

    if self.m_viewType==0 then
        buttonPost=cc.p(121,self.m_tabViewSize.height-self.m_oneHeight*(curCount+0.5)+2)
    else
        buttonPost=cc.p(121,self.m_tabViewSize.height-self.m_oneHeight*(curCount+0.5)+3)
    end

    _szName=_szName or ""
    _tag=_tag or curCount+1

    local button=gc.CButton:create()
    button:loadTextures(m_btnNormalPng,"",m_btnEnablePng)
    button:setPosition(buttonPost)
    button:addTouchEventListener(c)
    button:setTag(_tag)
    button:setSwallowTouches(false)
    -- button:enableSound()
    self.m_tabContainer:addChild(button,10)

    local btnSize=button:getContentSize()
    local label1=_G.Util:createLabel(_szName,24)
    label1:setColor(COLOR_BROWN)
    label1:setPosition(cc.p(btnSize.width/2,btnSize.height/2-2))
    button:addChild(label1)
    local label2=_G.Util:createLabel(_szName,24)
    label2:setPosition(cc.p(btnSize.width/2,btnSize.height/2-2))
    label2:setColor(COLOR_BROWN)
    label2:setVisible(false)
    button:addChild(label2)

    local tabTable={["button"]=button,["label1"]=label1,["label2"]=label2,isGray=_isGray,isHideBg=_isHideBg}
    table.insert(self.m_tabArray,tabTable)

    if self.m_viewType~=0 then
        if curCount>=self.m_maxTabCount then
            if self.m_tabScrollView==nil then
                local nParent=self.m_tabContainer:getParent()
                local nParpos=cc.p(self.m_tabContainer:getPosition())
                local scoView=cc.ScrollView:create()
                scoView:setDirection(ccui.ScrollViewDir.vertical)
                scoView:setTouchEnabled(true)
                scoView:setBounceable(false)
                scoView:setViewSize(self.m_tabViewSize)
                scoView:setPosition(self.m_scrollPos)
                scoView:setDelegate()
                nParent:addChild(scoView)

                self.m_tabContainer:retain()
                self.m_tabContainer:removeFromParent(false)
                scoView:addChild(self.m_tabContainer)
                self.m_tabContainer:release()
                self.m_tabScrollView=scoView
            end
            local contentHeight=(curCount+1)*self.m_oneHeight
            local subHeight=contentHeight-self.m_tabViewSize.height
            self.m_tabScrollView:setContentSize(cc.size(self.m_tabViewSize.width,contentHeight))
            self.m_tabScrollView:setContentOffset(cc.p(0,-subHeight))
            self.m_tabContainer:setPosition(0,subHeight-2)

            if self.m_scrollBarView==nil then
                self.m_scrollBarView=require("mod.general.ScrollBar")(self.m_tabScrollView)
                self.m_scrollBarView:setPosOff(cc.p(0,0))
            else
                self.m_scrollBarView:chuangeSize()
            end
        end
    else
        if curCount>=self.m_maxTabCount then
            if self.m_tabScrollView==nil then
                local nParent=self.m_tabContainer:getParent()
                local nParpos=cc.p(self.m_tabContainer:getPosition())
                local scoView=cc.ScrollView:create()
                scoView:setDirection(ccui.ScrollViewDir.vertical)
                scoView:setTouchEnabled(true)
                scoView:setBounceable(false)
                scoView:setViewSize(self.m_tabViewSize)
                scoView:setPosition(self.m_scrollPos)
                scoView:setDelegate()
                nParent:addChild(scoView)

                self.m_tabContainer:retain()
                self.m_tabContainer:removeFromParent(false)
                scoView:addChild(self.m_tabContainer)
                self.m_tabContainer:release()
                self.m_tabScrollView=scoView
            end
            local contentHeight=(curCount+1)*self.m_oneHeight
            local subHeight=contentHeight-self.m_tabViewSize.height
            self.m_tabScrollView:setContentSize(cc.size(self.m_tabViewSize.width,contentHeight))
            self.m_tabScrollView:setContentOffset(cc.p(0,-subHeight))
            self.m_tabContainer:setPosition(0,subHeight-2)

            if self.m_scrollBarView==nil then
                self.m_scrollBarView=require("mod.general.ScrollBar")(self.m_tabScrollView)
                self.m_scrollBarView:setPosOff(cc.p(0,0))
            else
                self.m_scrollBarView:chuangeSize()
            end
        end
    end
end

function TabLeftView.setTabStringByTag(self,_tag,_string)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            value.label1:setString(_string)
            value.label2:setString(_string)
        end
    end
end
function TabLeftView.getTabBtnByTag(self,_tag)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            return value.button
        end
    end
end

function TabLeftView.setTagIconNum(self,_tag,_num)
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
            iconSpr:setPosition(btnSize.width-15,btnSize.height-15)
            tempBtn:addChild(iconSpr,10,18888)

            local iconSize=iconSpr:getContentSize()
            local Count = _num>9 and "N" or _num
            local tempLabel=_G.Util:createLabel(tostring(Count),18)
            tempLabel:setPosition(iconSize.width*0.5+1.5,iconSize.height*0.5-2)
            iconSpr:addChild(tempLabel,0,520)
        end
    end
end

function TabLeftView.setTitle(self,_szTitle)
    self.m_normalView:setTitle(_szTitle)
end
function TabLeftView.getFrameSize(self)
    return self.m_normalView:getFrameSize()
end
function TabLeftView.getSecondSize(self)
    return P_SecondSize
end
function TabLeftView.showUpRightSpr(self,_width)
    self.m_normalView:showUpRightSpr(_width)
end
function TabLeftView.getUpRightSpr(self)
    return self.m_normalView:getUpRightSpr()
end
function TabLeftView.hideCloseBtn(self)
    self.m_normalView:hideCloseBtn()
end
function TabLeftView.showCloseBtn(self)
    self.m_normalView:showCloseBtn()
end
function TabLeftView.addCloseFun(self,_fun)
    self.m_normalView:addCloseFun(_fun)
end
function TabLeftView.addTabFun(self,_fun)
    self.m_tabFun=_fun
end
function TabLeftView.getCloseBtn( self )
    return self.m_normalView:getCloseBtn()
end

function TabLeftView.getObjByTag( self, _tag )
    for i,v in ipairs(self.m_tabArray) do
        if v.button:getTag() == _tag then
            return v.button
        end
    end
end
function TabLeftView.selectTagByTag(self,_tag)
    for i,value in ipairs(self.m_tabArray) do
        if value.button:getTag()==_tag then
            value.button:setEnabled(false)
            value.button:setBright(false)
            -- self.labelTitle : setString(value.szName)
            value.label1:setVisible(false)
            value.label2:setVisible(true)
            value.button:setPositionX(124)
        else
            value.button:setEnabled(true)
            value.button:setBright(true)
            -- _G.Util:playAudioEffect("ui_compose")
            value.label1:setVisible(true)
            value.label2:setVisible(false)
            value.button:setPositionX(121)
        end
    end
end

return TabLeftView