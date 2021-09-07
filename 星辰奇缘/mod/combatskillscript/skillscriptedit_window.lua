-- 战斗出招表主界面
-- @author huangzefeng
-- @date 20160616
SkillScriptEditWindow = SkillScriptEditWindow or BaseClass(BaseWindow)

function SkillScriptEditWindow:__init(model)
    self.model = model
    self.mgr = SkillScriptManager.Instance
    self.name = "SkillScriptEditWindow"

    self.resList = {
        {file = AssetConfig.skillconfigwindow, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
    }
    self.currindex = 0
    self.currgroup = 0
    self.lastSelect = nil
    self.changeTag ={
        [1] = false,
        [2] = false,
        [3] = false,
    }
    self.first = true
    self.holdTag = false
    self.holdTime = 0
    self.group = {}
    self.SelectPanel ={}
    self.updatefunc = function()
        self:UpdatGroup()
    end
end


function SkillScriptEditWindow:__delete()
    SkillScriptManager.Instance.OnRoleScriptChange:Remove(self.updatefunc)
    -- self:CheckSave()

    for k, v in pairs(self.group) do
        for k2, v2 in pairs(v.List) do
            v2.iconLoader:DeleteMe()
        end
    end
    self.group = {}
    for k, v in pairs(self.SelectPanel) do
        v.iconLoader:DeleteMe()
    end
    self.SelectPanel ={}
    self:CheckChange()
    self:ClearDepAsset()
end

function SkillScriptEditWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skillconfigwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)

    self.SelectPanel = {}
    self.tabGroupContainer = self.transform:Find("Main/TabButtonGroup")
    for i=1,12 do
        self.SelectPanel[i] = {}
        self.SelectPanel[i].transform = self.transform:Find("Main/SelectPanel/IconCon"):GetChild(i-1)
        self.SelectPanel[i].icon = self.SelectPanel[i].transform:Find("Icon"):GetComponent(Image)
        self.SelectPanel[i].iconLoader = SingleIconLoader.New(self.SelectPanel[i].transform:Find("Icon").gameObject)
        self.SelectPanel[i].name = self.SelectPanel[i].transform:Find("SkillNameTxt"):GetComponent(Text)
        self.SelectPanel[i].cbtn = self.SelectPanel[i].transform:GetComponent(CustomButton)
        self.SelectPanel[i].cding = true
    end
    self.group = {}
    for i=1,3 do
        self.tabGroupContainer:GetChild(i-1):Find("NotifyPoint").gameObject:SetActive(self.mgr.roleCurrIndex == i)
        self.group[i] = {}
        self.group[i].transform = self.transform:Find(string.format("Main/%s", i))
        self.group[i].gameObject = self.group[i].transform.gameObject
        self.group[i].titleTxt = self.group[i].transform:Find("List/Title/Text"):GetComponent(Text)
        self.group[i].btn = self.group[i].transform:Find("List/Button"):GetComponent(Button)
        self.group[i].savebtn = self.group[i].transform:Find("List/SaveButton"):GetComponent(Button)
        self.group[i].renamebtn = self.group[i].transform:Find("EditButton"):GetComponent(Button)
        self.group[i].btn.onClick:AddListener(function() self:CheckSave(i,true) end)
        self.group[i].savebtn.onClick:AddListener(function() self:CheckSave(i,false) end)
        self.group[i].renamebtn.onClick:AddListener(function() self:Rename(i) end)
        self.group[i].titleTxt.text = string.format(TI18N("%s执行顺序"), self.mgr:GetGroupName(i))
        self.group[i].SelectPanel = {}
        self.group[i].List = {}
        for Li=1,15 do
            self.group[i].List[Li] = {}
            self.group[i].List[Li].transform = self.group[i].transform:Find("List/IconCon"):GetChild(Li-1)
            self.group[i].List[Li].select = self.group[i].List[Li].transform:Find("select")
            self.group[i].List[Li].icon = self.group[i].List[Li].transform:Find("Icon"):GetComponent(Image)
            self.group[i].List[Li].iconLoader = SingleIconLoader.New(self.group[i].List[Li].transform:Find("Icon").gameObject)
            self.group[i].List[Li].cbtn = self.group[i].List[Li].transform:GetComponent(CustomButton)
        end
    end
    self.skillList = BaseUtils.copytab(SkillManager.Instance.model.role_skill)
    self.normalid = CombatUtil.GetNormalSKill(RoleManager.Instance.RoleData.classes)
    local defendid = 1001
    table.insert(self.skillList, {base={name = TI18N("普通攻击"), id = self.normalid, lev = -1}})
    table.insert(self.skillList, {base={name = TI18N("防御"),id = defendid, lev = -1}})
    self.ScriptSetting = BaseUtils.copytab(self.mgr.RoleSet)
    -- BaseUtils.dump(self.ScriptSetting)
    self:InitSettingData()
    self:InitSkillList()
    self:InitGroupList()
    self.tabGroup = TabGroup.New(self.tabGroupContainer.gameObject, function(index) self:ChangeTab(index) end)
    if self.openArgs ~= nil then
        self.tabGroup:ChangeTab(self.openArgs)
    end

    self.EditNamePanel = self.transform:Find("Main/EditNamePanel")
    self.EditNamePanel:Find("Main/I18N_Text"):GetComponent(Text).horizontalOverflow = 1
    self.EditNamePanel:Find("Main/I18N_Text"):GetComponent(Text).text = TI18N("请输入方案名:(最多4个字)")

    local btn = self.EditNamePanel:GetComponent(Button)
    btn.onClick:AddListener(function() self:Hideeditnamepanel() end)

    btn = self.EditNamePanel:FindChild("Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:SaveName() end)

    self.SkillScriptInfo = self.transform:Find("Main/infoButton"):GetComponent(Button)

    self.SkillScriptInfo.onClick:AddListener(
        function()
        TipsManager.Instance:ShowText({gameObject = self.SkillScriptInfo.gameObject, itemData = {
            TI18N("1、战斗中进入自动时，将按照所选方案<color='#ffff00'>依次使用</color>技能"),
            TI18N("2、如果轮到的技能无法使用，会自动跳至<color='#ffff00'>下一个技能</color>"),
            TI18N("3、方案中所有技能都执行完后，系统将默认<color='#ffff00'>重头开始</color>执行"),
            }})
        end
      )

    self:UpdatGroup()
    SkillScriptManager.Instance.OnRoleScriptChange:Add(self.updatefunc)
end

function SkillScriptEditWindow:ChangeTab(index)
    for i=1,3 do
        self.group[i].gameObject:SetActive(index == i)
    end
    self.currgroup = index
    self:ResetSelect(self.group[index], index)
end

function SkillScriptEditWindow:InitSkillList()
    local iconindex = 1
    for i,v in ipairs(self.skillList) do
        -- BaseUtils.dump(v, "????")
        if v.base == nil then
            -- print(v.id)
            -- v.base = DataSkill.data_skill_role[v.id.."_1"]
        end
        if v.base ~= nil and v.base.type ~= 1 then
            local sprite = nil
            if v.base.icon ~= nil then
                -- sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(v.base.icon))
                sprite = v.base.icon
            else
                if v.base.id == 1001 then
                    -- sprite = PreloadManager.Instance:GetPetSkillSprite(1001)
                    sprite = 1001
                elseif v.base.id == self.normalid then
                    -- sprite = PreloadManager.Instance:GetPetSkillSprite(1000)
                    sprite = 1000
                end
            end
            -- self.SelectPanel[iconindex].icon.sprite = sprite
            self.SelectPanel[iconindex].iconLoader:SetSprite(SingleIconType.SkillIcon, sprite)
            self.SelectPanel[iconindex].icon.gameObject:SetActive(true)
            self.SelectPanel[iconindex].transform.gameObject:SetActive(true)
            self.SelectPanel[iconindex].cbtn.onClick:RemoveAllListeners()
            local currindex = iconindex
            self.SelectPanel[iconindex].cbtn.onClick:AddListener(function()
                self:OnSkillIconClick(v.base.id, v.base.lev, sprite, currindex)
            end)
            self.SelectPanel[iconindex].name.text = v.base.name
            self.SelectPanel[iconindex].cbtn.onHold:RemoveAllListeners()
            self.SelectPanel[iconindex].cbtn.onHold:AddListener(function()
                self:OnSkillIconHold(self.SelectPanel[iconindex].icon, v.base, Skilltype.roleskill)
            end)
            v.slot = self.SelectPanel[iconindex]
            iconindex = iconindex + 1
        end
    end
