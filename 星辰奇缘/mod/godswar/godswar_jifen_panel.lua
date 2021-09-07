-- ----------------------------
-- 诸神之战  积分相关主界面
-- zyh
-- ----------------------------

GodsWarJiFenPanel = GodsWarJiFenPanel or BaseClass(BasePanel)

function GodsWarJiFenPanel:__init(parent)
    self.model = GodsWarManager.Instance.model
    self.parent = parent
    self.effectPath = "prefabs/effect/20009.unity3d"
    self.effect = nil

    self.resList = {
        {file = AssetConfig.godswarjifenpanel, type = AssetType.Main},
        {file = AssetConfig.godswartexture, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.classList =
    {
        [1] = {id = 1,name = "封神殿",spriteFun = {package = AssetConfig.godswartexture,name = "icon3"}},
        [2] = {id = 2,name = "诸神兑换",spriteFun = {package = AssetConfig.godswartexture,name = "icon1"}},
        [3] = {id = 3,name = "积分榜",spriteFun = {package = AssetConfig.godswartexture,name = "bfb"}},

    }

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.panelList = {}
    self.txtList = {}
    self.currentTabIndexId = 1
    self.isInit = false
end

function GodsWarJiFenPanel:__delete()
    for k,v in pairs(self.panelList) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
end



function GodsWarJiFenPanel:OnHide()
end

function GodsWarJiFenPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarjifenpanel))
    self.gameObject.name = "GodsWarJiFenPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0,0)

    self.mainTransform = self.transform:Find("Main")
    self.tabTemplate = self.transform:Find("TabContainer/TabButton").gameObject
    self.tabTemplate.gameObject:SetActive(false)
    self.tabLayout = LuaBoxLayout.New(self.transform:Find("TabContainer").gameObject, {axis = BoxLayoutAxis.X, spacing = 0})




    self.OnOpenEvent:Fire()
end

function GodsWarJiFenPanel:OnShow()
    self.isInit = false
    self:Layout()
    if self.openArgs ~= nil and next(self.openArgs) ~= nil then
        self:SwitchTabs(self.openArgs[1])
    else
        self:SwitchTabs(1)
    end

end

function GodsWarJiFenPanel:Layout()
     for i,v in ipairs(self.classList) do
      if v ~= nil then
         self.lastGroupIndex = v.group_index
         if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout:AddCell(obj)
         end
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:RemoveAllListeners()
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id) end)

         if v.spriteFun ~= nil then
            local tab = v.spriteFun
            t:Find("Text").anchoredPosition = Vector2(16,0)
            if type(v.spriteFun) == "table" then
                local sprite = self.assetWrapper:GetSprite(tab.package,tab.name)
                if sprite == nil then
                    sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon))
                end
                t:Find("Icon"):GetComponent(Image).sprite  = sprite
            end
            t:Find("Icon").gameObject:SetActive(true)
         else
            t:Find("Text").anchoredPosition = Vector2(0,0)
            t:Find("Icon").gameObject:SetActive(false)
         end
         -- if v.cond_type == 25 then
         --    local icon = t:Find("Icon").gameObject:GetComponent(RectTransform)
         --    icon.localScale = Vector3(1.2, 1.2, 1)
         --    icon.localPosition = Vector3(26, 3, 0)
         -- end

         self.txtList[i] = txt
        end
    end

    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end
end


function GodsWarJiFenPanel:SwitchTabs(indexId)

    if self.currentTabIndexId == indexId and self.isInit == true  then
        return
    end
    self.isInit = true
    self.txtList[self.currentTabIndexId].text = string.format(ColorHelper.TabButton2NormalStr, self.classList[self.currentTabIndexId].name)
    self.txtList[indexId].text = string.format(ColorHelper.TabButton2SelectStr, self.classList[indexId].name)
    self:EnableTab(self.currentTabIndexId, false)
    self:EnableTab(indexId, true)
    self:ChangePanel(indexId)
    self.currentTabIndexId = indexId
end

function GodsWarJiFenPanel:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end

function GodsWarJiFenPanel:ChangePanel(indexId)

    if self.panelList[self.currentTabIndexId] ~= nil then
        self.panelList[self.currentTabIndexId]:Hiden()
    end
    local panelId = nil
    self.currentTabIndexId = indexId
    if self.panelList[self.currentTabIndexId] == nil then
        if tonumber(indexId) == 1 then
            panelId = GodsWarJiFenBadgePanel.New(self)
        elseif tonumber(indexId) == 2 then
            local datalist = {}
            local lev = RoleManager.Instance.RoleData.lev
            local exchange_first = 2
            local exchange_second = 29
            for i,v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                table.insert(datalist, v)
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = "诸神商店", extString = "诸神战斗获胜时获得"})
        elseif tonumber(indexId) == 3 then
            panelId = GodsWarJiFenRankPanel.New(self)
        end

        self.panelList[indexId] = panelId
    end

    if self.panelList[indexId] ~= nil then
        self.panelList[indexId]:Show()
    end
end
