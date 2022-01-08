--[[
******帮派副本-章节列表*******

	-- by quanhuan
	-- 2015/12/28
]]

local HoushanReward = class("HoushanReward",BaseLayer)

function HoushanReward:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.HoushanReward")

end

function HoushanReward:initUI( ui )

	self.super.initUI(self, ui)


    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
    
    local imgDibgNode = TFDirector:getChildByPath(ui, 'img_dibg')
    self.txtOutPut = TFDirector:getChildByPath(imgDibgNode, 'txt3')

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_Reward")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    local panelNode = TFDirector:getChildByPath(ui, 'Panel_Reward')
    self.cellModel = TFDirector:getChildByPath(panelNode, "bg_1")
    self.cellModel:setVisible(false) 
    self.cellModelX =  self.cellModel:getPositionX()
    self.cellModelY =  self.cellModel:getContentSize().height/2 - 10
end


function HoushanReward:removeUI()
	self.super.removeUI(self)    
end

function HoushanReward:onShow()
    self.super.onShow(self)
end

function HoushanReward:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    
    self.guildDpsAwardSucessCallBack = function (event)
        self:awardDataReady()
        self.TabView:reloadData()
    end
    TFDirector:addMEGlobalListener(FactionManager.guildDpsAwardSucess, self.guildDpsAwardSucessCallBack)      
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.registerEventCallFlag = true 
end

function HoushanReward:removeEvents()

    self.super.removeEvents(self)

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)	
    

    TFDirector:removeMEGlobalListener(FactionManager.guildDpsAwardSucess, self.guildDpsAwardSucessCallBack)
    self.guildDpsAwardSucessCallBack = nil

    self.registerEventCallFlag = nil  
end

function HoushanReward:dispose()
	self.super.dispose(self)    
end

function HoushanReward:loadData(zone_id)
    
    self.currZoneId = zone_id

    self.dateTable = GuildZoneDpsAwardData:GetInfoByZoneId( zone_id )
    self.totalHurt = FactionManager:getTotalHurtByZoneId(zone_id)
    self.maxHrut = FactionManager:getMaxHurtOutPut(zone_id)

    self:awardDataReady()
    --self.txtOutPut:setText('累计输出:'..self.totalHurt..'/'..self.maxHrut)
    self.txtOutPut:setText(stringUtils.format(localizable.houshanReward_hurt,self.totalHurt,self.maxHrut))    
    self.TabView:reloadData()
end

function HoushanReward:awardDataReady()
    self.awardGetTable = FactionManager:getAwardGetList(self.currZoneId)
end

function HoushanReward.onBtnClickHandle(btn)
    local self = btn.logic
    local btnIndex = btn.idx  

    local dataInfo = self.dateTable[btnIndex]
    
    if self.totalHurt < dataInfo.hurt then
        --toastMessage('条件不满足')
        toastMessage(localizable.common_not_contidion)
        return
    end
    if self:isGetAward( dataInfo.id ) then
        --toastMessage('已经领取')
        toastMessage(localizable.common_get_award)
        return
    end

    FactionManager:requestDrawDpsAwardSucess(self.currZoneId, dataInfo.id)
end

function HoushanReward.cellSizeForTable(table,idx)
    return 110,640
end

function HoushanReward.numberOfCellsInTableView(table)
    local self = table.logic
    return #self.dateTable
end

function HoushanReward.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        local size = panel:getContentSize()
        panel:setPosition(ccp(self.cellModelX, self.cellModelY))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end
    panel:setVisible(true)
    idx = idx + 1
    self:cellInfoSet(cell, panel, idx)

    return cell
end

function HoushanReward:isGetAward( award_id )
    for k,v in pairs(self.awardGetTable) do
        if v == award_id then
            return true
        end
    end
    return false
end
function HoushanReward:cellInfoSet(cell, panel, idx)

    if not cell.boundData then
        cell.boundData = true
        
        cell.txtDesOutput = TFDirector:getChildByPath(panel, 'txt2')
        cell.txtCurrValue = TFDirector:getChildByPath(panel, 'txt3')
        cell.btn_get = TFDirector:getChildByPath(panel, 'btn_get')
        cell.panel_Icon = TFDirector:getChildByPath(panel, 'panel_Icon')
        cell.loadBar = TFDirector:getChildByPath(panel, 'load_di')        
        cell.loadBar:setDirection(TFLOADINGBAR_LEFT)

        cell.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClickHandle))
    end

    cell.btn_get.logic = self
    cell.btn_get.idx = idx
    local dataInfo = self.dateTable[idx]
    
    cell.txtDesOutput:setText(dataInfo.hurt)
    cell.txtCurrValue:setText(self.totalHurt..'/'..dataInfo.hurt)

    local percent = math.floor(self.totalHurt*100/dataInfo.hurt)
    if percent >= 100 then
        percent = 100
        cell.txtCurrValue:setText(dataInfo.hurt..'/'..dataInfo.hurt)
    end
    cell.loadBar:setPercent(percent)

    cell.btn_get:setVisible(true)
    if percent == 100 and self:isGetAward( dataInfo.id ) == false then
        cell.btn_get:setTouchEnabled(true)
        cell.btn_get:setGrayEnabled(false)
        cell.btn_get:setTextureNormal('ui_new/operatingactivities/yy_anniu1.png')
    elseif self:isGetAward( dataInfo.id ) then
        cell.btn_get:setTouchEnabled(false)
        cell.btn_get:setGrayEnabled(false)
        cell.btn_get:setTextureNormal('ui_new/operatingactivities/yy_anniu3.png')
    else
        cell.btn_get:setTouchEnabled(false)
        cell.btn_get:setGrayEnabled(true)
        cell.btn_get:setTextureNormal('ui_new/operatingactivities/yy_anniu1.png')        
    end

    cell.panel_Icon:removeAllChildren()
    local reward = dataInfo:getRewardInfo()
    local rewardInfo = BaseDataManager:getReward(reward)
    local rewardItem =  Public:createIconNumNode(rewardInfo)
    rewardItem:setPosition(ccp(0,0))
    rewardItem:setZOrder(1)
    cell.panel_Icon:addChild(rewardItem)
end

return HoushanReward