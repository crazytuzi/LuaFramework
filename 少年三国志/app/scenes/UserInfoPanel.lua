--UserInfoPanel.lua


local UserInfoPanel = class ("UserInfoPanel", UFCCSModelLayer)


function UserInfoPanel:ctor( ... )
	self.super.ctor(self, ...)

	self._func = nil
	self._target = nil

	self._senderName = ""
	self._senderId = 0
        self._userInfo = {}
        
        self.closeCallbackTarget = nil
        self.closeCallbackFunc = nil
end

function UserInfoPanel:onLayerLoad( ... )
	self:registerBtnClickEvent("Button_close", function (  )
                if self.closeCallbackTarget and self.closeCallbackFunc then
                    self.closeCallbackFunc(self.closeCallbackTarget)
                end
		self:close()
	end)
	self:registerBtnClickEvent("Button_siliao", function (  )
		if self._func ~= nil and self._target ~= nil then
			self._func(self._target, 4)
		elseif self._func ~= nil then
			self._func( 4 )
		end
		self:close()
	end)
        self:registerBtnClickEvent("Button_songtili", function (  )
		self:GiveOrReceivePresent()
	end)
        self:registerBtnClickEvent("Button_addfriend", function (  )
                self:AddOrDeleteFriend()
	end)
        
        self._btnAddFriend = self:getButtonByName("Button_addfriend")
        self._btnGivePresent = self:getButtonByName("Button_songtili")
end


function UserInfoPanel:showUserInfo( senderId, senderName, func, target )
	self._func = func
	self._target = target
	self._senderName = senderName
	self._senderId = senderId
                
        local f = G_Me.friendData:getFriendByUid(self._senderId)
        
        if f then
            dump(f)
            self._btnAddFriend:setTitleText("删除好友")
            self:updatePresentStatus()
        else
            self._btnAddFriend:setTitleText("添加好友")
            self:enableWidgetByName("Button_songtili", false)
        end
        

	if G_Me.userData.name == senderName then
		 self:enableWidgetByName("Button_siliao", false)
		 self:enableWidgetByName("Button_songtili", false)
		 self:enableWidgetByName("Button_heimingdan", false)
		 self:enableWidgetByName("Button_addfriend", false)
	end
end


function UserInfoPanel:AddOrDeleteFriend()
    local f = G_Me.friendData:getFriendByUid(self._senderId)
    if f then
        MessageBoxEx.showYesNoMessage("确认", "确定与"..self._senderName.."解除好友关系?", false, 
            function() 
                    print("delete friend")
                    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_DELETE, self.onFriendDeleteRsp, self)
                    G_HandlersManager.friendHandler:sendDeleteFriend(self._senderId) end,
            function() print("cancel delete friend") end,
            self)
    else
        __Log("senderName:%s", self._senderName)
        G_HandlersManager.friendHandler:sendAddFriend(self._senderName)
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD, self.onFriendAddRsp, self)
    end		
end

function UserInfoPanel:onFriendAddRsp(data)
    if data.ret == 1 then
        MessageBoxEx.showOkMessage("提示", "已发送好友邀请")
    --else
        --MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
end

function UserInfoPanel:onFriendDeleteRsp(data)
    if data.ret == 1 then
        MessageBoxEx.showOkMessage("提示", "已与"..self._senderName.."解除好友关系")

        if self.closeCallbackTarget and self.closeCallbackFunc then
                    self.closeCallbackFunc(self.closeCallbackTarget)
        end
	self:close()
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REFRESH, nil, false, nil)
end

function UserInfoPanel:GiveOrReceivePresent()
    local f = G_Me.friendData:getFriendByUid(self._senderId)
    if f.get_present == 1 then
        G_HandlersManager.friendHandler:sendReceivePresent(self._senderId)
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_RECEIVE, self.onReceivePresentRsp, self)
    elseif f.get_present == 2 then
        G_HandlersManager.friendHandler:sendGivePresent(self._senderId)
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_GIVE, self.onGivePresentRsp, self)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REFRESH, nil, false, nil)
end

function UserInfoPanel:onGivePresentRsp(data)
    if data.ret == 1 then
        MessageBoxEx.showOkMessage("赠送成功", "赠送成功")
        self._btnGivePresent:setTitleText("已赠送")
        self:enableWidgetByName("Button_songtili", false)
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end  
end

function UserInfoPanel:onReceivePresentRsp(data)
    if data.ret == 1 then
        MessageBoxEx.showOkMessage("领取成功", "体力+5，今日还可领取"..data.get_present_times.."次")
    else
        MessageBoxEx.showOkMessage("领取失败", "今日领取次数达到上限")
    end
    self:updatePresentStatus()
end

function UserInfoPanel:updatePresentStatus()
    local f = G_Me.friendData:getFriendByUid(self._senderId)
    if f and f.get_present then
        __Log("----------------------------"..f.get_present)
        if f.get_present == 1 then
                self._btnGivePresent:setTitleText("领取体力")
        elseif f.get_present == 2 then
                self._btnGivePresent:setTitleText("赠送体力")
        elseif f.get_present == 3 then
                self._btnGivePresent:setTitleText("已赠送")
                self:enableWidgetByName("Button_songtili", false)
        end
    end
end

return UserInfoPanel