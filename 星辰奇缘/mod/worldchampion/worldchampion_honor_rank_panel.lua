--author:zzl
--time:2017/2/13
--武道大会荣耀

WorldChampionHonorRankPanel= WorldChampionHonorRankPanel or BaseClass(BasePanel)

function WorldChampionHonorRankPanel:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.resList = {
        {file = AssetConfig.worldchampionno1honor, type = AssetType.Main}
    }
    self.hasInit = false
    return self
end

function WorldChampionHonorRankPanel:__delete()
    self.hasInit = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function WorldChampionHonorRankPanel:InitPanel()
    -- 星阵tab
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionno1honor))
    self.gameObject.name = "WorldChampionHonorRankPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.Main, self.gameObject)

    self.itemList = {}
    self.RankCon = self.transform.transform:FindChild("RankCon")
    for i = 1, 7 do
        local go = self.RankCon.transform:FindChild(tostring(i)).gameObject
        local item = self:CreateItem(go)
        table.insert(self.itemList, item)
    end

    self.toggleGroup= self.transform:FindChild("ToggleGroup").gameObject
    self.Toggle1 = self.toggleGroup.transform:FindChild("Toggle1"):GetComponent(Toggle)
    self.Toggle2 = self.toggleGroup.transform:FindChild("Toggle2"):GetComponent(Toggle)
    self.Toggle1.onValueChanged:AddListener(function(on)
        if on then
            local list = {}
            if self.model.fightScoreData ~= nil then
                self.itemList[1].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.awesome_kill)
                self.itemList[2].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.awesome_dmg)
                self.itemList[3].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.awesome_kill_num)
                self.itemList[4].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.mvp)
                self.itemList[5].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.awesome_heal)
                self.itemList[6].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.awesome_control)
                self.itemList[7].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.loss_mvp)
            end
        end
    end)
    self.Toggle2.onValueChanged:AddListener(function(on)
        if on then
            local list = {}
            if self.model.fightScoreData ~= nil then
                self.itemList[1].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_awesome_kill)
                self.itemList[2].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_awesome_dmg)
                self.itemList[3].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_awesome_kill_num)
                self.itemList[4].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_mvp)
                self.itemList[5].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_awesome_heal)
                self.itemList[6].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_awesome_control)
                 self.itemList[7].transform:Find("TxtNum"):GetComponent(Text).text = tostring(self.model.fightScoreData.season_loss_mvp)
            end
        end
    end)
    self.Toggle1.isOn = true
end

function WorldChampionHonorRankPanel:CreateItem(go)
    local item = {}
    item.gameObject = go
    item.transform = go.transform
    item.ImgIcon = item.transform:Find("ImgIcon"):GetComponent(Image)
    item.TxtNum = item.transform:Find("TxtNum"):GetComponent(Text)
    item.TxtName = item.transform:Find("TxtName"):GetComponent(Text)
    item.TxtDesc = item.transform:Find("TxtDesc"):GetComponent(Text)
    return item
end

function WorldChampionHonorRankPanel:SetItem(item, data)
    -- print("===========================dddddddddddddddddddddddddddd")
    -- BaseUtils.dump(data)
end