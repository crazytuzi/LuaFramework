local DailyPvpReplayLayer = class("DailyPvpReplayLayer",UFCCSModelLayer)


function DailyPvpReplayLayer.create()
   return DailyPvpReplayLayer.new("ui_layout/dailypvp_ReplayLayer.json", require("app.setting.Colors").modelColor)
end

function DailyPvpReplayLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self._listView = nil

    self:_initViews()

    self._replays = {}
    
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
end

function DailyPvpReplayLayer:onLayerEnter( ... )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self:closeAtReturn(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPHISTORYBATTLEREPORT, self.updateList, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPHISTORYBATTLEREPORTEND, self.updateList, self) 

    if G_Me.dailyPvpData:needGetReplays() then
        G_HandlersManager.dailyPvpHandler:sendTeamPVPHistoryBattleReport()
    end
end

function DailyPvpReplayLayer:onLayerExit( ... )
    
end


function DailyPvpReplayLayer:_initViews()    
    self._replays = G_Me.dailyPvpData:getReplays()
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.dailypvp.DailyPvpReplayCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
           cell:updateData(self._replays[index+1]) 
    end)
    self._listView:initChildWithDataLength( #self._replays)

end

function DailyPvpReplayLayer:updateList()   
    self._replays = G_Me.dailyPvpData:getReplays()
    self._listView:reloadWithLength( #self._replays)
end

return DailyPvpReplayLayer
