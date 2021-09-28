SpiritExpFightView = SpiritExpFightView or BaseClass(BaseView)

function SpiritExpFightView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","SpiritFightView"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.has_firend = false
end

function SpiritExpFightView:__delete()
end

function SpiritExpFightView:ReleaseCallBack()
	if self.model_my ~= nil then
		self.model_my:DeleteMe()
		self.model_my = nil
	end

	if self.model_enemy ~= nil then
		self.model_enemy:DeleteMe()
		self.model_enemy = nil
	end

	self.my_name = nil
	self.enemy_name = nil
	self.my_cap = nil
	self.enemy_cap = nil
	self.has_time = nil

	self.show_model_my = nil
	self.show_model_enemy = nil

	self.model_obj_my = nil
	self.model_obj_enemy = nil

	self.my_hp = nil
	self.enemy_hp = nil
	self.my_blood = nil
	self.enemy_blood = nil
end

function SpiritExpFightView:LoadCallBack()
	self.my_name = self:FindVariable("MyName")
	self.enemy_name = self:FindVariable("EnemyName")
	self.my_cap = self:FindVariable("MyCap")
	self.enemy_cap = self:FindVariable("EnemyCap")
	self.has_time = self:FindVariable("HasTime")
	self.show_model_my = self:FindVariable("ShowMyDis")
	self.show_model_enemy = self:FindVariable("ShowEnemyDis")

	self.model_obj_my = self:FindObj("DisplayMy")
	self.model_obj_enemy = self:FindObj("DisplayEnemy")

	self.my_hp = self:FindObj("MyHp"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.enemy_hp = self:FindObj("EnemyHp"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.my_blood = self:FindVariable("MyBlood")
	self.enemy_blood = self:FindVariable("EnemyBlood")

	self:ListenEvent("EventFight", BindTool.Bind(self.OnClickFight, self))
	self:ListenEvent("EventClose", BindTool.Bind(self.OnClickClose, self))
end

function SpiritExpFightView:SetData(stage)
	self.stage = stage
	if not self:IsOpen() then
		self:Open()
	end
end

function SpiritExpFightView:OpenCallBack()
	self:Flush()
end

function SpiritExpFightView:CloseCallBack()
	self.stage = nil
end

function SpiritExpFightView:OnClickFight()
	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_EXPLORE)
	self:Close()
end

function SpiritExpFightView:OnClickClose()
	self:Close()
end

function SpiritExpFightView:InitHp()
	local cur_hp, max_hp =  SpiritData.Instance:GetStageHPStr("my")
	if self.my_hp ~= nil then
		self.my_hp.value = cur_hp / max_hp
	end

	if self.my_blood ~= nil then
		self.my_blood:SetValue(cur_hp .. "/" .. max_hp)
	end

	cur_hp, max_hp =  SpiritData.Instance:GetStageHPStr("enemy")
	if self.enemy_hp ~= nil then
		self.enemy_hp.value = cur_hp / max_hp
	end

	if self.enemy_blood ~= nil then
		self.enemy_blood:SetValue(cur_hp .. "/" .. max_hp)
	end
end

function SpiritExpFightView:ShowModel(model_name, res_id, name, cap)
	if model_name == nil or res_id == nil then
		return
	end

	--local show_str = "show_model_" .. model_name
	local model_str = "model_" .. model_name
	local obj_str = "model_obj_" .. model_name

	-- local model_pos = Vector3(0, 0, 0)
	-- local cfg = {}
	local scale = Vector3(0.8, 0.8, 0.8)

	-- if self[obj_str] ~= nil and self[obj_str].ui3d_display then
	-- 	cfg.rotation = self[obj_str].ui3d_display.localRotation
	-- end

	-- if self[obj_str] ~= nil then
	-- 	model_pos = self[obj_str].transform.localPosition
	-- end

	-- if is_show and self[obj_str] ~= nil and self[model_str] == nil then
	-- 	self[model_str] = RoleModel.New()
	-- 	self[model_str]:SetDisplay(self[obj_str].ui3d_display)
	-- end

	-- if self[model_str] ~= nil and self[show_str] ~= nil then
	-- 	self[show_str]:SetValue(is_show or false)
	-- 	--self[model_str]:SetVisible(is_show)

	-- 	if is_show then
	-- 		self[model_str]:SetMainAsset(ResPath.GetSpiritModel(res_id))

	-- 		if model_name == "my" and not self.has_firend then
	-- 			if self.one_pos ~= nil then
	-- 				--self[model_str].display:SetOffset(self.one_pos.transform.localPosition)
	-- 				model_pos = self.one_pos.transform.localPosition
	-- 			end
	-- 		elseif model_name == "my" and self.has_firend then
	-- 			if self.my_model_pos ~= nil then
	-- 				--self[model_str].display:SetOffset(self.my_model_pos.localPosition)
	-- 				model_pos = self.my_model_pos
	-- 			end
	-- 		end

	-- 		if self.has_firend then
	-- 			--self[model_str]:SetModelScale(0.8)
	-- 		--else
	-- 			--self[model_str]:SetModelScale(0.7)
	-- 			scale = Vector3(0.7, 0.7, 0.7)
	-- 		end

	-- 		--self[model_str]:SetTransform(cfg)

	-- 		if self[obj_str] ~= nil then
	-- 			--self[obj_str]:SetLocalPosition(model_pos.x, model_pos.y, model_pos.z)
	-- 			--self[obj_str]:SetLocalRotation(scale.x, scale.y, scale.z)
	-- 			self[obj_str].transform:SetLocalPosition(model_pos.x, model_pos.y, model_pos.z)
	-- 			--self[obj_str].transform.localRotation = scale
	-- 		end

	-- 		if self[model_str].display ~= nil then
	-- 			self[model_str].display:SetScale(scale)
	-- 		end
	-- 	end
	-- end

	if self[obj_str] ~= nil and self[model_str] == nil then
		self[model_str] = RoleModel.New()
		self[model_str]:SetDisplay(self[obj_str].ui3d_display)
		-- self[model_str]:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], res_id, DISPLAY_PANEL.SPRIT_EXP)
		-- self[model_str]:SetLoadComplete(function() 
		-- 	local rotate = 0
		-- 	if 10008001 == res_id and "enemy" == model_name then
		-- 		rotate = -180
		-- 	end
		-- 	self[model_str]:SetRotation(Vector3(0, rotate, 0))
		-- end)
	end

	if self[model_str] ~= nil then
		self[model_str]:SetMainAsset(ResPath.GetSpiritModel(res_id))
	end

	if self[model_name .. "_name"] ~= nil and name ~= nil then
		self[model_name .. "_name"]:SetValue(name)
	end

	if self[model_name .. "_cap"] ~= nil and cap ~= nil then
		self[model_name .. "_cap"]:SetValue(cap)
	end

	self[model_str]:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], res_id, DISPLAY_PANEL.SPRIT_EXP)


	local rotate = 0
	if 10008001 == res_id and "enemy" == model_name then
		rotate = -180
	end
	self[model_str]:SetRotation(Vector3(0, rotate, 0))
