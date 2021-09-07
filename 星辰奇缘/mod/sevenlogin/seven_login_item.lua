SevenLoginItem = SevenLoginItem or BaseClass()

function SevenLoginItem:__init(gameObject,isHasDoubleClick,id,parent)
	self.id = id
	self.gameObject = gameObject
	self.parent = parent
	self.isHasDoubleClick = isHasDoubleClick
    local resources = {
      {file = AssetConfig.seven_login_panel_texture, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)

    self.itemSlotEffect = nil
    self.data = nil

    self.extra = {inbag = false, nobutton = true}

    -- local time = DataCampaign.data_list[582].cli_start_time[1]
    -- self.beginTime = tonumber(os.time{year = time[1], month = time[2], day = time[3], hour = time[4], min = time[5], sec = time[6]})

    self.activeDays = 0
    self.maxGetDays = 0
    self.rewardList = {}

    self.tipsPanel = nil

    self:InitPanel()
end


function SevenLoginItem:InitPanel()
    local t = self.gameObject.transform
    self.itemObj = t:Find("Bg/ItemMiddle/ItemSlot").gameObject
    self.ItemSlot = ItemSlot.New(self.itemObj,self.isHasDoubleClick)

    self.BgImage = t:Find("Bg"):GetComponent(Image)

    self.rotationBgTr = t:Find("Bg/ItemMiddle/Bg")
    self.rotationImage = t:Find("Bg/ItemMiddle/Bg"):GetComponent(Image)

    local top = t:Find("Bg/ItemTop")
    self.topImage = top:Find("ItemTopBg"):GetComponent(Image)
    self.topText = top:Find("Text"):GetComponent(Text)


    local bottom = t:Find("Bg/ItemBottom")
    self.bottomImage = bottom:Find("ItemBottomBg"):GetComponent(Image)
    self.bottomText = bottom:Find("Text"):GetComponent(Text)

    self.tag = t:Find("Bg/SecondayIcon")
    self.tag.gameObject:SetActive(false)

    self.tagText = t:Find("Bg/SecondayIcon/Text"):GetComponent(Text)


    self.hasGetPanel = t:Find("Bg/HasGetPanel")
    self.hasGetPanel.gameObject:SetActive(false)


    -- local bottonContainer = t:Find("ButtonContainer")
    -- self.canLoginButton = bottonContainer:Find("CanLogin"):GetComponent(Button)
    -- self.canLoginButton.gameObject:SetActive(false)
    -- self.canLoginText = bottonContainer:Find("CanLogin/Text"):GetComponent(Text)

    -- self.hasLoginButton = bottonContainer:Find("HasLogin"):GetComponent(Button)
    -- self.hasLoginButton.gameObject:SetActive(false)
    -- self.hasLoginText = bottonContainer:Find("HasLogin/Text"):GetComponent(Text)


    self.bgButton = t:Find("Bg/BgButton"):GetComponent(Button)
    self.bgButton.onClick:AddListener(function() self:BgClick() end)

    self:OnOpen(data)
end

-- function SevenLoginItem:RotationBg()
-- 	self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
-- end

-- function SevenLoginItem:RotationChange(value)
--    self.rotationBgTr.localRotation = Quaternion.Euler(0, 0, value)
-- end

function SevenLoginItem:__delete()
    if self.ItemSlot ~= nil then
    	self.ItemSlot:DeleteMe()
    end

    if self.itemSlotEffect ~= nil then
        self.itemSlotEffect:DeleteMe()
    end

  --   if self.rotationTweenId ~= nil then
	 -- 	Tween.Instance:Cancel(self.rotationTweenId)
	 -- 	self.rotationTweenId = nil
	 -- end
end

function SevenLoginItem:OnOpen()


	-- self:RotationBg()
    self:SetBaseData()

    -- self.data = BibleManager.Instance.sevenLoginData
    -- --获取协议数据
    -- self:SetData(data)
end


function SevenLoginItem:SetBaseData()
    self.rewardList = {}
	self.topText.text = SevenLoginEumn.Type[self.id]
    self.tagText.text = SevenLoginEumn.Type[self.id]


    for i,v in ipairs(DataCampSign.data_sevenlogin[self.id].item_list) do
        if v[4] == 2 or v[4] == RoleManager.Instance.RoleData.sex then
            table.insert(self.rewardList,v)
        end
    end

	local baseid = self.rewardList[1][1]
	local data = DataItem.data_get[baseid]
    self.tagText.text = SevenLoginEumn.Type[self.id]
	self.ItemSlot:SetAll(data,self.extra)
    self.ItemSlot:SetNum(DataCampSign.data_sevenlogin[self.id].item_list[1][3])
	self.bottomText.text = DataCampSign.data_sevenlogin[self.id].name

	-- if self.id == 7 then
	-- 	self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"reditemtop")
	-- 	self.BgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"reditemmiddle")
	-- 	self.rotationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"redflashbg")
	-- end
