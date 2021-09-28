require("game/map/map_local_view")
require("game/map/map_global_view")

MapView = MapView or BaseClass(BaseView)

function MapView:__init()
	self.ui_config = {"uis/views/map_prefab","MapView"}
	self.play_audio = true
	self.full_screen = true
end

function MapView:__delete()

end

function MapView:LoadCallBack()

	self.gold = self:FindVariable("gold")
	self.bind_gold = self:FindVariable("bind_gold")

	local local_content = self:FindObj("LocalMap")
	self.local_view = MapLocalView.New(local_content)

	local global_content = self:FindObj("GlobalMap")
	self.global_view = MapGlobalView.New(global_content)

	self.toggle_global = self:FindObj("ToggleGlobal")
	self.toggle_local = self:FindObj("ToggleLocal")

	self.toggle_global.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectGlobalTab,self))

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OnOpenLocal",
		BindTool.Bind(self.OnOpenLocal, self))
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))

	--监听系统事件
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

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
	if self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
	if self.money_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
		self.money_change_callback = nil
	end

	-- 清理变量和对象
	self.toggle_global = nil
	self.toggle_local = nil
	self.gold = nil
	self.bind_gold = nil
	self.money_change_callback = nil
end

function MapView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function MapView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end


function MapView:OpenCallBack()
	if self.local_view then
		self.local_view:ClearWalkPath()
		self.local_view:OpenCallBack()
	end
	if self.toggle_global.toggle.isOn then
		self.global_view:Flush()
	end

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])


end

function MapView:HandleClose()
	self:Close()
end

function MapView:OnSelectGlobalTab()
	self.global_view:Flush()
end

function MapView:OnSceneLoadingQuite()
	self.toggle_local.toggle.isOn = true
	self.toggle_global.toggle.isOn = false
	if self.local_view then
		self.local_view:OpenCallBack()
	end
end

function MapView:OnOpenLocal()
	if self.local_view then
		self.local_view:OpenCallBack()
	end
end

function MapView:FlushLocalMap()
	if self.local_view then
		self.local_view:Flush()
	end
end