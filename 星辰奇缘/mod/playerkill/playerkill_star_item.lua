-- ----------------------------------
-- 英雄擂台星星
-- hosr
-- ----------------------------------
PlayerkillStarItem = PlayerkillStarItem or BaseClass()

function PlayerkillStarItem:__init(transform, parent)
	self.transform = transform
	self.gameObject = self.transform.gameObject
	self.parent = parent

	self.index = 0

	self:InitPanel()
end

function PlayerkillStarItem:__delete()
	self:EndTime1()

	if self.image ~= nil then
		self.image.sprite = nil
		self.image = nil
	end

	if self.effectStarFlyOut ~= nil then
        GameObject.DestroyImmediate(self.effectStarFlyOut)
        self.effectStarFlyOut = nil
	end
end

function PlayerkillStarItem:InitPanel()
	self.image = self.transform:GetComponent(Image)

    self.effectStarFlyOut = GameObject.Instantiate(self.parent:GetPrefab(self.parent.effectStarFlyOutPath))
    self.effectStarFlyOut.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effectStarFlyOut.transform, "UI")
    self.effectStarFlyOut.transform.localScale = Vector3.one
    self.effectStarFlyOut.transform.localPosition = Vector3(0, 0, -400)
    self.effectStarFlyOut:SetActive(false)
end

function PlayerkillStarItem:Reset()
	self.transform.localScale = Vector3.one
	self.transform:Rotate(Vector3.zero)
end

function PlayerkillStarItem:LightUp(bool, isAll)
	self:Reset()
	if bool then
		self.image.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.playerkilltexture, "PlayKillStar1")
		self:ChangeShow(2, isAll)
	else
		self.image.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.playerkilltexture, "PlayKillStar0")
		self:ChangeShow(1, isAll)
	end
end

function PlayerkillStarItem:SetPos(pos)
	self:Reset()
	self.transform.localPosition = pos
end

function PlayerkillStarItem:ChangeShow(status, isAll)
	local lastStatus = PlayerkillManager.Instance.starStatus[self.index]
	PlayerkillManager.Instance.starStatus[self.index] = status
	if not isAll then
		if lastStatus == 2 and status == 1 then
			self.effectStarFlyOut:SetActive(false)
			self.effectStarFlyOut:SetActive(true)
		elseif status == 2 and lastStatus == 1 then
		end
		self:EndTime1()
		self.timeId1 = LuaTimer.Add(3500, function() self:TimeOut1() end)
	end
end

function PlayerkillStarItem:EndTime1()
	if self.timeId1 ~= nil then
		LuaTimer.Delete(self.timeId1)
		self.timeId1 = nil
	end
end

function PlayerkillStarItem:TimeOut1()
	if not BaseUtils.isnull(self.effectStarFlyOut) then
		self.effectStarFlyOut:SetActive(false)
	end
end