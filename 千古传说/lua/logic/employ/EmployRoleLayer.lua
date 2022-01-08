--[[
******放置单个佣兵*******

]]


local EmployRoleLayer = class("EmployRoleLayer", BaseLayer)

function EmployRoleLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.EmployRoleCell1")
end

function EmployRoleLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.tab = {}
    self.normalTextures = {}
    self.selectedTextures = {}
    for i=1,4 do
        self.tab[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
        self.normalTextures[i] = "ui_new/yongbing/tab_"..i..".png"
        self.selectedTextures[i] = "ui_new/yongbing/tab_"..i.."h.png"

    end

    self.panel_content= TFDirector:getChildByPath(ui, 'panel_Account')
    self.txt_num= TFDirector:getChildByPath(ui, 'txt_num')
    self.btn_help= TFDirector:getChildByPath(ui, 'btn_help')
    self.panel_cell1= TFDirector:getChildByPath(ui, 'panel_cell1')
    self.panel_cell1:setVisible(false)
    self.holeNum = EmployManager:getRoleHoleNum()
end

-- function EmployRoleLayer:setHomeLayer(layer)
--     self.homeLayer = layer
-- end

function EmployRoleLayer:removeUI()
    self.super.removeUI(self)
end

function EmployRoleLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpButtonClick))


    self.MyEmployInfoMessageCallBack = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(EmployManager.MyEmployInfoMessage, self.MyEmployInfoMessageCallBack)
end

function EmployRoleLayer:removeEvents()
    self.btn_help:removeMEListener(TFWIDGET_CLICK)


    TFDirector:removeMEGlobalListener(EmployManager.MyEmployInfoMessage, self.MyEmployInfoMessageCallBack)
    self.MyEmployInfoMessageCallBack = nil

    self.super.removeEvents(self)
end

function EmployRoleLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployRoleLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function EmployRoleLayer:refreshUI()
    if self.addEmployLayer then
        self.addEmployLayer:dispose()
        self.addEmployLayer:removeFromParentAndCleanup(true)
        self.addEmployLayer = nil
    end
    self:initTableView()
    local num = EmployManager.myEmployRoleList:length()
    self.txt_num:setText(num.."/"..MercenaryConfig:getEmployRoleConfigNum())
end

function EmployRoleLayer:initTableView()
    if self.tableView == nil then
        self:creatTableView()
    end
    self.tableView:reloadData()
end


function EmployRoleLayer:creatTableView()
    local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_content:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_content:getPosition())
    self.tableView = tableView

    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EmployRoleLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EmployRoleLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EmployRoleLayer.numberOfCellsInTableView)


    self.panel_content:getParent():addChild(self.tableView,1)
end


function EmployRoleLayer.cellSizeForTable(table,cell)
    return 145,740
end
function EmployRoleLayer.numberOfCellsInTableView(table,cell)
    -- print("MercenaryConfig:getEmployRoleConfigNum()",MercenaryConfig:getEmployRoleConfigNum())
    return MercenaryConfig:getEmployRoleConfigNum() 
end

function EmployRoleLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1

        local panel = self.panel_cell1:clone()
        panel:setVisible(true)
        cell:addChild(panel)
        panel:setPosition(ccp(20,0))
        panel.logic = self
        self:registerPanelEvents(panel)
        self.allPanels[newIndex] = panel
        panel:setTag(100)
    end
    local index = idx + 1
    local panel = cell:getChildByTag(100)
    if index > self.holeNum then
        self:setCellLock(panel,index)
    elseif index > EmployManager.myEmployRoleList:length() then
        self:setCellFree(panel,index)
    else
        self:setCellInfo(panel,index)
    end
    return cell
end

function EmployRoleLayer:registerPanelEvents( panel )
    local btn_jiahao = TFDirector:getChildByPath(panel, 'btn_jiahao')
    local btn_guidui = TFDirector:getChildByPath(panel, 'btn_guidui')
    local bg_lock = TFDirector:getChildByPath(panel, 'bg_lock')
    local bg_empty = TFDirector:getChildByPath(panel, 'bg_empty')

    btn_jiahao.logic = panel
    btn_guidui.logic = panel
    bg_lock.logic = panel
    bg_empty.logic = panel
    btn_jiahao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.addRoleButtonClick,play_buzhenluoxia))
    btn_guidui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.guiduiButtonClick,play_lingqu))
    bg_lock:addMEListener(TFWIDGET_CLICK, audioClickfun(self.lockButtonClick))
    bg_lock:setTouchEnabled(true)
    bg_empty:addMEListener(TFWIDGET_CLICK, audioClickfun(self.addRoleButtonClick,play_buzhenluoxia))
    bg_empty:setTouchEnabled(true)
end

function EmployRoleLayer:setCellLock(panel,idx)
    local bg_empty = TFDirector:getChildByPath(panel, 'bg_empty')
    local bg_full = TFDirector:getChildByPath(panel, 'bg_full')
    local bg_lock = TFDirector:getChildByPath(panel, 'bg_lock')
    bg_empty:setVisible(false)
    bg_full:setVisible(false)
    bg_lock:setVisible(true)
    panel.employIndex = idx
    local txt_paichu = TFDirector:getChildByPath(bg_lock, 'txt_paichu')

    local config = MercenaryConfig:getEmployRoleConfigByIndex(idx)
    if config == nil then
        return
    end
    --txt_paichu:setText("VIP"..config.vip_level.."解锁")
    txt_paichu:setText(stringUtils.format(localizable.assistFightLayer_vip_unlock,config.vip_level))
    -- local bg_empty = TFDirector:getChildByPath(panel, 'bg_empty')
end

