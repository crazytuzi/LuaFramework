local ChatWindowMediator=classGc(mediator,function(self,_view)
    self.name = "ChatWindowMediator"
    self.view = _view

    if _view.m_isNoMain then
        self:regSelf()
    else
        self:regSelfLong()
    end
end)
ChatWindowMediator.protocolsList={
    _G.Msg.ACK_CHAT_RECE_PM,
}

ChatWindowMediator.commandsList={
    ChatMsgCommand.TYPE,
}

function ChatWindowMediator.ACK_CHAT_RECE_PM(self, _ackMsg)
    print("ChatWindowMediator.ACK_CHAT_RECE_PM======>>>")

    if _G.GPropertyProxy:getMainPlay()==nil then return end
    self.view:showChatbtnAction()
end

function ChatWindowMediator.processCommand(self, _command)
    if _command:getType()==ChatMsgCommand.TYPE then
        self.view:insertOneChatMsg(_command.chatMsg)
    end
end

local ChatWindow=classGc(view,function(self,_isNoMain,_viewSize,_maxNum)
    self.m_isNoMain=_isNoMain
    self.m_maxCount=_maxNum or 1
    self.m_viewSize=_viewSize or cc.size(300,100)
    self.m_curHeight=0
    self.m_removeHeight=0
    self.m_lpRichTextArray={}

    self.m_mediator=ChatWindowMediator(self)
    self.m_winSize=cc.Director:getInstance():getWinSize()
end)

function ChatWindow.getLayer(self)
    return self.m_rootNode
end

function ChatWindow.showOnlyChannel(self,_channel)
    self.m_channel=_channel
end

local P_VERTICAL_SPACE=5

function ChatWindow.create(self)
	self.m_rootNode=cc.Node:create()
	self:__initView()
	return self.m_rootNode
end

function ChatWindow.__initView(self)

    local scrollPos=nil
    if not self.m_isNoMain then
        local chatBgSprSize=cc.size(350,25)
        if self.m_winSize.width<960 then
            chatBgSprSize=cc.size(290,25)
        end

        local midPos=cc.p(chatBgSprSize.width*0.5,chatBgSprSize.height*0.5+5)
        local chatBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_op.png")
        chatBgSpr:setPreferredSize(cc.size(chatBgSprSize.width,61))
        chatBgSpr:setPosition(midPos)
        chatBgSpr:setOpacity(150)
        chatBgSpr:setScaleY(chatBgSprSize.height/61)
        self.m_rootNode:addChild(chatBgSpr)

    	local function c(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                local nTag=sender:getTag()
                if nTag==1 then
            	   _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_CHATTING)
                elseif nTag==2 then
                    self.m_isShowWindow=not self.m_isShowWindow
                    _G.GSystemProxy:setChatWindowShow(self.m_isShowWindow)
                    if self.m_isShowWindow then
                        self:showView()
                        sender:setRotation(-90)
                    else
                        self:hideView()
                        sender:setRotation(90)
                    end
                end
            end
        end

    	-- 聊天
        -- local action=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,255)))
        local chatBtn=gc.CButton:create("general_chat_btn.png")
        -- chatBtn:runAction(action:clone())
        chatBtn:setPosition(midPos.x+chatBgSprSize.width*0.5+10,midPos.y+chatBgSprSize.height*0.5+5)
        chatBtn:addTouchEventListener(c)
        chatBtn:setContentSize(80,80)
        chatBtn:setTag(1)
        self.m_rootNode:addChild(chatBtn,10)
        self.m_chatBtn=chatBtn

        -- local arrayBtn=gc.CButton:create("general_arrow.png")
        -- local btnSize=arrayBtn:getContentSize()
        -- arrayBtn:setTag(2)
        -- arrayBtn:addTouchEventListener(c)
        -- arrayBtn:ignoreContentAdaptWithSize(false)
        -- arrayBtn:setContentSize(cc.size(80,40))
        -- arrayBtn:setPosition(midPos.x-chatBgSprSize.width*0.5+30,midPos.y+chatBgSprSize.height*0.5-10)
        -- self.m_rootNode:addChild(arrayBtn,10)
        -- self.m_arrayBtn=arrayBtn

        local function d(sender,eventType) return true end
        local touchWidget=ccui.Widget:create()
        touchWidget:setContentSize(chatBgSprSize)
        touchWidget:setTouchEnabled(true)
        touchWidget:addTouchEventListener(d)
        touchWidget:setPosition(midPos)
        touchWidget:enableSound()
        self.m_rootNode:addChild(touchWidget,-10)

        -- self.m_showPos=cc.p(0,0)
        -- self.m_hidePos=cc.p(0,-midPos.y-chatBgSprSize.height*0.5+18)
        self.m_viewSize=cc.size(chatBgSprSize.width-10,chatBgSprSize.height-4)
        
        scrollPos=cc.p(midPos.x-chatBgSprSize.width*0.5+5,midPos.y-chatBgSprSize.height*0.5+2)
    else
        scrollPos=cc.p(0,0)
    end

    self.m_lpScrollView=cc.ScrollView:create()
    self.m_lpScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_lpScrollView:setViewSize(self.m_viewSize)
    self.m_lpScrollView:setTouchEnabled(true)
    self.m_lpScrollView:setBounceable(false)
    self.m_lpScrollView:setPosition(scrollPos)
    self.m_lpScrollView:setContentSize(self.m_viewSize)
    self.m_rootNode:addChild(self.m_lpScrollView)

    self.m_lpScrollContainer=cc.Node:create()
    self.m_lpScrollView:addChild(self.m_lpScrollContainer)

    self:showChatInfo()
