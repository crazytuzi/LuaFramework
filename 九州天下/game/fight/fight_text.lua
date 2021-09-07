FightText = FightText or BaseClass()

local UIRoot = GameObject.Find("GameRoot/UILayer").transform

function FightText:__init()
	if FightText.Instance then
		print_error("[FightText]:Attempt to create singleton twice!")
	end
	FightText.Instance = self
	self.is_active = true
	-- Load floating canvas
	UtilU3d.PrefabLoad("uis/views/floatingtext_prefab", "FloatingCanvas", function(obj)
		self.canvas = obj:GetComponent(typeof(UnityEngine.Canvas))
		self.canvas.overrideSorting = true
		self.canvas.sortingOrder = 1000 * UiLayer.FloatText
		self.canvas_transform = self.canvas.transform

		self.canvas_transform:SetParent(UIRoot, false)
		self.canvas_transform:SetLocalScale(1, 1, 1)
		local rect = self.canvas_transform:GetComponent(
			typeof(UnityEngine.RectTransform))
		rect.anchorMax = Vector2(1, 1)
		rect.anchorMin = Vector2(0, 0)
		rect.anchoredPosition3D = Vector3(0, 0, 0)
		rect.sizeDelta = Vector2(0, 0)
	end)

	self.max_text_count = 25
	self.current_text_count = 0
	self.text_t = {}
end

function FightText:__delete()
	FightText.Instance = nil
end

function FightText:GetCanvas()
	return self.canvas
end


function FightText:SetActive(value)
	if self.is_active == value then return end
	self.is_active = value
	if self.canvas_transform then
		self.canvas_transform.gameObject:SetActive(value)
		if value then
			self.canvas_transform:SetParent(UIRoot, false)
			self.canvas_transform:SetLocalScale(1, 1, 1)
			local rect = self.canvas_transform:GetComponent(
				typeof(UnityEngine.RectTransform))
			rect.anchorMax = Vector2(1, 1)
			rect.anchorMin = Vector2(0, 0)
			rect.anchoredPosition3D = Vector3(0, 0, 0)
			rect.sizeDelta = Vector2(0, 0)
		end
	end
	if value then
		self:RemoveAll()
	end
end

function FightText:ShowText(bundle, asset, text, attach_point)
	if not self.is_active then
		return
	end
	if nil == self.canvas then
		return
	end

	if self.current_text_count > self.max_text_count then
		return
	end

	self.current_text_count = self.current_text_count + 1
	local attach_position = attach_point.position
	GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
		if not obj then
			return
		end

		if nil == MainCamera then
			GameObjectPool.Instance:Free(obj)
			return
		end

		local text_obj = obj.transform:Find("Text")
		local text_component = text_obj:GetComponent(typeof(UnityEngine.UI.Text))
		text_component.text = text

		local animator = obj:GetComponent(typeof(UnityEngine.Animator))
		animator:WaitEvent("exit", function(param)
			if self.text_t and self.text_t[obj] then
				self.text_t[obj] = nil
				GameObjectPool.Instance:Free(obj)
				self.current_text_count = math.max(self.current_text_count - 1, 0)
			end
		end)

		obj.transform:SetParent(self.canvas_transform, false)
		obj.transform.position = UIFollowTarget.CalculateScreenPosition(
			attach_position, MainCamera, self.canvas, obj.transform.parent)
		self.text_t[obj] = true
	end)
end

function FightText:RemoveAll()
	for k,v in pairs(self.text_t) do
		GameObjectPool.Instance:Free(k)
	end
	self.text_t = {}
	self.current_text_count = 0
end

