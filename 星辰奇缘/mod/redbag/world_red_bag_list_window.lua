-- ----------------------------------------------------------
-- UI - 世界红包列表窗口
-- ----------------------------------------------------------
WorldRedBagListWindow = WorldRedBagListWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function WorldRedBagListWindow:__init(model)
    self.model = model
    self.name = "WorldRedBagListWindow"
    self.windowId = WindowConfig.WinID.world_red_bag_list_win
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.world_red_bag_list_win, type = AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	self.container = nil
	self.cloneItem = nil

	self.itemList = {}
	------------------------------------------------
	
    ------------------------------------------------
    self._Update = function() self:Update() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldRedBagListWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function WorldRedBagListWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_red_bag_list_win))
    self.gameObject.name = "WorldRedBagListWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("MainCon")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.container = self.mainTransform:FindChild("Mask/Container").gameObject
    self.cloneItem = self.mainTransform:FindChild("CloneItem").gameObject
    self.cloneItem:SetActive(false)

   	self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButtonClick() end)

    self.noRedBag = self.mainTransform:FindChild("NoRedBag").gameObject
    self.mainTransform:FindChild("NoRedBag/Button"):GetComponent(Button).onClick:AddListener(function() self:OnOkButtonClick() end)
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function WorldRedBagListWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function WorldRedBagListWindow:OnShow()
	self:Update()

    RedBagManager.Instance.OnUpdateRedBag:Add(self._Update)
    RedBagManager.Instance:Send18500()
end

function WorldRedBagListWindow:OnHide()
	RedBagManager.Instance.OnUpdateRedBag:Remove(self._Update)
end

function WorldRedBagListWindow:Update()
	local redBagData = self.model.red_packet

    if #redBagData == 0 then
        self.noRedBag:SetActive(true)

        for i=1, #self.itemList do
            local item = self.itemList[i]
            if item ~= nil then
                item:SetActive(false)
            end
        end
    else
        self.noRedBag:SetActive(false)

    	for i=1, #redBagData do
    		local data = redBagData[i]
            local item = self.itemList[i]

            if item == nil then
                item = GameObject.Instantiate(self.cloneItem)
                item:SetActive(true)
                item.transform:SetParent(self.container.transform)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                self.itemList[i] = item
            end

            item:SetActive(true)
            item.transform:FindChild("RedBagText"):GetComponent(Text).text = data.title
            item.transform:FindChild("NameText"):GetComponent(Text).text = data.name

            if data.type ~= 2 then
                item.transform:FindChild("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "RedBagTxt")
            else
                item.transform:FindChild("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "Lock")
            end

            local hasGet = false
            local roleData = RoleManager.Instance.RoleData
            if data.log ~= nil then
                for _,log in pairs(data.log) do
                    if log.grabid == roleData.id and log.gplatform == roleData.platform and log.gzone_id == roleData.zone_id then
                        hasGet = true
                    end
                end
            end

            local stateImage = item.transform:FindChild("StateImage")
            if data.num == 0 then
                stateImage.gameObject:SetActive(true)
                stateImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "HaveRobbedTheLight")
            elseif hasGet then
                stateImage.gameObject:SetActive(true)
                stateImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "AlreadyReceive")
            else
                stateImage.gameObject:SetActive(false)
            end

            local button = item:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:OnItemClick(data) end)
    	end

        for i=#redBagData+1, #self.itemList do
            local item = self.itemList[i]
            if item ~= nil then
                item:SetActive(false)
            end
        end
    end
end

function WorldRedBagListWindow:OnItemClick(data)
    RedBagManager.Instance:Send18505(data.rid, data.platform, data.zone_id)
end

function WorldRedBagListWindow:OnOkButtonClick()
    local roleData = RoleManager.Instance.RoleData
    for _,value in pairs(self.model.red_packet) do
        if self.model.is_over == 0 and value.rid == roleData.id and value.zone_id == roleData.zone_id and value.platform == roleData.platform then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("你当前还有红包没有被抢完，要再发到世界频道吗？")
            data.sureLabel = TI18N("发送")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() 
                self:OnClickClose()
                RedBagManager.Instance:Send18502(value.type, 1, 1, value.title)  
            end
            NoticeManager.Instance:ConfirmTips(data)
            return
        end
    end

    -- self:OnClickClose()
	RedBagManager.Instance.model:InitRedBagSetUI()
end

