EquipmentView = EquipmentView or BaseClass(BaseView)

function EquipmentView:__init()
	self.title_img_path = ResPath.GetWord("word_equipment")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/appraisal.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.btn_info = {
		ViewDef.Equipment.Strength,
		ViewDef.Equipment.Refine,
		ViewDef.Equipment.Stone,
		ViewDef.Equipment.Authenticate,
		ViewDef.Equipment.Fusion,
	}

	require("scripts/game/equipment/view/qianghua_view").New(ViewDef.Equipment.Strength, self)
	require("scripts/game/equipment/view/affinage_view").New(ViewDef.Equipment.Refine, self)
	require("scripts/game/equipment/view/stone_view").New(ViewDef.Equipment.Stone, self)
	require("scripts/game/equipment/view/authenticate_view").New(ViewDef.Equipment.Authenticate, self)
	require("scripts/game/equipment/view/equipment_fusion_view").New(ViewDef.Equipment.Fusion, self)
end

function EquipmentView:__delete()
end

function EquipmentView:ReleaseCallBack()
end

function EquipmentView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
	self:AddObj("tabbar")

	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))
end

function EquipmentView:OpenCallBack()
end

function EquipmentView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		local vis = ViewManager.Instance:CanOpen(v)
		self.tabbar:SetToggleVisible(k, vis)
	end

	self:EquipmentRemindChange()
	
	-- 提前开放显示
	self.tabbar:SetToggleVisible(5, GameCondMgr.Instance:GetValue("CondId7"))
end

function EquipmentView:OnFlush(param_t, index)
end

function EquipmentView:CloseCallBack(is_all)
end

function EquipmentView:EquipmentRemindChange()
	self.tabbar:SetRemindByIndex(1, QianghuaData.Instance:GetCanStrengthNum() > 0)
	self.tabbar:SetRemindByIndex(2, AffinageData.Instance:GetCanAffinage() > 0)
	self.tabbar:SetRemindByIndex(3, StoneData.Instance:CanEquipInsetStone() > 0)
	self.tabbar:SetRemindByIndex(4, AuthenticateData.GetRemindIndex() > 0)
	self.tabbar:SetRemindByIndex(5, RemindManager.Instance:GetRemind(RemindName.EquipmentFusion) > 0)
end

function EquipmentView:OnRemindChanged(remind_name, num)
	if self.tabbar then
    	if remind_name == RemindName.EquipStrengthen then
            self.tabbar:SetRemindByIndex(1, num > 0)
        elseif remind_name == RemindName.EquipAffinage then
        	self.tabbar:SetRemindByIndex(2, num > 0)
		elseif remind_name == RemindName.EquipInlayStone then
            self.tabbar:SetRemindByIndex(3, num > 0)
        elseif remind_name == RemindName.EquipAuthenticate then
            self.tabbar:SetRemindByIndex(4, num > 0)
        elseif remind_name == RemindName.EquipmentFusion then
        	self.tabbar:SetRemindByIndex(5, num > 0)
        end
    end
end