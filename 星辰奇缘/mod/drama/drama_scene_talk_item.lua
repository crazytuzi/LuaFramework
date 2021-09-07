-- ---------------------------------
-- 剧情场景气泡元素
-- hosr
-- ---------------------------------
DramaSceneTalkItem = DramaSceneTalkItem or BaseClass()

function DramaSceneTalkItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.gameObject.name = "DramaSceneTalkItem"

	self.timeId = nil

	self.itemList = {}
	self.currIndex = 0

	self:InitPanel()
end

function DramaSceneTalkItem:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self.parent = nil
	self.timeId = nil
end

function DramaSceneTalkItem:InitPanel()
	self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3(0, 1, -30)
    self.transform.localScale = Vector3.one * 0.0045

    for i = 1, 2 do
    	local item = DTalkItem.New(self.transform:Find("originitem/talk" .. i).gameObject, self)
    	item.gameObject:SetActive(false)
    	table.insert(self.itemList, item)
    end
end

function DramaSceneTalkItem:Show(msg, time, callback)
	if self.gameObject ~= nil then
		self.gameObject:SetActive(true)
	end
	local moveup_item = self.itemList[self.currIndex]

	self.currIndex = self.currIndex + 1
	if self.currIndex > 2 then
		self.currIndex = 1
	end
	local item = self.itemList[self.currIndex]
	item:Reset()
	item:SetData(msg, time, callback)
	item:FadeShow()
	if moveup_item ~= nil and moveup_item.showing then
		moveup_item:MoveUp(item.height)
	end
end



-- ----------------------------------
-- 在拆开
-- ----------------------------------
DTalkItem = DTalkItem or BaseClass()

function DTalkItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.showing = false
	self.height = 0
	self.callback = nil
	self.time = 2000
	self:InitPanel()
end

function DTalkItem:__delete()
	self:Cancel()
end

function DTalkItem:Cancel()
	self.callback = nil
	if self.msg ~= nil then
		self.msg:DeleteMe()
		self.msg = nil
	end
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
	if self.tweenId2 ~= nil then
		Tween.Instance:Cancel(self.tweenId2)
		self.tweenId2 = nil
	end
	if self.faceTime ~= nil then
		LuaTimer.Delete(self.faceTime)
		self.faceTime = nil
	end
	if self.callTimeid ~= nil then
		LuaTimer.Delete(self.callTimeid)
		self.callTimeid = nil
	end
end

function DTalkItem:InitPanel()
	self.transform = self.gameObject.transform
	self.rect = self.gameObject:GetComponent(RectTransform)
	self.img = self.gameObject:GetComponent(Image)
	self.arraw = self.transform:Find("Arraw").gameObject
	self.text = self.transform:Find("msg"):GetComponent(Text)

    self.msgItem = MsgItemExt.New(self.text ,240, 28, 33, true)
end

function DTalkItem:SetData(msg, time, callback)
	self.callback = callback
	self.time = time or 2000
	if self.time == 0 then
		self.time = 2000
	end
    self.msgItem:SetData(msg)
    self.height = self.msgItem.selfHeight
end

function DTalkItem:Reset()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
	if self.tweenId2 ~= nil then
		Tween.Instance:Cancel(self.tweenId2)
		self.tweenId2 = nil
	end
	if self.faceTime ~= nil then
		LuaTimer.Delete(self.faceTime)
		self.faceTime = nil
	end
	if self.callTimeid ~= nil then
		LuaTimer.Delete(self.callTimeid)
		self.callTimeid = nil
	end
	self.rect.anchoredPosition = Vector3.zero
	self.img.transform:GetComponent(CanvasGroup).alpha = 0
	self.msgItem:Reset()
	self.text.text = ""
    self.height = 0
	self.gameObject:SetActive(false)
	self.arraw:SetActive(true)
end

function DTalkItem:FadeShow()
	self.showing = true
	self.gameObject:SetActive(true)
	self.transform.localPosition = Vector3(0, -self.transform.sizeDelta.y, 0)
	self.tweenId2 = Tween.Instance:MoveLocal(self.gameObject, Vector3.zero, 0.3, nil, LeanTweenType.easeOutQuart).id
	self.tweenId = Tween.Instance:ValueChange(0, 100, 0.3, function() self:AlphaShowOver() end, LeanTweenType.easeOutQuart, function(val) self:AlphaLoop(val) end).id
	self.callTimeid = LuaTimer.Add(self.time, function() self:CallBack() end)
end

function DTalkItem:AlphaShowOver()
	if BaseUtils.isnull(self.gameObject) then
		self:Cancel()
		return
	end

	self.faceTime = LuaTimer.Add(1500, function() self:FadeHide() end)
end

function DTalkItem:AlphaLoop(val)
	if BaseUtils.isnull(self.gameObject) then
		self:Cancel()
		return
	end

    if not BaseUtils.isnull(self.img) then
        self.img.transform:GetComponent(CanvasGroup).alpha = val/100
    end
end

function DTalkItem:FadeHide()
	self.tweenId = Tween.Instance:ValueChange(100, 0, 0.3, function() self:AlphaHideOver() end, LeanTweenType.linear, function(val) self:AlphaLoop(val) end).id
end

function DTalkItem:AlphaHideOver()
	if BaseUtils.isnull(self.gameObject) then
		self:Cancel()
		return
	end

	self.gameObject:SetActive(false)
	self.img.transform:GetComponent(CanvasGroup).alpha = 0
	self.showing = false
end

function DTalkItem:MoveUp(height)
	if BaseUtils.isnull(self.gameObject) then
		self:Cancel()
		return
	end

	self.arraw:SetActive(false)
	local t = self.transform.localPosition + Vector3(0, height + 30, 0)
	self.tweenId2 = Tween.Instance:MoveLocal(self.gameObject, t, 0.3, nil, LeanTweenType.easeOutQuart).id
end

function DTalkItem:CallBack()
	if self.callback ~= nil then
		self.callback()
	end
end