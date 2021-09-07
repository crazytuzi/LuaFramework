FashionSelectionLuckyWindow  =  FashionSelectionLuckyWindow or BaseClass(BaseWindow)

function FashionSelectionLuckyWindow:__init(model)
    self.name  =  "FashionSelectionLuckyWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_selection_lucky_window
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.resList  =  {
        {file = AssetConfig.fashion_selection_lucky_window, type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_lucky_top, type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_lucky_bottom1,type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_lucky_bottom2,type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_lucky_big2,type = AssetType.Dep}
        -- ,{file = AssetConfig.fashion_selection_texture, type = AssetType.Dep}
    }
    self.fashionSelectionItemList = {}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FashionSelectionLuckyWindow:OnHide()

end

function FashionSelectionLuckyWindow:__delete()
    for k,v in pairs(self.fashionSelectionItemList) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
    
    if self.bg3 ~= nil then
        BaseUtils.ReleaseImage(self.bg3)
    end

    if self.bg4 ~= nil then
        BaseUtils.ReleaseImage(self.bg4)
    end

    if self.bg5 ~= nil then
        BaseUtils.ReleaseImage(self.bg5)
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function FashionSelectionLuckyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_lucky_window))
    self.gameObject.name = "FashionSelectionLuckyWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

     self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
     self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.fashionContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")
    self.fashionItem = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/Item")
    self.fashionItem.gameObject:SetActive(false)

    self.bg4 = self.transform:Find("MainCon/Bg4"):GetComponent(Image)
    self.bg4.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_lucky_bottom1,"bottom11")
    self.transform:Find("MainCon/Bg4").gameObject:SetActive(true)

    self.bg5 = self.transform:Find("MainCon/Bg5"):GetComponent(Image)
    self.bg5.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_lucky_bottom2,"bottom12")
    self.transform:Find("MainCon/Bg5").gameObject:SetActive(true)

    --UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.vsbg)))
    local top = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_selection_lucky_top))
    UIUtils.AddBigbg(self.transform:Find("MainCon/Bg2"), top)
    self.transform:Find("MainCon/Bg2").gameObject:SetActive(true)

    self.bg3 = self.transform:Find("MainCon/Bg3"):GetComponent(Image)
    self.bg3.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_lucky_big2,"FashionLuckyBg2")
    self.transform:Find("MainCon/Bg3").gameObject:SetActive(true)





    self.tabLayout = LuaBoxLayout.New(self.fashionContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5,border = 5})




    self:OnShow()
end

function FashionSelectionLuckyWindow:OnShow()



    self:UpdateSelectionItem()

end


function FashionSelectionLuckyWindow:UpdateSelectionItem()
    BaseUtils.dump(FashionSelectionManager.Instance.luckyAllRoleData,"数据=============================================")
    self.myLuckyData = {}
    for i,v in ipairs(FashionSelectionManager.Instance.luckyAllRoleData.group) do
        if v.group_id == FashionSelectionManager.Instance.luckyGroupId then
            self.myLuckyData = BaseUtils.copytab(v.lucky_list)
            break
        end
    end
    BaseUtils.dump(self.myLuckyData,"当前幸运儿============================")
    for i,v in ipairs(self.myLuckyData) do
        if self.fashionSelectionItemList[i] == nil then
            local go = GameObject.Instantiate(self.fashionItem.gameObject)
            local selectionItem = FashionLuckySelectionItem.New(self,go,i)
            -- go.transform:SetParent(self.fashionContainer)
            -- go.transform.localScale = Vector3.one
            self.fashionSelectionItemList[i] = selectionItem
            self.tabLayout:AddCell(go)
        end
        self.fashionSelectionItemList[i]:SetData(v)

    end

end

function FashionSelectionLuckyWindow:OpenLuckyWindow()
    WindowManager.Instance:OpenWindowById(fashion_selection_lucky_window)
end

