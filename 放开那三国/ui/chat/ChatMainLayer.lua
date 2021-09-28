-- Filename: ChatMainLayer.lua
-- Author: DJN
-- Date: 2015-04-21
-- Purpose: 聊天主界面

module("ChatMainLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/chat/RecordUtil"
require "script/audio/AudioUtil"
require "script/ui/chat/ChatCache"
require "script/ui/chat/ChatInfoCell"
require "script/ui/chat/ChatGmLayer"
require "script/ui/chat/RecordTipSprite"

local _isOpen = false --记录整个聊天界面是否在打开的状态
local _chatMainLayer  --整个背景层
local _chatLayerBg    --聊天大背景
local _touchPriority  
local _ZOrder 
local _curIndex       --当前在哪个分页标签上（世界、私聊、军团、联系GM）
local _midNode        -- 一个node 用于包住聊天内容和下面的输入框 以便在点击联系GM的时候 隐藏其他聊天界面 
local _max_length_tip --提示当前最多输入多少字的tip
local _talkEditBox    --聊天内容输入框
local _keyButton      --键盘按钮
local _audioButton    --语音按钮
local _recorderBtn    --"按住说话"按钮
local _curButton      --在有语音功能的时候 区分当前是语音按钮还是键盘按钮
local _sendButton     --发送按钮
local _pmNode         --包装私聊中“对***说”的node
local _nameEditBox    --接收私聊中输入的名字的对话款
local _targetName     --保存私聊中对方的名字
local WORLD_TAG     = 1  -- 因为在添加顶端按钮bar的时候，使用封装的方法，menu会自动tag设置成1 2 3 4 所以这四个值不可以改
local PM_TAG        = 2
local GUILD_TAG     = 3
local GM_TAG        = 4
local _isBusy         --记录顶端按钮切换进度的tag 当他为true的时候，回调函数暂时不响应，避免玩家快速切换造成崩溃
local _new_pm_count = 0 --未读私聊数量
local _menuBar        --顶端四个按钮bar的menu 
local _pm_tip_node    --私聊未读提示
local _worldChatInfo  = {} --世界聊天信息
local _pmChatInfo     = {} --私聊聊天信息
local _guildChatInfo  = {} --军团聊天信息
local _curChatInfo    = {} --当前界面显示的聊天信息
local _chatScrollView --聊天内容的scrollview
local _change_head_btn --更换头像按钮
local _targetName     --私聊对象的名字
local _GMLayer        --联系GM的layer
local _isRecording    --是否正在录音
local _timerSprite    --录音计时用
local _recordTipSprite--正在录音的提示
function init( ... )
	_chatMainLayer = nil
	_chatLayerBg   = nil
	_touchPriority = nil
    _ZOrder        = nil
    _curIndex      = nil
    _midNode       = nil
    _max_length_tip = nil
    talkEditBox = nil
    _keyButton  = nil
    _audioButton = nil
    _recorderBtn = nil
    _curButton  = nil
    _sendButton = nil
    _pmNode = nil
    _nameEditBox = nil
    _targetName = nil
    _isBusy = false
    _menuBar = nil
    _pm_tip_node = nil
    -- _worldChatInfo = {}
    -- _pmChatInfo = {}
    -- _guildChatInfo = {}
    _chatScrollView = nil
    _change_head_btn = nil
    --_curChatInfo = {}
    _targetName = nil
    _GMLayer = nil
    _isRecording = nil
    _timerSprite = nil
    _recordTipSprite = nil
end
function cardLayerTouch(eventType, x, y)
    return true
end
function onNodeEvent(event)
    if event == "enter" then
    	_chatMainLayer:registerScriptTouchHandler(cardLayerTouch, false, _touchPriority, true)
    	_chatMainLayer:setTouchEnabled(true)
        -- if(RecordUtil.initRecord() == false)then
        --     AnimationTip.showTip(GetLocalizeStringBy("key_10145"))
        -- end
        _isOpen  = true
        ChatCache.setChatUIStatus(true)
    elseif event == "exit" then
        RecordUtil.stopPlayRecord()
        ChatInfoCell:stopLabaEffect()
        _isOpen = false
        ChatCache.setChatUIStatus(false)
        ChatInfoCell:stopLabaEffect()
        --首页的新消息提醒和军团新消息提醒都清除
        require "script/ui/main/MainBaseLayer"
        MainBaseLayer.showChatAnimation(false)
        MainBaseLayer.showChatTip(0)
        require "script/ui/guild/GuildBottomSprite"
        GuildBottomSprite.setGuildChatItemAnimation(false)
    end    
end
--[[
    @des    :顶端四个按钮回调(因为这个和UI和本地数据关联实在太密切，没有写到controler中，不然得写一大坨get和set函数)
    @param  :
    @return :
--]]
function menuBarCb(tag,item)
    if(_isBusy == true)then
        return
    end
    if(_curIndex == tag)then
        return
    end
    -- print("点击的tag",tag)
    _isBusy = true
    --停止播放语音
    RecordUtil.stopPlayRecord()
    --停止特效
    ChatInfoCell:stopLabaEffect()
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")    
    if(tag == PM_TAG)then
        --一定要把这一步放在更改_curIndex之前，不然与refreshPmTip函数中的判断冲突，会发生不刷新直接return
        _new_pm_count = 0
        --如果是私聊，清除提示数字红点
        refreshPmTip()
    end

    _curIndex = tag
    --刷新输入框
    refreshInputUI()
    --刷新聊天界面
    refreshChatView(_curIndex,true)
    _isBusy = false
end

-------------------------------------------------------以下是界面中的刷新动作行为。。。
--[[
	@des 	:关闭界面
	@param 	:
	@return :
--]]
function closeLayer( ... )
	--RecordUtil.stopPlayRecord()
    if(_chatMainLayer ~= nil)then
    	_chatMainLayer:removeFromParentAndCleanup(true)
    	_chatMainLayer = nil
    end
    _isOpen = false
end

--[[
    @des    :语音和文字按钮切换回调
    @param  :
    @return :
--]]
function switchBoardAction()
    _curButton:setVisible(false)
    if(_curButton == _keyButton)then
        _talkEditBox:setVisible(true)
        _recorderBtn:setVisible(false)
        _curButton = _audioButton
        _sendButton:setVisible(true)
    else
        _talkEditBox:setVisible(false)
        _recorderBtn:setVisible(true)
        _curButton = _keyButton
        _sendButton:setVisible(false)
    end
    _curButton:setVisible(true)
end
--[[
    @des    :是否显示私聊
    @param  :
    @return :
--]]
function setPmEditVisible(p_isVisiable )
    _pmNode:setVisible(p_isVisiable)
end
--[[
    @des    :刷新聊天内容显示
    @param  :p_tag:要刷新的页面的tag p_isInit:是否是第一次创建这个界面
    @return :
--]]
function refreshChatView(p_tag,p_isInit)
    local isInit = p_isInit or false
    if(_curIndex ~= p_tag or _curIndex == GM_TAG)then
        --如果后端推送过来的消息类型不是当前正在展示的，就不用做界面刷新
        --如果切换到联系GM的界面，不刷新消息
        return
    end
    if(_isOpen == false)then
        --界面还没打开，刷新个毛线
        return
    end
    --ChatInfoCell.create 里面作为参数的三个回调函数
    local callbackFun1 = ChatControler.headCb   --聊天头像点击回调
    local callbackFun2 = ChatControler.callbackLookReport  --战报类型消息的点击回调
    local callbackFun3 = nil  --私聊消息的回调

    if(_curIndex == WORLD_TAG)then       
        _curChatInfo = _worldChatInfo
    elseif(_curIndex == PM_TAG)then
        _curChatInfo = _pmChatInfo
          --收到私聊的话 填充对方名字
        callbackFun3 = ChatControler.chatPMCellClickCallback
    elseif(_curIndex == GUILD_TAG)then
        _curChatInfo = _guildChatInfo
    end
    --如果当前缓存消息太长了 要减 下面的同理  
    ChatUtil.cleanChatInfos(_curChatInfo)


    if(isInit)then
        --如果是初始化创建这个界面，就要把所有的消息逐个创建
        --当然也包括顶端四个按钮来回切换的情况，所以先把原来内容清了
        local container = _chatScrollView:getContainer()
        container:removeAllChildrenWithCleanup(true)
        if(table.isEmpty(_curChatInfo) == false)then
            for i =1, #_curChatInfo  do
                local chat_info = _curChatInfo[i]
                local infoCellType = ChatInfoCell:getChatInfoCellType()
                local chat_info_cell = ChatInfoCell:create(infoCellType.normal, chat_info, i, callbackFun1, callbackFun2, callbackFun3, _touchPriority - 2)
                ChatUtil.addChatInfoCell(_chatScrollView, chat_info_cell)
            end
        end
    else
        --不是初始化这个界面，就是刷新，只刷新一条
        local index = #_curChatInfo
        print("新增的index",index)
        local chat_info = _curChatInfo[index]
        local infoCellType = ChatInfoCell:getChatInfoCellType()
        local chat_info_cell = ChatInfoCell:create(infoCellType.normal, chat_info, index, callbackFun1, callbackFun2, callbackFun3, _touchPriority - 2)
        ChatUtil.addChatInfoCell(_chatScrollView, chat_info_cell)
    end
end
--[[
    @des    :刷新底部输入框的UI
    @param  :
    @return :
--]]
function  refreshChatForPosition( ... )
    ChatUtil.refreshView(_chatScrollView)
end
--[[
    @des    :刷新底部输入框的UI
    @param  :
    @return :
--]]
function refreshInputUI( ... )
    --一些按钮切来切去的啦~
    if(_curIndex == GM_TAG)then
        _midNode:setVisible(false)
        _GMLayer:setVisible(true)
    else
        _midNode:setVisible(true)
        _GMLayer:setVisible(false)
        if(_curIndex == WORLD_TAG )then
            _change_head_btn:setVisible(true)  
            _max_length_tip:setVisible(true)
            setPmEditVisible(false)
            --更换头像按钮显示
        elseif(_curIndex == GUILD_TAG)then
            _change_head_btn:setVisible(false) 
            _max_length_tip:setVisible(true)
            setPmEditVisible(false)
            --更换头像按钮不显示
        elseif(_curIndex == PM_TAG)then
            _change_head_btn:setVisible(false) 
            _max_length_tip:setVisible(false) 
            setPmEditVisible(true)
            --更换头像按钮不显示
        end
        --判断是否开启语音功能
        if(RecordUtil.isRecordOpen() == true)then
            _audioButton:setVisible(true)
            _keyButton:setVisible(false)
            _recorderBtn:setVisible(false)
        end

        _talkEditBox:setVisible(true)
        
        _curButton = _audioButton

        _sendButton:setVisible(true)
    end
end

--[[
    @des    :刷新未读私聊数量
    @param  :
    @return :
--]]
function refreshPmTip()
    if _isOpen == false then
        return
    end
    if _curIndex == PM_TAG then
        return
    end
    if _pm_tip_node ~= nil then
        _pm_tip_node:removeFromParentAndCleanup(true)
        _pm_tip_node = nil
    end
    print("refreshPmTip _new_pm_count",_new_pm_count)
    if _new_pm_count > 0 then
        _new_pm_count = _new_pm_count > 99 and 99 or _new_pm_count
        _pm_tip_node = LuaCCSprite.createTipSpriteWithNum(_new_pm_count)
        local pmButton = tolua.cast(_menuBar:getChildByTag(PM_TAG),"CCMenuItem")
        pmButton:addChild(_pm_tip_node)
        _pm_tip_node:setPosition(pmButton:getContentSize().width - 10, pmButton:getContentSize().height - 10)
    end
end
--------------------------------------------刷新动作行为完毕
--------------------------------------------以下是为controler提供的数据获取和设置方法

--[[
    @des    :获取未读私聊数量
    @param  :
    @return :
--]]
function getNewPmCount()
    return _new_pm_count
end
--[[
    @des    :增加未读私聊数量
    @param  :
    @return :
--]]
function addNewPmCount(p_count)
    _new_pm_count = _new_pm_count + tonumber(p_count)
end
--[[
    @des    :保存私聊对象
    @param  :
    @return :
--]]
function setTargetName(name)
    _targetName = name
    setNameEditBox(_targetName)
end
--[[
    @des    :设置私聊名称
    @param  :
    @return :
--]]

function setNameEditBox( t_name )
    if(_nameEditBox)then
        _nameEditBox:setText(t_name)
    end
end
--[[
    @des    :获取私聊名称
    @param  :
    @return :
--]]

function getNameEditBox()
    if(_nameEditBox)then
        return _nameEditBox:getText()
    end
end
--[[
    @des    :当前频道
    @param  :
    @return :
--]]
function getCurChannel()
    local m_channel = ChatCache.ChannelType.world
    if(_curIndex == WORLD_TAG)then
        m_channel = ChatCache.ChannelType.world
    elseif(_curIndex == PM_TAG)then
        m_channel = ChatCache.ChannelType.pm
    elseif(_curIndex == GUILD_TAG)then
        m_channel = ChatCache.ChannelType.union
    end

    return m_channel
end
--[[
    @des    :设置聊天对话框内容
    @param  :
    @return :
--]]

function setTalkEditBox( p_info )
    if(_talkEditBox)then
        _talkEditBox:setText(p_info)
    end
end
--[[
    @des    :获取聊天对话框内容
    @param  :
    @return :
--]]

function getTalkEditBox(  )
    if(_talkEditBox)then
        return _talkEditBox:getText()
    end
end
--[[
    @des    :获取_isOpen 
    @param  :
    @return :
--]]

function getIsOpen(  )
    return _isOpen
end
--[[
    @des    :获取聊天内容
    @param  :
    @return :
--]]
function getTalkInfoByTag(p_tag)
    local p_tag = tonumber(p_tag)
    if(p_tag == WORLD_TAG)then
        return _worldChatInfo
    elseif(p_tag == PM_TAG)then
        return _pmChatInfo
    elseif(p_tag == GUILD_TAG)then
        return _guildChatInfo
    end
end
--[[
    @des    :获取touch优先级
    @param  :
    @return :
--]]

function getTouchPriority()
    return _touchPriority
end
--[[
    @des    :获取当前聊天信息
    @param  :
    @return :
--]]

function getCurChatInfo()
    return _curChatInfo
end
--[[
    @des    :获取当前按钮bar index
    @param  :
    @return :
--]]

function getCurIndex()
    return _curIndex
end
--[[
    @des    :获取大背景
    @param  :
    @return :
--]]

function getChatLyerBg( ... )
    return _chatLayerBg
end

----------------------------------------为controler提供数据完毕
--[[
	@des 	:创建UI的入口
	@param 	:
	@return :
--]]
function createLayer( ... )
	
	--主背景
    local m_layerSize = CCSizeMake(620,757) 

    _chatLayerBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _chatLayerBg:setContentSize(m_layerSize)
    _chatLayerBg:setScale(MainScene.elementScale)
    _chatLayerBg:setAnchorPoint(ccp(0.5,0.5))
    _chatLayerBg:setPosition(ccp(_chatMainLayer:getContentSize().width * 0.5,_chatMainLayer:getContentSize().height * 0.5))
    _chatMainLayer:addChild(_chatLayerBg)
    
    -- 标题
    local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_chatLayerBg:getContentSize().width * 0.5, _chatLayerBg:getContentSize().height - 6))
	_chatLayerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1492"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 按钮Bar
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority - 50)
    _chatLayerBg:addChild(bgMenu)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.02, m_layerSize.height*1.02))
	bgMenu:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(ChatControler.closeClick)
    
    --这个node用于在切换成联系GM的时候隐藏聊天界面 所有聊天的相关内容的父节点是这个node
    _midNode = CCNode:create()
    _midNode:setAnchorPoint(ccp(0.5,0))
    _midNode:setContentSize(CCSizeMake(620,650))
    _chatLayerBg:addChild(_midNode)
    _midNode:setPosition(ccpsprite(0.5,0,_chatLayerBg))

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority -50)
    _chatLayerBg:addChild(menuBar)

    --二级棕色背景
    local m_chatViewBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    m_chatViewBg:setContentSize(CCSizeMake(570,470))
    m_chatViewBg:setAnchorPoint(ccp(0.5,1))
    m_chatViewBg:setPosition(ccpsprite(0.5,1,_midNode))
    _midNode:addChild(m_chatViewBg)
    --联系GM界面，先创建出来 不显示
    _GMLayer = ChatGmLayer.getChatGmLayer(_touchPriority - 60)
    _GMLayer:ignoreAnchorPointForPosition(false)
    _GMLayer:setAnchorPoint(ccp(0.5,1))
    _GMLayer:setPosition(ccp(_chatLayerBg:getContentSize().width*0.5,650))
    _chatLayerBg:addChild(_GMLayer)
    _GMLayer:setVisible(false)

    --创建下面的文本输入框    
    createInputDialog()
    --聊天内容的scrollview
    _chatScrollView = CCScrollView:create()
    _chatScrollView:setTouchPriority(_touchPriority - 20)
    --_chatScrollView:setContentSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.68))
    _chatScrollView:setViewSize(CCSizeMake(570,470))
    _chatScrollView:setDirection(kCCScrollViewDirectionVertical)
    _chatScrollView:setAnchorPoint(ccp(0,0))
    _chatScrollView:setPosition(ccp(0,0))
    m_chatViewBg:addChild(_chatScrollView)

    --创建标签
    require "script/libs/LuaCCMenuItem"
    
	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(175, 50)
	local btn_size_n2	= CCSizeMake(115, 50)
	local btn_size_h	= CCSizeMake(180, 55)
	local btn_size_h2	= CCSizeMake(120, 55)
	
	local text_color_n	= ccc3(0xf2, 0xe0, 0xcc)
	local text_color_h	= ccc3(0xff, 0xff, 0xff)
	local font			= g_sFontPangWa
	local font_size		= 30
	local strokeCor_n	= ccc3(0xf2, 0xe0, 0xcc)
	local strokeCor_h	= ccc3(0x00, 0x00, 0x00)
	local stroke_size_n	= 0
    local stroke_size_h = 1
    
    -- 原来的数据结构整理完才发现封装的方法不支持九宫格。。。。气哭了。。。哭了一下午。。。

    --创建menubar用的参数table
    local radio_data = {}
    radio_data.touch_priority = _touchPriority - 50
    radio_data.space = 15
    radio_data.callback = menuBarCb
    radio_data.direction = 1
    radio_data.defaultIndex = _curIndex
    radio_data.items = {}

    local worldButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("key_1664"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    
    local pmButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("key_1608"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)


    local unionButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("key_3406"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    local gmButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n, btn_size_h,btn_size_h,
          GetLocalizeStringBy("key_1531"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(radio_data.items,worldButton)
    table.insert(radio_data.items,pmButton)
    table.insert(radio_data.items,unionButton)
    table.insert(radio_data.items,gmButton)

    _menuBar = LuaCCSprite.createRadioMenuWithItems(radio_data)
    _menuBar:setAnchorPoint(ccp(0.5,0))
    _menuBar:setPosition(ccp(_chatLayerBg:getContentSize().width * 0.5,650))
    _chatLayerBg:addChild(_menuBar)
    --刷新私聊红点
    refreshPmTip()
    --刷新聊天界面
    refreshChatView(_curIndex,true)
end


--[[
    @des    :创建下方输入框的UI
    @param  :
    @return :
--]]
function createInputDialog()
    local m_layerSize = CCSizeMake(620,700)
    -- 提示字数限制
    local max_length = 40
    _max_length_tip = CCLabelTTF:create(GetLocalizeStringBy("key_8031", tostring(max_length)), g_sFontName, 23)
    _max_length_tip:setAnchorPoint(ccp(0, 0))
    _max_length_tip:setPosition(ccpsprite(0.05, 0.17,_midNode))
    _max_length_tip:setColor(ccc3(0x00, 0x00, 0x00))
    _midNode:addChild(_max_length_tip)
    
    --文本输入框
    if(RecordUtil.isRecordOpen() == true)then
        _talkEditBox = CCEditBox:create (CCSizeMake(380,60), CCScale9Sprite:create("images/chat/input_bg.png"))
        _talkEditBox:setPosition(ccpsprite(0.15,0.1,_midNode))
    else
        _talkEditBox = CCEditBox:create (CCSizeMake(450,60), CCScale9Sprite:create("images/chat/input_bg.png"))
        _talkEditBox:setPosition(ccpsprite(0.05,0.1,_midNode))
    end
    
    _talkEditBox:setAnchorPoint(ccp(0,0.5))
    _talkEditBox:setPlaceHolder(GetLocalizeStringBy("key_2499"))
    --talkEditBox:setScale(g_originalDeviceSize.width/g_winSize.width)
    _talkEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
    _talkEditBox:setMaxLength(max_length)
    _talkEditBox:setReturnType(kKeyboardReturnTypeDone)
    _talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    _talkEditBox:setTouchPriority(_touchPriority -2)
    

    -- if(_talkEditBox:getChildByTag(1001)~=nil)then
    --     tolua.cast(_talkEditBox:getChildByTag(1001),"CCLabelTTF"):setColor(ccc3(0xff,0xfb,0xd9))
    -- end
    -- if(_talkEditBox:getChildByTag(1002)~=nil)then
    --     tolua.cast(_talkEditBox:getChildByTag(1002),"CCLabelTTF"):setColor(ccc3(0xc3,0xc3,0xc3))
    -- end
    _talkEditBox:setFont(g_sFontName,23)
    
    _midNode:addChild(_talkEditBox)

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 50)
    _midNode:addChild(menu)
    
    require "script/libs/LuaCC"
    _sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_1138"),ccc3(255,222,0))
    _sendButton:setAnchorPoint(ccp(0.5,0.5))
    _sendButton:setPosition(ccp(m_layerSize.width*0.87,m_layerSize.height*0.1))
    _sendButton:registerScriptTapHandler(ChatControler.sendClick)
    
    menu:addChild(_sendButton)


    if(RecordUtil.isRecordOpen() == true)then
        --如果开启语音功能的话
        -- 键盘按钮
        _keyButton = CCMenuItemImage:create("images/chat/btn_keyboard_n.png", "images/chat/btn_keyboard_h.png")
        _keyButton:setAnchorPoint(ccp(0,0.5))
        _keyButton:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.1))
        _keyButton:registerScriptTapHandler(switchBoardAction)
        _keyButton:setVisible(false)
        menu:addChild(_keyButton)
        
        -- 语音按钮
        _audioButton = CCMenuItemImage:create("images/chat/btn_audio_n.png", "images/chat/btn_audio_h.png")
        _audioButton:setAnchorPoint(ccp(0,0.5))
        _audioButton:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.1))
        _audioButton:registerScriptTapHandler(switchBoardAction)
        -- _audioButton:setVisible(false)
        menu:addChild(_audioButton)

        _curButton = _audioButton

        -- 录音条按钮
        local normal_sprite = CCScale9Sprite:create("images/chat/audio_9scale_n.png")
        normal_sprite:setContentSize(CCSizeMake(380,60))
        local normal_label = CCLabelTTF:create(GetLocalizeStringBy("key_10006"), g_sFontName, 21)
        normal_label:setColor(ccc3(62,36,07))
        normal_label:setAnchorPoint(ccp(0.5,0.5))
        normal_label:setPosition(ccp(190,30))
        normal_sprite:addChild(normal_label)

        local highlight_sprite = CCScale9Sprite:create("images/chat/audio_9scale_h.png")
        highlight_sprite:setContentSize(CCSizeMake(380,60))
        local highlight_label = CCLabelTTF:create(GetLocalizeStringBy("key_10007"), g_sFontName, 21)
        highlight_label:setColor(ccc3(62,36,07))
        highlight_label:setAnchorPoint(ccp(0.5,0.5))
        highlight_label:setPosition(ccp(190,30))
        highlight_sprite:addChild(highlight_label)

        require "script/ui/chat/BTSButton"
        _recorderBtn = BTSButton:createWithNode(normal_sprite, highlight_sprite,ChatControler.endRecorder, ChatControler.beganRecorder, ChatControler.cancelRecorder, ChatControler.movedCallback)
        _recorderBtn:setPosition(ccpsprite(0.15,0.06,_midNode))
        -- b_button:setIsRelativeAnchorPoint(true)
        _recorderBtn:setAnchorPoint(ccp(0, 0))
        _midNode:addChild(_recorderBtn)
        _recorderBtn:setVisible(false)
    end

    -------- 私聊
    _pmNode = CCNode:create()
    --"对"
    local nameDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3267"),g_sFontName,23)
    nameDescLabel:setAnchorPoint(ccp(1,0.5))
    --nameDescLabel:setPosition(ccp(m_layerSize.width*0.05, m_layerSize.height*0.17))
    nameDescLabel:setColor(ccc3(0x00,0x6d,0x2f))
    --m_chatLayerBg:addChild(nameDescLabel)
    _pmNode:addChild(nameDescLabel)
    --接收输入名字
    _nameEditBox = CCEditBox:create (CCSizeMake(250,60), CCScale9Sprite:create("images/chat/input_bg.png"))
    _nameEditBox:setPosition(ccp(nameDescLabel:getPositionX() + 5,nameDescLabel:getPositionY()))
    _nameEditBox:setAnchorPoint(ccp(0, 0.5))
    _nameEditBox:setPlaceHolder(GetLocalizeStringBy("key_1397"))
    --nameEditBox:setScale(g_originalDeviceSize.width/g_winSize.width)
    _nameEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
    _nameEditBox:setMaxLength(13)
    _nameEditBox:setReturnType(kKeyboardReturnTypeDone)
    _nameEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    _nameEditBox:setTouchPriority(_touchPriority - 2)

    if(_targetName~=nil)then
        _nameEditBox:setText(_targetName)
    end
    
    -- if(_nameEditBox:getChildByTag(1001)~=nil)then
    --     tolua.cast(_nameEditBox:getChildByTag(1001),"CCLabelTTF"):setColor(ccc3(0x00,0xe4,0xff))
    -- end
    
    -- if(_nameEditBox:getChildByTag(1002)~=nil)then
    --     tolua.cast(_nameEditBox:getChildByTag(1002),"CCLabelTTF"):setColor(ccc3(0x00,0xe4,0xff))
    -- end
    
    _nameEditBox:setFont(g_sFontName,23)
    
    _pmNode:addChild(_nameEditBox)
    --“说”
    nameTalkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2978"),g_sFontName,23)
    nameTalkLabel:setAnchorPoint(ccp(0,0.5))

    nameTalkLabel:setPosition(_nameEditBox:getPositionX() + _nameEditBox:getContentSize().width + 5,_nameEditBox:getPositionY())
    nameTalkLabel:setColor(ccc3(0x00,0x6d,0x2f))
    _pmNode:addChild(nameTalkLabel)

    _pmNode:setContentSize(CCSizeMake(nameDescLabel:getContentSize().width + _nameEditBox:getContentSize().width + nameTalkLabel:getContentSize().width, _nameEditBox:getContentSize().height))
    _pmNode:setAnchorPoint(ccp(0,0))
    _pmNode:setPosition(ccpsprite(0.1,0.2,_midNode))
    _midNode:addChild(_pmNode)
 
     -- 更换头像
    _change_head_btn = CCMenuItemImage:create("images/chat/change_head_n.png","images/chat/change_head_h.png")
    _change_head_btn:setAnchorPoint(ccp(0.5,0.5))
    _change_head_btn:setPosition(ccp(m_layerSize.width*0.87, m_layerSize.height * 0.2))
    menu:addChild(_change_head_btn)
    _change_head_btn:registerScriptTapHandler(ChatControler.callbackChangeHead)

    refreshInputUI()
 
