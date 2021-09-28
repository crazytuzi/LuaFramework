module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_steedAutoRefineSet = i3k_class("wnd_steedAutoRefineSet", ui.wnd_base)

local ZQXL2 = "ui/widgets/zqxlt2"
local ZQXL4 = "ui/widgets/zqxlt4"
local ZQXL5 = "ui/widgets/zqxlt5"  

function wnd_steedAutoRefineSet:ctor()
	self._steedId = 0
	self._sortRefineCfg = nil
	self._powerFalg = false
	self._lockFlag = false
	self._properSet = {}
	self._rankText = {[3] = i3k_get_string(18158), [4] = i3k_get_string(18159), [5] = i3k_get_string(18160)}
	self._reflectInfo = {}
	self._curIndex = 0
end

function wnd_steedAutoRefineSet:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	widget.preview:onClick(self, self.onPreviewUI)
	widget.sureBtn:onClick(self, self.onSaveUI)
	widget.powerYbt:onClick(self, self.refreshPowerFlag, true)
	widget.powerNbt:onClick(self, self.refreshPowerFlag, false)
	widget.lockYbt:onClick(self, self.refreshLockFlag, true)
	widget.lockNbt:onClick(self, self.refreshLockFlag, false)
	widget.mask:onClick(self, function()
		widget.scroll2_root:hide()
	end)
	widget.allquality:onClick(self, self.onAllSelectQualityBt)
	widget.allselect:onClick(self, self.onAllSelectBt)
end

function wnd_steedAutoRefineSet:refresh(steedId, sortRefineCfg)
	self._steedId = steedId
	self._sortRefineCfg = sortRefineCfg
	local user_cfg = g_i3k_game_context:GetUserCfg()
	self._properSet = g_i3k_db.i3k_db_auto_refhine_user_cfg(steedId)
	self:refrectPropertyInfo()
	self:refreshRefineOhterFlag(user_cfg:GetSteedAutoRefinePowerSave())
	self:initDes()
	self:refreshRefineNumScroll()
end

function wnd_steedAutoRefineSet:refrectPropertyInfo()
	for i, v in ipairs(self._sortRefineCfg) do
		local item = {}
		
		for k, j in ipairs(v) do
			local value = self._properSet[i] and self._properSet[i][k] or 0
			
			if value == 0 then
				item[k] = {select = false, value = g_RANK_VALUE_BLUE}
			else
				item[k] = {select = true, value = value}
			end
		end
		
		table.insert(self._reflectInfo, item)
	end
end

function wnd_steedAutoRefineSet:refreshRefineOhterFlag(cfg)
	self:refreshPowerFlag(nil, cfg[1] == 1)
	self:refreshLockFlag(nil, cfg[2] == 1)
end

function wnd_steedAutoRefineSet:refreshPowerFlag(sender, flag)
	local widget = self._layout.vars
	self._powerFalg = flag
	widget.py:setVisible(flag)
	widget.pn:setVisible(not flag)
end

function wnd_steedAutoRefineSet:refreshLockFlag(sender, flag)
	local widget = self._layout.vars
	self._lockFlag = flag
	widget.ly:setVisible(flag)
	widget.ln:setVisible(not flag)
end

function wnd_steedAutoRefineSet:onPreviewUI()
	g_i3k_logic:OpenAutoRefhineSetPreviewUI(self._sortRefineCfg, self._properSet)
end

function wnd_steedAutoRefineSet:onSaveUI()
	local flag = false
	local unSet = {}
	
	for i = 1, #self._sortRefineCfg do
		local proset = self._properSet[i]
		
		if not proset then
			table.insert(unSet, i)
			flag = true
		else
			local sum = 0
		
			for _, j in ipairs(proset) do
				sum = sum + j
			end
		
			if sum == 0 then
				flag = true
				table.insert(unSet, i)
			end
		end	
	end
		
	if flag then
		local str = table.concat(unSet, ",") 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18161, str))
		return
	end

	local user_cfg = g_i3k_game_context:GetUserCfg()
	local power = {0, 0}
	power[1] = self._powerFalg and 1 or 0
	power[2] = self._lockFlag and 1 or 0
	user_cfg:SetSteedAutoRefinePowerSave(power)
	local propertySet = user_cfg:GetSteedAutoRefine()
	local preview = g_i3k_db.i3k_db_auto_refhine_data_to_user_cfg(self._properSet)
	propertySet[self._steedId] = preview
	user_cfg:SetSteedAutoRefine(propertySet)
	self:onCloseUI()
