-- Filename: ChatUtil.lua
-- Author: bzx
-- Date: 2014-05-20
-- Purpose: 聊天工具

module("ChatUtil", package.seeall)

require "db/DB_Chat_interface"
require "script/model/user/UserModel"
require "script/ui/chat/ChatCache"
require "script/ui/tip/AlertTip"
require "db/DB_Vip"


BattleTabStr = "battle-info"        -- 发送战报
AudioTabStr = "audio-info"          -- 语音聊天

-- 发送聊天信息
function sendChatinfo(chat_info, chat_info_type, channel_type, handler, uid)
    local text = nil
    -- 战报
    if chat_info_type == ChatCache.ChatInfoType.battle_report_player or 
        chat_info_type == ChatCache.ChatInfoType.battle_report_union or
        chat_info_type == ChatCache.ChatInfoType.battle_report_city then
        text = "<".. BattleTabStr ..">" .. chat_info.team1.name .. "," .. chat_info.team2.name .. "," ..
         chat_info.brid .. "," .. chat_info_type .. "</".. BattleTabStr..">"
    else
        text = chat_info
    end
    
    local hero_vip_level = UserModel.getVipLevel()
    local vip_db = DB_Vip.getDataById(hero_vip_level + 1)
    local chat_interface = DB_Chat_interface.getDataById(channel_type)
    local vip_is_chat = vip_db.isChat == nil and 0 or vip_db.isChat
    local level_limit = chat_interface.lv_require == nil and 0 or chat_interface.lv_require
    local could_send = true
    local tip_text = nil
    if  text == "" then
        could_send = false
        tip_text = GetLocalizeStringBy("key_2349")
    elseif vip_is_chat == 0 and level_limit > UserModel.getHeroLevel() then
        could_send = false
        if channel_type == ChatCache.ChannelType.world then
            tip_text = GetLocalizeStringBy("key_2805", tostring(level_limit))
        elseif channel_type == ChatCache.ChannelType.pm then
            tip_text = GetLocalizeStringBy("key_3122", tostring(level_limit))
        elseif channel_type == ChatCache.ChannelType.union then
            tip_text = GetLocalizeStringBy("key_8079", tostring(level_limit))
        end
    end
    if could_send then
        if channel_type == ChatCache.ChannelType.world then
            sendWorld(text, handler)
        elseif channel_type == ChatCache.ChannelType.pm then
            print("uid, text,=", uid, text)
            sendPm(uid, text, handler)
        elseif channel_type == ChatCache.ChannelType.union then
            sendUnion(text, handler)
        end
    else
        AlertTip.showAlert(tip_text, nil, false, nil)
    end
end

--
function getTable(table_str)
    local str_len = string.len(table_str)
    local new_str = string.sub(table_str, 8, str_len - 8)
    return string.split(new_str, ",")
end

-- 解析标签内容
function parseTabContent( table_str,  tab_type)
    local str_len = string.len(table_str)
    local tab_len = string.len(tab_type) +3
    local new_str = string.sub(table_str, tab_len, str_len - tab_len)
    return string.split(new_str, ",")
end

function isTable(text)
    local text_len = string.len(text)
    local is_table = string.sub(text, 1, 7) == "<table>" and string.sub(text, text_len - 7, text_len) == "<table/>"
    return is_table
end

function sendPm(uid, text, handler)
    RequestCenter.chat_sendPersonal(function ( cbFlag, dictData, bRet )
        handler(cbFlag, dictData, bRet, text)
    end,Network.argsHandler(uid,text))
end

function sendWorld(text, handler)
    RequestCenter.chat_sendWorld(handler,Network.argsHandler(text, 2))
     --[[
        -- 判断物品是否够
        require "script/ui/item/ItemUtil"
        local itemInfo = ItemUtil.getCacheItemInfoBy(chatItemId)
        if((itemInfo == nil or itemInfo.item_num == 0) and chatItemId ~= 0)then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_2764"))
            return
        end
    --]]
end

function sendUnion(text, handler)
    RequestCenter.chat_sendGuild(handler,Network.argsHandler(text))
end

