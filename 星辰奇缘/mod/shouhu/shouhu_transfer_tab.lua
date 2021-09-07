-- @author ###
-- @date 2018年4月17日,星期二

ShouhuTransferTab = ShouhuTransferTab or BaseClass(BasePanel)

function ShouhuTransferTab:__init(parent)
    self.parent = parent
    self.name = "ShouhuTransferTab"

    self.model = ShouhuManager.Instance.model

    self.resList = {
        {file = AssetConfig.shouhu_transfer_panel, type = AssetType.Main}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
        ,{file = AssetConfig.shouhu_Normal_bg, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = AssetConfig.guard_head, type = AssetType.Dep}
        ,{file = AssetConfig.worldlevgiftitem1, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateRightListener = function()
        if self.parent.last_selected_item.data ~= nil then
            self:UpdateContent(self.parent.last_selected_item.data)
        end
    end

    self._OnGemsLevelUpdate = function()
        print("_OnGemsLevelUpdate")
        self:OnGemsLevelUpdate()
    end

    self._OnAddPriceEvent = function(val)
        self.AddPrice = val
        self:OnAddPriceEvent(val)
    end

    self.has_recruit_enabled_list = { }    --已招募列表

    self.previewComp = nil
    self.reload = false   --是否加载界面完成

    self.IsSelectAnother = false  --是否选中另一个守护
    self.currentShouhu = nil    --选中的左边的守护
    self.anotherShouhu = nil    --选中的另一名守护

    self.IsMatch = 3       --左边守护是否满足条件(0(初始状态) 1 2 3 )

    self.sureTransfer = false  --即将转换标志

    self.AddPrice = 0      --转换增加的差价

    self.iconNum = 0
end

function ShouhuTransferTab:__delete()
    self.OnHideEvent:Fire()

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.AddeffTimerId ~= nil then
        LuaTimer.Delete(self.AddeffTimerId)
        self.AddeffTimerId = nil
    end

    if self.TransferLuatimer ~= nil then
        LuaTimer.Delete(self.TransferLuatimer)
        self.TransferLuatimer = nil
    end

    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    if self.LeftEffect ~= nil then
        self.LeftEffect:DeleteMe()
        self.LeftEffect = nil
    end

    if self.RightEffect ~= nil then
        self.RightEffect:DeleteMe()
        self.RightEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShouhuTransferTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_transfer_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.openCon = t:Find("Main/OpenCon")

    self.leftCon = self.openCon:Find("LeftCon")
    self.rightCon = self.openCon:Find("RightCon")
    self.middleCon = self.openCon:Find("MiddleCon")

    self.leftConImg = self.leftCon:GetComponent(Image)
    self.leftConImg.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_Normal_bg,"NormalBg")
    self.rightConImg = self.rightCon:GetComponent(Image)
    self.rightConImg.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_Normal_bg,"NormalBg")

    self.bottomBg = self.leftCon:Find("BottomBg"):GetComponent(Image)
    self.bottomBg.sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg,"WingsBookBg")

    self.leftTitle = self.leftCon:Find("TitleBg/I18N"):GetComponent(Text)

    self.rightTitleBg = self.rightCon:Find("TitleBg")

    self.rightTitle = self.rightCon:Find("TitleBg/I18N"):GetComponent(Text)

    self.ShouhuPreview = t:Find("Main/OpenCon/LeftCon/ShouHuPreview")

    self.ShouhuLeftAttr = self.leftCon:Find("Attr")
    self.ShouhuRightAttr = self.rightCon:Find("Attr")


    self.leftGrownNum = self.leftCon:Find("Attr/GrownNum"):GetComponent(Text)
    self.leftGrownIcon = self.leftCon:Find("Attr/GrownNum/Image"):GetComponent(Image)
    self.leftGemstoneNum = self.leftCon:Find("Attr/GemstoneNum"):GetComponent(Text)
    self.leftImproperNotice = self.leftCon:Find("ImproperNotice"):GetComponent(Text)
    self.leftImproperNotice.gameObject:SetActive(false)

    self.rightGrownNum = self.rightCon:Find("Attr/GrownNum"):GetComponent(Text)
    self.rightGrownIcon = self.rightCon:Find("Attr/GrownNum/Image"):GetComponent(Image)
    self.rightGemstoneNum = self.rightCon:Find("Attr/GemstoneNum"):GetComponent(Text)

    self.NoselectNotice = self.rightCon:Find("NoselectNotice")
    self.NoselectNotice.gameObject:SetActive(false)

    self.ShouHuBg = self.rightCon:Find("ShouHuBg"):GetComponent(Image)
    self.ShouHuBg.sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1, "worldlevitemlight1")

    self.ShouhuHeadIcon = self.rightCon:Find("ShouhuImg/Head/Item"):GetComponent(Image)
    self.ShouhuHeadIcon.gameObject:SetActive(false)

    self.ShouhuAddIcon = self.rightCon:Find("ShouhuImg/Head/Add")
    self.ShouhuAddIcon.gameObject:SetActive(false)

    self.ShouhuHeadButton = self.rightCon:Find("ShouhuImg/Head"):GetComponent(Button)
    self.ShouhuHeadButton.onClick:AddListener(function() self:OpenShouhuList() end)

    self.ShouhuHeadtransfer = self.rightCon:Find("ShouhuImg/Head/Transfer")
    self.ShouhuHeadtransferBtn = self.rightCon:Find("ShouhuImg/Head/Transfer"):GetComponent(Button)
    self.ShouhuHeadtransferBtn.onClick:AddListener(function() self:OpenShouhuList() end)

    self.NoSelectBtn = self.middleCon:Find("NoSelectMiddleButton"):GetComponent(Button)
    self.NoSelectBtn.onClick:AddListener(function() self:SetMiddleBtnStatus() end)
    self.NoSelectBtn.gameObject:SetActive(true)

    self.SelectBtn = self.middleCon:Find("SelectMiddleButton"):GetComponent(Button)
    self.SelectBtn.onClick:AddListener(function() self:SetMiddleBtnStatus() end)
    self.SelectBtn.gameObject:SetActive(false)

    self.SelectCost = self.middleCon:Find("SelectMiddleButton/Num"):GetComponent(Text)

    self.SelectCost.alignment = 5
    self.SelectCost.transform.anchoredPosition = Vector2(-15, 7.9)
    self.SelectCost.transform.sizeDelta = Vector2(55, 19.8)

    self.NoticeBtn = t:Find("Main/OpenCon/NoticeButton"):GetComponent(Button)
    self.NoticeText = t:Find("Main/OpenCon/Text"):GetComponent(Text)
    self.NoticeText.text = TI18N("1、<color='#ffff00'>橙色以上</color>守护的品阶、装备和刻印可<color='#ffff00'>转换继承</color>\n2、转换后宝石等级将<color='#ffff00'>按照差价折算</color>成为对应等级")
    self.reload = true
    if self.parent.last_selected_item ~= nil then
        self:UpdateContent(self.parent.last_selected_item.data)
    end