function EmployRoleLayer:setCellFree(panel,idx)
    local bg_empty = TFDirector:getChildByPath(panel, 'bg_empty')
    local bg_full = TFDirector:getChildByPath(panel, 'bg_full')
    local bg_lock = TFDirector:getChildByPath(panel, 'bg_lock')
    bg_empty:setVisible(true)
    bg_full:setVisible(false)
    bg_lock:setVisible(false)
    local roleNum = EmployManager.myEmployRoleList:length()
    panel.employIndex =  EmployManager:getIndexMin(idx - roleNum)
end

function EmployRoleLayer:setCellInfo(panel,idx)
    local bg_empty = TFDirector:getChildByPath(panel, 'bg_empty')
    local bg_full = TFDirector:getChildByPath(panel, 'bg_full')
    local bg_lock = TFDirector:getChildByPath(panel, 'bg_lock')
    bg_empty:setVisible(false)
    bg_full:setVisible(true)
    bg_lock:setVisible(false)
    local role = EmployManager.myEmployRoleList:objectAt(idx)
    if role == nil then
        print("角色为空 ==>  idx = ",idx)
        return
    end
    panel.employIndex = role.indexId

    local roleInfo = CardRoleManager:getRoleByGmid( role.roleId )
    if roleInfo == nil then
        print("角色在列表中找不到===>  gmid = ",role.roleId)
        return
    end

    local img_quality = TFDirector:getChildByPath(panel, 'img_quality')
    local img_icon = TFDirector:getChildByPath(img_quality, 'img_icon')
    local img_martialLevel = TFDirector:getChildByPath(img_quality, 'img_martialLevel')
    local img_zhiye = TFDirector:getChildByPath(img_quality, 'img_zhiye')

    img_quality:setTexture(GetColorIconByQuality(roleInfo.quality));
    img_icon:setTexture(roleInfo:getIconPath());
    img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png");
    img_martialLevel:setTexture(GetFightRoleIconByWuXueLevel(roleInfo.martialLevel))

    local txt_level = TFDirector:getChildByPath(panel, 'txt_lv');
    txt_level:setText(roleInfo.level);

    local txt_shouru = TFDirector:getChildByPath(panel, 'txt_shouru');
    local txt_coin = TFDirector:getChildByPath(txt_shouru, 'txt_num');
    txt_coin:setText(role.coin)
    
    local txt_time = TFDirector:getChildByPath(panel, 'txt_time');
    local txt_time_show = TFDirector:getChildByPath(txt_time, 'txt_num');
    txt_time_show:setText(self:showTime(role.startTime))

    local txt_cishu = TFDirector:getChildByPath(panel, 'txt_cishu');
    local txt_cishu_show = TFDirector:getChildByPath(txt_cishu, 'txt_num');
    txt_cishu_show:setText(role.count)

end

function EmployRoleLayer:showTime( startTime )
    local temp = MainPlayer:getNowtime() - startTime
    local hour = math.floor(temp/3600)
    local min = math.floor( (temp - hour*3600)/60)
    if hour > 0 then
        --return string.format("%d小时%d分钟",hour,min)
        return stringUtils.format(localizable.common_time_1,hour,min)
    end
    --return string.format("%d分钟",min)
    return stringUtils.format(localizable.common_time_2,min)
end

function EmployRoleLayer.addRoleButtonClick(sender)
    local panel = sender.logic
    local self = panel.logic
    self:showAddEmployLayer()
end

function EmployRoleLayer:showAddEmployLayer()
    -- if self.addEmployLayer == nil then
    --     local layer  = require("lua.logic.employ.EmployRoleSelect"):new()
    --     self:addLayer(layer)
    --     layer:setZOrder(11)
    --     self.addEmployLayer = layer
    -- end
    -- local filter_list = TFArray:new()
    -- for v in EmployManager.myEmployRoleList:iterator() do
    --     local role = CardRoleManager:getRoleByGmid(v.roleId)
    --     if role then
    --         filter_list:pushBack(role)
    --     end
    -- end
    local layer = AlertManager:addLayerByFile("lua.logic.employ.EmployRoleSelect",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_0);
    layer:initDateByFilter( CardRoleManager.cardRoleList, EmployManager:getFilterList(),function (cardRole)
        -- self.addEmployLayer:dispose()
        -- self.addEmployLayer:removeFromParentAndCleanup(true)
        -- self.addEmployLayer = nil
        AlertManager:close()
        EmployManager:EmployRoleOperation(cardRole.gmId , EmployManager.AddEmployRole)
    end)
    AlertManager:show()
end

function EmployRoleLayer.guiduiButtonClick(sender)
    local panel = sender.logic
    local indexId = panel.employIndex
    local role = EmployManager:getEmployRoleByIndex( indexId )
    local tempTime = MainPlayer:getNowtime() - role.startTime
    if tempTime < 1800 then
        toastMessage(localizable.Mercenary_Mercenary_back_limit)
        -- toastMessage("最少要30分钟才能归队")
        return
    end
    EmployManager:EmployRoleOperation(role.roleId , EmployManager.RemoveEmployRole)
end

function EmployRoleLayer.lockButtonClick(sender)
    local panel = sender.logic
    local indexId = panel.employIndex
    local config = MercenaryConfig:getEmployRoleConfigByIndex(indexId)
    if config == nil then
        return
    end
    local msg =  stringUtils.format(localizable.vip_employ_not_enough,config.vip_level,indexId);
    CommonManager:showOperateSureLayer(
            function()
                PayManager:showPayLayer();
            end,
            nil,
            {
            title = localizable.common_vip_up,
            msg = msg,
            uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
            }
    )

    -- toastMessage("解锁需要VIP".. config.vip_level .."级")
end

function EmployRoleLayer.helpButtonClick(sender)
    CommonManager:showRuleLyaer('yongbingshuoming')
end

return EmployRoleLayer
