DungeonClearBuff = DungeonClearBuff or BaseClass(BaseWindow)

function DungeonClearBuff:__init(model)
    self.model = model
    self.name = "DungeonClearBuff"
    self.windowId = WindowConfig.WinID.dungeonclearbuff

    self.resList = {
        {file = AssetConfig.dungeon_clear_buff, type = AssetType.Main},
        {file = AssetConfig.bufficon, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DungeonClearBuff:__delete()
    self.OnHideEvent:Fire()
    if self.itemIconImage ~= nil then
        self.itemIconImage.sprite = nil
        self.itemIconImage = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DungeonClearBuff:OnOpen()
    self:RemoveListeners()

    self:Reload(self.openArgs)
end

function DungeonClearBuff:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DungeonClearBuff:OnHide()
    self:RemoveListeners()
end

function DungeonClearBuff:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeon_clear_buff))
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.itemIconImage = main:Find("ItemBg/Icon"):GetComponent(Image)
    self.nameText = main:Find("Name"):GetComponent(Text)
    self.statusText = main:Find("Status"):GetComponent(Text)
    self.descExt = MsgItemExt.New(main:Find("Desc"):GetComponent(Text), 341.9, 17, 19)
end

function DungeonClearBuff:RemoveListeners()
end

function DungeonClearBuff:Reload(bool)
    local clearerBuff = self.model.clearerBuff
    self.itemIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.bufficon, clearerBuff.icon)
    self.nameText.text = clearerBuff.name
    self.descExt:SetData(clearerBuff.desc)

    if bool == true then
        self.statusText.text = TI18N("已获得")
        -- BaseUtils.SetGrey(self.itemIconImage, false)
        self.itemIconImage.color = Color(1, 1, 1)
    else
        self.statusText.text = TI18N("<color='#ff0000'>未获得</color>")
        self.itemIconImage.color = Color(0.5, 0.5, 0.5)
    end
end



