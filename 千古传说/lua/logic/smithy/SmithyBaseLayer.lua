--[[
******铁匠铺主界面*******

	-- by david.dai
	-- 2014/6/26
]]
local SmithyBaseLayer = class("SmithyBaseLayer", BaseLayer)

--Tab页个数
SmithyBaseLayer.kTabNumber = 7
--默认选中的Tab页索引
SmithyBaseLayer.kDefaultTabIndex = 1

--[[
	Tab按钮按下的图片地址
]]
local tabPressedPaths = {
	"ui_new/smithy/tab_intensify_pressed.png",
	"ui_new/smithy/tab_star_up_pressed.png",
	"ui_new/smithy/tab_practice_press.png",
	"ui_new/smithy/tab_refin_pressed.png",
	"ui_new/smithy/tab_recast_pressd.png",
	"ui_new/smithy/tab_mosaic_pressed.png",
	"ui_new/smithy/tab_gem_merge_pressed.png"
}

--[[
	Tab按钮未按下的图片地址
]]
local tabNormalPaths = {
	"ui_new/smithy/tab_intensify.png",
	"ui_new/smithy/tab_star_up.png",
	"ui_new/smithy/tab_practice.png",
	"ui_new/smithy/tab_refin.png",
	"ui_new/smithy/tab_recast.png",
	"ui_new/smithy/tab_mosaic.png",
	"ui_new/smithy/tab_gem_merge.png"
}

local layerDeclear = {
	"lua.logic.smithy.SmithyIntensify",
	"lua.logic.smithy.EquipmentStarUp",
	"lua.logic.smithy.EquipPractice",
	"lua.logic.smithy.EquipmentRefining",
	"lua.logic.smithy.SmithyRecast",
	"lua.logic.smithy.SmithyGem",
	"lua.logic.smithy.SmithyGemBuild",
}

function SmithyBaseLayer:ctor()
    self.super.ctor(self,gmId)
    self:init("lua.uiconfig_mango_new.smithy.SmithyBaseLayer")
    self.firstShow = true
end

function SmithyBaseLayer:loadData(gmId,list,equipType,allList)
    self.selectedTab = nil

    self.gmId = gmId
    self.equipList = list
    if equipType and equipType ~=0 then
    	self.equipType = equipType
    end
    self.allList = allList
end

function SmithyBaseLayer:initUI(ui)
	self.super.initUI(self,ui)

	--通用头部
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Smithy,{HeadResType.COIN,HeadResType.SYCEE})

    --Tab按钮
    self.btn_tab = {}
    self.btn_splats = {}
	for i=1,SmithyBaseLayer.kTabNumber do
		self.btn_tab[i] = TFDirector:getChildByPath(ui, "tab_" .. i)
		self.btn_tab[i].tag = i
		self.btn_tab[i].logic = self
		--self.btn_tab[i]:setClickScaleEnabled(true)

		self.btn_splats[i] = TFDirector:getChildByPath(ui, "img_splats_" .. i)
		self.btn_splats[i].tag = i
	end

	--内容图层
	self.panel_content  = TFDirector:getChildByPath(ui, 'panel_content')
	self.panel_touch_event = TFDirector:getChildByPath(ui, 'panel_touch_event')
	self.panel_touch_event:setVisible(true)
	--设置为事件穿透
	self.panel_touch_event:setSwallowTouch(false)
	
	--切换界面按钮
	self.btn_left 		= TFDirector:getChildByPath(ui, 'btn_left')
	self.btn_left.logic = self
	self.btn_right 		= TFDirector:getChildByPath(ui, 'btn_right')
	self.btn_right.logic= self

	self.btn_left:setClickScaleEnabled(true)
	self.btn_right:setClickScaleEnabled(true)

	self.operationLayer = {}

end

function SmithyBaseLayer:setEquipGmId(gmId)
	self.gmId = gmId
	self.operationLayer[self.selectedTab]:setVisible(true)
	if self.selectedTab ~= 7 then
		self.operationLayer[self.selectedTab]:setEquipGmId(gmId)
	end
end

function SmithyBaseLayer:onShow()
	self.super.onShow(self)
	self.generalHead:onShow();
    self:refreshUI()
    if self.selectedTab and self.operationLayer[self.selectedTab] then
    	self.operationLayer[self.selectedTab]:onShow()
    end
    if self.firstShow == true then
    	-- self.ui:runAnimation("Action0",1);
    	self.firstShow = false
    end
end

