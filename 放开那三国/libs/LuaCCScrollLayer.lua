-- Filename：    LuaCCScrollLayer.lua
-- Author：      DJN
-- Date：        2015-06-19
-- Purpose：     创建可横向拖动切换的layer

-- require "script/ui/chat/ChatControler"
LuaCCScrollLayer = class("LuaCCScrollLayer",function ()
    return CCLayer:create()
end)
LuaCCScrollLayer.Direction = {                --滑动方向
    Horizon   = 1,
    Vertical  = 2
    }

function LuaCCScrollLayer:ctor( ... )
    self._midNode            = nil      -- 放在中间的node

    self._touchPriority  = nil        --触摸优先级
    self._direction      = nil        --滑动方向
    self._AnchorPoint    = nil        --内部node的锚点
    self._cellSize       = nil        --layer尺寸
    self._scaleLeft      = nil        --左node的缩放比例 
    self._scaleRight     = nil        --右node的缩放比例

    
end
--[[
    @param cell_type            消息的类型
    @param data                 数据
    @param index                索引
    @param callback_head        点击头像的回调
    @param callback_look_report 点击查看战报的回调
--]]
function ChatInfoCell:create()
  
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