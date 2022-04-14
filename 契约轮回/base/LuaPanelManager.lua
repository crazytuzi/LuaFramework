--
-- Author: LaoY
-- Date: 2018-07-02 10:10:43
-- 界面管理器

LuaPanelManager = LuaPanelManager or class("LuaPanelManager",BaseManager)
local LuaPanelManager = LuaPanelManager

LuaPanelManager.Instance = nil
function LuaPanelManager:ctor()
	LuaPanelManager.Instance = self
	self.index = 0
	self.single_panel_list = {}
	self.panel_index_list = {}

	self.panel_list = {}
	self.open_index_list = {}

	self.camera_material = {}

	self.open_panel_his_list = {}
end

function LuaPanelManager:dctor()
end

function LuaPanelManager:Reset()
	local close_panel_list = {}
	for layer,list in pairs(self.panel_list) do
		for panel,index in pairs(list) do
			if panel.logout_close then
				if panel.is_exist_always then
					panel.is_exist_always = false
				end
				close_panel_list[#close_panel_list+1] = panel
			end
		end
	end

	for k,panel in pairs(close_panel_list) do
		panel:Close()
	end
end

function LuaPanelManager:GetInstance()
	if not LuaPanelManager.Instance then
		LuaPanelManager()
	end
	return LuaPanelManager.Instance
end

-- 获取界面实例，用的时候得判断实例是否为空
-- cls 界面类 ps:LoginPanel
function LuaPanelManager:GetPanel(cls)
	if not cls or not cls.__cname then
		return
	end
	return self.single_panel_list[cls.__cname]
end

function LuaPanelManager:GetPanelByName(cname)
	return self.single_panel_list[cname]
end

-- 获取界面实例，如果不存在就创建
-- cls 界面类 ps:LoginPanel
function LuaPanelManager:GetPanelOrCreate(cls,...)
	if not cls or not cls.__cname then
		return
	end
	local panel = self.single_panel_list[cls.__cname]
	if not panel then
		panel = cls(...)
	end
	return panel
end

-- 关闭界面 单例界面才处理
function LuaPanelManager:ClosePanel(cls)
	local panel = self:GetPanel(cls)
	if panel then
		panel:Close()
	end
end

function LuaPanelManager:OpenPanel(cls,...)
	self:GetPanelOrCreate(cls):Open(...)
end

function LuaPanelManager:IsOpenSinglePanel(cls)
	return self.single_panel_list[cls.__cname] ~= nil
end

function LuaPanelManager:OpenSinglePanel(panel)
	if not panel or not panel.__cname or not panel.is_singleton then
		return
	end
	if self:IsOpenSinglePanel(panel) then
		return
	end
	self.single_panel_list[panel.__cname] = panel	
end

function LuaPanelManager:CloseSinglePanel(panel)
	if not panel or not panel.__cname or panel.is_exist_always then
		return
	end
	self.single_panel_list[panel.__cname] = nil
end

-- basepanel 调用
function LuaPanelManager:ToOpenPanel(panel)
	if not panel then
		return
	end

	if AppConfig.Debug then
		self.open_panel_his_list[#self.open_panel_his_list+1] = panel.__cname
	end

	GlobalEvent:Brocast(EventName.OpenPanel,panel.__cname,panel.layer,panel.panel_type)
	self:SortPanelIndex(panel.layer)
	self:OpenSinglePanel(panel)
	self.panel_list[panel.layer] = self.panel_list[panel.layer] or {}
	local index = table.nums(self.panel_list[panel.layer]) + 1
	self.panel_list[panel.layer][panel] = index
	if panel.layer == LayerManager.LayerNameList.UI then
		if self:IsHideMainUI() then
			LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,false)
			local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
			if lv <= 150 then
				TaskModel:GetInstance():OpenUIChangeBitState(true)
			end
		end

		if self:IsHideModelAndEffect() then
			SceneManager:GetInstance():SetObjectsBitState(true,SceneManager.SceneObjectVisibleState.OpenUI)
		end
	end
end
-- basepanel 调用
function LuaPanelManager:ToClosePanel(panel)
	if not panel then
		return
	end
	
	self:CloseSinglePanel(panel)
	self:ReleaseCameraMaterial(panel)

	self.panel_list[panel.layer] = self.panel_list[panel.layer] or {}
	self.panel_list[panel.layer][panel] = nil
	self:SortTableIndex()
	self:SortPanelIndex(panel.layer)

	if panel.layer == LayerManager.LayerNameList.UI then
		self:SortUIPanel()
		if not self:IsHideMainUI() then
			LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,true)
			TaskModel:GetInstance():OpenUIChangeBitState(false)
		end
		if not self:IsHideModelAndEffect() then
			SceneManager:GetInstance():SetObjectsBitState(false,SceneManager.SceneObjectVisibleState.OpenUI)
		end
	end
	
	GlobalEvent:Brocast(EventName.ClosePanel,panel.__cname,panel.layer,panel.panel_type)
end

