-- @author 黄耀聪
-- @date 2017年3月21日

TalismanAbsorbWindow = TalismanAbsorbWindow or BaseClass(BaseWindow)

function TalismanAbsorbWindow:__init(model)
    self.model = model
    self.name = "TalismanAbsorbWindow"
    self.windowId = WindowConfig.WinID.talisman_absorb

    self.resList = {
        {file = AssetConfig.talisman_absorb, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_set, type = AssetType.Dep},
    }

    self.targetId = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TalismanAbsorbWindow:__delete()
    self.OnHideEvent:Fire()
    if self.currentPage ~= nil then
        self.currentPage:DeleteMe()
        self.currentPage = nil
    end
    if self.disappearPage ~= nil then
        self.disappearPage:DeleteMe()
        self.disappearPage = nil
    end
    if self.selectPage ~= nil then
        self.selectPage:DeleteMe()
        self.selectPage = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    self:AssetClearAll()
end

function TalismanAbsorbWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_absorb))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.currentPage = TalismanAbsorbPage.New(self.model, t:Find("Main/Item1").gameObject, 1, self.assetWrapper)
    self.disappearPage = TalismanAbsorbPage.New(self.model, t:Find("Main/Item2").gameObject, 2, self.assetWrapper)
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window) end)

    self.selectPage = TalismanAbsorbSelect.New(self.model, t:Find("Main/Select1").gameObject)
    self.empty = t:Find("Main/Empty")

    self.button = t:Find("Main/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.currentPage.minusCallback = function() self:ChoosingTarget() end
    self.disappearPage.minusCallback = function() self:ChoosingAbsorb() end

    self.frozen = FrozenButton.New(self.button.gameObject)
    self.priceExt = MsgItemExt.New(t:Find("Main/Button/Text"):GetComponent(Text), 120, 19, 22)

    self.disappearPage.gameObject:SetActive(true)
    self.selectPage.gameObject:SetActive(false)

    t:Find("Main/I18N1/I18N1"):GetComponent(Text).text = TI18N("1.低级宝物属性可洗练到对应高级宝物上\n2.可洗练的属性数量与具有的属性数量有关\n3.三星以下的属性不可被吸收")
    -- t:Find("Main/I18N1/I18N1"):GetComponent(Text).text = TI18N("1.所选属性可直接洗炼至身上宝物中\n2.根据属性星级，每次洗炼消耗一定金币\n3.宝物被吸收后将完全消失")

    local tipsText = {
            TI18N("<color='#ffff00'>   宝物可洗炼属性数量规则：</color>"),
            TI18N("1、拥有<color='#00ff00'>1-3</color>条属性则可洗炼<color='#00ff00'>1</color>条 "),
            TI18N("2、拥有<color='#00ff00'>4-5</color>条属性则可洗炼<color='#00ff00'>2</color>条 "),
            TI18N("3、拥有<color='#00ff00'>6-7</color>条属性则可洗炼<color='#00ff00'>3</color>条 "),
        }

    self.tipsbtn = t:Find("Main/TipsBtn"):GetComponent(Button)
    self.tipsbtn.onClick:AddListener(function()  TipsManager.Instance:ShowText({gameObject = self.tipsbtn, itemData = tipsText})    end)
end

function TalismanAbsorbWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()

    self.absorbId = (self.openArgs or {}).id
    self:Reload()
end

function TalismanAbsorbWindow:OnOpen()
    self:RemoveListeners()
end

function TalismanAbsorbWindow:OnHide()
    self:RemoveListeners()
end

function TalismanAbsorbWindow:RemoveListeners()
end

function TalismanAbsorbWindow:Reload()
    if self.absorbId ~= nil then
        local selectItem = self.model.itemDic[self.absorbId]
        local baseData = DataTalisman.data_get[selectItem.base_id]
        local index = TalismanEumn.TypeProto[baseData.type]
        local plan = self.model.planList[self.model.use_plan or 1]
        local currItem = self.model.planList[self.model.use_plan or 1][index]
        currItem = self.model.itemDic[currItem.id]
        self.targetId = currItem.id
        local attrNum = self:GetAbsorbAttrNum(selectItem)
        local minStar = self:GetAbsorbMinStar(selectItem, currItem)

        self.disappearPage.clickCallback = function(attr) self:ClickAttr(attr) end
        self.disappearPage:SetData(selectItem, attrNum, minStar)
        self.currentPage:SetData(currItem, attrNum)

        self:SetDescText(selectItem, currItem)
    end
end

function TalismanAbsorbWindow:ClickAttr(attrList)
    local cost = 0
    local costAssets = 0
    for key, attr in pairs(attrList) do
        if attr ~= nil then
            cost = cost + DataTalisman.data_absorb[TalismanEumn.DecodeFlag(attr.flag, 2)].loss[1][2]
            costAssets = DataTalisman.data_absorb[TalismanEumn.DecodeFlag(attr.flag, 2)].loss[1][1]
        end
    end

    if costAssets ~= 0 then
        self.priceExt:SetData(string.format(TI18N("%s{assets_2,%s}洗练"), BaseUtils.FormatNum(cost), costAssets))
        local size = self.priceExt.contentTrans.sizeDelta
        self.priceExt.contentTrans.anchoredPosition = Vector2(-size.x/2, size.y/2)
    else
        self.priceExt:SetData(TI18N("洗练"))
        local size = self.priceExt.contentTrans.sizeDelta
        self.priceExt.contentTrans.anchoredPosition = Vector2(-size.x/2, size.y/2)
    end
end

-- function TalismanAbsorbWindow:ChoosingTarget()
--     local datalist = {}
--     for _,v in pairs(self.model.itemDic) do
--         table.insert(datalist, v)
--     end
--     self.selectPage:SetData(datalist)
--     self.selectPage.transform.anchoredPosition = Vector2(-153, 30.6)
--     self.selectPage.clickCallback = function(id)
--         self.targetId = id
--         self.selectPage.gameObject:SetActive(false)
--         self.currentPage:SetData(self.model.itemDic[self.targetId])
--         self.currentPage.gameObject:SetActive(true)
--         self.empty.gameObject:SetActive(false)
--         self:ChoosingAbsorb()
--     end
--     self.selectPage.gameObject:SetActive(true)
--     self.currentPage.gameObject:SetActive(false)
--     self.empty.gameObject:SetActive(true)
--     self.disappearPage.gameObject:SetActive(false)
-- end

-- function TalismanAbsorbWindow:ChoosingAbsorb()
--     local datalist = {}
--     local set_id = DataTalisman.data_get[self.model.itemDic[self.targetId].base_id].set_id
--     local type = DataTalisman.data_get[self.model.itemDic[self.targetId].base_id].type
--     for _,v in pairs(self.model.itemDic) do
--         if self.model.useItemDic[v.id] == nil and v.id ~= self.targetId and DataTalisman.data_get[v.base_id].set_id == set_id and type == DataTalisman.data_get[v.base_id].type then
--             table.insert(datalist, v)
--         end
--     end
--     self.selectPage:SetData(datalist)
--     self.selectPage.transform.anchoredPosition = Vector2(153, 30.6)
--     self.selectPage.clickCallback = function(id)
--         self.absorbId = id
--         self.selectPage.gameObject:SetActive(false)
--         self.disappearPage.gameObject:SetActive(true)
--         self.disappearPage:SetData(self.model.itemDic[self.absorbId])
--     end
--     self.empty.gameObject:SetActive(false)
--     self.selectPage.gameObject:SetActive(true)
--     self.disappearPage.gameObject:SetActive(false)
-- end

function TalismanAbsorbWindow:OnClick()
    local targetAttr = self.currentPage:GetAttr()
    local absorbAttr = self.disappearPage:GetAttr()
    if self.targetId == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择法宝"))
    elseif targetAttr == nil or #targetAttr == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择属性"))
    elseif self.absorbId == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要吸收的法宝"))
    elseif absorbAttr == nil or #absorbAttr == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要吸收的法宝属性"))
    elseif #targetAttr ~= #absorbAttr then
        NoticeManager.Instance:FloatTipsByString(TI18N("两边所选属性数量相同时才可洗练哟{face_1, 22}"))
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("转移属性后，被吸收的装备将完全消失")
        confirmData.sureCallback = function() self:DoAbsorb() end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function TalismanAbsorbWindow:DoAbsorb()
    if self.currentPage ~= nil and self.disappearPage ~= nil then
        local targetAttr = self.currentPage:GetAttr()
        local absorbAttr = self.disappearPage:GetAttr()
        TalismanManager.Instance:send19607(self.targetId, targetAttr, self.absorbId, absorbAttr)
        self.frozen:OnClick()
    end
    -- WindowManager.Instance:CloseWindow(self)
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window)
end

