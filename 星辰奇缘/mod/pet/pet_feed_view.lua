-- ----------------------------------------------------------
-- UI - 宠物窗口 主窗口
-- ----------------------------------------------------------
PetFeedView = PetFeedView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetFeedView:__init(model)
    self.model = model
    self.name = "PetFeedView"
    self.windowId = WindowConfig.WinID.pet_feed
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.pet_feed_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
	self.currentIndex = 0

	self.childIndex = {
		happy = 1,
		quality = 2,
	}

	------------------------------------------------
	self.tabGroup = nil
	self.tabGroupObj = nil

	self.childTab = {}

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetFeedView:__delete()
    self:OnHide()
    if self.childTab ~= nil then
        for _,tab in pairs(self.childTab) do
            if tab ~= nil then
                tab:DeleteMe()
            end
        end
        self.childTab = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
end

function PetFeedView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_feed_window))
    self.gameObject.name = "PetFeedView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")

    local setting = {
        notAutoSelect = true,
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, setting)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetFeedView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetFeedView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 and self.currentIndex ~= self.openArgs[1] then
        self.tabGroup:ChangeTab(self.openArgs[1])
        return
    end
    if self.currentIndex == 0 then
        self.tabGroup:ChangeTab(1)
        return
    end
	local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Show()
    end
end

function PetFeedView:OnHide()
	local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
end

function PetFeedView:ChangeTab(index)
	if self.currentIndex ~= 0 and self.currentIndex ~= index then
        self.childTab[self.currentIndex]:Hiden()
    end
    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == self.childIndex.happy then
        	child = PetFeedView_Happy.New(self)
        elseif index == self.childIndex.quality then
            child = PetFeedView_Quality.New(self)
        end
        self.childTab[self.currentIndex] = child
    end
    child:Show()
end
