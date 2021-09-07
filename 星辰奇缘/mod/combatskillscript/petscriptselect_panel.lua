-- 战斗宠物出招选择
-- @author huangzefeng
-- @date 20160616

PetScriptSelectPanel = PetScriptSelectPanel or BaseClass(BasePanel)


function PetScriptSelectPanel:__init(model)
    self.model = model
    self.name = "PetScriptSelectPanel"
    self.mgr = SkillScriptManager.Instance

    self.resList = {
        {file = AssetConfig.setpetskillpanel, type = AssetType.Main}
    }
    local currpet = PetManager.Instance.model.battle_petdata
    if currpet.status == 1 then
        self.petskillList = BaseUtils.copytab(currpet.skills)
        table.insert( self.petskillList, {id = 1000} )
        table.insert( self.petskillList, {id = 1001} )
    else
        self.petskillList = {}
    end
    self.end_fight_callback = function()
        self.model:ClosePetPanel()
    end

    self.headLoaderList = {}
    self.skillIconLoaderList = {}
    self.currselect = nil
    self.currselectid = nil
    self.haveSpecialSkill = nil -- 针对剑盾之心这类特殊技能加的标记，如果宠物技能列表中有该项技能，则haveSpecialSkill为1，否则为nil
end

function PetScriptSelectPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.end_fight_callback)
    for i, v in ipairs(self.skillIconLoaderList) do
        v:DeleteMe()
        v = nil
    end
    self.skillIconLoaderList = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function PetScriptSelectPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.setpetskillpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "PetScriptSelectPanel"
    self.transform = self.gameObject.transform

    if self.openArgs then
        self.transform:Find("Main").anchoredPosition = Vector2(75, 37)
        EventMgr.Instance:AddListener(event_name.end_fight, self.end_fight_callback)
    end
    self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetPanel() end)
    self.petGrid = self.transform:Find("Main/Mash/Grid")
    self.baseItem = self.transform:Find("Main/Mash/BaseIcon").gameObject
    local setting = {
        column = 3
        ,cspacing = 23
        ,rspacing = 14
        ,cellSizeX = 64
        ,cellSizeY = 64
        ,scrollRect = self.petGrid.parent
    }
    self.PetLayout = LuaGridLayout.New(self.petGrid, setting)

    for i,v in ipairs(self.petskillList) do
        local key = string.format("%s_1", v.id)
        local basedata = DataCombatSkill.data_combat_skill[key]
        local icondata = DataSkill.data_petSkill[key]
        if (v.id == 1000 or v.id == 1001) or (basedata ~= nil and basedata.type == 0) then
            if basedata ~= nil then
                print(basedata.type)
            end
            local item = GameObject.Instantiate(self.baseItem)
            local skillIconLoader = SingleIconLoader.New(item.transform:Find("icon").gameObject)
            table.insert(self.skillIconLoaderList, skillIconLoader)
            self.PetLayout:AddCell(item)
            if v.id == 1000 or v.id == 1001 then
                -- item.transform:Find("icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(v.id)
                skillIconLoader:SetSprite(SingleIconType.SkillIcon, v.id)
                if v.id == 1000 then
                    item.transform:Find("SkillNameTxt"):GetComponent(Text).text = TI18N("普通攻击")
                else
                    item.transform:Find("SkillNameTxt"):GetComponent(Text).text = TI18N("防御")
                end
            else
                -- local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(v.id, 1)
                -- if Gassest ~= "" then
                --     item.transform:Find("icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(Gassest, icondata.icon)
                -- else
                --     item.transform:Find("icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(icondata.icon)
                -- end
                skillIconLoader:SetSprite(SingleIconType.SkillIcon, icondata.icon)
                item.transform:Find("SkillNameTxt"):GetComponent(Text).text = icondata.name
            end

            item.transform:GetComponent(CustomButton).onClick:RemoveAllListeners()
            item.transform:GetComponent(CustomButton).onClick:AddListener(function()
                self:clickItem(v.id, item)
            end)
            item.transform:GetComponent(CustomButton).onHold:RemoveAllListeners()
            item.transform:GetComponent(CustomButton).onHold:AddListener(function()
                self:holdItem(item,icondata)
            end)

            if v.id == self.mgr.PetSet then
                self.currselect = item.transform:Find("Label")
                self.currselectid = v.id
                self.currselect.gameObject:SetActive(true)
            end

            if self:checkHaveSpecialSkill(v.id) then
                self.haveSpecialSkill = true
            end

        else
        end
    end

    -- 如果检测到有剑盾之心一类的特殊技能，则添加智能模式选项供挂机选择
    if self.haveSpecialSkill then
        local key = string.format("%s_1", 0)
        local icondata = DataSkill.data_petSkill[key]
        local data = PetManager.Instance.model.battle_petdata
        local item = GameObject.Instantiate(self.baseItem)
        self.PetLayout:AddCell(item)
        item.transform:Find("SkillNameTxt"):GetComponent(Text).text = TI18N("智能模式")

        local loaderId = item.transform:Find("icon"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:Find("icon"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,data.base.head_id)

        -- item.transform:Find("icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data.base.head_id), string.format("%s", data.base.head_id))

        item.transform:GetComponent(CustomButton).onClick:RemoveAllListeners()
        item.transform:GetComponent(CustomButton).onClick:AddListener(function()
            self:clickItem(0, item)
        end)
        item.transform:GetComponent(CustomButton).onHold:RemoveAllListeners()
        item.transform:GetComponent(CustomButton).onHold:AddListener(function()
            self:holdItem(item,icondata)
        end)

        if 0 == self.mgr.PetSet then
            self.currselect = item.transform:Find("Label")
            self.currselectid = 0
            self.currselect.gameObject:SetActive(true)
        end
    end
    -- 修改by嘉俊

end

function PetScriptSelectPanel:clickItem(id, item)
    if self.currselect ~= nil then
        self.currselect.gameObject:SetActive(false)
    end
    self.currselect = item.transform:Find("Label")
    self.currselectid = id
    self.currselect.gameObject:SetActive(true)
    self.mgr:Send10765(id)
    self.model:ClosePetPanel()
end

function PetScriptSelectPanel:checkHaveSpecialSkill(id)
    local specialSkillList = {60507}
    for var = 1,#specialSkillList do
        if id == specialSkillList[var] then
            return true
        end
    end
    return false
end


function PetScriptSelectPanel:holdItem(parent, skilldata)
    local tipsinfo = {gameObject = parent, skillData = skilldata, type = Skilltype.petskill}
    TipsManager.Instance:ShowSkill(tipsinfo)
end