function SmithyBaseLayer:refreshUI()
	self:autoCheckLeftRightArrowButtonVisiable()
    self:refreshTabButton()
    self:selectDefaultTab()
end

function SmithyBaseLayer:setLogic(logic)
	self.logic = logic
end

--[[
	刷新顶部tab栏的按钮
]]
function SmithyBaseLayer:refreshTabButton()
	for i = 1,#self.btn_tab do
		--这里处理每一个按钮
	end
	
	CommonManager:updateWidgetState(self.btn_tab[2],EquipmentManager.Function_StarUp,false, visiable,ccp(-30,10))
	CommonManager:updateWidgetState(self.btn_tab[3],EquipmentManager.Function_Parctice,false, visiable,ccp(-30,10))
	CommonManager:updateWidgetState(self.btn_tab[5],EquipmentManager.Function_Recast,false, visiable,ccp(-30,10))
	CommonManager:updateWidgetState(self.btn_tab[4],EquipmentManager.Function_Refining,EquipmentManager:isHaveNewRefinStone(), visiable,ccp(-30,10))
	CommonManager:updateWidgetState(self.btn_tab[6],EquipmentManager.Function_Gem_Mount,EquipmentManager:isHaveNewGem(), visiable,ccp(-30,10))
	CommonManager:updateWidgetState(self.btn_tab[7],EquipmentManager.Function_Gem_Merge,EquipmentManager:isHaveGemEnough(), visiable,ccp(-30,10))
end

function SmithyBaseLayer:removeUI()
	self.super.removeUI(self)
end

--销毁方法
function SmithyBaseLayer:dispose()
	for i = 1,#layerDeclear do
		if self.operationLayer[i] then
			self.operationLayer[i]:dispose()
		end
	end

	if self.generalHead then
		self.generalHead:dispose()
		self.generalHead = nil
	end

    self.super.dispose(self)
end

--默认选中第一个tab按钮
function SmithyBaseLayer:selectDefaultTab()
	if not self.selectedTab then
		self.tabButtonClickHandle(self.btn_tab[SmithyBaseLayer.kDefaultTabIndex])
	end
end

--[[
设置左右切换装备箭头是否显示
]]
function SmithyBaseLayer:setLeftRightArrowButtonsVisible(visible)
	self.btn_left:setVisible(visible)
	self.btn_right:setVisible(visible)
	if visible then
		self:autoCheckLeftRightArrowButtonVisiable()
	end
end

--顶部按钮点击事件
function SmithyBaseLayer.tabButtonClickHandle(sender)
	local self = sender.logic
	if self.selectedTabButton then
		local tag = self.selectedTabButton.tag
		self.selectedTabButton:setTextureNormal(tabNormalPaths[tag])
		self.selectedTabButton:setZOrder(1)
	end
	self.selectedTabButton = sender
	self.selectedTab = sender.tag
	self.selectedTabButton:setTextureNormal(tabPressedPaths[sender.tag])
	self.selectedTabButton:setZOrder(2)

	--隐藏所有其他tab对应的图层
	for i = 1,#layerDeclear do
		if self.selectedTab ~= i and self.operationLayer[i] then
			self.operationLayer[i]:setVisible(false)
			if i == 7 then
				self.operationLayer[i]:stopAutoBuild()
			end
		end
	end

	--显示当前tab对应的图层
	if not self.operationLayer[self.selectedTab] then
		local newLayer = require(layerDeclear[self.selectedTab]):new(self.gmId)
		self.operationLayer[self.selectedTab] = newLayer
		self.panel_content:addChild(newLayer)
		newLayer:onShow()
	else
		self.operationLayer[self.selectedTab]:setVisible(true)
		if self.selectedTab ~= 7 then
			self.operationLayer[self.selectedTab]:setEquipGmId(self.gmId)
		else
			self.operationLayer[self.selectedTab]:onShow()
		end
	end
	if self.selectedTab == 4 and EquipmentManager:isHaveNewRefinStone() then
		EquipmentManager:onIntoRefinLayer()
		CommonManager:removeRedPoint(self.btn_tab[4])
	end
	if self.selectedTab == 6 and EquipmentManager:isHaveNewGem() then
		EquipmentManager:onIntoGemLayer()
		CommonManager:removeRedPoint(self.btn_tab[6])
	end

	if self.selectedTab == 7 then
		self:setLeftRightArrowButtonsVisible(false)
	else
		self:setLeftRightArrowButtonsVisible(true)
	end
end


