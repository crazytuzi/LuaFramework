WorldChampionFormationOP2V2 = WorldChampionFormationOP2V2 or BaseClass()

function WorldChampionFormationOP2V2:__init(go, mainPanel)
    self.gameObject = go
    self.mainPanel = mainPanel
    self.transform = self.gameObject.transform
    self.Mgr = WorldChampionManager.Instance

    self.NoticeGroup = self.transform:Find("NoticeGroup").gameObject
    self.guardButtonList = {}
    for i=2,5 do
        local btn = self.transform:Find(tostring(i).."/GuardButton").gameObject
        btn:GetComponent(Button).onClick:AddListener(function() self:ShowSelectGuardPanel(i) end)
        self.guardButtonList[i] = btn

        btn.gameObject:GetComponent(Image).rectTransform.sizeDelta = Vector2(32, 34)
    end

    self.btnGroup = {}
    self.memberTab = {}
    for i=1,5 do
        self.btnGroup[i] = {}
        self.btnGroup[i].btn = self.transform:Find(tostring(i).."/Button"):GetComponent(Button)
        self.btnGroup[i].Text = self.transform:Find(tostring(i).."/Text").gameObject
        self.btnGroup[i].btn.onClick:RemoveAllListeners()
        self.btnGroup[i].btn.onClick:AddListener(function() self:OnClick(i) end)
        self.memberTab[i] = {}
        self.memberTab[i]["formation1"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo1").gameObject
        self.memberTab[i]["formation2"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo2").gameObject
        self.memberTab[i]["formation_txt1"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo1/Text"):GetComponent(Text)
        self.memberTab[i]["formation_img1"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo1/Image"):GetComponent(Image)
        self.memberTab[i]["formation_txt2"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo2/Text"):GetComponent(Text)
        self.memberTab[i]["formation_img2"] = self.btnGroup[i].btn.transform.parent:Find("FormationInfo2/Image"):GetComponent(Image)
    end

    self.currSelect = nil
    self.currSelect_index = nil
    self.isshow = false
    self:UpdateAttr(1,1)
    self:InitFormationList()
    self:HideAttr()

    self.changeGuard = WorldChampionChangeGuardPanel.New(self)
    self.show = false
end

function WorldChampionFormationOP2V2:__delete()
    self.btnGroup = nil
    self.memberTab = nil

    if self.changeGuard ~= nil then
        self.changeGuard:DeleteMe()
        self.changeGuard = nil
    end
end

function WorldChampionFormationOP2V2:Show()
    self.isshow = true
    self.gameObject:SetActive(true)
    self:ShowNoticeGroup(true)
    LuaTimer.Add(300, function() self.NoticeGroup:SetActive(false) end)
    LuaTimer.Add(500, function() self.NoticeGroup:SetActive(true) end)
    LuaTimer.Add(700, function() self.NoticeGroup:SetActive(false) end)
    LuaTimer.Add(800, function() if self.btnGroup[1].btn.gameObject.activeSelf then self.NoticeGroup:SetActive(true) end end)
    self:ShowAttr()
    -- self:ShowBtn()
end

function WorldChampionFormationOP2V2:Hide()
    self.isshow = false

    self:ShowNoticeGroup(false)
    self.mainPanel.FormatChangeGuard:SetActive(false)
    self:HideBtn()
    -- self:HideAttr()

    self.changeGuard:Hiden()
end

function WorldChampionFormationOP2V2:ShowBtn()
    self:ShowNoticeGroup(true)
    for i=1,5 do
        self.btnGroup[i].btn.gameObject:SetActive(true)
    end
end

function WorldChampionFormationOP2V2:HideBtn()
    self:ShowNoticeGroup(false)
    for i=1,5 do
        self.btnGroup[i].Text:SetActive(false)
        self.btnGroup[i].btn.gameObject:SetActive(false)
    end
end

function WorldChampionFormationOP2V2:ShowAttr()
    for i,v in ipairs(self.btnGroup) do
        self.memberTab[i]["formation1"]:SetActive(true)
        self.memberTab[i]["formation2"]:SetActive(true)
    end
end

function WorldChampionFormationOP2V2:HideAttr()
    for i,v in ipairs(self.btnGroup) do
        v.btn.gameObject:SetActive(false)
        v.Text.gameObject:SetActive(false)
        self.memberTab[i]["formation1"]:SetActive(false)
        self.memberTab[i]["formation2"]:SetActive(false)
    end
end

function WorldChampionFormationOP2V2:OnClick(index)
    if index == 1 then return end
    if self.currSelect == nil then
        self.currSelect = self.btnGroup[index]
        self.currSelect_index = index
        for i=2,5 do
            self.btnGroup[i].Text:SetActive(i ~= index)
        end
        print("没有点击目标")
    elseif self.currSelect_index == index then
        for i=2,5 do
            self.btnGroup[i].Text:SetActive(false)
        end
        self.currSelect = nil
        self.currSelect_index = nil
        print("点击同一目标")
    else
        for i=2,5 do
            self.btnGroup[i].Text:SetActive(false)
        end
        self:Switch(self.currSelect_index, index)
        self.currSelect = nil
        self.currSelect_index = nil
        print("点击不同目标")
    end
end

function WorldChampionFormationOP2V2:Switch(from, to)
  -- print("发送位置调整####")
    local data1 = self.mainPanel.memberList[from]
    local data2 = self.mainPanel.memberList[to]
    if data1 == nil or data2 == nil then
        return
    end
    self.Mgr:Require16414(data1.rid, data1.platform, data1.zone_id, data2.rid, data2.platform, data2.zone_id)
end

function WorldChampionFormationOP2V2:UpdateAttr(id, lev)
    local attrs = {{}, {}, {}, {}, {}}
    local fdata = DataFormation.data_list[string.format("%s_%s", id, lev)]
    if fdata ~= nil then
        attrs = {fdata.attr_1, fdata.attr_2, fdata.attr_3, fdata.attr_4, fdata.attr_5}
    end

    for i,attr in ipairs(attrs) do
        local tab = self.memberTab[i]
        if #attr == 0 then
            tab["formation2"]:SetActive(false)
            tab["formation_txt2"].gameObject:SetActive(false)
            tab["formation_img2"].gameObject:SetActive(false)

            tab["formation1"]:SetActive(true)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(false)

            tab["formation_txt1"].text = TI18N("无加成")
            tab["formation1"].transform.anchoredPosition = Vector2(5, -139)
        elseif #attr == 1 then
            tab["formation1"]:SetActive(true)
            tab["formation2"]:SetActive(false)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(true)
            tab["formation_txt2"].gameObject:SetActive(false)
            tab["formation_img2"].gameObject:SetActive(false)

            tab["formation_txt1"].text = KvData.attr_name_show[attr[1].attr_name]
            if attr[1].val > 0 then
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["formation1"].transform.anchoredPosition = Vector2(0, -139)

        elseif #attr == 2 then
            tab["formation1"]:SetActive(true)
            tab["formation2"]:SetActive(true)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(true)
            tab["formation_txt2"].gameObject:SetActive(true)
            tab["formation_img2"].gameObject:SetActive(true)

            tab["formation_txt1"].text = KvData.attr_name_show[attr[1].attr_name]
            tab["formation_txt2"].text = KvData.attr_name_show[attr[2].attr_name]
            if attr[1].val > 0 then
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["formation1"].transform.anchoredPosition = Vector2(-34, -139)

            if attr[2].val > 0 then
                tab["formation_img2"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img2"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["formation2"].transform.anchoredPosition = Vector2(25, -139)
        end
    end
end

function WorldChampionFormationOP2V2:InitFormationList()
    local list = FormationManager.Instance.formationList
    local parent = self.mainPanel.FormatChangeGuard.transform:Find("Main/Scroll/Container")
    local BaseItem = self.mainPanel.FormatChangeGuard.transform:Find("Main/Scroll/Cloner")
    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 43
        ,Top = 0
    }
    self.Layout = LuaBoxLayout.New(parent, setting)
    for i,v in ipairs(list) do
        local item = GameObject.Instantiate(BaseItem.gameObject)
        local formationdata = DataFormation.data_list[BaseUtils.Key(tostring(v.id), tostring(v.lev))]
        item.transform:Find("Text"):GetComponent(Text).text = string.format("%slv.%s", formationdata.name, formationdata.lev)
        item.transform:GetComponent(Button).onClick:AddListener(function()
            if self.mainPanel.currformation ~= v.id then
                self.Mgr:Require16415(v.id)
                self.mainPanel.FormatChangeGuard:SetActive(false)
            end
        end)
        self.Layout:AddCell(item)
    end
end

function WorldChampionFormationOP2V2:ShowNoticeGroup(show)
    self.show = show
    if show then
        self.NoticeGroup:SetActive(true)

        for i=2,5 do
            local member = self.mainPanel.memberList[i]
            if member ~= nil and member.isGuard then
                self.guardButtonList[i]:SetActive(true)
            else
                self.guardButtonList[i]:SetActive(false)
            end
        end
    else
        self.NoticeGroup:SetActive(false)
        for i=2,5 do
            self.guardButtonList[i]:SetActive(false)
        end
    end
end

function WorldChampionFormationOP2V2:UpdateGuardButton()
    if self.show then
        for i=2,5 do
            local member = self.mainPanel.memberList[i]
            if member ~= nil and member.isGuard then
                self.guardButtonList[i]:SetActive(true)
            else
                self.guardButtonList[i]:SetActive(false)
            end
        end
    end
end

function WorldChampionFormationOP2V2:ShowSelectGuardPanel(index)
    -- print("Click "..index)
    local member = self.mainPanel.memberList[index]
    if member ~= nil and member.isGuard then
        -- print("Open")
        local callBack = function(base_id)
            -- print("Select: "..base_id)

            for memberIndex, member in ipairs(self.mainPanel.memberList) do
                if member.base_id == base_id then
                    local data = self.mainPanel.memberList[index]
                    if member.rid ~= data.rid or member.platform ~= data.platform or member.zone_id ~= data.zone_id then
                        WorldChampionManager.Instance:Require16414(member.rid, member.platform, member.zone_id, data.rid, data.platform, data.zone_id)
                    end
                    return
                end
            end

            WorldChampionManager.Instance:Require16429(base_id, index)
        end

        self.changeGuard:Show({ index = index, base_id = member.base_id, callBack = callBack })
    end
end