end

function ChatWindow.hideView(self)
    -- if self.m_hidePos==nil then return end
    -- if self.m_isActionHide then return end
    -- self.m_rootNode:stopAllActions()
    -- self.m_rootNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(0,10)),
    --                                              cc.MoveTo:create(0.3,self.m_hidePos)))
    -- self.m_isActionHide=true
end

function ChatWindow.showView(self)
    -- if self.m_showPos==nil then return end
    -- if (_G.g_Stage.m_isCity and _G.GSystemProxy:isSystemViewShow()) or not _G.GSystemProxy:isChatWindowShow() then return end
    -- local act1=cc.MoveTo:create(0.3,cc.p(self.m_showPos.x,self.m_showPos.y+15))
    -- local act2=cc.MoveTo:create(0.15,cc.p(self.m_showPos.x,self.m_showPos.y-5))
    -- local act3=cc.MoveTo:create(0.1,self.m_showPos)
    -- self.m_rootNode:stopAllActions()
    -- self.m_rootNode:runAction(cc.Sequence:create(act1,act2,act3))
    -- self.m_isActionHide=false
end

function ChatWindow.showChatbtnAction(self)
    if not self.m_chatBtn then return end

    if self.m_chatBtn:getActionByTag(666) then return end

    local act=cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5,1),cc.ScaleTo:create(0.5,0.7)))
    act:setTag(666)
    self.m_chatBtn:runAction(act)
end
function ChatWindow.hideChatbtnAction(self)
    if not self.m_chatBtn then return end
    self.m_chatBtn:stopAllActions()
    -- self.m_chatBtn:setButtonScale(0.7)
end

function ChatWindow.showChatInfo(self)
    local chatMsgArray=_G.GChatProxy:getChatMsgArray(self.m_channel or _G.Const.CONST_CHAT_ALL)
    local chatMsgCount=#chatMsgArray
    local startIdx=chatMsgCount-self.m_maxCount+1
    startIdx=startIdx<1 and 1 or startIdx
    for i=startIdx,chatMsgCount do
        self:insertOneChatMsg(chatMsgArray[i])
    end
end

function ChatWindow.insertOneChatMsg(self,_msg)
    if self.m_channel~=nil and self.m_channel~=_msg.channel then return end
    
    local tempRichText=ccui.RichText:create()
    tempRichText:setTouchEnabled(true)
    tempRichText:setSwallowTouches(false)
    tempRichText:ignoreContentAdaptWithSize(false)
    tempRichText:setContentSize(cc.size(self.m_viewSize.width,0))
    -- tempRichText:setVerticalSpace(P_VERTICAL_SPACE)
    tempRichText:setPosition(cc.p(self.m_viewSize.width*0.5,-self.m_curHeight))

    local msgArray=_msg.contentArray
    if self.m_channel==nil then
        for i=1,#msgArray do
            _G.GChatProxy:insertRichTextOne(msgArray[i],tempRichText,18)
        end
    else
        for i=1,#msgArray do
            if msgArray[i].type~=_G.Const.kChatTypeChanel then
                _G.GChatProxy:insertRichTextOne(msgArray[i],tempRichText,18)
            end
        end
    end

    if #self.m_lpRichTextArray+1>self.m_maxCount then
        local firstRichText=self.m_lpRichTextArray[1]
        local firstSize=firstRichText:getIgnoreContentSize()
        self.m_removeHeight=self.m_removeHeight+firstSize.height+P_VERTICAL_SPACE
        firstRichText:removeFromParent(true)
        table.remove(self.m_lpRichTextArray,1)
    end

    tempRichText:formatText()
    local contentSize=tempRichText:getIgnoreContentSize()
    self.m_curHeight=self.m_curHeight+contentSize.height+P_VERTICAL_SPACE

    if self.m_curHeight>self.m_viewSize.height then
        local subHeight=self.m_curHeight-self.m_removeHeight
        if subHeight>self.m_viewSize.height then
            self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,subHeight))
            if not self.m_isNoMain then
                self.m_lpScrollView:setContentOffset(cc.p(0,-contentSize.height-P_VERTICAL_SPACE))
            end
        else
            self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,self.m_viewSize.height))
        end
        self.m_lpScrollContainer:setPosition(0,self.m_curHeight)
    else
        self.m_lpScrollContainer:setPosition(0,self.m_viewSize.height+self.m_removeHeight)
    end
    self.m_lpScrollContainer:addChild(tempRichText)
    self.m_lpRichTextArray[#self.m_lpRichTextArray+1]=tempRichText
end


return ChatWindow