function TalismanAbsorbWindow:GetAbsorbAttrNum(selectItem)
    local attrNum = 0
    for i,v in ipairs(selectItem.attr) do
        if v.type == 9 and v.name ~= 0 then
            attrNum = attrNum + 1
        end
    end

    local data_absorb_num = DataTalisman.data_absorb_num[attrNum]
    if data_absorb_num == nil then
        return 1
    else
        return data_absorb_num.dst_absorb_num
    end
end

function TalismanAbsorbWindow:GetAbsorbMinStar(selectItem, currItem)
    local selectItem_config = DataTalisman.data_get[selectItem.base_id]
    local currItem_config = DataTalisman.data_get[currItem.base_id]
    local data_absorb_set_id_map = DataTalisman.data_absorb_set_id_map[selectItem_config.set_id]
    if data_absorb_set_id_map ~= nil and BaseUtils.ContainValueTable(data_absorb_set_id_map.dst_map, currItem_config.set_id) then
        return 3
    else
        return 1
    end
end

function TalismanAbsorbWindow:SetDescText(selectItem, currItem)
    local selectItem_config = DataTalisman.data_get[selectItem.base_id]
    local currItem_config = DataTalisman.data_get[currItem.base_id]
    if selectItem_config.set_id == currItem_config.set_id then
        self.transform:Find("Main/I18N1/I18N1"):GetComponent(Text).text = TI18N("1.所选属性可直接洗炼至身上宝物中\n2.根据属性星级，每次洗炼消耗一定金币\n3.宝物被吸收后将完全消失")
    else
        self.transform:Find("Main/I18N1/I18N1"):GetComponent(Text).text = TI18N("1.低级宝物属性可洗练到对应高级宝物上\n2.可洗练的属性数量与具有的属性数量有关\n3.三星以下的属性不可被吸收")
    end
end
