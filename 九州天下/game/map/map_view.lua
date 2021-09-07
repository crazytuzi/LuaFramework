require("game/map/map_local_view")
require("game/map/map_global_view")
require("game/map/map_country_view")

MapView = MapView or BaseClass(BaseView)

function MapView:__init()
	self.ui_config = {"uis/views/map","MapView"}
	self.play_audio = true
	self:SetMaskBg()
end

function MapView:__delete()

end

function MapView:LoadCallBack()
	local local_content = self:FindObj("LocalMap")
	self.local_view = MapLocalView.New(local_content)

	local global_content = self:FindObj("GlobalMap")
	self.global_view = MapGlobalView.New(global_content)

	local country_content = self:FindObj("CountryMap")
	self.country_view = MapCountryView.New(country_content)

	self.toggle_global = self:FindObj("ToggleGlobal")
	self.toggle_local = self:FindObj("ToggleLocal")
	self.toggle_country = self:FindObj("ToggleCountry")

	self.world_name = self:FindVariable("WorldName")

	self.toggle_global.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectGlobalTab,self))
	self.toggle_country.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectCountryTab,self))

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OnOpenLocal",
		BindTool.Bind(self.OnOpenLocal, self))
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))

	self:GetMapName()
end

function MapView:ReleaseCallBack()
	if self.local_view then
		self.local_view:DeleteMe()
		self.local_view = nil
	end
	if self.global_view then
		self.global_view:DeleteMe()
		self.global_view = nil
	end
	if self.country_view then
		self.country_view:DeleteMe()
		self.country_view = nil
	end
	if self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end

	-- 清理变量和对象
	self.toggle_global = nil
	self.toggle_local = nil
	self.toggle_country = nil
	self.world_name = nil
end

function MapView:OpenCallBack()
	if self.local_view then
		self.local_view:ClearWalkPath()
		self.local_view:OpenCallBack()
	end
	if self.toggle_global.toggle.isOn then
		self.global_view:Flush()
	elseif self.toggle_country.toggle.isOn then
		self.country_view:Flush()
	end
end

function MapView:HandleClose()
	self:Close()
end

function MapView:OnSelectGlobalTab()
	if self.toggle_global.toggle.isOn then
		self.global_view:Flush()
	end
end

function MapView:OnSelectCountryTab()
	if self.toggle_country.toggle.isOn then
		self.country_view:Flush()
	end
end

function MapView:OnSceneLoadingQuite()
	self.toggle_local.toggle.isOn = true
	self.toggle_global.toggle.isOn = false
	self.toggle_country.toggle.isOn = false
	if self.local_view then
		self.local_view:OpenCallBack()
	end
	self:GetMapName()
end

function MapView:OnOpenLocal()
	if self.local_view then
		self.local_view:OpenCallBack()
	end
end

function MapView:OnOpenCountry()
	self.toggle_local.toggle.isOn = false
	self.toggle_global.toggle.isOn = false
	self.toggle_country.toggle.isOn = true
end

function MapView:GetMapName()
	local scene_id = Scene.Instance:GetSceneId()
	local key = MapData.MapNameList[scene_id]
	if scene_id ~= nil and key ~= nil then
		self.world_name:SetAsset(ResPath.GetMapName(key))
	end
end