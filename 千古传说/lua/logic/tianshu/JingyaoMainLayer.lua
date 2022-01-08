--[[
    精要主界面
]]

local JingyaoMainLayer = class("JingyaoMainLayer", BaseLayer)

JingyaoMainLayer.TYPE_UNEQUIPPED = 1
JingyaoMainLayer.TYPE_EQUIPPED = 2

function JingyaoMainLayer:ctor(data)
    --左侧tab类别
    self.equipType = self.TYPE_UNEQUIPPED

    self.itemType = 1
    self.itemQuality = 0

    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.tianshu.JingYaoMain")
    self.firstShow = true
end

function JingyaoMainLayer:initUI(ui)
	self.super.initUI(self, ui)

	--通用头部
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.JingYao, {HeadResType.YUELI, HeadResType.COIN, HeadResType.SYCEE})

    --左侧按钮
    self.panel_tab = TFDirector:getChildByPath(ui, "panel_tab")
    self.btn_tab = {}
    self.btn_tab[1] = TFDirector:getChildByPath(ui, "btn_jingyao")
    self.btn_tab[1].logic = self
    self.btn_tab[1].tag = 1
	self.btn_tab[2] = TFDirector:getChildByPath(ui, "btn_piece")
	self.btn_tab[2].logic = self
    self.btn_tab[2].tag = 2
  

	--大遮罩
    self.panel_choice = TFDirector:getChildByPath(ui, "panel_choice")
    self.panel_choice:setVisible(false)
    self.panel_choice.logic = self

    self.img_choice_bg = TFDirector:getChildByPath(ui, "img_choice_bg")
    self.img_choice_bg:setVisible(false)
    --下拉小背景
    self.panel_xiala = TFDirector:getChildByPath(ui, "panel_xiala")

    self.img_bg1 = TFDirector:getChildByPath(ui, "img_bg1")
    self.img_bg2 = TFDirector:getChildByPath(ui, "img_bg2")
    self.tabButtonTextureNormal = {
        'ui_new/tianshu/tab_jy.png',
        'ui_new/tianshu/tab_jysp.png',
    }
    self.tabButtonTextureSelect = {
        'ui_new/tianshu/tab_jyh.png',
        'ui_new/tianshu/tab_jysph.png',
    }

	self.btn_fenjie = TFDirector:getChildByPath(ui, "btn_fenjie")
	self.btn_fenjie.logic = self

	self.bg = TFDirector:getChildByPath(ui, "bg")
	self.panel_list = TFDirector:getChildByPath(ui, "panel_list")
    
    --下拉panel
    self.panel_menu = TFDirector:getChildByPath(ui, "panel_menu")
    self.panel_menu:setVisible(false)

    --下拉按钮
    self.btn_xiala = TFDirector:getChildByPath(ui, "btn_xiala")
    self.btn_xiala.logic = self

    --两个下拉选择按钮
    self.btn_yzp = TFDirector:getChildByPath(ui, "btn_yzp")
    self.btn_yzp.logic = self
    self.btn_wzp = TFDirector:getChildByPath(ui, "btn_wzp")
    self.btn_wzp.logic = self

    self.groupButtonManager = GroupButtonManager:new({[1] = self.btn_wzp, [2] = self.btn_yzp})
    self.groupButtonManager:selectBtn(self.btn_wzp);
    --下拉按钮上显示未装配或已装配
    self.btn_wzp_press = TFDirector:getChildByPath(ui, "btn_wzp-press")
    self.btn_yzp_press = TFDirector:getChildByPath(ui, "btn_yzp-press")

    --self.btn_hecheng = TFDirector:getChildByPath(ui, "btn_hecheng")
    --self.btn_hecheng.logic = self

    self.btn_press = {[1] = self.btn_wzp_press, [2] = self.btn_yzp_press}
    for i = 1, #self.btn_press do
        self.btn_press[i]:setVisible(false)
    end
    --默认显示未装配
    self.btn_press[self.equipType]:setVisible(true)


    self.btn_choice = {}
    for i=1,5 do
        self.btn_choice[i] = TFDirector:getChildByPath(ui, 'btn_choice_'..i)
    end
    self.btn_listType = TFDirector:getChildByPath(ui, 'btn_listType')
    self.img_listType = TFDirector:getChildByPath(ui, 'img_listType')

    self.normalTextureBlack = {"ui_new/yongbing/btn_quanbu1.png","ui_new/tianshu/img_cheng2.png","ui_new/tianshu/img_zi2.png","ui_new/tianshu/img_lan2.png","ui_new/tianshu/img_lv2.png","ui_new/tianshu/img_bai2.png"}
    self.normalTexture = {"ui_new/yongbing/btn_quanbu.png","ui_new/tianshu/img_cheng1.png","ui_new/tianshu/img_zi1.png","ui_new/tianshu/img_lan1.png","ui_new/tianshu/img_lv1.png","ui_new/tianshu/img_bai1.png"}

    self:freshItemTypeButton()
    --self:selectDefaultTab()
