SignRewardItem = SignRewardItem or BaseClass()

function SignRewardItem:__init(gameObject,isHasDoubleClick,targetObj)
	 self.targetObj = targetObj
	 self.targetTr = self.targetObj.transform
	 self.slot = ItemSlot.New(gameObject,isHasDoubleClick)
     self:InitSignRewardItem()
end

function SignRewardItem:__delete()
	if self.effect ~= nil then
		self.effect:DeleteMe()
	end
	self.targetObj = nil
	self.targetTr = nil
	self.signRewardSelect.gameObject:SetActive(false)
	self.showGet.gameObject:SetActive(false)
	self.button.onClick:RemoveAllListeners()
end

function SignRewardItem:InitSignRewardItem()
	if self.targetTr~= nil then
	   self.signRewardSelect = self.targetTr:Find("Select")
	   self.signRewardSelect.gameObject:SetActive(false)
	   self.showGet = self.targetTr:Find("Got")
	   self.button = self.targetTr:Find("Mask"):GetComponent(Button)
	   self.button.onClick:AddListener(function() self.slot:ClickSelf() end)
	   self.slot.button.onClick:RemoveAllListeners()
	end
end

function SignRewardItem:ShowMySelectImg(t)
	self.signRewardSelect.gameObject:SetActive(t)
end

function SignRewardItem:ShowGetImg(t)
	self.showGet.gameObject:SetActive(t)
end

function SignRewardItem:ShowEffect(t)
	if t == 1 then
		if self.effect == nil then
             self.effect = BibleRewardPanel.ShowEffect(20223, self.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
        end
    elseif t == 0 then
        if self.effect ~= nil then
           self.effect:DeleteMe()
        end
    end
end