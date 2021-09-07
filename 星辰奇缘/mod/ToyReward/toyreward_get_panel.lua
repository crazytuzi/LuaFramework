ToyRewardGetPanel = ToyRewardGetPanel or BaseClass(BasePanel)

function ToyRewardGetPanel:__init(parent, force_parent, mask_flag)
    self.parent = parent
    self.force_parent = force_parent
    self.mask_flag = mask_flag
	self.resList = {
       {file = AssetConfig.toyreward_get_panel,type = AssetType.Main},
       {file = AssetConfig.toyreward_textures,type = AssetType.Dep},
       {file = string.format(AssetConfig.effect,20331), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()},
       {file = string.format(AssetConfig.effect,20333), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.OnOpenEvent:AddListener(function()
           self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
    	   self:OnHide()
    end)

    self.effectShowId = nil
    self.oneEffect = nil
    self.oneNextEffect = nil
    self.tenEffectList = {}
    self.itemList = {}
    self.tenIcon = {}
    self.hasOpen = false
    self.eggList = {}

    self.extra = {inbag = false, nobutton = true}
    self.currentChange = true
    self.showing = false
end

function ToyRewardGetPanel:__delete()
    self:EndLock()
    self:EndTime()
    self:EndJump()
    if self.itemList ~= nil then
    		for i,v in ipairs(self.itemList) do
    			v:DeleteMe()
    		end
  	end

    if self.ontEgg ~= nil then
        self.ontEgg:DeleteMe()
        self.ontEgg = nil
    end

    for i,v in ipairs(self.eggList) do
        v:DeleteMe()
    end
    self.eggList = nil

  	if self.getOneItem ~= nil then
  		  self.getOneItem:DeleteMe()
  	end

    if self.effectShowId ~= nil then
        LuaTimer.Delete(self.effectShowId)
        self.effectShowId = nil
    end

    if self.oneEffect ~= nil then
    	 self.oneEffect:DeleteMe()
    end

    self.oneEffect = nil

    if self.oneNextEffect ~= nil then
        self.oneNextEffect:DeleteMe()
    end
    self.oneNextEffect = nil

    if self.tenEffectList ~= nil then
        for i,v in ipairs(self.tenEffectList) do
        	v.firstEffect:DeleteMe()
            v.secondEffect:DeleteMe()
        end
    end

    for i,v in ipairs(self.tenIcon) do
        v:GetComponent(Image).sprite = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()

end

function ToyRewardGetPanel:InitPanel()

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_get_panel))

    if self.force_parent then 
        self:AddUIChild(self.force_parent.parent.gameObject,self.gameObject)
    else
        self:AddUIChild(self.parent.parent.gameObject,self.gameObject)
    end


    local t = self.gameObject.transform

    self.panel = t:Find("Panel")

    if self.mask_flag then 
        self.panel.offsetMax = Vector2(115,60)
        self.panel.offsetMin = Vector2(-285,-80)
    end

    self.panel:GetComponent(Button).onClick:AddListener(function() self:ClickOpen() end)

	  self.getTenContainer = t:Find("Main/GetTenContainer")
    self.getOneContainer = t:Find("Main/GetOne").gameObject
    self.getOneItemTr = t:Find("Main/GetOne/Container/ItemSlot")
    self.getOneIcon = t:Find("Main/GetOne/Container/Icon")
    self.getOneIcon.gameObject:SetActive(false)

    self.getOneItem = ItemSlot.New(self.getOneItemTr.gameObject)
    self.getOneItem.gameObject:SetActive(false)
    self.ontEgg = ToyrewardEgg.New(t:Find("Main/GetOne/Container").gameObject, self)

    self.openButton = t:Find("Main/Button"):GetComponent(Button)
    self.openButton.onClick:AddListener(function() self:ClickOpen() end)
    self.openTxt = t:Find("Main/Button/Text"):GetComponent(Text)
    self.openTxt.text = TI18N("一键打开")

    self.titleTxt = t:Find("Title/Text"):GetComponent(Text)
    self.titleTxt.text = TI18N("恭喜你抽出幸运彩蛋!")  --恭喜你抽出甜蜜巧克力!

    for i = 1,10 do
        local item = ToyrewardEgg.New(self.getTenContainer:GetChild(i - 1).gameObject, self)
        table.insert(self.eggList, item)

        local parent = self.getTenContainer:GetChild(i - 1)
        local item = parent:Find("ItemSlot")
        local icon = parent:Find("Icon")
        icon.gameObject:SetActive(false)
        local itemSlot = ItemSlot.New(item.gameObject)
        itemSlot.gameObject:SetActive(false)
        self.itemList[i] = itemSlot
        self.tenIcon[i] = icon
    end

    self:OnOpen()
end