end

function JingyaoMainLayer:freshItemTypeButton()
    for i=1,#self.btn_tab do
        if i == self.itemType then
            self.btn_tab[i]:setTextureNormal(self.tabButtonTextureSelect[i])
        else
            self.btn_tab[i]:setTextureNormal(self.tabButtonTextureNormal[i])
        end
    end
    if self.itemType == 1 then
        self:showSBStoneLayer()
    else
        self:showSBStonePieceLayer()
    end
end


function JingyaoMainLayer:onShow()
    print("+++++++onShow+++++++", self.itemType, self.itemQuality)
	self.super.onShow(self)
	self.generalHead:onShow()
    self:refreshBaseUI()

    print("+++++++onShow+++++++", self.itemType, self.itemQuality)

    self:refreshUI()
    if self.firstShow == true then
    	self.ui:runAnimation("Action0", 1)
    	self.firstShow = false
    end
end

function JingyaoMainLayer:refreshBaseUI()
end

function JingyaoMainLayer:refreshUI()
    -- self:selectDefaultTab()
	self:freshItemTypeButton()

    local temp = 1
    for i=0,5 do
        if i ~= self.itemQuality then
            self.btn_choice[temp]:setTextureNormal(self.normalTexture[i+1])
            -- self.btn_choice[temp]:setPressedTexture(self.normalTexture[i+1])
            temp = temp + 1
        else
            self.img_listType:setTexture(self.normalTextureBlack[i+1])
        end
    end

    self:refreshRedPointState()
    --self:refreshTabButton()
    --self:selectDefaultTab()
end

--更新红点状态
function JingyaoMainLayer:refreshRedPointState()
    local position = ccp(0, -10)
    local bHave = SkyBookManager:isHaveJingyaoCanHecheng()

    CommonManager:updateRedPoint(self.btn_tab[2], bHave, position)
end

--左侧按钮点击事件
function JingyaoMainLayer.itemTypeButtonClickHandle(sender)
    local self = sender.logic
    if self.itemType == sender.tag then
        return
    end

    self.itemType = sender.tag
    self:freshItemTypeButton()

end

function JingyaoMainLayer:showSBStoneLayer()
    self.btn_fenjie:setVisible(true)
    self.btn_xiala:setVisible(true)
    self:refreshJingyaoList()
end

function JingyaoMainLayer:showSBStonePieceLayer()
    self.btn_fenjie:setVisible(false)
    self.btn_xiala:setVisible(false)
    self:refreshJingyaoPieceList()
end

-- --左侧按钮点击事件
-- function JingyaoMainLayer.itemTypeButtonClickHandle(sender)
--     local self = sender.logic
--     if self.itemType
--     if self.selectedTabButton then
--         local tag = self.selectedTabButton.tag
--         self.selectedTabButton:setTextureNormal(self.tabButtonTextureNormal[tag + 1])
--     end
--     self.selectedTabButton = sender
--     self.selectedTab = sender.tag

--     self.selectedTabButton:setTextureNormal(self.tabButtonTextureSelect[sender.tag + 1])

--     self:refreshJingyaoList()
-- end

function JingyaoMainLayer:removeUI()
	self.super.removeUI(self)
    self.equipType = nil
    self.selectedTab = nil
    self.jingyaoList = nil
end