function LuaPanelManager:SortPanelIndex(layer)
	if not self.panel_list[layer] then
		return
	end
	local t = {}
	for panel,index in pairs(self.panel_list[layer]) do
		t[#t+1] = {panel = panel,index = index}
	end
	local function SortFunc(a,b)
		return a.index < b.index
	end
	table.sort(t,SortFunc)
	local len = #t
	for i=1,len do
		local info = t[i]
		local panel = info.panel
		self.panel_list[layer][panel] = i
		local z = self:GetPanelPositionZ(panel)
		panel:ResetOrderIndex()
	end
end

function LuaPanelManager:SetPanelIndex(panel,index)
	local layer = panel.layer
	local panel_list = self.panel_list[layer]
	if not panel_list then
		return
	end
	local oldIndex = self.panel_list[layer][panel]
	index = index or 1
	for panel,index in pairs(panel_list) do
		t[index] = {panel = panel,index = index}
	end
	local info
	if oldIndex then
		info = table.remove(t,oldIndex)
	else
		info = {panel = panel,index = index}
	end
	table.insert(t,index)
	for i=1,len do
		local info = t[i]
		local panel = info.panel
		self.panel_list[layer][panel] = i
		local z = self:GetPanelPositionZ(panel)
		panel:ResetOrderIndex()
	end
end

function LuaPanelManager:SortUIPanel()
	local last_panel
	local last_index = -1
	local min_panel_type = 10
	local ui_list = self:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	for _panel,_index in pairs(ui_list) do
		if last_panel and last_panel.is_hide_other_panel then
			if _panel.is_hide_other_panel and _index > last_index then
				last_index = _index
				last_panel = _panel
				min_panel_type = _panel.panel_type
			end
		elseif _panel.panel_type < min_panel_type or (_panel.panel_type == min_panel_type and _index > last_index) or 
		_panel.is_hide_other_panel then
			if _panel.isVisible ~= false then
				last_index = _index
				last_panel = _panel
				min_panel_type = _panel.panel_type
			end
		end
	end
	if last_panel then
		for _panel,_index in pairs(ui_list) do
			local visible = true
			if last_panel.is_hide_other_panel then
				visible = _index >= last_index
			elseif min_panel_type == 1 or min_panel_type == 2 then
				visible = _index >= last_index
			end
			if _panel.isVisible ~= false then
				_panel:SetVisibleInside(visible)
			end
			local z = lua_panelMgr:GetPanelPositionZ(_panel)
			_panel:ResetOrderIndex()
		end
	else
		for _panel,_index in pairs(ui_list) do
			if _panel.isVisible ~= false then
				_panel:SetVisibleInside(true)
			end
			local z = lua_panelMgr:GetPanelPositionZ(_panel)
			_panel:ResetOrderIndex()
		end
	end
end

function LuaPanelManager:GetUIPanelTypeNumber(panel_type,isEqual)
	local num = 0
	local ui_list = self:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	for _panel,index in pairs(ui_list) do
		if isEqual then
			if _panel.panel_type == panel_type then
				num = num + 1
			end
		else
			if _panel.panel_type and _panel.panel_type <= panel_type then
				num = num + 1
			end
		end
	end
	return num
end

function LuaPanelManager:IsHideMainUI()
	local panel_type_1_num = self:GetUIPanelTypeNumber(1)
	local panel_type_2_num = self:GetUIPanelTypeNumber(3)
	local panel_type_3_num = self:GetUIPanelTypeNumber(7,true)
	return panel_type_1_num + panel_type_2_num + panel_type_3_num > 0
end

function LuaPanelManager:IsHideModelAndEffect()
	local ui_list = self:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	for _panel,index in pairs(ui_list) do
		if _panel.is_hide_model_effect then
			return true
		end
	end
	return false
end

function LuaPanelManager:SetBottomLayerVisible(flag)
	LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,flag)
end

function LuaPanelManager:GetPanelPositionZ(panel)
	if panel.layer == LayerManager.LayerNameList.Bottom or 
	panel.layer == LayerManager.LayerNameList.Top then
		return 0
	end
	-- local ui_list = self:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	local index = self:GetPanelInLayerIndex(LayerManager.LayerNameList.UI)
	if not index then
		return 0
	end
	-- index = index - self:GetLayerPanelNumber(LayerManager.LayerNameList.Bottom)
	index = index
	-- return (index - 1) * 10
	return 0
end

function LuaPanelManager:GetPanelOrderIndex(panel)
	local index = self:GetPanelInLayerIndex(panel.layer,panel)
	if not index or not LayerManager.LayerOrderInLayer[panel.layer] then
		return 0
	end
	return LayerManager.LayerOrderInLayer[panel.layer] + index * 20
end

function LuaPanelManager:GetPanelInLayerIndex(layer,panel)
	local ui_list = self:GetPanelListByLayer(layer)
	return ui_list[panel]
end

function LuaPanelManager:GetPanelListByLayer(layer_name)
	self.panel_list[layer_name] = self.panel_list[layer_name] or {}
	return self.panel_list[layer_name]
end

function LuaPanelManager:GetLayerPanelNumber(layer_name)
	local count = 0
	local list = self:GetPanelListByLayer(layer_name)
	for _panel,_index in pairs(list) do
		if _panel.layer == layer_name then
			count = count + 1
		end
	end
	return count
end

function LuaPanelManager:SortTableIndex()
	local t = {}
	local index = 0
	local ui_list = self:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	for k,v in table.pairByValue(ui_list) do
		index = index + 1
		t[k] = index
	end
	self.panel_index_list = t
end

--[[
	@author LaoY
	@des	界面底图显示摄像机高斯模糊
--]]
function LuaPanelManager:CameraBlur(cls,transform)
	if cls and not self.camera_material[cls] then
		self.camera_material[cls] = transform
		UtilManager.CameraBlur(transform)
	end
end

function LuaPanelManager:ReleaseCameraMaterial(cls)
	local last_count = table.nums(self.camera_material)
	self.camera_material[cls] = nil
	if last_count > 0 and table.isempty(self.camera_material) then
		UtilManager.ReleaseCameraMaterial()
	end
end

function LuaPanelManager:DebugList()
	if not AppConfig.Debug then
		return
	end

	DebugLog("")
	DebugLog("")
	DebugLog("-------LuaPanelManager:DebugList()-----------")
	local len = #self.open_panel_his_list
	for i=1,len do
		DebugLog(i,self.open_panel_his_list[i]) 
	end
	DebugLog("")
	DebugLog("")
	
end