end

function SkillScriptEditWindow:OnSkillIconClick(id, lev, sprite, index)
    if self.holdTag == true and self.holdTime+1> Time.time then
        self.holdTag = false
        return
    end
    self.holdTag = false
    local key = CombatUtil.Key(id, lev)
    local skillData = DataCombatSkill.data_combat_skill[key]
    local precd = skillData ~= nil and skillData.pre_cooldown or nil
    -- local cd = 1
    -- print(self.SelectPanel[index].cding)
    if precd ~= nil and precd ~= 0 and self.currindex<= precd then
        -- NoticeManager.Instance:FloatTipsByString("该技能前置cd大于回合数可能无法使用")
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.blueSure = true
        confirmData.greenCancel = true
        confirmData.sureLabel = TI18N("放入")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            self:InsertToScript(id, sprite)
        end
        confirmData.content = TI18N("根据前面所选技能，该技能当前可能会处于冷却状态，是否确定放入？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    elseif self.SelectPanel[index].cding == true then
        -- NoticeManager.Instance:FloatTipsByString("该技能冷却中可能无法使用")
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.blueSure = true
        confirmData.greenCancel = true
        confirmData.sureLabel = TI18N("放入")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            self:InsertToScript(id, sprite)
        end
        confirmData.content = TI18N("根据前面所选技能，该技能冷却中可能无法使用，是否确定放入？")
        NoticeManager.Instance:ConfirmTips(confirmData)
        -- self:InsertToScript(id, sprite)
    else
        self:InsertToScript(id, sprite)
    end
end

function SkillScriptEditWindow:OnSkillIconHold(parent, skillData, skilltype)
    -- BaseUtils.dump(skillData)
    if skillData.lev == -1 then
        return
    end
    self.holdTag = true
    self.holdTime = Time.time
    local tipsinfo = {gameObject = parent.gameObject, skillData = skillData, type = skilltype}
    TipsManager.Instance:ShowSkill(tipsinfo)
end

function SkillScriptEditWindow:InsertToScript(id, sprite)
    if self.currindex == 0 or self.currgroup == 0 then
        return
    end
    -- self.group[self.currgroup].List[self.currindex].icon.sprite = sprite
    -- self.group[self.currgroup].List[self.currindex].icon.color = Color.white
    self.group[self.currgroup].List[self.currindex].iconLoader:SetSprite(SingleIconType.SkillIcon, sprite)
    self.group[self.currgroup].List[self.currindex].iconLoader:SetIconColor(Color.white)
    self.ScriptSetting[self.currgroup][self.currindex] = id
    if self.currindex < 15 then
        self:SelectSlot(self.currindex+1, false)
    end
    self.changeTag[self.currgroup] = true
    self:UpdatGroup()
end

function SkillScriptEditWindow:ResetSelect(group, index)
    local data = self.ScriptSetting[index]

    local last = 15
    for i,v in ipairs(data) do
        if v == 0 then
            last = i
            break
        end
    end
    self:SelectSlot(last, false)
end

function SkillScriptEditWindow:InitSettingData()
    self.ScriptSetting = BaseUtils.copytab(self.mgr.RoleSet)
    local temp = {}
    for i=1,3 do
        temp[i] = {}
        for ii=1,15 do
            temp[i][ii] = 0
            if self.ScriptSetting[i] ~= nil then
                for _, v in ipairs(self.ScriptSetting[i]) do
                    if v.skill_index == ii then
                        temp[i][ii] = v.skill_id
                        break
                    end
                end
            end
        end
    end
    self.ScriptSetting = temp
end

function SkillScriptEditWindow:InitGroupList()
    local nothingList = {}
    local colorno = Color(1,1,1,0)
    for i=1,3 do
        local settingData = self.ScriptSetting[i]
        self.group[i].transform = self.transform:Find(string.format("Main/%s", i))
        self.group[i].gameObject = self.group[i].transform.gameObject
        self.group[i].btn = self.group[i].transform:Find("List/Button"):GetComponent(Button)
        self.group[i].SelectPanel = {}
        for Li=1,15 do
            self.group[i].List[Li].transform = self.group[i].transform:Find("List/IconCon"):GetChild(Li-1)
            self.group[i].List[Li].select = self.group[i].List[Li].transform:Find("select")
            if settingData[Li] ~= 0 then
                local skillData = DataSkill.data_skill_role[settingData[Li].."_1"]
                if skillData ~= nil and skillData.icon ~= nil then
                    -- self.group[i].List[Li].icon.sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(skillData.icon))
                    self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
                else
                    if settingData[Li] == 1001 then
                        -- self.group[i].List[Li].icon.sprite = PreloadManager.Instance:GetPetSkillSprite(1001)
                        self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, 1001)
                    elseif settingData[Li] == self.normalid then
                        -- self.group[i].List[Li].icon.sprite = PreloadManager.Instance:GetPetSkillSprite(1000)
                        self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, 1000)
                    end
                end
                self.group[i].List[Li].icon.color = Color.white
            elseif Li == 1 then
                self.group[i].List[Li].icon.color = colorno
                table.insert(nothingList, i)
            else
                self.group[i].List[Li].icon.color = colorno
            end
            self.group[i].List[Li].icon.gameObject:SetActive(true)
            -- self.group[i].List[Li].icon.gameObject:SetActive(settingData[Li] ~= 0)
            self.group[i].List[Li].cbtn.onClick:RemoveAllListeners()
            self.group[i].List[Li].cbtn.onClick:AddListener(function()
                self:SelectSlot(Li, true)
            end)
        end
    end
    local lev = RoleManager.Instance.RoleData.lev
    if #nothingList > 0 and lev > 50 then
        local myclass = RoleManager.Instance.RoleData.classes
        for i,v in ipairs(nothingList) do
            local defaultdata = DataCombatUtil.data_skillset[string.format("%s_%s", myclass, v)]
            if defaultdata ~= nil and #defaultdata.unit_ids > 0 then
                local temp = {}
                for k,v in pairs(defaultdata.unit_ids) do
                    table.insert(temp, {skill_index = v[1], skill_id = v[2]})
                end
                self.mgr:SetGroupName(v, defaultdata.name, true)
                self.mgr:Send10764(v, temp, true)
            end
        end
    end
