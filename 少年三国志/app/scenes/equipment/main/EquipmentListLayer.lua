

local equipmentItem = require("app.scenes.equipment.cell.EquipmentListCell")

--local TreasureItem = require("app.scenes.treasureCulture.TreasureItem")
local EquipmentListLayer = class("EquipmentListLayer",UFCCSNormalLayer)
local EquipmentConst = require("app.const.EquipmentConst")
local funLevelConst = require("app.const.FunctionLevelConst")

function EquipmentListLayer.create(...)
    return EquipmentListLayer.new("ui_layout/equipment_EquipmentListLayer.json", ...)
end

function EquipmentListLayer:ctor(...)
    
    self._listView = nil
    self._cellHeight = 0
    self.super.ctor(self, ...)
end


function EquipmentListLayer:onLayerEnter()
    if self._listView ~= nil then
        local listData = self:getList()

        --由于排序之类的可能已经发生变化, 找到现在需要展示的equipment的cellIndex,然后 +self._deltaIndex 赋值给列表
        local targetCellIndex = -1
        if self._detailView ~= nil then
            local equipment = self._detailView:getEquipment()
            if equipment ~= nil then
                for i,v in ipairs (listData) do
                    if v.id == equipment.id then
                        targetCellIndex = i-1
                       
                        break
                    end
                end
            end
        end

        local startIndex = 0
        if targetCellIndex ~= -1 then
            startIndex= calculateListViewCenterIndex(self._cellHeight, self._listView:getContentSize().height, #listData, targetCellIndex)
        end

        self._listView:reloadWithLength(#listData, startIndex)

        if targetCellIndex ~= -1 then
            self._listView:showDetailWithIndex(targetCellIndex)
        end
    end


end

function EquipmentListLayer:__prepareDataForAcquireGuide__( funId, param )
    if type(param) ~= "number" then 
        return
    end

    local listData = self:getList()
    local _findDestEquip = function ( typeId )
        local ctrlName = nil
        local equipIndex = 0        
        for key, value in ipairs(listData) do 
            if equipIndex < 1 then 
                if value:getWearingKnightId() > 0 then 
                    if (param == 1) and
                        (value:getMaxStrengthLevel() > value.level) then
                        equipIndex = key
                        ctrlName = "Button_strength"
                    elseif (param == 2) and
                        G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING) and 
                        value.refining_level < value:getMaxRefineLevel() then
                        equipIndex = key
                        ctrlName = "Button_xilian"
                    end
                end
            end
        end
        
        return equipIndex, ctrlName
    end

    local equipIndex, ctrlName = _findDestEquip(param)
    if type(equipIndex) ~= "number" or type(ctrlName) ~= "string" then 
        return 
    end

    if self._listView ~= nil and equipIndex > 0 then
        self._listView:reloadWithLength(#listData, equipIndex - 2)

        self._listView:showDetailWithIndex(equipIndex - 1)
        local detailCell = self._listView:getDetailCell()
        if detailCell then
            local widget = detailCell:getWidgetByName(ctrlName)
            if widget then 
                local x, y = widget:convertToWorldSpaceXY(0, 0)
                local widgetSize = widget:getSize()
                local detailSize = detailCell:getSize()
                return CCRectMake(x - widgetSize.width/2, 
                    y - detailSize.height - widgetSize.height/2,
                     widgetSize.width, widgetSize.height)
            end
        end
    end

    return nil
end

function EquipmentListLayer:updateView()

    if self._listView == nil then
        -- init list view
        self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_listViewContainer"), LISTVIEW_DIR_VERTICAL)
        self._listView:setSpaceBorder(0, 40)
        self._listView:setCreateCellHandler(function ( list, index)
            local cell= require("app.scenes.equipment.cell.EquipmentListCell").new(list, index)
            if self._cellHeight == 0 then
                self._cellHeight = cell:getContentSize().height
            end
            cell:setDetailCallback(function(show) 
                if show then
                    self._listView:showDetailWithIndex(cell:getCellIndex())

                end
            end)
            return cell
        end)
        self._detailView = require("app.scenes.equipment.cell.EquipmentListCellDetail").create()
        self._listView:setDetailCell(self._detailView)
        self._listView:setDetailEnabled(true)
        self._listView:setDetailCellHandler(function ( list, detail, cell, index, show )
            local listData = self:getList()
            if show then
                detail:updateDetail(listData[index+1])
            end
            if cell then
                cell:onDetailShow(show)
            end
        end)
        self:registerListViewEvent("Panel_listViewContainer", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
        end)
    end

    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local listData = self:getList()
        if index < #listData then
            cell:updateData(listData[index+1], index == self._listView:getDetailCellIndex())
        end
        
    end)
    
    local listData = self:getList()
    self._listView:reloadWithLength(#listData, 0 ,0.2)

end

function EquipmentListLayer:getList()
    return G_Me.bagData:getSortedEquipmentList()
end

function EquipmentListLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return EquipmentListLayer
