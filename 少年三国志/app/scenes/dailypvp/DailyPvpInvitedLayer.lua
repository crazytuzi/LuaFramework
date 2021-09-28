
local DailyPvpInvitedCell= require("app.scenes.dailypvp.DailyPvpInvitedCell")

local DailyPvpInvitedLayer = class("DailyPvpInvitedLayer", UFCCSModelLayer)
-- require("app.cfg.role_info")

function DailyPvpInvitedLayer.create(...)
    return DailyPvpInvitedLayer.new("ui_layout/dailypvp_InvitedLayer.json",Colors.modelColor, ...)
end

function DailyPvpInvitedLayer:ctor(...)

    self.super.ctor(self, ...)
    self:showAtCenter(true)

    self._listview = nil
    self._friends = {}
    self:initListView()
    self:getLabelByName("Label_tips"):setVisible(false)
    self:getLabelByName("Label_noInvite"):createStroke(Colors.strokeBrown, 1)

    self._inviteCheck = self:getCheckBoxByName("CheckBox_noInvite")
    self:registerCheckboxEvent("CheckBox_noInvite", function( widget, type, isCheck )
        local check = G_Me.dailyPvpData:getAcceptInvite()
        G_HandlersManager.dailyPvpHandler:sendTeamPVPAcceptInvite(not check)
    end)

    self:registerBtnClickEvent("Button_close", function(widget) 
        self:animationToClose()
        end)
    
end

function DailyPvpInvitedLayer:initListView()
    local listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    listView:setCreateCellHandler(function ( list, index)
        return DailyPvpInvitedCell.new(list, index)
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
        if  index < #self._friends then
           cell:updateData(self._friends[index+1]) 
        end
    end)
    -- listView:initChildWithDataLength( #G_Me.dailyPvpData:getInvitedList())
    listView:initChildWithDataLength( 0)
    self._listview = listView
end

function DailyPvpInvitedLayer:onLayerEnter()
    self.super:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBEINVITED, self._onRefresh, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITEDJOINTEAM, self._onRefresh, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITECANCELED, self._onRefresh, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_LIST, self._onFriendListRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPACCEPTINVITE, self.updateCheckBox, self)

    G_HandlersManager.friendHandler:sendFriendList()
    self:closeAtReturn(true)

    self:updateCheckBox()
end

function DailyPvpInvitedLayer:_onFriendListRsp()
    self._friends = G_Me.dailyPvpData:getInvitedList()
    self._listview:reloadWithLength(#self._friends)
    self:getLabelByName("Label_tips"):setVisible(#self._friends==0)
end

function DailyPvpInvitedLayer:onLayerExit()

end

function DailyPvpInvitedLayer:updateCheckBox()
    local check = G_Me.dailyPvpData:getAcceptInvite()
    self._inviteCheck:setSelectedState(not check)
end

function DailyPvpInvitedLayer:_onRefresh()
    self._friends = G_Me.dailyPvpData:getInvitedList()
    self._listview:reloadWithLength(#self._friends)
    self:getLabelByName("Label_tips"):setVisible(#self._friends==0)
end

return DailyPvpInvitedLayer

