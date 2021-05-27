require("scripts/game/setting/guaji_protect/setting_protect_data")

-- 挂机保护设置
SettingProtectCtrl = SettingProtectCtrl or BaseClass(BaseController)

function SettingProtectCtrl:__init()
	if SettingProtectCtrl.Instance ~= nil then
		ErrorLog("[SettingProtectCtrl] Attemp to create a singleton twice !")
	end
	SettingProtectCtrl.Instance = self
	self.protect_data = SettingProtectData.New()
	self.check_time = 0
	self.open_auto_buy_durg = false
	self.drug_use_count = 0
	-- RoleData.Instance:NotifyAttrChange(BindTool.Bind1(self.RoleDataChangeCallback, self))
	-- ItemData.Instance:NotifyDataChangeCallBack(BindTool.Bind1(self.OnItemDataChange, self))
	self.loading_event = GlobalEventSystem:Bind(LoginEventType.LOADING_COMPLETED, BindTool.Bind(self.OnLoadingComplete, self))
	self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	self.role_data_listener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, self.role_attr_change_callback)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnItemDataChange, self))
end

function SettingProtectCtrl:__delete()
	self.protect_data:DeleteMe()
	self.protect_data = nil
	self.role_attr_change_callback = nil
	if self.drup_use_timer then
		GlobalTimerQuest:CancelQuest(self.drup_use_timer)
		self.drup_use_timer = nil
	end
	GlobalEventSystem:UnBind(self.loading_event)

	SettingProtectCtrl.Instance = nil
end

function SettingProtectCtrl:OnLoadingComplete()
	Runner.Instance:AddRunObj(self, 8)
end

function SettingProtectCtrl:Update(now_time, elapse_time)
	if now_time - self.check_time < 3 then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsDead() then
		return 
	end
	self.check_time = now_time
	self:CanCheckHpMpSetting()
	self:CheckDrugBuySetting()
	self:AutoCallHeroSetting()
end

function SettingProtectCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_HP or vo.key == OBJ_ATTR.CREATURE_MP then
		self:CanCheckHpMpSetting(vo.value < vo.old_value)
	end
end

function SettingProtectCtrl:OnItemDataChange(vo)
	-- self.open_auto_buy_durg = true
end

function SettingProtectCtrl:CanCheckHpMpSetting(check_run)
	if self.drug_use_count > 0 then
		self.drug_use_count = self.drug_use_count + 1
		return
	end
	self.drug_use_count = self.drug_use_count + 1
	self:CheckHpMpSetting(check_run)
	self.drup_use_timer = GlobalTimerQuest:AddDelayTimer(function() 
		if self.drug_use_count > 1 then
			self.drug_use_count = 0 
			self:CanCheckHpMpSetting(check_run)
		else
			self.drug_use_count = 0 
		end
	end, 0.5)
end

function SettingProtectCtrl:CheckHpMpSetting(check_run)
	local hp_percent, mp_percent, hp_run_percent = SettingData.Instance:GetSupplyData()
	local hp_select, mp_select, run_select, pick_eq_select = SettingData.Instance:GetSelectOptionData()
	local cur_hp = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) or 0
	local cur_mp = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MP) or 0
	local hp_max = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP) or 1
	local mp_max = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP) or 1
	local hp_per = cur_hp / hp_max * 100
	local mp_per = cur_mp / mp_max * 100
	local need_tip = false
	if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.HP_AUTO) and hp_per < hp_percent then
		if BagData.Instance:GetOneItem(SettingData.DRUG_T[hp_select + 1]) then
			local item = BagData.Instance:GetOneItem(SettingData.DRUG_T[hp_select + 1])
			BagCtrl.Instance:SendUseItem(item.series, 0, 1)
		else
			need_tip = true
		end
	end
	if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.MP_AUTO) and mp_per < mp_percent then
		if BagData.Instance:GetOneItem(SettingData.DRUG_T[mp_select + 1]) then
			local item = BagData.Instance:GetOneItem(SettingData.DRUG_T[mp_select + 1])
			BagCtrl.Instance:SendUseItem(item.series, 0, 1)
		else
			need_tip = true
		end
	end
	
	if need_tip then
		if not SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.SPECIFIC_DRUG_AUTO_BUY) then
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BUY_DRUG, 1, function()
				ViewManager.Instance:OpenViewByDef(ViewDef.PerShop)
			end)
		end
	else
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BUY_DRUG, 0)
	end

	if check_run and SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.HP_AUTO_RUN) and hp_per < hp_run_percent then
		if BagData.Instance:GetOneItem(SettingData.DELIVERY_T[run_select + 1]) then
			local area_info = Scene.Instance:GetCurAreaInfo()
			if not area_info.attr_t[MapAreaAttribute.aaSaft] and not area_info.attr_t[MapAreaAttribute.aaSaftRelive] then
				local item = BagData.Instance:GetOneItem(SettingData.DELIVERY_T[run_select + 1])
				BagCtrl.Instance:SendUseItem(item.series, 0, 1)
			end
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BUY_LOTUS, 0)
		else
			if not SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.REMISSION_DRUG_AUTO_BUY) then
				MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BUY_LOTUS, 1, function()
					ViewManager.Instance:OpenViewByDef(ViewDef.PerShop)
				end)
			end
		end
	end
end

function SettingProtectCtrl:CheckDrugBuySetting()
	self.open_auto_buy_durg = SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.SPECIFIC_DRUG_AUTO_BUY) or SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.REMISSION_DRUG_AUTO_BUY)
	if not self.open_auto_buy_durg then return end
	local drug_cfg = nil
	if not SettingProtectData.HasSpecificDrug() and 5 ~= Scene.Instance:GetSceneId() then
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.SPECIFIC_DRUG_AUTO_BUY) then
			drug_cfg = SettingProtectData.GetUsableDrugCfg(false)
			if drug_cfg then
				ShopCtrl.BuyItemFromStore(drug_cfg.id, 1, drug_cfg.item)
			end
		end
	end
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local cur_circle = 0
	local item_id = SettingData.REMISSION_DRUG[1]
	for k,v in pairs(SettingData.REMISSION_DRUG) do
		local lv, circle = ItemData.GetItemLevel(v)
		if circle <= role_circle and cur_circle <= circle then 
			cur_circle = circle
			item_id = v
		end
	end
	if not BagData.Instance:GetOneItem(item_id)
	and not RoleData.HasBuffGroup(BUFF_GROUP.BLOOD_RETURNING)
	and 5 ~= Scene.Instance:GetSceneId()
	then
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.REMISSION_DRUG_AUTO_BUY) then
			drug_cfg = SettingProtectData.GetUsableDrugCfg(true)
			if drug_cfg then
				ShopCtrl.BuyItemFromStore(drug_cfg.id, 1, drug_cfg.item)
			end
		end
	end
end

function SettingProtectCtrl:AutoCallHeroSetting()
	local area_info = Scene.Instance:GetCurAreaInfo()
	if not area_info.attr_t[MapAreaAttribute.aaNotCallZhanJiang]
		 and SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_CALL_HERO) 
		 and ZhanjiangCtrl.Instance:CanCallHero(HERO_TYPE.ZC)
		-- and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN) >= ZhanjiangData.EXPENDMONEY 
		then
		ZhanjiangCtrl.Instance:SetHeroFightReq(HERO_TYPE.ZC)
	end
end