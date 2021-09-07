--2016/7/14
--zzl
SummerLossChildPanel = SummerLossChildPanel or BaseClass(BasePanel)

function SummerLossChildPanel:__init(model, parent)
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.summer_loss_child_panel, type = AssetType.Main}
        ,{file = AssetConfig.summer_loss_child_bigbg,type = AssetType.Main}
        ,{file = AssetConfig.summer_loss_child_txt,type = AssetType.Main}
        ,{file = AssetConfig.summer_loss_child_bigtextrue,type = AssetType.Dep}
        ,{file = AssetConfig.may_textures, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }
    self.has_init = false
    --self.campaignData = 962
    return self
end

function SummerLossChildPanel:__delete()
    -- self.ImgBg.sprite = nil
    self.has_init = false
    if self.Grild ~= nil and self.Grild.sprite ~= nil then
        self.Grild.sprite = nil
    end
    if self.slot_list ~= nil then
        for _,v in pairs(self.slot_list) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slot_list = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SummerLossChildPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_loss_child_panel))
    self.gameObject.name = "SummerLossChildPanel"
    self.transform = self.gameObject.transform
    -- self.transform:SetParent(self.parent.RightCon)
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.one
    --self.transform.anchoredPosition = Vector2(91,-3)

    self.TopCon = self.transform:Find("TopCon")

    self.bigBg = self.transform:Find("TopCon/BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_loss_child_bigbg))
    UIUtils.AddBigbg(self.bigBg, bigObj)

    self.transform:Find("TopCon/Txt").gameObject:SetActive(false)
    UIUtils.AddBigbg(self.transform:Find("TopCon/Txt"), GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_loss_child_txt)))


    self.bgText = self.transform:Find("TopCon/Text"):GetComponent(Text)
    self.bgText.text = string.format("活动时间:%s月%s日 - %s月%s日",DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])
    self.bgText.transform.anchoredPosition = Vector2(-7, -60)
    -- self.bgText.gameObject:SetActive(false)

    local beginTime = DataAgenda.data_list[2029].open_timestamp[1][1]
    local endTime = DataAgenda.data_list[2029].open_timestamp[1][2]
    local bm = tonumber(os.date("%m", beginTime))
    local bd = tonumber(os.date("%d", beginTime))

    local em = tonumber(os.date("%m", endTime))
    local ed = tonumber(os.date("%d", endTime))
    self.noticeText = self.transform:Find("BottomCon/TxtDescI18N"):GetComponent(Text)

    self.noticeText.text = DataCampaign.data_list[self.campId].cond_desc
    -- self.noticeText.text = string.format(TI18N("参与等级：30级\n参与限制：3人或3人以上组队\n活动时间：<color='#13FC60'>%s月%s日~%s月%s日%s</color>\n参与方式：活动期间内每隔<color='#ffff00'>60分钟</color>刷出<color='#00ff00'>清甜冰沙</color>，通过挑战\n即可获得<color='#ffff00'>丰厚奖励</color>\n参与次数：每天<color='#13FC60'>前2次</color>成功挑战可获得奖励，失败不计次数"),bm,bd,em,ed,DataAgenda.data_list[2029].time)




    self.BottomCon = self.transform:Find("BottomCon")

    self.Grild = self.transform:Find("BottomCon/Grild"):GetComponent(Image)
    self.Grild.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_loss_child_bigtextrue, "GuideSprite")
    self.slot_list = {}
    for i=1,4 do
        local slotCon = self.BottomCon:Find(string.format("Slot%s", i))
        local slot = self:create_equip_slot(slotCon)
        -- slot:SetItemBg("ItemDefaultRed")
        table.insert(self.slot_list, slot)
    end

    -- local cfg_data = DataAgenda.data_list[2029]
    -- for i=1,#cfg_data.reward do
    --     local slot = self.slot_list[i]
    --     local d = cfg_data.reward[i]
    --     local base_data = DataItem.data_get[d.key]
    --     self:set_slot_data(slot, base_data)
    -- end
    local cfg_data = DataCampaign.data_list[self.campId]
    for i= 1, #cfg_data.reward do
        local slot = self.slot_list[i]
        local d = cfg_data.reward[i]
        local base_data = DataItem.data_get[d[1]]
        self:set_slot_data(slot, base_data)
    end

    -- UIUtils.AddBigbg(self.TopCon:Find("ImgBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_summer_happy_bg)))
    -- self.ImgIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantIcon1")
end


--创建slot
function SummerLossChildPanel:create_equip_slot(slot_con)
    local _slot = ItemSlot.New()
    _slot.gameObject.transform:SetParent(slot_con)
    _slot.gameObject.transform.localScale = Vector3.one
    _slot.gameObject.transform.localPosition = Vector3.zero
    _slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = _slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return _slot
end

--对slot设置数据
function SummerLossChildPanel:set_slot_data(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if _nobutton == nil then
        slot:SetAll(cell, {nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end
