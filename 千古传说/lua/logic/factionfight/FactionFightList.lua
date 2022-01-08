--[[
******帮派战-查看帮派排名*******

	-- by quanhuan
	-- 2016/3/4
	
]]

local FactionFightList = class("FactionFightList",BaseLayer)

local memberData = {}
function FactionFightList:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionFightList")
end

function FactionFightList:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    
    
    --创建TabView
    local tabViewUI = TFDirector:getChildByPath(ui,"panel_paiming")
    local tabView =  TFTableView:create()
    tabView:setTableViewSize(tabViewUI:getContentSize())
    tabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    tabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tabView.logic = self
    tabViewUI:addChild(tabView)
    tabView:setPosition(ccp(0,0))
    self.tabView = tabView

    self.offsetX = {}
    for i=1,3 do
        local bgNode = TFDirector:getChildByPath(ui, 'bg_'..i)
        self.offsetX[i] = bgNode:getPositionX()
        bgNode:setVisible(false)
    end
    self.cellModel = TFDirector:getChildByPath(ui, 'bg_1')
    self.cellModel:setVisible(false)
end


function FactionFightList:removeUI()
	self.super.removeUI(self)
end

function FactionFightList:onShow()
    self.super.onShow(self)
end

function FactionFightList:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    self.tabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabView.logic = self

    self.registerEventCallFlag = true 
end

function FactionFightList:removeEvents()

    self.super.removeEvents(self)

    self.tabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.registerEventCallFlag = nil
end

function FactionFightList:dispose()
	self.super.dispose(self)
end

function FactionFightList.cellSizeForTable(table,idx)
    return 60,355
end

function FactionFightList.numberOfCellsInTableView(table)

    -- return math.ceil(#memberData/2)
    return 8
end

function FactionFightList.tableCellAtIndex(table, idx)

    local self = table.logic
    
    local cell = table:dequeueCell()
    if cell == nil then
        cell = TFTableViewCell:create()
        cell.panels = {}

        local panel1 = self.cellModel:clone()
        panel1:setPosition(ccp(self.offsetX[1],0))
        cell:addChild(panel1)
        panel1:setVisible(true)        
        cell.panels[1] = panel1

        local panel2 = self.cellModel:clone()
        panel2:setPosition(ccp(self.offsetX[2],0))
        cell:addChild(panel2)
        panel2:setVisible(true)
        cell.panels[2] = panel2
    end

    local panels = cell.panels or {}

    for k,panel in pairs(panels) do

        local txt_name = TFDirector:getChildByPath(panel, 'txt_name')
        txt_name:setVisible(false)
        local txt2 = TFDirector:getChildByPath(panel, 'txt2')
        txt2:setVisible(false)
        local img_shunxu = TFDirector:getChildByPath(panel, 'img_shunxu')
        img_shunxu:setVisible(false)
        local txt_shunxu = TFDirector:getChildByPath(panel, 'txt_shunxu')
        txt_shunxu:setVisible(false)
        -- panel:setVisible(false)
        panel:setVisible(true)

        local dataIndex = idx + 1 + (k-1)*8
        local itemData = memberData[dataIndex]
        if itemData then
            -- panel:setVisible(true)
            if dataIndex < 4 then
                img_shunxu:setVisible(true)
                img_shunxu:setTexture("ui_new/leaderboard/no"..dataIndex..".png")
            else
                txt_shunxu:setVisible(true)
                txt_shunxu:setText(dataIndex)
            end
            txt_name:setVisible(true)
            txt_name:setText(itemData.guildName)
            txt2:setVisible(true)
            txt2:setText(itemData.guildBoom)
        end
    end
    return cell
end

function FactionFightList:dataReady()

    memberData = FactionFightManager:getGuildBoomList()
    
    self.tabView:reloadData()
end

return FactionFightList