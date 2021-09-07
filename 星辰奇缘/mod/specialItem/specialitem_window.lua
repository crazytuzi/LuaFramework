--2017/5/6
--zyh
--超值礼包
SpecialItemWindow = SpecialItemWindow or BaseClass(BaseWindow)

function SpecialItemWindow:__init(model)
	self.model = model
	self.mgr = SpecialItemWindow.Instance

	self.resList = {
	   {file = AssetConfig.specialitem_window,type = AssetType.Main,holdTime = 5}
	  ,{file = AssetConfig.specialitem_texture,type = AssetType.Dep}
	  -- ,{file  =  AssetConfig.firstrechargedeveloptexture,type = AssetType.Dep}
	  ,{file = AssetConfig.specialitem_bigbg,type = AssetType.Dep}
    ,{file = AssetConfig.grild_bigbg,type = AssetType.Dep}
	  -- ,{file = AssetConfig.specialitem_text_bigbg,type = AssetType.Main}
	  -- ,{file = AssetConfig.specialitem_icon_bigbg,type = AssetType.Main}

    }

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.specialitem_window

    self.refreshData = function() self:RefreshData() end
    self.itemDataList = {}
    self.itemList = {}
    self.itemEffectList = {}

    self.distance = 5
    self.tagetIndex = 0
    self.effTimerId = nil

    self.topImgLoader = nil
    self.leftImgLoader = nil
    self.rightImgLoader = nil
    self.extra = {inbag = false, nobutton = true}
end

function SpecialItemWindow:__delete()
    if self.grildBigBg ~= nil and self.grildBigBg.sprite ~= nil then
      self.grildBigBg.sprite = nil
    end
    if self.topImgLoader ~= nil then
        self.topImgLoader:DeleteMe()
        self.topImgLoader = nil
    end

     if self.leftImgLoader ~= nil then
        self.leftImgLoader:DeleteMe()
        self.leftImgLoader = nil
    end

     if self.rightImgLoader ~= nil then
        self.rightImgLoader:DeleteMe()
        self.rightImgLoader = nil
    end




	if self.effTimerId ~= nil then
		LuaTimer.Delete(self.effTimerId)
		self.effTimerId = nil
	end

	 if self.itemEffectList ~= nil then
        for i,v in ipairs(self.itemEffectList) do
          v:DeleteMe()
        end
        self.itemEffectList = {nil}
     end

     if self.itemList ~= nil then
     	for i,v in ipairs(self.itemList) do
     		v:DeleteMe()
     	end
     	self.itemList = {}
     end

     if self.itemLayout ~= nil then
     	self.itemLayout:DeleteMe()
     end
     if self.topLayout ~= nil then
     	self.topLayout:DeleteMe()
     end
     if self.leftLayout ~= nil then
     	self.leftLayout:DeleteMe()
     end
     if self.rightLayout ~= nil then
     	self.rightLayout:DeleteMe()
     end

     if self.gameObject ~= nil then
     	GameObject.DestroyImmediate(self.gameObject)
     	self.gameObject = nil
     end
     self:AssetClearAll()

end

function SpecialItemWindow:RemoveListeners()
end


function SpecialItemWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.specialitem_window))
	self.gameObject.name = "SpecialItemWindow"

	UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

	local t = self.gameObject.transform

	self.transform = t

	self.bigBgImg  = t:Find("MainCon/Bg/BigBg/BackGround"):GetComponent(Image)
  self.bigBgImg.sprite =self.assetWrapper:GetSprite(AssetConfig.specialitem_bigbg,"I18NSpecialBigBg")

	t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
  self.grildBigBg = t:Find("MainCon/Bg/Grild"):GetComponent(Image)
  self.grildBigBg.sprite = self.assetWrapper:GetSprite(AssetConfig.grild_bigbg,"grild")



	-- self.bigTextBg = t:Find("MainCon/Bg/TextBg")
	-- bigObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.specialitem_text_bigbg))
	-- UIUtils.AddBigbg(self.bigTextBg,bigObject)
	-- bigObject.transform.anchoredPosition = Vector2(0,0)


	-- self.bigIconBg = t:Find("MainCon/Bg/IconBg")
	-- bigObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.specialitem_icon_bigbg))
	-- UIUtils.AddBigbg(self.bigIconBg,bigObject)
	-- bigObject.transform.anchoredPosition = Vector2(0,0)


	self.scrollRectRtr = t:Find("MainCon/ScrollRect"):GetComponent(RectTransform)
	self.scrollRectRtr.anchoredPosition = Vector2(-22,-11)
    self.scrollRectTT = t:Find("MainCon/ScrollRect"):GetComponent(ScrollRect)
    self.scrollRectTT.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)


	self.itemContainer = t:Find("MainCon/ScrollRect/ImageContainer")

	self.button = t:Find("MainCon/ConfirmButton"):GetComponent(Button)
	self.button.onClick:AddListener(function() self:ApplyButton() end)

	self.itemLayout = LuaBoxLayout.New(self.itemContainer.gameObject,{axis = BoxLayoutAxis.X, border = self.distance})


    self.numTemplate = t:Find("MainCon/NumTemplate")

    self.topContainer = t:Find("MainCon/TopContainer")
    self.topContainer.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-57,138)
    self.topLayout = LuaBoxLayout.New(self.topContainer.gameObject,{axis = BoxLayoutAxis.X, cspacing = 3,border = -5})
    self.topIconImg = t:Find("MainCon/TopIcon"):GetComponent(Image)

    self.leftContainer = t:Find("MainCon/LeftIcon/LeftContainer")
    self.leftContainer.transform:GetComponent(RectTransform).anchoredPosition = Vector2(82,8)
    self.leftLayout = LuaBoxLayout.New(self.leftContainer.gameObject,{axis = BoxLayoutAxis.X, cspacing = 0.1,border = - 4})
    self.leftIconImg = t:Find("MainCon/LeftIcon/Icon"):GetComponent(Image)

    self.rightContainer = t:Find("MainCon/RightIcon/RightContainer")
    self.rightContainer.transform:GetComponent(RectTransform).anchoredPosition = Vector2(36,8)
    self.rightLayout = LuaBoxLayout.New(self.rightContainer.gameObject,{axis = BoxLayoutAxis.X, cspacing = 0.1,border = -4})
    self.rightIconImg = t:Find("MainCon/RightIcon/Icon"):GetComponent(Image)
    self.rightIconImg:GetComponent(RectTransform).anchoredPosition = Vector2(99,10)

	self:OnOpen()
end

function SpecialItemWindow:OnOpen()
  print("=================================")
  ------------------------------打印出当前栈
  BaseUtils.dump(self.openArgs,"参数===========================")
  print(debug.traceback())
	if self.openArgs ~= nil then
	   self.rewardId = self.openArgs[1]
	end
    self:SetDataItem()
    self:SetBaseData()
    self:OnRectScroll({x = 0})
    if self.effTimerId == nil then
   		 self.effTimerId = LuaTimer.Add(1000, 3000, function()
		        self.button.gameObject.transform.localScale = Vector3(1.1,1.1,1)
		        Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
		    end)
   	end
end

function SpecialItemWindow:SetBaseData()
	local strLenghtOne = string.len(tostring(DataMonthGift.data_specialitem[self.tagetIndex].origin_price[1][2]))
	local strLenghtTwo = string.len(tostring(DataMonthGift.data_specialitem[self.tagetIndex].price[1][2]))
    local imageId1 = DataMonthGift.data_specialitem[self.tagetIndex].origin_price[1][1]
    local iconId1 = DataItem.data_get[imageId1].icon

    local imageId2 = DataMonthGift.data_specialitem[self.tagetIndex].price[1][1]
    local iconId2 = DataItem.data_get[imageId2].icon

    for i=1,strLenghtOne do

    	local gameObjectTwo = GameObject.Instantiate(self.numTemplate.gameObject)
    	gameObjectTwo.transform:GetComponent(RectTransform).sizeDelta = Vector2(25,34)
    	local str = string.sub(tostring(DataMonthGift.data_specialitem[self.tagetIndex].origin_price[1][2]),i,i)

    	local iconStr = "number" .. tostring(str)

    	gameObjectTwo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.specialitem_texture,iconStr)


        self.leftLayout:AddCell(gameObjectTwo)
    end


    for i=1,strLenghtTwo do
    	local gameObjectOne = GameObject.Instantiate(self.numTemplate.gameObject)
    	gameObjectOne.transform:GetComponent(RectTransform).sizeDelta = Vector2(25,34)

    	local gameObjectTwo = GameObject.Instantiate(self.numTemplate.gameObject)
    	gameObjectTwo.transform:GetComponent(RectTransform).sizeDelta = Vector2(30,38)

    	local str = string.sub(tostring(DataMonthGift.data_specialitem[self.tagetIndex].price[1][2]),i,i)
        local iconStr = "number" .. tostring(str)
        print(iconStr)

        gameObjectOne.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.specialitem_texture,iconStr)
        gameObjectTwo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.specialitem_texture,iconStr)
    	self.rightLayout:AddCell(gameObjectOne)
    	self.topLayout:AddCell(gameObjectTwo)
    end

    if self.leftImgLoader == nil then
        local go = self.leftIconImg.gameObject
        self.leftImgLoader = SingleIconLoader.New(go)
    end
    self.leftImgLoader:SetSprite(SingleIconType.Item, iconId1)



    if self.topImgLoader == nil then
        local go = self.topIconImg.gameObject
        self.topImgLoader = SingleIconLoader.New(go)
    end
    self.topImgLoader:SetSprite(SingleIconType.Item, iconId2)


    if self.rightImgLoader == nil then
        local go = self.rightIconImg.gameObject
        self.rightImgLoader = SingleIconLoader.New(go)
    end
    self.rightImgLoader:SetSprite(SingleIconType.Item, iconId2)


