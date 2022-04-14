SiegewarParentPanel = SiegewarParentPanel or class("SiegewarParentPanel",WindowPanel)
local SiegewarParentPanel = SiegewarParentPanel

function SiegewarParentPanel:ctor()
	self.abName = "siegewar"
	self.assetName = "SiegewarParentPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 2								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = true		--是否显示侧边栏
	--[[if self.show_sidebar then		-- 侧边栏配置
		self.sidebar_data = {
			{text = ConfigLanguage.Custom.Message,id = 1,img_title = "system:ui_img_text_title",icon = "roleinfo:img_message_icon_1",dark_icon ="roleinfo:img_message_icon_2",},
		}
	end--]]
	self.table_index = nil
	self.model = SiegewarModel:GetInstance()
	self.global_events = {}
end

function SiegewarParentPanel:dctor()
end

function SiegewarParentPanel:Open( )
	SiegewarParentPanel.super.Open(self)
end

function SiegewarParentPanel:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	self:SetTileTextImage("siegewar_image", "siegewartitle_img")
	self:CheckRedDot()
end

function SiegewarParentPanel:AddEvent()
	local function call_back(sceneid)
		local scenecfg = Config.db_scene[sceneid]
		if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR then
			self:Close()
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.EndHandleTimeline, call_back)
end

function SiegewarParentPanel:OpenCallBack()
	self:UpdateView()
end

function SiegewarParentPanel:UpdateView( )

end

function SiegewarParentPanel:CloseCallBack(  )
	if self.show_panel then
		self.show_panel:destroy()
		self.show_panel = nil
	end
	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end
end
function SiegewarParentPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	if self.show_panel then
		self.show_panel:destroy()
		self.show_panel = nil
	end
	if self.table_index == 1 then
		if not self.show_panel then
			self.show_panel = SiegewarPanel(self.transform)
		end
		self:PopUpChild(self.show_panel)
	elseif self.table_index == 2 then
		if not self.show_panel then
			self.show_panel = SiegewarDropLogPanel(self.transform)
		end
		self:PopUpChild(self.show_panel)
	end
end

function SiegewarParentPanel:CheckRedDot()
	local flag = self.model:IsHaveRedDot()
	self:SetIndexRedDotParam(1, flag)
end