function SmithyBaseLayer:autoCheckLeftRightArrowButtonVisiable()
	local hasPrev,hasNext =self:hasPrevOrNext(self.gmId)
	if hasPrev then
		self.btn_left:setVisible(true)
	else
		self.btn_left:setVisible(false)
	end
	if hasNext then
		self.btn_right:setVisible(true)
	else
		self.btn_right:setVisible(false)
	end
end

--向左按钮点击，实际上是切换到上一个装备
function SmithyBaseLayer.leftButtonClickHandle(sender)
	local self = sender.logic
	if self.selectedTab == 2 then
    	local currentPage = self.operationLayer[self.selectedTab]
    	if currentPage.lockMark then
    		return
    	end
    end
	local prevEquip,hasPrev,hasNext = self:getPrevEquip(self.gmId)
	if hasPrev then
		self.btn_left:setVisible(true)
	else
		self.btn_left:setVisible(false)
	end
	if hasNext then
		self.btn_right:setVisible(true)
	else
		self.btn_right:setVisible(false)
	end
	self:setEquipGmId(prevEquip.gmId)
end

--向右按钮点击，实际上是切换到下一个装备
function SmithyBaseLayer.rightButtonClickHandle(sender)
	local self = sender.logic
	if self.selectedTab == 2 then
    	local currentPage = self.operationLayer[self.selectedTab]
    	if currentPage.lockMark then
    		return
    	end
    end
	local nextEquip,hasPrev,hasNext = self:getNextEquip(self.gmId)
	if hasPrev then
		self.btn_left:setVisible(true)
	else
		self.btn_left:setVisible(false)
	end
	if hasNext then
		self.btn_right:setVisible(true)
	else
		self.btn_right:setVisible(false)
	end
	self:setEquipGmId(nextEquip.gmId)
end

function SmithyBaseLayer:registerEvents()
	self.super.registerEvents(self)

	--左侧按钮事件监听
	for i = 1,#self.btn_tab do
		self.btn_tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClickHandle))
	end

	self.btn_left:addMEListener(TFWIDGET_CLICK, audioClickfun(self.leftButtonClickHandle),1)
	
	self.btn_right:addMEListener(TFWIDGET_CLICK, audioClickfun(self.rightButtonClickHandle),1)


	self.EquipmentResultCallBack = function (event)
        self:refreshTabButton()
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_REFINING_RESULT,self.EquipmentResultCallBack)
    TFDirector:addMEGlobalListener(BagManager.GEM_BULID_RESULT,self.EquipmentResultCallBack)
    TFDirector:addMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.EquipmentResultCallBack)
    TFDirector:addMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.EquipmentResultCallBack)

    --滑动事件监听，切换装备
    function onTouchBegin(widget,pos,offset)
    	local currentPage = self.operationLayer[self.selectedTab]
    	if self.selectedTab == 2 or self.selectedTab == 6 or self.selectedTab == 7 then
    		self.touchInTableView = currentPage:isTouchInTableView(pos)
    		if self.touchInTableView then
    			return
    		end
    	end
    	self.touchInTableView = false
    	self.touchBeginPos = pos
    end

    function onTouchMove(widget,pos,offset)
    end

    function onTouchEnd(widget,pos)
    	if self.touchInTableView or self.selectedTab == 7 then
    		return
    	end

    	if self.selectedTab == 2 then
    		local currentPage = self.operationLayer[self.selectedTab]
    		if currentPage.lockMark then
    			return
    		end
    	end

    	local offsetX = pos.x - self.touchBeginPos.x
    	if offsetX < -80 then
    		local nextEquip,hasPrev,hasNext = self:getNextEquip(self.gmId)
    		if nextEquip then
    			self:setEquipGmId(nextEquip.gmId)
    		end
    	elseif offsetX > 80 then
    		local prevEquip,hasPrev,hasNext = self:getPrevEquip(self.gmId)
    		if prevEquip then
    			self:setEquipGmId(prevEquip.gmId)
    		end
    	end
    	self:autoCheckLeftRightArrowButtonVisiable()
    end

    self.panel_touch_event:addMEListener(TFWIDGET_TOUCHBEGAN, onTouchBegin)
    self.panel_touch_event:addMEListener(TFWIDGET_TOUCHMOVED, onTouchMove)
    self.panel_touch_event:addMEListener(TFWIDGET_TOUCHENDED, onTouchEnd)

    --重登录,因为强化装备列表为输入参数，可能已经不可用要重新设定
    self.relogonCallback = function(event)
		self:refreshEquipList()
		self:refreshUI()
   	end
   	TFDirector:addMEGlobalListener(MainPlayer.RE_CONNECT_COMPLETE,self.relogonCallback)

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


    if self.generalHead then
        self.generalHead:registerEvents()
    end

    --适配缓存机制，注册所有已经打开过的tab页面的事件
    for i = 1,#layerDeclear do
		if self.operationLayer[i] then
				self.operationLayer[i]:registerEvents()
			-- if self.selectedTab == i then
			-- else
			-- 	self.operationLayer[i]:registerEvents()
			-- end
		end
	end
