--武道大会荣誉战绩
--2017/02/13
--zzl

 WorldChampionFightHonorWindow  =  WorldChampionFightHonorWindow or BaseClass(BaseWindow)

function WorldChampionFightHonorWindow:__init(model)
    self.name  =  "WorldChampionFightHonorWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.worldchampionno1score, type  =  AssetType.Main}
        , {file = AssetConfig.no1inworld_textures, type = AssetType.Dep}
        ,{file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep}
    }

    self.rightItemList = nil
    return self
end

function WorldChampionFightHonorWindow:__delete()
    self.is_open  =  false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldChampionFightHonorWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionno1score))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldChampionFightHonorWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.Main = self.gameObject.transform:Find("Main")

    local closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseFightHonorWindow()
    end)

    local tabGroup = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:TabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:TabChange(2) end)

    self:TabChange(self.openArgs)
end

function WorldChampionFightHonorWindow:TabChange(index)
    self.current_index = index
    if index == 1 then
        self:SwitchTabBtn(self.tab_btn1)
        self:ShowFirst(true)
        self:ShowSecond(false)
    elseif index == 2 then
        self:SwitchTabBtn(self.tab_btn2)
        self:ShowFirst(false)
        self:ShowSecond(true)
    end
end

function WorldChampionFightHonorWindow:SwitchTabBtn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end


function WorldChampionFightHonorWindow:ShowFirst(IsShow)
    if IsShow then
        if self.subFirst == nil then
            self.subFirst = WorldChampionHonorRankPanel.New(self)
        end
        self.subFirst:Show()
    else
        if self.subFirst ~= nil then
            self.subFirst:Hiden()
        end
    end
end

function WorldChampionFightHonorWindow:ShowSecond(IsShow)
    if IsShow then
        if self.subSecond == nil then
            self.subSecond = WorldChampionWarRankPanel.New(self)
        end
        self.subSecond:Show()
    else
        if self.subSecond ~= nil then
            self.subSecond:Hiden()
        end
    end
end

function WorldChampionFightHonorWindow:UpdateFightScorePanel(data)
    if self.subSecond ~= nil then
        self.subSecond:UpdateInfo(data)
    end
end
