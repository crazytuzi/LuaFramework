--[[
******铁匠铺主界面*******

	-- by david.dai
	-- 2014/6/26
]]

local SmithyMainLayer = class("SmithyMainLayer", BaseLayer)

function SmithyMainLayer:ctor(data)
    self.equipType = 0
    self.functionId = 3

    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.smithy.SmithyMainLayer")
    self.firstShow = true
end

function SmithyMainLayer:initUI(ui)
	self.super.initUI(self,ui)

	--通用头部
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Smithy,{HeadResType.COIN,HeadResType.SYCEE})

    --左侧按钮
    self.panel_tab 		= TFDirector:getChildByPath(ui, 'panel_tab')
    self.btn_tab = {}
    self.icon_tab = {}
	for i=1,5 do
		local str = "btn_role_" .. i
		self.btn_tab[i] = TFDirector:getChildByPath(ui, str)
		self.icon_tab[i] = TFDirector:getChildByPath(ui, "img_icon_" .. i)
		self.btn_tab[i].tag = i
		self.btn_tab[i].logic = self
	end
	--其他
	self.btn_tab[6] = TFDirector:getChildByPath(ui, "btn_other")
	self.btn_tab[6].tag = 6
	self.btn_tab[6].logic = self

	--右上角类别选择Select
	self.panel_choice 	= TFDirector:getChildByPath(ui, 'panel_choice')
	self.panel_choice:setVisible(false)
	self.panel_choice.logic = self

	self.btn_choice = {}
	for i=1,5 do
		local str = "btn_choice_" .. i
		self.btn_choice[i] = TFDirector:getChildByPath(ui, str)
		self.btn_choice[i].tag = i
		self.btn_choice[i].logic = self
	end
	self.btn_listType 	= TFDirector:getChildByPath(ui, 'btn_listType')
	self.btn_listType.logic = self
	self.img_listType 	= TFDirector:getChildByPath(ui, 'img_listType')
	self.btn_sell 	= TFDirector:getChildByPath(ui, 'btn_sell')
	self.btn_sell.logic = self

	--图层，布局，控件
	self.bg 			= TFDirector:getChildByPath(ui, 'bg')
	self.panel_list 	= TFDirector:getChildByPath(ui, 'panel_list')
	
     --传承
    self.btn_smriti = TFDirector:getChildByPath(ui, 'btn_chuancheng')
    self.btn_smriti.logic = self

	self:initTableView()
end

function SmithyMainLayer:onShow()
	self.super.onShow(self)
	self.generalHead:onShow();
    self:refreshBaseUI()
    self:refreshUI()
    if self.firstShow == true then
    	-- self.ui:runAnimation("Action0",1);
    	self.firstShow = false
    end
end

function SmithyMainLayer:refreshBaseUI()
end

function SmithyMainLayer:refreshUI()
	self:refreshEquipList()
    self:refreshTabButton()
    self:selectDefaultTab()
end

