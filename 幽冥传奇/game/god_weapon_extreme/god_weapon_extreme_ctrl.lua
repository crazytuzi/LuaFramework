require("scripts/game/god_weapon_extreme/god_weapon_extreme_data")
require("scripts/game/god_weapon_extreme/god_weapon_extreme_view")
GodWeaponExtremeCtrl = GodWeaponExtremeCtrl or BaseClass(BaseController)

function GodWeaponExtremeCtrl:__init()
	if GodWeaponExtremeCtrl.Instance then
		ErrorLog("[GodWeaponExtremeCtrl]:Attempt to create singleton twice!")
	end
	GodWeaponExtremeCtrl.Instance = self
	self.view = GodWeapoExtremeView.New(ViewName.GodWeapon)
	self.data = GodWeaponEtremeData.New()
	
	self:RegisterAllProtocols()

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	self.item_data_change_back = BindTool.Bind1(self.ItemDataChangeCallback,self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_back)
end

function GodWeaponExtremeCtrl:__delete()
	
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	if self.item_data_change_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_back)
		self.item_data_change_back = nil 
	end
    GodWeaponExtremeCtrl.Instance = nil
  
end

function GodWeaponExtremeCtrl:RegisterAllProtocols()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.GodWeaponUp, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.GodFashionUp, true, 1)
end

function GodWeaponExtremeCtrl:GetRemindSign(remind_name)
	if remind_name == RemindName.GodWeaponUp then
		return self.data:GetWeaponCanUp()
	elseif remind_name == RemindName.GodFashionUp then
		return self.data:GetFashionCanUp()
	end
end

function GodWeaponExtremeCtrl:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemind(RemindName.GodWeaponUp)
		RemindManager.Instance:DoRemind(RemindName.GodFashionUp)
	end
end

function GodWeaponExtremeCtrl:ItemDataChangeCallback(change_type, item_id, index, series, reason)

	if not self.delay_do_equipment_comp then
		self.delay_do_equipment_comp = GlobalTimerQuest:AddDelayTimer(function()
			if GodWeaponEtremeData:GetBoolFlushTabbarByItemId(item_id,  GODWEAPONETREMEDATA_TYPE.WEAPON) then
				RemindManager.Instance:DoRemind(RemindName.GodWeaponUp)
			end
			if GodWeaponEtremeData:GetBoolFlushTabbarByItemId(item_id,  GODWEAPONETREMEDATA_TYPE.FASHION) then
				RemindManager.Instance:DoRemind(RemindName.GodFashionUp)
			end
			if self.delay_do_equipment_comp then
				GlobalTimerQuest:CancelQuest(self.delay_do_equipment_comp)
				self.delay_do_equipment_comp = nil
			end	
		end,0.5)
	end	
end