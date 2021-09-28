GodFightRuneItem = BaseClass(LuaUI)

function GodFightRuneItem:__init(...)
	self.URL = "ui://s210esy7s4zfn";
	self:__property(...)
	self:Config()
end

function GodFightRuneItem:SetProperty(...)
	
end

function GodFightRuneItem:Config()
	self:InitData()
	self:InitUI()
	self:CleanUI()
end

function GodFightRuneItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("GodFightRune","GodFightRuneItem")
	self.bgIcon = self.ui:GetChild("bgIcon")
	self.icon = self.ui:GetChild("icon")
	self.imgLock = self.ui:GetChild("imgLock")
	self.imgAdd = self.ui:GetChild("imgAdd")
	self.bgName = self.ui:GetChild("bgName")
	self.labelName = self.ui:GetChild("labelName")
	self.imgSelected = self.ui:GetChild("imgSelected")
	self.effectRoot0 = self.ui:GetChild("effectRoot0")
	self.effectRoot1 = self.ui:GetChild("effectRoot1")
end

function GodFightRuneItem.Create(ui, ...)
	return GodFightRuneItem.New(ui, "#", {...})
end

function GodFightRuneItem:__delete()
	self.model = nil
	self:CleanAllEffect()
	self:CleanData()
end

function GodFightRuneItem:InitData()
	self.itemData ={}
	self.model = GodFightRuneModel:GetInstance()
	self.effectRootList = {} --特效挂载点list
	self.effectObjList = {} --特效实例list
end

function GodFightRuneItem:InitUI()
	self.effectRootList[1] = self.effectRoot0
	self.effectRootList[2] = self.effectRoot1
end

function GodFightRuneItem:SetData(data)
	self.itemData = data or {}
end

function GodFightRuneItem:CleanData()
	self.itemData = {}
end

function GodFightRuneItem:SetUI()
	self:CleanUI()
	if not TableIsEmpty(self.itemData) then
		if self.itemData.effectType == GodFightRuneConst.EffectType.SwapSkill then
			local baseSkillId = self.itemData.effectId
			local skillIndex = self.itemData.attrValue
			local newSkillId = SkillModel:GetInstance():GetSkillIdByBaseIdAndSkillIndex(baseSkillId, skillIndex)
			if newSkillId ~= -1 then
				local skillInfo = self.model:GetSkillCfgInfo(newSkillId)
			 	if not TableIsEmpty(skillInfo) then
				 	self.labelName.text = skillInfo.name
				 	self.icon.url = StringFormat("Icon/Skill/{0}", skillInfo.iconID)
			 	end
			end
		elseif self.itemData.effectType == GodFightRuneConst.EffectType.AddBuff then
			
			local attrInfo = self.model:GetAttrCfgInfo(self.itemData.effectId)
			if not TableIsEmpty(attrInfo) then
				self.icon.url = StringFormat("Icon/Attribution/{0}", attrInfo.icon or "")
				self.labelName.text = string.format("%s+%s", attrInfo.name, self.itemData.attrValue or "")
			end
		elseif self.itemData.effectType == GodFightRuneConst.EffectType.None then
			self:SetAddUI(true)
		else

		end
	else
		self:SetAddUI(true)
	end
end

function GodFightRuneItem:CleanUI()
	self.icon.url = ""
	self.imgLock.visible = false
	self.imgAdd.visible = false
	self.imgSelected.visible = false
	self.labelName.text = ""
end

function GodFightRuneItem:SetClockUI(bl)
	self.imgLock.visible = bl
end

function GodFightRuneItem:SetAddUI(bl)
	self.imgAdd.visible = bl
end

function GodFightRuneItem:SetSelected(bl)
	self.imgSelected.visible = bl
end

function GodFightRuneItem:GetAttrCfgInfo(attrId)
	local attrInfo = {}
	if attrId ~= nil then
		local attrCfg = GetCfgData("proDefine"):Get(attrId)
		if not TableIsEmpty(attrCfg) then
			attrInfo = attrCfg
		end
	end
	return attrInfo
end

function GodFightRuneItem:GetSkillCfgInfo(skillId)
	local skillInfo = {}
	if skillId ~= nil then
		local skillCfg = GetCfgData("skill_CellNewSkillCfg"):Get(skillId)
		if skillCfg ~= nil then
			skillInfo = skillCfg
		end
	end
	return skillInfo
end

function GodFightRuneItem:LoadEffect(res , effectMountIndex , posVet3)
	local function LoadCallback(effect)
		if effect then
			if self.effectObjList[effectMountIndex] ~= nil then
				destroyImmediate(self.effectObjList[effectMountIndex])
				self.effectObjList[effectMountIndex] = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			local tf = effectObj.transform
			tf.localPosition = posVet3
			tf.localScale = Vector3.New(1, 1, 1)
	 		tf.localRotation = Quaternion.Euler(0, 0, 0)
			self.effectRootList[effectMountIndex]:SetNativeObject(GoWrapper.New(effectObj))
			self.effectObjList[effectMountIndex] = effectObj
		end
	end
	LoadEffect(res , LoadCallback)
end

--如果当前槽位拥有铭文，则加载该特效，持续播放
function GodFightRuneItem:LoadEffect0()
	self:LoadEffect("4502" , 1 , Vector3.New(62.4 , -41.7 , 0))
end

--使用灵石，对该槽位进行装备，装备成功，则加载该特效
function GodFightRuneItem:LoadEffect1()
	self:LoadEffect("4501" , 2 , Vector3.New(-9, 24.33 , 0))
	local function callback()
		self:CleanEffect1()
	end
	DelayCall(callback, 1)
end

function GodFightRuneItem:CleanEffect1()
	if self.effectObjList[2] ~= nil then
		destroyImmediate(self.effectObjList[2])
		self.effectObjList[2] = nil
	end
end

function GodFightRuneItem:CleanAllEffect()
	for index = 1 , #self.effectObjList do
		if self.effectObjList[index] ~= nil then
			destroyImmediate(self.effectObjList[index])
			self.effectObjList[index] = nil
		end
	end
	self.effectObjList = {}
end