end

function ShouhuTransferTab:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShouhuTransferTab:OnOpen()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateRightListener)
    ShouhuManager.Instance.OnGemsLevelUpdate:AddListener(self._OnGemsLevelUpdate)
    ShouhuManager.Instance.OnAddPriceEvent:AddListener(self._OnAddPriceEvent)

    self.reload = true
    self.sureTransfer = false

end

function ShouhuTransferTab:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateRightListener)
    ShouhuManager.Instance.OnGemsLevelUpdate:RemoveListener(self._OnGemsLevelUpdate)
    ShouhuManager.Instance.OnAddPriceEvent:RemoveListener(self._OnAddPriceEvent)

    self.model.selectedTransferAnotherSH = {}

    if self.TransferLuatimer ~= nil then
        LuaTimer.Delete(self.TransferLuatimer)
        self.TransferLuatimer = nil
    end

    -- if self.sureTransfer == true then
    --     if self.currentShouhu ~= nil and self.anotherShouhu ~= nil then
    --         ShouhuManager.Instance:Send10920(self.currentShouhu.base_id, self.anotherShouhu.base_id)
    --     end
    -- end

    if self.AddeffTimerId ~= nil then
        LuaTimer.Delete(self.AddeffTimerId)
        self.AddeffTimerId = nil
    end

    if self.TransferLuatimer_two ~= nil then
        LuaTimer.Delete(self.TransferLuatimer_two)
        self.TransferLuatimer_two = nil
    end


    if self.openEffect ~= nil then
        self.openEffect:SetActive(false)
    end

    if self.LeftEffect ~= nil then
        self.LeftEffect:SetActive(false)
    end

    if self.RightEffect ~= nil then
        self.RightEffect:SetActive(false)
    end
