
local CheckDungeonInfo = class("CheckDungeonInfo",UFCCSNormalLayer)
require("app.cfg.dungeon_info")
require("app.cfg.dungeon_info_config")
require("app.cfg.dungeon_info_holiday")


require("app.cfg.dungeon_stage_info")

function CheckDungeonInfo.create()
    return CheckDungeonInfo.new("ui_layout/shop_ShopLayer_0.json")
end


local name01 = {
    "info",
    "holiday",
    "config",
}


function CheckDungeonInfo:ctor(json,...)
   self.super.ctor(self,...)
   self._views = {}
end


function CheckDungeonInfo:_onCheckCallback(name)
    print("name="..name)
    if name == "CheckBox_normal" then
        self:_InfoList()
    elseif name == "CheckBox_holiday" then
        self:_HolidayList()
    elseif name == "CheckBox_config" then
        self:_ConfigList()
    end
end

function CheckDungeonInfo:_InfoList()
    -- self:_infoData()
    if self._views["CheckBox_normal"] == nil then
        local panel = self:getPanelByName("Panel_normal")
        self._views["CheckBox_normal"] = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._views["CheckBox_normal"]:setCreateCellHandler(function(list,index)
            local item = require("app.scenes.shop.recharge.CheckDungeonCell").new()        
            return item
        end)
        self._views["CheckBox_normal"]:setUpdateCellHandler(function(list,index,cell)
            cell:updateCell(self._stagedata[index+1],1)
            end)
        self._views["CheckBox_normal"]:reloadWithLength(#self._stagedata,self._views["CheckBox_normal"]:getShowStart(),0.2)
    end
    self._tabs:updateTab("CheckBox_normal", self._views["CheckBox_normal"])
end

function CheckDungeonInfo:_HolidayList()
    -- self:_holidayData()
    if self._views["CheckBox_holiday"] == nil then
        local panel = self:getPanelByName("Panel_holiday")
        self._views["CheckBox_holiday"] = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._views["CheckBox_holiday"]:setCreateCellHandler(function(list,index)
            local item = require("app.scenes.shop.recharge.CheckDungeonCell").new()      
            return item
        end)
        self._views["CheckBox_holiday"]:setUpdateCellHandler(function(list,index,cell)
            cell:updateCell(self._stagedata[index+1],2)
            end)
        self._views["CheckBox_holiday"]:reloadWithLength(#self._stagedata,self._views["CheckBox_holiday"]:getShowStart(),0.2)
    end
    self._tabs:updateTab("CheckBox_holiday", self._views["CheckBox_holiday"])
end

function CheckDungeonInfo:_ConfigList()
    -- self:_configData()
    if self._views["CheckBox_config"] == nil then
        local panel = self:getPanelByName("Panel_config")
        self._views["CheckBox_config"] = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._views["CheckBox_config"]:setCreateCellHandler(function(list,index)
            local item = require("app.scenes.shop.recharge.CheckDungeonCell").new()  
            return item
        end)
        self._views["CheckBox_config"]:setUpdateCellHandler(function(list,index,cell)
            cell:updateCell(self._stagedata[index+1],3)
            end)
        self._views["CheckBox_config"]:reloadWithLength(#self._stagedata,self._views["CheckBox_config"]:getShowStart(),0.2)
    end
    self._tabs:updateTab("CheckBox_config", self._views["CheckBox_config"])
end

function CheckDungeonInfo:onLayerEnter()
    self:_initSatgeData()
    self:adapterLayer()
    self._tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)
    self._tabs:add("CheckBox_normal", self._views["CheckBox_normal"],"Label_normal")
    self._tabs:add("CheckBox_holiday", self._views["CheckBox_holiday"],"Label_holiday")
    self._tabs:add("CheckBox_config", self._views["CheckBox_config"],"Label_config")
    self._tabs:checked("CheckBox_normal")
    self:showTextWithLabel("Label_normal", name01[1])
    self:showTextWithLabel("Label_normal_0", name01[1])
    self:showTextWithLabel("Label_holiday", name01[2])
    self:showTextWithLabel("Label_holiday_0", name01[2])
    self:showTextWithLabel("Label_config", name01[3])
    self:showTextWithLabel("Label_config_0", name01[3])
end

function CheckDungeonInfo:_initSatgeData()
    if self._stagedata ~= nil and #self._stagedata > 0 then return end
    self._stagedata = {}
    local len = dungeon_stage_info.getLength()
    for i=1,len do
        local item = dungeon_stage_info.indexOf(i)

        if item.image > 0  then
            local info = dungeon_info.get(item.value)
            if info.difficulty >=2 then
                self._stagedata[#self._stagedata+1] = item
            end
        end
    end
end


-- function CheckDungeonInfo:_infoData()
--     if self._infoListData ~= nil and #self._infoListData > 0 then return end
--     self._infoListData = {}
--     local len = dungeon_info.getLength()
--     for i=1,len do
--         local item = dungeon_info.indexOf(i)
--         if item.difficulty >= 2 then
--             print("xasdasdasd")
--             self._infoListData[#self._infoListData+1] = item
--         end
--     end
-- end

-- function CheckDungeonInfo:_holidayData()
--     if self._holidayList ~= nil and #self._holidayList > 0 then return end
--     self._holidayList = {}
--     local len = dungeon_info_holiday.getLength()
--     for i=1,len do
--         local item = dungeon_info_holiday.indexOf(i)
--         if item.difficulty >= 2 then
--             self._holidayList[#self._holidayList+1] = item
--         end
--     end
-- end

-- function CheckDungeonInfo:_configData()
--     if self._configList ~= nil and #self._configList > 0 then return end
--     self._configList = {}
--     local len = dungeon_info_config.getLength()
--     for i=1,len do
--         local item = dungeon_info_config.indexOf(i)
--         if item.difficulty >= 2 then
--             self._configList[#self._configList+1] = item
--         end
--     end
-- end


function CheckDungeonInfo:adapterLayer()
    self:adapterWidgetHeight("Panel_alllistview","Panel_topbar","",0,-54)
end

return CheckDungeonInfo