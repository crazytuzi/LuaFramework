-- Filename：	ChatInfoCell.lua
-- Author：		DJN
-- Date：		2015-05-4
-- Purpose：		聊天信息Cell
require "script/ui/chat/ChangeHeadLayer"
require "script/model/user/UserModel"
require "script/model/utils/HeroUtil"
require "script/ui/chat/ChatUtil"
require "script/libs/LuaCCLabel"
-- require "script/ui/chat/ChatControler"
ChatInfoCell = class("ChatInfoCell",function ()
    return CCNode:create()
end)
ChatInfoCell.Direction = {                --消息方向
    left      = 1,
    right     = 2
    }
ChatInfoCell.Sex = {                       --发送者性别
    boy     = 1,
    girl    = 2
    }

ChatInfoCell._chatInfoCellType =  {          -- 消息类型
    normal         = 1,     -- 普通
    copyReport     = 2,     -- 副本战报
    playerReport   = 3      -- PVP战报
    }
ChatInfoCell.kTagLaba = 10086              -- 小喇叭的tag
function ChatInfoCell:ctor( ... )
    self.chatInfo            = {}      --聊天信息
    self.cell_size           = CCSizeMake(568,170)     --聊天消息盒子的尺寸  

    self._touch_priority = nil              --触摸优先级
    self.labaEffect = nil              --喇叭特效
    self._labaSprite = nil             --喇叭图标
    self.battleReportCb  = nil         --点击查看战报的回调
    self.pmClickCb = nil               --点击私聊的回调
    self.callback_head = nil           --点击头像的回调
    self.isPlaying    = false          --是否正在播放语音
    
end
--[[
    @param cell_type            消息的类型
    @param data                 数据
    @param index                索引
    @param callback_head        点击头像的回调
    @param callback_look_report 点击查看战报的回调
--]]
function ChatInfoCell:create(cell_type, data, index, callback_head, callback_look_report, PmCallback, touchPriority)
  
    local cell = ChatInfoCell:new()
    cell._touch_priority = touchPriority or -404
    cell.chatInfo = data
    cell.battleReportCb = callback_look_report
    cell.pmClickCb = PmCallback
    cell.callback_head = callback_head  
    cell:setContentSize(cell.cell_size)
    cell:setAnchorPoint(ccp(0.5, 1))
    local uid = tonumber(data.sender_uid)
    local direction = nil
    if uid == UserModel.getUserUid() then
        direction = ChatInfoCell.Direction.right
    else
        direction = ChatInfoCell.Direction.left
    end
    
    -- 如果是普通消息，要改变方向
    if cell_type == ChatInfoCell._chatInfoCellType.normal then
        local distance_x = 105
        -- local distance_y = 50
        local box =cell:createBox(cell.chatInfo, direction)
        if(box:getContentSize().height > cell.cell_size.height)then
            --这种情况是针对 玩家在对长语音翻译过后退出了聊天 又重新进入 这个时候语音已经是转换为文字了 这个时候可能高度比原来的cell高度要高
            cell:setContentSize(ccp(cell.cell_size.width,box:getContentSize().height))
        end
        box:ignoreAnchorPointForPosition(false)
        cell:addChild(box)
        if direction == ChatInfoCell.Direction.left then
            box:setAnchorPoint(ccp(0, 1))
            --box:setPosition(ccp(head_btn:getPositionX() + distance_x, head_btn:getPositionY() + distance_y))
            box:setPosition(ccp( distance_x, cell:getContentSize().height-20))
        elseif direction == ChatInfoCell.Direction.right then
            box:setAnchorPoint(ccp(1, 1))
            box:setPosition(ccp( cell.cell_size.width -distance_x, cell:getContentSize().height-20))
        end
    end
    return cell
end

-- 根据x改变方向
function ChatInfoCell:across(node, x)
    local anchor_point = node:getAnchorPoint()
    node:setAnchorPoint(ccp(1 - anchor_point.x, anchor_point.y))
    node:setPositionX(x * 2 - node:getPositionX())
