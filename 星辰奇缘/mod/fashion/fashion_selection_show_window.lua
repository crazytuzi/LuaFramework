FashionSelectionShowWindow  =  FashionSelectionShowWindow or BaseClass(BaseWindow)

function FashionSelectionShowWindow:__init(model)
    self.name  =  "FashionSelectionShowWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_selection_show_window
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.resList  =  {
        {file = AssetConfig.fashion_selection_show_window, type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_show_big_bg, type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_texture, type = AssetType.Dep}
    }

    self.tabShowMount = 3

    self.fashionSelectionItemList = {}
    self.friendItemList = {}
    self.selectionData = nil
    self.sex = RoleManager.Instance.RoleData.sex

    self.showListener = function()  end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FashionSelectionShowWindow:OnHide()


    if self.fashionSelectionItemList ~= nil then
        for i,v in ipairs(self.fashionSelectionItemList) do
            if v ~= nil then
                v:OnHide()
            end
        end
    end


end

function FashionSelectionShowWindow:__delete()
    if self.fashionSelectionItemList ~= nil then
        for i,v in ipairs(self.fashionSelectionItemList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.fashionSelectionItemList = nil
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function FashionSelectionShowWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_show_window))
    self.gameObject.name = "FashionSelectionShowWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

     self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
     self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.fashionContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")
    self.fashionItem = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/FashionItem")
    self.fashionItem.gameObject:SetActive(false)



    self.bigParent = self.transform:Find("MainCon/BigBg")

    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_show_big_bg))
    UIUtils.AddBigbg(self.bigParent,bigObj)

    self.changeSexButton = self.transform:Find("MainCon/TopButton"):GetComponent(Button)
    self.changeSexButton.onClick:AddListener(function() self:ChangeSex() end)


    self.tabLayout = LuaBoxLayout.New(self.fashionContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = -50,border = -125})

    for i=1,self.tabShowMount do
        local go = GameObject.Instantiate(self.fashionItem.gameObject)
        local selectionItem = FashionSelectionShowItem.New(go,self,i)
        self.fashionSelectionItemList[i] = selectionItem
        self.tabLayout:AddCell(go)
    end


    self:OnShow()
end

function FashionSelectionShowWindow:OnShow()
    -- self:RemoveAllListeners()
    -- self:AddAllListeners()
    self.tabIndex = 1


    self:UpdateSelectionItem()
    for i,v in ipairs(self.fashionSelectionItemList) do
        v:OnOpen()
    end
end


function FashionSelectionShowWindow:UpdateSelectionItem()
    for i,v in ipairs(self.fashionSelectionItemList) do
        local suportData  = FashionSelectionManager.Instance.luckyAllRoleData.group[i]
        local data = nil
        if self.sex == RoleManager.Instance.RoleData.sex then
            data = self.model.fashionList[suportData.group_id]
        else
            data = self.model.otherFashionList[suportData.group_id]
        end

        if data ~= nil then
            data.vote_rate = suportData.vote_rate
            data.group_id = suportData.group_id
            v.gameObject:SetActive(true)
            v:SetData(data)

            v:OnOpen()

        else
            v.gameObject:SetActive(false)
        end
    end
end


-- function FashionSelectionShowWindow:AddAllListeners()
--     FashionSelectionManager.Instance.onUpdateRoleShowData:AddListener(self.showListener)
-- end

-- function FashionSelectionShowWindow:RemoveAllListeners()
--     FashionSelectionManager.Instance.onUpdateRoleShowData:RemoveListener(self.showListener)
-- end
function FashionSelectionShowWindow:OpenLuckyWindow(data)
    FashionSelectionManager.Instance.luckyGroupId = data.group_id
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_selection_lucky_window)
end

function FashionSelectionShowWindow:ChangeSex()
    if self.sex == 0 then
        self.sex = 1
    elseif self.sex == 1 then
        self.sex = 0
    end

    self:UpdateSelectionItem()
end