end

function wnd_steedAutoRefineSet:initDes()
	local widget = self._layout.vars
	widget.des:setText(i3k_get_string(18155))
	widget.powerDes:setText(i3k_get_string(18156))
	widget.lockDes:setText(i3k_get_string(18157))
	self:initAllTxt()
end

function wnd_steedAutoRefineSet:initAllTxt()
	local widget = self._layout.vars
	widget.allTxt:setText(self._rankText[g_RANK_VALUE_BLUE]) 
	local tb = g_i3k_db.i3k_db_get_color_outColor(g_RANK_VALUE_BLUE)	
	widget.allTxt:setTextColor(tb[1])
	--widget.allTxt:enableOutline(tb[2])
end

function wnd_steedAutoRefineSet:refreshRefineNumScroll()
	local widgets = self._layout.vars
	
	for i, v in ipairs(self._sortRefineCfg) do
		local layer = require(ZQXL2)()
		local widget = layer.vars	
		widget.txt:setText(i3k_get_string(18164, i))
		widget.clickBt:onClick(self, self.refreshRefinePorpertyScroll, {index = i, value = v, node = widget})
		widgets.scroll:addItem(layer)
	end
	
	self:refreshRefinePorpertyScroll(nil, {index = 1, value = self._sortRefineCfg[1]})
end

function wnd_steedAutoRefineSet:refreshRefineNumScrollItemBtState(index)
	local widgets = self._layout.vars
	local childs = widgets.scroll:getAllChildren()
	
	for i, v in ipairs(childs) do
		if i == index then
			v.vars.clickBt:stateToPressed()
		else
			v.vars.clickBt:stateToNormal() 
		end
	end
end

function wnd_steedAutoRefineSet:refreshRefinePorpertyScroll(sender, info)
	if self._curIndex == info.index then
		return
	end
	
	self._curIndex = info.index
	local widgets = self._layout.vars
	widgets.scollList:removeAllChildren()
	self:refreshAllSlectUI(false)
	self:initAllTxt()
	self:refreshRefineNumScrollItemBtState(info.index)

	for i, v in ipairs(info.value) do
		local layer = require(ZQXL4)()
		local widget = layer.vars	
		local attrName = i3k_db_prop_id[v.propId].desc
		widget.name:setText(attrName)
		local rank = self._properSet[info.index] and self._properSet[info.index][i] or 0
		widget.selectImg:setVisible(rank ~= 0)
		local str = self._rankText[rank] or self._rankText[g_RANK_VALUE_BLUE]
		local tb = {}
		
		if rank ~= 0 then
			widget.quality:setText(str)
			tb = g_i3k_db.i3k_db_get_color_outColor(rank)
			widget.list:enableWithChildren()
		else
			widget.quality:setText(str)
			tb = g_i3k_db.i3k_db_get_color_outColor(g_RANK_VALUE_BLUE)
			widget.list:disableWithChildren()
		end
		
		widget.quality:setTextColor(tb[1])
		--widget.quality:enableOutline(tb[2])
		widget.select:onClick(self, self.onProPertySelectBt, {index = i, node = widget})
		widget.list:onClick(self, self.onPropertyListBt, {index = i, node = widget})
		widgets.scollList:addItem(layer)
	end
end

function wnd_steedAutoRefineSet:checkReflectInfo(infoIndex)
	local fun = function(propertys, index)
		local pro = propertys or {}
		
		for i = #pro + 1, index do
			pro[i] = {select = false, value = g_RANK_VALUE_BLUE}
		end
		
		return pro
	end
	
	if not self._reflectInfo[self._curIndex] then -- 如果开第六个属性槽
		self._reflectInfo[self._curIndex] = fun(nil, infoIndex)
	end
	
	if not self._reflectInfo[self._curIndex][infoIndex] then
		self._reflectInfo[self._curIndex] = fun(self._reflectInfo[self._curIndex], infoIndex) --如果加了一个属性并隔着点击 
	end
end

function wnd_steedAutoRefineSet:onProPertySelectBt(sender, info)
	local widget = info.node
	local value = not widget.selectImg:isVisible()
	widget.selectImg:setVisible(value)
	
	if value then
		widget.list:enableWithChildren()
	else
		widget.list:disableWithChildren()
	end	
	
	--self:checkReflectInfo(info.index)
	self._reflectInfo[self._curIndex][info.index].select = value
	self:refreshProperty()
