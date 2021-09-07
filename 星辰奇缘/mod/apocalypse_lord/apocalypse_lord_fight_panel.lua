-- @author 林嘉豪
-- @date 2017年7月14日, 星期一

ApocalypseLordFightPanel = ApocalypseLordFightPanel or BaseClass(BasePanel)

function ApocalypseLordFightPanel:__init(model)
    self.model = model
    self.name = "ApocalypseLordFightPanel"

    self.resList = {
        {file = AssetConfig.glory_fight, type = AssetType},
    }

    self.updateListener = function(data) self:Update(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ApocalypseLordFightPanel:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function ApocalypseLordFightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_fight))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(CombatManager.Instance.combatCanvas, self.gameObject)
    self.transform = t

    t:Find("Bg").sizeDelta = Vector2(155, 50)
    self.descText = t:Find("Text"):GetComponent(Text)
    self.descText.transform.sizeDelta = Vector2(145, 50)
end

function ApocalypseLordFightPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ApocalypseLordFightPanel:OnOpen()
    self:RemoveListeners()
    ApocalypseLordManager.Instance.OnUpdateBossWave:AddListener(self.updateListener)

    self:Update()
end

function ApocalypseLordFightPanel:OnHide()
    self:RemoveListeners()
end

function ApocalypseLordFightPanel:RemoveListeners()
    ApocalypseLordManager.Instance.OnUpdateBossWave:RemoveListener(self.updateListener)
end

function ApocalypseLordFightPanel:Update(data)
    local wave = ApocalypseLordManager.Instance.model.wave

    if wave == 0 then
        self.gameObject:SetActive(false)
    else
        self.gameObject:SetActive(true)

        local maxWave = #DataOracleTreasure.data_wave
        if wave < maxWave then
            self.descText.text = string.format(TI18N("<color='#ffff00'>----第%s阶段----</color>\n后续还有<color='#00ff00'>%s个</color>阶段"), wave, maxWave - wave)
        else
            self.descText.text = TI18N("<color='#ffff00'>----最终阶段----</color>")
            self.transform:Find("Bg").sizeDelta = Vector2(155, 30)
        end
    end
end