function ToyRewardGetPanel:OnOpen()
    self.showing = true
    self.currentChange = true
    self.parent:PanelOpened()
    self.hasOpen = false
    self.getOneContainer:SetActive(false)
    self.getTenContainer.gameObject:SetActive(false)
    if self.tenEffectList ~= nil then
        for i,v in ipairs(self.tenEffectList) do
             v.firstEffect:SetActive(false)
             v.secondEffect:SetActive(false)
        end
    end

    if self.openArgs[1] ~= nil then
        if self.openArgs[1] == ToyRewardEumn.Type.One then
              if self.openArgs[3] == nil then
                self.openArgs[3] = 1
              end

              self.getOneIcon.gameObject:SetActive(false)
              self.getOneContainer:SetActive(true)
              self.getOneIcon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures,"egg".. self.openArgs[3])
              -- self.getOneIcon:GetComponent(Image):SetNativeSize()
              self.getOneIcon.sizeDelta = Vector2(96, 112)
              self.ontEgg.gameObject:SetActive(false)
              self.ontEgg:JumpOut()
              self:Lock()
        elseif self.openArgs[1] == ToyRewardEumn.Type.Ten then
              self.getTenContainer.gameObject:SetActive(true)
              if self.openArgs[3] == nil then
                  self.openArgs[3] = 1
              end

              for i,v in ipairs(self.tenIcon) do
                  local t = (self.openArgs[3] + i) % 4 + 1
                  self.openArgs[3] = t
                  v.gameObject:SetActive(false)
                  v:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures,"egg".. t)
                  -- v:GetComponent(Image):SetNativeSize()
                  v.sizeDelta = Vector2(64, 72)
              end
              self:EndJump()
              self.jumpCount = 0
              self.jumpId = LuaTimer.Add(0, 50, function() self:LoopJump() end)
        end
    end

    self:ShowBtnTime(10, 1)
end

function ToyRewardGetPanel:LoopJump()
    if self.jumpCount >= 10 then
        self:EndJump()
        self:Lock()
        return
    end
    self.jumpCount = self.jumpCount + 1
    local egg = self.eggList[self.jumpCount]
    egg:JumpOut()
end

function ToyRewardGetPanel:EndJump()
    if self.jumpId ~= nil then
        LuaTimer.Delete(self.jumpId)
        self.jumpId = nil
    end
end

function ToyRewardGetPanel:ClickOpen()
  if self.showing then
      return
  end

  if self.currentChange ~= self.hasOpen then
    if self.hasOpen == false  then
        self.showing = true
        self:ShowEffect()
        self.currentChange = false
    elseif self.hasOpen == true  then
        self:Hiden()
    end
  end
end

function ToyRewardGetPanel:ShowEffect()
  self.hasOpen = true
	if self.openArgs[1] ~= nil then
		if self.openArgs[1] == ToyRewardEumn.Type.One then
			if self.oneEffect == nil then
	      self.oneEffect = BibleRewardPanel.ShowEffect(20331,self.gameObject.transform,Vector3(1,1,1),Vector3(0,0,-400))
	    else
	      self.oneEffect:SetActive(true)
	    end
      self.getOneIcon.gameObject:SetActive(false)
    elseif self.openArgs[1] == ToyRewardEumn.Type.Ten then
      if self.itemList ~= nil and self.tenEffectList ~= nil then
          for i,v in ipairs(self.itemList) do
            self.tenIcon[i].gameObject:SetActive(false)
    	   	  if self.tenEffectList[i] == nil then
              self.tenEffectList[i] = {}
    	   	   	self.tenEffectList[i].firstEffect = BibleRewardPanel.ShowEffect(20331,v.gameObject.transform.parent,Vector3(1,1,1),Vector3(0,0,-400))
              self.tenEffectList[i].secondEffect = BibleRewardPanel.ShowEffect(20333,v.gameObject.transform.parent,Vector3(1,1,1),Vector3(0,0,-400))
    	   	  else
    	   	   	self.tenEffectList[i].firstEffect:SetActive(true)
    	   	  end
          end
      end
    end
  end
  self.effectShowId = LuaTimer.Add(300,function() self:SetItem() end)
end

