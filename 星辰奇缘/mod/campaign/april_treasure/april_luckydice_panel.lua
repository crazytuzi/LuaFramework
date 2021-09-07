-- @author 111
-- @date 2018年3月13日,星期二

AprilLuckyDicePanel = AprilLuckyDicePanel or BaseClass(BasePanel)

function AprilLuckyDicePanel:__init(model, parentGameOject, parent)
    self.model = model
    self.parentGo = parentGameOject
    self.parentWin = parent
    self.name = "AprilLuckyDicePanel"
    self.resList = {
        {file = AssetConfig.aprilTurnDice_win, type = AssetType.Main}
        ,{file = AssetConfig.apriltreasure_Texture, type =AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.DiceList = { }

    self.sureNum = 0   --选定的数字
end

function AprilLuckyDicePanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AprilLuckyDicePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.aprilTurnDice_win))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parentGo, self.gameObject)

    self.transform.localPosition = Vector3(0, 0, -400)

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:Hiden() end)

    self.sureBtn = self.transform:FindChild("MainCon/SureBtn"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function() self:onClickSure() end)

    local diceContainer = self.transform:FindChild("MainCon/DicePanel")
    for i = 1, 6 do
        if self.DiceList[i] == nil then
            self.DiceList[i] = { }
            self.DiceList[i].btn = diceContainer:GetChild(i - 1):GetComponent(Button)
            self.DiceList[i].btn.onClick:AddListener(function() self:onClickDice(i) end)
            self.DiceList[i].bg = diceContainer:GetChild(i - 1):Find(Image):GetComponent(Image)
        end
    end

    self.transform:FindChild("MainCon/Desc"):GetComponent(Text).text = TI18N("<color='#ffff00'>使用幸运骰子可以自选任意前进步数1-6格</color>")
end

function AprilLuckyDicePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AprilLuckyDicePanel:onClickDice(i)
    local index = i
    print("选中"..i)
    if self.DiceList[i] ~= nil and self.DiceList ~= nil then
        for k = 1, 6 do
            if k == index then
                self.DiceList[k].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.apriltreasure_Texture, "SelectBg")
            else
                self.DiceList[k].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.apriltreasure_Texture, "NoSelectBg")
            end
        end
    end
    self.sureNum = i

    self.sureBtn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
    self.sureBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
end


--点击了确定按钮
function AprilLuckyDicePanel:onClickSure()
    if self.sureNum > 0 and self.sureNum < 7 then
        self:Hiden()
        if self.parentWin ~= nil then
            self.parentWin:OnLuckyReturn(self.sureNum)
        end
    else
        NoticeManager.Instance:FloatTipsByString("请先选择要走的步数~")
    end
end



function AprilLuckyDicePanel:OnOpen()
    self:AddListeners()
    self.sureNum = 0
    for k = 1, 6 do
        self.DiceList[k].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.apriltreasure_Texture, "NoSelectBg")
    end
    self.sureBtn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
    self.sureBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
end

function AprilLuckyDicePanel:OnHide()
    self:RemoveListeners()
end

function AprilLuckyDicePanel:AddListeners()
    self:RemoveListeners()
end

function AprilLuckyDicePanel:RemoveListeners()
end

function AprilLuckyDicePanel:OnClose()
end


