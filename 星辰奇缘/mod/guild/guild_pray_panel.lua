--2017/2/17
--公会祈福
--zzl

GuildPrayPanel = GuildPrayPanel or BaseClass(BasePanel)

function GuildPrayPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.guild_pray_panel, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20302), type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.has_init = false

    self.OnOpenEvent:AddListener(function()
        self:UpdateBottom()
    end)

    self.OnHideEvent:Add(function()
    end)
    self.curIndex = 1
    self.roleCurList = {}
    self.roleNewList = {}
    self.petCurList = {}
    self.petNewList = {}
    self.need1 = nil
    self.need2 = nil
    self.has2 = nil

    self.skillIconDic = {[62000] = 36, [62100] = 6, [62200] = 7, [62300] = 21, [62400] = 56, [62500] = 57}
    self.timerId = 0
    self.effectDelayTimerId = 0
    return self
end

function GuildPrayPanel:__delete()
    self:SaveData()
    if self.effectDelayTimerId ~= 0 then
        LuaTimer.Delete(self.effectDelayTimerId)
        self.effectDelayTimerId = 0
    end


    self:StopTimer()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.last_selected_item = nil
    self:AssetClearAll()
end


function GuildPrayPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_pray_panel))
    self.gameObject.name = "GuildPrayPanel"
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)
    self.transform = self.gameObject.transform

    self.LeftCon = self.transform:Find("LeftCon")
    self.ImgBg = self.LeftCon:Find("ImgBg")

    self.effect_success_go = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20302)))
    self.effect_success_go.transform:SetParent(self.LeftCon)
    self.effect_success_go.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_success_go.transform, "UI")
    self.effect_success_go.transform.localScale = Vector3(1, 1, 1)
    self.effect_success_go.transform.localPosition = Vector3(0, 0, -400)
    self.effect_success_go:SetActive(false)

    self.RightCon = self.transform:Find("RightCon")
    self.InfoCon = self.RightCon:Find("InfoCon")
    self.RightUnOpenGo = self.InfoCon:Find("UnOpenCon").gameObject
    self.RightOpenGo = self.InfoCon:Find("AttrCon").gameObject
    self.TopCon = self.InfoCon:Find("AttrCon/TopCon")
    self.topItemList = {}
    for i = 1, 12 do
        local item = self.TopCon:Find(string.format("MaskCon/ScrollLayer/Container/Item%s", i))
        table.insert(self.topItemList, item)
    end
    local nothing = self.TopCon:Find("Nothing")
    self.topNothing = nothing.gameObject
    self.topNothingTxt = nothing:GetComponent(Text)

    self.BottomUnOpenConGo = self.InfoCon:Find("AttrCon/UnOpenCon").gameObject
    self.BottomOpenConGo = self.InfoCon:Find("AttrCon/BottomCon").gameObject
    self.BottomCon = self.InfoCon:Find("AttrCon/BottomCon")
    self.bottomItemList = {}
    for i = 1, 12 do
        local item = self.BottomCon:Find(string.format("MaskCon/ScrollLayer/Container/Item%s", i))
        table.insert(self.bottomItemList, item)
    end
    self.BottomBtnCon = self.transform:Find("BottomCon")
    self.ItemCostCon = self.BottomBtnCon:Find("ItemCostCon")
    self.costIcon = self.ItemCostCon:Find("ImgTxtVal/ImgGx"):GetComponent(Image)
    self.costTxt = self.ItemCostCon:Find("ImgTxtVal/TxtVal"):GetComponent(Text)
    self.ItemHasCon = self.BottomBtnCon:Find("ItemHasCon")
    self.hasIcon = self.ItemHasCon:Find("ImgTxtVal/ImgGx"):GetComponent(Image)
    self.hasTxt = self.ItemHasCon:Find("ImgTxtVal/TxtVal"):GetComponent(Text)
    self.Toggle1 = self.BottomBtnCon:Find("Toggle1"):GetComponent(Toggle)
    self.Toggle2 = self.BottomBtnCon:Find("Toggle2"):GetComponent(Toggle)
    self.Toggle2.onValueChanged:AddListener(function()
        self:IsNoticeConfirm()
    end)

    self.tgl_ignore = self.BottomBtnCon:Find("tgl_ignore"):GetComponent(Toggle)
    self.BtnConfirm = self.BottomBtnCon:Find("BtnToggle"):GetComponent(Button)
    self.Toggle1.onValueChanged:AddListener(function()
        self:UpdateBottom()
    end)

    self.Toggle2.onValueChanged:AddListener(function()
        self:SaveData()
        self:UpdateBottom()
    end)

    self.tgl_ignore.onValueChanged:AddListener(function()
        self:SaveData()
    end)

    self.BtnSave = self.BottomBtnCon:Find("BtnSave"):GetComponent(Button)

    self.BtnSaveEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnSaveEffect.transform:SetParent(self.BtnSave.transform)
    self.BtnSaveEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnSaveEffect.transform, "UI")
    self.BtnSaveEffect.transform.localScale = Vector3(1.6, 0.8, 1)
    self.BtnSaveEffect.transform.localPosition = Vector3(-50, -18, -400)
    self.BtnSaveEffect:SetActive(false)
    self.BtnSaveTxt = self.BottomBtnCon:Find("BtnSave/Text"):GetComponent(Text)

    self.BtnSaveTxt.color = ColorHelper.DefaultButton4
    self.BtnSave.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self.BtnSave.enabled = false
     self.BtnSaveEffect:SetActive(false)


    self.BtnPray = self.BottomBtnCon:Find("BtnPray"):GetComponent(Button)
    self.BtnPrayTxt = self.BottomBtnCon:Find("BtnPray/Text"):GetComponent(Text)
    self.TxtTime = self.BottomBtnCon:Find("TxtTime"):GetComponent(Text)
    self.BtnConfirm.onClick:AddListener(function()
        if self.Toggle1.isOn then

            self.costTxt.text = string.format("%s", self.need1)
            self.Toggle1.isOn = false
        else
            self.parent.model:OpenPrayConfirmWindow()
        end
    end)
    self.BtnSave.onClick:AddListener(function()
        GuildManager.Instance:request11191(self.curIndex)
    end)
    self.BtnPray.onClick:AddListener(function()
        local totalLev = 0
        for i = 1, #self.parent.model.my_guild_data.element_info do
            totalLev = totalLev + self.parent.model.my_guild_data.element_info[i].lev
        end
        local costCfgData = DataGuild.data_guild_element_cost[totalLev]
        local hasCoin = RoleManager.Instance.RoleData.coin
        local needCoin1 = costCfgData.pray_loss_1[1][2]
        local mySelf = self.parent.model:get_mine_member_data()
        local hasGongXian = mySelf.TotalGx
        local needCoin2 = costCfgData.pray_loss_2[1][2]
        local needGongXian2 = costCfgData.pray_loss_2[2][2]
        local  costType = 1
        local  useType = 1
        if self.Toggle2.isOn then
            costType = 2
        end
        if self.Toggle1.isOn then
            useType = 2
        end
        if needGongXian2 > hasGongXian and not self.Toggle2.isOn then

             -- NoticeManager.Instance:FloatTipsByString(TI18N("您当前的公会贡献不足，无法祈福"))
             self:IsNoticeConfirm()
--            local confirmData = NoticeConfirmData.New()
--            confirmData.type = ConfirmData.Style.Normal
--            confirmData.sureLabel = TI18N("确认")
--            confirmData.cancelLabel = TI18N("取消")
--            confirmData.sureCallback = function()
--                self:SwitchPrayBtnState(false)
--                GuildManager.Instance:request11190(self.curIndex, useType,costType)
--            end
--            confirmData.content = string.format(TI18N("您当前的公会贡献不足，是否消耗%s银币进行祈福？"), needCoin1)
--            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self:SwitchPrayBtnState(false)
            GuildManager.Instance:request11190(self.curIndex, useType,costType)
        end
    end)

    -- local tabBtnGroupGo = self.RightCon:Find("TabButtonGroup").gameObject
    -- self.tabgroup = TabGroup.New(tabBtnGroupGo, function (tab) self:OnTabChange(tab) end)
    -- self.tabgroup:ChangeTab(1)

    self.tab_btn1 = self.RightCon:Find("TabButtonGroup"):GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:OnTabChange(1) end)
    self.tab_btn2 = self.RightCon:Find("TabButtonGroup"):GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:OnTabChange(2) end)

    self:SetData()
    if self.openArgs ~= nil then
        if self.openArgs == 2 then
            if self.parent.model:CheckPrayElementLev() then
                self:OnTabChange(2)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("至少一个元素升至20级才能开启宠物祈福哦{face_1,32}"))
                self:OnTabChange(1)
            end
        else
            self:OnTabChange(1)
        end
    else
        self:OnTabChange(1)
    end
