SkillEffect = BaseClass(LuaUI)

function SkillEffect:__init(...)
	self.URL = "ui://tv6313j0w5h8e";
	self:__property(...)
	self:Config()
end

function SkillEffect:SetProperty(...)
	
end

function SkillEffect:Config()
	self:InitData()
	self:CleanUI()
end

function SkillEffect:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillEffect");

	self.img_title_bg = self.ui:GetChild("img_title_bg")
	self.img_content_bg = self.ui:GetChild("img_content_bg")
	self.label_title = self.ui:GetChild("label_title")
end

function SkillEffect.Create(ui, ...)
	return SkillEffect.New(ui, "#", {...})
end

function SkillEffect:__delete()
	self:DisposeEffectItems()
	
end

function SkillEffect:InitData()
	self.effectItems = {}
	self.skillData = {}
	self.skillEffectType = SkillConst.SkillEffectType.None
end

function SkillEffect:SetData(data ,isLearn)
	self.skillData = data or {}
	self.isLearn = isLearn
end

function SkillEffect:SetUI()
	for index = 1 , SkillConst.MaxSkillEffect do
		self:SetEffectItem(index)
	end
end

function SkillEffect:SetEffectItem(index)
	local effectName = ""
	local effectValue = ""
	if not TableIsEmpty(self.skillData) then
		if index == 1 then
			effectName = self.skillData.proName1 or ""
			if self.isLearn == nil then
				effectValue = self.skillData.proValue1 or ""
			else
				effectValue = "0%"
			end
		end

		if index == 2 then
			effectName = self.skillData.proName2 or ""
			if self.isLearn == nil then
				effectValue = self.skillData.proValue2 or ""
			else
				effectValue = "0%"
			end
		end

		if index == 3 then
			effectName = "" --等策划表配置好了第三个属性和值，则未对应属性
			effectValue = ""
		end
	end

	local oldEffectItem = self:GetEffectItemByIndex(index)
	if effectName ~= "" then
		local curEffectItem = {}
		if TableIsEmpty(oldEffectItem) then
			curEffectItem = SkillEffectItem.New()
			self.ui:AddChild(curEffectItem.ui)
			table.insert(self.effectItems , curEffectItem)
		else
			curEffectItem = oldEffectItem
		end
			
		local effectValueColor = self:GetEffectValueColor()
		if effectValue ~= "" then
			effectValue = StringFormat("[color=#{0}]{1}[/color]" , effectValueColor , effectValue)
		end

		curEffectItem:SetUI(effectName , effectValue)
		curEffectItem:SetXY(9 , 49 + 40 * ( index  - 1))
		curEffectItem:SetVisible(true)
	else
		if not TableIsEmpty(oldEffectItem) then
			oldEffectItem:SetVisible(false)
		end
	end
end

function SkillEffect:CleanUI()

end

function SkillEffect:DisposeEffectItems()
	for index = 1 , #self.effectItems do
		if self.effectItems[index] then
			self.effectItems[index]:Destroy()
		end
	end
	self.effectItems = {}
end

function SkillEffect:GetEffectItemByIndex(index)
	return self.effectItems[index] or {}
end

function SkillEffect:SetTitle(strTitle)
	self.label_title.text = strTitle or ""
end

function SkillEffect:SetEffectType(typeData)
	if typeData == SkillConst.SkillEffectType.CurLev then
		self.skillEffectType = SkillConst.SkillEffectType.CurLev
	elseif typeData == SkillConst.SkillEffectType.NextLev then
		self.skillEffectType = SkillConst.SkillEffectType.NextLev
	elseif typeData == SkillConst.SkillEffectType.MaxLev then
		self.skillEffectType = SkillConst.SkillEffectType.MaxLev
	else
		self.skillEffectType = SkillConst.SkillEffectType.None
	end
end

function SkillEffect:GetEffectValueColor()
	local rtnColor = ""
	if self.skillEffectType == SkillConst.SkillEffectType.CurLev then
		rtnColor = "1e67af"
	elseif self.skillEffectType == SkillConst.SkillEffectType.NextLev then
		rtnColor = "00620e"
	elseif self.skillEffectType == SkillConst.SkillEffectType.MaxLev then
		rtnColor = "1e67af"
	else
		rtnColor = "1e67af"
	end	
	return rtnColor
end
