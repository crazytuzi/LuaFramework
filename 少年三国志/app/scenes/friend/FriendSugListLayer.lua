
local FriendSugListCell = require("app.scenes.friend.FriendSugListCell")

local FriendSugListLayer = class("FriendSugListLayer", UFCCSModelLayer)
require("app.cfg.role_info")

local COUNT_MAX = 10

function FriendSugListLayer.create(...)
    return require("app.scenes.friend.FriendSugListLayer").new("ui_layout/friend_FriendSugListLayer.json",Colors.modelColor, ...)
end

function FriendSugListLayer:ctor(...)

    self.super.ctor(self, ...)
    self:showAtCenter(true)

    self._listview = nil
    self._friends = {}

    self._countLabel = self:getLabelByName("Label_count")
    self._countLabel:setVisible(false)
    self._countLabel:createStroke(Colors.strokeBrown, 1)
    -- self._countMax = 10
    self._count = 0

    local listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.friend.FriendSugListCell").new(list, index)
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
        if  index < #self._friends then
           cell:updateData(list, index,self._friends[index+1]) 
        end
    end)
    listView:initChildWithDataLength( 0)
    self._listview = listView
    

    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close", function(widget) 
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
        end)
    self:registerBtnClickEvent("Button_refresh", function(widget) 
        if self._count > 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_CDING"))
            return
        end
        self:_refresh()
        end)
    
    -- self:_createListView()
end

function FriendSugListLayer:_refresh()
    self._count = COUNT_MAX
    self._countLabel:setVisible(true)
    self._countLabel:setText(G_lang:get("LANG_FRIEND_CDDESC",{time=self._count}))
    self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    G_Me.friendData:sugStartCount()
    self:getButtonByName("Button_refresh"):setTouchEnabled(false)
    self:getImageViewByName("Image_7"):showAsGray(true)

    G_HandlersManager.friendHandler:sendChooseFriendList()
end

function FriendSugListLayer:_refreshTimeLeft()

    self._count = self._count - 1
    if self._count <= 0 then
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self:getButtonByName("Button_refresh"):setTouchEnabled(true)
            self:getImageViewByName("Image_7"):showAsGray(false)
            self._schedule = nil
        end
        self._countLabel:setVisible(false)
    end

    self._countLabel:setText(G_lang:get("LANG_FRIEND_CDDESC",{time=self._count}))

end

function FriendSugListLayer:onLayerEnter()
    self.super:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_CHOOSE_LIST, self._onFriendListRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD, self._onFriendAddRsp, self)
     
    self:closeAtReturn(true)

    local left = G_Me.friendData:getSugCount()
    if left > 0 then
        self._count = left
        self._countLabel:setVisible(true)
        self._countLabel:setText(G_lang:get("LANG_FRIEND_CDDESC",{time=self._count}))
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
        self:getButtonByName("Button_refresh"):setTouchEnabled(false)
        self:getImageViewByName("Image_7"):showAsGray(true)
        self:_onFriendListRsp(G_Me.friendData:getFriendSugList())
    else
        -- G_HandlersManager.friendHandler:sendChooseFriendList()
        self:_refresh()
    end
end

function FriendSugListLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end
end

--排序,在线,等级
local sortFunc = function(a,b)

    -- if a.online == 0 and b.online == 0 then
    --     return a.level > b.level
    -- end

    -- if a.online > 0 and b.online > 0 then
    --     return a.level > b.level
    -- end

    if a.online == 0 and b.online > 0 then
        return true
    end

    if a.online > 0 and b.online == 0 then
        return false
    end

    if a.online == b.online then
        return a.level > b.level
    else
        return a.online > b.online
    end

    -- if a.online > 0 and b.online > 0 then
    --     return a.level > b.level
    -- end

end

function FriendSugListLayer:_onFriendListRsp(data)
    -- dump(data)
    if data then
        if rawget(data, "friends") ~= nil then
            self._friends = data.friends
        else
            self._friends = {}
        end
        self:_refreshFriends()
        self._listview:initChildWithDataLength(#self._friends)
    else
        self._listview:initChildWithDataLength(0)
    end
end

function FriendSugListLayer:_refreshFriends()
    local preList = {}
    for k,v in pairs(self._friends) do
        local roleInfo = role_info.get(v.level)
        if roleInfo and v.name ~= G_Me.userData.name and not G_Me.friendData:isFriend(v.name) and v.friend_count < roleInfo.max_friend_num then
            table.insert(preList, #preList + 1, v)
        end
    end
    table.sort(preList, sortFunc)
    self._friends = preList
end

function FriendSugListLayer:_onFriendAddRsp(data)
    -- dump(data)
    if data.ret == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDSUCCESS",{name=data.name}))
        local tempList = {}
        for k,v in pairs(self._friends) do
            if v.name == data.name then
                table.remove(self._friends, k)
            end
        end
        self._listview:reloadWithLength(#self._friends)
        self._listview:refreshAllCell()
    elseif data.ret == 3 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR3"))
    elseif data.ret == 9 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR4"))
    elseif data.ret == 10 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDERROR5"))
    else
        -- MessageBoxEx.showCSProtoErrorMessage(data.ret)
    end
end

return FriendSugListLayer

