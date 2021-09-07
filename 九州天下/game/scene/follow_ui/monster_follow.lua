
MonsterFollow = MonsterFollow or BaseClass(CharacterFollow)

function MonsterFollow:__init()
	self.is_boss = false
end

function MonsterFollow:__delete()
end

function MonsterFollow:SetIsBoss(is_boss)
	self.is_boss = is_boss
	if self.is_boss then
		self:Hide()
	end
end

function MonsterFollow:CreateTextName()
	return CharacterFollow.CreateTextName(self)
end

function MonsterFollow:Show()
	if nil ~= self.hp_bar and not self.is_boss then
		self.hp_bar:SetActive(true)
	end
end

function MonsterFollow:Hide()
	if nil ~= self.hp_bar then
		self.hp_bar:SetActive(false)
	end
	if self.name and self.name.gameObject then
		self.name.gameObject:SetActive(false)
	end
end


function MonsterFollow:ShowName()
	if self.name and self.name.gameObject then
		self.name.gameObject:SetActive(true)
	end
end

function MonsterFollow:HideName()
	if self.name and self.name.gameObject then
		self.name.gameObject:SetActive(false)
	end
end

function MonsterFollow:Create(obj_type)
	FollowUi.Create(self, obj_type or 0)

	self.hp_bar = self:CreateHpBar()
	local the_follow = self.root_obj.transform:Find("Follow").transform
	if nil ~= self.hp_bar then
		self.hp_bar.transform:SetParent(the_follow, false)
	end
end

function MonsterFollow:CreateHpBar()
	return GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "MonsterHP"))
end

function MonsterFollow:SetHpPercent(percent)
	if nil == self.hp_bar then
		return
	end

	if nil == self.hp_slider_top then
		self.hp_slider_top = self.hp_bar.transform:Find("MonsterHPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	end
	self.hp_slider_top.value = percent

	if nil == self.hp_slider_bottom then
		self.hp_slider_bottom = self.hp_bar.transform:Find("MonsterHPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
		self.hp_slider_bottom.value = percent
	else
		self.hp_slider_bottom:DOValue(percent, 0.5, false)
	end
end