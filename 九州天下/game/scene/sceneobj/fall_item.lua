FallItem = FallItem or BaseClass(SceneObj)

function FallItem:__init(vo)
	self.obj_type = SceneObjType.FallItem
	self.draw_obj:SetObjType(self.obj_type)

	self.is_picked = false
	self.picked_invalid_time = 0

	-- 是否延时创建
	self.is_delay_create = vo.is_create == 1
	self.create_time = Status.NowTime
end

function FallItem:__delete()
	self:RemoveDelayTime()
	if nil ~= self.item_effect then
		self.item_effect:DeleteMe()
		self.item_effect = nil
	end
end

function FallItem:InitInfo()
	SceneObj.InitInfo(self)

	self.cfg , self.item_type = ItemData.Instance:GetItemConfig(self.vo.item_id)
	if nil ~= self.cfg then
		self.vo.name = self.cfg.name
	end
end

function FallItem:InitShow()
	-- 延迟创建
	if self.is_delay_create then
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.is_delay_create = false self:InitShow() end, 1)
		return
	end

	SceneObj.InitShow(self)
	local model_bundle, model_asset = ResPath.GetFallItemModel(5102002) -- 宝箱模型

	local effect_name = nil
	local pos_y = 0
	if self.item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and not EquipData.IsJLType(self.cfg.sub_type) then
		effect_name = "zhuangbei_0"..self.cfg.color
		model_bundle, model_asset = ResPath.GetForgeEquipModel("000" .. self.cfg.drop_icon) --装备模型
		pos_y = 0.7

	elseif self.vo.is_buff_falling == 1 then
		effect_name = BUFF_FALLING_APPEARAN_TYPE_EFF[self.vo.buff_appearan] or BUFF_FALLING_APPEARAN_TYPE_EFF[1]
		model_bundle, model_asset = nil, nil
		if Language.TowerDefend.FallItemName[self.vo.buff_appearan] then
			local follow_ui = self:GetFollowUi()
			follow_ui:Show()
			follow_ui:SetLocalUI(0, 80, 0)
			follow_ui:SetName(Language.TowerDefend.FallItemName[self.vo.buff_appearan], self)
		end
	else
		effect_name = "baoxiang_0"..self.cfg.color
	end

	if self.item_effect == nil  then
		self.item_effect = AsyncLoader.New(self.draw_obj:GetRoot().transform, pos_y)
	end

	self:ChangeModel(SceneObjPart.Main, model_bundle, model_asset)--self.cfg.drop_icon

	if effect_name then
		self.item_effect:Load("effects2/prefab/misc/" .. string.lower(effect_name) .. "_prefab", effect_name)
	end
	self.item_effect:SetActive(effect_name ~= nil)

	if self.vo.create_interval > 1 then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetTrigger("fall_imm")
	end
end

function FallItem:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function FallItem:Update(now_time, elapse_time)
	if self.picked_invalid_time > 0 and now_time >= self.picked_invalid_time then
		self.picked_invalid_time = 0
		self.is_picked = false
	end
end

function FallItem:IsCoin()
	return self.vo.coin > 0
end

function FallItem:GetAutoPickupMaxDis()
	-- 如果在障碍区，则直接捡起
	if self:IsInBlock() then
		return 0
	elseif self.vo and self.vo.buff_appearan > 0 then
		return 4
	else
		return Scene.Instance:GetSceneLogic():GetPickItemMaxDic(self.vo.item_id)
	end
end

function FallItem:PlayPick()
	-- 播放拾取特效
	local position = self:GetRoot().transform.position
	UtilU3d.PrefabLoad("effects2/prefab/misc/drop_weapon_prefab", "drop_weapon", function(obj)
		obj.transform.position = position

		local follow = obj:GetComponent(typeof(FollowTarget))
		local main_role = Scene.Instance:GetMainRole()
		if follow ~= nil and
			main_role ~= nil and
			main_role.draw_obj ~= nil and
			not main_role:IsDeleted() and
			main_role:GetRoot().gameObject ~= nil then
			local hurt_point = main_role.draw_obj:GetAttachPoint(AttachPoint.Hurt)
			follow:Follow(hurt_point, function()
				GameObject.Destroy(obj)
			end)
		else
			GameObject.Destroy(obj)
		end
		if self.vo.is_buff_falling == 1 then
			GlobalTimerQuest:AddDelayTimer(function() self:CheckShowEff() end, 0.5)
			if Language.TowerDefend.FallItemDec[self.vo.buff_appearan] then
				TipsCtrl.Instance:ShowSystemMsg(Language.TowerDefend.FallItemDec[self.vo.buff_appearan])
			end
		end
	end)
end

function FallItem:RecordIsPicked()
	self.is_picked = true
	self.picked_invalid_time = Status.NowTime + 1.5
end

function FallItem:IsPicked()
	return self.is_picked
end

function FallItem:CheckShowEff()
	if self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_1 then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").level_scene_cfg[1]
		local life_tower_monster_id = other_cfg.life_tower_monster_id
		local monster_list = Scene.Instance:GetMonsterList()
		for k,v in pairs(monster_list) do
			if v:GetMonsterId() >= life_tower_monster_id then
				local res = "BUFF_meirenzhufu"
				local pos = v.draw_obj:GetRoot().transform.position
				if pos then
					local bundle_name, prefab_name = ResPath.GetBuffEffect("buff_prefab", res)
					EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, Vector3(pos.x, pos.y + 3, pos.z))
				end
			end
		end
	elseif self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_2 then
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			main_role:AddEffect("BUFF_meirenzhiqiang", 3)
		end
	elseif self.vo.buff_appearan == BUFF_FALLING_APPEARAN_TYPE.NSTF_BUFF_3 then
		local pos = Scene.Instance:GetMainRole().draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
		if pos then
			local bundle_name, prefab_name = ResPath.GetEffect("BUFF_meirenzhinu")
			EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
		end
	end
end