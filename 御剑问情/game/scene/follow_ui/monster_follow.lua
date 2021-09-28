
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
