-- ------------------------------
-- 英雄擂台胜利块块
-- hosr
-- ------------------------------
PlayerkillWinItem = PlayerkillWinItem or BaseClass()

function PlayerkillWinItem:__init(transform, parent)
	self.transform = transform
	self.gameObject = self.transform.gameObject
	self.parent = parent
	self:InitPanel()
end

function PlayerkillWinItem:__delete()
	if self.image ~= nil then
		self.image.sprite = nil
		self.image = nil
	end

	if self.effectFlag ~= nil then
        GameObject.DestroyImmediate(self.effectFlag)
        self.effectFlag = nil
	end

	if self.effect3Win ~= nil then
        GameObject.DestroyImmediate(self.effect3Win)
        self.effect3Win = nil
	end
end

function PlayerkillWinItem:InitPanel()
	self.image = self.gameObject:GetComponent(Image)

    self.effectFlag = GameObject.Instantiate(self.parent:GetPrefab(self.parent.effectFlagPath))
    self.effectFlag.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effectFlag.transform, "UI")
    self.effectFlag.transform.localScale = Vector3.one
    self.effectFlag.transform.localPosition = Vector3(20, -20, -400)
    self.effectFlag:SetActive(false)

    self.effect3Win = GameObject.Instantiate(self.parent:GetPrefab(self.parent.effect3WinPath))
    self.effect3Win.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect3Win.transform, "UI")
    self.effect3Win.transform.localScale = Vector3.one
    self.effect3Win.transform.localPosition = Vector3(20, -20, -400)
    self.effect3Win:SetActive(false)
end

function PlayerkillWinItem:LightUp(bool)
	if bool then
		self.image.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.playerkilltexture, "PlayKillWin1")
	else
		self.image.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.playerkilltexture, "PlayKillWin0")
	end
	self.effectFlag:SetActive(bool)
end

function PlayerkillWinItem:Boom()
	if self.effect3Win ~= nil then
		self.effect3Win:SetActive(false)
		self.effect3Win:SetActive(true)
	end
	self:LightUp(false)
end

function PlayerkillWinItem:NoBoom()
	if self.effect3Win ~= nil then
		self.effect3Win:SetActive(false)
	end
end