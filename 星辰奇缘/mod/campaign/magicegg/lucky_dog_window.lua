LuckyDogWindow = LuckyDogWindow or BaseClass(BaseWindow)

function LuckyDogWindow:__init(model)
    self.model = model
    self.name = "LuckyDogWindow"
    self.windowId = WindowConfig.WinID.luckydogwindow
    -- self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.luckydog, type = AssetType.Main}
        ,{file = AssetConfig.luckywindowbg, type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{file = AssetConfig.textures_magicegg, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }

    self.itemList = {}
    self.imgLoader = {}
    self.luckydogList = nil
    self.colorKind = "<color='#c3692c'>%s</color>"

    self._updateModeldata = function() self:UpdateData(self.model.luckydogList) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LuckyDogWindow:__delete()
    self.OnHideEvent:Fire()

    if self.bgImg ~= nil then
        BaseUtils.ReleaseImage(self.bgImg)
    end

    for k,v in pairs(self.imgLoader) do
        v:DeleteMe()
        v = nil
    end
end

function LuckyDogWindow:OnInitCompleted()
    self:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function LuckyDogWindow:OnOpen()
    self:RemoveListeners()
    MagicEggManager.Instance.OnUpdateLuckyDogList:Add(self._updateModeldata)
    MagicEggManager.Instance:Send20404()
    self:UpdateData(self.model.luckydogList)
end

function LuckyDogWindow:RemoveListeners()
    MagicEggManager.Instance.OnUpdateLuckyDogList:Remove(self._updateModeldata)
end

function LuckyDogWindow:OnHide()
    self:RemoveListeners()
end


function LuckyDogWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.luckydog))
    self.gameObject.name = self.name

    -- self.gameObject.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseLuckyDogWindow() end)

    local Main = self.gameObject.transform:Find("Main")
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.bgImg = Main:Find("bg"):GetComponent(Image)
    self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.luckywindowbg, "luckywindowbg")

    self.closeBtn = Main:Find("CloseButton"):GetComponent(Button)

    self.container = Main:Find("Mask/Container")
    self.itemcloner = self.container:Find("Item").gameObject
    self.itemcloner:SetActive(false)


    self.closeBtn.onClick:AddListener(function()  self.model:CloseLuckyDogWindow() end)
end


function LuckyDogWindow:UpdateData(datalist)
    local testlist = {
            {reward_rank = 0, reward_item = 20364, name = TI18N("虚位以待"), zone_name = "——",reward_time = 0 },
            {reward_rank = 1, reward_item = 20303, name = TI18N("虚位以待"), zone_name = "——",reward_time = 0 },
            {reward_rank = 1, reward_item = 29004, name = TI18N("虚位以待"), zone_name = "——",reward_time = 0 },
            {reward_rank = 1, reward_item = 20302, name = TI18N("虚位以待"), zone_name = "——",reward_time = 0 },
     }

    local function sortfun(a,b)
        local amonth = tonumber(os.date("%m",a.reward_time))
        local bmonth = tonumber(os.date("%m",b.reward_time))

        local aday = tonumber(os.date("%d",a.reward_time))
        local bday = tonumber(os.date("%d",b.reward_time))


        if a.reward_rank ~=  b.reward_rank then
            return a.reward_rank < b.reward_rank
        end

        if amonth ~= bmonth then
            return amonth > bmonth
        end

        return aday > bday
    end

    if datalist == nil or #datalist == 0 then
        datalist = testlist
    end
    table.sort(datalist,sortfun)

    local index = 1
    for i ,data in ipairs (datalist) do
        local item = self.itemList[i]
        if item == nil then
            item = GameObject.Instantiate(self.itemcloner)
            item.transform:SetParent(self.container)
            item.transform.localScale = Vector3(1, 1, 1)
            item:SetActive(true)
            self.itemList[i] = item

            local go = item.transform:Find("Headbg/Image"):GetComponent(Image).gameObject
            go.transform:GetComponent(RectTransform).sizeDelta = Vector2(52, 52)
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        item.transform:Find("rewardname"):GetComponent(Text).text = self:GetRankText(data.reward_rank)

        --图片框处理
        --local headId = tostring(data.reward_item)
        --local headImage = item.transform:Find("Headbg/Image"):GetComponent(Image)
        --headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)

        local baseData = BackpackManager.Instance:GetItemBase(data.reward_item)
        self.imgLoader[i]:SetSprite(SingleIconType.Item, baseData.icon)

        item.transform:Find("NameText"):GetComponent(Text).text = string.format(self.colorKind,DataItem.data_get[data.reward_item].name)
        item.transform:Find("rolename"):GetComponent(Text).text = data.name
        item.transform:Find("severname"):GetComponent(Text).text = data.zone_name
        item.transform:Find("date"):GetComponent(Text).text = self:GetDate(data.reward_time)

        index = i + 1
    end

    for i,v in ipairs (self.itemList) do
        if i >= index then
            v:SetActive(false)
        end
    end

end


function LuckyDogWindow:GetRankText(rank)
    local str = nil
    if rank == 0 then
        str = TI18N("<color='#c3692c'>欧皇奖</color>")
        self.colorKind = "<color='#c3692c'>%s</color>"
    elseif rank == 1 then
        str = TI18N("<color='#b031d5'>幸运奖</color>")
        self.colorKind = "<color='#b031d5'>%s</color>"
    end
    return str
end

function LuckyDogWindow:GetDate(date)
    if date == 0 then
        return "——"
    end
    local month = os.date("%m",date)
    local day = os.date("%d",date)
    return string.format(TI18N("%s月%s日"),month,day)
end
