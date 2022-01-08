--[[
******放置单个佣兵*******

]]


local ShowEmployRoleLayer = class("ShowEmployRoleLayer", BaseLayer)

local columnNumber = 4
function ShowEmployRoleLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.YongbingCell1")
end

function ShowEmployRoleLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.tab = {}
    self.normalTextures = {"ui_new/yongbing/tab_quanbu.png","ui_new/yongbing/tab_haoyou.png","ui_new/yongbing/tab_bangpai.png"}
    self.selectedTextures = {"ui_new/yongbing/tab_quanbuh.png","ui_new/yongbing/tab_haoyouh.png","ui_new/yongbing/tab_bangpaih.png"}

    self.tab[1] = TFDirector:getChildByPath(ui, 'btn_quanbu')
    self.tab[2] = TFDirector:getChildByPath(ui, 'btn_haoyou')
    self.tab[3] = TFDirector:getChildByPath(ui, 'btn_bangpai')


    self.panel_choice = TFDirector:getChildByPath(ui, 'panel_choice')

    self.panel_choice:setVisible(false)

    self.btn_choice = {}
    for i=1,4 do
        self.btn_choice[i] = TFDirector:getChildByPath(ui, 'btn_choice_'..i)
    end
    self.btn_listType = TFDirector:getChildByPath(ui, 'btn_listType')
    self.img_listType = TFDirector:getChildByPath(ui, 'img_listType')

    self.panel_content= TFDirector:getChildByPath(ui, 'panel_Account')

    self.filterType = 0
    self.relationType = 0

    self.panel_cell1= TFDirector:getChildByPath(ui, 'panel_cell1')
    self.panel_cell1:setVisible(false)


     self.normalTextureBlack = {"ui_new/yongbing/btn_quanbu1.png","ui_new/yongbing/btn_gongji1.png","ui_new/yongbing/btn_fangyu1.png","ui_new/yongbing/btn_zhiliao1.png","ui_new/yongbing/btn_kongzhi1.png"}
    self.normalTextureWhite = {"ui_new/yongbing/btn_quanbu.png","ui_new/yongbing/btn_gongji.png","ui_new/yongbing/btn_fangyu.png","ui_new/yongbing/btn_zhiliao.png","ui_new/yongbing/btn_kongzhi.png"}

end


function ShowEmployRoleLayer:removeUI()
    self.super.removeUI(self)
end

function ShowEmployRoleLayer:registerEvents()
    self.super.registerEvents(self)

    for i=1,3 do
        self.tab[i].logic = self
        self.tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relationTypeClick))
        self.tab[i]:setTag(i)
    end

    for i=1,4 do
        self.btn_choice[i].logic = self
        self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.filterTypeClick))
        self.btn_choice[i]:setTag(i)
    end


    self.panel_choice.logic = self
    self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.choiceLayerClick))


    self.btn_listType.logic = self
    self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buttonListTypeClick))

    self.AllEmployInfoMessageCallBack = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(EmployManager.AllEmployInfoMessage, self.AllEmployInfoMessageCallBack)
end

function ShowEmployRoleLayer:removeEvents()

    TFDirector:removeMEGlobalListener(EmployManager.AllEmployInfoMessage, self.AllEmployInfoMessageCallBack)
    self.AllEmployInfoMessageCallBack = nil

    self.super.removeEvents(self)
end

function ShowEmployRoleLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function ShowEmployRoleLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function ShowEmployRoleLayer:refreshUI()
    self.roleList = self.roleList or TFArray:new()
    self.roleList:clear()
    for v in EmployManager.employRoleList:iterator() do
        if self:isRelation(v) and self:isProfession(v) then
            self.roleList:pushBack(v)
        end
    end

    for i=1,3 do
        if i == self.relationType + 1 then
            self.tab[i]:setTextureNormal(self.selectedTextures[i])
        else
            self.tab[i]:setTextureNormal(self.normalTextures[i])
        end
    end

    local temp = 1
    for i=0,4 do
        if i ~= self.filterType then
            self.btn_choice[temp]:setTextureNormal(self.normalTextureWhite[i+1])
            -- self.btn_choice[temp]:setPressedTexture(self.normalTexture[i+1])
            temp = temp + 1
        else
            self.img_listType:setTexture(self.normalTextureBlack[i+1])
        end
    end

    self:initTableView()
end