end

function SevenLoginItem:SetData(data)
	local baseTime = BaseUtils.BASE_TIME
	-- if baseTime > self.beginTime then
 --    	local distanceTime = baseTime - self.beginTime

 --    	self.activeDays = math.floor(distanceTime/86400)
 --    else
 --    	self.canLoginButton.gameObject:SetActive(true)
 --        self.canLoginButton.onClick:RemoveAllListeners()

 --    	self.hasLoginButton.gameObject:SetActive(false)

    if data.num + 1 == self.id and data.flag == 0 then
        if self.itemSlotEffect == nil then
           self.itemSlotEffect = BibleRewardPanel.ShowEffect(20361,self.gameObject.transform,Vector3(0.77, 0.75, 1),Vector3(63.3,-74.9,-20))
        end
        self.itemSlotEffect:SetActive(true)
    else
        if self.itemSlotEffect~= nil then
            self.itemSlotEffect:SetActive(false)
        end
    end

    if self.id <= data.num then
        self.hasGetPanel.gameObject:SetActive(true)
    end

    --     self.canLoginText.text = "领取"
    --     return
    -- end
 --    print("活动天数" .. self.activeDays)

	-- self.data = data

 --    self.maxGetDays = self.data.num

 --    local isHasGet = false
	-- for k,v in pairs(data.days) do
	-- 	if self.id == v.day then
	-- 		self.canLoginButton.gameObject:SetActive(false)
 --    	    self.hasLoginButton.gameObject:SetActive(true)

 --    	    if self.signRewardEffect ~= nil then
 --        		self.signRewardEffect:SetActive(false)
 --        	end
 --        	isHasGet = true
 --        end

 --        if v.day > self.maxGetDays then
 --        	self.maxGetDays = v.day
 --        end
	-- end

	-- if isHasGet == true then
 --       return
 --    end
 --    -- 协议天数变化的时候也应该接

	-- if self.id <= data.num then
	-- 	self.canLoginButton.gameObject:SetActive(true)
	-- 	self.canLoginButton.onClick:RemoveAllListeners()
	-- 	self.canLoginButton.onClick:AddListener(function() self:GetReward() end)

 --    	self.hasLoginButton.gameObject:SetActive(false)


 --    	if self.signRewardEffect == nil then
 --           self.signRewardEffect = BibleRewardPanel.ShowEffect(20053,self.canLoginButton.transform,Vector3(1.4, 0.6, 1),Vector3(-46.5, -14.5, -400))
 --        end
 --        self.signRewardEffect:SetActive(true)
 --        self.canLoginText.text = "领取"

 --    elseif data.num < self.id and self.id <= self.activeDays then
 --    	self.canLoginButton.gameObject:SetActive(true)
 --    	self.canLoginButton.onClick:RemoveAllListeners()
	-- 	self.canLoginButton.onClick:AddListener(function() self:PopTips() end)

 --    	self.hasLoginButton.gameObject:SetActive(false)


 --    	if self.signRewardEffect ~= nil then
 --           self.signRewardEffect:SetActive(false)
 --        end
 --        self.canLoginText.text = "补领"
 --     else
 --        self.canLoginButton.gameObject:SetActive(true)
 --        self.canLoginButton.onClick:RemoveAllListeners()

 --    	self.hasLoginButton.gameObject:SetActive(false)


 --    	if self.signRewardEffect ~= nil then
 --           self.signRewardEffect:SetActive(false)
 --        end
 --        self.canLoginText.text = "领取"
 --     end

