
local DailyPvpInviteCell= require("app.scenes.dailypvp.DailyPvpInviteCell")

local DailyPvpInviteLayer = class("DailyPvpInviteLayer", UFCCSModelLayer)
-- require("app.cfg.role_info")

function DailyPvpInviteLayer.create(...)
    return DailyPvpInviteLayer.new("ui_layout/dailypvp_InviteLayer.json",Colors.modelColor, ...)
end

function DailyPvpInviteLayer:ctor(...)

    self.super.ctor(self, ...)
    self:showAtCenter(true)

    self._listview = nil
    self._friends = {}
    self:initListView()
    self:getLabelByName("Label_tips"):setVisible(false)

    self:registerBtnClickEvent("Button_close", function(widget) 
        self:animationToClose()
        end)
    
end

function DailyPvpInviteLayer:initListView()
    local listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    listView:setCreateCellHandler(function ( list, index)
        return DailyPvpInviteCell.new(list, index)
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
        if  index < #self._friends then
           cell:updateData(self._friends[index+1]) 
        end
    end)
    listView:initChildWithDataLength( 0)
    self._listview = listView
end

function DailyPvpInviteLayer:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_LIST, self._onFriendListRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITE, self._onInviteRsp, self)
     
    self:closeAtReturn(true)
    G_HandlersManager.friendHandler:sendFriendList()

    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
end

function DailyPvpInviteLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
end

function DailyPvpInviteLayer:_onFriendListRsp()
    self._friends = G_Me.dailyPvpData:getOnlineFriends()
    self._listview:reloadWithLength(#self._friends)
    self:getLabelByName("Label_tips"):setVisible(#self._friends==0)
end

function DailyPvpInviteLayer:_onInviteRsp()
    self._friends = G_Me.dailyPvpData:getOnlineFriends()
    self._listview:refreshAllCell()
end

function DailyPvpInviteLayer:_refreshTimeLeft()
    self._listview:refreshAllCell()
end

return DailyPvpInviteLayer

