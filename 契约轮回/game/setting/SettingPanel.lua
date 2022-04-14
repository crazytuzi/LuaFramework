SettingPanel = SettingPanel or class("SettingPanel",WindowPanel)
local SettingPanel = SettingPanel

function SettingPanel:ctor()
	self.abName = "autoplay"
	self.assetName = "SettingPanel"
	self.layer = "UI"

	self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 2							--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = true		--是否显示侧边栏
	if self.show_sidebar then		-- 侧边栏配置
		self.sidebar_data = {
			{text = ConfigLanguage.Setting.Set,id = 1,img_title = "autoplay:setting_title",icon = "roleinfo:img_message_icon_1",dark_icon ="roleinfo:img_message_icon_2",},
			{text = ConfigLanguage.Setting.AutoPlay,id = 2,img_title = "autoplay:autoplay_title",show_lv=65, open_lv=65},
		}
	end
	self.table_index = nil

	self.global_event_list = {}
	--self.model = 2222222222222end:GetInstance()
end

function SettingPanel:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function SettingPanel:Open(table_index)
	SettingPanel.super.Open(self)
	self.default_table_index = table_index or 1
	DebugLog("===============SettingPanel===========",Application.targetFrameRate)
end

function SettingPanel:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
end

function SettingPanel:AddEvent()
	local function call_back()
		self:Close()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.GameReset, call_back)

	local function call_back()
		self:Close()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.SDKLogOut, call_back)
end

function SettingPanel:OpenCallBack()
	self:UpdateView()
end

function SettingPanel:UpdateView( )

end

function SettingPanel:CloseCallBack(  )
	if self.show_panel then
		self.show_panel:destroy()
	end
	if self.autoplay_panel then
		self.autoplay_panel:destroy()
	end
end
function SettingPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	if self.table_index == 1 then
		if not self.show_panel then
			self.show_panel = SettingView(self.transform)
		end
		self:PopUpChild(self.show_panel)
	elseif self.table_index == 2 then
		if not self.autoplay_panel then
			self.autoplay_panel = AutoPlayView(self.transform)
		end
		self:PopUpChild(self.autoplay_panel)
	end
end