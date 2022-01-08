--[[
******帮派动态信息*******

	-- by quanhuan
	-- 2015/10/26
	
]]

local FactinoAccount = class("FactinoAccount",BaseLayer)

function FactinoAccount:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactinoAccount")
end

function FactinoAccount:initUI( ui )

	self.super.initUI(self, ui)

	--创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_Account")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.AccountCell")
    self.cellModel:retain()

    self.cellMax = 0
 
end

function FactinoAccount:removeUI()
   	self.super.removeUI(self)
   	if self.cellModel then
	   	self.cellModel:release()
	   	self.cellModel = nil
	end
end

function FactinoAccount:onShow()
    self.super.onShow(self)
end

function FactinoAccount:registerEvents()

	if self.registerEventCallFlag then
		return
	end

	self.super.registerEvents(self)

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.refreshAccountInfoCallBack = function (event)
        self:refreshWindow()        
    end
    TFDirector:addMEGlobalListener(FactionManager.refreshAccountInfo, self.refreshAccountInfoCallBack)

    self.registerEventCallFlag = true
end

function FactinoAccount:removeEvents()

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(FactionManager.refreshAccountInfo, self.refreshAccountInfoCallBack)
    self.refreshAccountInfoCallBack = nil
    self.super.removeEvents(self)
    self.registerEventCallFlag = nil
    
end

function FactinoAccount:dispose()
    self.super.dispose(self)
end


function FactinoAccount.cellSizeForTable(table,idx)
	local self = table.logic

    return 36,735
end

function FactinoAccount.numberOfCellsInTableView(table)
	local self = table.logic
    return self.cellMax
end

function FactinoAccount.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()

	local panel = nil
	if cell == nil then
	    cell = TFTableViewCell:create()
		panel = self.cellModel:clone()
		panel:setPosition(ccp(0,0))
		cell:addChild(panel)
		panel:setTag(10086)

		panel.txt = TFDirector:getChildByPath(panel, "txt_Account")
		panel.spilt = TFDirector:getChildByPath(panel, "txt_day")
		panel.spiltL = TFDirector:getChildByPath(panel, "img_x1")
		panel.spiltR = TFDirector:getChildByPath(panel, "img_x2")
		panel.btn = TFDirector:getChildByPath(panel, 'btn_zjgd')
		panel.btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.moreButtonClick))
		panel.btn.logic = self
	else
		panel = cell:getChildByTag(10086)
	end
	idx = idx + 1
	local cellInfo = self.recordList:getObjectAt(idx)
	panel.txt:setVisible(false)
	panel.spilt:setVisible(false)
	panel.spiltL:setVisible(false)
	panel.spiltR:setVisible(false)
	panel.btn:setVisible(false)

	if cellInfo.spilt then
		panel.spiltL:setVisible(true)
		panel.spiltR:setVisible(true)
		panel.spilt:setVisible(true)
		panel.spilt:setText(cellInfo.str)
	else
		panel.txt:setVisible(true)
		panel.txt:setColor(cellInfo.color)
		panel.txt:setText(cellInfo.str)
	end

    return cell
end

function FactinoAccount:refreshWindow()
	FactionManager:requestRecordTable()
	self.recordList = nil
	self.recordList = FactionManager:getFactionRecordTable()
	FactionManager:resetLatestSpilt(self.recordList)
	self.cellMax = self.recordList:length()

	self.TabView:reloadData()
	self.TabView:setScrollToBegin()
end
function FactinoAccount:refreshWindowAndClose()
	
end

function FactinoAccount.moreButtonClick( btn )
	local self = btn.logic
end
return FactinoAccount