SpiritSoulItem = SpiritSoulItem or BaseClass(BaseRender)

function SpiritSoulItem:__init(instance)
	self.name = self:FindVariable("name")

	self.icon_root = self:FindObj("Icon")

	self.effect = nil
	self.tip_effect = nil
	self.is_destroy_effect = true
	self.is_loading = false

	self.is_is_destroy_effect_loading = false
end

function SpiritSoulItem:__delete()
	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	end
	if self.tip_effect then
		GameObject.Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_destroy_effect = nil
	self.data = nil
end

function SpiritSoulItem:CloseCallBack()
	if self.tip_effect then
		GameObject.Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_is_destroy_effect_loading = false
end

function SpiritSoulItem:IsDestroyEffect(enable)
	self.is_destroy_effect = enable
end

function SpiritSoulItem:SetData(data)
	self.data = data
	if nil == data then return end
	local cfg = SpiritData.Instance:GetSpiritSoulCfg(data.id)
	if data.id == GameEnum.HUNSHOU_EXP_ID then
		cfg = {name = Language.JingLing.ExpHun, hunshou_color = 1, hunshou_effect = "minghun_g_01"}
	end

	if self.effect and self.is_destroy_effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	elseif self.is_loading and self.is_destroy_effect then
		self.is_is_destroy_effect_loading = true
	end

	if cfg then
		local str = "<color=%s>"..cfg.name.."</color>"
		self.name:SetValue(string.format(str, SPIRIT_SOUL_COLOR[cfg.hunshou_color]))
		if cfg.hunshou_effect then
			if not self.effect and not self.is_loading then

				local name = data.id ~= GameEnum.HUNSHOU_EXP_ID and cfg.hunshou_effect or "minghun_g_01"
				self.is_loading = true

				PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_jinglinminghun/" .. name .. "_prefab", name), function (prefab)
					if not prefab or self.effect then return end

					if self.is_is_destroy_effect_loading then
						self.is_loading = false
						self.is_is_destroy_effect_loading = false
						return
					end

					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					local transform = obj.transform
					transform:SetParent(self.icon_root.transform, false)
					self.effect = obj.gameObject
					self.is_loading = false
				end)
			end
		end
	else
		self.name:SetValue("")
	end
end

function SpiritSoulItem:GetData()
	return self.data
end

-- function SpiritSoulItem:SetItemActive(enable)
-- 	self.root_node:SetActive(enable)
-- end

function SpiritSoulItem:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

-- function SpiritSoulItem:SetToggleGroup(toggle_group)
-- 	self.root_node.toggle.group = toggle_group
-- end