end

--点击左边守护按钮
function ShouhuTransferTab:UpdateContent(shData)
    if self.reload == false then return end

    if shData.war_id == nil then
        return
    end
    self.currentShouhu = shData
    self.model.my_sh_selected_data = shData

    self.has_recruit_enabled_list = {}
    for i = 1, #self.model.my_sh_list do
        if self.model.my_sh_list[i].base_id ~= self.currentShouhu.base_id then
            table.insert(self.has_recruit_enabled_list, self.model.my_sh_list[i])
        end
    end

    -- local function sortfun(a,b)
    --     return (a.quality >= 3 and self.model:CheckAllGemsBiggerOne(a)) and (b.quality >= 3 and self.model:CheckAllGemsBiggerOne(b)) or (a.quality >= 3 and self.model:CheckAllGemsBiggerOne(a) == false) or (a.quality < 3 and self.model:CheckAllGemsBiggerOne(a)) or (a.quality < 3 and self.model:CheckAllGemsBiggerOne(a) == false)
    -- end
    -- table.sort(self.has_recruit_enabled_list, sortfun)

    local fun = function(a,b)
        if (a.quality >= 4 and self.model:CheckAllGemsBiggerOne(a)) and (b.quality >= 4 and self.model:CheckAllGemsBiggerOne(b)) then
            return a.score > b.score
        elseif a.quality == b.quality then
            return self.model:GetTotalGemsLevel(a) > self.model:GetTotalGemsLevel(b)
        elseif a.quality ~= b.quality then
            return a.quality > b.quality
        end
    end
    table.sort(self.has_recruit_enabled_list, fun)



    self.leftTitle.text = ColorHelper.color_item_name(self.currentShouhu.quality , self.currentShouhu.alias)

    if self.model:CheckIsPurpleShouhu(self.currentShouhu) then
        if self.model:CheckAllGemsBiggerOne(self.currentShouhu) then
            self.ShouhuLeftAttr.gameObject:SetActive(true)
            self.leftImproperNotice.gameObject:SetActive(false)
            self.IsMatch = 3
            self.leftGrownNum.text = string.format("%s", self.model:get_growth(self.currentShouhu))
            self.leftGemstoneNum.text = string.format("总计%s级", self.model:GetTotalGemsLevel(self.currentShouhu))

            --BaseUtils.dump(self.has_recruit_list,"self.has_recruit_list:")
            local curWakeUpQuality = self.model.my_sh_selected_data.quality
            self.leftGrownIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", curWakeUpQuality))
        else
            --宝石需大于1
            self.IsMatch = 1
            self.ShouhuLeftAttr.gameObject:SetActive(false)
            self.leftImproperNotice.gameObject:SetActive(true)
            self.leftImproperNotice.text = TI18N("<color='#ffff00'>所有宝石≥1级才可转换</color>")
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>装备所有宝石</color>再来转换吧{face_1,3}"), self.currentShouhu.name))
        end
    else
        --品阶需大于紫色
        self.IsMatch = 2
        self.ShouhuLeftAttr.gameObject:SetActive(false)
        self.leftImproperNotice.gameObject:SetActive(true)
        self.leftImproperNotice.text = TI18N("<color='#ffff00'>品阶≥橙色才可转换</color>")
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>品阶不足橙色</color>，不能转换哟{face_1,2}"), self.currentShouhu.name))
    end

    self:UpdateShouhuModel(self.currentShouhu)  --更新守护模型
    self:SetAnotherData()     --更新缓存的要交换的守护

end


