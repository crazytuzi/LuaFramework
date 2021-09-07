-- ------------------------
-- 坐骑技能每项结构
-- hosr
-- ------------------------
RideSkillItem = RideSkillItem or BaseClass()

function RideSkillItem:__init(gameObject, parent, noClick, noTips, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index
	self.gameObject:SetActive(false)
	self.transform = self.gameObject.transform
	self.noClick = noClick
	self.noTips = noTips
	self.specialNotice = nil
	self.iconLoader = nil
	self:InitPanel()
end

function RideSkillItem:__delete()
	self.icon.sprite = nil
	if self.iconLoader ~= nil then
		self.iconLoader:DeleteMe()
		self.iconLoader = nil
	end
	self.gameObject = nil
	self.transform = nil
end

function RideSkillItem:InitPanel()
	self.icon = self.transform:GetComponent(Image)
	self.lev = self.transform:Find("Lev/Text"):GetComponent(Text)
	self.select = self.transform:Find("Select").gameObject
	self.name = self.transform:Find("Name/Text"):GetComponent(Text)
	self.levObj = self.transform:Find("Lev").gameObject
	self.lock = self.transform:Find("Lock").gameObject
	if self.transform:Find("Tag") ~= nil then
		self.tag = self.transform:Find("Tag").gameObject
		self.tag:SetActive(false)
	end

	self.select:SetActive(false)
	if not self.noTips or not self.noClick then
		self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Click() end)
	end
end

 -- {uint8, skill_index, "技能槽id"}
 -- ,{uint32, skill_id, "技能id"}
 -- ,{uint32, skill_lev, "等级"}
function RideSkillItem:SetData(data)
	self.data = data
	if self.data == nil then
		-- 锁
		self.levObj:SetActive(false)
		self.lock:SetActive(true)
		self.name.text = string.format(TI18N("技能%s"), BaseUtils.NumToChn(self.index))
		if self.iconLoader ~= nil then
			self.iconLoader:DeleteMe()
			self.iconLoader = nil
		end
		self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.ride_texture, "RideSkillBg")
	else
		self.levObj:SetActive(true)
		self.lock:SetActive(false)
		self.skillData = DataSkill.data_mount_skill[string.format("%s_%s", data.skill_id, data.skill_lev)]
		if self.skillData ~= nil then
			self.name.text = RideEumn.ColorName(data.skill_lev, self.skillData.name)
			self.lev.text = RideEumn.SkillLevShow[data.skill_lev]
			-- self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(self.skillData.icon))
			if self.iconLoader == nil then
				self.iconLoader = SingleIconLoader.New(self.icon.gameObject)
			end
			self.iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(self.skillData.icon))

			if self.tag ~= nil then
				if self.skillData.effect_type == RideEumn.SkillEffectType.Pet then
					self.tag:SetActive(false)
				else
					self.tag:SetActive(true)
				end
			end
		end
	end
	self.gameObject:SetActive(true)
end

function RideSkillItem:Select(bool)
	self.select:SetActive(bool)
end

function RideSkillItem:Click()
	if self.data == nil then
		if self.specialNotice == nil then
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("坐骑<color='#ffff00'>%s级突破</color>可解锁"), (self.index - 1) * 10))
		else
			NoticeManager.Instance:FloatTipsByString(self.specialNotice)
		end
		return
	end
	if not self.noClick then
		self.parent:SelectOne(self)
	end
	if not self.noTips then
		TipsManager.Instance:ShowRideSkill({gameObject = self.gameObject, data = self.skillData})
	end

	if self.callback ~= nil then
		self.callback(self)
	end
end
