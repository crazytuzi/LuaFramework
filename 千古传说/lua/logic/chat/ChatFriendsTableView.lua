--[[
    This module is developed by Eason
    2015/10/22
]]

local ChatFriendsTableView = class("ChatFriendsTableView", BaseLayer)

local localVars = {
    privateChatList = nil,
    friendList = {},
    preSelectedPlayerID = 0,
    selectedPlayerID = 0,
    cells = {},
}

function ChatFriendsTableView:ctor(data)
    print("ChatFriendsTableView:ctor(data)")

    self.super.ctor(self, data)

    -- init
    self:init("lua.uiconfig_mango_new.chat.ChatFriendsTableView")
end

function ChatFriendsTableView:initUI(ui)
    print("ChatFriendsTableView:initUI(ui)")

    self.super.initUI(self, ui)

    local tableView = TFTableView:create()
    tableView:setTableViewSize(self.ui:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView.parent = self

    self.tableView = tableView
    self:addChild(self.tableView)
end

function ChatFriendsTableView:onShow()
    print("ChatFriendsTableView:onShow()")

    self.super.onShow(self)
end

function ChatFriendsTableView:onHide()
    print("ChatFriendsTableView:onHide()")

    if localVars.selectedPlayerID > 0 then
        -- 退出聊天
        ChatManager:swapCurrentChatPlayer(0)
    end

    localVars.preSelectedPlayerID = 0
    localVars.selectedPlayerID = 0
    localVars.cells = nil
    localVars.cells = {}

    if #ChatManager:getNewMessageList() > 0 then
        ChatManager:showPrivateChatRedPoint()
    end

    self.super.onHide(self)
end

function ChatFriendsTableView:registerEvents()
    print("ChatFriendsTableView:registerEvents()")

    self.super.registerEvents(self)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX         , self.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX          , self.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)

    -- private chat list updated
    self.onPrivateChatListUpdated = function(event)
        self:refreshUI()
        self:selectCell(localVars.selectedPlayerID)
    end
    TFDirector:addMEGlobalListener(ChatManager.PrivateChatListUpdated, self.onPrivateChatListUpdated)
end

function ChatFriendsTableView:removeEvents()
    print("ChatFriendsTableView:removeEvents()")

    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(ChatManager.PrivateChatListUpdated, self.onPrivateChatListUpdated)
    self.onPrivateChatListUpdated = nil
    self.super.removeEvents(self)
end

function ChatFriendsTableView:dispose()
    print("ChatFriendsTableView:dispose()")

    self.super.dispose(self)
end

function ChatFriendsTableView:refreshUI()
    print("ChatFriendsTableView:refreshUI()")

    localVars.privateChatList = ChatManager:getPrivateChatList()
    localVars.friendList = FriendManager:getFriendInfoList() or {}

    -- 拷贝有聊天信息的好友信息到tmp中
    local tmp = {}
    for i = 1, localVars.privateChatList:length() do
        local id = localVars.privateChatList:objectAt(i)
        -- 只接受好友的信息
        if FriendManager:isInFriendList(id) then
            table.insert(tmp, FriendManager:getFriendInfoByID(id))
        end
    end

    -- 拷贝剩下的好友信息到tmp中
    for i = 1, #localVars.friendList do
        local found = false
        for j = 1, #tmp do
            if localVars.friendList[i].info.playerId == tmp[j].playerId then
                found = true
            end
        end

        if not found then
            table.insert(tmp, localVars.friendList[i].info)
        end
    end

    -- 替换原有的好友列表
    localVars.friendList = tmp

    -- 默认选择第一个好友
    if localVars.selectedPlayerID == 0 then
        if #localVars.friendList > 0 then
            localVars.selectedPlayerID = localVars.friendList[1].playerId
        end
    end

    self.tableView:reloadData()

    local newMessageList = ChatManager:getNewMessageList()
    print(newMessageList)
    for i = 1, #newMessageList do
        for _, v in pairs(localVars.cells) do
            -- 说明是新消息
            if v.friendCell:getPlayerInfo().playerId == newMessageList[i] then
                -- 不是正在聊天的好友
                if v.friendCell:getPlayerInfo().playerId ~= localVars.selectedPlayerID then
                    -- 显示小红点
                    v.friendCell:showRedPoint()
                end
            end
        end
    end
