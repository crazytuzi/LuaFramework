ShouhuMainTabFirst = ShouhuMainTabFirst or BaseClass(BasePanel)

function ShouhuMainTabFirst:__init(parent)
    self.parent = parent
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.guideEffect1 = nil

    self.resList = {
        {file = AssetConfig.shouhu_main_tab1, type = AssetType.Main}
        ,{file = self.effectPath, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20118), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
        ,{file = AssetConfig.petevaluation_texture,type = AssetType.Dep}

    }
    self.has_init = false
    self.init_go = false
    self.rightSkillList = nil
    self.skillItem_list = nil
    self.propTxtList = nil
    self.equipList = nil
    self.cur_model_base_id = 0
    self.shouhuInfoTab = 0--0 主信息，1属性信息
    self.last_selected_item = nil

    self.previewComp1 = nil

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function()
        if self.previewComp1 ~= nil then
            self.previewComp1:Hide()
        end
    end)

    self.updateRightListener = function()
        if self.parent.last_selected_item.data ~= nil then
            self:update_content(self.parent.last_selected_item.data)
        end
    end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateRightListener)
end

function ShouhuMainTabFirst:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateRightListener)

    self.TopCon.transform:Find("PreviewBg"):GetComponent(Image).sprite = nil
    self.BtnQuickBuyCostIcon.sprite = nil
    self.ImgGrowthBg.transform:FindChild("ImgWakeUp"):GetComponent(Image).sprite = nil
    self.TopCon.transform:FindChild("GiftTips/Tips/ImgCur"):GetComponent(Image).sprite = nil

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.imgLoader2 ~= nil then
        self.imgLoader2:DeleteMe()
        self.imgLoader2 = nil
    end
    if self.BtnRecruitBuy ~= nil then
        self.BtnRecruitBuy:DeleteMe()
        self.BtnRecruitBuy = nil
    end

    for i,v in ipairs(self.equipList) do
        v:DeleteMe()
    end
    self.equipList = nil

    for k, v in pairs(self.propIconList) do
        v.sprite = nil
    end

    for i,v in ipairs(self.rightSkillList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.rightSkillList = nil

    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    self.init_go = false
    self.rightSkillList = nil
    self.skillItem_list = nil
    self.propTxtList = nil
    self.equipList = nil
    self.cur_model_base_id = 0
    self.shouhuInfoTab = 0--0 主信息，1属性信息
    self.last_selected_item = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.has_init = false
    self:AssetClearAll()
end


function ShouhuMainTabFirst:InitPanel()
    --右边

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_main_tab1))
    self.gameObject.name = "ShouhuMainTabFirst"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.Con_right = self.transform:FindChild("Con_right").gameObject
    self.TopCon = self.Con_right.transform:FindChild("TopCon").gameObject
    self.TopCon.transform:Find("PreviewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.BtnOneKey = self.TopCon.transform:FindChild("BtnOnekey"):GetComponent(Button)
    self.MidBg = self.TopCon.transform:FindChild("MidBg"):GetComponent(Image)
    self.PreviewBg = self.TopCon.transform:FindChild("PreviewBg"):GetComponent(Image)
    self.ImgScoreBg = self.TopCon.transform:FindChild("ImgScoreBg").gameObject
    self.TxtScore = self.ImgScoreBg.transform:FindChild("TxtScore"):GetComponent(Text)
    self.BtnTanHao = self.ImgScoreBg.transform:FindChild("BtnTanHao"):GetComponent(Button)
    self.WakeUpCon = self.TopCon.transform:FindChild("WakeUpCon")
    self.WakeUpCon.gameObject:SetActive(false)
    self.WakeUpIconList = {}
    for i = 1, 3 do
        local wakeUpIcon = self.WakeUpCon:FindChild(string.format("WakeUpIcon%s", i)).gameObject
        wakeUpIcon.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickWakeUpStone(i)
        end)
        wakeUpIcon:SetActive(false)
        table.insert(self.WakeUpIconList, wakeUpIcon)
    end
    self.showGrowth = false
    self.ImgGrowthBg = self.TopCon.transform:FindChild("ImgGrowthBg").gameObject
    self.TxtGrowth = self.ImgGrowthBg.transform:FindChild("TxtGrowth"):GetComponent(Text)
    self.ImgWakeUp = self.ImgGrowthBg.transform:FindChild("ImgWakeUp"):GetComponent(Image)
    self.TopCon.transform:FindChild("ImgGrowthBg"):GetComponent(Button).onClick:AddListener(function()
        self.showGrowth = not self.showGrowth
        self.TopCon.transform:FindChild("GiftTips").gameObject:SetActive(self.showGrowth)
    end)
    self.TopCon.transform:FindChild("GiftTips"):GetComponent(Button).onClick:AddListener(function()
        self.showGrowth = false
        self.TopCon.transform:FindChild("GiftTips").gameObject:SetActive(self.showGrowth)
    end)
    self.ImgGrowthCur = self.TopCon.transform:FindChild("GiftTips"):FindChild("Tips"):FindChild("ImgCur"):GetComponent(Image)
    self.TxtGrowthCur = self.TopCon.transform:FindChild("GiftTips"):FindChild("Tips"):FindChild("TxtGrowth"):GetComponent(Text)

    self.Con_mid = self.TopCon.transform:FindChild("Con_mid").gameObject
    self.Preview = self.Con_mid.transform:FindChild("Preview").gameObject

    self.ConTop = self.Con_mid.transform:FindChild("ConTop").gameObject
    self.ConShouhuEquip0 = self.ConTop.transform:FindChild("ConShouhuEquip0").gameObject
    self.ConShouhuEquip1 = self.ConTop.transform:FindChild("ConShouhuEquip1").gameObject
    self.ConShouhuEquip2 = self.ConTop.transform:FindChild("ConShouhuEquip2").gameObject
    self.ConShouhuEquip3 = self.ConTop.transform:FindChild("ConShouhuEquip3").gameObject
    self.ConShouhuEquip4 = self.ConTop.transform:FindChild("ConShouhuEquip4").gameObject
    self.ConShouhuEquip5 = self.ConTop.transform:FindChild("ConShouhuEquip5").gameObject

    self.Con_bottom = self.Con_right.transform:FindChild("Con_bottom").gameObject
    self.ConBottom = self.Con_bottom.transform:FindChild("ConBottom").gameObject
    self.SkillItemCon = self.ConBottom.transform:FindChild("SkillItemCon").gameObject
    self.ShouhuSkill1 = self.SkillItemCon.transform:FindChild("ShouhuSkill1").gameObject
    self.ShouhuSkill2 = self.SkillItemCon.transform:FindChild("ShouhuSkill2").gameObject
    self.ShouhuSkill3 = self.SkillItemCon.transform:FindChild("ShouhuSkill3").gameObject
    self.ShouhuSkill4 = self.SkillItemCon.transform:FindChild("ShouhuSkill4").gameObject
    self.ShouhuSkill5 = self.SkillItemCon.transform:FindChild("ShouhuSkill5").gameObject
    self.ShouhuSkill6 = self.SkillItemCon.transform:FindChild("ShouhuSkill6").gameObject
    self.ShouhuSkill7 = self.SkillItemCon.transform:FindChild("ShouhuSkill7").gameObject
    self.ShouhuSkill8 = self.SkillItemCon.transform:FindChild("ShouhuSkill8").gameObject

    self.skillItem_list = {}
    table.insert(self.skillItem_list, self.ShouhuSkill1)
    table.insert(self.skillItem_list, self.ShouhuSkill2)
    table.insert(self.skillItem_list, self.ShouhuSkill3)
    table.insert(self.skillItem_list, self.ShouhuSkill4)
    table.insert(self.skillItem_list, self.ShouhuSkill5)
    table.insert(self.skillItem_list, self.ShouhuSkill6)
    table.insert(self.skillItem_list, self.ShouhuSkill7)
    table.insert(self.skillItem_list, self.ShouhuSkill8)

    self.PropItemCon = self.ConBottom.transform:FindChild("PropItemCon").gameObject
    self.MaskCon = self.PropItemCon.transform:FindChild("MaskCon").gameObject
    self.ScrollCon = self.MaskCon.transform:FindChild("ScrollCon").gameObject
    self.LayoutCon = self.ScrollCon.transform:FindChild("LayoutCon").gameObject
    self.LayoutCon_rect = self.LayoutCon.transform:GetComponent(RectTransform)

    self.BtnDetailInfo = self.Con_bottom.transform:FindChild("BtnDetailInfo"):GetComponent(Button)
    self.BtnQuickBuy = self.Con_bottom.transform:FindChild("BtnQuickBuy")
    self.BtnQuickBuyBtnCon = self.BtnQuickBuy.transform:FindChild("QuickBuyCon")
    self.BtnQuickBuy.transform:Find("CostCon"):GetComponent(CanvasGroup).blocksRaycasts = false
    self.BtnQuickBuyVal = self.BtnQuickBuy.transform:Find("CostCon/TxtVal"):GetComponent(Text)
    self.BtnQuickBuyIcon = self.BtnQuickBuy.transform:Find("CostCon/ImgIcon")
    self.BtnQuickBuyCostVal = self.BtnQuickBuy.transform:Find("CostCon/CostValCon/TxtCoinVal"):GetComponent(Text)
    self.BtnQuickBuyCostIcon = self.BtnQuickBuy.transform:Find("CostCon/CostValCon/ImgCoinCon"):GetComponent(Image)
    self.BtnRecruitBuy= BuyButton.New(self.BtnQuickBuyBtnCon, TI18N(""))
    self.BtnRecruitBuy.key = "ShouhuRecruit"
    self.BtnRecruitBuy.protoId = 10900
    self.BtnRecruitBuy:Show()
    self.OnRecruitFunc = function()
        self:on_click_list_info_btn(3)
    end
    self.OnPriceBack = function(prices)
        local data =  prices[self.parent.model.my_sh_selected_data.lossItemId]
        if data == nil then
            self.BtnQuickBuy.transform:Find("CostCon/CostValCon").gameObject:SetActive(false)
        else
            local allprice = data.allprice
            local price_str = ""
            if allprice >= 0 then
                price_str = string.format("<color='%s'>%s</color>", "#ffffff", allprice)
            else
                price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
            end
            self.BtnQuickBuyCostVal.text = price_str
            self.BtnQuickBuyCostIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[data.assets])
            self.BtnQuickBuy.transform:Find("CostCon/CostValCon").gameObject:SetActive(true)
        end
    end

    self.BtnRecruit = self.Con_bottom.transform:FindChild("BtnRecruit"):GetComponent(Button)

    self.effect_recruit = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20118)))
    self.effect_recruit.transform:SetParent(self.BtnRecruit.transform)
    self.effect_recruit.transform.localRotation = Quaternion.identity
    self.effect_recruit:SetActive(true)
    Utils.ChangeLayersRecursively(self.effect_recruit.transform, "UI")

    self.effect_recruit.transform.localScale = Vector3(1, 1, 1)
    self.effect_recruit.transform.localPosition = Vector3(-51, 27, -400)

    self.txtBtnRecruit = self.BtnRecruit.transform:FindChild("TxtVal"):GetComponent(Text)
    self.txtBtnRecruitName = self.BtnRecruit.transform:FindChild("Text"):GetComponent(Text)
    self.txtTextLock = self.BtnRecruit.transform:FindChild("TextLock"):GetComponent(Text)
    self.recruitImgIcon = self.BtnRecruit.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.BtnRecruit.gameObject:SetActive(false)

    self.BtnFight = self.Con_bottom.transform:FindChild("BtnFight"):GetComponent(Button)
    self.txtBtnFight = self.BtnFight.transform:FindChild("Text"):GetComponent(Text)

    self.BtnCancel = self.Con_bottom.transform:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCancel.gameObject:SetActive(false)

    --装备
    self.equipList = {}
    local equip0 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip0)
    local equip1 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip1)
    local equip2 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip2)
    local equip3 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip3)
    local equip4 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip4)
    local equip5 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip5)
    table.insert(self.equipList,equip0)
    table.insert(self.equipList,equip1)
    table.insert(self.equipList,equip2)
    table.insert(self.equipList,equip3)
    table.insert(self.equipList,equip4)
    table.insert(self.equipList,equip5)

    --属性
    self.propNameList = {}
    self.propIconList = {}
    self.propTxtList = {}
    self.propTxtBgList = {}

    for i=1, 4 do
        local item = self.LayoutCon.transform:FindChild(string.format("Item%s", i))
            self.propNameList[#self.propNameList+1] = item:Find("Prop1/TxtDesc"):GetComponent(Text)
            self.propIconList[#self.propIconList+1] = item:Find("Prop1/ImgIcon"):GetComponent(Image)
            self.propTxtBgList[#self.propTxtBgList+1] = item:Find("Prop1/ImgValBg")
            self.propTxtList[#self.propTxtList+1] = item:Find("Prop1/ImgValBg/Text"):GetComponent(Text)

            self.propNameList[#self.propNameList].gameObject:SetActive(false)
            self.propIconList[#self.propIconList].gameObject:SetActive(false)
            self.propTxtList[#self.propTxtList].gameObject:SetActive(false)
--
            self.propNameList[#self.propNameList+1] = item:Find("Prop2/TxtDesc"):GetComponent(Text)
            self.propIconList[#self.propIconList+1] = item:Find("Prop2/ImgIcon"):GetComponent(Image)
            self.propTxtBgList[#self.propTxtBgList+1] = item:Find("Prop1/ImgValBg")
            self.propTxtList[#self.propTxtList+1] = item:Find("Prop2/ImgValBg/Text"):GetComponent(Text)

            self.propNameList[#self.propNameList].gameObject:SetActive(false)
            self.propIconList[#self.propIconList].gameObject:SetActive(false)
            self.propTxtBgList[#self.propTxtBgList].gameObject:SetActive(false)
            self.propTxtList[#self.propTxtList].gameObject:SetActive(false)
        -- end
    end
    self.BtnDetailInfo.onClick:AddListener(function() self:on_click_list_info_btn(1) end)  --技能/属性
    self.BtnFight.onClick:AddListener(function() self:on_click_list_info_btn(2) end)  --休息/上阵
    self.BtnRecruit.onClick:AddListener(function() self:on_click_list_info_btn(3) end)  --招募
    self.BtnCancel.onClick:AddListener(function() self:on_click_list_info_btn(4) end)  --取消助战

    self.BtnOneKey.onClick:AddListener(function() self:on_click_list_info_btn(5) end)  --一键升级

    self.BtnTanHao.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("当前守护装备等级低于世界等级<color='#ffff00'>5级</color>，升级装备消耗降低为原来的<color='#ffff00'>50%</color>"))
        TipsManager.Instance:ShowText({gameObject = self.BtnTanHao.gameObject, itemData = tips})

    end)
    self.BtnTanHao.gameObject:SetActive(false)

    self.init_go = true
    self:on_switch_shouhu_info(self.PropItemCon)

    if self.parent.last_selected_item ~= nil then
        self:update_content(self.parent.last_selected_item.data)
    end

    self.guideEffect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.guideEffect.name = "GuideEffect"
    local trans = self.guideEffect.transform
    trans:SetParent(self.BtnRecruit.gameObject.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(trans, "UI")
    self.guideEffect:SetActive(false)

    ----评论按钮
    self.evaluationbtn = self.transform:Find("Con_right/EvaluationButton").gameObject:GetComponent(Button)
    self.evaluationbtn.onClick:AddListener(function()
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petevaluation,{self.parent.model.my_sh_selected_data,2})
     end
    )
end

function ShouhuMainTabFirst:OnInitCompleted()
    GuideManager.Instance:OpenWindow(self.parent.windowId)
end

function ShouhuMainTabFirst:OnShow()
    if self.previewComp1 ~= nil then
        self.previewComp1:Show()
    end
    GuideManager.Instance:OpenWindow(self.parent.windowId)
end
-------------------------------事件监听逻辑
-------切换显示属性还是技能
function ShouhuMainTabFirst:on_switch_shouhu_info(selectCon)
    self.SkillItemCon:SetActive(false)
    self.PropItemCon:SetActive(false)
    selectCon:SetActive(true)
end

--我的守护列表信息按钮点击监听
function ShouhuMainTabFirst:on_click_list_info_btn(bt)
    if bt == 5 then
        --一键升级
        if self.parent.model.my_sh_selected_data == nil then
            return
        end

        local equip_num, cost_num = self.parent.model:get_shouhu_can_equip_up_num(self.parent.model.my_sh_selected_data)

        local str = string.format(TI18N("是否消耗<color='#FFFF9A'>%s</color>{assets_2, 90000}升级%s件装备"), cost_num, equip_num)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            for i=1, #self.parent.model.my_sh_selected_data.equip_list do-- 装备
                local d = self.parent.model.my_sh_selected_data.equip_list[i]
                if (self.parent.model.my_sh_selected_data.sh_lev - d.lev) >= self.parent.model.init_equip_lev then
                    ShouhuManager.Instance:request10902(self.parent.model.my_sh_selected_data.base_id, d.type)
                end
            end
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif bt == 4 then  --取消助战
        --请求守护离阵
        ShouhuManager.Instance:request10909(self.parent.model.my_sh_selected_data.base_id)
    elseif bt == 3 then  --招募
        -- 人物提升到xx级才可以解锁守护名称哦
        TipsManager.Instance:HideGuide()
        if not BaseUtils.is_null(self.guideEffect) then
            self.guideEffect:SetActive(false)
        end

        if self.parent.model.my_sh_selected_data.war_id == nil then
            if self.parent.model.my_sh_selected_data.recruit_lev <= RoleManager.Instance.RoleData.lev then
                --判断下消耗材料是否足够
                local has_num = 0
                if self.parent.model.my_sh_selected_data.lossItemId == 90000 then
                    --消耗银币，检查下银币是否足够
                    if self.parent.model.my_sh_selected_data.lossItemNum > RoleManager.Instance.RoleData.coin then
                        ExchangeManager.Instance.model:OpenPanel(2)
                    end
                else
                    --消耗材料，检查下材料是否足够
                    -- if self.parent.model.my_sh_selected_data.lossItemNum > BackpackManager.Instance:GetItemCount(self.parent.model.my_sh_selected_data.lossItemId) then
                    --     local base_data = DataItem.data_get[self.parent.model.my_sh_selected_data.lossItemId]
                    --     local info = {itemData = base_data, gameObject = self.BtnRecruit.gameObject}
                    --     TipsManager.Instance:ShowItem(info)
                    -- end
                end
                ShouhuManager.Instance:request10900(self.parent.model.my_sh_selected_data.base_id)
            else
                NoticeManager.Instance:FloatTipsByString(string.format("%s<color='%s'>%s%s</color>%s%s%s",TI18N("人物提升到"), ColorHelper.color[5], self.parent.model.my_sh_selected_data.recruit_lev, TI18N("级"), TI18N("才可以解锁"), self.parent.model.my_sh_selected_data.name, TI18N("哦")))
            end
        end
    elseif bt  == 1 then  --属性/技能
        local txt = self.BtnDetailInfo.transform:FindChild("Text"):GetComponent(Text)
        if self.shouhuInfoTab  == 0 then--切换成属性信息
            self.shouhuInfoTab = 1
            txt.text = TI18N("属性")
            self:on_switch_shouhu_info(self.SkillItemCon)
        else
            self.shouhuInfoTab = 0
            txt.text = TI18N("技能")
            self:on_switch_shouhu_info(self.PropItemCon)
        end
    elseif bt  == 2 then  --休息/上阵
        if self.parent.model.my_sh_selected_data.war_id ~= 0 then--休息
            self.parent.model.main_tab_first_opera_type = 1
            FormationManager.Instance:UpDown(self.parent.model.my_sh_selected_data.base_id)
        else--没有上阵
            if self.parent.model.my_sh_selected_data.guard_fight_state == self.parent.model.guard_fight_state.field then
                --守护取消助战
                self.parent.model.main_tab_first_opera_type = 3
                ShouhuManager.Instance:request10909(self.parent.model.my_sh_selected_data.base_id)
            else
                --判断下是否已经有四个守护上阵，是的话则不能再上阵
                local count = 0
                for i=1,#self.parent.model.my_sh_list do
                    local data = self.parent.model.my_sh_list[i]
                    if data.war_id ~= 0 then
                        count = count + 1
                    end
                end
                -- print(count)
                if count < 4 then--上阵
                    self.parent.model.main_tab_first_opera_type = 2
                    FormationManager.Instance:UpDown(self.parent.model.my_sh_selected_data.base_id)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("当前已经上阵4个守护，请先下阵其他守护"))
                end
            end
        end
    end
end

-------------------右边逻辑
--点击魂石弹出tips
function ShouhuMainTabFirst:OnClickWakeUpStone(quality)
    local tempStr = ""
    if quality == 1 then
        tempStr = TI18N("蓝")
    elseif quality == 2 then
        tempStr = TI18N("紫")
    elseif quality == 3 then
        tempStr = TI18N("橙")
    end
    local args = {base_id = self.parent.model.my_sh_selected_data.base_id, quality = quality, pointIndex = 0, title = string.format(TI18N("%s色魂石已激活"), tempStr)}
    self.parent.model:OpenWakeupPointTips(args)
end


--设置我的守护右边的信息内容
function ShouhuMainTabFirst:update_content(dat)
    if self.init_go == false then
        return
    end

    -- 守护信息
    self.parent.model.my_sh_selected_data = dat
    --BaseUtils.dump(self.parent.model.my_sh_selected_data,"守护装备列表===============================================")
    self.BtnOneKey.gameObject:SetActive(false)


    ---------------------- 技能
    if self.rightSkillList ==nil then
        self.rightSkillList = {}
    end

    for i=1,#self.rightSkillList do
        local skillItem = self.rightSkillList[i]
        skillItem.gameObject:SetActive(false)
    end

    if dat.actSkillDic  == nil then
        dat.actSkillDic = self.parent.model:get_skill_data_dic_by_base_id(dat.base_id)
    end
    if dat.has_get_skill_list == nil and dat.war_id == nil then
        --未招募
        for j=1, #dat.actSkillDic do
            local temp_data = dat.actSkillDic[j]
            if temp_data.skill_id == skillId then
                temp_data.hasGet = true
            end
        end
    else
        --已招募的
        for i=1, #dat.has_get_skill_list do--设置那些已经激活
            local skillId = dat.has_get_skill_list[i]
            for j=1, #dat.actSkillDic do
                local temp_data = dat.actSkillDic[j]
                if temp_data.skill_id == skillId then
                    temp_data.hasGet = true
                end
            end
        end
    end

    table.sort( dat.actSkillDic, function(a, b)
        return a[2] < b[2]
    end)

    local index = 1
    for i=1, #dat.actSkillDic do
        local skillItem = self.rightSkillList[index]
        local temp = dat.actSkillDic[index]
        if temp.hasGet == nil then
            temp.hasGet = false
        end
        if skillItem == nil then
            skillItem = SkillSlot.New()
            self.rightSkillList[index] = skillItem
            UIUtils.AddUIChild(self.skillItem_list[index], skillItem.gameObject)
        end
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", temp[1])]
        skillItem:SetAll(Skilltype.shouhuskill,{id = skillData.id, icon = skillData.icon, lev = temp[2]})
        skillItem.gameObject:SetActive(true)

        if RoleManager.Instance.RoleData.lev < temp[2] then
            BaseUtils.SetGrey(skillItem.skillImg, true)
        else
            BaseUtils.SetGrey(skillItem.skillImg, false)
        end
        index = index + 1
    end

    local wakeUpSkillList = self.parent.model:get_wakeup_skills(dat.base_id)
    for i = 1, #wakeUpSkillList do
        local wakeUpData = wakeUpSkillList[i]
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", wakeUpData[1])]
        local skillItem = self.rightSkillList[index]
        if skillItem == nil then
            skillItem = SkillSlot.New()
            self.rightSkillList[index] = skillItem
            UIUtils.AddUIChild(self.skillItem_list[index], skillItem.gameObject)
        end
        skillItem:SetAll(Skilltype.shouhuskill, {id = skillData.id, icon = skillData.icon, quality = wakeUpData[2]})
        skillItem.gameObject:SetActive(true)
        index = index + 1

        if dat.quality >= wakeUpData[2] then
            BaseUtils.SetGrey(skillItem.skillImg, false)
        else
            BaseUtils.SetGrey(skillItem.skillImg, true)
        end
    end

    ---------按钮显示逻辑
    self.BtnFight.gameObject:SetActive(false)
    self.BtnRecruit.gameObject:SetActive(false)
    self.BtnCancel.gameObject:SetActive(false)
    self.BtnQuickBuy.gameObject:SetActive(false)
    if self.parent.model.my_sh_selected_data.war_id == nil then
        --未招募
        self.BtnRecruit.gameObject:SetActive(true)

        local loss_data = self.parent.model.my_sh_selected_data.loss[1]
        local loss_item_num_str = ""
        local has_num = 0
        if loss_data.label == "item_base_id_auto_buy" then
            self.parent.model.my_sh_selected_data.lossItemId = loss_data.val[1][1]
            self.parent.model.my_sh_selected_data.lossItemNum = loss_data.val[1][2]
            has_num = BackpackManager.Instance:GetItemCount(self.parent.model.my_sh_selected_data.lossItemId)
            if has_num >= self.parent.model.my_sh_selected_data.lossItemNum then
                loss_item_num_str = tostring(self.parent.model.my_sh_selected_data.lossItemNum)
            else
                loss_item_num_str = string.format("<color='#f58140'>%s</color>/%s", has_num,self.parent.model.my_sh_selected_data.lossItemNum)
            end
            --不够钱招募
            self.effect_recruit:SetActive(false)

            if self.parent.model.my_sh_selected_data.recruit_lev > RoleManager.Instance.RoleData.lev then
                self.BtnQuickBuy.gameObject:SetActive(false)
                self.BtnRecruit.gameObject:SetActive(true)
            else
                self.BtnQuickBuy.gameObject:SetActive(true)
                self.BtnRecruit.gameObject:SetActive(false)
            end

            local buy_list = {[self.parent.model.my_sh_selected_data.lossItemId] = {need = self.parent.model.my_sh_selected_data.lossItemNum}}
            self.BtnRecruitBuy:Layout(buy_list, self.OnRecruitFunc, self.OnPriceBack)
        elseif loss_data.label == "coin" then
            self.parent.model.my_sh_selected_data.lossItemId = 90000
            self.parent.model.my_sh_selected_data.lossItemNum = loss_data.val[1]
            has_num = RoleManager.Instance.RoleData.coin

            if has_num >= self.parent.model.my_sh_selected_data.lossItemNum then
                loss_item_num_str = tostring(self.parent.model.my_sh_selected_data.lossItemNum)
            else
                loss_item_num_str = string.format("<color='#f58140'>%s</color>", self.parent.model.my_sh_selected_data.lossItemNum)
            end
            --够钱招募
            self.effect_recruit:SetActive(false)
            self.effect_recruit:SetActive(true)

            self.BtnQuickBuy.gameObject:SetActive(false)
            self.BtnRecruit.gameObject:SetActive(true)
        end

        local slotData= DataItem.data_get[self.parent.model.my_sh_selected_data.lossItemId]
        self.BtnQuickBuyVal.text = loss_item_num_str
        if self.imgLoader == nil then
            local go = self.BtnQuickBuyIcon.gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, slotData.icon)

        local newX = self.BtnQuickBuyIcon:GetComponent(RectTransform).sizeDelta.x/2
        self.BtnQuickBuyVal.transform:GetComponent(RectTransform).anchoredPosition = Vector2(newX, -12.4)
        local iconX = - newX - (self.BtnQuickBuyVal.preferredWidth/2 - newX)
        iconX = iconX > 0 and 0-iconX or iconX
        self.BtnQuickBuyIcon:GetComponent(RectTransform).anchoredPosition = Vector2(iconX, -8.8)

        if self.imgLoader2 == nil then
            local go = self.BtnRecruit.transform:FindChild("ImgIcon").gameObject
            self.imgLoader2 = SingleIconLoader.New(go)
        end
        self.imgLoader2:SetSprite(SingleIconType.Item, slotData.icon)

        self.txtBtnRecruit.text = loss_item_num_str
        self.txtTextLock.gameObject:SetActive(false)
        self.txtBtnRecruitName.gameObject:SetActive(false)
        self.txtBtnRecruit.gameObject:SetActive(false)
        self.recruitImgIcon.gameObject:SetActive(false)
        if self.parent.model.my_sh_selected_data.war_id == nil then
            if self.parent.model.my_sh_selected_data.recruit_lev <= RoleManager.Instance.RoleData.lev then
                self.txtBtnRecruitName.gameObject:SetActive(true)
                self.txtBtnRecruit.gameObject:SetActive(true)
                self.recruitImgIcon.gameObject:SetActive(true)
                self.txtBtnRecruitName.text = TI18N("招募")
            else
                self.txtTextLock.gameObject:SetActive(true)
                self.txtTextLock.text = string.format("<color='%s'>%s%s</color>%s", ColorHelper.color[5], self.parent.model.my_sh_selected_data.recruit_lev, TI18N("级"), TI18N("解锁"))

                self.effect_recruit:SetActive(false)
            end
        end

    elseif self.parent.model.my_sh_selected_data.war_id ~= 0 then --上阵

        self.BtnFight.gameObject:SetActive(true)
        --没有助战
        self.txtBtnFight.text = TI18N("休息")
    else
    --没有上阵
        if self.parent.model.my_sh_selected_data.guard_fight_state == self.parent.model.guard_fight_state.field then --出战
            self.BtnFight.gameObject:SetActive(false)
            self.BtnCancel.gameObject:SetActive(true)
        else
            self.BtnFight.gameObject:SetActive(true)
            --没有助战
            self.txtBtnFight.text = TI18N("上阵")
        end
    end


    local curWakeUpQuality = self.parent.model.my_sh_selected_data.quality

    local curMaxShowNum = curWakeUpQuality;
    if curMaxShowNum > 4 then
        curMaxShowNum = 4
    end
    if self.parent.model.my_sh_selected_data.war_id ~= nil then
        --已招募
        for i=1,#self.WakeUpIconList do
            self.WakeUpIconList[i]:SetActive(false)
        end
        self.WakeUpCon.gameObject:SetActive(true) --self.parent.model.wakeUpDataSocketDic[self.parent.model.my_sh_selected_data.base_id].quality
        local baseQuality = DataShouhu.data_guard_base_cfg[self.parent.model.my_sh_selected_data.base_id].quality
        if curMaxShowNum > baseQuality then
            local index = curMaxShowNum - 1
            for i=baseQuality, index do
                self.WakeUpIconList[i]:SetActive(true)
            end
        end
        local curPosition = self.WakeUpCon:GetComponent(RectTransform).anchoredPosition
        self.WakeUpCon:GetComponent(RectTransform).anchoredPosition = Vector2(curPosition.x, 6 + (baseQuality-1)*51)

        self.TxtScore.text = string.format("%s%s",TI18N("评分:"), self.parent.model:get_score(dat)) --评分
        self.TxtGrowth.text = string.format("%s%s",TI18N("成长:"), self.parent.model:get_growth(dat)) --成长

        self.ImgGrowthBg.transform:FindChild("ImgWakeUp"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", curWakeUpQuality))
        self.TopCon.transform:FindChild("GiftTips"):FindChild("Tips"):FindChild("ImgCur"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", curWakeUpQuality))
        self.TxtGrowthCur.text = tostring(self.parent.model:get_unrecruit_growth(dat))
    else
        self.WakeUpCon.gameObject:SetActive(false)
        self.TxtScore.text = string.format("%s%s",TI18N("评分:"), self.parent.model:get_unrecruit_score(dat)) --评分
        self.TxtGrowth.text = string.format("%s%s",TI18N("成长:"), self.parent.model:get_unrecruit_growth(dat)) --成长

        self.ImgGrowthBg.transform:FindChild("ImgWakeUp"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", curWakeUpQuality))
        self.TopCon.transform:FindChild("GiftTips"):FindChild("Tips"):FindChild("ImgCur"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", curWakeUpQuality))
        self.TxtGrowthCur.text = tostring(self.parent.model:get_unrecruit_growth(dat))
    end
    ------更新模型
    self:update_sh_model(dat)

    -------------------------装备逻辑
    self:update_sh_equip()


    --------------------------属性逻辑
    self.LayoutCon_rect.anchoredPosition = Vector2(0, 0)

    if dat.sh_attrs_list ~= nil then
        local allAttrDic = {}
        if dat.war_id ~= nil then
            allAttrDic[1] = {1,dat.sh_attrs_list.hp_max, "AttrIcon1"} --生命上限
            allAttrDic[2] = {2,dat.sh_attrs_list.mp_max, "AttrIcon2"} --魔法上限
            allAttrDic[53] = {53,dat.sh_attrs_list.atk_speed, "AttrIcon3"} --攻击速度
            allAttrDic[4] = {4,dat.sh_attrs_list.phy_dmg, "AttrIcon4"} --物攻
            allAttrDic[5] = {5,dat.sh_attrs_list.magic_dmg, "AttrIcon5"} --魔攻
            allAttrDic[6] = {6,dat.sh_attrs_list.phy_def, "AttrIcon6"} --物防
            allAttrDic[7] = {7,dat.sh_attrs_list.magic_def, "AttrIcon7"} --魔防
            allAttrDic[43] = {43,dat.sh_attrs_list.heal_val, "AttrIcon1"} --魔防
        else
            allAttrDic[1] = {1,0, "AttrIcon1"}
            allAttrDic[2] = {2,0, "AttrIcon2"}
            allAttrDic[53] = {53,0, "AttrIcon3"}
            allAttrDic[4] = {4,0, "AttrIcon4"}
            allAttrDic[5] = {5,0, "AttrIcon5"}
            allAttrDic[6] = {6,0, "AttrIcon6"}
            allAttrDic[7] = {7,0, "AttrIcon7"}
            allAttrDic[43] = {43,0, "AttrIcon1"} --魔防

            for i=1, #dat.sh_attrs_list do
                local aDat = dat.sh_attrs_list[i]
                if allAttrDic[aDat.attr] ~= nil then
                    allAttrDic[aDat.attr][2] = allAttrDic[aDat.attr][2]+ aDat.val
                else
                    allAttrDic[aDat.attr] = {aDat.attr, aDat.val}
                end
            end
        end

        local temp_list = {}
        table.insert(temp_list, allAttrDic[1])
        table.insert(temp_list, allAttrDic[43])
        table.insert(temp_list, allAttrDic[2])
        table.insert(temp_list, allAttrDic[53])
        table.insert(temp_list, allAttrDic[4])
        table.insert(temp_list, allAttrDic[5])
        table.insert(temp_list, allAttrDic[6])
        table.insert(temp_list, allAttrDic[7])
        local index = 1
        for i=1,#temp_list do
            local v = temp_list[i]
            self.propNameList[index].text = KvData.attr_name[v[1]]
            self.propIconList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon,v[3])
            self.propTxtList[index].text = tostring(v[2])
            self.propNameList[index].gameObject:SetActive(true)
            self.propIconList[index].gameObject:SetActive(true)
            self.propTxtList[index].gameObject:SetActive(true)
            self.propTxtBgList[index].gameObject:SetActive(true)
            index = index + 1
        end
    end

    -- 详细信息
    TipsManager.Instance:HideGuide()
    if ShouhuManager.Instance.needGuide then
        if ShouhuManager.Instance:HasEmpty() then
            -- 有空位，直接引导阿瑞斯上阵
            if dat.base_id == 1020 then
                if not BaseUtils.is_null(self.guideEffect) then
                    self.guideEffect:SetActive(true)
                    TipsManager.Instance:ShowGuide({gameObject = self.BtnRecruit.gameObject, data = TI18N("点击使<color='#00ff00'>阿瑞斯</color>上阵"), forward = TipsEumn.Forward.Left})
                end
            end
        else
            -- 没空位，先引导菲亚下阵
            if dat.base_id == 1002 then
                if not BaseUtils.is_null(self.guideEffect) then
                    self.guideEffect:SetActive(true)
                    TipsManager.Instance:ShowGuide({gameObject = self.BtnRecruit.gameObject, data = TI18N("点击使<color='#00ff00'>菲雅</color>下阵"), forward = TipsEumn.Forward.Left})
                end
            end
        end
    else
        if ShouhuManager.Instance:Checkaien() and dat.base_id == 1018 then
            if not BaseUtils.is_null(self.guideEffect) then
                self.guideEffect:SetActive(true)
                TipsManager.Instance:ShowGuide({gameObject = self.BtnRecruit.gameObject, data = TI18N("<color='#ffff00'>招募凯恩</color>成为守护吧"), forward = TipsEumn.Forward.Left})
            end
        end
    end
end

--更新选中的守护的装备
function ShouhuMainTabFirst:update_sh_equip()
    local is_show_tanhao = false
    local dat = self.parent.model.my_sh_selected_data
    for i=1, #self.parent.model.my_sh_list do
        if self.parent.model.my_sh_list[i].base_id == dat.base_id then
            dat = self.parent.model.my_sh_list[i]
            self.parent.model.my_sh_selected_data = dat
            break
        end
    end
    if dat.equip_list ~= nil and #dat.equip_list > 0 then
        for i=1, #dat.equip_list do-- 装备
            local d = dat.equip_list[i]
            local equip = self.equipList[i]
            equip:set_equip_my_sh_data(dat)
            equip:set_sh_equip_item_data(d)
            if d.lev <= RoleManager.Instance.world_lev - 5 then
                is_show_tanhao = true
            end
        end
    else
        for i=1, #self.equipList do-- 装备
            local equip = self.equipList[i]
            equip:set_equip_my_sh_data(nil)
            equip:set_sh_equip_item_data(nil)
        end
    end

    if self.parent.model.my_sh_selected_data.war_id ~= nil  then
        if self.parent.model:check_shouhu_equip_can_lev_up(dat) then
            self.BtnOneKey.gameObject:SetActive(true)
        end
    else
        self.BtnOneKey.gameObject:SetActive(false)
    end
    if dat.war_id == nil then
        is_show_tanhao = false
    end
    self.BtnTanHao.gameObject:SetActive(is_show_tanhao)
end

-------------------------------------模型逻辑
--更新守护模型
function ShouhuMainTabFirst:update_sh_model(shdata)
    local res_id = shdata.res_id
    local animation_id = shdata.animation_id
    local paste_id = shdata.paste_id
    local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", shdata.base_id, shdata.quality)]
    if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
        res_id = wakeUpCfgData.model
        paste_id = wakeUpCfgData.skin
        animation_id = wakeUpCfgData.animation
    end
    if self.last_model_data ~= nil then
        local last_res_id = self.last_model_data.res_id
        local last_animation_id = self.last_model_data.animation_id
        local last_paste_id = self.last_model_data.paste_id
        local lastWakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.last_model_data.base_id, self.last_model_data.quality)]
        if lastWakeUpCfgData ~= nil and lastWakeUpCfgData.model ~= 0 then
            last_res_id = lastWakeUpCfgData.model
            last_paste_id = lastWakeUpCfgData.skin
            last_animation_id = lastWakeUpCfgData.animation
        end
        if self.last_model_data.base_id == shdata.base_id and last_res_id == res_id and last_animation_id == animation_id and last_paste_id == paste_id then
            if self.previewComp1 ~= nil and self.previewComp1.tpose ~= nil then
                local cfg_data = DataAnimation.data_npc_data[animation_id]
                self.animator = self.previewComp1.tpose:GetComponent(Animator)
                local state = string.format("Stand%s", cfg_data.stand_id)
                self.animator:Play(state)
            end
            return
        end
    end
    self.last_model_data = shdata
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "Shouhu"
        ,orthographicSize = 0.75
        ,width = 341
        ,height = 341
        ,offsetY = -0.425
    }
    local modelData = {type = PreViewType.Shouhu, skinId = paste_id, modelId = res_id, animationId = animation_id, scale = 1}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function ShouhuMainTabFirst:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end