end

function SmithyBaseLayer:refreshEquipList()
	local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    if self.allList then
    	self.equipList = EquipmentManager:GetAllEquipInWarSideFirst(self.equipType)
    else
    	if equip.equip ~= 0 then
	   		local role = CardRoleManager:getRoleById(equip.equip)
	   		self.equipList = role.equipment:allAsArray()
	   	else
	   		self.equipList = EquipmentManager:GetAllEquipInWarSideFirst(self.equipType)
	   	end
    end
end


function SmithyBaseLayer:removeEvents()
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_REFINING_RESULT,self.EquipmentResultCallBack)
    TFDirector:removeMEGlobalListener(BagManager.GEM_BULID_RESULT,self.EquipmentResultCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.EquipmentResultCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.EquipmentResultCallBack)

    TFDirector:removeMEGlobalListener(EquipmentManager.DEL_EQUIP,self.EquipmentDelCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    
	for i=1,SmithyBaseLayer.kTabNumber do
		self.btn_tab[i]:removeMEListener(TFWIDGET_CLICK)
	end

	self.btn_left:removeMEListener(TFWIDGET_CLICK)
	self.btn_right:removeMEListener(TFWIDGET_CLICK)

	TFDirector:removeMEGlobalListener(MainPlayer.RE_CONNECT_COMPLETE,self.relogonCallback)

    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    --适配缓存机制，移除所有已经打开过的tab页面的事件
    for i = 1,#layerDeclear do
		if self.operationLayer[i] then
				self.operationLayer[i]:removeEvents()
			-- if self.selectedTab == i then
			-- else
			-- 	self.operationLayer[i]:removeEvents()
			-- end
		end
	end

	self.firstShow = true
end

--[[
	获取下一个装备
	@param instanceId 装备实例ID，gmId
	@return 下一个装备实例,是否还有再上一个,是否还有再下一个
]]
function SmithyBaseLayer:getNextEquip(instanceId)
	if not self.equipList then
		return
	end

	local length = self.equipList:length()
	if length < 2 then
		return
	end

	local index = 0
	for tmp in self.equipList:iterator() do
		index = index + 1
		if tmp and tmp.gmId == instanceId then
			break
		end
	end

	local nextIndex = index + 1

	if nextIndex <= length then
		return self.equipList:objectAt(nextIndex),nextIndex > 1 , length > nextIndex
	else
		return nil,nextIndex > 1 , length > nextIndex
	end
end

function SmithyBaseLayer:setEquipList(list)
	self.equipList = list
end

--[[
是否有上一个或者下一个装备
@param instanceId 装备实例ID，gmId
@return 是否还有再上一个,是否还有再下一个
]]
function SmithyBaseLayer:hasPrevOrNext(instanceId)
	if not self.equipList then
		return
	end

	local length = self.equipList:length()
	if length < 2 then
		return
	end

	local index = 0
	for tmp in self.equipList:iterator() do
		index = index + 1
		if tmp and tmp.gmId == instanceId then
			break
		end
	end

	return index > 1 , length > index
end

--[[
	获取上一个装备
	@param instanceId 装备实例ID，gmId
	@return 上一个装备实例,是否还有再上一个,是否还有再下一个
]]
function SmithyBaseLayer:getPrevEquip(instanceId)
	if not self.equipList then
		return
	end

	local length = self.equipList:length()
	if length < 2 then
		return
	end

	local index = 0
	for tmp in self.equipList:iterator() do
		index = index + 1
		if tmp and tmp.gmId == instanceId then
			break
		end
	end

	local prevIndex = index - 1

	if prevIndex >= 1 then
		return self.equipList:objectAt(prevIndex),prevIndex > 1 , length > prevIndex
	else
		return nil,prevIndex > 1 , length > prevIndex
	end
end

return SmithyBaseLayer;