end

-- function SpiritExpFightView:ShowFirendModel(is_show, res_id)
-- 	if is_show and self.firend_model_obj ~= nil and self.firend_model == nil then
-- 		self.firend_model = RoleModel.New()
-- 		self.firend_model:SetDisplay(self.firend_model_obj.ui3d_display)
-- 	end

-- 	if self.firend_model ~= nil and self.show_firend_model ~= nil then
-- 		self.show_firend_model:SetValue(is_show)
-- 		self.firend_model:SetMainAsset(ResPath.GetSpiritModel(res_id))
-- 	end
-- end

-- function SpiritExpFightView:ShowEnemyModel(is_show, res_id)
-- 	if is_show and self.enemy_model_obj ~= nil and self.enemy_model == nil then
-- 		self.enemy_model = RoleModel.New()
-- 		self.enemy_model:SetDisplay(self.enemy_model_obj.ui3d_display)
-- 	end

-- 	if self.enemy_model ~= nil and self.show_enemy_model ~= nil then
-- 		self.show_enemy_model:SetValue(is_show)
-- 		self.enemy_model:SetMainAsset(ResPath.GetSpiritModel(res_id))
-- 	end
-- end

function SpiritExpFightView:FlushModel()
	local my_spirit = SpiritData.Instance:GetMySpiritInOther()
	if my_spirit.item_id > 0 then
		local cap = PlayerData.Instance:GetCapByType(CAPABILITY_TYPE.CAPABILITY_TYPE_JINGLING)
		local buy_count = SpiritData.Instance:GetExploreBuyBuffCount()
		local up_value = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_add_per") or 0
		local up_percent = buy_count * up_value
		cap = cap + cap * (up_percent/100)
		cap = math.ceil(cap)
		self:ShowModel("my", my_spirit.res_id, my_spirit.spirit_name, cap)
	end

	if self.stage ~= nil then
		local data = SpiritData.Instance:GetStageInfoByIndex(self.stage)
		if data ~= nil and data.jingling_id ~= nil and data.jingling_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(data.jingling_id)
			if item_cfg ~= nil then
				local res_cfg = SpiritData.Instance:GetSpiritResIdByItemId(data.jingling_id)
				local name = SpiritData.Instance:GetExpSpiritName(res_cfg.name)
				if res_cfg ~= nil then
					self:ShowModel("enemy", res_cfg.res_id, name, data.capability)
				end
			end
		end
	end
end

function SpiritExpFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			self:FlushModel()
			self:InitHp()
		end
	end
end