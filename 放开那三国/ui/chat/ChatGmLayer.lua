-- Filename: ChatGmLayer.lua
-- Author: k
-- Date: 2013-08-16
-- Purpose: 联系GM！（真是醉了，原来的注释都是随便写的么）



require "script/utils/extern"
require "script/utils/LuaUtil"
--require "amf3"
-- 主城场景模块声明
module("ChatGmLayer", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/libs/LuaCCLabel"

local IMG_PATH = "images/chat/"				-- 图片主路径

local m_layerSize = CCSizeMake(570,700)
local m_chatGmLayer
local m_chatGmLayerBg
--提交界面
local m_chatsubmitLayer
local talkEditBox

local counselButton
local bugButton
local complaintButton
local adviseButton
local _touchPriority

--查看界面
local m_chatreviewLayer

local m_chatGmInfo

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function closeClick()
    require "script/ui/chat/ChatMainLayer"
    ChatMainLayer.closeLayer()
    
    --print("==========getSubmitView closeClick===============")
end

function sendCallback(res, hnd)
    
	LoadingUI.reduceLoadingUI()
    --print("==============CCHttpRequest back================")
    --print(res:getResponseData(), res:getResponseCode())
    if(res:getResponseCode()==200)then
        talkEditBox:setText("")
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2678"), nil, false, nil)
    else
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
    end
end

function sendClick()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --print("==========getSubmitView sendClick===============")
    
    if(talkEditBox:getText()~=nil and talkEditBox:getText()~="" )then
        require "script/ui/login/ServerList"
        local serverInfo = ServerList.getSelectServerInfo()
        print("serverInfo:",serverInfo)
        --print_table("ServerList",ServerList)
        local serverID = "test001"
        local server_id = "server001"
        if(serverInfo~=nil and serverInfo.group~=nil)then
            serverID = serverInfo.group
        end
        
        if(serverInfo~=nil and serverInfo.server_id~=nil)then
            server_id = serverInfo.server_id
        end
        
        local url = Platform.getDomain() .. "phone/question?"
        if(BTUtil:getDebugStatus()==true)then
            url = Platform.getDomain_debug() .. "phone/question?"
        end
        
        url = url .. "method=" .. "GET"
        --serverID
        url = url .. "&serverID=" .. serverID
        --serverID
        url = url .. "&server_id=" .. server_id
        --content
        url = url .. "&content=" .. talkEditBox:getText()
        --classID
        local classType = 1
        if(counselButton:isSelected())then
            classType = 1
        end
        if(bugButton:isSelected())then
            classType = 2
        end
        if(complaintButton:isSelected())then
            classType = 3
        end
        if(adviseButton:isSelected())then
            classType = 4
        end
        url = url .. "&classID=" ..classType
        --uid
        url = url .. "&uid=" .. UserModel.getUserInfo().uid
        --uname
        url = url .. "&uname=" .. UserModel.getUserInfo().uname
        --action
        url = url .. "&action=" .. "question"
        
        print("request url:",url)
        CCHttpRequest:open(url, kHttpGet):sendWithHandler(sendCallback)
        LoadingUI.addLoadingUI()
    else
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2349"), nil, false, nil)
    end
end

function getQuestionCallBack(res, hnd)
    
	LoadingUI.reduceLoadingUI()
    --print("==============getQuestionCallBack back================")
    --print(res:getResponseCode(),hnd)
    --print("res:getResponseData():",res:getResponseData())
    
    if(res:getResponseCode()==200)then
        local cjson = require "cjson"
        --print("res:getResponseData():",res:getResponseData())
        local results = cjson.decode(res:getResponseData())
        --print_table("res:getResponseData()",results)
        
        --更新
        local scrollView = tolua.cast(m_chatreviewLayer:getChildByTag(1189),"CCScrollView")
        --print("scrollView",scrollView,m_chatreviewLayer:getChildByTag(1189))
        local totalHeight = 0
        local chatInfoLayer = CCLayer:create()
        -- chatInfoLayer:retain()
        chatInfoLayer:setAnchorPoint(ccp(0,0))
        
        for i=1,#(results.msg) do
            local nodeInfo = {}
            --print("results.msg[i].answer:",results.msg[i].answer,"nil",results.msg[i].answer==nil,"b",results.msg[i].answer=="")
            local gmAnswer = (results.msg[i].answer==nil or results.msg[i].answer=="") and GetLocalizeStringBy("key_3178") or results.msg[i].answer
            nodeInfo.text = gmAnswer
            --nodeInfo.text = "no idea测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试"
            nodeInfo.fontname = g_sFontName
            nodeInfo.fontsize = 20
            nodeInfo.width = m_layerSize.width*0.8
            
            local answerLabel = LuaCCLabel.createMultiLineLabels(nodeInfo)
            answerLabel:setColor(ccc3(0xff,0xfb,0xd9))
            answerLabel:setAnchorPoint(ccp(0,0))
            answerLabel:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.005))
            
            local answerBg = CCScale9Sprite:create(CCRectMake(34, 10, 30, 10),"images/chat/reviewcontent_bg.png")
            answerBg:setContentSize(CCSizeMake(m_layerSize.width*0.9,answerLabel:getContentSize().height+m_layerSize.height*0.01))
            answerBg:setAnchorPoint(ccp(0,0))
            answerBg:setPosition(ccp(0,totalHeight))
            answerBg:addChild(answerLabel)
            chatInfoLayer:addChild(answerBg)
            
            local answerNameHeight = answerBg:getContentSize().height+m_layerSize.height*0.005
            
            local answerNameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3017"),g_sFontName,23)
            answerNameLabel:setAnchorPoint(ccp(0,0))
            answerNameLabel:setPosition(ccp(m_layerSize.width*0.05,totalHeight+answerNameHeight))
            answerNameLabel:setColor(ccc3(0x70,0xff,0x18))
            chatInfoLayer:addChild(answerNameLabel)
            
            local questionLabelHeight = answerNameHeight + answerNameLabel:getContentSize().height + m_layerSize.height*0.005
            
            --问题部分
            local qInfo = {}
            qInfo.text = results.msg[i].question
            --qInfo.text = "no idea测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试长度测试"
            qInfo.fontname = g_sFontName
            qInfo.fontsize = 20
            qInfo.width = m_layerSize.width*0.8
            
            local questionLabel = LuaCCLabel.createMultiLineLabels(qInfo)
            questionLabel:setColor(ccc3(0xff,0xfb,0xd9))
            questionLabel:setAnchorPoint(ccp(0,0))
            questionLabel:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.005))
            
            local questionBg = CCScale9Sprite:create(CCRectMake(34, 10, 30, 10),"images/chat/reviewcontent_bg.png")
            questionBg:setContentSize(CCSizeMake(m_layerSize.width*0.9,questionLabel:getContentSize().height+m_layerSize.height*0.01))
            questionBg:setAnchorPoint(ccp(0,0))
            questionBg:setPosition(ccp(0,totalHeight+questionLabelHeight))
            questionBg:addChild(questionLabel)
            chatInfoLayer:addChild(questionBg)
            
            local questionNameHeight = questionLabelHeight + questionBg:getContentSize().height+m_layerSize.height*0.005
            
            require "script/model/user/UserModel"
            local questionNameLabel = CCLabelTTF:create(UserModel.getUserInfo().uname,g_sFontName,23)
            questionNameLabel:setAnchorPoint(ccp(0,0))
            questionNameLabel:setPosition(ccp(m_layerSize.width*0.05,totalHeight+questionNameHeight))
            questionNameLabel:setColor(ccc3(0x00,0xef,0xff))
            chatInfoLayer:addChild(questionNameLabel)
            if(i==#(results.msg))then
                
                totalHeight = totalHeight + questionNameHeight + questionNameLabel:getContentSize().height+ m_layerSize.height*0.01
            else
                local spliterHeight = questionNameLabel:getContentSize().height + questionNameHeight+m_layerSize.height*0.01
                
                local splitSprite = CCScale9Sprite:create(CCRectMake(30, 1, 56, 2),"images/chat/spliter.png")
                splitSprite:setContentSize(CCSizeMake(m_layerSize.width*0.9,4))
                splitSprite:setAnchorPoint(ccp(0,0))
                splitSprite:setPosition(ccp(0, totalHeight+spliterHeight))
                chatInfoLayer:addChild(splitSprite)
                
                totalHeight = totalHeight + spliterHeight + splitSprite:getContentSize().height+ m_layerSize.height*0.01
            end
        end
        
        print("totalHeight:",totalHeight)
        chatInfoLayer:setContentSize(CCSizeMake(m_layerSize.width*0.9,totalHeight))
        scrollView:setContainer(chatInfoLayer)
        if(m_layerSize.height*0.6>totalHeight)then
            print("scrollView:getContentSize().height:",scrollView:getContentSize().height)
            chatInfoLayer:setPositionY(m_layerSize.height*0.6-totalHeight)
        end
        
        m_chatsubmitLayer:setVisible(false)
        m_chatreviewLayer:setVisible(true)
    else
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
    end
end

function showSubmitView()
    m_chatsubmitLayer:setVisible(true)
    m_chatreviewLayer:setVisible(false)
end

function showReviewView()
    require "script/ui/login/ServerList"
    local serverInfo = ServerList.getSelectServerInfo()
    print("serverInfo:",serverInfo)
    --print_table("ServerList",ServerList)
    local serverID = "test001"
    local server_id = "server001"
    if(serverInfo~=nil and serverInfo.group~=nil)then
        serverID = serverInfo.group
    end
    
    if(serverInfo~=nil and serverInfo.server_id~=nil)then
        server_id = serverInfo.server_id
    end
    
    local url = Platform.getDomain() .. "phone/question?"
    if(BTUtil:getDebugStatus()==true)then
        url = Platform.getDomain_debug() .. "phone/question?"
    end
    
    url = url .. "method=" .. "GET"
    --serverID
    url = url .. "&serverID=" .. serverID
    --serverID
    url = url .. "&server_id=" .. server_id
    --uid
    url = url .. "&uid=" .. UserModel.getUserInfo().uid
    --action
    url = url .. "&action=" .. "answer"
    
    print("request url:",url)
    CCHttpRequest:open(url, kHttpGet):sendWithHandler(getQuestionCallBack)
    
    LoadingUI.addLoadingUI()
end

function initSubmitView()
    m_chatsubmitLayer = CCLayer:create()
    m_chatsubmitLayer:setContentSize(CCSizeMake(570,570))
    m_chatsubmitLayer:ignoreAnchorPointForPosition(false)
    m_chatsubmitLayer:setAnchorPoint(ccp(0.5,0))
    m_chatsubmitLayer:setPosition(ccp(m_chatGmLayer:getContentSize().width*0.5,0))
    
    
    local submitBg = CCScale9Sprite:create(CCRectMake(160, 55, 10, 10),"images/chat/submit_bg.png")
    submitBg:setContentSize(CCSizeMake(560,480))
    submitBg:setAnchorPoint(ccp(0,0))
    submitBg:setPosition(ccp(5,90))
    m_chatsubmitLayer:addChild(submitBg)
    
	local submitLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2026"),g_sFontName,25)
    submitLabel:setAnchorPoint(ccp(0.5,0.5))
    submitLabel:setPosition(ccp(m_layerSize.width*0.13, m_layerSize.height*0.78))
    submitLabel:setColor(ccc3(0xcc,0x92,0x4b))
    m_chatsubmitLayer:addChild(submitLabel)
    
    --发送按键
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority -1)
    m_chatsubmitLayer:addChild(menu)
    
    require "script/libs/LuaCC"
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(150,64),GetLocalizeStringBy("key_1138"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.1 - 18))
    sendButton:registerScriptTapHandler(sendClick)
    
    menu:addChild(sendButton)
    
	local reviewLabel = CCMenuItemFont:create(GetLocalizeStringBy("key_3250"))
    reviewLabel:setFontNameObj(g_sFontName)
    reviewLabel:setFontSizeObj(25)
    reviewLabel:setAnchorPoint(ccp(0.5,0.5))
    reviewLabel:setPosition(ccp(m_layerSize.width*0.425, m_layerSize.height*0.78))
    reviewLabel:setColor(ccc3(0xff,0xd2,0x85))
    menu:addChild(reviewLabel)
    reviewLabel:registerScriptTapHandler(showReviewView)
    
    local typeDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1484"),g_sFontName,23)
    typeDescLabel:setAnchorPoint(ccp(0,0))
    typeDescLabel:setPosition(ccp(m_layerSize.width*0.05, m_layerSize.height*0.71))
    typeDescLabel:setColor(ccc3(0xff,0xfb,0xd9))
    m_chatsubmitLayer:addChild(typeDescLabel)
    
	local typeMenu = BTMenu:create(true)
    typeMenu:setTouchPriority(_touchPriority - 1)
	typeMenu:setStyle(kMenuRadio)
    
	 counselButton = CCMenuItemImage:create(IMG_PATH .. "radio_n.png", IMG_PATH .. "radio_s.png")
	counselButton:setPosition(ccp(m_layerSize.width*0.15, m_layerSize.height*0.71))
	typeMenu:addChild(counselButton)
	--counselButton:registerScriptTapHandler(coinUnlock)
	typeMenu:setMenuSelected(counselButton)
    
    local counselLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1895"),g_sFontName,23)
    counselLabel:setColor(ccc3(0xf9,0x59,0xff))
	counselLabel:setAnchorPoint(ccp(0,0))
	counselLabel:setPosition(ccp(m_layerSize.width*0.21, m_layerSize.height*0.71))
    m_chatsubmitLayer:addChild(counselLabel)
    
    
	 bugButton = CCMenuItemImage:create(IMG_PATH .. "radio_n.png", IMG_PATH .. "radio_s.png")
	bugButton:setPosition(ccp(m_layerSize.width*0.35, m_layerSize.height*0.71))
	typeMenu:addChild(bugButton)
	--bugButton:registerScriptTapHandler(goodUnlock)
    
    local bugLabel = CCLabelTTF:create("BUG",g_sFontName,23)
    bugLabel:setColor(ccc3(0xf9,0x59,0xff))
	bugLabel:setAnchorPoint(ccp(0,0))
	bugLabel:setPosition(ccp(m_layerSize.width*0.41, m_layerSize.height*0.71))
    m_chatsubmitLayer:addChild(bugLabel)
    
    
	 complaintButton = CCMenuItemImage:create(IMG_PATH .. "radio_n.png", IMG_PATH .. "radio_s.png")
	complaintButton:setPosition(ccp(m_layerSize.width*0.55, m_layerSize.height*0.71))
	typeMenu:addChild(complaintButton)
	--complaintButton:registerScriptTapHandler(goodUnlock)
    
    local complaintLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1694"),g_sFontName,23)
    complaintLabel:setColor(ccc3(0xf9,0x59,0xff))
	complaintLabel:setAnchorPoint(ccp(0,0))
	complaintLabel:setPosition(ccp(m_layerSize.width*0.61, m_layerSize.height*0.71))
    m_chatsubmitLayer:addChild(complaintLabel)
    
    
	 adviseButton = CCMenuItemImage:create(IMG_PATH .. "radio_n.png", IMG_PATH .. "radio_s.png")
	adviseButton:setPosition(ccp(m_layerSize.width*0.75, m_layerSize.height*0.71))
	typeMenu:addChild(adviseButton)
	--adviseButton:registerScriptTapHandler(goodUnlock)
    
    local adviseLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1576"),g_sFontName,23)
    adviseLabel:setColor(ccc3(0xf9,0x59,0xff))
	adviseLabel:setAnchorPoint(ccp(0,0))
	adviseLabel:setPosition(ccp(m_layerSize.width*0.81, m_layerSize.height*0.71))
    m_chatsubmitLayer:addChild(adviseLabel)
    
    
	typeMenu:setPosition(ccp(0, 0))
	typeMenu:setAnchorPoint(ccp(0, 0))
	m_chatsubmitLayer:addChild(typeMenu)

    
    --输入框
    local contentDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3064"),g_sFontName,23)
    contentDescLabel:setAnchorPoint(ccp(0,0))
    contentDescLabel:setPosition(ccp(m_layerSize.width*0.05, m_layerSize.height*0.63))
    contentDescLabel:setColor(ccc3(0xff,0xfb,0xd9))
    m_chatsubmitLayer:addChild(contentDescLabel)
    
    --scale changed by zhang zihang
    talkEditBox = CCEditBox:create (CCSizeMake(450,270), CCScale9Sprite:create("images/common/bg/white_text_ng.png"))
	talkEditBox:setPosition(ccp(m_layerSize.width*0.15, m_layerSize.height*0.47))
	talkEditBox:setAnchorPoint(ccp(0, 0.5))
	talkEditBox:setPlaceHolder(GetLocalizeStringBy("key_2499"))
    --talkEditBox:setScale(g_originalDeviceSize.width/g_winSize.width)
    --talkEditBox:setPlaceholderFont(g_sFontName,21)
	talkEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
	talkEditBox:setMaxLength(200)
	talkEditBox:setReturnType(kKeyboardReturnTypeDone)
	talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    talkEditBox:setTouchPriority(_touchPriority - 2)
    
    if(talkEditBox:getChildByTag(1001)~=nil)then
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setDimensions(CCSizeMake(440,250))
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setColor(ccc3(0x78,0x25,0x00))
    end
    
    if(talkEditBox:getChildByTag(1002)~=nil)then
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setDimensions(CCSizeMake(440,250))
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setColor(ccc3(0x86,0x86,0x86))
    end
    talkEditBox:setFont(g_sFontName,21)
    
    m_chatsubmitLayer:addChild(talkEditBox)
    
    local splitSprite = CCScale9Sprite:create(CCRectMake(30, 1, 56, 2),"images/chat/spliter.png")
    splitSprite:setContentSize(CCSizeMake(550,4))
    splitSprite:setAnchorPoint(ccp(0.5,0))
    splitSprite:setPosition(ccp(m_layerSize.width*0.5, m_layerSize.height*0.25))
    m_chatsubmitLayer:addChild(splitSprite)
    
    local thxLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2709"),g_sFontName,21)
    thxLabel:setColor(ccc3(0x70,0xff,0x18))
    thxLabel:setAnchorPoint(ccp(0.5,0))
    thxLabel:setPosition(ccp(m_layerSize.width*0.5, m_layerSize.height*0.19))
    m_chatsubmitLayer:addChild(thxLabel)
    return m_chatsubmitLayer
