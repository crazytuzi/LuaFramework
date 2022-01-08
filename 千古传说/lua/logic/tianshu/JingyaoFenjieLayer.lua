--[[
    精要分解界面
]]

local JingyaoFenjieLayer = class("JingyaoFenjieLayer", BaseLayer)

JingyaoFenjieLayer.TAB_NUM = 5

function JingyaoFenjieLayer:ctor(data)
    self.super.ctor(self, data)
    self.itemQuality = 0
    self:init("lua.uiconfig_mango_new.tianshu.JingYaoFenJie")
    self.firstShow = true
    self.fenjieList = {}
end

function JingyaoFenjieLayer:initUI(ui)
	self.super.initUI(self, ui)
	--通用头部
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.JingyaoFenjie, {HeadResType.YUELI, HeadResType.COIN, HeadResType.SYCEE})



	self.panel_list = TFDirector:getChildByPath(ui, "panel_list")


	--确定分解按钮
	self.btn_fenjie = TFDirector:getChildByPath(ui, "btn_qdfj")
	self.btn_fenjie.logic = self


    --大遮罩
    self.panel_choice = TFDirector:getChildByPath(ui, "panel_choice")
    self.panel_choice:setVisible(false)
    self.panel_choice.logic = self

    self.img_choice_bg = TFDirector:getChildByPath(ui, "img_choice_bg")
    self.img_choice_bg:setVisible(false)

    self.btn_choice = {}
    for i=1,5 do
        self.btn_choice[i] = TFDirector:getChildByPath(ui, 'btn_choice_'..i)
    end
    self.btn_listType = TFDirector:getChildByPath(ui, 'btn_listType')
    self.img_listType = TFDirector:getChildByPath(ui, 'img_listType')

    self.normalTextureBlack = {"ui_new/yongbing/btn_quanbu1.png","ui_new/tianshu/img_cheng2.png","ui_new/tianshu/img_zi2.png","ui_new/tianshu/img_lan2.png","ui_new/tianshu/img_lv2.png","ui_new/tianshu/img_bai2.png"}
    self.normalTexture = {"ui_new/yongbing/btn_quanbu.png","ui_new/tianshu/img_cheng1.png","ui_new/tianshu/img_zi1.png","ui_new/tianshu/img_lan1.png","ui_new/tianshu/img_lv1.png","ui_new/tianshu/img_bai1.png"}

    self.img_bg1 = TFDirector:getChildByPath(ui, "img_bg1")
    self.img_bg2 = TFDirector:getChildByPath(ui, "img_bg2")


	self:initTableView()
end

function JingyaoFenjieLayer:loadData()
	--self.selectedItem = {}
end

function JingyaoFenjieLayer:onShow()
	self.super.onShow(self)
	--self:refreshSelectIcon()
	self.generalHead:onShow()
    self:refreshBaseUI()
    self:refreshUI()
    if self.firstShow == true then
    	self.ui:runAnimation("Action0", 1)
    	self.firstShow = false
    end
end

function JingyaoFenjieLayer:refreshBaseUI()

end

function JingyaoFenjieLayer:refreshUI()
	self:refreshItemList()

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


end

function JingyaoFenjieLayer:removeUI()
	self.super.removeUI(self)
end

function JingyaoFenjieLayer.cellSizeForTable(table,idx)
    return 180, 725
end

--销毁方法
function JingyaoFenjieLayer:dispose()
    self:disposeAllPanels()
    if self.generalHead then
    	self.generalHead:dispose()
    	self.generalHead = nil
    end
    
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function JingyaoFenjieLayer:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r = 1, #self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
            print("----------------------disposeAllPanels")
        end
    end
end

function JingyaoFenjieLayer.tableCellAtIndex(table, idx)
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
            local item_panel = require("lua.logic.tianshu.JingyaoIcon"):new()
            local size = item_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset
            item_panel:setPosition(ccp(x, 0))
            item_panel:setLogic(self)
            cell:addChild(item_panel)
            cell.item_panel = cell.item_panel or {}
            cell.item_panel[i] = item_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = item_panel
        end
    end
    for i = 1, 5 do
    	if (idx * 5 + i) <= self.itemList:length() then
	    	local item = self.itemList:objectAt(idx * 5 + i)
    		cell.item_panel[i]:setId(item.id)
    	else
    		cell.item_panel[i]:setId(nil)
    	end
    end

    return cell
