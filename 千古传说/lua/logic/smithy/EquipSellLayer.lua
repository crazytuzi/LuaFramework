--[[
******装备出售*******

]]

local EquipSellLayer = class("EquipSellLayer", BaseLayer)

function EquipSellLayer:ctor(data)
    self.equipType = 0

    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.smithy.EquipSellLayer")
    self.firstShow = true

end

function EquipSellLayer:initUI(ui)
	self.super.initUI(self,ui)
	print("initUI-----------------1")
	--通用头部
    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.SmithySell,{HeadResType.COIN,HeadResType.SYCEE})

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
	self.btn_tab[6].tag = 0
	self.btn_tab[6].logic = self

	--右上角类别选择Select
	self.panel_choice 	= TFDirector:getChildByPath(ui, 'panel_choice')
	self.panel_choice:setVisible(false)
	self.panel_choice.logic = self

	self.btn_choice = {}
	for i=1,2 do
		local str = "btn_choice_" .. i
		self.btn_choice[i] = TFDirector:getChildByPath(ui, str)
		self.btn_choice[i].tag = i
		self.btn_choice[i].logic = self
	end
	self.btn_listType 	= TFDirector:getChildByPath(ui, 'btn_listType')
	self.btn_listType.logic = self
	self.img_listType 	= TFDirector:getChildByPath(ui, 'img_listType')

	--图层，布局，控件
	self.bg 			= TFDirector:getChildByPath(ui, 'bg')
	self.panel_list 	= TFDirector:getChildByPath(ui, 'panel_list')

	self.tabButtonTextureNormal = {
		'ui_new/smithy/all.png',
		'ui_new/smithy/TAB1.png',
		'ui_new/smithy/TAB2.png',
		'ui_new/smithy/TAB5.png',
		'ui_new/smithy/TAB3.png',
		'ui_new/smithy/TAB4.png'		
	}
	self.tabButtonTextureSelect = {
		'ui_new/smithy/all_pressed.png',
		'ui_new/smithy/TAB1b.png',
		'ui_new/smithy/TAB2b.png',
		'ui_new/smithy/TAB5b.png',
		'ui_new/smithy/TAB3b.png',
		'ui_new/smithy/TAB4b.png'		
	}

	--确认出售按钮
	self.btn_sell = TFDirector:getChildByPath(ui, 'btn_sell')
	self.btn_sell.logic = self
	--返还资源
	self.txt_tips = TFDirector:getChildByPath(ui, 'txt_tips')

	self:initTableView()
end

function EquipSellLayer:setData()
	self.selectGmID = {}
end

function EquipSellLayer:onShow()
	self.super.onShow(self)
	self:refreshSelectIcon()
	self.generalHead:onShow()
    self:refreshBaseUI()
    self:refreshUI()
    if self.firstShow == true then
    	-- self.ui:runAnimation("ActionMoveIn",1);
    	self.firstShow = false
    end
end

function EquipSellLayer:refreshBaseUI()

end

function EquipSellLayer:refreshUI()
	self:refreshEquipList()
    self:selectDefaultTab()
end

function EquipSellLayer:getEmptyIcon()
	return "icon/notfound.png"
end

function EquipSellLayer:removeUI()
	self.super.removeUI(self)
end

function EquipSellLayer.cellSizeForTable(table,idx)
    return 160,725
end

--销毁方法
function EquipSellLayer:dispose()
    self:disposeAllPanels()
    if self.generalHead then
    	self.generalHead:dispose()
    	self.generalHead = nil
    end
    
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function EquipSellLayer:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
            print("----------------------disposeAllPanels")
        end
    end
end

function EquipSellLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    local startOffset = 10
    local columnSpace = 10
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
    		cell.equip_panel[i]:setEquipGmId(equip.gmId)
    		cell.equip_panel[i]:setDuigouVisiable(self.selectIconTable[equip.gmId])
    	else
    		cell.equip_panel[i]:setEquipGmId(nil)
    		cell.equip_panel[i]:setDuigouVisiable(nil)
    	end
    end
    return cell
end

function EquipSellLayer.numberOfCellsInTableView(table)
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
function EquipSellLayer:initTableView()

	local  tableView =  TFTableView:create()
	tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EquipSellLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EquipSellLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EquipSellLayer.numberOfCellsInTableView)

	self.panel_list:addChild(tableView)
end

function EquipSellLayer.listTypeClickHandle(sender)
	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
	else
		self.panel_choice:setVisible(true)
	end