end

function wnd_steedAutoRefineSet:onPropertyListBt(sender, info)
	self:setSelectPanalPos(sender, info)
end

function wnd_steedAutoRefineSet:setSelectPanalPos(sender, info)
	local widgets = self._layout.vars
	widgets.scroll2_root:show()
	local itemSize = sender:getContentSize()
	local sectPos = sender:getPosition()
	local btnPos = sender:getParent():convertToWorldSpace(sectPos)
	widgets.scroll2_root:setPosition(btnPos.x, btnPos.y - itemSize.height / 2)
	widgets.scroll2:removeAllChildren()
	
	for i = g_RANK_VALUE_BLUE, g_RANK_VALUE_ORANGE do
		local layer = require(ZQXL5)()
		local wid = layer.vars
		wid.txt:setText(self._rankText[i])
		local tb = g_i3k_db.i3k_db_get_color_outColor(i)	
		wid.txt:setTextColor(tb[1])
		--wid.txt:enableOutline(tb[2])
		wid.btn:onClick(self, self.onProPertyChoiceBt, {handle = info, quality = i})
		widgets.scroll2:addItem(layer)
	end
end

function wnd_steedAutoRefineSet:onProPertyChoiceBt(sender, qualityInfo)
	local wid = self._layout.vars
	local info = qualityInfo.handle
	local rank = qualityInfo.quality
	
	if info then
		self._reflectInfo[self._curIndex][info.index].value = rank
		local widget = info.node
		widget.quality:setText(self._rankText[rank])
		local tb = g_i3k_db.i3k_db_get_color_outColor(rank)	
		widget.quality:setTextColor(tb[1])
		--widget.quality:enableOutline(tb[2])
	else
		local childs = wid.scollList:getAllChildren()
		wid.allTxt:setText(self._rankText[rank])
		local tb = g_i3k_db.i3k_db_get_color_outColor(rank)
		wid.allTxt:setTextColor(tb[1])
		--wid.allTxt:enableOutline(tb[2])	
		
		for _, v in ipairs(childs) do
			local wid = v.vars	
			wid.quality:setText(self._rankText[rank])
			wid.quality:setTextColor(tb[1])
			--wid.quality:enableOutline(tb[2])	
		end
		
		local reflect = self._reflectInfo[self._curIndex]
		
		for _, v in ipairs(reflect) do
			v.value = rank
		end
	end
	
	wid.scroll2_root:hide()
	self:refreshProperty()
end

function wnd_steedAutoRefineSet:onAllSelectQualityBt(sender)
	self:setSelectPanalPos(sender)
end

function wnd_steedAutoRefineSet:refreshProperty()
	for i, v in ipairs(self._reflectInfo) do
		if not self._properSet[i] then
			self._properSet[i] = {}
		end
		
		for k, j in ipairs(v) do
			if j.select then
				self._properSet[i][k] = j.value
			else
				self._properSet[i][k] = 0
			end
		end
	end
end

function wnd_steedAutoRefineSet:onAllSelectBt()
	local widgets = self._layout.vars
	local value = not widgets.allselectImg:isVisible()
	self:refreshAllSlectUI(value)
	local childs = widgets.scollList:getAllChildren()
	
	for _, v in ipairs(childs) do
		local wid = v.vars	
		wid.selectImg:setVisible(value)
	
		if value then
			wid.list:enableWithChildren()
		else
			wid.list:disableWithChildren()
		end	
	end
	
	--self:checkReflectInfo(#self._sortRefineCfg[self._curIndex])
	
	local reflect = self._reflectInfo[self._curIndex]
		
	for _, v in ipairs(reflect) do
		v.select = value
	end
	
	self:refreshProperty()
end

function wnd_steedAutoRefineSet:refreshAllSlectUI(value)
	local widgets = self._layout.vars
	
	if value then
		widgets.allselectImg:show()
		widgets.allquality:enableWithChildren()
	else
		widgets.allselectImg:hide()
		widgets.allquality:disableWithChildren()
	end
end

function wnd_create(layout)
	local wnd = wnd_steedAutoRefineSet.new();
	wnd:create(layout);
	return wnd;
end
