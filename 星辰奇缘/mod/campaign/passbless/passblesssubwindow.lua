-- @author hze
-- @date #2018/05/03#
-- 传递花语弹窗

PassBlessSubWindow = PassBlessSubWindow or BaseClass(BaseWindow)

function PassBlessSubWindow:__init(model)
    self.model = model
    self.name = "PassBlessSubWindow"

    self.windowId = WindowConfig.WinID.passblesssubwindow
    self.itemIdList = {70086, 70087, 70088, 70089, 70090, 70091, 70092} --花id

    self.resList = {
        {file = AssetConfig.passblesssubwindow, type = AssetType.Main},
        {file = AssetConfig.passblesssubbg, type = AssetType.Main},
        {file = AssetConfig.passbless_res, type = AssetType.Dep},
        {file = AssetConfig.nationalsecond_accept_texture, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PassBlessSubWindow:__delete()
    self.OnHideEvent:Fire()
    if self.iconImg ~= nil then
        BaseUtils.ReleaseImage(self.iconImg)
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PassBlessSubWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.passblesssubwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")

    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.passblesssubbg)))

    self.descTxt = MsgItemExt.New(main:Find("Desc"):GetComponent(Text), 300, 18, 21)

    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.passblesswindow,{campId = 1062}) end)

    self.item = main:Find("Item"):GetComponent(Button)
    self.iconImg = main:Find("Item/Icon"):GetComponent(Image)


end

function PassBlessSubWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PassBlessSubWindow:OnOpen()
    self:RemoveListeners()
    local name = "神秘人"
    local flower_id = 1
    local time = 10
    BaseUtils.dump(self.openArgs)
    if self.openArgs ~= nil then
        name = self.openArgs[1]
        flower_id = self.openArgs[2]
        time = self.openArgs[3]
    end

    self.iconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.nationalsecond_accept_texture,DataCampPassFlowerLanguage.data_get_flower_info[flower_id].icon)

    local txt =  string.format("<color='#C437F9'>%s</color>将%s传递给你，<color='#c3692c'>%d分钟</color>内传递出去可领取丰厚的奖励哟{face_1,3}",name,DataCampPassFlowerLanguage.data_get_flower_info[flower_id].name,time)
    self.descTxt:SetData(txt)

    local itemData = ItemData.New()
    itemData:SetBase(DataItem.data_get[self.itemIdList[flower_id]])
    self.item.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.item.gameObject, itemData = itemData, {inbag = false, nobutton = true}}) end)
end

function PassBlessSubWindow:OnHide()
    self:RemoveListeners()
end

function PassBlessSubWindow:RemoveListeners()
end