end

--[[
local listTypeName = {
	"ui_new/equipment/tjp_quanbu1_icon.png",
	"ui_new/smithy/img_qianghuadengji2.png",
	"ui_new/smithy/img_pingzhi2.png",
	"ui_new/smithy/img_shenxingdengji2.png",
	}
local btnChoiceName = {
	"ui_new/equipment/tjp_quanbu_icon.png",
	"ui_new/smithy/img_qianghuadengji.png",
	"ui_new/smithy/img_pingzhi.png",
	"ui_new/smithy/img_shenxingdengji.png",
}]]
local listTypeName = {
	"ui_new/smithy/img_pingzhi2.png",
	"ui_new/smithy/img_qianghuadengji2.png",
	"ui_new/smithy/img_shenxingdengji2.png",
	}
local btnChoiceName = {
	"ui_new/smithy/img_pingzhi.png",
	"ui_new/smithy/img_qianghuadengji.png",
	"ui_new/smithy/img_shenxingdengji.png",
}


function EquipSellLayer:openOperationLayer(gmId)

--	local coin,jinglianshi,propId,propNum,pieceId,pieceNum = self:calculationResult(gmId)

	local touchPanel = nil
	for i=1,#self.allPanels do		
		if self.allPanels[i]:getEquipGmId() == gmId then
			touchPanel = self.allPanels[i]
			break
		end
	end

	if touchPanel == nil then
		print("没有找到这件装备",gmId)
		return
	end

	if self.selectIconTable[gmId] then
		--取消选择
		touchPanel:setDuigouVisiable(false)
		self.selectIconTable[gmId] = false
		self.selectIconCount = self.selectIconCount - 1

		-- self.coinNum = self.coinNum - coin
		-- self.jingLianNum = self.jingLianNum - jinglianshi
		-- if propId then
		-- 	self.propTable[propId] = self.propTable[propId] - propNum
		-- end
	else
		if self.selectIconCount >= 15 then
			--toastMessage("最多可以选择15件装备!")
			toastMessage(localizable.smithy_EquipSell_max_equip)
			return
		end
		touchPanel:setDuigouVisiable(true)
		self.selectIconTable[gmId] = true
		self.selectIconCount = self.selectIconCount + 1

		-- self.coinNum = self.coinNum + coin
		-- self.jingLianNum = self.jingLianNum + jinglianshi
		-- if propId then
		-- 	self.propTable[propId] = self.propTable[propId] or 0
		-- 	self.propTable[propId] = self.propTable[propId] + propNum
		-- end
	end
	self.tableView:reloadData()
end

function EquipSellLayer:refreshEquipList()

	self.equipList = EquipmentManager:GetEquipByTypeAndUsed(self.selectedTab,false);

	self:sortListByType()

	if self.tableView then
		self.tableView:reloadData()
		print("<<<<<<<<<<<<<<<<<<<<<reloadData<<<<<<<<<<<<<<<<<<<<<<<<<<<")
		self.tableView:setScrollToBegin()
	end
end

--类别过滤按钮点击事件
function EquipSellLayer.btnChoiceClickHandle(sender)
	local self = sender.logic
	self.equipType = sender.tag

	if self.equipType == 0 then
		self.img_listType:setTexture(listTypeName[1])
	else
		self.img_listType:setTexture(listTypeName[self.equipType + 1])
	end
	local temp = 1
	for i=0,2 do
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
	self.panel_choice:setVisible(false)

	self:sortListByType()

	if self.tableView then
		self.tableView:reloadData()
		self.tableView:setScrollToBegin()
	end
end

function EquipSellLayer:sortListByType()

	--简单品质ID排序
    local function sortQuality(src,target)
        if src.quality > target.quality then
            return true
        elseif src.quality == target.quality then
            if src.id < target.id then
                return true
            end
        end
    end

    --强化等级排序
    local function sortStrengthen(src,target)
        if src.level > target.level then
            return true
        elseif src.level == target.level then
            --if src.id < target.id then
            return sortQuality(src,target)
            --end
        end
    end

    --升星等级排序
    local function sortStarLevel(src,target)
        if src.star > target.star then
            return true
        elseif src.star == target.star then
            --if src.id < target.id then
            return sortQuality(src,target)
            --end
        end
    end

    local sortFunc = sortQuality
	if self.equipType == 0 then --品质
		sortFunc = sortQuality
	elseif self.equipType == 1 then --强化等级
		sortFunc = sortStrengthen
	else--if self.equipType == 2 then --品质
		sortFunc = sortStarLevel
	--else							--self.equipType == 3 then --升星等级
	--	sortFunc = sortStarLevel
	end

	self.equipList:sort(sortFunc)