end

function SevenLoginItem:OnHide()

end


function SevenLoginItem:GetReward()
	self.parent.rewardId = self.id
	NewLabourManager.Instance:send14029({day = self.id})
end

-- function SevenLoginItem:PopTips()
--     local num = DataCampLogin.data_base[self.id].cost[1][2]
--     local baseId = DataCampLogin.data_base[self.id].cost[1][1]
--     local data = DataItem.getGetFunc(baseId)
--     local name = data.name

--     if self.id == self.maxGetDays +1 then
--          local data = NoticeConfirmData.New()
--          data.type = ConfirmData.Style.Normal
--          data.content = string.format(TI18N("是否消耗%d%s进行补领"),num,name)
--          data.sureLabel = TI18N("确认")
--          data.cancelLabel = TI18N("取消")
--          data.sureCallback = function ()
--              self.parent.rewardId = self.id
--              -------------------------------------------------------
--              NewLabourManager.Instance:send14029({day = self.id})
--          end
--          NoticeManager.Instance:ConfirmTips(data)
--     else
--     	NoticeManager.Instance:FloatTipsByString("需在前一天奖励领取后才能补签哟{face_1,3}")
--     end
-- end


function SevenLoginItem:BgClick()
    -- self.parent:ChangeBgId(self.id)

    if #self.rewardList <=1 then
    	 local baseId = self.rewardList[1][1]
    	 local data = DataItem.data_get[baseId]
    	 local itemData = ItemData.New()
         itemData:SetBase(data)
         TipsManager.Instance:ShowItem({gameObject = self.ItemSlot.gameObject, itemData = itemData,extra = self.extra})
    else


        if self.tipsPanel == nil then
             self.tipsPanel = SevenLoginTipsPanel.New(self)
         end
         self.tipsPanel:Show({self.rewardList})
    end

    -- self.parent:CloseItemEffect()
end

function SevenLoginItem:SetTag(t)
    if t == true then
        self.tag.gameObject:SetActive(true)
    else
        self.tag.gameObject:SetActive(false)
    end
end

-- function SevenLoginItem:SetItemSlotEffect(t)
--     if t == true then
--         if self.itemSlotEffect == nil then
--            self.itemSlotEffect = BibleRewardPanel.ShowEffect(20361,self.gameObject.transform,Vector3(0.68, 0.68, 1),Vector3(56,-62, -400))
--         end
--         self.itemSlotEffect:SetActive(true)
--     else
--         if self.itemSlotEffect~= nil then
--             self.itemSlotEffect:SetActive(false)
--         end
--     end
-- end

-- function SevenLoginItem:SetColorRed(isRed)
-- 	if isRed == true then
-- 		self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"reditemtop")
-- 		self.BgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"reditemmiddle")
-- 		self.rotationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"redflashbg")
-- 	else
-- 		self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"blueitemtop")
-- 		self.BgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"blueitemmiddle")
-- 		self.rotationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"blueflashbg")
-- 	end

-- end



-- function SevenLoginItem:SetQualityInBag(quality)
--     quality = quality or 0
--     quality = quality + 1
--     if quality < 5 then
--         self.ItemSlot.qualityBg.gameObject:SetActive(false)
--     else
--         self.ItemSlot.qualityBg.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, string.format("ItemImage%s", quality))
--         self.ItemSlot.gameObject:SetActive(true)
--     end
-- end

-- function SevenLoginItem:SetDefaultQuality()
--     self.ItemSlot.qualityBg.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "ItemImage")
-- end