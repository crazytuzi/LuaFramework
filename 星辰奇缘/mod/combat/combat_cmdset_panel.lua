CombatCmdSetPanel = CombatCmdSetPanel or BaseClass(BasePanel)

function CombatCmdSetPanel:__init()
    self.name = "CombatCmdSetPanel"
    self.Mgr = CombatManager.Instance
    self.resList = {
    {file = AssetConfig.combatcmdpanel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.currInputField = nil
    self.isLeft = nil
    self.reloadfunc = function()
        self:Reload()
    end
end


function CombatCmdSetPanel:OnInitCompleted()

end

function CombatCmdSetPanel:__delete()
    self.Mgr.OnCmdChangeEvent:RemoveListener(self.reloadfunc)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function CombatCmdSetPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatcmdpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "CombatCmdSetPanel"
    self.transform = self.gameObject.transform
    self.maincon = self.transform:Find("Main/Con")
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self:Hiden()
    end)
    self:InitIPF()
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function()
        self.Mgr:Send10743(0, 0, "")
        self.Mgr:Send10743(1, 0, "")
    end)
    self.Mgr.OnCmdChangeEvent:AddListener(self.reloadfunc)
end

function CombatCmdSetPanel:InitIPF()
    local Lpanel = self.maincon:Find("LPanel")
    local Rpanel = self.maincon:Find("RPanel")
    self:InitIpfGroup(Lpanel, true)
    self:InitIpfGroup(Rpanel, false)
end

function CombatCmdSetPanel:InitIpfGroup(parent, isLeft)
    -- local settingData = isLeft and self.Mgr.target_preside or self.Mgr.self_preside
    -- BaseUtils.dump(settingData,"设置数据")
    for i=1,5 do
        -- local item = self.maincon:Find("LPanel"):Find(tostring(i))
        local item = parent:Find(tostring(i))
        local ipf = item:Find("InputField"):GetComponent(InputField)
        local placeholder = ipf.transform:Find("Placeholder"):GetComponent(Text)
        placeholder.text = TI18N("请输入内容")
        local ipfText = ipf.transform:Find("Text"):GetComponent(Text)
        local ipfBtn = item:Find("ipfbtn"):GetComponent(Button)
        local slBtn = item:Find("SaveLoad"):GetComponent(Button)
        ipf.textComponent = ipfText
        ipf.placeholder = placeholder
        -- ipf.interactable = false
        if isLeft then
            ipf.text = self:GetTargetCmd(i) or TargetCombatCommand[i]
        else
            ipf.text = self:GetSelfCmd(i) or SelfCombatCommand[i]
        end
        ipfBtn.gameObject:SetActive(false)
        local editcallback = function()
            if self.currInputField == ipf then
                if string.utf8len(ipf.text) > 4 or string.utf8len(ipf.text) <= 0 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("指挥标记只能1-4个字符"))
                    return
                end
                slBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                slBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("编辑")
                -- ipf.interactable = false
                self.currInputField = nil
                self.isLeft = nil
                -- ipfBtn.gameObject:SetActive(true)
                if isLeft then
                    self.Mgr:Send10743(1, i, ipf.text)
                else
                    self.Mgr:Send10743(0, i, ipf.text)
                end
                -- morebtn.gameObject:SetActive(false)
                -- resetbtn.gameObject:SetActive(false)
            elseif self.currInputField == nil then
                slBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                slBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("保存")
                ipf.interactable = true
                self.currInputField = ipf
                self.isLeft = isLeft
                -- ipfBtn.gameObject:SetActive(false)
                -- morebtn.gameObject:SetActive(true)
                -- resetbtn.gameObject:SetActive(true)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请先保存修改"))
            end
        end
        local onVC = function(vc, _ipf)
            if self.currInputField == ipf then
                if string.utf8len(ipf.text) > 4 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("指挥标记最多4个字符"))
                    return
                end
                if slBtn.transform:Find("Text"):GetComponent(Text).text == TI18N("编辑") then
                    slBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                    slBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("保存")
                end
                self.isLeft = isLeft
                -- if isLeft then
                --     self.Mgr:Send10743(1, i, ipf.text)
                -- else
                --     self.Mgr:Send10743(0, i, ipf.text)
                -- end
                -- morebtn.gameObject:SetActive(false)
                -- resetbtn.gameObject:SetActive(false)
            elseif self.currInputField == nil then
                slBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                slBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("保存")
                -- ipf.interactable = true
                self.currInputField = ipf
                self.isLeft = isLeft
                -- ipfBtn.gameObject:SetActive(false)
                -- morebtn.gameObject:SetActive(true)
                -- resetbtn.gameObject:SetActive(true)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请先保存修改"))
            end
        end
        ipf.onValueChange:AddListener(function (val) onVC(val,ipf) end)
        slBtn.onClick:AddListener(editcallback)
        ipfBtn.onClick:AddListener(editcallback)
    end
end

function CombatCmdSetPanel:GetSelfCmd(id)
    local str = nil
    for i,v in ipairs(self.Mgr.self_preside) do
        if v.flag1 == id then
            str = v.text2
        end
    end
    return str
end

function CombatCmdSetPanel:GetTargetCmd(id)
    local str = nil
    for i,v in ipairs(self.Mgr.target_preside) do
        if v.flag2 == id then
            str = v.text2
        end
    end
    return str
end

function CombatCmdSetPanel:Reload()
    for i=1,10 do
        -- local item = self.maincon:Find("LPanel"):Find(tostring(i))
        local parent
        if i>5 then
            parent = self.maincon:Find("RPanel")
        else
            parent = self.maincon:Find("LPanel")
        end
        if self.maincon == nil or parent == nil then
            self.Mgr.OnCmdChangeEvent:RemoveListener(self.reloadfunc)
            return
        end
        local item = parent:Find(tostring((i-1)%5+1))
        local ipf = item:Find("InputField"):GetComponent(InputField)
        if i<=5 then
            local str = self:GetTargetCmd(i)
            if str ~= nil then
                ipf.text = str
            else
                ipf.text = TargetCombatCommand[i]
            end
        else
            local str = self:GetSelfCmd(i-5)
            if str ~= nil then
                ipf.text = self:GetSelfCmd(i-5)
            else
                ipf.text = SelfCombatCommand[i-5]
            end
        end

    end
end
