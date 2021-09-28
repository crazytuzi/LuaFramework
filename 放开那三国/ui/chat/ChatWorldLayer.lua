-- Filename: ChatWorldLayer.lua
-- Author: k
-- Date: 2013-08-16
-- Purpose: 世界聊天


require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/ui/chat/ChatMainLayer"
--require "amf3"
-- 主城场景模块声明
module("ChatWorldLayer", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/libs/LuaCCLabel"


local IMG_PATH = "images/chat/"				-- 图片主路径

local m_chatWorldLayer  = nil
local m_chatLayerBg
local worldButton
local pmButton
local gmButton

local hornNumberLabel
local chatInterface
local chatItemId
local scrollView
local m_layerSize
local _touchPriority

local _keyButton = nil
local _audioButton = nil
local _curButton = nil
local talkEditBox = nil
local _recorderBtn = nil

local m_chatWorldInfo = {}

function addChatInfo(chatInfo)
    ChatUtil.cleanChatInfos(m_chatWorldInfo)
    m_chatWorldInfo[#m_chatWorldInfo+1] = chatInfo
    if m_chatWorldLayer ~= nil then
        refreshChatView()
    end
end

function getChatInfoes()
    return m_chatWorldInfo
end


local function cardLayerTouch(eventType, x, y)
    return true
end

function closeClick()
    m_chatWorldLayer:removeFromParentAndCleanup(true)
end


function showBroadCastView()
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert( GetLocalizeStringBy("key_3021"), nil, false, nil)
end

function callbackChangeHead()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "db/DB_Normal_config"
    require "script/model/user/UserModel"
    require "script/ui/tip/SingleTip"
    local vip_level_need = DB_Normal_config. getDataById(1).chatChangeHead
    if vip_level_need > UserModel.getVipLevel() then
        SingleTip.showTip("VIP" .. tostring(vip_level_need) .. GetLocalizeStringBy("key_8030"))
        return
    end
    require "script/ui/chat/ChangeHeadLayer"
    ChangeHeadLayer.show()
end

function showFriendView(tag,node)
    local index = node:getTag()
    local chatInfo = m_chatWorldInfo[index]
    
    local htid = tonumber(chatInfo.sender_tmpl)
    if(chatInfo.figure~=nil and #(chatInfo.figure)>0)then
        --[[
        require "db/DB_Item_dress"
        local dress = DB_Item_dress.getDataById(tmplId)
        for modelIndex=1,#modelArray do
            local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
            local dressHtid = lua_string_split(modelArray[modelIndex],"|")[2]
            
            require "db/DB_Heroes"
            local heroTmpl = DB_Heroes.getDataById(tonumber(cardInfo.htid))
            if(heroTmpl.model_id == tonumber(baseHtid))then
                print("m_playerCardHidMap[cardInfo.hid]:",cardInfo.hid,baseHtid)
                m_playerCardHidMap[cardInfo.hid .. ""] = tonumber(dressHtid)
            end
        end
         --]]
    end
    
    ChatMainLayer.showFriendView(chatInfo.sender_uname,chatInfo.sender_level,chatInfo.sender_fight,htid,chatInfo.sender_uid,chatInfo.sender_gender,chatInfo.figure)
end

function refreshChatView()
    local index = #m_chatWorldInfo
    local chat_info = m_chatWorldInfo[index]
    require "script/ui/chat/ChatInfoCell"
    local chat_info_cell = ChatInfoCell.create(ChatInfoCell.ChatInfoCellType.normal, chat_info, index, showFriendView, nil, nil, _touchPriority - 2)
    ChatUtil.addChatInfoCell(scrollView, chat_info_cell)
end

-- 获得世界聊天层
function getChatWorldLayer(touchPriority)
    _touchPriority = touchPriority or -410
    m_layerSize = CCSizeMake(620,700)
    
    m_chatWorldLayer = CCLayer:create()
    m_chatWorldLayer:registerScriptHandler(onNodeEvent)
    m_chatWorldLayer:setAnchorPoint(ccp(0,0))
    m_chatWorldLayer:setPosition(ccp(0,0))
    
    scrollView = CCScrollView:create()
    scrollView:setTouchPriority(_touchPriority - 20)
	scrollView:setContentSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.68))
	scrollView:setViewSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.68))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0,0))
	scrollView:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height*0.26))
    m_chatWorldLayer:addChild(scrollView)
    
    local chatInfoLayer = CCLayer:create()
    scrollView:setContainer(chatInfoLayer)
    chatInfoLayer:setAnchorPoint(ccp(0,0))
    chatInfoLayer:setPosition(ccp(0,0))
    require "script/libs/LuaCCLabel"
    local startIndex = #m_chatWorldInfo>60 and #m_chatWorldInfo-60 or 1
    for i=startIndex,#m_chatWorldInfo do
        local chatInfo = m_chatWorldInfo[i]
        require "script/ui/chat/ChatInfoCell"
        local chat_info_cell = ChatInfoCell.create(ChatInfoCell.ChatInfoCellType.normal, chatInfo, i, showFriendView, nil, nil, touchPriority - 2)
        ChatUtil.addChatInfoCell(scrollView, chat_info_cell)
    end
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 1)
    m_chatWorldLayer:addChild(menu)
    -- 更换头像
    local change_head_btn = CCMenuItemImage:create(IMG_PATH .. "change_head_n.png",IMG_PATH .. "change_head_h.png")
    change_head_btn:setAnchorPoint(ccp(0.5,0.5))
    change_head_btn:setPosition(ccp(m_layerSize.width*0.87, m_layerSize.height * 0.2))
    menu:addChild(change_head_btn)
    change_head_btn:registerScriptTapHandler(callbackChangeHead)
    
    -- 发言需要的物品
	local hornDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3315"),g_sFontName,23)
    hornDescLabel:setAnchorPoint(ccp(0,0))
    hornDescLabel:setPosition(ccp(m_layerSize.width*0.05, m_layerSize.height*0.15))
    hornDescLabel:setColor(ccc3(0x00,0x6d,0x2f))
    m_chatWorldLayer:addChild(hornDescLabel)
    
    hornDescLabel:setVisible(false)
    
    require "db/DB_Chat_interface"
    chatInterface = DB_Chat_interface.getDataById(1)
    if(chatInterface ==nil or chatInterface.chat_cost_goods==nil)then
        chatItemId = 0
    else
        chatItemId = tonumber(lua_string_split(chatInterface.chat_cost_goods,"|")[1])
    end
    require "script/ui/item/ItemUtil"
    local itemInfo = ItemUtil.getCacheItemInfoBy(tonumber(chatItemId))
    local hornNumber = 0
    if(itemInfo ~= nil and itemInfo.item_num ~= nil and tonumber(itemInfo.item_num) ~= 0)then
        hornNumber = itemInfo.item_num
    end

    return m_chatWorldLayer
end

---
function getChatInfoByIndex(p_index)
    return m_chatWorldInfo[p_index]
end


function onNodeEvent(event)
    if event == "enter" then
    elseif event == "exit" then
        m_chatWorldLayer = nil
    end
end

-- 退出场景，释放不必要资源
function release (...) 

end