end

--默认选中第一个tab按钮
function EquipSellLayer:selectDefaultTab()
	if not self.selectedTab then
		self.tabButtonClickHandle(self.btn_tab[6])
	end
end

--左侧按钮点击事件
function EquipSellLayer.tabButtonClickHandle(sender)
	local self = sender.logic
	if self.selectedTabButton then
		local tag = self.selectedTabButton.tag
		self.selectedTabButton:setTextureNormal(self.tabButtonTextureNormal[tag+1])
	end
	self.selectedTabButton = sender
	self.selectedTab = sender.tag

	self.selectedTabButton:setTextureNormal(self.tabButtonTextureSelect[sender.tag+1])

	self:refreshEquipList()
end

--[[
遮罩点击事件处理方法
]]
function EquipSellLayer.panelChoiceClickHandle(sender)

	local self = sender.logic
	if self.panel_choice:isVisible() then
		self.panel_choice:setVisible(false)
	else
		self.panel_choice:setVisible(true)
	end

end

function EquipSellLayer:registerEvents()
	self.super.registerEvents(self)

	self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.panelChoiceClickHandle))

	--类别选择按钮事件监听
	self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.listTypeClickHandle))
	for i=1,#self.btn_choice do
		self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnChoiceClickHandle))
	end

	--左侧按钮事件监听
	for i = 1,#self.btn_tab do
		self.btn_tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClickHandle))
	end

	--确认出售按钮
	self.btn_sell:addMEListener(TFWIDGET_CLICK, audioClickfun(self.confirmSellClickHandle))

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.sellEquipCallBack = function ()
    	self:onShow()
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_SELL_RESULT,self.sellEquipCallBack)    
end

function EquipSellLayer:removeEvents()
	
	print("------------------------EquipSellLayer:removeEvents()--------------------")
	self.btn_listType:removeMEListener(TFWIDGET_CLICK)

	self.panel_choice:removeMEListener(TFWIDGET_CLICK)
	for i=1,2 do
		self.btn_choice[i]:removeMEListener(TFWIDGET_CLICK)
	end
    
    self.btn_sell:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.firstShow = true

    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_SELL_RESULT,self.sellEquipCallBack) 
    self.sellEquipCallBack = nil   
end

function EquipSellLayer:calculationResult( gmid )

	local resultTbl = {
		coin = 0,
		jinlianshi = 0,
		propId = 0,
		propNum = 0,
		pieceId = 0,
		pieceNum = 0
	}
	local equip = EquipmentManager:getEquipByGmid(gmid)
	local coin = 0
    if equip == nil  then
        print("equipment not found .",gmid)
        return resultTbl
    end
    
    local refineLevel   = equip.refineLevel

    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    if equipmentTemplate == nil then
        print("没有此类装备模板信息")
        return resultTbl
    end

    --强化到equip.level所需要的铜币
    for i=1, equip.level do
		coin = coin + IntensifyData:getConsumeByIntensifyLevel(i,equip.quality)
    end
	coin = math.ceil(coin*0.8)
	resultTbl.coin = coin + equip.price

	--返还精炼石
	--精炼石返还   （当前精炼最大的值 - 初始值 ）/ 精炼随机最大值  = 返还精炼石数量，向上取整
	--根据禅道863号 修改精炼石返还规则
	local jinlianshi = 0    
    if equip.quality >= 2 then
		local attribute,indexTable = equip:getExtraAttribute():getAttribute()
		local min_attribute , max_attribute = equipmentTemplate:getExtraAttribute(refineLevel)

		local index = 1
		local maxPercent = 0

    	for k,i in pairs(indexTable) do
    		if min_attribute[i] and max_attribute[i] then
    			local percent = attribute[i]/max_attribute[i]		
    			if percent > maxPercent then
    				maxPercent = percent
    				local initValue = min_attribute[i]+equipmentTemplate.init_min
	            	local Dvalue = attribute[i] - initValue
	            	local refiningGood = string.split(equipmentTemplate.refining_good,'|')
	            	local refiningNew = {}
	            	for k,v in pairs(refiningGood) do
						local activity= string.split(v,'_')
						local arrIdx = tonumber(activity[1])
						local arrValue = tonumber(activity[2])	            		
	            		refiningNew[arrIdx] = arrValue
	            	end
    				jinlianshi = math.ceil(Dvalue/refiningNew[i])
    			end
    		end
	        index = index + 1
	    end
    end
    resultTbl.jinlianshi = jinlianshi

    --升星道具返还
    local starExchangeData = self:equipStarExchangeDataGet(equip.quality, equip.star)
   	local propId = 0
   	local propNum = 0
    if starExchangeData then
	    local activity 		= string.split(starExchangeData.resources,':')
		propId				= tonumber(activity[1])
		propNum 			= tonumber(activity[2])
    end
    resultTbl.propId = tonumber(propId) or 0
    resultTbl.propNum = tonumber(propNum) or 0

    --装备重铸返还
    local equipPieceNum = 0
    if equip.recastInfo then
		for k,v in pairs(equip.recastInfo) do
			if v.ratio and v.ratio ~= 0 then
				equipPieceNum = equipPieceNum + 1
			end
		end
	end
	local pieceId = equipmentTemplate.fragment_id or 0
	local pieceNum = equipmentTemplate.merge_num or 0
	if equipPieceNum > 0 then
		equipPieceNum = math.floor(equipPieceNum*pieceNum/2)
	end
	resultTbl.pieceId = tonumber(pieceId) or 0
	resultTbl.pieceNum = tonumber(equipPieceNum) or 0

	-- print('xxxxxresultTbl = ',resultTbl)
	-- print('equip.recastInfo = ',equip.recastInfo)
    return resultTbl