end

--切换toggle
function GuildPrayPanel:OnSwitchPrayToggle()
    self.Toggle1.isOn = true
    local costCfgData = DataGuild.data_guild_element_cost[totalLev]
    if costCfgData ~= nil then
        local need1 = self.need1 * 1.3
        local mySelf = self.parent.model:get_mine_member_data()
        local has2 = mySelf.TotalGx
        local need2 = costCfgData.pray_loss_2[2][2]
        local color2 = has2 >= need2 and "#08F612" or  "#FF0000"
        self.hasTxt.text = string.format("<color='%s'>%s</color>/%s", color2, has2, need2 * 1.3)
        self.costTxt.text = string.format("%s",need1)
    end
end

function GuildPrayPanel:IsNoticeConfirm()
    if self.Toggle2.isOn == false and self.has2 < self.need2 then
         local data = NoticeConfirmData.New()
              data.type = ConfirmData.Style.Normal
              data.content = "公会贡献不足,是否只消耗银币"
              data.sureLabel = "确定"
              data.cancelLabel = "取消"
              data.sureCallback = function() self.Toggle2.isOn = true  self:UpdateBottom() end
              data.showClose = 1
              data.blueSure = true
              data.greenCancel = true
              data.cancelCallback = sure
              NoticeManager.Instance:ConfirmTips(data)
    end
