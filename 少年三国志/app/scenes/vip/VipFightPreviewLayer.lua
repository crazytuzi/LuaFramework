
local VipFightPreviewLayer = class("VipFightPreviewLayer", UFCCSModelLayer)

local VipFightPreviewCell = require("app.scenes.vip.VipFightPreviewCell")

require("app.cfg.dungeon_daily_info")

-- 解锁等级超过它就不显示出来了
VipFightPreviewLayer.MAX_LEVEL_SHOW = 200
VipFightPreviewLayer.MAX_LEVEL_NUM = 6

function VipFightPreviewLayer.show( dungeonInfo )   
    local chooseHardLevelLayer = VipFightPreviewLayer.new("ui_layout/vip_hardLevelChooseLayer.json", require("app.setting.Colors").modelColor)
    chooseHardLevelLayer:updateView(dungeonInfo.id)
    uf_sceneManager:getCurScene():addChild(chooseHardLevelLayer)
end

function VipFightPreviewLayer:ctor(...)
    self.super.ctor(self, ...)
    self:showAtCenter(true)

    self._listview = nil

    self:registerBtnClickEvent("Button_Close", function (  )
        self:animationToClose()
    end)

    self:_initListView()
end

function VipFightPreviewLayer:_initListView(  )
    if self._listview then return end

    self._listview = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Hard_Levels"), LISTVIEW_DIR_VERTICAL)

    self._listview:setCreateCellHandler(function ( list, index)
        return VipFightPreviewCell.new(list, index)
    end)

    self._listview:setUpdateCellHandler(function ( list, index, cell)
        if cell ~= nil and index < dungeon_daily_info.getLength() then
            local clickChallengeCallback = function (  )
                G_HandlersManager.vipHandler:sendDungeonDailyChallenge(self._dungeonId, index + 1)
            end

            cell:updateData(list, index, self._dungeonId, clickChallengeCallback)
        end
    end)
end

function VipFightPreviewLayer:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

    self:closeAtReturn(true)
end

function VipFightPreviewLayer:onLayerExit()
end

function VipFightPreviewLayer:updateView(dungeonId)

    self._dungeonId = dungeonId

    local dungeonInfo = dungeon_daily_info.get(dungeonId)

    if dungeonInfo then
        local showItemNum = 0

        for i = 1, VipFightPreviewLayer.MAX_LEVEL_NUM do
            if VipFightPreviewLayer.MAX_LEVEL_SHOW >= dungeonInfo["level_" .. i] then
                showItemNum = showItemNum + 1
            end
        end

        self._listview:initChildWithDataLength(showItemNum)
    end    
end

return VipFightPreviewLayer

