
local IllustrationOutPutLayer = class("IllustrationOutPutLayer", BaseLayer)
local CardEquipment = require('lua.gamedata.base.CardEquipment')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')
--local typeDesc = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "招募" ,"金宝箱", "银宝箱", "", "", ""}
local typeDesc = localizable.IllOutputLayer_Desc

function IllustrationOutPutLayer:ctor(param)
    self.super.ctor(self)
    print("param = ", param)
    self.id = 1
    if param == nil then
        self.output = ""
    else
        if  param.roleId then
            local role  = RoleData:objectByID(param.roleId)
            self.output = role.show_way
        elseif param.equipId then
            self.output = "1|2|3|50|100"
        elseif param.output then
            self.output = param.output
            self.id     = param.id
        end
    end
    print("output = ", self.output)
    self:init("lua.uiconfig_mango_new.handbook.HandbookOutput")

    if self.id == nil then
        self.id = 1
    end
end

function IllustrationOutPutLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn    = TFDirector:getChildByPath(ui, 'btn_close')
    self.layer_list  = TFDirector:getChildByPath(ui, 'panel_list')
    self:draw()
end

function IllustrationOutPutLayer:registerEvents(ui)
    self.super.registerEvents(self)
    
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn)
end

function IllustrationOutPutLayer:removeEvents()
    self.super.removeEvents(self)
end

function IllustrationOutPutLayer.onclikOutPut(sender)
    
end

function IllustrationOutPutLayer:draw()

    self.outputList  = string.split(self.output, "|")
    self.outputNum   = #self.outputList

    if self.outputNum > 0 then
        self:drawOutPutList()
    end

end

function IllustrationOutPutLayer:drawOutPutList()
    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, IllustrationOutPutLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, IllustrationOutPutLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, IllustrationOutPutLayer.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.layer_list:addChild(self.tableView,1)
end

function IllustrationOutPutLayer.cellSizeForTable(table, idx)
    return 40+10,420
end

function IllustrationOutPutLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        node = createUIByLuaNew("lua.uiconfig_mango_new.handbook.HandbookOutPutCell");
        node:setPosition(ccp(0, 0))
        cell:addChild(node);
        node:setTag(617)

        local touchNode  = TFDirector:getChildByPath(node, 'panel_card')
        touchNode.parent = node
        touchNode.logic  = self
        touchNode:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchMission),1)
    end

    node = cell:getChildByTag(617)
    -- node.mission = tonumber(self.outputList[idx + 1])
    local output = string.split(self.outputList[idx + 1], "_")
    node.type    = tonumber(output[1])
    node.mission = tonumber(output[2])
    self:drawNode(node)
    return cell
end

function IllustrationOutPutLayer.numberOfCellsInTableView(table)
    local self = table.logic

    return self.outputNum
end

function IllustrationOutPutLayer:drawNode(node)
    local txt_leveldesc   = TFDirector:getChildByPath(node, 'txt_leveldesc')
    local txt_levelopen   = TFDirector:getChildByPath(node, 'txt_levelopen')

    -- draw line
    local img_line   = TFDirector:getChildByPath(node, 'img_line')
    -- local size = txt_leveldesc:getContentSize()
    -- img_line:setContentSize(CCSize(size.width, 2))
    img_line:setVisible(true)

    -- 不是关卡则return
    local type = node.type

    if type == 22 then
        local missionId = node.mission

        local mission = AdventureMissionManager:getMissionById(missionId)
        if not mission then
            print("mission == nil ,missionId =" , missionId)
            return
        end
        local map = AdventureMissionManager:getMapById(mission.map_id)
        txt_leveldesc:setText(map.name .. " " .. mission.name)
        -- local difficulty = mission.difficulty
        -- node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOutClickHandle), 1)

        local size = txt_leveldesc:getContentSize()
        local scalx = size.width / (img_line:getContentSize().width)
        img_line:setScaleY(2)
        img_line:setScaleX(scalx)
        txt_levelopen:setText(localizable.IllOutputLayer_tianshu)
        txt_levelopen:setColor(ccc3(0,0,0))
        return
    end
    if  type ~= 1 then

        local desc = EnumItemOutPutType[type]
        txt_leveldesc:setText(desc)

        txt_levelopen:setVisible(false)
        local size = txt_leveldesc:getContentSize()
        local size2 = txt_leveldesc:getDimensions()

        -- print("getContentSize = ", size)
        -- print("getDimensions = ", size2)
        -- img_line:setContentSize(CCSize(30, 2))
        -- img_line:setContentSize(CCSize(size.width, 2))
        local scalx = size.width / (img_line:getContentSize().width)
        img_line:setScaleY(2)
        img_line:setScaleX(scalx)
        return
    end

    local missionId         = node.mission
    -- local open    = MissionManager:getMissionIsOpen(missionId)
    -- txt_levelopen:setVisible(not open)

    local mission = MissionManager:getMissionById(missionId);
    local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
    local curMissionlist = missionlist[mission.difficulty];
    local index = curMissionlist:indexOf(mission);
    local map = MissionManager:getMapById(mission.mapid)


    txt_leveldesc:setText( map.name .. " " .. mission.stagename)

    local size = txt_leveldesc:getContentSize()
    local scalx = size.width / (img_line:getContentSize().width)
    img_line:setScaleY(2)
    img_line:setScaleX(scalx)

    local difficulty = mission.difficulty
    if difficulty == 1 then
        --txt_levelopen:setText("(普通)")
        txt_levelopen:setText(localizable.IllOutputLayer_base)
    elseif difficulty == 2 then
        --txt_levelopen:setText("(宗师)")
        txt_levelopen:setText(localizable.IllOutputLayer_big)
    else
        txt_levelopen:setText("")
    end
    txt_levelopen:setColor(ccc3(0,0,0))
end

function IllustrationOutPutLayer.touchMission(sender)
    local self    = sender.logic
    local type    = sender.parent.type
    local mission = sender.parent.mission

    IllustrationManager:gotoProductSystem(type, mission)
    
end

return IllustrationOutPutLayer