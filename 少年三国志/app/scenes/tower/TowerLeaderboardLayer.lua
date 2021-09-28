
local TowerLeaderboardLayerCell = require("app.scenes.tower.TowerLeaderboardCellLayer")
local TowerLeaderBoardLayer = class("TowerLeaderBoardLayer", UFCCSModelLayer)

function TowerLeaderBoardLayer:ctor(...)
    self.super.ctor(self, ...)
    self:showAtCenter(true)
    self._numberLabel = self:getLabelBMFontByName("LabelBMFont_SelfNumber")
    self._nameLabel = self:getLabelByName("Label_SelfName")
    -- self._dungeonLabel = self:getLabelByName("Label_SelfDungeon")
    self._floorLabel = self:getLabelByName("Label_SelfFloor")
    self._infoBg = self:getImageViewByName("ImageView_Notbang")
    
    self:registerBtnClickEvent("Button_Close", function()
        self:close()
    end)
    self:registerBtnClickEvent("Button_OK", function()
        self:close()
    end)
    
end

function TowerLeaderBoardLayer:initWithTowerLayer(towerLayer)
    self._towerLayer = towerLayer
end

function TowerLeaderBoardLayer:onLayerEnter()
    self.super:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_RANK, self._onRankRsp, self)
    
    G_HandlersManager.towerHandler:sendTowerRank()
    self:closeAtReturn(true)
end

function TowerLeaderBoardLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function TowerLeaderBoardLayer:_onRankRsp(data)
    if data and data.ranking then
        self:_createListview(data.ranking)
        self:_setSelfScore(data.ranking)
    else
        self:_setSelfScore(nil)
    end
end

function TowerLeaderBoardLayer:_setSelfScore(ranks)
     local f = nil
     if ranks then
        for k,v in pairs(ranks) do
        if v.name == G_Me.userData.name then
           f = k
           break
        end
        end
    end
    if f ~= nil then
        self._numberLabel:setText(f)
    else
        self._numberLabel:setVisible(false)
        self._infoBg:setVisible(true)
    end
    
    self._nameLabel:setText(G_Me.userData.name)
    self._floorLabel:setText((self._towerLayer:getMaxFloor()).."层")
end

function TowerLeaderBoardLayer:_createListview(ranks)
    self._listview = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_ListviewContainer"), LISTVIEW_DIR_VERTICAL)
    self._listview:setCreateCellHandler(function ( list, index)
        return TowerLeaderboardLayerCell.new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        if cell ~= nil and index < table.getn(ranks) then
            local f = ranks[index+1]
            cell:updateData(list, index, f)
        end
    end)
    
    self._listview:initChildWithDataLength(table.getn(ranks))
end

return TowerLeaderBoardLayer

