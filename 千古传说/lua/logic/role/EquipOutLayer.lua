--[[
******穿戴装备*******

    king
    -- 2015/7/9
]]

local EquipOutLayer = class("EquipOutLayer", BaseLayer)

local equipStageList = require("lua.table.t_s_equipStage")
-- 

function EquipOutLayer:ctor(data)
    self.super.ctor(self,data)

    self.isfirst = true
    self:init("lua.uiconfig_mango_new.role.EquipEmpty")

end

function EquipOutLayer:loadData(type)
    self.outputNum = 0

    local outPutList = equipStageList:objectByID(type)
    if outPutList == nil then
        return
    end

    print("outPutList = ", outPutList)
    self.equipOutList = {}

    local temptbl = string.split(outPutList.stage,'|')
    local count = 0
    for k,v in pairs(temptbl) do
        count = count + 1
        local missionid      = tonumber(v)

        self.equipOutList[count] = missionid
    end


    self.outputNum = count
end

function EquipOutLayer:onShow()
    self.super.onShow(self)
    
    self:refreshBaseUI()
    self:refreshUI()
    if self.isfirst == true then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function EquipOutLayer:refreshBaseUI()

end


function EquipOutLayer:refreshUI()

    self:refreshTable()

    
end

function EquipOutLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.panel_outnode   =  TFDirector:getChildByPath(ui, "bg_cell")
    self.panel_outnode:setVisible(false)

    self.panel_outlist      = TFDirector:getChildByPath(ui, 'panel_outlist');
    

end

function EquipOutLayer:refreshTable()

  

    local pannel_outList =  self.panel_outlist
    if self.panel_outlist == nil then
        return
    end
    
    if self.outputTableView ~= nil then
        self.outputTableView:setVisible(true)
        self.outputTableView:reloadData()
        self.outputTableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(pannel_outList:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.outputTableView = tableView
    self.outputTableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EquipOutLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EquipOutLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EquipOutLayer.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    pannel_outList:addChild(tableView,1)
end

function EquipOutLayer.cellSizeForTable(table, idx)
    return 70, 348
end

function EquipOutLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.panel_outnode:clone()

        node:setPosition(ccp(150, 30))
        cell:addChild(node)
        node:setTag(617)
    end

    node = cell:getChildByTag(617)
    -- local output = string.split(self.outputList[idx + 1], "_")

    -- local equipStage = equipStageList:getObjectAt(idx+1)

    node.type    = 1
    node.mission = self.equipOutList[idx+1] --tonumber(output[2])
    node.logic   = self
    self:drawOutNode(node)

    node:setVisible(true)

    return cell
end

function EquipOutLayer.numberOfCellsInTableView(table)
    local self = table.logic
 
    return self.outputNum
end

function EquipOutLayer:drawOutNode(node)
    
    local txt_leveldesc  = TFDirector:getChildByPath(node, "txt_leveldesc")
    local txt_levelopen  = TFDirector:getChildByPath(node, "txt_levelopen")

   print("node.mission = ", node.mission)

    -- 不是关卡则return
    local type = node.type
    if  type ~= 1 then

        local desc = typeDesc[type]
        txt_leveldesc:setText(desc)
        txt_levelopen:setText("")
        return
    end

    local missionId     = node.mission
    local open          = MissionManager:getMissionIsOpen(missionId)
    -- txt_levelopen:setVisible(not open)

    local mission = MissionManager:getMissionById(missionId);
    if mission == nil then
        print("mission == nil ,missionId =" , missionId)
        return
    end
    local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
    local curMissionlist = missionlist[mission.difficulty];
    local index = curMissionlist:indexOf(mission);
    local map = MissionManager:getMapById(mission.mapid)

    local difficulty = mission.difficulty
    if difficulty == 1 then
        --txt_levelopen:setText("(普通)")
        txt_levelopen:setText(localizable.common_round_normal)
    elseif difficulty == 2 then
        --txt_levelopen:setText("(宗师)")
        txt_levelopen:setText(localizable.common_round_high)
    else
         txt_levelopen:setText("")
    end

    --local zhangjie = "第"..mission.mapid.."章"
    local zhangjie = stringUtils.format(localizable.common_index_chapter,mission.mapid)

    -- print("mission = ", mission)
    -- txt_leveldesc:setText( map.name .. " " .. mission.stagename)
    txt_leveldesc:setText(zhangjie .. " " .. mission.stagename)
    -- print(" mission.explain = ",  mission)

    node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOutClickHandle),1)

    if open then
        txt_leveldesc:setColor(ccc3(0,0,0))
        txt_levelopen:setColor(ccc3(0,0,0))
        node:setTexture("ui_new/rolebook/bg_cell.png")
    else
        txt_leveldesc:setColor(ccc3(141,141,141))
        txt_levelopen:setColor(ccc3(141,141,141))
        node:setTexture("ui_new/rolebook/bg_cell2.png")
    end

end


function EquipOutLayer.onOutClickHandle(sender)
    local self    = sender.logic
    local type    = sender.type
    local mission = sender.mission

    print("sender.type = ", sender.type)
    if type == 1 then
        local open    = MissionManager:getMissionIsOpen(mission)

        if open then
            MissionManager:showHomeToMissionLayer(mission)
        else
            --toastMessage("关卡尚未开启")
            toastMessage(localizable.equipOutLayer_chapter)
        end
        
    elseif type == 2 then
        if PlayerGuideManager:GetArenaOpenLevel() <= MainPlayer:getLevel() then
            MallManager:openQunHaoShopHome()
        else
            --toastMessage("群豪谱尚未开启")
            toastMessage(localizable.equipOutLayer_qunhao)
        end

    elseif type == 7 then
        -- 进入商店
        -- MallManager:openMallLayer()
        local bookid  = self.bookList[self.bookCount]
        MallManager:openMallLayer(self.id)
    end
end

function EquipOutLayer:removeEvents()
    self.super.removeEvents(self)
    self.isfirst = true
end
return EquipOutLayer