function JingyaoMainLayer.cellSizeForTable(table, idx)
    local self = table.logic
    local num = math.ceil(self.jingyaoList:length() / 5)
    if num < 2 then
        num = 2
    end
    if idx + 1 == num and num ~= 2 then
        return 210, 725
    end

    return 180, 725
end

--销毁方法
function JingyaoMainLayer:dispose()
    self:disposeAllPanels()
    if self.generalHead then
    	self.generalHead:dispose()
    	self.generalHead = nil
    end
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function JingyaoMainLayer:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r = 1, #self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            --panel:dispose()
            panel = nil
        end
    end
end

function JingyaoMainLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    local startOffset = 10
    local columnSpace = 10
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i = 1, 5 do
            local equip_panel = require('lua.logic.tianshu.NewJingyaoIcon'):new()
            local size = equip_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset

            equip_panel:setPosition(ccp(x, 0))
            equip_panel:setLogic(self)
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = equip_panel
        end
    end
    for i=1,5 do
    	if (idx * 5 + i) <= self.jingyaoList:length() then
	    	local item = self.jingyaoList:objectAt(idx * 5 + i)
    		cell.equip_panel[i]:setData(item.id, self.itemType ,self.equipType, item)
            if self.selectId == item.id then
                self:select(item.id)
            end
    	else
    		cell.equip_panel[i]:setData(nil)
    	end

        local size = cell.equip_panel[i]:getSize()
        local x = size.width*(i-1)
        if i > 1 then
            x = x + (i-1)*columnSpace
        end
        x = x + startOffset

        local num = math.ceil(self.jingyaoList:length() / 5)
        if num < 2 then
            num = 2
        end
        if idx + 1 == num and num ~= 2 then
            cell.equip_panel[i]:setPosition(ccp(x, 30))
        else
            cell.equip_panel[i]:setPosition(ccp(x, 0))
        end
    end
    cell:setZOrder(-idx)

    return cell
end

--选中精要碎片
function JingyaoMainLayer:select(id)
    if self.selectId then
        if self.selectId == id then
            --return
        end

        self:unselectAllCellPanels()
    end
    
    self.selectId = id
    self:updateSelectCell()

    --self.selectId = id

    for i = 1, #self.allPanels do
        if self.allPanels[i].id == self.selectId then
            self.allPanels[i]:setChoose(true)
        end
    end
end

--刷新全部cell
function JingyaoMainLayer:updateSelectCell()
    if self.allPanels == nil then
        return
    end

    for i = 1, #self.allPanels do
        local panel = self.allPanels[i]
        panel:refreshUI()
    end
end

--选中默认cell
function JingyaoMainLayer:selectDefault()
    if self.jingyaoList and self.jingyaoList:length() > 0 then
        self:select(self.jingyaoList:objectAt(1).id)
    else
        print("JingyaoMainLayer:selectDefault(), jingyaoList is nil or length == 0")
    end
end

--全部cell都重置为未选中
function JingyaoMainLayer:unselectAllCellPanels()
    if self.allPanels == nil then
        return
    end

    for i = 1, #self.allPanels do
        local panel = self.allPanels[i]
        if self.selectId and panel.id == self.selectId then
            panel:setChoose(false)
        end
    end
end

function JingyaoMainLayer.numberOfCellsInTableView(table)
	local self = table.logic
	if self.jingyaoList and self.jingyaoList:length() > 0 then
		local num = math.ceil(self.jingyaoList:length()/5)
		if num < 2 then
			return 2
		else
			return num
		end
    end
    return 2
end

function JingyaoMainLayer:initTableView()
    if self.tableView then
        return
    end

	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, JingyaoMainLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, JingyaoMainLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, JingyaoMainLayer.numberOfCellsInTableView)
    tableView:addMEListener(TFTABLEVIEW_SCROLL, JingyaoMainLayer.scrollForTable);
	self.panel_list:addChild(tableView)
end

function JingyaoMainLayer.btnXialaClickHandle(sender)
	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
        self.panel_menu:setVisible(false)
        self.img_choice_bg:setVisible(false)
	else
		self.panel_choice:setVisible(true)
        self.panel_menu:setVisible(true)
	end
end