end

function SkillScriptEditWindow:UpdateGroupList()
    local nothingList = {}
    local colorno = Color(1,1,1,0)
    BaseUtils.dump(self.ScriptSetting, "设置")
    for i=1,3 do
        local settingData = self.ScriptSetting[i]
        for Li=1,15 do
            if settingData[Li] ~= 0 then
                local skillData = DataSkill.data_skill_role[settingData[Li].."_1"]
                if skillData ~= nil and skillData.icon ~= nil then
                    -- self.group[i].List[Li].icon.sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(skillData.icon))
                    self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
                else
                    if settingData[Li] == 1001 then
                        -- self.group[i].List[Li].icon.sprite = PreloadManager.Instance:GetPetSkillSprite(1001)
                        self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, 1001)
                    elseif settingData[Li] == self.normalid then
                        -- self.group[i].List[Li].icon.sprite = PreloadManager.Instance:GetPetSkillSprite(1000)
                        self.group[i].List[Li].iconLoader:SetSprite(SingleIconType.SkillIcon, 1000)
                    end
                end
                self.group[i].List[Li].icon.color = Color.white
            elseif Li == 1 then
                table.insert(nothingList, i)
                self.group[i].List[Li].icon.color = colorno
            else
                self.group[i].List[Li].icon.color = colorno
            end
            -- self.group[i].List[Li].icon.gameObject:SetActive(settingData[Li] ~= 0)
            -- self.group[i].List[Li].cbtn.onClick:RemoveAllListeners()
            -- self.group[i].List[Li].cbtn.onClick:AddListener(function()
            --     self:SelectSlot(Li, true)
            -- end)
        end
    end
    -- if #nothingList > 0 then
    --     local myclass = RoleManager.Instance.RoleData.classes
    --     for i,v in ipairs(nothingList) do
    --         local defaultdata = DataCombatUtil.data_skillset[string.format("%s_%s", myclass, v)]
    --         if defaultdata ~= nil and #defaultdata.unit_ids > 0 then
    --             local temp = {}
    --             for k,v in pairs(defaultdata.unit_ids) do
    --                 table.insert(temp, {skill_index = v[1], skill_id = v[2]})
    --             end
    --             self.mgr:Send10764(v, temp, true)
    --         end
    --     end
    -- end