--[[
	刷新左侧tab栏的按钮
]]
function SmithyMainLayer:refreshTabButton()
	local fightMatix = StrategyManager:getList()
	local tmpIdx = 0
	for i = 1,10 do
		if fightMatix[i] and fightMatix[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(fightMatix[i])
			if role then
				tmpIdx = tmpIdx + 1
				self.btn_tab[tmpIdx]:setGrayEnabled(false)
				self.btn_tab[tmpIdx]:setTouchEnabled(true)
				--print("self.icon_tab[tmpIdx]",self.icon_tab[tmpIdx])
				self.icon_tab[tmpIdx]:setTexture(role:getIconPath())
				self.icon_tab[tmpIdx]:setVisible(true)
			end
			if tmpIdx == 5 then
				break
			end
		end
	end
	
	for i = tmpIdx + 1,#self.btn_tab - 1 do
		self.btn_tab[i]:setGrayEnabled(true)
		self.btn_tab[i]:setTouchEnabled(false)
		self.icon_tab[i]:setVisible(false)
		--self.icon_tab[i]:setTexture(self:getEmptyIcon())
	end
end

function SmithyMainLayer:getEmptyIcon()
	return "icon/notfound.png"
end

function SmithyMainLayer:removeUI()
	self.super.removeUI(self)
end

function SmithyMainLayer.cellSizeForTable(table,idx)
    return 160, 700
end

--销毁方法
function SmithyMainLayer:dispose()
    self:disposeAllPanels()
    if self.generalHead then
    	self.generalHead:dispose()
    	self.generalHead = nil
    end
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function SmithyMainLayer:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
        end
    end
end

function SmithyMainLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    local startOffset = 10
    local columnSpace = 5
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,5 do
            local equip_panel = require('lua.logic.smithy.SmithyEquipIcon'):new()
            local size = equip_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset
            equip_panel:setPosition(ccp(x,0))
            equip_panel:setLogic(self)
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = equip_panel
        end
    end
    for i=1,5 do
    	if (idx * 5 + i) <= self.equipList:length() then
	    	local equip = self.equipList:objectAt(idx * 5 + i)
	    	--cell.equip_panel[i]:setVisible(true)
    		cell.equip_panel[i]:setEquipGmId(equip.gmId)
    	else
    		--cell.equip_panel[i]:setVisible(false)
    		--cell.equip_panel[i]:setVisible(true)
    		cell.equip_panel[i]:setEquipGmId(nil)
    	end
    end
    return cell
end

function SmithyMainLayer.numberOfCellsInTableView(table)
	local self = table.logic
	if self.equipList and self.equipList:length() > 0 then
		local num = math.ceil(self.equipList:length()/5)
		if num < 2 then
			return 2
		else
			return num
		end
    end
    return 2
end

--初始化TableView
function SmithyMainLayer:initTableView()
	--print("initTableView")
	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, SmithyMainLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, SmithyMainLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, SmithyMainLayer.numberOfCellsInTableView)

	self.panel_list:addChild(tableView)
end

function SmithyMainLayer.listTypeClickHandle(sender)
	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
	else
		self.panel_choice:setVisible(true)
	end

end
function SmithyMainLayer.BtnSellClickHandle(sender)
	local self = sender.logic
	-- self.ui:setAnimationCallBack("ActionMoveOut", TFANIMATION_END, function()
	-- 	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.EquipSellLayer");
	-- 	layer.selectedTab = nil;
	-- 	AlertManager:show();
	-- 	self.firstShow = true
	-- end)
	-- self.ui:runAnimation("ActionMoveOut",1);


	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.EquipSellLayer");
	layer.selectedTab = nil;
	AlertManager:show();
	self.firstShow = true
end

local listTypeName = {
	"ui_new/equipment/tjp_quanbu1_icon.png",
	"ui_new/equipment/tjp_wuqi1_icon.png",
	"ui_new/equipment/tjp_yifu1_icon.png",
	"ui_new/equipment/tjp_jiezhi1_icon.png",
	"ui_new/equipment/tjp_yaodai1_icon.png",
	"ui_new/equipment/tjp_xiezi1_icon.png",
	}
local btnChoiceName = {
	"ui_new/equipment/tjp_quanbu_icon.png",
	"ui_new/equipment/tjp_wuqi_icon.png",
	"ui_new/equipment/tjp_yifu_icon.png",
	"ui_new/equipment/tjp_jiezhi_icon.png",
	"ui_new/equipment/tjp_yaodai_icon.png",
	"ui_new/equipment/tjp_xiezi_icon.png",
}



function SmithyMainLayer:openOperationLayer(gmId)
	--local layer = require("lua.logic.smithy.SmithyBaseLayer"):new(gmId,self.equipList)
    --AlertManager:addLayer(layer)
    --AlertManager:show()
    EquipmentManager:showEquipDetailsDialog(gmId,self.equipList,self.equipType,self.selectedTab == 6)
    PlayerGuideManager:showNextGuideStep()
end

function SmithyMainLayer:refreshEquipList()
	local used = true

	if self.selectedTab == 6 then
		used = false
	end

	local selectedRole = StrategyManager:getFightRoleBySequence(self.selectedTab)
	if selectedRole == nil then
		used = false
	end
	if not used then
		self.equipList = EquipmentManager:GetAllEquipInWarSideFirst(self.equipType)
		--self.equipList:sort(sortUnequiped)
	else
		if self.equipType and self.equipType > 0 then
			if self.equipList then
				self.equipList:clear()
			else
				self.equipList = TFArray:new()
			end
			self.equipList:pushBack(selectedRole.equipment.map[self.equipType])
		else
			self.equipList = selectedRole.equipment:allAsArray()
		end
	end

	if self.tableView then
		self.tableView:reloadData()
		self.tableView:setScrollToBegin()
	end