end


--[[
	@des 	:入口函数
	@param 	:viewIndex：进来时默认在哪种聊天界面(1:世界 2:私聊 3:军团 4:联系GM)
	@return :
--]]
function showChatLayer(p_viewIndex, p_touchPriority, p_zOrder)
    if _isOpen == true then
        closeLayer()
        showChatLayer(p_viewIndex, p_touchPriority, p_zOrder)
        return 
        --这种情况 是针对 当前聊天界面已经打开了 但是从世界频道中点击某人 头像 转到私聊的情况 为了防止创建两层layer 加了这种判 
        --print("p_viewIndex,_curIndex",p_viewIndex,_curIndex) 
        -- local selectedItem = _menuBar:getChildByTag(p_viewIndex)
        -- local curSelectedItem = _menuBar:getChildByTag(_curIndex)
        -- if(selectedItem ~= nil)then
        --     selectedItem = tolua.cast(selectedItem, "CCMenuItem")
        --     curSelectedItem = tolua.cast(curSelectedItem, "CCMenuItem")
        --     selectedItem:setEnabled(false)
        --     curSelectedItem:setEnabled(true)
        -- end
        -- menuBarCb(p_viewIndex)
        -- return

    end
    
    _isOpen = true
    init()
    _touchPriority = p_touchPriority or -499
    
    _ZOrder = p_zOrder or 1200
    _curIndex = p_viewIndex or WORLD_TAG
 
    _chatMainLayer = CCLayerColor:create(ccc4(11,11,11,166))
    _chatMainLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild( _chatMainLayer, _ZOrder, 3121)

    if(ChatControler == nil)then
        --本来是ChatControler引用了ChatMainLayer 但是如果在玩家从登陆到打开聊天界面这段时间，一直没有聊天内容推送进来的话，ChatMainLayer又先于ChatControler被引用
        --而又不能循环引用，所以这里用了一个判断方法，表怪我。。。。
        require "script/ui/chat/ChatControler"
    end
    ChatControler.init()
    createLayer()  

    return _chatMainLayer     
end