end
-------------------------------------------------------------------------
-- ／￣￣￣Y￣￣ ＼
-- 　 　 l　　　　　　　　　l
-- 　　 ヽ,,,,,／ ￣￣￣￣ ヽﾉ
-- 　　　|::::: 　　　　　　　l
-- 　　　|:::　　 ＿_　　　　 |
-- 　　（6　　　＼●>　 <●人
-- 　　　!　　　　　 )・・(　 l
-- 　　　ヽ 　 　　　　(三)　 ﾉ
-- 　　　 ／＼　　　　二　 ノ
-- 　　 /⌒ヽ. ‘ー — 一* ＼
-- 　　l　　　 |　　　　　 ヽo　ヽ
-----------------------------------------------------------------------------

-- /＼7　　　 ∠＿/
-- 　 /　│　　 ／　／
-- 　│　Z ＿,＜　／　　 /`ヽ
-- 　│　　　　　ヽ　　 /　　〉
-- 　 Y　　　　　`　 /　　/
-- 　ｲ●　､　●　　⊂⊃〈　　/
-- 　()　 へ　　　　|　＼〈
-- 　　>ｰ ､_　 ィ　 │ ／／
-- 　 / へ　　 /　ﾉ＜| ＼＼
-- 　 ヽ_ﾉ　　(_／　 │／／
-- 　　7　　　　　　　|／
-- 　　＞―r￣￣`ｰ―＿
-----------------------------------------------------------------------------
function ChatInfoCell:createBox(chat_info, direction)

    local is_vip = tonumber(chat_info.sender_vip) > 0
    local text = chat_info.message_text
    print("texttexttexttext",chat_info.message_text)
    local bg_infos = {
        {
            file_name = "images/chat/box_boy.png",      -- 背景
            full_rect = CCRectMake(0, 0, 49, 62),
            insert_rect = CCRectMake(17, 47, 4, 1),
            text_color = ccc3(0x00, 0x00, 0x00),        -- 文字颜色
            bg_width_min = 50,                          -- 背景最小宽度
            single_line_height = 62,                    -- 只有一行时的高度
            lable_width_max = 390                       -- 文字最大宽度
        },
        {
            file_name = "images/chat/box_girl.png",
            full_rect = CCRectMake(0, 0, 49, 62),
            insert_rect = CCRectMake(17, 47, 4, 1),
            text_color = ccc3(0x00, 0x00, 0x00),
            bg_width_min = 50,
            single_line_height = 62,
            lable_width_max = 390
        },
        {
            file_name = "images/chat/vip_box_boy.png",
            full_rect  = CCRectMake(0, 0, 50, 70),
            insert_rect = CCRectMake(18, 51, 2, 1),
            text_color = ccc3(0xff, 0xff, 0xff),
            bg_width_min = 110,
            single_line_height = 70,
            lable_width_max = 390
        },
        {
            file_name = "images/chat/vip_box_girl.png",
            full_rect  = CCRectMake(0, 0, 50, 70),
            insert_rect = CCRectMake(18, 51, 2, 1),
            text_color = ccc3(0xff, 0xff, 0xff),
            bg_width_min = 110,
            single_line_height = 70,
            lable_width_max = 390
        }
    }
  
    local bg_index = nil
    if is_vip then
        if chat_info.sender_gender  == "1" then -- 男
            bg_index = 3
        else -- 女
            bg_index = 4
        end
    elseif chat_info.sender_uid == tostring(UserModel.getUserUid()) then
        bg_index = 1
    else
        bg_index = 2
    end
    local bg_info = bg_infos[bg_index]
    
    --创建一个容器先
    local box = CCNode:create()
    
    local bg = CCScale9Sprite:create(bg_info.file_name, bg_info.full_rect, bg_info.insert_rect)
    box:addChild(bg)
    bg:setAnchorPoint(ccp(0.5, 1))
    
    local direction_about = {} -- 可能会改变方向的节点的集合
    local is_battle_report = ChatUtil.isChatCellTypeBy(text, ChatUtil.BattleTabStr)
    local box_size = nil
    
    -- 如果是战报
    if (is_battle_report==true) then
        box_size = CCSizeMake(bg_info.lable_width_max + 50, 85)

        box:setContentSize(box_size)
        bg:setPreferredSize(box_size)
        bg:setPosition(ccp(box_size.width * 0.5, box_size.height))
        
        local battle_report_info = ChatUtil.parseTabContent(text, ChatUtil.BattleTabStr)
        local player_str = "【".. battle_report_info[1] .. " VS " .. battle_report_info[2] .."】"
        local player_label = CCLabelTTF:create(player_str, g_sFontName, 21)
        box:addChild(player_label)
        player_label:setAnchorPoint(ccp(0, 0))
        player_label:setColor(bg_info.text_color)
        player_label:setPosition(ccp(25, bg:getPositionY() - bg:getContentSize().height * 0.5))
        local menu = BTSensitiveMenu:create()
        box:addChild(menu)
        menu:setTouchPriority(self._touch_priority -1)
        menu:setContentSize(box_size)
        menu:setPosition(ccp(0, 0))
        
        local node_normal = CCNode:create()
        node_normal:setContentSize(box_size)
        --查看战报的回调
        local battleCb = function ( ... )
            self.battleReportCb(chat_info)
        end
        local look_report = CCMenuItemSprite:create(node_normal, nil)
        menu:addChild(look_report)
        look_report:setAnchorPoint(ccp(0, 0))
        look_report:setPosition(ccp(0, 0))
        look_report:registerScriptTapHandler(battleCb)
        --look_report:setTag(index)
        --look_report:setTag(tonumber(battle_report_info[3]))
                
        local look_report_lable = CCLabelTTF:create(GetLocalizeStringBy("key_8026"), g_sFontName, 21)
        box:addChild(look_report_lable)
        look_report_lable:setColor(bg_info.text_color)
        look_report_lable:setAnchorPoint(ccp(0.5, 0.5))
        look_report_lable:setPosition(ccp(box_size.width - 105, 30))
    elseif(ChatUtil.isChatCellTypeBy(text, ChatUtil.AudioTabStr)==true)then
        -- 如果是语音

        local temp_arr = ChatUtil.parseTabContent(text, ChatUtil.AudioTabStr)
    
        local aid = temp_arr[1]
        local aSec = tonumber(temp_arr[2])
        print(" aid, aSec:", aid, aSec)

        local b_length = (bg_info.lable_width_max + 50)/(20*1000) *aSec
        if(b_length < (bg_info.lable_width_max + 50)/(20*1000) *6000)then
            b_length = (bg_info.lable_width_max + 50)/(20*1000) *6000
        end

        if(b_length> (bg_info.lable_width_max + 10))then
            b_length = (bg_info.lable_width_max + 10)
        end

        local menu = BTSensitiveMenu:create()
        

        -- 语音文字
        local a_text = ChatCache.getAudioTextBy(aid)
        
        local b_height = 70
        local v_menu_length = 0

        if(a_text)then
            -- if(string.len(a_text)>138)then
            --     a_text = string.sub(a_text, 1, 138)
            --     a_text = a_text .. "..."
            -- end
            local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=a_text, color=ccc3(0xff,0xff,0xff), width=bg_info.lable_width_max-30})

            -- if(ccLabelDesc:getContentSize().height>70)then
            --     ccLabelDesc:setContentSize(CCSizeMake(ccLabelDesc:getContentSize().width, 70))
            -- end
            local c_contentSize = ccLabelDesc:getContentSize()
            if(b_length  < c_contentSize.width + 35)then
                b_length = c_contentSize.width + 35
            end
            
            v_menu_length = b_length
            ccLabelDesc:setAnchorPoint(ccp(0, 1))
            ccLabelDesc:setPosition(ccp(15, c_contentSize.height + 10))
            b_height = b_height + c_contentSize.height + 10

            box:addChild(ccLabelDesc)

            local lineSprite = CCSprite:create("images/chat/line.png")
            if(b_length < lineSprite:getContentSize().width)then
                local sc = (b_length/lineSprite:getContentSize().width)
                lineSprite:setScale(sc)
            end
            lineSprite:setAnchorPoint(ccp(0.5, 0))
            lineSprite:setPosition(ccp(b_length*0.5, c_contentSize.height + 20))
            box:addChild(lineSprite)
        else
            -- 文本按钮回调
            local textCb = function (p_tag,p_btn )
                self:getRecordRext(chat_info,p_btn)
            end
            -- 文本的按钮
            local text_report = CCMenuItemImage:create("images/chat/wen.png", "images/chat/wen.png")
            menu:addChild(text_report)
            text_report:setAnchorPoint(ccp(0, 0.5))
            text_report:setPosition(ccp(15, b_height*0.5))
            text_report:registerScriptTapHandler(textCb)
            text_report:setUserObject(CCString:create(aid))
            --text_report:setTag(index)
            table.insert(direction_about, text_report)
            v_menu_length = b_length - 45

            local shuxianSprite = CCSprite:create("images/chat/shuxian.png")
            shuxianSprite:setAnchorPoint(ccp(0, 0.5))
            shuxianSprite:setPosition(ccp(15+ text_report:getContentSize().width , b_height*0.5))
            box:addChild(shuxianSprite)
            table.insert(direction_about, shuxianSprite)
        end

        print("b_length==", b_length)
        box_size = CCSizeMake( b_length, b_height)
        box:setContentSize(box_size)
        bg:setContentSize(box_size)
        bg:setPosition(ccp(box_size.width * 0.5, box_size.height))

        box:addChild(menu)
        menu:setTouchPriority(self._touch_priority-1)
        menu:setContentSize(box_size)
        menu:setPosition(ccp(0, 0))

        local v_x = 0
        if(a_text)then
            v_x = 50
        end
        local v_scaleX = 1

        if(direction == ChatInfoCell.Direction.right)then
            v_x = v_menu_length - 50
            v_scaleX = -1
        end

        -- 时长
        local timeLabel = CCLabelTTF:create( math.floor(aSec/1000) .. " \" ", g_sFontName, 21)
        timeLabel:setColor(ccc3(0xff,0xff,0xff))
        timeLabel:setAnchorPoint(ccp(1, 0.5))
        timeLabel:setPosition(ccp(-15, 35))
        box:addChild(timeLabel)
        table.insert(direction_about, timeLabel)
        
        local play_item_size = CCSizeMake(v_menu_length, 70)
        local node_normal = CCNode:create()
        node_normal:setContentSize(play_item_size)
        --播放语音回调
        local recorderCb = function (p_tag,p_btn)
            self:playRecorder(p_tag,p_btn)
        end
        local look_report = CCMenuItemSprite:create(node_normal, nil)
        menu:addChild(look_report)
        look_report:setAnchorPoint(ccp(0, 1))
        look_report:setPosition(ccp(box_size.width-v_menu_length, box_size.height))
        look_report:registerScriptTapHandler(recorderCb)
        look_report:setUserObject(CCString:create(aid))

        -- 小喇叭
        self._labaSprite = CCSprite:create("images/chat/xiaokaba.png")
        self._labaSprite:setAnchorPoint(ccp(0.5, 0.5))
        self._labaSprite:setPosition(ccp(v_x, 35))
        self._labaSprite:setScaleX(v_scaleX)
        look_report:addChild(self._labaSprite, 2, ChatInfoCell.kTagLaba)

    else
        local lable = CCLabelTTF:create(text, g_sFontName, 21)
        lable:setAnchorPoint(ccp(1, 0.5))
        lable:setColor(bg_info.text_color)
        direction_about[#direction_about + 1] = lable
        local bg_height = nil
        if lable:getContentSize().width > bg_info.lable_width_max then
            -- 文字单行过长要换行, 22.5为单行lable的高度
            local lable_height = math.ceil(lable:getContentSize().width / bg_info.lable_width_max) * 22.5
            lable:setDimensions(CCSizeMake(bg_info.lable_width_max, lable_height))
            lable:setHorizontalAlignment(kCCTextAlignmentLeft)
            bg_height = lable:getContentSize().height + 40 -- 加上上下边距之和40
        else
            bg_height = bg_info.single_line_height
        end
        local bg_width = lable:getContentSize().width + 50  -- 加上左右边距之和50
        if bg_width < bg_info.bg_width_min then
            bg_width = bg_info.bg_width_min
        end

        box_size = CCSizeMake(bg_width, bg_height)
        box:setContentSize(box_size)

        bg:setPreferredSize(box_size)
        bg:setPosition(ccp(box_size.width * 0.5, box_size.height))

        box:addChild(lable)
        lable:setPosition(ccp(bg:getContentSize().width - 35, bg:getContentSize().height * 0.5))
    end
    --如果是私聊的话 对于私聊聊天框 有点击回调
    if chat_info.channel == "4" then
        local menu = BTSensitiveMenu:create()
        box:addChild(menu)
        menu:setPosition(ccp(0, 0))
        menu:setContentSize(box:getContentSize())
        menu:setTouchPriority(self._touch_priority + 1)
        local normal = CCNode:create()
        normal:setContentSize(box:getContentSize())
        local selected = CCNode:create()
        selected:setContentSize(box:getContentSize())
        --点击私聊的回调
        local PMCb = function (p_tag , p_btn )
            self.pmClickCb(chat_info,p_btn)
        end
        local menuItem = CCMenuItemSprite:create(normal, selected)
        menu:addChild(menuItem)
        --menuItem:setTag(index)
        menuItem:registerScriptTapHandler(PMCb)
    end
    -----------------------------头像模块 移到box里面了  为了翻译超长语音的时候做界面刷新的时候头像位置跟着动
    local head_id = tonumber(chat_info.headpic)
    local head = nil
    if head_id == 0 then
        local sender_gender = nil
        if chat_info.sender_gender == "1" then --男
            sender_gender = 1
        else   -- 女 “0”
            sender_gender = 2
        end
        head = HeroUtil.getHeroIconByHTID(tonumber(chat_info.sender_tmpl), chat_info.figure["1"], sender_gender)
    else
        head = HeroUtil.getHeroIconByHTID(head_id)
    end
   
    local headmenu = BTSensitiveMenu:create()
    box:addChild(headmenu)
    headmenu:setTouchPriority(self._touch_priority -1)
    headmenu:setContentSize(box_size)
    headmenu:setPosition(ccp(0, 0))

    --头像的点击回调函数
    local headCb = function ( ... )
       self.callback_head(chat_info)
    end
   
    local head_btn = CCMenuItemSprite:create(head, head)
    headmenu:addChild(head_btn)
    head_btn:registerScriptTapHandler(headCb)
    head_btn:setAnchorPoint(ccp(0, 1))
    head_btn:setPosition(box_size.width, box_size.height)
    --head_btn:setTag(index)
    local sender_info = {}
    local uid = tonumber(chat_info.sender_uid)
    local direction = nil
    if uid == UserModel.getUserUid() then
        direction = ChatInfoCell.Direction.right
    else
        direction = ChatInfoCell.Direction.left
    end
    sender_info.name =  direction == ChatInfoCell.Direction.right and UserModel.getUserName() or chat_info.sender_uname
    if chat_info.sender_gender == "1" then
        sender_info.sex = ChatInfoCell.Sex.boy
    else
        sender_info.sex = ChatInfoCell.Sex.girl
    end
    
    local name_node = CCSprite:create()
    head_btn:addChild(name_node)
    name_node:setAnchorPoint(ccp(1, 1))
    name_node:setPosition(ccp(head:getContentSize().width, -5))
    
    local name_node = CCSprite:create()
    head_btn:addChild(name_node)
    name_node:setAnchorPoint(ccp(1, 1))
    name_node:setPosition(ccp(head:getContentSize().width, -5))
    
    if direction == ChatInfoCell.Direction.left then
        name_node:setAnchorPoint(ccp(0, 1))
        name_node:setPosition(ccp(0, -5))
    end
    
    local name_node_width = 0
    local name_node_height = 30
    local status = nil
    -- 军团频道
    if chat_info.channel == "101" and chat_info.guild_status ~= nil then
        if tonumber(chat_info.guild_status) == 1 then
            status = GetLocalizeStringBy("key_3322")
        elseif tonumber(chat_info.guild_status) == 2 then
            status = GetLocalizeStringBy("key_2406")
        end
    end
    -- 如果有职位，显示职位名称
    if status ~= nil then
        local status_label = CCRenderLabel:create(status, g_sFontPangWa, 22, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
        name_node:addChild(status_label)
        status_label:setColor(ccc3(0x70,0xff,0x18))
        status_label:setAnchorPoint(ccp(0, 0.5))
        status_label:setPosition(ccp(0, name_node_height * 0.5))
        name_node_width = name_node_width + status_label:getContentSize().width
    end
    -- 名字
    local name_label = CCRenderLabel:create(sender_info.name, g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_shadow)
    name_node:addChild(name_label)
    name_label:setAnchorPoint(ccp(0, 0.5))
    name_label:setPosition(ccp(name_node_width, name_node_height * 0.5))
    if sender_info.sex == ChatInfoCell.Sex.boy then
        name_label:setColor(ccc3(0x00, 0xe4, 0xff))
    elseif sender_info.sex == ChatInfoCell.Sex.girl then
        name_label:setColor(ccc3(0xf9, 0x59, 0xff))
    end
    name_node_width = name_node_width + name_label:getContentSize().width
    name_node:setContentSize(CCSizeMake(name_node_width, name_node_height))
    if direction == ChatInfoCell.Direction.left then
        ChatInfoCell:across(head_btn, box_size.width * 0.5)
    end
    ----------------------------

    local vip = nil
    local star_right = nil
    
    if is_vip then
        vip = CCSprite:create("images/chat/vip.png")
        box:addChild(vip)
        vip:setAnchorPoint(ccp(0.5, 0))
        vip:setPosition(bg:getContentSize().width - 34, bg:getPositionY() - 10)
        
        local star_left = CCSprite:create("images/chat/star_2.png")
        bg:addChild(star_left)
        star_left:setPosition(ccp(-10, -5))
        
        star_right = CCSprite:create("images/chat/star_1.png")
        bg:addChild(star_right)
        star_right:setAnchorPoint(ccp(1, 0))
        star_right:setPosition(bg:getContentSize().width - 10, -5)
    end

    if direction == ChatInfoCell.Direction.left then
        bg:setScaleX(-1)
        if is_vip then
            ChatInfoCell:across(vip, box_size.width * 0.5)
        end
        for i = 1, #direction_about do
            local node = direction_about[i]
            ChatInfoCell:across(node, box_size.width * 0.5)
        end
    end

    return box
end

-- 获取文本
function ChatInfoCell:getRecordRext( p_chatInfo, btn )
    if(RecordUtil.isSupportRecord() == false)then
        AnimationTip.showTip(GetLocalizeStringBy("key_10165"))
        return
    end
    RecordUtil.stopPlayRecord()
    LoadingUI.addLoadingUI()
    local userObject = tolua.cast(btn:getUserObject(), "CCString")
    print("getRecordRext:getCString()==", userObject:getCString())
    RecordUtil.getSvrRecordTextById(userObject:getCString(), function ( p_status, text_arr, audio_data )

        LoadingUI.reduceLoadingUI()
        if( p_status~=0 )then
            return
        end

        print("p_status, p_text=", p_status, text_arr.asr)
        if(table.isEmpty(text_arr))then
            AnimationTip.showTip(GetLocalizeStringBy("key_10162"))
            return
        end
        if( text_arr.ret and tonumber(text_arr.ret) ~= 0 )then
            if( tonumber(text_arr.ret) == RecordUtil.EERRO_CODE_WAIT_ASR )then
                AnimationTip.showTip(GetLocalizeStringBy("key_10163"))
                return 
            else
                ChatCache.addAudioTextBy(userObject:getCString(), RecordUtil.getErrDesc(tonumber(text_arr.ret)))
            end
        elseif(text_arr.asr == nil or text_arr.asr == "" or text_arr.asr == " ")then
            ChatCache.addAudioTextBy(userObject:getCString(), GetLocalizeStringBy("key_10164"))
        else
            ChatCache.addAudioTextBy(userObject:getCString(), text_arr.asr)
        end
        --获取到容器box和cell
        local curBox = btn:getParent():getParent()
        local curCell = curBox:getParent()

        --local chat_data = ChatMainLayer.getChatInfoByIndex(tag)
        local chat_data = p_chatInfo
        local direction = nil
        local uid = tonumber(chat_data.sender_uid)
        if uid == UserModel.getUserUid() then
            direction = ChatInfoCell.Direction.right
        else
            direction = ChatInfoCell.Direction.left
        end

        local r_box = self:createBox(chat_data, direction)
        local curCellSize = curCell:getContentSize()
        local needReload = false
        if(r_box:getContentSize().height > curCell:getContentSize().height)then
            --如果翻译出来的文字很多了，curcell的高度要跟着增加
            needReload = true
            curCell:setContentSize(CCSizeMake(curCellSize.width,r_box:getContentSize().height ))
        end
        local p_x, p_y = curBox:getPosition()
        r_box:ignoreAnchorPointForPosition(false)
        -- local scaleX = curBox:getScaleX()
        r_box:setPosition(ccp(p_x, curCell:getContentSize().height-20))
        -- r_box:setScaleX(scaleX)
        r_box:setAnchorPoint(curBox:getAnchorPoint())
        curBox:removeFromParentAndCleanup(true)
        curCell:addChild(r_box)
        --刷新一下，防止翻译太长被挡住 
        if(needReload)then         
            ChatMainLayer.refreshChatForPosition()
        end
    end)
    
end

-- 播放录音
function ChatInfoCell:playRecorder(tag, btn )

    if( Platform.getOS() == "android")then
        if(string.checkScriptVersion(g_publish_version, "4.3.4") < 0)then
            AnimationTip.showTip(GetLocalizeStringBy("key_10147"))
            RecordUtil.showDownloadTip()
            return
        end
    end

    if(RecordUtil.isSupportRecord() == false)then
        AnimationTip.showTip(GetLocalizeStringBy("key_10165"))
        RecordUtil.showDownloadTip()
        return
    end
    AudioUtil.stopBgm()
    print("AudioUtil.stopBgm()")
    RecordUtil.stopPlayRecord()
    print("RecordUtil.stopPlayRecord()")
    local userObject = tolua.cast(btn:getUserObject(), "CCString")
    local playEndCb= function ( ... )
        self:overPlayRecorder()
    end
    RecordUtil.playRecordBy(userObject:getCString(),playEndCb)
    print("userObject:getCString()==", userObject:getCString())
    self:showLabaEffectBy(btn)   
end

-- 播放结束
function ChatInfoCell:overPlayRecorder(flag)
    flag = tonumber(flag)
    if(ChatCache.isInChatUI() == true)then
        self:stopLabaEffect()
    end

    if(flag and flag ~= 0)then
        AnimationTip.showTip(RecordUtil.getErrDesc(flag))
    end

    if(ChatControler.isRecording() == false)then
        AudioUtil.playBgm()
    end
end

-- 播放声音特效
function ChatInfoCell:showLabaEffectBy( p_btn )
    self._labaSprite:setVisible(false)

    local p_x, p_y = self._labaSprite:getPosition()
    local p_scaleX = self._labaSprite:getScaleX()
    self.labaEffect = XMLSprite:create("images/base/effect/chat/bofang/bofang")    
    self.labaEffect:setPosition(ccp(p_x, p_y))
    self.labaEffect:setAnchorPoint(ccp(0.5, 0.5))
    self.labaEffect:setScaleX(p_scaleX)
    p_btn:addChild( self.labaEffect)
end

-- 停止声音特效
function ChatInfoCell:stopLabaEffect()
    if(tolua.isnull(self))then
        return
    end

    if(self._labaSprite)then
        self._labaSprite:setVisible(true)
    end
    if(self.labaEffect ~= nil)then
         self.labaEffect:removeFromParentAndCleanup(true)
         self.labaEffect = nil
    end
end
--得到chatInfoTyoe
function ChatInfoCell:getChatInfoCellType()
    return ChatInfoCell._chatInfoCellType
end

function lookReportEnd()
    --[[
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer", MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
    ChatMainLayer.showChatLayer()
    --]]
end