function addChatInfoCell(scroll_view, chat_info_cell)
    local container = scroll_view:getContainer()
    container:addChild(chat_info_cell)
    chat_info_cell:ignoreAnchorPointForPosition(false)
    chat_info_cell:setPosition(ccp(scroll_view:getViewSize().width * 0.5, chat_info_cell:getContentSize().height))
    chat_info_cell:setAnchorPoint(ccp(0.5,1))

    local chat_info_cells = container:getChildren() 
    if chat_info_cells:count() >= 61 then
         --消息队列的数量达到规定的上限 要清理一条 
         local chat_info_cell_temp = tolua.cast(chat_info_cells:objectAtIndex(0), "CCNode")
         chat_info_cell_temp:removeFromParentAndCleanup(true)
         chat_info_cells = container:getChildren()
    end
    local total_height = 0
    for i = 1, chat_info_cells:count() do
        local chat_info_cell_temp = tolua.cast(chat_info_cells:objectAtIndex(i - 1), "CCNode")
        total_height = total_height + chat_info_cell_temp:getContentSize().height
    end

    local min_height = 476
    if total_height < min_height then
        total_height = min_height
    end

    local content_size = container:getContentSize()
    scroll_view:setContentSize(CCSizeMake(content_size.width, total_height))
    scroll_view:setContentOffset(ccp(0, 0))

    for i = 1, chat_info_cells:count() do
        local chat_info_cell_temp = tolua.cast(chat_info_cells:objectAtIndex(i - 1), "CCNode")
        chat_info_cell_temp:setPositionY(total_height)
        total_height = total_height - chat_info_cell_temp:getContentSize().height
    end
end
--刷新聊天界面内各个格子的高度和位置，因为新增的语音功能在翻译后可能翻译出很长一段话，被下面的聊天内容覆盖的情况，所以每次点击翻译后，要调用一下这个函数
function refreshView( scroll_view)
    local container = scroll_view:getContainer()

    --因为推出了语音功能 翻译上有长有短 所以高度要重新算
    local chat_info_cells = container:getChildren()
    local total_height = 0
    --local needRoload = false --记录是否需要重新设置高度的标志位
    for i = 1, chat_info_cells:count() do
        local chat_info_cell_temp = tolua.cast(chat_info_cells:objectAtIndex(i - 1), "CCNode")
        total_height = total_height + chat_info_cell_temp:getContentSize().height
        -- if(chat_info_cell_temp:getContentSize().height > 170)then
        --     needRoload = true
        -- end
    end
    -- if(needRoload == false)then
    --     --如果遍历了一圈发现并没有超高的cell 就不用刷新了
    --     return
    -- end
    local min_height = 476
    if total_height < min_height then
        total_height = min_height
    end

    local content_size = container:getContentSize()
    scroll_view:setContentSize(CCSizeMake(content_size.width, total_height))
    scroll_view:setContentOffset(ccp(0, 0))
    for i = 1, chat_info_cells:count() do
        local chat_info_cell_temp = tolua.cast(chat_info_cells:objectAtIndex(i - 1), "CCNode")    
        chat_info_cell_temp:ignoreAnchorPointForPosition(false)
        chat_info_cell_temp:setAnchorPoint(ccp(0.5,1))
        chat_info_cell_temp:setPositionY(total_height)
        total_height = total_height - chat_info_cell_temp:getContentSize().height
    end
end
--清理一下消息队列长度
function cleanChatInfos(chat_infoes)
    if #chat_infoes >= 100 then
        for i = 1, 40 do
            table.remove(chat_infoes, 1)
        end
        --为了防止玩家登陆后很久没有打开聊天，世界聊天频道消息过多的情况，要递归检查一下消息队列的长度
        if #chat_infoes >= 100 then
            cleanChatInfos(chat_infoes)
        else
            return
        end
    end
end


-- 是不是这个类型的聊天类型
function isChatCellTypeBy(chat_info, p_type_str)
    local text_len  = string.len(chat_info)
    local tab_len   = string.len(p_type_str) +2
    return string.sub(chat_info, 1, tab_len) == "<"..p_type_str..">" and string.sub(chat_info, text_len - tab_len, text_len) == "</"..p_type_str..">"
end

-- 拼接语音聊天串
function unionAudioText( aid, aSec)
    
    return "<" .. AudioTabStr .. ">".. aid ..","..aSec .."</"..AudioTabStr..">"
end