end

function EquipSellLayer:equipStarExchangeDataGet( quality, level )

	local starExchangeData = nil

	for i=1,EquipStarExchangeData:size() do
		starExchangeData = EquipStarExchangeData:getObjectAt(i)
		if starExchangeData.quality == quality and starExchangeData.level == level then
			return starExchangeData
		end
	end
	return nil
end


function EquipSellLayer:refreshSelectIcon()
	self.selectIconTable = {}
	self.selectIconCount = 0

	self.coinNum = 0
	self.jingLianNum = 0
	self.propTable = {}

	self.allPanels = self.allPanels or {}
	for k,v in pairs(self.allPanels) do		
		if v then
			v:setEquipGmId(nil)
		end
	end

	print("--------------refreshSelectIcon------------------")
end

function EquipSellLayer.confirmSellClickHandle( btn )

	local self = btn.logic
	if self.selectIconCount <= 0 then
		--toastMessage("你没有选择装备！")
		toastMessage(localizable.smithy_EquipSell_not_check)
		return
	end

	local calculateRewardList = self:calculateReward()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.hermit.HermitSure",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	--layer:setTitle("本次出售装备可获得：")
	layer:setTitle(localizable.smithy_EquipSell_sell)
	layer:loadData(calculateRewardList);
	layer:setBtnHandle(function ()
	    self:confirmSell()
    end);
    AlertManager:show();
end

function EquipSellLayer:confirmSell()
	print("OK!")
	local Msg = {}
    local index = 1
    for k,v in pairs(self.selectIconTable) do
        if v then
            Msg[index] = k
            index = index + 1
        end
    end
    --AlertManager:close(AlertManager.TWEEN_NONE)
    TFDirector:send(c2s.EQUIPMENT_SELL,{Msg})
    showLoading();
end

function EquipSellLayer:calculateReward()

    local calculateRewardList = TFArray:new();

    local coin = 0
    local jinlianshi = 0
    local goodsTbl = {}

    for k,v in pairs(self.selectIconTable) do
    	if v then
    		local tbl = self:calculationResult(k)
    		print('tbl = ', tbl)
    		coin = tbl.coin + coin
    		jinlianshi = tbl.jinlianshi + jinlianshi
    		if tbl.propNum ~= 0 and tbl.propId ~= 0 then
    			goodsTbl[tbl.propId] = goodsTbl[tbl.propId] or 0
    			goodsTbl[tbl.propId] = goodsTbl[tbl.propId] + tbl.propNum
    		end
    		if tbl.pieceId ~= 0 and tbl.pieceNum ~= 0 then
    			goodsTbl[tbl.pieceId] = goodsTbl[tbl.pieceId] or 0
    			goodsTbl[tbl.pieceId] = goodsTbl[tbl.pieceId] + tbl.pieceNum
    		end
    	end
    end
 
 	if coin > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.COIN
        rewardInfo.number = coin
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
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
    
    return calculateRewardList
end
return EquipSellLayer;