end

function JingyaoFenjieLayer.numberOfCellsInTableView(table)
	local self = table.logic
	if self.itemList and self.itemList:length() > 0 then
		local num = math.ceil(self.itemList:length() / 5)
		if num < 2 then
			return 2
		else
			return num
		end
    end
    return 2
end

--初始化TableView
function JingyaoFenjieLayer:initTableView()
	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, JingyaoFenjieLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, JingyaoFenjieLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, JingyaoFenjieLayer.numberOfCellsInTableView)
    tableView:addMEListener(TFTABLEVIEW_SCROLL, JingyaoFenjieLayer.scrollForTable);

	self.panel_list:addChild(tableView)
end

function JingyaoFenjieLayer:openOperationLayer(id)
	local touchPanel = nil
	for i = 1, #self.allPanels do		
		if self.allPanels[i]:getId() == id then
			touchPanel = self.allPanels[i]
			break
		end
	end

	if touchPanel == nil then
		print("没有找到这件装备", id)
		return
	end
   
	self.tableView:reloadData()
end

--通过品质筛选
function JingyaoFenjieLayer:filterItemListByQuality(itemList, quality)
    if not itemList then
        return itemList
    end

    local array = TFArray:new()
    for v in itemList:iterator() do
        if v.quality == quality then
            array:push(v)
        end
    end
    
    return array
end

function JingyaoFenjieLayer:refreshItemList()

    self.fenjieList = {}
    local itemList = BagManager:getItemByType(SkyBookManager.TYPE_ESSENTIAL)
    --1-5:tab按钮tag,品质:橙紫蓝绿白 /// 0:所有
    if self.itemQuality == 0 then
        self.itemList = itemList
    else
        for i = 1, 5 do
            if self.itemQuality == i then
                local quality = 5 - (i - 1)
                self.itemList = self:filterItemListByQuality(itemList, quality)
            end
        end
    end
	self:sortListByQuality()

	if self.tableView then
		self.tableView:reloadData()
		self.tableView:setScrollToBegin()
	end
end

function JingyaoFenjieLayer:sortListByQuality()
    local function sortQuality(src,target)
        if src.quality > target.quality then
            return true
        elseif src.quality == target.quality then
            if src.id < target.id then
                return true
            end
        end
    end

    local sortFunc = sortQuality
	self.itemList:sort(sortFunc)
end



function JingyaoFenjieLayer:registerEvents()
	self.super.registerEvents(self)


	--确认出售按钮
	self.btn_fenjie:addMEListener(TFWIDGET_CLICK, audioClickfun(self.confirmFenjieClickHandle))

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.essentialExplodeCallBack = function()
    	self:onShow()
    end
    TFDirector:addMEGlobalListener(SkyBookManager.ESSENTIAL_EXPLODE_RESULT, self.essentialExplodeCallBack)   

    for i=1,5 do
        self.btn_choice[i].logic = self
        self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.choiceButtonClick))
        self.btn_choice[i]:setTag(i)
    end
    self.btn_listType.logic = self
    self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buttonListTypeClick))
    self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.panelChoiceClickHandle))

end

function JingyaoFenjieLayer:removeEvents()	
	print("------------------------JingyaoFenjieLayer:removeEvents()--------------------")
    self.btn_fenjie:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.firstShow = true
 
    TFDirector:removeMEGlobalListener(SkyBookManager.ESSENTIAL_EXPLODE_RESULT, self.essentialExplodeCallBack) 
    self.essentialExplodeCallBack = nil   
end

function JingyaoFenjieLayer:calculationResult( gmid )
    return {}
end

