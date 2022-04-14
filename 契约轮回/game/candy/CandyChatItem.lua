-- @Author: lwj
-- @Date:   2019-03-02 15:30:49
-- @Last Modified time: 2019-02-15 19:31:16

CandyChatItem = CandyChatItem or class("CandyChatItem", BaseChatItemSettor)
local CandyChatItem = CandyChatItem

--CandyChatItem.__cache_count=3
function CandyChatItem:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyChatItem"
    self.layer = layer
    self.is_self = true
    CandyChatItem.super.Load(self)

    --self.model = CandyChatModel.GetInstance()
end

--[[function CandyChatItem:dctor()
    -- 手动删除
    if self.lua_link_text ~= nil then
        self.lua_link_text:destroy()
    end

    CandyChatItem.super.dctor(self)
end--]]

function CandyChatItem:SetSaiZiItemSize()
    self.height = 200
    GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
end

function CandyChatItem:UpdateFrameShow(is_dont_need_change_span)
    local show_cf = FrameShowConfig.ChatFrame[self.msg_bg_id]
    if show_cf then
        --需要调整位置
        self.msg_bg_group.padding.top = show_cf.top or 0
        self.msg_bg_group.padding.bottom = show_cf.bottom or 0
        self.msg_bg_group.padding.left = show_cf.left or 0
        self.msg_bg_group.padding.right = show_cf.right or 0
        local x = show_cf.pos_x or 0
        --别人的对话
        if not self.is_self then
            local half_dis = x - self.middle_pos_x
            x = self.middle_pos_x - half_dis
        end
        local special_x = x + 43
        local y = show_cf.pos_y or 0
        SetLocalPosition(self.msgbg.transform, special_x, y, 0)
        if not is_dont_need_change_span then
            self:ResetItemSpan(show_cf.span)
        end
    end
end