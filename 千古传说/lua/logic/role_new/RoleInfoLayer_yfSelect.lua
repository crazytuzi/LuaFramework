

local RoleInfoLayer_yfSelect = class("RoleInfoLayer_yfSelect",BaseLayer)

local columnNumber = 3

function RoleInfoLayer_yfSelect:ctor(data)

	self.super.ctor(self, data)
	self.isFirst = true
	self:init("lua.uiconfig_mango_new.role_new.RoleInfoLayer_yfdaoju")
end

function RoleInfoLayer_yfSelect:initUI( ui )

	self.super.initUI(self, ui)
	self.Panel_useitem = TFDirector:getChildByPath(ui, 'Panel_useitem')
	self.img_guodu1 = TFDirector:getChildByPath(ui, 'img_guodu1')
    self.img_guodu2 = TFDirector:getChildByPath(ui, 'img_guodu2')

    self.img_guodu1:setZOrder(10)
    self.img_guodu2:setZOrder(10)
	self.cellModel = TFDirector:getChildByPath(ui, 'btn_node')
    self.cellModel:retain()
    self.cellModel:setVisible(false)
end



function RoleInfoLayer_yfSelect:initDate( item_list, clickCallBack)
    local function simpleSort(itemInfo1,itemInfo2)
        local item1 = ItemData:objectByID(itemInfo1.id)
        local item2 = ItemData:objectByID(itemInfo2.id)
        if item1.quality > item2.quality then
            return false
        elseif item1.quality == item2.quality and item1.usable > item2.usable then
            return false
        else
            return true
        end
    end
	self.itemList = item_list
	self.clickCallBack = clickCallBack

    self.itemList:sort(simpleSort)
	if self.tableView == nil then
		self:creatTableView()
	end
	self.tableView:reloadData()

    self.img_guodu1:setVisible(false)
    if self.itemList:length() > 6 then
        self.tableView:setInertiaScrollEnabled(true)
        self.img_guodu2:setVisible(true)
    else
        self.tableView:setInertiaScrollEnabled(false)
        self.img_guodu2:setVisible(false)
    end

end




function RoleInfoLayer_yfSelect:creatTableView()
	local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.Panel_useitem:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.Panel_useitem:getPosition())
    self.tableView = tableView
     
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleInfoLayer_yfSelect.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleInfoLayer_yfSelect.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleInfoLayer_yfSelect.numberOfCellsInTableView)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleInfoLayer_yfSelect.numberOfCellsInTableView)
    tableView:addMEListener(TFTABLEVIEW_SCROLL, RoleInfoLayer_yfSelect.scrollForTable);

    self.Panel_useitem:getParent():addChild(self.tableView,1)
end


function RoleInfoLayer_yfSelect.scrollForTable(table)
	local self = table.logic
    local currentSize = table:getContentSize()
    local tabSize = table:getSize()
    local offset = table:getContentOffset()
    if tabSize.height - offset.y < currentSize.height then
        self.img_guodu1:setVisible(true)
    else
        self.img_guodu1:setVisible(false)
    end
    if offset.y >= 0 then
        self.img_guodu2:setVisible(false)
    else
        self.img_guodu2:setVisible(true)
    end
end
function RoleInfoLayer_yfSelect.cellSizeForTable(table,cell)
    return 140,477
end

function RoleInfoLayer_yfSelect.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1
        self.allPanels[newIndex] = cell

        for i=1,columnNumber do
            local panel = self.cellModel:clone()
            panel:setPosition(ccp(20 + 140 * (i - 1) ,0))
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



function RoleInfoLayer_yfSelect:cellInfoSet( panel, idx )

    if panel.boundData == nil then
        panel.boundData = true
        panel.img_icon = TFDirector:getChildByPath(panel, "img_icon")
        panel.txt_num = TFDirector:getChildByPath(panel, "txt_num")

        panel:addMEListener(TFWIDGET_CLICK,audioClickfun(self.cellButtonClick))
        panel.logic = self
    end
    panel.idx = idx


    local itemInfo = self.itemList:objectAt(idx);
    if  itemInfo then
        panel:setVisible(true)
        local item = ItemData:objectByID( itemInfo.id );
        panel.img_icon:setTexture(item:GetPath())
        panel.txt_num:setText(itemInfo.num)
        panel:setTextureNormal(GetColorIconByQuality(item.quality))
    else
        panel:setVisible(false)
    end
end

function RoleInfoLayer_yfSelect.numberOfCellsInTableView(table,cell)
    local self = table.logic
	if self.itemList == nil then
		return 0
	end
	return math.ceil(self.itemList:length()/columnNumber)
end


function RoleInfoLayer_yfSelect.cellButtonClick( btn )
    local self = btn.logic
    local item = self.itemList:objectAt(btn.idx)
    local layer = require("lua.logic.common.YuanfenUsedLayer"):new(item.id)
    layer:setClickFun(self.clickCallBack)
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()

    -- TFFunction.call(self.clickCallBack,self.itemList:objectAt(btn.idx))
end

function RoleInfoLayer_yfSelect:removeUI()
	self.super.removeUI(self)

	if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function RoleInfoLayer_yfSelect:onShow()
    self.super.onShow(self)
end



function RoleInfoLayer_yfSelect.closeBtnClick(btn)
    AlertManager:close()
end


function RoleInfoLayer_yfSelect:registerEvents()
	self.ui.logic = self
    self.ui:setTouchEnabled(true)
	self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))
	self.super.registerEvents(self)
end

function RoleInfoLayer_yfSelect:removeEvents()
    self.super.removeEvents(self)

    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function RoleInfoLayer_yfSelect:dispose()

	self.super.dispose(self)
end


return RoleInfoLayer_yfSelect