end

function SkillScriptEditWindow:SelectSlot(index, clear)
    if self.lastSelect ~= nil then
        self.lastSelect.gameObject:SetActive(false)
    end
    local trans = self.group[self.currgroup].List[index].select
    self.lastSelect = trans
    self.lastSelect.gameObject:SetActive(true)
    self.currindex = index
    self:updataSkillList()
    if clear == true then
        -- self.group[self.currgroup].List[self.currindex].icon.sprite = sprite
        self.group[self.currgroup].List[self.currindex].icon.color = Color(1,1,1,0)
        self.ScriptSetting[self.currgroup][self.currindex] = 0
        self.changeTag[self.currgroup] = true
    end
end

-- 更新技能面板判断是否不能使用
function SkillScriptEditWindow:updataSkillList()
    for i,v in ipairs(self.skillList) do
        if v.slot ~= nil then
            local key = CombatUtil.Key(v.base.id, v.base.lev)
            local skillData = DataCombatSkill.data_combat_skill[key]
            v.slot.icon.color = Color.white
            v.slot.cding = false
            if skillData ~= nil and ((skillData.pre_cooldown ~= nil and skillData.pre_cooldown ~= 0) or (skillData.cooldown ~= nil and skillData.cooldown ~= 0)) then
                if skillData.pre_cooldown ~= nil and skillData.pre_cooldown ~= 0 and self.currindex <= skillData.pre_cooldown then
                    v.slot.icon.color = Color.grey
                elseif skillData.cooldown ~= nil and skillData.cooldown ~= 0 then
                    local startI = math.max(1,self.currindex - skillData.cooldown)
                    for point=startI,self.currindex-1 do
                        if self.ScriptSetting[self.currgroup][point] == v.base.id then
                            v.slot.icon.color = Color.grey
                            v.slot.cding = true
                            break
                        end
                    end
                else
                end
            end
        end
    end
