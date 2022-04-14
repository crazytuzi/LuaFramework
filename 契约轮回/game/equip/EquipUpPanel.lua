--
-- @Author: chk
-- @Date:   2018-09-18 14:40:24
--
EquipUpPanel = EquipUpPanel or class("EquipUpPanel",WindowPanel)
local EquipUpPanel = EquipUpPanel

function EquipUpPanel:ctor()
	self.abName = "equip"
	self.assetName = "EquipUpPanel"
	self.layer = "UI"

	--self.use_background = true
	--self.change_scene_close = true

	self.panel_type = 2
	self.model = EquipModel.GetInstance()

	--[[self.show_sidebar = true		--是否显示侧边栏
	if self.show_sidebar then		-- 侧边栏配置
		self.sidebar_data = {
			{text = ConfigLanguage.Equip.Strong,id = 1,img_title = "equip:equip_strong_f",},
			{text = ConfigLanguage.Equip.Mount,id = 2,img_title = "equip:equip_mount_f",},
			{text = ConfigLanguage.Equip.Suit,id = 3,img_title = "equip:equip_suit_f",},
		}
	end--]]

	self.strong_view = nil
	self.global_events = {}
	self.bind_data_events = {}
end

function EquipUpPanel:dctor()
	if self.strong_view ~= nil then
		self.strong_view:destroy()
	end
	self.strong_view = nil

	if self.mount_view ~= nil then
		self.mount_view:destroy()
	end
	self.mount_view = nil

	if self.suit_view ~= nil then
		self.suit_view:destroy()
		self.suit_view = nil
	end

	if self.refine_view then
		self.refine_view:destroy()
		self.refine_view = nil
	end

	for i=1, #self.global_events do 
		GlobalEvent:RemoveListener(self.global_events[i])
	end
	for k, v in pairs(self.bind_data_events) do
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(v)
	end
	self.model = nil
end

function EquipUpPanel:Open(sub_id)
	self.default_table_index = self.model.equipUpPanelIndex
	self.sub_id = sub_id
	EquipUpPanel.super.Open(self)
end

function EquipUpPanel:LoadCallBack()
	self.nodes = {
		"panelContain",
		"panelContain/Image",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	--self:SwitchCallBack(1)
	self:ShowRedDot()
end

function EquipUpPanel:AddEvent()

	local function call_back( )
		self:ShowSuiteRedDot()
		self:ShowStoneRedDot()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.BuildSuitSucess, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.StoneChange, call_back)

    local function call_back()
    	self:ShowStrongRedDot()
    end
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.StrongSucess, call_back)
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.StrongFail, call_back)
    self.bind_data_events[#self.bind_data_events+1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("coin", call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.EquipStrongSuite, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.EquipCastSuccess, call_back)

    local function call_back()
    	self:ShowRefineRedDot()
    end
    self.bind_data_events[#self.bind_data_events+1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    self.bind_data_events[#self.bind_data_events+1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("vip", call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.UpdateRefineInfo, call_back)

    local function call_back()
    	self:ShowRedDot()
    end
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.PutOnEquipSucess, call_back)
end

function EquipUpPanel:OpenCallBack()
	self:UpdateView()
end

function EquipUpPanel:UpdateView( )
	self:SetTabIndex(self.model.equipUpPanelIndex)
	--self:SwitchCallBack(self.model.equipUpPanelIndex)
end

function EquipUpPanel:CloseCallBack(  )

end


function EquipUpPanel:SwitchCallBack(index)
	if self.child_node then
		self.child_node:SetVisible(false)
	end
	if index == 1 then
		if not self.strong_view then
			self.strong_view = EquipStrongView(self.panelContain, "UI", self.sub_id)
		end
		SetVisible(self.Image, true)
		self:PopUpChild(self.strong_view)
	elseif index == 2 then
		if not self.mount_view then
			self.mount_view = EquipMountStoneView(self.panelContain,"UI",self.sub_id)
		end
		SetVisible(self.Image, true)
		self:PopUpChild(self.mount_view)
	elseif index == 3 then
		if not self.suit_view then
			self.suit_view = EquipSuitView(self.panelContain,"UI")
		end
		SetVisible(self.Image, false)
		self:PopUpChild(self.suit_view)
	elseif index == 4 then
		if not self.refine_view then
			self.refine_view = EquipRefineView(self.panelContain)
		end
		SetVisible(self.Image, false)
		self:PopUpChild(self.refine_view)
	end
end

function EquipUpPanel:ShowRedDot()
	self:ShowSuiteRedDot()
	self:ShowStoneRedDot()
	self:ShowStrongRedDot()
	self:ShowRefineRedDot()
end

function EquipUpPanel:ShowSuiteRedDot()
	if OpenTipModel.GetInstance():IsOpenSystem(120, 3) then
		local suite_show = EquipSuitModel.GetInstance():GetNeedShowRedDot()
		self:SetIndexRedDotParam(3, suite_show)
	end
end

function EquipUpPanel:ShowStoneRedDot()
	if OpenTipModel.GetInstance():IsOpenSystem(120, 2) then
		local stone_show = EquipMountStoneModel.GetInstance():GetNeedShowRedDot()
		self:SetIndexRedDotParam(2, stone_show)
	end
end

function EquipUpPanel:ShowStrongRedDot()
	if OpenTipModel.GetInstance():IsOpenSystem(120, 1) then
		local strong_show = EquipStrongModel.GetInstance():GetNeedShowRedDot()
		local cast_show = EquipStrongModel.GetInstance():GetNeedShowCastRedDot()
		local suite_show = EquipStrongModel.GetInstance():IsCanUpStrongSuite()
		self:SetIndexRedDotParam(1, strong_show or cast_show or suite_show)
	end
end

function EquipUpPanel:ShowRefineRedDot()
	if OpenTipModel.GetInstance():IsOpenSystem(120, 4) then
		local refine_show = EquipRefineModel.GetInstance():GetNeedShowRedDot()
		self:SetIndexRedDotParam(4, refine_show)
	end
end