end
--切换祈祷按钮状态
function GuildPrayPanel:SwitchPrayBtnState(state)
    self.BtnPray.enabled = state
    if state then
        self.BtnPrayTxt.color = ColorHelper.DefaultButton3
        self.BtnPray.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    else
        self.BtnPrayTxt.color = ColorHelper.DefaultButton4
        self.BtnPray.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
end

--播特效
function GuildPrayPanel:SetData()

    local roleData = RoleManager.Instance.RoleData
    local key1 = BaseUtils.Key(roleData.id,roleData.platform,roleData.zone_id,"tgl_ignore")
    local key2 = BaseUtils.Key(roleData.id,roleData.platform,roleData.zone_id,"Toggle2")
    local str1 = PlayerPrefs.GetString(key1)
    local str2 = PlayerPrefs.GetString(key2)

    if str1 == "true" then
        self.tgl_ignore.isOn = true
    elseif str1 == "false" then
        self.tgl_ignore.isOn = false
    end

    if str2 == "true" then
        self.Toggle2.isOn = true
    elseif str2 == "false" then
        self.Toggle2.isOn = false
    end

end

function GuildPrayPanel:SaveData()
    local roleData = RoleManager.Instance.RoleData
    local key1 = BaseUtils.Key(roleData.id,roleData.platform,roleData.zone_id,"tgl_ignore")
    local key2 = BaseUtils.Key(roleData.id,roleData.platform,roleData.zone_id,"Toggle2")
    local str1 = nil
    local str2 = nil

    if self.tgl_ignore ~= nil then
        if self.tgl_ignore.isOn == true then
            str1 = "true"
        elseif self.tgl_ignore.isOn == false then
            str1 = "false"
        end
    end

    --print(str1 .. "此时设置的是否播放特效")
    if self.Toggle2 ~= nil then
        if self.Toggle2.isOn == true then
            str2 = "true"
        elseif self.Toggle2.isOn == false then
            str2 = "false"
        end
    end


    PlayerPrefs.SetString(key1,str1)
    PlayerPrefs.SetString(key2,str2)
end

function GuildPrayPanel:PlayEffect(data)
   if self.effectDelayTimerId ~= 0 then
        LuaTimer.Delete(self.effectDelayTimerId)
        self.effectDelayTimerId = 0
    end
    self.effect_success_go:SetActive(false)
    if self.tgl_ignore.isOn then
        self.isPrayUpdate = false
        self:UpdatePrayPanelAttr(data)
       return
    end
    self.effect_success_go:SetActive(true)
    self.effectDelayTimerId = LuaTimer.Add(2800, function()
        self.isPrayUpdate = false
        if self.effect_success_go ~= nil then
           self.effect_success_go:SetActive(false)
           self:UpdatePrayPanelAttr(data)
        end
    end )
end

function GuildPrayPanel:SwitchTabBtn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

function GuildPrayPanel:OnTabChange(index)
    if index == 2 then
        if not self.parent.model:CheckPrayElementLev() then
            NoticeManager.Instance:FloatTipsByString(TI18N("至少一个元素升至20级才能开启宠物祈福哦{face_1,32}"))
            return
        end
    end
    self.curIndex = index
    if self.curSocketData == nil then
        GuildManager.Instance:request11192()
    else
        self:UpdatePrayPanelAttr(self.curSocketData)
    end
    if index == 1 then
        self:SwitchTabBtn(self.tab_btn1)
    else
        self:SwitchTabBtn(self.tab_btn2)
    end
end