end

function SkillScriptEditWindow:CheckSave(targetindex, issetindex)
    if targetindex == nil then
        for index,v in ipairs(self.changeTag) do
            if v then
                local data = self.ScriptSetting[index]
                local temp = {}
                local I = 1
                for i,v in ipairs(data) do
                    if v ~= 0 then
                        table.insert(temp, {skill_index = I, skill_id = v})
                        I = I + 1
                    end
                end
                self.changeTag[index] = false
                BaseUtils.dump(temp,"更改的结果")
                self.mgr:Send10764(index, temp)
            end
        end
    else
        if issetindex == true then
            if self.mgr.roleCurrIndex == targetindex then
                NoticeManager.Instance:FloatTipsByString(TI18N("已使用当前方案"))
            -- else
            --     print("我擦")
            --     self.model.mgr:Send10766(targetindex)
            end
            if self.changeTag[targetindex] then
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.sureSecond = -1
                confirmData.showClose = true
                confirmData.blueSure = true
                confirmData.greenCancel = true
                confirmData.sureLabel = TI18N("保存")
                confirmData.cancelLabel = TI18N("不保存")
                confirmData.sureCallback = function()
                    self:CheckSave(targetindex)
                    self:CheckSave(targetindex,true)
                end
                confirmData.cancelCallback = function()
                    -- WindowManager.Instance:CloseWindow(self.window)
                end
                confirmData.content = TI18N("当前方案尚未保存，是否保存并使用？")
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                self.model.mgr:Send10766(targetindex)
            end

        else
            if self.changeTag[targetindex] then
                local data = self.ScriptSetting[targetindex]
                local temp = {}
                local I = 1
                for i,v in ipairs(data) do
                    if v ~= 0 then
                        table.insert(temp, {skill_index = I, skill_id = v})
                        I = I + 1
                    end
                end
                self.changeTag[targetindex] = false
                self.mgr:Send10764(targetindex, temp)
            end
        end
    end
