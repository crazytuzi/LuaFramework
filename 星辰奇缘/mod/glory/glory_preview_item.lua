-- @author 黄耀聪
-- @date 2016年7月21日

GloryPreviewItem = GloryPreviewItem or BaseClass()

function GloryPreviewItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.mgr = GloryManager.Instance
    self.assetWrapper = assetWrapper

    local t = self.transform
    self.firstKillName = t:Find("FirstKill"):GetComponent(Text)
    self.bestKillName = t:Find("BestKill"):GetComponent(Text)
    self.shouhuText = t:Find("Shouhu"):GetComponent(Text)
    self.select = t:Find("Select").gameObject
    self.digit = {t:Find("Level/Digit/Digit1"):GetComponent(Image), t:Find("Level/Digit/Digit2"):GetComponent(Image), t:Find("Level/Digit/Digit3"):GetComponent(Image)}
    self.nameText = t:Find("Name/Text"):GetComponent(Text)
    self.passedObj = t:Find("Label/Passed").gameObject
    self.notopenObj = t:Find("Label/NotOpen").gameObject
    self.notopenText = t:Find("Label/NotOpen/Text"):GetComponent(Text)
    self.challengeObj = t:Find("Label/Challengable").gameObject
    self.preview = t:Find("MosterPreview").gameObject
    self.btn = t:GetComponent(Button)

    self.btn.onClick:AddListener(function() self:OnClick() end)

    self:Select(false)
end

function GloryPreviewItem:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self.assetWrapper = nil
    self.gameObject = nil
    self.model = nil
    self.callback = nil
    self.btn.onClick:RemoveAllListeners()
end

function GloryPreviewItem:update_my_self(id)
    self.select:SetActive(false)
    self.index = id

    local temp = self.index
    local c = 0
    while temp ~= 0 do
        c = c + 1
        self.digit[c].sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_3, "Num3_"..tostring(temp % 10))
        temp = math.floor(temp / 10)
        self.digit[c].gameObject:SetActive(true)
    end
    for i=c + 1,#self.digit do
        self.digit[i].gameObject:SetActive(false)
    end

    local data = DataGlory.data_level[id]
    local lev = RoleManager.Instance.RoleData.lev
    local model = self.model

    local monsterData = DataUnit.data_unit[data.unit_id]

    self.nameText.text = data.name
    local callback = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview.transform)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        self.preview:SetActive(true)
    end
    local setting = {
        name = "Moster"
        ,orthographicSize = 0.55
        ,width = 220
        ,height = 140
        ,offsetY = -0.38
        , noDrag = true
        ,noMaterial = true
    }
    local monsterdata = {type = PreViewType.Npc, skinId = monsterData.skin, modelId = monsterData.res, animationId = monsterData.animation_id, scale = monsterData.scale / 100, noMaterial = false}

    if model.level_id >= data.id then     -- 已通关
        self.passedObj:SetActive(true)
        self.challengeObj:SetActive(false)
        self.notopenObj:SetActive(false)
    else
        if lev >= data.need_lev then        -- 达到等级，已通关前面关卡，可挑战
            self.passedObj:SetActive(false)
            self.challengeObj:SetActive(true)
            self.notopenObj:SetActive(false)
        else                                            -- 未达到等级
            self.notopenText.text = string.format(TI18N("%s级开启"), data.need_lev)
            self.notopenObj:SetActive(true)
            self.challengeObj:SetActive(false)
            self.passedObj:SetActive(false)
        end
    end

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, monsterdata)
    else
        self.previewComp:Reload(monsterdata, callback)
        self.previewComp.loader.layer = "ModelPreview"
    end

    if model.selectData ~= nil then
        self.select:SetActive(model.selectData.id == self.index)
    end
end

function GloryPreviewItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GloryPreviewItem:OnClick()
    if self.index ~= nil and self.callback ~= nil then
        self.callback(self.index)
        self:Select(true)
    end
end

function GloryPreviewItem:Select(bool)
    local model = self.model

    self.select:SetActive(bool)
    self.firstKillName.gameObject:SetActive(bool)
    self.bestKillName.gameObject:SetActive(bool)
    self.shouhuText.gameObject:SetActive(bool)
    self.isSelected = false

    if bool then
        self.isSelected = true
        local basedata = DataGlory.data_level[self.index]
        if basedata.guard_num == 4 then
            self.shouhuText.text = TI18N("特殊条件:无")
        elseif basedata.guard_num > 0 then
            self.shouhuText.text = TI18N("守护人数≤")..basedata.guard_num
        else
            self.shouhuText.text = TI18N("不能携带守护")
        end

        local protoData = model.levelDataList[self.index]
        if protoData == nil then
            self.firstKillName.text = TI18N("首杀:")..ColorHelper.Fill("#ffff9a", TI18N("暂无"))
            self.bestKillName.text = TI18N("最佳:")..ColorHelper.Fill("#d781f2", TI18N("暂无"))
            self.mgr:send14405({id = self.index})
        else
            if protoData.first_name ~= nil and protoData.first_name ~= "" then
                self.firstKillName.text = TI18N("首杀:")..ColorHelper.Fill("#ffff9a", protoData.first_name)
            else
                self.firstKillName.text = TI18N("首杀:")..ColorHelper.Fill("#ffff9a", TI18N("暂无"))
            end
            if protoData.best_rank ~= nil and #protoData.best_rank > 0  then
                self.bestKillName.text = TI18N("最佳:")..ColorHelper.Fill("#d781f2", protoData.best_rank[1].name)
            else
                self.bestKillName.text = TI18N("最佳:")..ColorHelper.Fill("#d781f2", TI18N("暂无"))
            end
        end
    end
end