function JingyaoMainLayer.onFenjieClickHandle(sender)
	local self = sender.logic
	self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
		local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.tianshu.JingyaoFenjieLayer")
		AlertManager:show()
		self.firstShow = true
	end)
	self.ui:runAnimation("Action1", 1)
end

--更新精要list数据
function JingyaoMainLayer:refreshJingyaoList()

    local function sortByQuality(item1, item2)
        if item1.quality > item2.quality then
            return true
        elseif item1.quality == item2.quality then
            if item1.id < item2.id then
                return true
            end
        end
        return false
    end

	if self.equipType == self.TYPE_UNEQUIPPED then
        --未装备到天书上的精要
        self.jingyaoList = BagManager:getItemByType(SkyBookManager.TYPE_ESSENTIAL)

        if self.itemQuality > 0 and self.itemQuality < 6 then
            local quality = 5 - (self.itemQuality - 1)
            local arr = TFArray:new()
            for v in self.jingyaoList:iterator() do
                if v.quality == quality then
                    arr:push(v)
                end
            end
            self.jingyaoList = arr
        end
        self.jingyaoList:sort(sortByQuality)
    else
        --已经装备到天书上的精要
        self.jingyaoList = SkyBookManager:getEquippedJingyaoList()
        if self.itemQuality > 0 and self.itemQuality < 6 then
            local quality = 5 - (self.itemQuality - 1)
            local arr = TFArray:new()
            for v in self.jingyaoList:iterator() do
                local id = v.id
                local item = ItemData:objectByID(id)
                local temp = item.quality
                if quality == temp then
                    arr:push(v)
                end
            end
            self.jingyaoList = arr
        end
    end
    --[[
    print("{{{{{{{{{")
    print(self.jingyaoList:length())
    print("}}}}}}}}}")
    ]]
    
    self:initTableView()
	if self.tableView then
		self.tableView:reloadData()
		--self.tableView:setScrollToBegin()
	end
end

--更新精要list数据
function JingyaoMainLayer:refreshJingyaoPieceList()

    local function sortByQuality(item1, item2)
        if item1.quality > item2.quality then
            return true
        elseif item1.quality == item2.quality then
            if item1.id < item2.id then
                return true
            end
        end
        return false
    end

    local function sortByCustom(item1, item2)
        local jingyaoId1 = SkyBookManager:getJingyaoIdByPieceId(item1.id)
        local bCanMerge1 = SkyBookManager:isJingyaoCanHecheng(jingyaoId1)

        local jingyaoId2 = SkyBookManager:getJingyaoIdByPieceId(item2.id)
        local bCanMerge2 = SkyBookManager:isJingyaoCanHecheng(jingyaoId2)

        if bCanMerge1 == bCanMerge2 then
            return sortByQuality(item1, item2)
        else
            return bCanMerge1
        end
    end

    --未装备到天书上的精要
    self.jingyaoList = BagManager:getItemByType(EnumGameItemType.SBStonePiece)

    if self.itemQuality > 0 and self.itemQuality < 6 then
        local quality = 5 - (self.itemQuality - 1)
        local arr = TFArray:new()
        for v in self.jingyaoList:iterator() do
            if v.quality == quality then
                arr:push(v)
            end
        end
        self.jingyaoList = arr
    end
    self.jingyaoList:sort(sortByCustom)
  
    self:initTableView()
    if self.tableView then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin()
    end

    print("{{{{{{{selectId = ", self.selectId)
    if self.selectId then
        if BagManager:getItemNumById(self.selectId) == 0 then
            self:selectDefault()
        else
            self:select(self.selectId)
        end
    else
        self:selectDefault()
    end
end


--默认选中第一个tab按钮
function JingyaoMainLayer:selectDefaultTab()
	if not self.selectedTab then
		self.itemTypeButtonClickHandle(self.btn_tab[1])
	end
end

--[[
遮罩点击事件处理方法
]]
function JingyaoMainLayer.panelChoiceClickHandle(sender)
	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
        self.panel_menu:setVisible(false)
        self.img_choice_bg:setVisible(false)
	else
		self.panel_choice:setVisible(true)
	end
end