--更新属性
function GuildPrayPanel:UpdatePrayPanelAttr(data)
    self:SwitchPrayBtnState(true)
    self.curSocketData = data
    self:StopTimer()
    self.end_time = 0
    self.temp_end_time = 0
    for k, v in pairs(data.element_attr) do
        if v.effect_obj == self.curIndex then
            self.end_time  = v.end_time - BaseUtils.BASE_TIME
            break
        end
    end
    for k, v in pairs(data.tmp_element_attr) do
        if v.effect_obj == self.curIndex then
            self.temp_end_time  = v.end_time - BaseUtils.BASE_TIME
            break
        end
    end
    self.roleCurList, self.roleNewList, self.petCurList, self.petNewList =  self.parent.model:GetPrayList(data)
    if self.end_time  > 0 then
        self:StartTimer()
    else
        self.TxtTime.text = ""
    end
    if self.end_time <= 2 then
        self.roleCurList = {}
        self.petCurList = {}
    end
    if self.temp_end_time <= 2 then
        self.roleNewList = {}
        self.petNewList = {}
    end

    if self.curIndex == 1 then
        --角色
        self:UpdateRoleTab()
    elseif self.curIndex == 2 then
        --宠物
        self:UpdatePetTab()
    end
    self:UpdateBottom()
end

--更新角色tab
function GuildPrayPanel:UpdateRoleTab(data)
    if #self.roleCurList == 0 and #self.roleNewList == 0 then
        self.RightUnOpenGo:SetActive(true)
        self.RightOpenGo:SetActive(false)
    else
        self.RightUnOpenGo:SetActive(false)
        self.RightOpenGo:SetActive(true)
        if #self.roleNewList == 0 then
            self.BottomUnOpenConGo:SetActive(true)
            self.BottomOpenConGo:SetActive(false)
        else
            self.BottomUnOpenConGo:SetActive(false)
            self.BottomOpenConGo:SetActive(true)
        end
        self:UpdateItemTop(self.roleCurList)
        self:UpdateItemBottom(self.roleNewList)
    end
end

--更新宠物tab
function GuildPrayPanel:UpdatePetTab(data)
    if #self.petCurList == 0 and #self.petNewList == 0 then
        self.RightUnOpenGo:SetActive(true)
        self.RightOpenGo:SetActive(false)
    else
        self.RightUnOpenGo:SetActive(false)
        self.RightOpenGo:SetActive(true)
        if #self.petNewList == 0 then
            self.BottomUnOpenConGo:SetActive(true)
            self.BottomOpenConGo:SetActive(false)
        else
            self.BottomUnOpenConGo:SetActive(false)
            self.BottomOpenConGo:SetActive(true)
        end
        self:UpdateItemTop(self.petCurList)
        self:UpdateItemBottom(self.petNewList)
    end
end

--更新当前祝福
function GuildPrayPanel:UpdateItemTop(dataList)
    for i = 1, #self.topItemList do
        self.topItemList[i].gameObject:SetActive(false)
    end
    for i = 1, #dataList do
        local data = dataList[i]
        local item = self.topItemList[i]
        self:SetAttrItem(item, data)
        item.gameObject:SetActive(true)
    end

    if #self.roleCurList == 0 and #self.roleNewList > 0 then
        self.topNothing:SetActive(true)
        self.topNothingTxt.text = TI18N("祝福效果已过期\n<color='#ffffff'>请保存新祝福或重新祈福</color>")
    else
        self.topNothing:SetActive(false)
        self.topNothingTxt.text = ""
    end
end

--更新新的祝福
function GuildPrayPanel:UpdateItemBottom(dataList)
    for i = 1, #self.bottomItemList do
        self.bottomItemList[i].gameObject:SetActive(false)
    end
    for i = 1, #dataList do
        local data = dataList[i]
        local item = self.bottomItemList[i]
        self:SetAttrItem(item, data)
        item.gameObject:SetActive(true)
    end

    if self.temp_end_time > 2 and #dataList > 0 then
        self.BtnSaveTxt.color = ColorHelper.DefaultButton2
        self.BtnSave.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.BtnSave.enabled = true
         self.BtnSaveEffect:SetActive(false)
    else
        self.BtnSaveTxt.color = ColorHelper.DefaultButton4
        self.BtnSave.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BtnSave.enabled = false
         self.BtnSaveEffect:SetActive(false)
    end
end

