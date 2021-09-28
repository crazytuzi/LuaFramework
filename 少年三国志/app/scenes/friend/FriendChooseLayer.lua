
local FriendAddCell = require("app.scenes.friend.FriendAddCell")

local FriendChooseLayer = class("FriendChooseLayer", UFCCSModelLayer)

function FriendChooseLayer:ctor(...)
    self.super.ctor(self, ...)

    --uf_notifyLayer:addNode(self)
    self:adapterWithScreen()
    
    -- self._listview = nil
    -- self._friends = {}
      
    -- self:_createListView()
end

function FriendChooseLayer:onLayerLoad( )
        self.super:onLayerLoad()
        
        self._textField =  self:getTextFieldByName("TextField_friend")
        if self._textField then 
            self._textField:setText("")
        end
        --self._textField:setText("输入玩家名字")
        -- self.label_FriendNumber = self:getLabelByName("Label_FriendNumber")
    
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_REQUEST_LIST, self._onFriendAddListRsp, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_CONFIRM, self._onFriendConfirmRsp, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD, self._onFriendAddRsp, self)
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD_NOTIFY, self._onFriendAddNotifyRsp, self)
        
        self:registerBtnClickEvent("Button_ok",function(widget)
            local uname = self._textField:getStringValue()
            if string.len(uname) > 0 then
                if G_Me.userData.name ~= uname then
                    if self:_checkDulpicateAddFriend(uname) then
                        MessageBoxEx.showOkMessage("error", uname.."已经是你的好友")
                        self._textField:setText("")
                    else
                        G_HandlersManager.friendHandler:sendAddFriend(uname)
                        self._textField:setText("")
                        self:close()
                    end           
                else
                    MessageBoxEx.showOkMessage("error", "不能加自己为好友")
                    self._textField:setText("")
                end
            else
                MessageBoxEx.showOkMessage("error", "名字不能为空")
            end
            
            --todo test
            --local decodeBuffer = {ret=1, name="sanguohero"}
            --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_ADD, nil, false, decodeBuffer)
        end)
        self:registerBtnClickEvent("Button_cancel",function(widget)
            self:close()
        end)
        self:registerBtnClickEvent("Button_Test",function(widget)
            self:onTest()
        end)
        
        --self._textField:setClickHandler(function ( )
        --    self._textField:setText("")
        --end)
        
        -- G_HandlersManager.friendHandler:sendFriendAddInfo()
end

function FriendChooseLayer:onLayerUnload( )
        self.super:onLayerUnload()
	uf_eventManager:removeListenerWithTarget(self)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REFRESH, nil, false, nil)
end

-- function FriendAddLayer:_createListView( )
--     self._listview = CCSListViewEx:createWithPanel(self:getPanelByName("ListView_Friends"), LISTVIEW_DIR_VERTICAL)
--     self._listview:setCreateCellHandler(function ( list, index)
--         return FriendAddCell.new(list, index)
--     end)
--     self._listview:setUpdateCellHandler(function ( list, index, cell)
--         if cell ~= nil and index < table.getn(self._friends) then
--             local f = self._friends[index+1]
--             cell:updateData(list, index, f)
--         end
--     end)
--     self._listview:initChildWithDataLength(0)
-- end

-- function FriendAddLayer:_onFriendAddListRsp(data)
--     local n = table.getn(data.friend)
--     self.label_FriendNumber:setText(n.."/99")
--     self._friends = data.friend
--     if self._listview then
--         self._listview:initChildWithDataLength(n)
--     end
-- end

function FriendChooseLayer:_onFriendAddRsp(data)
    dump(data)
    if data.ret == 1 then
        MessageBoxEx.showOkMessage("提示", "已发送好友邀请"..data.name)
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
end

function FriendChooseLayer:_onFriendAddNotifyRsp(data)
    --if data.friend then
    --    MessageBoxEx.showOkMessage("提示", "添加好友"..data.friend.name.."成功")
    --end
    
end

function FriendChooseLayer:_onFriendConfirmRsp(data)
    if data.ret == 1 then
        self:_removeFriendByUid(data.id)
        self._listview:initChildWithDataLength(table.getn(self._friends))
        self._listview:refreshWithStart()
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
end

function FriendChooseLayer:_removeFriendByUid(uid)
    for k,v in ipairs(self._friends) do
        if v.id == uid then
            table.remove(self._friends, k)
            break
        end
    end
end

function FriendChooseLayer:_checkDulpicateAddFriend(uname)
    local fl = G_Me.friendData:getFriendList()
    if not fl then
        return false
    end
    for k,v in pairs(fl) do
        if v.name == uname then
            return true
        end
    end
    
    return false
end

function FriendChooseLayer:onTest()
    local decodeBuffer = {}
    local _friends = {}
    for i=0,15 do
        local f = {id=i, name="testName"..i, level=i, star=i, fightingCapacity=i*10000, vip=i%2, online=i%2, getPresent=i%3+1}
        _friends[i] = f
    end
    decodeBuffer.friend = _friends
    self._friends = _friends
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REQUEST_LIST, nil, false,decodeBuffer)
end

return FriendChooseLayer

