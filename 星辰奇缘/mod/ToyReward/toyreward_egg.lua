-- ----------------------------------
-- 扭蛋的蛋蛋
-- hosr
-- ----------------------------------
ToyrewardEgg = ToyrewardEgg or BaseClass()

function ToyrewardEgg:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function ToyrewardEgg:__delete()
	self:EndTween()
	self.icon = nil
	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end
end

function ToyrewardEgg:InitPanel()
	self.transform = self.gameObject.transform
    self.icon = self.transform:Find("Icon"):GetComponent(Image)
    self.transform:Find("Icon"):GetComponent(Button).onClick:AddListener(function() self:ClickEgg() end)
    self.slot = ItemSlot.New(self.transform:Find("ItemSlot").gameObject)
    self.icon.gameObject:SetActive(false)
    self.slot.gameObject:SetActive(false)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.name.text = ""

    self.defaultPos = self.transform.localPosition
end

function ToyrewardEgg:ClickEgg()
	self.parent:ClickOpen()
end

function ToyrewardEgg:EndTween()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
end

function ToyrewardEgg:SetName(name)
	self.name.text = name
end

function ToyrewardEgg:JumpOut()
	self:EndTween()
	self.transform.localPosition = self.defaultPos - Vector3(0, 20, 0)
	self.gameObject:SetActive(true)
    self.icon.gameObject:SetActive(true)
	self.tweenId = Tween.Instance:MoveLocal(self.gameObject, self.defaultPos, 0.4, function() self:Pingpong() end, LeanTweenType.easeOutElastic).id
end

function ToyrewardEgg:Pingpong()
	self:EndTween()
	self.tweenId = Tween.Instance:MoveLocal(self.gameObject, self.defaultPos + Vector3(0, 10, 0), 1.2, nil, LeanTweenType.linear):setLoopPingPong().id
end