end

function initReviewView()
    
    m_chatreviewLayer = CCLayer:create()
    m_chatreviewLayer:setContentSize(CCSizeMake(570,570))
    m_chatreviewLayer:ignoreAnchorPointForPosition(false)
    m_chatreviewLayer:setAnchorPoint(ccp(0.5,0))
    m_chatreviewLayer:setPosition(ccp(m_chatGmLayer:getContentSize().width*0.5,0))

    local reviewBg = CCScale9Sprite:create(CCRectMake(320, 55, 10, 10),"images/chat/review_bg.png")
    reviewBg:setContentSize(CCSizeMake(560,480))
    reviewBg:setAnchorPoint(ccp(0,0))
    reviewBg:setPosition(ccp(5,90))
    m_chatreviewLayer:addChild(reviewBg)
    
	local reviewLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3250"),g_sFontName,25)
    reviewLabel:setAnchorPoint(ccp(0.5,0.5))
    reviewLabel:setPosition(ccp(m_layerSize.width*0.425, m_layerSize.height*0.78))
    reviewLabel:setColor(ccc3(0xcc,0x92,0x4b))
    m_chatreviewLayer:addChild(reviewLabel)
    
    --发送按键
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 1)
    m_chatreviewLayer:addChild(menu)
    
    require "script/libs/LuaCC"
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(150,64),GetLocalizeStringBy("key_2474"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.1-18))
    sendButton:registerScriptTapHandler(closeClick)
    
    menu:addChild(sendButton)
	local submitLabel = CCMenuItemFont:create(GetLocalizeStringBy("key_2026"))
    submitLabel:setFontNameObj(g_sFontName)
    submitLabel:setFontSizeObj(25)
    submitLabel:setAnchorPoint(ccp(0.5,0.5))
    submitLabel:setPosition(ccp(m_layerSize.width*0.13, m_layerSize.height*0.78))
    submitLabel:setColor(ccc3(0xff,0xd2,0x85))
    menu:addChild(submitLabel)
    submitLabel:registerScriptTapHandler(showSubmitView)
    
    local scrollView = CCScrollView:create()
    scrollView:setTouchPriority(_touchPriority)
	scrollView:setContentSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.6))
	scrollView:setViewSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.6))
	-- 设置弹性属性
	scrollView:setBounceable(true)
	-- 垂直方向滑动
	scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0,0))
	scrollView:setPosition(ccp(m_layerSize.width*0.01,m_layerSize.height*0.16))
    m_chatreviewLayer:addChild(scrollView,0,1189)
    
    local totalHeight = 0
    
    --local chatInfoLayer = CCLayer:create()
    local chatInfoLayer = CCLayerColor:create(ccc4(111,111,111,166))
    chatInfoLayer:setAnchorPoint(ccp(0,0))
    chatInfoLayer:setPosition(ccp(0,0))
    
    for i=1,25 do
        local chatLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1988"),g_sFontName,23)
        chatLabel:setAnchorPoint(ccp(0,0))
        chatLabel:setPosition(ccp(0,totalHeight))
        chatInfoLayer:addChild(chatLabel)
        
        totalHeight = totalHeight + chatLabel:getContentSize().height
    end
    --print("totalHeight:",totalHeight)
    
    totalHeight = totalHeight>scrollView:getContentSize().height and totalHeight or scrollView:getContentSize().height

    chatInfoLayer:setContentSize(CCSizeMake(m_layerSize.width*0.9,totalHeight))
    scrollView:setContainer(chatInfoLayer)
    
    return m_chatreviewLayer
end

function getChatGmLayer(touchPriority)
    _touchPriority = touchPriority or -410
    m_chatGmLayer = CCLayer:create()
    m_chatGmLayer:setAnchorPoint(ccp(0,0))
    m_chatGmLayer:setPosition(ccp(0,0))
    m_chatGmLayer:setContentSize(CCSizeMake(570,570))
    
    m_chatGmLayerBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    m_chatGmLayerBg:setContentSize(CCSizeMake(570,570))
    m_chatGmLayerBg:setAnchorPoint(ccp(0.5,0.5))
   --m_chatGmLayerBg:setPosition(ccp(25,35 + 55))
    m_chatGmLayerBg:setPosition(ccpsprite(0.5,0.5,m_chatGmLayer))
    m_chatGmLayer:addChild(m_chatGmLayerBg)
    
    initSubmitView()
    initReviewView()
    m_chatGmLayer:addChild(m_chatsubmitLayer)
    m_chatGmLayer:addChild(m_chatreviewLayer)
    m_chatreviewLayer:setVisible(false)
    
    
    return m_chatGmLayer
end

-- 退出场景，释放不必要资源
function release (...) 

end