--设置属性Item
function GuildPrayPanel:SetAttrItem(item, data)
    local ImgIcon = item:Find("ImgIcon"):GetComponent(Image)
    local TxtName = item:Find("TxtName"):GetComponent(Text)

    local skillStr = ""
    local iconStr = ""
    if data.effect_type == nil then
        --附加技能
        local skillData = DataSkillPrac.data_skill[data.skill_id]
        skillStr = string.format("%s <color='#ffff00'>+%s</color>", skillData.name, data.lev)
        iconStr = string.format("AttrIcon%s", self.skillIconDic[data.skill_id])
    else
        if KvData.prop_percent[data.effect_type] == nil then
            skillStr = string.format("%s <color='#ffff00'>+%s</color>", KvData.attr_name[data.effect_type], data.val)
        else
            skillStr = string.format("%s <color='#ffff00'>+%s%%</color>", KvData.attr_name[data.effect_type], data.val / 10)
        end
        iconStr = string.format("AttrIcon%s", data.effect_type)
    end
    TxtName.text = skillStr
    ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, iconStr)
end

--更新界面底部
function GuildPrayPanel:UpdateBottom()
    self:SetData()
    local totalLev = 0
    for i = 1, #self.parent.model.my_guild_data.element_info do
        totalLev = totalLev + self.parent.model.my_guild_data.element_info[i].lev
    end
    local costCfgData = DataGuild.data_guild_element_cost[totalLev]
    if costCfgData ~= nil then
        -- if self.Toggle1.isOn then
        --     local has1 = RoleManager.Instance.RoleData.coin
        --     local need1 = costCfgData.pray_loss_1[1][2]
        --     local color1 = has1 >= need1 and "#08F612" or  "#FF0000"
        --     self.costTxt.text = string.format("%s", need1)
        --     self.ItemCostCon.gameObject:SetActive(true)
        --     self.ItemHasCon.gameObject:SetActive(true)
        --     -- local newX = self.ItemCostCon:GetComponent(RectTransform).anchoredPosition.x
        --     -- self.ItemCostCon:GetComponent(RectTransform).anchoredPosition = Vector2(newX, 0)
        -- else
            self.ItemCostCon.gameObject:SetActive(true)
            self.ItemHasCon.gameObject:SetActive(true)
            local has1 = RoleManager.Instance.RoleData.coin
            local mySelf = self.parent.model:get_mine_member_data()
            local has2 = mySelf.TotalGx
            local need1 = costCfgData.pray_loss_2[1][2]
            local need2 = costCfgData.pray_loss_2[2][2]
            local color1 = has1 >= need1 and "#08F612" or  "#FF0000"
            local color2 = has2 >= need2 and "#08F612" or  "#FF0000"
            if self.Toggle2.isOn then
            need1 = costCfgData.pray_loss_1[1][2]
            need2 = 0
            end
            self.need1 = need1
            self.need2 = need2
            self.has2 = has2
            if self.Toggle1.isOn == true then
               self.costTxt.text = string.format("%s",need1 * 1.3)
               self.hasTxt.text = string.format("<color='%s'>%s</color>/%s", color2, has2, need2 * 1.3)
            else
                self.costTxt.text = string.format("%s",need1)
                self.hasTxt.text = string.format("<color='%s'>%s</color>/%s", color2, has2, need2)
            end

            -- local newX = self.ItemCostCon:GetComponent(RectTransform).anchoredPosition.x
            -- self.ItemCostCon:GetComponent(RectTransform).anchoredPosition = Vector2(newX, 20.5)
        -- end
    end

end

function GuildPrayPanel:GetAttrList(data)
    local roleCurList = {}
    local roleNewList = {}
    local petCurList = {}
    local petNewList = {}

    for k, v in pairs(data.element_attr) do
        if v.effect_obj == 1 then
            for k1, v1 in pairs(v.attr) do
                table.insert(roleCurList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(roleCurList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(roleCurList, v1)
            end
        elseif v.effect_obj == 2 then
            for k1, v1 in pairs(v.attr) do
                table.insert(petCurList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(petCurList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(petCurList, v1)
            end
        end
    end
    for k, v in pairs(data.tmp_element_attr) do
        if v.effect_obj == 1 then
            for k1, v1 in pairs(v.attr) do
                table.insert(roleNewList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(roleNewList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(roleNewList, v1)
            end
        elseif v.effect_obj == 2 then
            for k1, v1 in pairs(v.attr) do
                table.insert(petNewList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(petNewList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(petNewList, v1)
            end
        end
    end
    return roleCurList ,roleNewList ,petCurList ,petNewList
end



------计时器逻辑
function GuildPrayPanel:StartTimer()
    self:StopTimer()
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimerTick() end)
end

function GuildPrayPanel:StopTimer()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function GuildPrayPanel:TimerTick()
    -- local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.end_time - 1)
    -- self.TxtTime.text = string.format(TI18N("剩余时间：%s天%s小时"), my_date)
end