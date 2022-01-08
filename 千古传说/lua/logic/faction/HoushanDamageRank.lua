--[[
******帮派副本-章节列表*******

	-- by quanhuan
	-- 2015/12/28
]]

local HoushanDamageRank = class("HoushanDamageRank",BaseLayer)

local normalBtn = 'ui_new/faction/houshan/tab_2.png'
local touchBtn = 'ui_new/faction/houshan/tab_2h.png'
local rankImg = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}
function HoushanDamageRank:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.HoushanDamageRank")
end

function HoushanDamageRank:initUI( ui )

	self.super.initUI(self, ui)


    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
    self.btnTable = {}
    for i=1,5 do
        self.btnTable[i] = {}
        local node = TFDirector:getChildByPath(ui, 'tab'..i)
        self.btnTable[i].btn = TFDirector:getChildByPath(ui, 'tab'..i)
        self.btnTable[i].txt = TFDirector:getChildByPath(node, 'txt_name'..i)        
    end
    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_player")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    local panelNode = TFDirector:getChildByPath(ui, 'panel_player')
    self.cellModel = TFDirector:getChildByPath(panelNode, "bg")
    self.cellModel:setVisible(false) 
    self.cellModelX =  self.cellModel:getPositionX()
    self.cellModelY =  self.cellModel:getContentSize().height/2 - 10
end


function HoushanDamageRank:removeUI()
	self.super.removeUI(self)    
end

function HoushanDamageRank:onShow()
    self.super.onShow(self)
end

function HoushanDamageRank:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    
    self.guildCheckPointRankCallBack = function (event)
        print(event.data[1])
        -- p.pp = 1
        local data = event.data[1][1]
        if data.infos == nil then
            --toastMessage('虚席以待')
            toastMessage(localizable.common_wait)
            return
        end
        self.dateTable = data.infos
        self.totleHurt = data.totleHurt or 0
        print('self.dateTable = ',self.dateTable)
        self.TabView:reloadData()

    end
    TFDirector:addMEGlobalListener(FactionManager.guildCheckPointRank, self.guildCheckPointRankCallBack)      
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    for i=1,5 do
        self.btnTable[i].btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClickHandle))
        self.btnTable[i].btn.logic = self
        self.btnTable[i].btn.idx = i
    end


    self.registerEventCallFlag = true 
end

function HoushanDamageRank:removeEvents()

    self.super.removeEvents(self)

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
 	
    for i=1,5 do
        self.btnTable[i].btn:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(FactionManager.guildCheckPointRank, self.guildCheckPointRankCallBack)
    self.guildCheckPointRankCallBack = nil

    self.registerEventCallFlag = nil  
end

function HoushanDamageRank:dispose()
	self.super.dispose(self)    
end

function HoushanDamageRank:loadData(zone_id)
    
    self.totleHurt = 0 
    self.currZoneId = zone_id
    self:choseBtnIndex(1)

    local checkPointList = GuildZoneCheckPointData:GetInfoByZoneId( self.currZoneId )
    for i=1,5 do
        if i==1 then
            --self.btnTable[i].txt:setText('总伤害')
            self.btnTable[i].txt:setText(localizable.common_all_hurt)
        else
            self.btnTable[i].txt:setText(checkPointList[i-1].name)
        end
    end    
end

function HoushanDamageRank.onBtnClickHandle(btn)
    local self = btn.logic
    local btnIndex = btn.idx   
    if self.choseBtn ~= btnIndex then
        self:choseBtnIndex(btnIndex)
    end
end

function HoushanDamageRank:choseBtnIndex( index )
    self.choseBtn = index
    for i=1,5 do
        if i==index then
            self.btnTable[i].btn:setTextureNormal(touchBtn)
            self.btnTable[i].txt:setColor(ccc3(255,255,255))
        else
            self.btnTable[i].btn:setTextureNormal(normalBtn)
            self.btnTable[i].txt:setColor(ccc3(0,0,0))
        end
    end
    self.dateTable = {}
    self.TabView:reloadData()

    local checkPointList = GuildZoneCheckPointData:GetInfoByZoneId( self.currZoneId )
    local checkId = self.choseBtn - 1
    if checkId ~= 0 then
        checkId = checkPointList[checkId].checkpoint_id
    end
    FactionManager:requestGuildCheckPointRank(self.currZoneId, checkId)
end


function HoushanDamageRank.cellSizeForTable(table,idx)
    return 120,718
end

function HoushanDamageRank.numberOfCellsInTableView(table)
    local self = table.logic
    return #self.dateTable
end

function HoushanDamageRank.tableCellAtIndex(table, idx)

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


function HoushanDamageRank:cellInfoSet(cell, panel, idx)

    if not cell.boundData then
        cell.boundData = true
        cell.headImg = TFDirector:getChildByPath(panel, 'Image_MembersCell_1')
        cell.txtLevel = TFDirector:getChildByPath(panel, 'txt_level')
        cell.txtName = TFDirector:getChildByPath(panel, 'txt_name')
        cell.txtHurt = TFDirector:getChildByPath(panel, 'txt_offlinetime')
        cell.loadBar = TFDirector:getChildByPath(panel, 'load_di')
        local Node = TFDirector:getChildByPath(panel, 'img_di')
        cell.loadPercent = TFDirector:getChildByPath(Node, 'txt_level')
        cell.img_rank = TFDirector:getChildByPath(panel, 'img_rank')
        cell.txt_rank = TFDirector:getChildByPath(panel, 'txt_rank')
        cell.frameImg = TFDirector:getChildByPath(panel, 'bg_touxiang')
        cell.loadBar:setDirection(TFLOADINGBAR_LEFT)
    end

    local dataInfo = self.dateTable[idx]

    local RoleIcon = RoleData:objectByID(dataInfo.icon)                     --pck change head icon and head icon frame
    cell.headImg:setTexture(RoleIcon:getIconPath())
    Public:addFrameImg(cell.headImg,dataInfo.headPicFrame)                 --end
    Public:addInfoListen(cell.headImg,true,3,dataInfo.playerId)

    cell.txtLevel:setText(dataInfo.level..'d')
    cell.txtName:setText(dataInfo.name)
    cell.txtHurt:setText(dataInfo.hurt)
    
    if idx <= 3 then
        cell.img_rank:setVisible(true)
        cell.img_rank:setTexture(rankImg[idx])
        cell.txt_rank:setVisible(false)
    else
        cell.img_rank:setVisible(false)
        cell.txt_rank:setVisible(true)
        cell.txt_rank:setText(idx)
    end

    local currIndex = self.choseBtn - 1
    local checkPointList = GuildZoneCheckPointData:GetInfoByZoneId( self.currZoneId )
    local percent = 0
    -- if currIndex == 0 then
    --     local total = FactionManager:getZoneTotalHp(self.currZoneId)        
    --     percent = math.floor(dataInfo.hurt*100/total)
    -- else
    --     local total = FactionManager:getCheckpointTotalHp(self.currZoneId, checkPointList[currIndex].checkpoint_id)
    --     percent = math.floor(dataInfo.hurt*100/total)
    -- end
    if self.totleHurt == 0 then
        percent = 0
    else
        -- percent = math.floor(dataInfo.hurt*100/self.totleHurt)
        percent = dataInfo.hurt*100/self.totleHurt
    end
    
    if percent > 100 then
        percent = 100
    end
    percent = string.format("%0.1f", percent)
    cell.loadBar:setPercent(percent)
    cell.loadPercent:setText(percent..'%')
end
return HoushanDamageRank