end

--类别过滤按钮点击事件
function SmithyMainLayer.btnChoiceClickHandle(sender)
	local self = sender.logic
	self.equipType = sender.tag

	if self.equipType == 0 then
		self.img_listType:setTexture(listTypeName[1])
	else
		self.img_listType:setTexture(listTypeName[self.equipType + 1])
	end
	local temp = 1
	for i=0,5 do
		if i ~= self.equipType then
			self.btn_choice[temp].tag = i
			if i == 0 then
				self.btn_choice[temp]:setTextureNormal(btnChoiceName[1])
			else
				self.btn_choice[temp]:setTextureNormal(btnChoiceName[i+1])
			end
			temp = temp + 1
		end
	end

	self:refreshEquipList()

	self.panel_choice:setVisible(false)

end

--默认选中第一个tab按钮
function SmithyMainLayer:selectDefaultTab()
	if not self.selectedTab then
		self.tabButtonClickHandle(self.btn_tab[6])
	end
end

--左侧按钮点击事件
function SmithyMainLayer.tabButtonClickHandle(sender)
	local self = sender.logic
	if self.selectedTabButton then
		local tag = self.selectedTabButton.tag
		if tag ~= 6 then
			self.selectedTabButton:setTextureNormal("ui_new/smithy/bg_role_" .. tag .. ".png")
		else
			self.selectedTabButton:setTextureNormal("ui_new/smithy/all.png")
		end
	end
	self.selectedTabButton = sender
	self.selectedTab = sender.tag
	if sender.tag ~= 6 then
		sender:setTextureNormal("ui_new/smithy/bg_role_" .. sender.tag .. "_pressed.png")
	else
		sender:setTextureNormal("ui_new/smithy/all_pressed.png")
	end

	self:refreshEquipList()
end

function SmithyMainLayer.onBtnSmriti(sender)
	local self = sender.logic
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.SmritiMain");
	local newEquipList = self.equipList
	AlertManager:show();
end

--[[
遮罩点击事件处理方法
]]
function SmithyMainLayer.panelChoiceClickHandle(sender)
	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
	else
		self.panel_choice:setVisible(true)
	end

end

function SmithyMainLayer:registerEvents()
	self.super.registerEvents(self)

	self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.panelChoiceClickHandle))

	--类别选择按钮事件监听
	self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.listTypeClickHandle))
	for i=1,#self.btn_choice do
		self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnChoiceClickHandle))
	end

	self.btn_sell:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnSellClickHandle))
	--左侧按钮事件监听
	for i = 1,#self.btn_tab do
		self.btn_tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClickHandle))
	end
    
    self.btn_smriti:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnSmriti))

	--装备删除监听
	self.EquipmentDelCallBack = function (event)
		self:refreshEquipList()
    end

    TFDirector:addMEGlobalListener(EquipmentManager.DEL_EQUIP,self.EquipmentDelCallBack)

    --新增物品监听
	self.itemAddCallBack = function (event)
		if event.data[1] == EnumGameItemType.Equipment then
			self:refreshEquipList()
		end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    --TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,self.EquipmentDelCallBack)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

     -- self.ui:runAnimation("Action0",1);
end

function SmithyMainLayer:removeEvents()
	print("------------------------SmithyMainLayer:removeEvents()--------------------")
	self.btn_listType:removeMEListener(TFWIDGET_CLICK)

	for i=1,5 do
		self.btn_choice[i]:removeMEListener(TFWIDGET_CLICK)
	end
    
    TFDirector:removeMEGlobalListener(EquipmentManager.DEL_EQUIP,self.EquipmentDelCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,self.EquipmentDelCallBack)
	self.EquipmentDelCallBack = nil
	self.itemAddCallBack = nil
    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.firstShow = true
end

return SmithyMainLayer;
