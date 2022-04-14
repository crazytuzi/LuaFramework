-- @Author: lwj
-- @Date:   2019-03-11 14:10:24
-- @Last Modified time: 2019-03-11 14:10:24
--

MapWorldPanel = MapWorldPanel or class("MapWorldPanel", BaseItem)
local MapWorldPanel = MapWorldPanel

function MapWorldPanel:ctor(parent_node, layer)
    self.abName = "map"
    self.assetName = "MapWorldPanel"
    self.layer = layer

    self.item_list = {}
    MapWorldPanel.super.Load(self)
end

function MapWorldPanel:dctor()
    self:DestroyItems()
    self.point_list = nil
end

function MapWorldPanel:LoadCallBack()
    self.nodes = {
        "scroll/Viewport/Content/map/MapWordItem", "scroll/Viewport/Content/map",
        "scroll/Viewport/Content/map/point_1",
        "scroll/Viewport/Content/map/point_2",
        "scroll/Viewport/Content/map/point_3",
        "scroll/Viewport/Content/map/point_4",
        "scroll/Viewport/Content/map/point_5",
        "scroll/Viewport/Content/map/point_6",
        "scroll/Viewport/Content/map/point_7",
        "scroll/Viewport/Content/map/point_8",
        "scroll/Viewport/Content/map/point_9",
        "scroll/Viewport/Content/map/point_10",
        "scroll/Viewport/Content/map/point_11",
        "scroll/Viewport/Content/map/point_12",
        "scroll/Viewport/Content/map/point_13",
    }
    self:GetChildren(self.nodes)
    self.item_gameObject = self.MapWordItem.gameObject
    self:AddPoints()

    self:AddEvent()
    self:InitPanel()
end

function MapWorldPanel:AddPoints()
    self.point_list = {}
    self.point_list[#self.point_list + 1] = self.point_1
    self.point_list[#self.point_list + 1] = self.point_2
    self.point_list[#self.point_list + 1] = self.point_3
    self.point_list[#self.point_list + 1] = self.point_4
    self.point_list[#self.point_list + 1] = self.point_5
    self.point_list[#self.point_list + 1] = self.point_6
    self.point_list[#self.point_list + 1] = self.point_7
    self.point_list[#self.point_list + 1] = self.point_8
    self.point_list[#self.point_list + 1] = self.point_9
    self.point_list[#self.point_list + 1] = self.point_10
    self.point_list[#self.point_list + 1] = self.point_11
    self.point_list[#self.point_list + 1] = self.point_12
    self.point_list[#self.point_list + 1] = self.point_13
end

function MapWorldPanel:AddEvent()
end

function MapWorldPanel:InitPanel()
    self:LoadWordItems()
end

function MapWorldPanel:LoadWordItems()
    self:DestroyItems()
    local interator = table.pairsByKey(Config.db_scene)
    local index = 1
    for i, v in interator do
        if v.type == 1 or v.type == 2 and v.map_isshow == 1 then
            local data = {}
            data.conData = v
            data.conData.index = index
            local item = MapWordItem(self.item_gameObject, self.point_list[index])
            item:SetData(data)
            self.item_list[#self.item_list + 1] = item
            index = index + 1
        end
    end
end

function MapWorldPanel:DestroyItems()
    if table.isempty(self.item_list) then
        return
    end
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end