function ShowEmployRoleLayer:isRelation( role )
    if self.relationType == 0 then
        return true
    end
    local flag = bit_and(role.relation,2^(self.relationType-1))
    if flag == 0 then
        return false
    end
    return true
end

function ShowEmployRoleLayer:isProfession( role )
    if self.filterType == 0 then
        return true
    end
    local roleInfo = RoleData:objectByID(role.roleId)
    if roleInfo then
        return roleInfo.outline == self.filterType
    end
    return false
end

function ShowEmployRoleLayer:initTableView()
    if self.tableView == nil then
        self:creatTableView()
    end
    self.tableView:reloadData()
end


function ShowEmployRoleLayer:creatTableView()
    local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_content:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_content:getPosition())
    self.tableView = tableView

    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ShowEmployRoleLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ShowEmployRoleLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ShowEmployRoleLayer.numberOfCellsInTableView)


    self.panel_content:getParent():addChild(self.tableView,1)
end


function ShowEmployRoleLayer.cellSizeForTable(table,cell)
    return 220,780
end
function ShowEmployRoleLayer.numberOfCellsInTableView(table,cell)
    local self = table.logic
    if self.roleList == nil then
        return 0
    end
    return math.ceil(self.roleList:length()/columnNumber)
end

function ShowEmployRoleLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1

        for i=1,columnNumber do
            local panel = self.panel_cell1:clone()
            panel:setVisible(true)
            panel:setPosition(ccp(20 + 170 * (i - 1), 0))
            panel.logic = self
            panel:addMEListener(TFWIDGET_CLICK,self.panelClickCallBack)
            cell:addChild(panel)
            panel:setTag(i)
        end
    end

    for i=1,columnNumber do
        local panel = cell:getChildByTag(i)
        self:cellInfoSet(panel, idx*columnNumber+i)
    end
    return cell
end

function ShowEmployRoleLayer.panelClickCallBack( panel )
    local roleItem = panel.logic.roleList:objectAt(panel.index);
    if roleItem then
        RankManager:requestRoleDataById( roleItem.playerId, roleItem.instanceId ,{name = roleItem.name})
    end
end
function ShowEmployRoleLayer:cellInfoSet( panel, idx )
    panel.index = idx
    local bg_full = TFDirector:getChildByPath(panel, "bg_full")
    if idx > self.roleList:length() then
        bg_full:setVisible(false)
        panel:setTouchEnabled(false)
        return
    end
    local roleItem = self.roleList:objectAt(idx);
    if  roleItem == nil then
        panel:setTouchEnabled(false)
        bg_full:setVisible(false)
        return
    end
    bg_full:setVisible(true)
    panel:setTouchEnabled(true)
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
    img_martialLevel:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martial))

    local txt_level = TFDirector:getChildByPath(panel, 'txt_lv');
    txt_level:setText(roleItem.level);

    local txt_name = TFDirector:getChildByPath(panel, 'txt_name');
    txt_name:setText(roleItem.name)
    
    local txt_role_name = TFDirector:getChildByPath(panel, 'txt_time');
    if IsPlayerRole(roleItem.roleId) then
        if roleItem.start ~= 0 then
            txt_role_name:setText(roleItem.name.."+"..roleItem.start)
        else
            txt_role_name:setText(roleItem.name)
        end
    else
        if roleItem.start ~= 0 then
            txt_role_name:setText(roleInfo.name.."+"..roleItem.start)
        else
            txt_role_name:setText(roleInfo.name)
        end
    end

    local txt_power = TFDirector:getChildByPath(panel, 'txt_power');
    txt_power:setText(roleItem.power)
end

function ShowEmployRoleLayer.relationTypeClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    if index == self.relationType + 1 then
        return
    end
    self.relationType = index - 1
    
    self:refreshUI()
end

function ShowEmployRoleLayer.choiceLayerClick(sender)
    local self = sender.logic
    self.panel_choice:setVisible(false)
end

function ShowEmployRoleLayer.filterTypeClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    local temp = 0
    for i=0,4 do
        if i ~= self.filterType then
            temp = temp + 1
        end
        if temp == index then
            self.filterType = i
            self.panel_choice:setVisible(false)
            self:refreshUI()
            return
        end
    end
end

function ShowEmployRoleLayer.buttonListTypeClick(sender)
    local self = sender.logic
    self.panel_choice:setVisible(true)
end
return ShowEmployRoleLayer
