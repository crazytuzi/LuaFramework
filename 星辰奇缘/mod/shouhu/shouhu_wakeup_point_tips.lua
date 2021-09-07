--author:zzl
--time:2016/11/22
--守护觉醒星阵阵位点击tipspanel

ShouhuWakeUpPointTips  =  ShouhuWakeUpPointTips or BaseClass(BasePanel)

function ShouhuWakeUpPointTips:__init(model)
    self.name  =  "ShouhuWakeUpPointTips"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.shouhu_wakeup_point_tips, type  =  AssetType.Main}
    }

    self.is_open = false
    return self
end

function ShouhuWakeUpPointTips:__delete()
    self.is_open = false
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ShouhuWakeUpPointTips:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_wakeup_point_tips))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuWakeUpPointTips"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -800)
    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseWakeupPointTips() end)

    self.MainCon = self.transform:FindChild("MainCon")

    self.TitleTxt = self.MainCon:FindChild("TitleCon"):FindChild("TxtTitle"):GetComponent(Text)
    self.PointCon = self.MainCon:FindChild("PointCon")
    self.TxtCondition1 = self.PointCon:FindChild("TxtCondition1"):GetComponent(Text)
    self.TxtCondition2 = self.PointCon:FindChild("TxtCondition2"):GetComponent(Text)
    self.TxtCondition3 = self.PointCon:FindChild("TxtCondition3"):GetComponent(Text)
    self.BtnSkill = self.PointCon:FindChild("BtnSkill"):GetComponent(Button)
    self.BtnSkillTxt = self.PointCon:FindChild("BtnSkill"):FindChild("Text"):GetComponent(Text)
    self.showSkillTips = false

    self.BtnSkill.onClick:AddListener(function() self:ClickSkill() end)

    self.SkillCon = self.MainCon:FindChild("SkillCon")
    self.SlotCon = self.SkillCon:FindChild("SlotCon")
    self.TxtSkillName = self.SkillCon:FindChild("TxtSkillName"):GetComponent(Text)
    self.TxtSkillLev = self.SkillCon:FindChild("TxtSkillLev"):GetComponent(Text)
    self.TxtSkillDesc = self.SkillCon:FindChild("TxtSkillDesc"):GetComponent(Text)

    self.StarCon = self.MainCon:FindChild("StarCon")
    self.StarTxtCondition1 = self.StarCon:FindChild("TxtCondition1"):GetComponent(Text)
    self.StarTxtCondition2 = self.StarCon:FindChild("TxtCondition2"):GetComponent(Text)

    local baseData = DataShouhu.data_guard_base_cfg[self.openArgs.base_id]
    local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.openArgs.base_id, self.openArgs.quality+1)]

    if self.openArgs.pointIndex == 0 then
        local attrData = self.model:GetGuardWakeupUpgrade(self.openArgs.base_id, self.openArgs.quality)
        --激活位
        self.PointCon.gameObject:SetActive(true)
        self.StarCon.gameObject:SetActive(false)
        self.TxtCondition1.text = string.format(TI18N("2、%s品质→<color='#2acbfe'>%s</color>"), baseData.alias, self.model.wakeUpQualityName[self.openArgs.quality+1])
        self.TxtCondition2.text = string.format(TI18N("3、%s习得新技能："), baseData.alias)

        self.TxtCondition3.text = string.format(TI18N("1、<color='#ffff00'>人物%s+%s</color>"), KvData.attr_name[attrData.attr], attrData.val)

        self.BtnSkillTxt.text = ""
        local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.openArgs.base_id, 4)]
        local skillId = 0
        for k, v in pairs(upgradeCfgData.qualitySkills) do
            if v[2] == self.openArgs.quality+1 then
                skillId = v[1]
                break
            end
        end
         if skillId > 0 then
             self.BtnSkillTxt.text = string.format("[%s]", DataSkill.data_skill_guard[string.format("%s_1", skillId)].name)
         else
             self.BtnSkillTxt.text = ""
             self.TxtCondition2.text = ""
        end
       
    else
        --星阵位
        local baseCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.openArgs.base_id, self.openArgs.pointIndex, self.openArgs.quality)]
        local growthVal = baseCfgData.growth/1000
        if self.openArgs.quality > baseData.quality then
            local lastCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.openArgs.base_id, self.openArgs.pointIndex, self.openArgs.quality - 1)]
            if lastCfgData ~= nil then
                growthVal = growthVal - lastCfgData.growth/1000
            end
        end
        self.PointCon.gameObject:SetActive(false)
        self.StarCon.gameObject:SetActive(true)
        self.StarTxtCondition1.text = string.format(TI18N("%s成长 +%s"), baseData.alias, growthVal)
    end

    if self.openArgs.title ~= nil then
        self.TitleTxt.text = self.openArgs.title
    end
end

function ShouhuWakeUpPointTips:ClickSkill()
    self.showSkillTips = not self.showSkillTips
    self.SkillCon.gameObject:SetActive(self.showSkillTips)

    local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.openArgs.base_id, 4)]
    local skillId = 0
    for k, v in pairs(upgradeCfgData.qualitySkills) do
        if v[2] == self.openArgs.quality+1 then
            skillId = v[1]
            break
        end
    end
    local skillData = DataSkill.data_skill_guard[string.format("%s_1", skillId)]

    self.TxtSkillName.text = skillData.name
    self.TxtSkillLev.text = string.format("<color='#6d889a'>%s%s%s</color>", TI18N("进阶"), ShouhuManager.Instance.model.wakeUpQualityName[self.openArgs.quality+1], TI18N("色可习得"))
    self.TxtSkillDesc.text = skillData.desc

    if self.slot == nil then
        self.slot = SkillSlot.New()
        UIUtils.AddUIChild(self.SlotCon, self.slot.gameObject)
        self.slot:SetNotips(true)
        self.slot.gameObject:SetActive(true)
    end
    self.slot:SetAll(Skilltype.shouhuskill,{id = skillData.id, icon = skillData.icon})
end