function JingyaoFenjieLayer.confirmFenjieClickHandle(sender)

	local self = sender.logic
	if (not self.fenjieList) or #self.fenjieList <= 0 then
		--toastMessage("你没有选择精要！")
        toastMessage(localizable.Tianshu_rongru_text3)
		return
	end

	local calculateRewardList = self:calculateReward()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.hermit.HermitSure",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	layer:setTitle(localizable.sbStone_fenjie_tip)
	layer:loadData(calculateRewardList);
	layer:setBtnHandle(function ()
	    self:confirmFenjie()
    end);
    AlertManager:show();
end

function JingyaoFenjieLayer:confirmFenjie()
	print("confirmFenjie!")

    SkyBookManager:requestEssentialExplode(self.fenjieList)
end

function JingyaoFenjieLayer:calculateReward()
    local calculateRewardList = TFArray:new()

    local coin = 0
    local goodsTbl = {}
    for i = 1, #self.fenjieList do
        local id = self.fenjieList[i].id
        local item = EssentialData:objectByID(tonumber(id))
        local oneCost = item.explode
        coin = coin + oneCost * self.fenjieList[i].num
    end

    if coin > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.YUELI
        rewardInfo.number = coin
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    --[[
    if jinlianshi > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.GOODS
        rewardInfo.itemId = 30021
        rewardInfo.number = jinlianshi
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end

    print('goodsTbl = ',goodsTbl)
    for k,v in pairs(goodsTbl) do
        if v > 0 then
            local rewardInfo = {}
            rewardInfo.type = EnumDropType.GOODS
            rewardInfo.itemId = k
            rewardInfo.number = v
            print('rewardInfo = ',rewardInfo)
            local _rewardInfo = BaseDataManager:getReward(rewardInfo)
            calculateRewardList:push(_rewardInfo);
        end
    end    
    ]]
    
    return calculateRewardList
end

--添加要分解的精要到list
function JingyaoFenjieLayer:addToFenjieList(id, icon, num)
    local item = ItemData:objectByID(id)
    if item == nil then
        print("item不存在,id ==" .. id)
        return
    end

    local listInfo = self:findInFenjieList(id)
    if not listInfo then
        listInfo = {}
        listInfo.id  = id
        listInfo.num = 0
        table.insert(self.fenjieList, listInfo)
    end

    listInfo.num = listInfo.num + num
    if listInfo.num > icon.maxNum then
        listInfo.num = icon.maxNum
    end

    icon:changeNum(listInfo.num)
    self:testPrintList()
end

--test print fenjieList
function JingyaoFenjieLayer:testPrintList()
    print("+++++++++++")
    if not self.fenjieList then
        return
    end
    for i = 1, #self.fenjieList do        
        print(self.fenjieList[i].id, " //// ", self.fenjieList[i].num)
    end
    print("+++++++++++")
end

--从list中删除要分解的精要
function JingyaoFenjieLayer:delAtFenjieList(id, icon)
    local item = ItemData:objectByID(id)
    if item == nil then
        print("item不存在,id ==" .. id)
        return
    end

    local listInfo, index = self:findInFenjieList(id)

    if not listInfo then
        print("no item in fenjie list, id = ", id)
        return
    else
        listInfo.num = listInfo.num - 1
    end

    icon:changeNum(listInfo.num)
    if listInfo.num <= 0 then
        table.remove(self.fenjieList, index)
    end
end

function JingyaoFenjieLayer:findInFenjieList(id)
    for i = 1, #self.fenjieList do
        if self.fenjieList[i].id == id then
            return self.fenjieList[i], i
        end
    end

    return nil
end

--[[
遮罩点击事件处理方法
]]
function JingyaoFenjieLayer.panelChoiceClickHandle(sender)
    local self = sender.logic
    if self.panel_choice:isVisible() then
        self.panel_choice:setVisible(false)
        self.img_choice_bg:setVisible(false)
    else
        self.panel_choice:setVisible(true)
    end
end

function JingyaoFenjieLayer.choiceButtonClick(sender)
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

function JingyaoFenjieLayer.buttonListTypeClick(sender)
    local self = sender.logic
    self.panel_choice:setVisible(true)
    self.img_choice_bg:setVisible(true)
end

function JingyaoFenjieLayer.scrollForTable(table)
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

return JingyaoFenjieLayer