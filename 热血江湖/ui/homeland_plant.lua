-- zengqingfeng
-- 2018/5/12
--eUIID_HomelandPlant --家园种植界面
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local itemPath = "ui/widgets/jiayuanzzt"
local cropTypes = {1, 2, 3} -- 界面上的作物id
-------------------------------------------------------
wnd_homeland_plant = i3k_class("homeland_plant", ui.wnd_base)

function wnd_homeland_plant:ctor()
	self._tid = g_TYPE_PLANT_FLOWER
	self._groundType = 0
	self._groundIndex = 0  -- 选中的地块的index
	self._groundLevel = 0
	self._cropCfgs = {} -- 已经分类的作物
	self._tabM = nil
end

function wnd_homeland_plant:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	
	local listener = {
		preTabChanged = nil, 
		onTabChanged = self.onTabChanged,
	}
	local selectTagbtn = {widgets.all_btn, widgets.flower_btn, widgets.tree_btn}
	self._tabM = i3k_ui_mgr:createTabManager(selectTagbtn, self, listener)
	widgets.tip_name:setText("")
	widgets.level:setText("")
	widgets.needTime:setText("")
	widgets.produce:setText("")
	
	self._item_scroll = widgets.item_scroll
end

function wnd_homeland_plant:onShow()
end

function wnd_homeland_plant:onHide()

end 

function wnd_homeland_plant:updateCostItem()
	self:refresh(self._groundType, self._groundIndex, self._groundLevel)
end 

function wnd_homeland_plant:refresh(groundType, groundIndex, groundLevel)
	self._groundType = groundType -- 地块类型
	self._groundIndex = groundIndex -- 地块索引
	self._groundLevel = groundLevel -- 地块等级
	self._tabM:onClick(groundType)
end 

function wnd_homeland_plant:onTabChanged(sender, index)
	self._tid = index
	self:setStoreListInfo()
end 

function wnd_homeland_plant:setStoreListInfo()
	local item_scroll = self._item_scroll
	local item_info = self:getCropInfo(cropTypes[self._tid])
	
	item_scroll:removeAllChildren()
	local allBars = item_scroll:addChildWithCount(itemPath, 5, #item_info)
	for index, bar in ipairs(allBars) do
		self:setItemDetail(bar, item_info[index], index)	
	end 
	local child = item_scroll:getChildAtIndex(1)
	if child then 
		self:onSelectCropItem(nil, child)
	end
end

function wnd_homeland_plant:setItemDetail(bar, info, index)
	if not info then 
		return false
	end

	local id = info.cropCfg.needItemID
	local isLocked = g_i3k_game_context:homelandCheckCropIsLock(self._groundLevel, info.cropCfg)
	local costItems = {[info.cropCfg.needItemID] = info.cropCfg.needItemCount}
	info.costItems = costItems
	bar.info = info 
	local widgets = bar.vars
	widgets.bt:onClick(self, self.onSelectCropItem, bar)
	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id == 0 and 106 or id))
	widgets.item_icon:setImage(id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
	widgets.suo:setVisible(isLocked)
	widgets.item_count:setText(info.count)
	if isLocked or not g_i3k_game_context:checkNeedCommonItems(info.costItems) then 
		widgets.item_icon:disable()
	else 
		widgets.item_icon:enable()
	end
end 

-- 获取种子的信息（数量，种子配置表，植物配置表）并且按页签分类缓存到本UI中
function wnd_homeland_plant:getCropInfo(plantType)
	if not self._cropCfgs[plantType] then 
		for index, cropCfg in ipairs(i3k_db_home_land_corp) do
			if not self._cropCfgs[cropCfg.corpType] then 
				self._cropCfgs[cropCfg.corpType] = {}
			end
			local count = g_i3k_game_context:GetBagMiscellaneousCount(cropCfg.needItemID) + g_i3k_game_context:GetBagMiscellaneousCount(-cropCfg.needItemID)
			local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(cropCfg.needItemID)
			table.insert(self._cropCfgs[cropCfg.corpType], {itemCfg = itemCfg, cropCfg = cropCfg, count = count, plantId = index})
		end 
	end 
	
	return self._cropCfgs[plantType]
end 

-- 点击种子item时更新UI右边的种子详情
function wnd_homeland_plant:onSelectCropItem(sender, item)
	local info = item.info 
	if sender and (g_i3k_game_context:homelandCheckCropIsLock(self._groundLevel, info.cropCfg) or not g_i3k_game_context:checkNeedCommonItems(info.costItems)) then 
		self:_onItemTips(sender, info.cropCfg.needItemID)
	end 
	self:setCellIsSelectHide()
	if item and item.vars then 
		item.vars.is_select:show()
	end 
	
	local widgets = self._layout.vars
	local id = info.cropCfg.needItemID
	widgets.tip_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.level:setText(info.cropCfg.plantLvlLimit)
	
	local needTime = info.cropCfg.seedlingTime + info.cropCfg.strongTime -- 这个时间不知道是计算还是之后的
	local harvestTimes = i3k_db_home_land_base.plantCfg.harvestTimes
	local minHarvest = info.cropCfg.harvestMinNum
	local maxHarvest = info.cropCfg.harvestMaxNum
	needTime = i3k_get_time_show_text_simple(needTime)
	widgets.needTime:setText(needTime)
	widgets.produce:setText("("..minHarvest.."~"..maxHarvest..")".."x"..harvestTimes)
	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id == 0 and 106 or id))
	widgets.curIcon:setImage(id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgets.plant_btn:onClick(self, self.plantCrop, info)
end 

-- 种植该种子，最好弹出二次确认，此前先做可行性判断
function wnd_homeland_plant:plantCrop(sender, info)
	local costItems = self:checkCanPlant(info)
	if costItems then 
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5067), function(flag)
			if flag then 
				i3k_sbean.homeland_plant(cropTypes[self._tid], self._groundIndex, info.plantId, costItems) --参数有点问题
				self:onCloseUI()
			end 
		end)
	end
end 

function wnd_homeland_plant:checkCanPlant(info) -- 能否种植作物的判断
	local cropCfg = info.cropCfg
	if self._groundIndex and self._tid and info and cropCfg then 
		if g_i3k_game_context:homelandCheckCropIsLock(self._groundLevel, cropCfg, true) then 
			
		elseif self._groundType ~= cropTypes[self._tid] then 
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5068))
		elseif not g_i3k_game_context:GetHomeLandCurEquipCanPlant() then -- 锄头的判断
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5069))
			self:openLinkTips()
		else
			if g_i3k_game_context:checkNeedCommonItems(info.costItems, true) then 
				return info.costItems
			end 
		end 
	else 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5070))	
	end 
	return false
end 

function wnd_homeland_plant:setCellIsSelectHide()
	for i, e in ipairs(self._item_scroll:getAllChildren()) do
		e.vars.is_select:hide()
	end
end

function wnd_homeland_plant:_onItemTips(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_ItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ItemInfo, id)
end

function wnd_homeland_plant:openLinkTips()
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5071), function(flag)
		if flag then 
			g_i3k_logic:OpenHomeLandEquipUI()
			self:onCloseUI()
		end 
	end)
end 

function wnd_create(layout,...)
	local wnd = wnd_homeland_plant.new()
	wnd:create(layout,...)
	return wnd
end
