-- Filename: ChatPmLayer.lua
-- Author: k
-- Date: 2013-08-16
-- Purpose: 私聊



require "script/utils/extern"
require "script/utils/LuaUtil"
--require "amf3"
-- 主城场景模块声明
module("ChatPmLayer", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/libs/LuaCCLabel"
require "script/ui/chat/ChatInfoCell"
require "script/ui/chat/ChatCache"
require "script/ui/chat/ChatUtil"

local IMG_PATH = "images/chat/"				-- 图片主路径

local m_chatPmLayer     = nil
local m_chatLayerBg
local nameEditBox
local talkEditBox

local uid
local utid
local htid
local fight
local ulevel
local dressInfo
local scrollView
local m_layerSize

local m_chatPmInfo = {}
local _touchPriority



function addChatInfo(chatInfo)
    ChatUtil.cleanChatInfos(m_chatPmInfo)
    m_chatPmInfo[#m_chatPmInfo+1] = chatInfo
    if m_chatPmLayer ~= nil then
        refreshChatView()
    end
end

local function cardLayerTouch(eventType, x, y)
    return true
    
end

function closeClick()
    m_chatPmLayer:removeFromParentAndCleanup(true)
end



function showBroadCastView()
    
end

function showFriendView(tag,node)
    local index = node:getTag()
    local chatInfo = m_chatPmInfo[index]
    
    ChatMainLayer.showFriendView(chatInfo.sender_uname,chatInfo.sender_level,chatInfo.sender_fight,chatInfo.sender_tmpl,chatInfo.sender_uid,chatInfo.sender_gender,chatInfo.figure)
end

function refreshChatView()
    local index = #m_chatPmInfo
    local chat_info = m_chatPmInfo[index]
    require "script/ui/chat/ChatInfoCell"
    local chat_info_cell = ChatInfoCell.create(ChatInfoCell.ChatInfoCellType.normal, chat_info, index, showFriendView, nil, chatCellClickCallback, _touchPriority - 10)
    ChatUtil.addChatInfoCell(scrollView, chat_info_cell)
end

-- 获得私聊层
function getChatPmLayer(touchPriority)
    _touchPriority = touchPriority or -410
    m_layerSize = CCSizeMake(620,700)
    
    m_chatPmLayer = CCLayer:create()
    m_chatPmLayer:registerScriptHandler(onNodeEvent)
    m_chatPmLayer:setAnchorPoint(ccp(0,0))
    m_chatPmLayer:setPosition(ccp(0,0))
    
    scrollView = CCScrollView:create()
    scrollView:setTouchPriority(_touchPriority - 20)
	scrollView:setContentSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.68))
	scrollView:setViewSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.68))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0,0))
	scrollView:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.26))
    m_chatPmLayer:addChild(scrollView)
    
    local chatInfoLayer = CCLayer:create()
    scrollView:setContainer(chatInfoLayer)
    chatInfoLayer:setAnchorPoint(ccp(0,0))
    chatInfoLayer:setPosition(ccp(0,0))
    
    require "script/libs/LuaCCLabel"
    
    local startIndex = #m_chatPmInfo>60 and #m_chatPmInfo-60 or 1
    for i=startIndex,#m_chatPmInfo do
        local chatInfo = m_chatPmInfo[i]
        local chat_info_cell = ChatInfoCell.create(ChatInfoCell.ChatInfoCellType.normal, chatInfo, i, showFriendView, nil, chatCellClickCallback, _touchPriority - 10)
        ChatUtil.addChatInfoCell(scrollView, chat_info_cell)
    end
    
    return m_chatPmLayer
end

function chatCellClickCallback( tag, menuItem )
    local index = tag
    local chatInfo = m_chatPmInfo[index]
    if chatInfo.sender_uname ~= UserModel.getUserName() then
        ChatMainLayer.setNameEditBox(chatInfo.sender_uname)
    end
end

---
function getChatInfoByIndex(p_index)
    return m_chatPmInfo[p_index]
end

function onNodeEvent(event)
    if event == "enter" then
    elseif event == "exit" then
        m_chatPmLayer = nil
    end
end

-- 退出场景，释放不必要资源
function release (...) 

end