function ShouhuTransferTab:UpdateShouhuModel(shdata)
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
            if self.previewComp ~= nil and self.previewComp.tpose ~= nil then
                local cfg_data = DataAnimation.data_npc_data[animation_id]
                self.animator = self.previewComp.tpose:GetComponent(Animator)
                local state = string.format("Stand%s", cfg_data.stand_id)
                self.animator:Play(state)
            end
            return
        end
    end
    self.last_model_data = shdata

    local callback = function(composite)
        self:BuildCompleted(composite)
    end
    local setting = {
        name = "Shouhu"
        ,orthographicSize = 0.75
        ,width = 341
        ,height = 341
        ,offsetY = -0.425
    }
    local modelData = {type = PreViewType.Shouhu, skinId = paste_id, modelId = res_id, animationId = animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        --self.OnHideEvent:AddListener(function() self.previewComp:Hide() end)
        --self.OnOpenEvent:AddListener(function() self.previewComp:Show() end)
    else
        self.previewComp:Reload(modelData, callback)
    end
end

--守护模型加载完成
function ShouhuTransferTab:BuildCompleted(composite)
    local rawImage = composite.rawImage

    rawImage.transform:SetParent(self.ShouhuPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

function ShouhuTransferTab:SetMiddleBtnStatus()
    if self.IsMatch == 3 then
        if self.sureTransfer then return end --（点击确定后，未发协议前不可再点）
        if self.anotherShouhu ~= nil then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否确认消耗<color='#00ff00'>%s</color>{assets_2,%s},将守护<color='#00ff00'>%s</color>与守护<color='#00ff00'>%s</color>的培养进度相互转换？"),self.iconNum + self.AddPrice,90003, self.currentShouhu.name, self.anotherShouhu.name)
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function ()
                if self.anotherShouhu == nil then NoticeManager.Instance:FloatTipsByString("请选择需要转换的守护") return end --(协议未收到前可能会出现确认窗)
                --发送守护转换协议（协议返回后将model中的对应表中删除操作的两个守护）
                self.sureTransfer = true
                if self.openEffect == nil then
                   self.openEffect = BaseUtils.ShowEffect(20480, self.openCon, Vector3(1,1,1), Vector3(0,32,-400))
                end
                self.openEffect:SetActive(false)
                self.openEffect:SetActive(true)

                self.TransferLuatimer = LuaTimer.Add(2000,function()
                        self.openEffect:SetActive(false)
                        self.sureTransfer = false
                        ShouhuManager.Instance:Send10920(self.currentShouhu.base_id, self.anotherShouhu.base_id)
                    end)
                self.TransferLuatimer_two = LuaTimer.Add(2500,function()
                        if self.LeftEffect == nil then
                           self.LeftEffect = BaseUtils.ShowEffect(20260, self.leftCon, Vector3(0.62,1,1), Vector3(0,-18,-400))
                        end
                        self.LeftEffect:SetActive(false)
                        self.LeftEffect:SetActive(true)

                        if self.RightEffect == nil then
                           self.RightEffect = BaseUtils.ShowEffect(20260, self.rightCon, Vector3(0.62,1,1), Vector3(0,-18,-400))
                        end
                        self.RightEffect:SetActive(false)
                        self.RightEffect:SetActive(true)
                    end)
                --ShouhuManager.Instance:Send10920(self.currentShouhu.base_id, self.anotherShouhu.base_id)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            NoticeManager.Instance:FloatTipsByString("请选择需要转换的守护")
            self:OpenShouhuList()
            return
        end
    else
        if self.IsMatch == 2 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>品阶不足橙色</color>，不能转换哟{face_1,2}"), self.currentShouhu.name))
        elseif self.IsMatch == 1 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>装备所有宝石</color>再来转换吧{face_1,3}"), self.currentShouhu.name))
        end
    end
end

--设置右边守护的数据
function ShouhuTransferTab:SetAnotherData()
    --self.anotherShouhu = shData
    self.anotherShouhu = self.model.selectedTransferAnotherSH[self.currentShouhu.base_id]
    if self.anotherShouhu ~= nil then
        --右侧守护有数据
        local shData = self.anotherShouhu
        local resId = tostring(shData.avatar_id)
        self.ShouhuHeadIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, resId)
        self.ShouhuHeadIcon.gameObject:SetActive(true)
        self.rightTitle.text = ColorHelper.color_item_name(shData.quality , shData.alias)
        self.rightGrownNum.text = string.format("%s", self.model:get_growth(shData))
        self.rightGemstoneNum.text = string.format("总计%s级", self.model:GetTotalGemsLevel(shData))
        self.rightGrownIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", shData.quality))

        self.SelectBtn.gameObject:SetActive(true)
        self.NoSelectBtn.gameObject:SetActive(false)
        self.iconNum = self:CalcuNeedCoins(self.currentShouhu.quality, self.anotherShouhu.quality)
        --self.SelectCost.text = self.iconNum

        self.NoselectNotice.gameObject:SetActive(false)
        self.ShouhuRightAttr.gameObject:SetActive(true)
        self.rightTitleBg.gameObject:SetActive(true)
        self.ShouhuHeadtransfer.gameObject:SetActive(true)
        self.ShouhuAddIcon.gameObject:SetActive(false)
        self.ShouhuHeadIcon.gameObject:SetActive(true)
        if self.AddeffTimerId ~= nil then
            LuaTimer.Delete(self.AddeffTimerId)
            self.AddeffTimerId = nil
        end
    else
        self.ShouhuAddIcon.gameObject:SetActive(true)
        if self.AddeffTimerId ~= nil then
            LuaTimer.Delete(self.AddeffTimerId)
            self.AddeffTimerId = nil
        end
        self.AddeffTimerId = LuaTimer.Add(1000, 3000, function()
            self.ShouhuAddIcon.gameObject.transform.localScale = Vector3(1.3,1.3,1)
            Tween.Instance:Scale(self.ShouhuAddIcon.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)

        self.NoselectNotice.gameObject:SetActive(true)
        self.SelectBtn.gameObject:SetActive(false)
        self.NoSelectBtn.gameObject:SetActive(true)


        self.ShouhuRightAttr.gameObject:SetActive(false)
        self.rightTitleBg.gameObject:SetActive(false)
        self.ShouhuHeadIcon.gameObject:SetActive(false)
        self.ShouhuHeadtransfer.gameObject:SetActive(false)
    end
end


function ShouhuTransferTab:OpenShouhuList()

    if self.IsMatch == 2 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>品阶不足橙色</color>，不能转换哟{face_1,2}"), self.currentShouhu.name))
        return
    elseif self.IsMatch == 1 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>装备所有宝石</color>再来转换吧{face_1,3}"), self.currentShouhu.name))
        return
    end

    if self.ShouhuListPanel == nil then
        self.ShouhuListPanel = ShouhuTransferListPanel.New(self.model, self.transform, self)
    end
    self.ShouhuListPanel:Show()
end


function ShouhuTransferTab:CloseShouhuList()
    if self.ShouhuListPanel ~= nil then
        self.ShouhuListPanel:DeleteMe()
    end
    self.ShouhuListPanel = nil
end

function ShouhuTransferTab:CalcuNeedCoins(level1,level2)
    local level = level1
    if level2 > level then
        level = level2
    end

    if level == 3 then
        return 30000
    elseif level == 4 then
        return 50000
    elseif level == 5 then
        return 80000
    end
end

function ShouhuTransferTab:OnGemsLevelUpdate()
    if self.currentShouhu ~= nil and self.leftGemstoneNum ~= nil then
        self.leftGemstoneNum.text = string.format("总计%s级", self.model:GetTotalGemsLevel(self.currentShouhu))
    end
    if self.anotherShouhu ~= nil and self.rightGemstoneNum ~= nil then
        self.rightGemstoneNum.text = string.format("总计%s级", self.model:GetTotalGemsLevel(self.anotherShouhu))
    end
end

function ShouhuTransferTab:OnAddPriceEvent(val)
    local AddpriceNum = val
    if self.iconNum ~= nil and self.SelectCost ~= nil then
        self.iconNum = self:CalcuNeedCoins(self.currentShouhu.quality, self.anotherShouhu.quality)
        self.SelectCost.text = self.iconNum + AddpriceNum
    end
end