end



function SpecialItemWindow:SetDataItem()
	self.itemDataList = {}
	local data = DataMonthGift.data_specialitem
	for k,v in pairs(data) do
	-- if v.gift_id == self.rewardId and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData <= v.max_lev and ((RoleManager.Instance.RoleData.sex == v.sex) or (v.sex == 2)) and RoleManager.Instance.RoleData.lev_break_times >= v.min_lev_break and RoleManager.Instance.RoleData.lev_break_times <= v.max_lev_break then
   	    if v.gift_id == self.rewardId and ((RoleManager.Instance.RoleData.sex == v.sex) or (v.sex == 2)) then
			self.tagetIndex = k
			table.insert(self.itemDataList,v)

		end
	end


    local nownum = 0
    for i,v in pairs(self.itemDataList) do
    	nownum = nownum + 1
    	local id = v.item_id
        local num = v.num
        local itemtype = v.type
        local nowData = DataItem.data_get[id]
    	if self.itemList[nownum] ~= nil then
    	    self.itemList[nownum].gameObject:SetActive(true)
    	    self.itemList[nownum]:SetAll(nowData,self.extra)
    	    self.itemList[nownum]:SetNum(num)
    	else
    		local itemSlot = ItemSlot.New()
    		itemSlot:SetAll(nowData,self.extra)
    		itemSlot:SetNum(num)
    		self.itemList[nownum] = itemSlot
    		self.itemLayout:AddCell(itemSlot.gameObject)
    	end


        if itemtype >= 2 then
          if self.itemEffectList[nownum] == nil then
              self.itemEffectList[nownum] = BibleRewardPanel.ShowEffect(20223,self.itemList[nownum].transform, Vector3(1, 1, 1), Vector3(32,0, -400))
          else
            self.itemEffectList[nownum]:SetActive(true)
          end
        else
          if self.itemEffectList[nownum] ~= nil then
            self.itemEffectList[nownum]:SetActive(false)
          end
        end
    end
    local lenghtNum = #self.itemDataList
    if lenghtNum > 5 then
    	lenghtNum = 5
    	self.scrollRectRtr.transform:GetComponent(ScrollRect).movementType = 1
    else
    	self.scrollRectRtr.transform:GetComponent(ScrollRect).movementType = 2
    end
    self.scrollRectRtr.sizeDelta = Vector2(lenghtNum * 64 + lenghtNum * self.distance,self.scrollRectRtr.sizeDelta.y)

end


function SpecialItemWindow:ApplyButton()
    local itemData = DataItem.data_get[self.rewardId]
    local quantity = itemData.quantity
    if self.openArgs ~= nil then

	    BackpackManager.Instance:Send10315(self.openArgs[2],self.openArgs[3])
      WindowManager.Instance:CloseWindow(self)
	end
end


function SpecialItemWindow:OnRectScroll(value)
  if #self.itemDataList > 5 then
    local Left = (value.x-1)*(self.scrollRectTT.content.sizeDelta.x - 345) + 172.5 - 62
    local Right = Left + 345 + 128
    for i,v in ipairs(self.itemList) do
      local ax = v.transform.anchoredPosition.x
      local sx = v.transform.sizeDelta.x

      if ax + sx > Right or ax < Left then
          v.gameObject:SetActive(false)
      else
          v.gameObject:SetActive(true)
      end
    end
   end
end