function JingyaoMainLayer.onSortSelectClickHandle(sender)
    local self = sender.logic

    self.panel_menu:setVisible(false)
    self.panel_choice:setVisible(false)

    if self.groupButtonManager:getSelectButton() == sender then
       return
    end

   if sender == self.btn_yzp then
        for i = 1, #self.btn_press do
            self.btn_press[i]:setVisible(false)
        end
        self.btn_yzp_press:setVisible(true)
        self.equipType = self.TYPE_EQUIPPED
   elseif sender == self.btn_wzp then
        for i = 1, #self.btn_press do
            self.btn_press[i]:setVisible(false)
        end
        self.btn_wzp_press:setVisible(true)
        self.equipType = self.TYPE_UNEQUIPPED
   end

   self.groupButtonManager:selectBtn(sender)
   self:refreshJingyaoList()
end

function JingyaoMainLayer:registerEvents()
	self.super.registerEvents(self)

	self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.panelChoiceClickHandle))

	--下拉按钮
	self.btn_xiala:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnXialaClickHandle))

    self.btn_wzp:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortSelectClickHandle), 1)
    self.btn_yzp:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortSelectClickHandle), 1)

    --分解按钮
	self.btn_fenjie:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFenjieClickHandle))
	--左侧按钮事件监听
	for i = 1, #self.btn_tab do
		self.btn_tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.itemTypeButtonClickHandle))
	end

    for i=1,5 do
        self.btn_choice[i].logic = self
        self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.choiceButtonClick))
        self.btn_choice[i]:setTag(i)
    end
    self.btn_listType.logic = self
    self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buttonListTypeClick))

    self.EssentialMergeCallback = function(event)
        print("type == ", self.itemType, self.itemQuality)

        local jingyaoId = event.data[1]
        local layer = require("lua.logic.bag.BagPieceMergeResult"):new(jingyaoId)
        AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
        AlertManager:show()
    end

    TFDirector:addMEGlobalListener(BagManager.EQUIP_PIECE_MERGE, self.EssentialMergeCallback)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

     -- self.ui:runAnimation("Action0",1);
end


function JingyaoMainLayer.choiceButtonClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    local temp = 0
    for i=0,5 do
        if i ~= self.itemQuality then
            temp = temp + 1
        end
        if temp == index then
            self.itemQuality = i
            self.panel_choice:setVisible(false)
            self.img_choice_bg:setVisible(false)
            self:refreshUI()
            return
        end
    end
end

function JingyaoMainLayer.onHechengClickHandle(sender)
    local self = sender.logic

    print("jingyao piece hecheng clicked!")

    if not self.selectId then
        return
    end

    local jingyaoId = SkyBookManager:getJingyaoIdByPieceId(self.selectId)
    print("++++++++++target jingyaoId = ", jingyaoId)
    if SkyBookManager:isJingyaoCanHecheng(jingyaoId) then
        SkyBookManager:requestEssentialMerge(jingyaoId)
    else
        toastMessage(localizable.Tianshu_hecheng_text1)
    end
end

function JingyaoMainLayer.buttonListTypeClick(sender)
    local self = sender.logic
    if self.panel_choice:isVisible() then
        self.panel_choice:setVisible(false)
        self.panel_menu:setVisible(false)
        self.img_choice_bg:setVisible(false)
    else
        self.panel_choice:setVisible(true)
        self.img_choice_bg:setVisible(true)
    end
end
function JingyaoMainLayer:removeEvents()
	print("------------------------JingyaoMainLayer:removeEvents()--------------------")

    TFDirector:removeMEGlobalListener(BagManager.EQUIP_PIECE_MERGE, self.EssentialMergeCallback)

    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.firstShow = true
end

function JingyaoMainLayer.scrollForTable(table)
    local self = table.logic
    local currentSize = table:getContentSize()
    local tabSize = table:getSize()
    local offset = table:getContentOffset()
    if tabSize.height - offset.y < currentSize.height then
        self.img_bg1:setVisible(true)
    else
        self.img_bg1:setVisible(false)
    end
    if offset.y >= 0 then
        self.img_bg2:setVisible(false)
    else
        self.img_bg2:setVisible(true)
    end
end
return JingyaoMainLayer
