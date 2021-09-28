
local WushLeaderboardLayerCell = require("app.scenes.wush.WushLeaderboardCellLayer")
local WushLeaderBoardLayer = class("WushLeaderBoardLayer", UFCCSModelLayer)

function WushLeaderBoardLayer:ctor(...)
    self.super.ctor(self, ...)
    self:showAtCenter(true)
    self._numberLabel = self:getLabelBMFontByName("LabelBMFont_SelfNumber")
    self._nameLabel = self:getLabelByName("Label_SelfName")
    -- self._dungeonLabel = self:getLabelByName("Label_SelfDungeon")
    self._floorLabel = self:getLabelByName("Label_SelfFloor")
    self._infoBg = self:getImageViewByName("ImageView_Notbang")
    self._championImg = self:getImageViewByName("ImageView_Champion")
    self._nameLabel:setVisible(false)
    self._floorLabel:setVisible(false)
    self._championImg:setVisible(false)
    self._numberLabel:setVisible(false)

    self:enableAudioEffectByName("Button_close", false)
    
    self:registerBtnClickEvent("Button_Close", function()
        self:animationToClose()
                local soundConst = require("app.const.SoundConst")
                G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    self:registerBtnClickEvent("Button_OK", function()
        self:animationToClose()
    end)
    
    

end

function WushLeaderBoardLayer:initWithWushLayer(WushLayer)
    self._WushLayer = WushLayer
end

function WushLeaderBoardLayer:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self.super:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_RANK, self._onRankRsp, self)
    
    G_HandlersManager.wushHandler:sendWushRank()
    self:closeAtReturn(true)
end

function WushLeaderBoardLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushLeaderBoardLayer:_onRankRsp(data)
    if data and data.ranking then
        self:_createListview(data.ranking)
        self:_setSelfScore(data.ranking)
    else
        self:_setSelfScore(nil)
    end
end

function WushLeaderBoardLayer:_setSelfScore(ranks)
     local rank = nil
     if ranks then
        for k,v in pairs(ranks) do
        if v.name == G_Me.userData.name then
           rank = k
           break
        end
        end
    end

    self._championImg:setVisible(false)
    self._numberLabel:setVisible(false)
    self._infoBg:setVisible(true)
    self._nameLabel:setVisible(true)
    self._floorLabel:setVisible(true)
    

    if rank ~= nil then
        self._infoBg:setVisible(false)

        if rank < 4 then 
            self._championImg:setVisible(true)
            self._championImg:loadTexture(string.format("ui/text/txt/phb_%dst.png", rank))
        else
            self._numberLabel:setVisible(true)
            self._numberLabel:setText(tostring(rank))
        end
    end
    
    
    self._nameLabel:setText(G_Me.userData.name)
    self._floorLabel:setText((G_Me.wushData:getStarHis()).."星")
end

function WushLeaderBoardLayer:_createListview(ranks)
    self._listview = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_ListviewContainer"), LISTVIEW_DIR_VERTICAL)
    self._listview:setCreateCellHandler(function ( list, index)
        return WushLeaderboardLayerCell.new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        if cell ~= nil and index < table.getn(ranks) then
            local f = ranks[index+1]
            cell:updateData(list, index, f)
        end
    end)
    
    self._listview:initChildWithDataLength(table.getn(ranks))
end

return WushLeaderBoardLayer

