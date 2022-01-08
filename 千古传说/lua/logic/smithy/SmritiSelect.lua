--region *.lua
--Date
--选择传承装备
local SmritiSelect = class("SmritiSelect",BaseLayer)

function SmritiSelect:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.smithy.SmritiSelect")
    self.selectGmId = 0 
end

function SmritiSelect:initUI( ui )
	self.super.initUI(self,ui)
    self.ui = ui
	self.btn_close =  TFDirector:getChildByPath(ui, 'btn_shousuo')
	self.panel_list = TFDirector:getChildByPath(ui, 'panel_cardregional')
end

function SmritiSelect:initTableview()
	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, SmritiSelect.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, SmritiSelect.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, SmritiSelect.numberOfCellsInTableView)
	self.panel_list:addChild(tableView)

    self.tableView:reloadData()
end

function SmritiSelect.cellSizeForTable(table,idx)
    return 165,725
end
function SmritiSelect.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    local startOffset = 15
    local columnSpace = 10
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,4 do
            local equip_panel = require('lua.logic.smithy.SmithyEquipIcon'):new()
            local size = equip_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset
            equip_panel:setPosition(ccp(x,0))
            equip_panel:setSmritiLogic(self)
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = equip_panel
        end
    end
    for i=1,4 do
        local count = self.equipList:length()
    	if (idx * 4 + i) <= self.equipList:length() then
	    	local equip = self.equipList:objectAt(idx * 4 + i)
    		cell.equip_panel[i]:setEquipGmId(equip.gmId)
    	else
    		cell.equip_panel[i]:setEquipGmId(nil)
    	end
    end
    return cell
end

function SmritiSelect.numberOfCellsInTableView(table)
	local self = table.logic
	if self.equipList and self.equipList:length() > 0 then
		local num = math.ceil(self.equipList:length()/4)
		if num < 2 then
			return 2
		else
			return num
		end
    end
    return 2
end

function SmritiSelect:setParent(parent)
	self.parent = parent
end

function SmritiSelect:setSelectId(selectGmId) 
	--self.parent:setSelectId(selectGmId)
    self.selectGmId = selectGmId
	self.onBtnClose(self.btn_close)
end

function SmritiSelect:setGmId(gmId)
    self.old_equipList = EquipmentManager:GetAllEquipInWarSideFirst(0)
    local equip = EquipmentManager:getEquipByGmid(gmId)
    self.equipList = TFArray:new()
    if gmId~= 0 then
        for v in self.old_equipList:iterator() do
            if v.equipType == equip.equipType and v.quality == equip.quality and v.quality >= 4 and equip.gmId ~= v.gmId then
                self.equipList:push(v)
            end    
        end
    else
        for v in self.old_equipList:iterator() do
            if v.quality >= 4  then
                self.equipList:push(v)
            end    
        end
    end    
     
    self:initTableview()    
end


function SmritiSelect.onBtnClose(sender)
    local self = sender.logic
    self.ui:runAnimation("Action1",1)
    self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
        self.parent:setSelectId(self.selectGmId)
        AlertManager:close()
        end)

end

function SmritiSelect:removeUI()
   	self.super.removeUI(self)  
end

function SmritiSelect:onShow()
    self.super.onShow(self)
    self.ui:runAnimation("Action0",1)
end

function SmritiSelect:registerEvents()
	self.super.registerEvents(self)
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClose))   
    self.btn_close.logic = self 

    self.ui.logic = self
    self.ui:setTouchEnabled(true)
    --self.btn_shousuo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))
    self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnClose))
end

function SmritiSelect:removeEvents()
	self.super.removeEvents(self)
end


function SmritiSelect:dispose()
    self.super.dispose(self)
end

return SmritiSelect


--endregion
