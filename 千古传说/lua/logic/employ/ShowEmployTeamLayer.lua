--[[
******放置单个佣兵*******

]]


local ShowEmployTeamLayer = class("ShowEmployTeamLayer", BaseLayer)

local columnNumber = 4
function ShowEmployTeamLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.YongbingCell2")
end

function ShowEmployTeamLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.tab = {}
    self.normalTextures = {"ui_new/yongbing/tab_quanbu.png","ui_new/yongbing/tab_hydw.png","ui_new/yongbing/tab_bpdw.png"}
    self.selectedTextures = {"ui_new/yongbing/tab_quanbuh.png","ui_new/yongbing/tab_hydwh.png","ui_new/yongbing/tab_bpdwh.png"}

    self.tab[1] = TFDirector:getChildByPath(ui, 'btn_quanbu')
    self.tab[2] = TFDirector:getChildByPath(ui, 'btn_haoyou')
    self.tab[3] = TFDirector:getChildByPath(ui, 'btn_bangpai')


    self.panel_content= TFDirector:getChildByPath(ui, 'panel_Account')

    self.relationType = 0

    self.panel_cell1= TFDirector:getChildByPath(ui, 'panel_cell1')
    self.panel_cell1:setVisible(false)

end


function ShowEmployTeamLayer:removeUI()
    self.super.removeUI(self)
end

function ShowEmployTeamLayer:registerEvents()
    self.super.registerEvents(self)

    for i=1,3 do
        self.tab[i].logic = self
        self.tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relationTypeClick))
        self.tab[i]:setTag(i)
    end

    self.AllEmployTeamMessageCallBack = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(EmployManager.AllEmployTeamMessage, self.AllEmployTeamMessageCallBack)
end

function ShowEmployTeamLayer:removeEvents()

    TFDirector:removeMEGlobalListener(EmployManager.AllEmployTeamMessage, self.AllEmployTeamMessageCallBack)
    self.AllEmployTeamMessageCallBack = nil

    self.super.removeEvents(self)
end

function ShowEmployTeamLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function ShowEmployTeamLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function ShowEmployTeamLayer:refreshUI()
    self.teamList = self.teamList or TFArray:new()
    self.teamList:clear()
    for v in EmployManager.employTeamList:iterator() do
        if self:isRelation(v)  then
            self.teamList:pushBack(v)
        end
    end

    for i=1,3 do
        if i == self.relationType + 1 then
            self.tab[i]:setTextureNormal(self.selectedTextures[i])
        else
            self.tab[i]:setTextureNormal(self.normalTextures[i])
        end
    end

    self:initTableView()
end

function ShowEmployTeamLayer:isRelation( teamInfo )
    if self.relationType == 0 then
        return true
    end
    local flag = bit_and(teamInfo.relation,2^(self.relationType-1))
    if flag == 0 then
        return false
    end
    return true
end

function ShowEmployTeamLayer:initTableView()
    if self.tableView == nil then
        self:creatTableView()
    end
    self.tableView:reloadData()
end


function ShowEmployTeamLayer:creatTableView()
    local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_content:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_content:getPosition())
    self.tableView = tableView

    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ShowEmployTeamLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ShowEmployTeamLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ShowEmployTeamLayer.numberOfCellsInTableView)


    self.panel_content:getParent():addChild(self.tableView,1)
end


function ShowEmployTeamLayer.cellSizeForTable(table,cell)
    return 160,740
end
function ShowEmployTeamLayer.numberOfCellsInTableView(table,cell)
    local self = table.logic
    if self.teamList == nil then
        return 0
    end
    return self.teamList:length()
end

function ShowEmployTeamLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1


        local panel = self.panel_cell1:clone()
        panel:setVisible(true)
        panel:setPosition(ccp(20 ,0))
        cell:addChild(panel)
        cell.panel = panel
    end
    self:cellInfoSet(cell.panel ,idx+1)
    return cell
end


function ShowEmployTeamLayer:cellInfoSet( panel, idx )
    local bg_full = TFDirector:getChildByPath(panel, "bg_full")

    local teamItem = self.teamList:objectAt(idx);
    if  teamItem == nil then
        bg_full:setVisible(false)
        return
    end
    bg_full:setVisible(true)

    local txt_name = TFDirector:getChildByPath(panel, 'txt_name')
    txt_name:setText(stringUtils.format(localizable.ShowEmTeamLayer_team,teamItem.playerName)) 

    local txt_power = TFDirector:getChildByPath(panel, 'txt_power')
    txt_power:setText(teamItem.power)

    local  battleRoleNum = 0
    if teamItem.battleRole ~= nil then
        battleRoleNum = #teamItem.battleRole
    end
    for i=1,5 do
        local img_di = TFDirector:getChildByPath(panel, 'img_di'..i)
        local panel_info = TFDirector:getChildByPath(img_di, 'panel_info')
        if i > battleRoleNum then
            panel_info:setVisible(false)
        else
            panel_info:setVisible(true)
            self:setRoleIcon(panel_info,teamItem.battleRole[i])
        end
    end
end
function ShowEmployTeamLayer:setRoleIcon( panel , roleItem )
    local roleInfo = RoleData:objectByID(roleItem.roleId)
    if roleInfo == nil then
        print("角色找不到===>  id = ",roleItem.roleId)
        return
    end

    local img_quality = TFDirector:getChildByPath(panel, 'img_quality')
    local img_icon = TFDirector:getChildByPath(img_quality, 'img_icon')
    local img_martialLevel = TFDirector:getChildByPath(img_quality, 'img_martialLevel')
    local img_zhiye = TFDirector:getChildByPath(img_quality, 'img_zhiye')

    img_quality:setTexture(GetColorIconByQuality(roleItem.quality));
    img_icon:setTexture(roleInfo:getIconPath());
    img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png");
    img_martialLevel:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))

    local txt_level = TFDirector:getChildByPath(panel, 'txt_lv');
    txt_level:setText(roleItem.level);
end

function ShowEmployTeamLayer.relationTypeClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    if index == self.relationType + 1 then
        return
    end
    self.relationType = index - 1
    
    self:refreshUI()
end

return ShowEmployTeamLayer