end

function SkillScriptEditWindow:UpdatGroup()
    for i=1,3 do
        local gname = self.mgr:GetGroupName(i)
        self.group[i].titleTxt.text = string.format(TI18N("%s执行顺序"), gname)
        self.tabGroup.buttonTab[i]["normalTxt"].text = gname
        self.tabGroup.buttonTab[i]["selectTxt"].text = gname
        self.tabGroupContainer:GetChild(i-1):Find("NotifyPoint").gameObject:SetActive(self.mgr.roleCurrIndex == i)
        if self.changeTag[i] then
            self.group[i].savebtn.gameObject.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.group[i].savebtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        else
            self.group[i].savebtn.gameObject.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.group[i].savebtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        end
        if self.mgr.roleCurrIndex == i then
            self.group[i].btn.gameObject.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.group[i].btn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("使用中")
            self.group[i].btn.gameObject.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        else
            self.group[i].btn.gameObject.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.group[i].btn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("使 用")
            self.group[i].btn.gameObject.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        end
    end
    if self.mgr.updateall > 0 then
        self:InitSettingData()
        self:UpdateGroupList()
    end
end

function SkillScriptEditWindow:Rename(i)
    local input_field = self.EditNamePanel:Find("Main/InputCon"):Find("InputField"):GetComponent(InputField)
    input_field.textComponent = self.EditNamePanel:Find("Main/InputCon/InputField/Text"):GetComponent(Text)
    input_field.characterLimit = 50
    input_field.text = ""
    self.EditNamePanel.gameObject:SetActive(true)
end

function SkillScriptEditWindow:Hideeditnamepanel(i)
    self.EditNamePanel.gameObject:SetActive(false)
end

function SkillScriptEditWindow:SaveName()
    local input_field = self.EditNamePanel:Find("Main/InputCon"):Find("InputField"):GetComponent(InputField)
    if string.utf8len(input_field.text) > 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("方案名字最长为4个字"))
    else
        self.mgr:SetGroupName(self.currgroup, input_field.text)
        self:Hideeditnamepanel()
    end
end

function SkillScriptEditWindow:CheckChange()
    for index,v in ipairs(self.changeTag) do
        if v then
            return true
        end
    end
end