end

function ChatFriendsTableView.cellSizeForTable(table, idx)
    return 64, 148
end

function ChatFriendsTableView.tableCellAtIndex(table, idx)
    local index = idx + 1

    local cell = table:dequeueCell()
    if not cell then
        cell = TFTableViewCell:create()

        local friendCell = require("lua.logic.chat.ChatFriendListCell"):new()
        friendCell.index = index
        friendCell:setParentLayer(table.parent)

        cell.friendCell = friendCell
        cell:addChild(cell.friendCell)
    end
        localVars.cells[index] = cell


    local name = localVars.friendList[index].name
    cell.friendCell:setText(name)
    cell.friendCell:setPlayerInfo(localVars.friendList[index])

    -- 如果是选择的玩家
    if localVars.friendList[index].playerId == localVars.selectedPlayerID then
        cell.friendCell:selected()
    else
        cell.friendCell:unselected()
    end

    return cell
end

function ChatFriendsTableView.numberOfCellsInTableView(table)
    local length = #localVars.friendList
    return length
end
function ChatFriendsTableView:getFriendInfoByID( id )
    for i=1,#localVars.friendList do
        local info = localVars.friendList[i]
        if info.playerId == id then
            return info
        end
    end
    return nil
end

function ChatFriendsTableView:selectCell(selectedPlayerID)
    print("ChatFriendsTableView:selectCell(index)     ",selectedPlayerID)

    -- 没有数据
    if #localVars.cells < 1 then
        return
    end

    -- -- 获取cell的index
    -- local cellIndex = nil
    -- for i, v in ipairs(localVars.cells) do
    --     if v.friendCell:getPlayerInfo().playerId == selectedPlayerID then
    --         cellIndex = i 
    --         break
    --     end
    -- end

    -- if not cellIndex then
    --     return
    -- end

    -- -- 设置当前选择的playerID
    -- local friendInfo = localVars.friendList[cellIndex]
    -- localVars.selectedPlayerID = friendInfo.playerId
    -- if  localVars.selectedPlayerID ==  selectedPlayerID then
    -- print("localVars.selectedPlayerID == selectedPlayerID", selectedPlayerID)
    --     return
    -- end
    local friendInfo = self:getFriendInfoByID(selectedPlayerID)
    if friendInfo == nil then
    print("找不到角色信息")
        return
    end

    localVars.selectedPlayerID =  selectedPlayerID
    -- for i=1,#localVars.friendList do
    --     local info = localVars.friendList[i]
    --     if info.playerId == selectedPlayerID then
    --         friendInfo = info
    --     end
    -- end


    -- print(localVars.preSelectedPlayerID, localVars.selectedPlayerID)
    -- if localVars.preSelectedPlayerID == localVars.selectedPlayerID then
    --     return
    -- end

    for _, v in pairs(localVars.cells) do
        if v.friendCell:getPlayerInfo().playerId == selectedPlayerID then
            v.friendCell:selected()
        else
            v.friendCell:unselected()
        end
    end

    -- localVars.preSelectedPlayerID = localVars.selectedPlayerID
    
    -- 选中
    -- localVars.cells[cellIndex].friendCell:selected()
    
    ChatManager:clearFriendChat()
    
    ChatManager:setChatFriendInfo(friendInfo)
    ChatManager:swapCurrentChatPlayer(friendInfo.playerId)
    ChatManager:switchFriendMessagesByID(friendInfo.playerId)
end

return ChatFriendsTableView