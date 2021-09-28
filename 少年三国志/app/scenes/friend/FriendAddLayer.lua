
local FriendAddLayer = class("FriendAddLayer", UFCCSModelLayer)

function FriendAddLayer:ctor(...)
    self.super.ctor(self, ...)

    self:adapterWithScreen()

end

function FriendAddLayer:onLayerEnter( ... )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --     local img = self:getImageViewByName("Image_23")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end

    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
end

function FriendAddLayer:onLayerLoad( )
        self.super:onLayerLoad()
        
        self._textField =  self:getTextFieldByName("TextField_friend")
        if self._textField then
            self._textField:setText("")
        end

        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD, self._onFriendAddRsp, self)
        
        self:registerBtnClickEvent("Button_ok",function(widget)
            local uname = self._textField:getStringValue()
            if string.len(uname) > 0 then
                if G_Me.userData.name ~= uname then
                    if self:_checkDulpicateAddFriend(uname) then
                        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ALEADYADDED",{name=uname}))
                        self._textField:setText("")
                    else
                        G_HandlersManager.friendHandler:sendAddFriend(uname)
                        self._textField:setText("")
                        
                    end           
                else
                    G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR1"))
                    self._textField:setText("")
                end
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR2"))
            end

        end)
        self:registerBtnClickEvent("Button_cancel",function(widget)
            self:animationToClose()
        end)
end

function FriendAddLayer:onLayerUnload( )
        self.super:onLayerUnload()
	uf_eventManager:removeListenerWithTarget(self)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REFRESH, nil, false, nil)
end

function FriendAddLayer:_onFriendAddRsp(data)
    -- dump(data)
    if data.ret == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDSUCCESS",{name=data.name}))
    -- elseif data.ret == 3 then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR3"))
    -- elseif data.ret == 9 then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR4"))
    -- elseif data.ret == 10 then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR5"))
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
    self:animationToClose()
end

function FriendAddLayer:_checkDulpicateAddFriend(uname)
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

return FriendAddLayer