function FightText:ShowHurt(text, pos, attach_point, text_type)
	local add_str = pos.is_top and "1" or ""
	text_type = text_type or FIGHT_TEXT_TYPE.NORMAL
	if text_type == FIGHT_TEXT_TYPE.NORMAL or text_type == FIGHT_TEXT_TYPE.SHENSHENG then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeft1", text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRight1", text, attach_point)
		end
	-- elseif text_type == FIGHT_TEXT_TYPE.BAOJU then
	-- 	if pos.is_left then
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtLeftBaoJu" .. add_str, text, attach_point)
	-- 	else
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtRightBaoJu" .. add_str, text, attach_point)
	-- 	end
	-- elseif text_type == FIGHT_TEXT_TYPE.NVSHEN then
	-- 	if pos.is_left then
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtLeftNvShen" .. add_str, text, attach_point)
	-- 	else
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtRightNvShen" .. add_str, text, attach_point)
	-- 	end
	-- elseif text_type == FIGHT_TEXT_TYPE.SHENSHENG then
	-- 	if pos.is_left then
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtLeftShenSheng" .. add_str, Language.Common.ShenSheng .. text, attach_point)
	-- 	else
	-- 		self:ShowText("uis/views/floatingtext_prefab", "HurtRightShenSheng" .. add_str, Language.Common.ShenSheng .. text, attach_point)
	-- 	end
	end
end

function FightText:ShowGeneralHurt(text, pos, attach_point, text_type)
	local add_str = pos.is_top and "1" or ""
	text_type = text_type or FIGHT_TEXT_TYPE.GREATE_SOLDIER
	if text_type == FIGHT_TEXT_TYPE.GREATE_SOLDIER then
		self:ShowText("uis/views/floatingtext_prefab", "HurtGeneral", text, attach_point)
	end
end

function FightText:ShowCritical(text, pos, attach_point, text_type)
	local add_str = pos.is_top and "1" or ""
	text_type = text_type or FIGHT_TEXT_TYPE.NORMAL
	if text_type == FIGHT_TEXT_TYPE.NORMAL then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "CriticalLeft", Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "CriticalRight", Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point)
		end
	-- elseif text_type == FIGHT_TEXT_TYPE.BAOJU then
	-- 	if pos.is_left then
	-- 		self:ShowText("uis/views/floatingtext_prefab", "CriticalLeftBaoJu" .. add_str, Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point)
	-- 	else
	-- 		self:ShowText("uis/views/floatingtext_prefab", "CriticalRightBaoJu" .. add_str, Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point)
	-- 	end
	end
end

function FightText:ShowBeHurt(text, pos, attach_point)
	local add_str = pos.is_top and "1" or ""
	-- if pos.is_left then
	local main_role = Scene.Instance:GetMainRole()
	local is_hundun = main_role:IsHudun()
	if not is_hundun then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", text, attach_point)
	else
		if text == 0 then return end
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeftHuDun", Language.Common.AbsorbHurt..text, attach_point)
	end
	-- if text == 0 then return end
	-- self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", text, attach_point)
	-- else
	-- 	self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight" .. add_str, text, attach_point)
	-- end
end

function FightText:ShowBeCritical(text, pos, attach_point)
	local add_str = pos.is_top and "1" or ""
	-- if pos.is_left then

		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", text, attach_point)
	-- else
	-- 	self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight" .. add_str, text, attach_point)
	-- end
end

function FightText:ShowDodge(pos, attach_point, is_main_role)
	local add_str = pos.is_top and "1" or ""
	-- if pos.is_left then
	if is_main_role then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", Language.Common.PassvieSkillAttr.wei_ming_zhong, attach_point)
	else
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", Language.Common.PassvieSkillAttr.shan_bi, attach_point)
	end
	-- else
	-- 	self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight" .. add_str, Language.Common.PassvieSkillAttr.shan_bi, attach_point)
	-- end
end

function FightText:ShowRecover(text, attach_point)
	self:ShowText("uis/views/floatingtext_prefab", "Recover", "+" .. text, attach_point)
end


function FightText:ShowCardHurt(text, pos, attach_point, text_type)
	self:ShowText("uis/views/floatingtext_prefab", "HurtCard", Language.MuseumCard.Hurt .. text, attach_point)
end