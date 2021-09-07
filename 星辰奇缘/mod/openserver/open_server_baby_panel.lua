OpenServerBabyPanel = OpenServerBabyPanel or BaseClass(BasePanel)

function OpenServerBabyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_baby, type = AssetType.Main}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.noticeMsg = TI18N("活动期间<color=#00FF00>上传头像</color>的公会宝贝，人气值达到<color=#00FF00>前20</color>可进入当前排名")

    self.itemList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:ReloadBabies() end

    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
end

function OpenServerBabyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
                self.itemList[k] = nil
                v = nil
            end
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerBabyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_baby))
    self.gameObject.name = "BabyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.noticeBtn = t:Find("Title/Notice"):GetComponent(Button)
    self.container = t:Find("ScrollLayer/Container")
    self.cloner = t:Find("ScrollLayer/Cloner").gameObject
    self.nothingObj = t:Find("Nothing").gameObject

    self.cloner.transform:Find("InfoArea/GuildIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon27")

    self.cloner:SetActive(false)
    if self.noticeBtn == nil then
        self.noticeBtn = t:Find("Title/Notice").gameObject:AddComponent(Button)
    end
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)

    self.OnOpenEvent:Fire()
end

function OpenServerBabyPanel:OnOpen()
    self:ReloadBabies()

    self:RemoveListeners()
    self.mgr.onUpdateBaby:AddListener(self.updateListener)
    self.mgr:send14005()
end

function OpenServerBabyPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerBabyPanel:RemoveListeners()
    self.mgr.onUpdateBaby:RemoveListener(self.updateListener)
end

function OpenServerBabyPanel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.noticeMsg}})
    -- self.model:OpenBabyGiftTips({12121212})
end

function OpenServerBabyPanel:ReloadBabies()
    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    end
    local obj = nil
    self.nothingObj:SetActive(#self.mgr.guildBabyList == 0)
    for i,v in ipairs(self.mgr.guildBabyList) do
        if self.itemList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.itemList[i] = OpenServerBabyItem.New(self.model, obj, self.assetWrapper)
        end
        self.itemList[i]:SetData(v, i)
    end
    for i=#self.mgr.guildBabyList + 1, #self.itemList do
        self.itemList[i]:SetActive(false)
    end
end
