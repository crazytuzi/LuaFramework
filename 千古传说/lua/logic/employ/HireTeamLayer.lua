--[[
******放置单个佣兵*******

]]


local HireTeamLayer = class("HireTeamLayer", BaseLayer)

local columnNumber = 4
function HireTeamLayer:ctor(data)
    self.super.ctor(self,data)
    self.useType = data
    self:init("lua.uiconfig_mango_new.yongbing.ChooseTeam")
end

function HireTeamLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.tab = {}
    self.normalTextures = {"ui_new/smithy/all.png","ui_new/yongbing/tab_5.png","ui_new/yongbing/tab_6.png"}
    self.selectedTextures = {"ui_new/smithy/all_pressed.png","ui_new/yongbing/tab_5h.png","ui_new/yongbing/tab_6h.png"}

    for i=1,3 do
        self.tab[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
    end


    self.panel_scroll= TFDirector:getChildByPath(ui, 'panel_scroll')
    self.panel_scroll:setVisible(false)
    self.btn_close= TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_close:setZOrder(11)
    self.relationType = 0

    self.panel_cell1= TFDirector:getChildByPath(ui, 'panel_cell1')
    self.panel_cell1:setVisible(false)
    self.img_empty= TFDirector:getChildByPath(ui, 'img_empty')
    self.img_empty:setVisible(false)
    local text = TFDirector:getChildByPath(self.img_empty, 'Txt')
    text:setText(localizable.Mercenary_Team_is_empty)
end


function HireTeamLayer:removeUI()
    self.super.removeUI(self)
end

function HireTeamLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);
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

function HireTeamLayer:removeEvents()

    TFDirector:removeMEGlobalListener(EmployManager.AllEmployTeamMessage, self.AllEmployTeamMessageCallBack)
    self.AllEmployTeamMessageCallBack = nil

    self.super.removeEvents(self)
end

function HireTeamLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function HireTeamLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end



function HireTeamLayer:sortTeamList()
    local function cmpFun(teamInfo1, teamInfo2)
        local hire_1 = self:isCanHire(teamInfo1)
        local hire_2 = self:isCanHire(teamInfo2)
        if hire_1 == false and hire_2 == true then
            return false
        end
        if hire_1 == hire_2 then
            if teamInfo1.power <= teamInfo2.power then
                return false
            end
        end
        return true
    end

    self.teamList:sort(cmpFun);
end

function HireTeamLayer:refreshUI()
    self.teamList = self.teamList or TFArray:new()
    self.teamList:clear()
    for v in EmployManager.employTeamList:iterator() do
        if self:isRelation(v)  then
            self.teamList:pushBack(v)
        end
    end

    self:sortTeamList()

    for i=1,3 do
        if i == self.relationType + 1 then
            self.tab[i]:setTextureNormal(self.selectedTextures[i])
        else
            self.tab[i]:setTextureNormal(self.normalTextures[i])
        end
    end

    self:initTableView()

    if self.teamList:length() == 0 then
        self.img_empty:setVisible(true)
    else
        self.img_empty:setVisible(false)
    end
end

function HireTeamLayer:isRelation( teamInfo )
    if self.relationType == 0 then
        return true
    end
    local flag = bit_and(teamInfo.relation,2^(self.relationType-1))
    if flag == 0 then
        return false
    end
    return true
end

function HireTeamLayer:initTableView()
    if self.tableView == nil then
        self:creatTableView()
    end
    self.tableView:reloadData()
end


function HireTeamLayer:creatTableView()
    local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_scroll:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_scroll:getPosition())
    self.tableView = tableView

    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, HireTeamLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, HireTeamLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, HireTeamLayer.numberOfCellsInTableView)

    self.panel_scroll:getParent():addChild(self.tableView,1)
    self.tableView:setZOrder(11)
end


function HireTeamLayer.cellSizeForTable(table,cell)
    return 160,740
end
function HireTeamLayer.numberOfCellsInTableView(table,cell)
    local self = table.logic
    if self.teamList == nil then
        return 0
    end
    return self.teamList:length()
end

function HireTeamLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1


        local panel = self.panel_cell1:clone()
        panel:setVisible(true)
        self:registerPanelEvents(panel)
        panel:setPosition(ccp(0 ,0))
        panel.logic = self
        cell:addChild(panel)
        cell.panel = panel
    end
    self:cellInfoSet(cell.panel ,idx+1)
    return cell
end


function HireTeamLayer:registerPanelEvents(panel)
    local btn_xiangxi = TFDirector:getChildByPath(panel, "btn_xiangxi")
    btn_xiangxi.logic = panel
    btn_xiangxi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.xiangxiInfoClick))
    local btn_guyong = TFDirector:getChildByPath(panel, "btn_guyong")
    btn_guyong.logic = panel
    btn_guyong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hireTeamClick))
end

function HireTeamLayer:cellInfoSet( panel, idx )
    local bg_full = TFDirector:getChildByPath(panel, "bg_full")

    panel.index = idx
    local teamItem = self.teamList:objectAt(idx);
    if  teamItem == nil then
        bg_full:setVisible(false)
        return
    end
    bg_full:setVisible(true)
    

    local txt_name = TFDirector:getChildByPath(panel, 'txt_name')
    -- txt_name:setText(teamItem.playerName.."的队伍")
    txt_name:setText(stringUtils.format(localizable.ShowEmTeamLayer_team, teamItem.playerName))
    

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



    local txt_tips = TFDirector:getChildByPath(panel, 'txt_tips');
    local btn_guyong = TFDirector:getChildByPath(panel, 'btn_guyong');
    local txt_price = TFDirector:getChildByPath(panel, 'txt_price');
    if self:isCanHire(teamItem) then
        txt_tips:setVisible(false)
        btn_guyong:setVisible(true)
        txt_price:setText(math.floor(teamItem.power*0.1+1000))
    else
        txt_tips:setVisible(true)
        btn_guyong:setVisible(false)
    end


end
function HireTeamLayer:setRoleIcon( panel , roleItem )
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

function HireTeamLayer.relationTypeClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    if index == self.relationType + 1 then
        return
    end
    self.relationType = index - 1
    
    self:refreshUI()
end

function HireTeamLayer.xiangxiInfoClick(sender)
    local panel = sender.logic
    local index = panel.index
    local self = panel.logic
    local teamItem = self.teamList:objectAt(index);
    if teamItem == nil then
        print("没有角色队伍信息")
        return
    end
    EmployManager:openEmployTeamInfo( teamItem )
end


function HireTeamLayer:setHireBtnClick( clickCallBack )
    self.clickCallBack = clickCallBack
end

function HireTeamLayer.hireTeamClick(sender)
    local panel = sender.logic
    local index = panel.index
    local self = panel.logic
    local teamItem = self.teamList:objectAt(index);

    EmployManager:EmployTeamSureLayer( teamItem ,self.useType,self.clickCallBack)
end

function HireTeamLayer:isCanHire( roleItem )
    if EmployManager:isTeamHasFired( roleItem.playerId ) then
        print("已经雇佣过")
        return false
    end
    if roleItem.battleRole then
        for i=1,#roleItem.battleRole do
            local battleRole = roleItem.battleRole[i]
            if EmployManager:isPlayerCanFiredByLevel( battleRole.level ) == false then
                print("等级不足")
                return false
            end
        end
    end
    return true
end

return HireTeamLayer
