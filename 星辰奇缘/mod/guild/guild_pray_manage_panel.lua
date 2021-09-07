--2017/2/16
--公会祈福管理
--zzl

GuildPrayManagePanel = GuildPrayManagePanel or BaseClass(BasePanel)

function GuildPrayManagePanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.guild_pray_manage_panel, type = AssetType.Main}
        , {file = AssetConfig.guild_element_icon, type = AssetType.Dep}
    }
    self.has_init = false

    self.OnOpenEvent:AddListener(function()
    end)

    self.OnHideEvent:Add(function()
    end)

    self.itemList = nil
    self.lastSelectedItem = nil
    self.timer_id = 0
    return self
end

function GuildPrayManagePanel:__delete()
    self:StopTimer()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.last_selected_item = nil
    self:AssetClearAll()
end


function GuildPrayManagePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_pray_manage_panel))
    self.gameObject.name = "GuildPrayManagePanel"
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)
    self.transform = self.gameObject.transform


    self.main = self.gameObject.transform:Find("Main")
    self.LeftCon = self.main:Find("LeftCon")
    self.MaskLayer = self.LeftCon:Find("MaskLayer")
    self.ScrollLayer = self.MaskLayer:Find("ScrollLayer")
    self.LayoutLayer = self.ScrollLayer:Find("LayoutLayer")
    self.Item = self.LayoutLayer:Find("Item").gameObject
    self.Item:SetActive(false)
    self.itemList = {}

    self.RightCon = self.main:Find("RightCon")
    self.BtnCon = self.RightCon:Find("BtnCon")
    self.BtnStudy = self.BtnCon:Find("BtnStudy"):GetComponent(Button)
    self.ProgCon = self.BtnCon:FindChild("ProgCon")
    self.ImgProg = self.ProgCon.transform:FindChild("GrowupProgCon"):FindChild("ImgProg")
    self.ImgProgBar_rect = self.ImgProg.transform:FindChild("ImgProgBar"):GetComponent(RectTransform)
    self.TxtProg = self.ImgProg.transform:FindChild("TxtProg"):GetComponent(Text)

    self.TopCon = self.RightCon:Find("TopCon")
    self.ImgTitle = self.TopCon:Find("ImgTitle")
    self.TxtLev = self.ImgTitle:Find("TxtLev"):GetComponent(Text)
    self.TxtName = self.ImgTitle:Find("TxtName"):GetComponent(Text)
    self.TxtDesc = self.TopCon:Find("TxtDesc"):GetComponent(Text)
    self.TxtEffectDesc = self.TopCon:Find("TxtEffectDesc"):GetComponent(Text)

    self.txtCost1 = self.TopCon:Find("CostCon/Item1/ImgTxtVal/TxtVal"):GetComponent(Text)
    self.txtCost2 = self.TopCon:Find("CostCon/Item2/ImgTxtVal/TxtVal"):GetComponent(Text)
    self.txtCost3 = self.TopCon:Find("CostCon/Item3/ImgTxtVal/TxtVal"):GetComponent(Text)

    self.BtnStudy.onClick:AddListener(function()
        GuildManager.Instance:request11111(self.lastSelectedItem.data.build_type, 0)
    end)

    self:UpdateLeftList()
end

