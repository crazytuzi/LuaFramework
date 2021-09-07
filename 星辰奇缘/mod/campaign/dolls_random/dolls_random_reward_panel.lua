-- 作者:jia
-- 4/27/2017 2:42:54 PM
-- 功能:套娃获得奖励弹窗

DollsRandomRewardPanel = DollsRandomRewardPanel or BaseClass(BasePanel)
function DollsRandomRewardPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.dollsrandomrewardpanel, type = AssetType.Main}
        ,{file = AssetConfig.toyreward_textures, type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type =AssetType.Dep}
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.hasInit = false
    self.rewardItems = { }
    self.leftTime = 10
end

function DollsRandomRewardPanel:__delete()
    DollsRandomManager.Instance.isOpening = false

    BaseUtils.ReleaseImage(self.ImageTitle)

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    if self.rewardItems ~= nil then
        for _, v in pairs(self.rewardItems) do
            v:DeleteMe()
        end
        self.rewardItems = nil
    end
    if self.rewardItems ~= nil then
        for _, item in pairs(self.rewardItems) do
            item:DeleteMe()
        end
        self.rewardItems = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DollsRandomRewardPanel:OnHide()

end

function DollsRandomRewardPanel:OnOpen()
    local rewards = self.openArgs
    if next(rewards) ~= nil then
        if self.Layout ~= nil then
            self.Layout:Reset()
            self.Layout:DeleteMe()
        end
        local len = #rewards
        local borderleft = 48
        if len < 4 then
            borderleft =(550 - len * self.setting.cellSizeX -(len - 1) * self.setting.cspacing) * 0.5
        end
        self.setting.borderleft = borderleft
        self.Layout = LuaGridLayout.New(self.GrdItems, self.setting)
        local delateTime = 0;
        for key, reward in pairs(rewards) do
            local item = self.rewardItems[key]
            if BaseUtils.is_null(item) then
                item = DollsRandomRewardItem.New(
                function()
                    item:SetData(reward)
                    item:StartShake(tonumber(key) * 100)
                    self.Layout:AddCell(item.gameObject)
                end )
                item:Show()
                self.rewardItems[key] = item
            else
                item:SetData(reward)
                item:StartShake(tonumber(key) * 100)
            end

        end
    end
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end
    self.leftTime = 10
    self.timer = LuaTimer.Add(0, 1000, function()
        self:onTimeClick()
    end )
end

function DollsRandomRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandomrewardpanel))
    self.gameObject.name = "DollsRandomRewardPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.Panel = self.transform:Find("Panel")
    self.Panel:GetComponent(Button).onClick:AddListener( function() self:Close() end)
    self.TxtTite = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.ImageTitle = self.transform:Find("Main/Title/Image"):GetComponent(Image)
    self.ImageTitle.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyCeremonyI18N")
    self.BaseItem = self.transform:Find("Main/BaseItem")
    self.GrdItems = self.transform:Find("Main/GrdItems")
    self.BtnSure = self.transform:Find("Main/BtnSure"):GetComponent(Button)
    self.BtnSure.onClick:AddListener(
    function()
        self:Close()
    end )
    self.TxtBtn = self.transform:Find("Main/BtnSure/Text"):GetComponent(Text)

    self.setting = {
        column = 4
        ,
        cspacing = 72
        ,
        rspacing = 50
        ,
        cellSizeX = 65
        ,
        cellSizeY = 65,
    }
    self.OnOpenEvent:Fire()
end

function DollsRandomRewardPanel:Close()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
        self.leftTime = 0
    end
    DollsRandomManager.Instance.model:CloseRewardPanel()
end

function DollsRandomRewardPanel:onTimeClick()
    self.TxtBtn.text = string.format(TI18N("确定")) .. "（" .. self.leftTime .. "s）"
    self.leftTime = self.leftTime - 1
    if self.leftTime < 0 then
        self:Close()
    end
end