function ToyRewardGetPanel:SetItem()
    if self.openArgs[1] ~= nil then
        if self.openArgs[1] == ToyRewardEumn.Type.One then
               if self.oneNextEffect == nil then
                  self.oneNextEffect = BibleRewardPanel.ShowEffect(20333,self.gameObject.transform,Vector3(1,1,1),Vector3(0,0,-400))
               else
                  self.oneNextEffect:SetActive(true)
               end
        elseif self.openArgs[1] == ToyRewardEumn.Type.Ten then
                if self.tenEffectList ~= nil then
                    for i,v in ipairs(self.tenEffectList) do
                         v.firstEffect:SetActive(false)
                         v.secondEffect:SetActive(true)
                    end
                end
        end
    end

    if self.openArgs[1] ~= nil then
	     if self.openArgs[1] == ToyRewardEumn.Type.Ten then
            local data = OpenBetaManager.Instance.model.rewardTenList
            for i,v in ipairs(data) do
                local baseId = DataCampTurn.data_item[v].item_id
                local num = DataCampTurn.data_item[v].num
                local myData = DataItem.data_get[baseId]
              	self.itemList[i]:SetAll(myData,self.extra)
              	self.itemList[i].gameObject:SetActive(true)
                if num > 1 then
                    self.eggList[i]:SetName(ColorHelper.color_item_name(myData.quality, string.format("%sx%s", myData.name, num)))
                else
                    self.eggList[i]:SetName(ColorHelper.color_item_name(myData.quality, string.format("%s", myData.name)))
                end
            end
         elseif self.openArgs[1] == ToyRewardEumn.Type.One then
         	    local id = self.openArgs[2]
              local baseId = DataCampTurn.data_item[id].item_id
              local num = DataCampTurn.data_item[id].num
              local myData = DataItem.data_get[baseId]
             	self.getOneItem:SetAll(myData,self.extra)
             	self.getOneItem.gameObject:SetActive(true)
              if num > 1 then
                  self.ontEgg:SetName(ColorHelper.color_item_name(myData.quality, string.format("%sx%s", myData.name, num)))
              else
                  self.ontEgg:SetName(ColorHelper.color_item_name(myData.quality, string.format("%s", myData.name)))
              end
         end
    end

    OpenBetaManager.Instance:send14040()
    self:ShowBtnTime(3, 2)
    self:Lock()
end


function ToyRewardGetPanel:OnHide()
    self.parent:PanelClosed()
    self:EndLock()
    self:EndTime()
    self:EndJump()

    if self.effectShowId ~= nil then
        LuaTimer.Delete(self.effectShowId)
        self.effectShowId = nil
    end

    if self.eggList ~= nil then
        for i,v in ipairs(self.eggList) do
            v:EndTween()
            v:SetName("")
        end
    end

    if self.ontEgg ~= nil then
        self.ontEgg:EndTween()
        self.ontEgg:SetName("")
    end

  	if self.itemList ~= nil then
    		for i,v in ipairs(self.itemList) do
    			v.gameObject:SetActive(false)
    		end
  	end

  	if self.getOneItem ~= nil then
  		  self.getOneItem.gameObject:SetActive(false)
  	end

  	if self.tenEffectList ~= nil then
    		for i,v in ipairs(self.tenEffectList) do
    			 v.firstEffect:SetActive(false)
           v.secondEffect:SetActive(false)
    		end
  	end

  	if self.oneEffect ~= nil then
  		  self.oneEffect:SetActive(false)
  	end

    if self.oneNextEffect ~= nil then
        self.oneNextEffect:SetActive(false)
    end

    self.getOneIcon.gameObject:SetActive(false)

    if self.tenIcon ~= nil then
        for i,v in ipairs(self.tenIcon) do
            v.gameObject:SetActive(false)
        end
    end
end

function ToyRewardGetPanel:AddUIChild(parentObj, childObj)
       local trans = childObj.transform
       trans:SetParent(parentObj.transform)
       trans.localScale = Vector3.one
       trans.localPosition = Vector3.zero
       trans.localRotation = Quaternion.identity

       local rect = childObj:GetComponent(RectTransform)
       rect.anchorMax = Vector2.one
       rect.anchorMin = Vector2.zero
       rect.offsetMin = Vector2.zero
       rect.offsetMax = Vector2.zero
       rect.localScale = Vector3.one
       rect.localPosition = Vector3.zero
       rect.anchoredPosition = Vector2.zero
       childObj:SetActive(true)
end

function ToyRewardGetPanel:ShowBtnTime(count, type)
    self:EndTime()
    if type == 2 then
        self.openTxt.text = TI18N("确定")
    else
      self.count = count
      self.timeId = LuaTimer.Add(0, 1000, function() self:LoopTime(type) end)
    end
end

function ToyRewardGetPanel:LoopTime(type)
    if self.count <= 0 then
        self:EndTime()
        self:ClickOpen()
        return
    end

    if type == 1 then
        self.openTxt.text = string.format(TI18N("一键打开(%ss)"), self.count)
    else
        self.openTxt.text = string.format(TI18N("确定(%ss)"), self.count)
    end
    self.count = self.count - 1
end

function ToyRewardGetPanel:EndTime()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
end

function ToyRewardGetPanel:Lock()
    self:EndLock()
    self.lockId = LuaTimer.Add(1000, function() self.showing = false end)
end

function ToyRewardGetPanel:EndLock()
    if self.lockId ~= nil then
        LuaTimer.Delete(self.lockId)
        self.lockId = nil
    end
end