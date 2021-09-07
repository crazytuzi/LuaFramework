-- -------------------------------
-- 诸神之战淘汰赛元素
-- hosr
-- -------------------------------
GodsWarFightElimintionItem = GodsWarFightElimintionItem or BaseClass()

function GodsWarFightElimintionItem:__init(gameObject, parent, effect)
	self.gameObject = gameObject
	self.parent = parent
	self.effect = effect

	self.index = 0
	self:InitPanel()
end

function GodsWarFightElimintionItem:__delete()
	self.img.sprite = nil
	self.img = nil
end

function GodsWarFightElimintionItem:InitPanel()
	self.transform = self.gameObject.transform
	self.img = self.gameObject:GetComponent(Image)
	self.rect = self.gameObject:GetComponent(RectTransform)
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	if self.transform:Find("No") ~= nil then
		self.no = self.transform:Find("No").gameObject
	end
	if self.transform:Find("Yes") ~= nil then
		self.yes = self.transform:Find("Yes").gameObject
	end
	self.text = self.transform:Find("Text"):GetComponent(Text)

	if self.effect ~= nil then
	    self.effect.transform:SetParent(self.transform)
	    self.effect.transform.localScale = Vector3(0.9, 1, 1)
	    self.effect.transform.localPosition = Vector3(0, -15, -400)
	    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
	    self.effect:SetActive(false)
	end
end

function GodsWarFightElimintionItem:SetData(data, isFinal)
	self.data = data
	if self.data == nil then
		if isFinal then
			self.text.text = TI18N("<color='#ffff9a'>未决出</color>")
		else
			self.text.text = TI18N("<color='#ff0000'>轮空</color>")
		end
	else
		local my = GodsWarManager.Instance.myData
		if my ~= nil and my.tid == self.data.tid then
			self.text.text = string.format("<color='#ffff00'>%s</color>", self.data.name)
		else
			self.text.text = self.data.name
		end
	end

	if self.no ~= nil then
		self.no:SetActive(false)
	end

	if self.yes ~= nil then
		self.yes:SetActive(false)
	end
end

function GodsWarFightElimintionItem:ChangeTxt(str)
	if self.gameObject == nil then
		return
	end

	if str ~= "" then
		self.text.text = str
	end
end

function GodsWarFightElimintionItem:ClickSelf()
	if self.index == 0 then
		if self.data ~= nil then
			GodsWarManager.Instance.model:OpenTeam(self.data)
		end
	else
		if self.parent ~= nil then
			self.parent:ClickItem(self)
		end
	end
end

function GodsWarFightElimintionItem:SetResult(result)
	if result == 1 then
		if self.no ~= nil then
			self.no:SetActive(false)
		end
		if self.yes ~= nil then
			self.yes:SetActive(true)
		end
	elseif result == 2 then
		if self.no ~= nil then
			self.no:SetActive(true)
		end
		if self.yes ~= nil then
			self.yes:SetActive(false)
		end
	end
end

function GodsWarFightElimintionItem:ColorName()
	local my = GodsWarManager.Instance.myData
	if my ~= nil and my.tid == self.data.tid then
		self.text.text = string.format("<color='#ffff00'>%s</color>", self.text.text)
	else
		self.text.text = string.format("<color='#ffff9a'>%s</color>", self.text.text)
	end
end

function GodsWarFightElimintionItem:PlayEffect(bool)
	if self.effect ~= nil then
		self.effect:SetActive(bool)
	end
end

function GodsWarFightElimintionItem:ChangeThirdShow(bool)
	if bool then
		self.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "bg2")
		self.rect.sizeDelta = Vector2(124, 38)
	else
		self.img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
		self.rect.sizeDelta = Vector2(100, 30)
	end
end