function GuildPrayManagePanel:UpdateRight(item)
    if self.lastSelectedItem ~= nil then
        self.lastSelectedItem.ImgSelect:SetActive(false)
    end
    item.ImgSelect:SetActive(true)
    self.lastSelectedItem = item

    self.TxtLev.text = string.format("Lv.%s", item.cfgData.lev)
    self.TxtName.text = item.cfgData.element_name


    local nextCfgData = DataGuild.data_guild_element[string.format("%s_%s", item.data.lev+1, item.data.build_type)]
    if nextCfgData ~= nil and RoleManager.Instance.world_lev < nextCfgData.need_world_lev then
        self.TxtDesc.text = string.format(TI18N("%s\n<color='#AB3AD5'>（下级学习需世界等级达到%s）</color>"), item.cfgData.desc, nextCfgData.need_world_lev)
    else
        self.TxtDesc.text = string.format(TI18N("%s"), item.cfgData.desc)
    end

    local roleStr = ""
    for i = 1, #item.cfgData.buff_attr do
        local attrCfgData = DataGuild.data_get_element_attr_ratio[item.cfgData.buff_attr[i].attr_type]
        local attrName = KvData.attr_name[item.cfgData.buff_attr[i].attr_type]
        local roleMin =  math.floor(item.cfgData.buff_attr[i].val*attrCfgData.odds[1][1]/100)
        local roleMax = math.floor(item.cfgData.buff_attr[i].val*attrCfgData.odds[#attrCfgData.odds][1]/100)
        if roleStr == "" then
            roleStr = string.format(TI18N("角色：<color='#FFF000'>%s~%s</color>%s"), roleMin, roleMax, attrName)
        else
            roleStr = string.format("%s、<color='#FFF000'>%s~%s</color>%s", roleStr, roleMin, roleMax, attrName)
        end
    end
    local petLev = item.cfgData.open_pet_lev
    local petStr = ""
    if item.data.lev >= petLev then
        for i = 1, #item.cfgData.pet_buff_attr do
            local attrCfgData = DataGuild.data_get_element_attr_ratio[item.cfgData.pet_buff_attr[i].attr_type]
             local attrName = KvData.attr_name[item.cfgData.pet_buff_attr[i].attr_type]
            local roleMin =  math.floor(item.cfgData.pet_buff_attr[i].val*attrCfgData.odds[1][1]/100)
            local roleMax = math.floor(item.cfgData.pet_buff_attr[i].val*attrCfgData.odds[#attrCfgData.odds][1]/100)
            if petStr == "" then
                petStr = string.format(TI18N("宠物：<color='#FFF000'>%s~%s</color>%s"), roleMin, roleMax, attrName)
            else
                petStr = string.format("%s、<color='#FFF000'>%s~%s</color>%s", petStr, roleMin, roleMax, attrName)
            end
        end
    else
        petStr = string.format(TI18N("宠物：当%s达到<color='#AB3AD5'>%s</color>级时开启宠物祝福"), item.cfgData.element_name, petLev)
    end
    local blessStr = ""
    local lastStr = ""
    if #item.cfgData.skill_prac > 0 or #item.cfgData.up_attr > 0 or #item.cfgData.pet_up_attr then
        if #item.cfgData.skill_prac > 0 or #item.cfgData.up_attr > 0 then
            for i = 1, #item.cfgData.skill_prac do
                local temp = string.format(TI18N("角色%s+%s"), DataSkillPrac.data_skill[item.cfgData.skill_prac[i][1]].name, item.cfgData.skill_prac[i][2])
                if blessStr == "" then
                    blessStr = temp
                else
                    blessStr = string.format(TI18N("%s、%s"), blessStr, temp)
                end
            end
            for i = 1, #item.cfgData.up_attr do
                local temp = string.format(TI18N("角色%s"), KvData.GetAttrStringNoColor(item.cfgData.up_attr[i].attr_name, item.cfgData.up_attr[i].val))
                if blessStr == "" then
                    blessStr = temp
                else
                    blessStr = string.format(TI18N("%s、%s"), blessStr, temp)
                end
            end
        end

        if #item.cfgData.pet_up_attr > 0 then
            for i = 1, #item.cfgData.pet_up_attr do
                local tempVal = item.cfgData.pet_up_attr[i].val
                local tempKey = item.cfgData.pet_up_attr[i].attr_name
                if tempKey == 30 or tempKey == 31 or tempKey == 45 or tempKey == 46 then
                    tempVal = string.format("%s%s", tempVal/10, "%")
                end
                local temp = string.format(TI18N("宠物%s+%s"),  KvData.attr_name[item.cfgData.pet_up_attr[i].attr_name], tempVal)
                if blessStr == "" then
                    blessStr = temp
                else
                    blessStr = string.format(TI18N("%s、%s"), blessStr, temp)
                end
            end
        end
    end
    if blessStr == "" or item.data.lev < petLev then
        lastStr = ""
    else
        if item.cfgData.lev >= 40 then
            lastStr = string.format(TI18N("每次祝福有一定几率获得<color='#ffff00'>%s</color>的祝福"), blessStr)
        else
            lastStr = string.format(TI18N("%s达到<color='#AB3AD5'>%s</color>级时，每次祝福有一定几率获得<color='#ffff00'>%s</color>的祝福"), item.cfgData.element_name, 40, blessStr)
        end
    end

    self.TxtEffectDesc.text = string.format(TI18N("祝福效果\n%s\n%s\n%s"), roleStr, petStr, lastStr)


    GuildManager.Instance:request11193(self.lastSelectedItem.data.build_type)


    self.tick_time = item.data.time - BaseUtils.BASE_TIME
    if self.tick_time > 0 then
        --逢5有cd
        local nextLevCfgData = DataGuild.data_guild_element[string.format("%s_%s", item.cfgData.lev+1, item.cfgData.element_type)]
        self.speedup_fenmu = nextLevCfgData.need_time
        self.BtnStudy.gameObject:SetActive(false)
        self.ProgCon.gameObject:SetActive(true)
        self:StartTimer()
    else
        self.BtnStudy.gameObject:SetActive(true)
        self.ProgCon.gameObject:SetActive(false)
    end
end

--更新底部价格
function GuildPrayManagePanel:UpdateRightBottom(data)
    --更新价格
    local nextLevCfgData = DataGuild.data_guild_element[string.format("%s_%s", self.lastSelectedItem.cfgData.lev+1, self.lastSelectedItem.cfgData.element_type)]
    if nextLevCfgData ~= nil then
        local mySelf = self.parent.model:get_mine_member_data()
        local myAssets = self.parent.model.my_guild_data.Assets
        local color = ""
        color = myAssets >= nextLevCfgData.cost and "#08F612" or "#08F612"
        self.txtCost1.text = string.format("<color='%s'>%s</color>", color, tostring(nextLevCfgData.cost))
        self.txtCost2.text = string.format("<color='%s'>%s</color>", color, tostring(nextLevCfgData.need))
        self.txtCost3.text = tostring(myAssets)
        self.TopCon:Find("CostCon").gameObject:SetActive(true)
        self.TopCon:Find("UnOpenCon").gameObject:SetActive(false)
    else
        self.TopCon:Find("CostCon").gameObject:SetActive(false)
        self.TopCon:Find("UnOpenCon").gameObject:SetActive(true)
    end
end

function GuildPrayManagePanel:UpdateLeftList()
    for i = 1, #self.itemList do
        self.itemList[i].go:SetActive(false)
    end
    local tempDataList = self.parent.model.my_guild_data.element_info
    local index = 1

    local dataList = {}
    for k, v in pairs(tempDataList) do
        if v.build_type == 6 then
            dataList[1] = v
        elseif v.build_type == 5 then
            dataList[2] = v
        elseif v.build_type == 9 then
            dataList[3] = v
        elseif v.build_type == 8 then
            dataList[4] = v
        elseif v.build_type == 7 then
            dataList[5] = v
        elseif v.build_type == 10 then
            dataList[6] = v
        end
    end

    for i = 1, #dataList do
        local data = dataList[i]
        local cfgData = DataGuild.data_guild_element[string.format("%s_%s", data.lev, data.build_type)]
        if cfgData ~= nil then
            local item = self.itemList[index]
            if item == nil then
                item = self:CreateItem(self.Item)
                table.insert(self.itemList, item)
            end
            self:SetItemData(item, data, index)
            index = index + 1
        end
    end
    local newH = 80*#dataList
    self.LayoutLayer:GetComponent(RectTransform).sizeDelta = Vector2(0, newH)


    if self.lastSelectedItem ~= nil then
        for i = 1, #self.itemList do
            local item = self.itemList[i]
            if item.data.build_type == self.lastSelectedItem.data.build_type then
                self:UpdateRight(self.lastSelectedItem)
                break
            end
        end
    else
        if self.itemList[1] ~= nil then
            self:UpdateRight(self.itemList[1])
        end
    end
end

function GuildPrayManagePanel:CreateItem(go)
    local item = {}
    item.go = GameObject.Instantiate(go)
    item.transform = item.go.transform
    item.transform:SetParent(go.transform.parent)
    item.transform.localScale = Vector3.one
    item.ImgSelect = item.transform:Find("ImgSelect").gameObject
    item.ImgIcon = item.transform:Find("ImgCon/Img"):GetComponent(Image)
    item.TxtName = item.transform:Find("TxtName"):GetComponent(Text)
    item.TxtDesc = item.transform:Find("TxtDesc"):GetComponent(Text)
    item.TxtLev = item.transform:Find("TxtLev"):GetComponent(Text)
    item.transform:GetComponent(Button).onClick:AddListener(function()
        self:UpdateRight(item)
    end)
    return item
end

function GuildPrayManagePanel:SetItemData(item, data, index)
    item.data = data
    item.cfgData = DataGuild.data_guild_element[string.format("%s_%s", data.lev, data.build_type)]
    item.index = index
    local newY = (index - 1)*-80
    item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(5, newY)
    item.go:SetActive(true)
    item.TxtName.text = item.cfgData.element_name
    local str = ""
    for i = 1, #item.cfgData.buff_attr do
        if str == "" then
            str = string.format(TI18N("提升%s"), KvData.attr_name[item.cfgData.buff_attr[i].attr_type])
        else
            str = string.format("%s、%s", str, KvData.attr_name[item.cfgData.buff_attr[i].attr_type])
        end
    end
    item.TxtDesc.text = str
    item.TxtLev.text = string.format("Lv.%s", item.cfgData.lev)

    item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_element_icon , tostring(item.cfgData.element_type))
end


--计时关掉界面
function GuildPrayManagePanel:StartTimer()
    self:StopTimer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:TimerTick() end)
end

function GuildPrayManagePanel:StopTimer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function GuildPrayManagePanel:TimerTick()
    self.tick_time = self.tick_time - 1

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.tick_time)
    my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)

    self.ImgProgBar_rect.sizeDelta = Vector2(150*self.tick_time/self.speedup_fenmu, self.ImgProgBar_rect.rect.height)
    self.TxtProg.text = string.format("%s:%s:%s", my_hour, my_minute, my_second)
    if self.tick_time <= 0 then
        self:StopTimer()
        self.TxtProg.text = "--:--:--"
        self.BtnStudy.gameObject:SetActive(true)
        self.ProgCon.gameObject:SetActive(false)
    end
end