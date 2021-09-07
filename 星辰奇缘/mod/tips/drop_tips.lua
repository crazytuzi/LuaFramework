-- ------------------------------
-- 获取途径
-- hosr
-- ------------------------------
DropTips = DropTips or BaseClass(BasePanel)

function DropTips:__init(model)
    self.model = model
    self.name = "DropTips"
    self.path = "prefabs/ui/tips/droptips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.dropicon, type = AssetType.Dep}
    }
    self.buttons = {}
end

function DropTips:__delete()
end

function DropTips:Show(arge)
    if self.loading then
        return
    end

    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self.gameObject:SetActive(true)
        self:OnInitCompleted()
    else
        self.loading = true
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function DropTips:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self:HideAll()
end

function DropTips:HideAll()
    for i,tab in ipairs(self.buttons) do
        tab.gameObject:SetActive(false)
        tab.descObj:SetActive(false)
    end
end

function DropTips:HideAllDesc()
    for i,tab in ipairs(self.buttons) do
        tab.descObj:SetActive(false)
    end
end

function DropTips:OnInitCompleted()
    self:UpdateInfo(self.openArgs.info, self.openArgs.dropstr, self.openArgs.height)
end

function DropTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "DropTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() EventMgr.Instance:Fire(event_name.tips_cancel_close) self.model:Closetips() end)

    self.container = self.transform:Find("Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.containerTransform = self.container.transform

    for i=1,6 do
        local tab = {}
        tab.gameObject = self.containerTransform:GetChild(i - 1).gameObject
        tab.transform = tab.gameObject.transform
        tab.button = tab.transform:Find("Button"):GetComponent(Button)
        tab.label = tab.button.gameObject.transform:Find("Text"):GetComponent(Text)
        tab.icon = tab.button.gameObject.transform:Find("Icon"):GetComponent(Image)
        tab.infoBtn = tab.transform:Find("Info"):GetComponent(Button)
        tab.descObj = tab.transform:Find("Desc").gameObject
        tab.descRect = tab.descObj:GetComponent(RectTransform)
        tab.descTxt = tab.descObj.transform:Find("Text"):GetComponent(Text)
        tab.descTxtRect = tab.descTxt.gameObject:GetComponent(RectTransform)

        tab.descObj:SetActive(false)
        tab.gameObject:SetActive(false)

        table.insert(self.buttons, tab)

        local index = i
        tab.infoBtn.onClick:AddListener(function() self:ShowDesc(index) end)
        tab.descObj:GetComponent(Button).onClick:AddListener(function() self:HideDesc(index) end)
    end
end

function DropTips:ShowDesc(index)
    self:HideAllDesc()
    local tab = self.buttons[index]
    tab.descObj:SetActive(true)
end

function DropTips:HideDesc(index)
    local tab = self.buttons[index]
    tab.descObj:SetActive(false)
end

--[{1;30|1|2;商城;消耗钻石购买;0}]
function DropTips:UpdateInfo(info, dropstr, itemHeight)
    self.itemHeight = itemHeight -- 依附的对象啊高度，用于计算位置
    self:HideAll()
    local count = 0
    for code,argstr,label,desc,icon in string.gmatch(dropstr, "{(%d-);(.-);(.-);(.-);(%d-)}") do
        code = tonumber(code)
        count = count + 1
        local tab = self.buttons[count]
        tab.label.text = label
        tab.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, tostring(icon))
        tab.descTxt.text = desc

        local w = tab.descTxt.preferredWidth
        local h = tab.descTxt.preferredHeight
        tab.descTxtRect.offsetMin = Vector2.zero
        tab.descTxtRect.offsetMax = Vector2.zero
        tab.descTxtRect.sizeDelta = Vector2(w, h)
        tab.descRect.sizeDelta = Vector2(w + 30, h + 30)

        local args = StringHelper.Split(argstr, "|")
        if #args == 0 then
            table.insert(args,tonumber(argstr))
        end
        tab.button.onClick:RemoveAllListeners()
        local func = nil
        if code == TipsEumn.DropCode.OpenWindow then
            func = function()
                self.model:Closetips()
                local windowId = tonumber(args[1])
                table.remove(args, 1)
                local fuck = {}
                for i,v in ipairs(args) do
                    table.insert(fuck, tonumber(v))
                end
                table.insert(fuck, info.itemData.base_id)
                if windowId == WindowConfig.WinID.guildauctionwindow then
                    if GuildManager.Instance.model:has_guild() then
                        WindowManager.Instance:OpenWindowById(windowId, fuck)
                    end
                else
                    WindowManager.Instance:OpenWindowById(windowId, fuck)
                end
            end
        elseif code == TipsEumn.DropCode.FindNpc then
            func = function()
                self.model:Closetips()
                EventMgr.Instance:Fire(event_name.drop_findnpc)
                local key = BaseUtils.get_unique_npcid(args[2], args[1])
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
            end
        elseif code == TipsEumn.DropCode.FloatTips then
            func = function()
                NoticeManager.Instance:FloatTipsByString(argstr)
            end
        end
        if func ~= nil then
            tab.button.onClick:AddListener(func)
        end
        tab.gameObject:SetActive(true)
    end
    self.height = count * 55
    self.height = self.height + 100
    self.height = math.max(self.itemHeight, self.height)
    self.rect.sizeDelta = Vector2(315, self.height)
    self.rect.anchoredPosition = Vector2.zero

    -- local offsety = (self.itemHeight - self.height) / 2
    -- self.rect.anchoredPosition = Vector2(0, offsety)
end
