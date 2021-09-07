AutoFarmWindow = AutoFarmWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function AutoFarmWindow:__init(model)
    self.model = model
    self.name = "AutoFarmWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.winLinkType = WinLinkType.Single
    self.autofarmMgr = self.model.autofarmMgr
    self.resList = {
        {file = AssetConfig.autofarmwindow, type = AssetType.Main}
    }
    self.previewList = {}
    self.oldPetItem = {}
    self.headLoaderList = {}
    self.bestpage = 1
    self.bestindex = 1

    self.scriptSetfunc = function()
        self:InitSkillSet()
    end
end

function AutoFarmWindow:__delete()
    PetManager.Instance.OnUpdatePetList:Remove(self.scriptSetfunc)
    SkillScriptManager.Instance.OnRoleScriptChange:Remove(self.scriptSetfunc)
    SkillScriptManager.Instance.OnPetScriptChange:Remove(self.scriptSetfunc)
    if self.petLayout ~= nil then
        self.petLayout:DeleteMe()
        self.petLayout = nil
    end

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end

    if self.roleItemSkillIconLoader ~= nil then
        self.roleItemSkillIconLoader:DeleteMe()
        self.roleItemSkillIconLoader = nil
    end
    if self.presentLayout ~= nil then
        self.presentLayout:DeleteMe()
        self.presentLayout = nil
    end
    if self.tabpage ~= nil then
        self.tabpage:DeleteMe()
        self.tabpage = nil
    end
    if self.previewList ~= nil then
        for k,v in pairs(self.previewList) do
            v:DeleteMe()
        end
        self.previewList = nil
    end
    self.lockpanel = nil
    self:ClearDepAsset()
end

function AutoFarmWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.autofarmwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMain() end)
    -- self.hasText = self.transform:Find("Main/BottomCon/hasText"):GetComponent(Text)
    self.remainText = self.transform:Find("Main/BottomCon/remainText"):GetComponent(Text)

    self.lockBtn = self.transform:Find("Main/BottomCon/LockButton"):GetComponent(Button)
    self.lockBtn.onClick:AddListener(function()
            self:OnClickLockScreen()
        end)

    self.transform:Find("Main/BottomCon/StartButton"):GetComponent(Button).onClick:AddListener(function() self.autofarmMgr:tofarm(SceneManager.Instance:CurrentMapId()) end)
    self.transform:Find("Main/BottomCon/FreezButton"):GetComponent(Button).onClick:AddListener(function() self:FreezPoint() end)
    self.transform:Find("Main/BottomCon/GetButton"):GetComponent(Button).onClick:AddListener(function() self:GetPoint() end)
    self.transform:Find("Main/BottomCon/infoButton"):GetComponent(Button).onClick:AddListener(
        function()
        TipsManager.Instance:ShowText({gameObject = self.transform:Find("Main/BottomCon/infoButton").gameObject, itemData = {
            TI18N("1、野外挂机和悬赏任务可使用双倍点数"),
            TI18N("2、挂机场景每场战斗消耗1点双倍"),
            TI18N("3、野外挂机有50%几率不消耗双倍点数"),
            TI18N("4、野外打怪需要领取双倍才有可能遇到<color='#ffff00'>宠物宝宝</color>"),
            string.format(TI18N("5、每周可领取<color='#00ff00'>%s</color>点双倍点"), tostring(AgendaManager.Instance.DefaultDoubleNum)),
            TI18N("6、双倍点数最多可以存储<color='#00ff00'>420</color>点"),
            TI18N("7、冻结双倍点数需要消耗1点双倍点"),
            string.format(TI18N("8、当前剩余<color='#00ff00'>%s</color>点未领取"), tostring(AgendaManager.Instance.max_double_point)),
            }})
        end
      )

    self.petPanel = self.transform:Find("Main/PetCon")
    self.petPanelCon = self.petPanel:Find("PetMaskCon/PetItemCon")
    self.petitem = self.petPanel:Find("PetMaskCon/PetItem").gameObject
    self.petPanel:Find("closePanel"):GetComponent(Button).onClick:AddListener(function() self.petPanel.gameObject:SetActive(false) end)

    local setting = {
        axis = BoxLayoutAxis.X
        ,cspacing = 0
        ,Left = 0
    }
    self.petLayout = LuaBoxLayout.New(self.petPanelCon, setting)

    self.page = self.transform:Find("Main/MaskScroll/Page").gameObject
    self.page:SetActive(false)
    local setting1 = {
        axis = BoxLayoutAxis.X
        ,cspacing = 0
        ,Left = 0
    }
    self.presentLayout = LuaBoxLayout.New(self.transform:Find("Main/MaskScroll/Container"), setting1)
    self.pagenum = math.ceil(DataHangup.data_list_length/3)
    self:InitPage()
    local panel = self.transform:Find("Main/MaskScroll").gameObject
    self.tabpage = TabbedPanel.New(panel, self.pagenum, 746)
    self.OnHideEvent:AddListener(function() self:HidePreview() end)
    self.OnOpenEvent:AddListener(function() self:ShowPreview() end)
    self:setPoint()
    self:SetBestItem()
    self.tabpage:TurnPage(self.bestpage)

    self.RoleItem = self.transform:Find("Main/SkillMaskScroll/Container/RoleItem")
    self.PetItem = self.transform:Find("Main/SkillMaskScroll/Container/PetItem")
    self.RoleItembtn = self.RoleItem:Find("Button"):GetComponent(Button)
    self.PetItembtn = self.PetItem:Find("Button"):GetComponent(Button)

    self.roleItemSkillIconLoader = SingleIconLoader.New(self.RoleItem:Find("Icon"):GetComponent(Image).gameObject)
    self.headLoader = SingleIconLoader.New(self.PetItem:Find("Icon"):GetComponent(Image).gameObject)

    self:InitSkillSet()
    self.SkillScriptInfo = self.transform:Find("Main/SkillMaskScroll/infoButton"):GetComponent(Button)

    self.SkillScriptInfo.onClick:AddListener(
        function()
        TipsManager.Instance:ShowText({gameObject = self.SkillScriptInfo.gameObject, itemData = {
            TI18N("1、战斗中进入自动时，将按照所选方案<color='#ffff00'>依次使用</color>技能"),
            TI18N("2、如果轮到的技能无法使用，会自动跳至<color='#ffff00'>下一个技能</color>"),
            TI18N("3、方案中所有技能都执行完后，系统将默认<color='#ffff00'>重头开始</color>执行"),
            }})
        end
      )

    PetManager.Instance.OnUpdatePetList:Add(self.scriptSetfunc)
    SkillScriptManager.Instance.OnRoleScriptChange:Add(self.scriptSetfunc)
    SkillScriptManager.Instance.OnPetScriptChange:Add(self.scriptSetfunc)
end

function AutoFarmWindow:OnClickLockScreen()
    self.model:CloseMain()
    SettingManager.Instance.lockpanel:Show()
end

function AutoFarmWindow:InitPage()
    for i = 1, self.pagenum do
        local page = GameObject.Instantiate(self.page)
        page.gameObject.name = tostring(i)
        for sub = 1, 3 do
            local item = page.transform:Find(string.format("Item%s", tostring(sub)))
            local index = (i-1)*3+sub
            self:SetPageitem(item, index)
        end
        self.presentLayout:AddCell(page.gameObject)
    end
end


function AutoFarmWindow:SetPageitem(item, index)
    local dat = DataHangup.data_list[index]
    if dat == nil then
        item.gameObject:SetActive(false)
        return
    end
    item.name = tostring(index)
    local page = math.ceil(index/3)
    if not BaseUtils.isnull(item.transform:Find(string.format("bg/backgroungImage%s",tostring(page)))) then
        item.transform:Find(string.format("bg/backgroungImage%s",tostring(page))).gameObject:SetActive(true)
    else
        item.transform:Find("bg/backgroungImage3").gameObject:SetActive(true)
    end
    local lev = RoleManager.Instance.RoleData.lev
    if RoleManager.Instance.RoleData.lev_break_times > 0 and RoleManager.Instance.RoleData.lev < 100 then
        lev = 100
    end
    if lev>= dat.min_lev and lev <=dat.max_lev then
        self.bestpage = page
        self.bestindex = index
        -- item.transform:Find("Label").gameObject:SetActive(true)
        -- item.transform:Find("Select").gameObject:SetActive(true)
    end
    item.gameObject:SetActive(true)
    item.transform:Find("TextArea"):GetComponent(Text).text=dat.name
    item.transform:Find("TextLev"):GetComponent(Text).text=string.format(TI18N("%s-%s级"),tostring(dat.min_lev),tostring(dat.max_lev))
    local Info = item.transform:Find("infoButton").gameObject
    Info:GetComponent(Button).onClick:RemoveAllListeners()
    Info:GetComponent(Button).onClick:AddListener(function() self:setPetList(index) end)
    local function tofarm (  )
        self.autofarmMgr:tofarm( dat.map_id )
    end
    item:GetComponent(Button).onClick:AddListener(function (  )
        if CombatManager.Instance.isFighting == true then
            --战斗中不执行
            NoticeManager.Instance:FloatTipsByString(TI18N("当前在战斗中，不能进行该操作"))
        end
        if RoleManager.Instance.RoleData.lev<dat.min_lev then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("该场景怪物等级较高,挂机有风险,是否前往该场景?")
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = tofarm
            NoticeManager.Instance:ConfirmTips(data)
        else
            tofarm (  )
        end
    end)
    local previewCon = item.transform:Find("preview")
    local previewcb = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(previewCon)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform:Rotate(Vector3(350, 340, 0))
    end
    self:LoadPreview(dat.monster_id[1], previewcb)
end

function AutoFarmWindow:SetBestItem()
    local page = math.ceil(self.bestindex/3)
    local item = self.transform:Find(string.format("Main/MaskScroll/Container/%s/%s", tostring(page), tostring(self.bestindex)))
    item.transform:Find("Label").gameObject:SetActive(true)
    item.transform:Find("Select").gameObject:SetActive(true)
end

function AutoFarmWindow:setPetList(index)
    local dat = DataHangup.data_list[index]
    self.petPanel:Find("TextArea"):GetComponent(Text).text = dat.name
    for i,v in ipairs(self.oldPetItem) do
        GameObject.DestroyImmediate(v)
    end
    self.oldPetItem = {}
    self.petLayout:ReSet()
    for i,v in ipairs(dat.pet_id) do
        local petitem = GameObject.Instantiate(self.petitem)
        local basepetData = DataPet.data_pet[v]
        petitem.gameObject.name = basepetData.name
        petitem.transform:Find("TextArea"):GetComponent(Text).text = basepetData.name
        local loaderId = petitem.transform:Find("Image"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(petitem.transform:Find("Image"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,basepetData.head_id)
        -- petitem.transform:Find("Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(basepetData.head_id), basepetData.head_id)
        table.insert(self.oldPetItem, petitem.gameObject)
        self.petLayout:AddCell(petitem)
    end

    self.petPanel.gameObject:SetActive(true)
end

function AutoFarmWindow:LoadPreview(baseid, callback)
    local previewComp = nil
    local cb = function(composite)
        callback(composite)
    end
    local BaseData = DataUnit.data_unit[baseid]
    local setting = {
        name = BaseData.name
        ,orthographicSize = 0.5
        ,width = 160
        ,height = 240
        ,offsetY = -0.36
        ,noDrag = true
        ,noMaterial = true
    }
    local modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 0.8}
    previewComp = PreviewComposite.New(cb, setting, modelData)
    table.insert(self.previewList, previewComp)

end

function AutoFarmWindow:HidePreview()
    for k,v in pairs(self.previewList) do
        v:Hide()
    end
end

function AutoFarmWindow:ShowPreview()
    self:InitSkillSet()
    for k,v in pairs(self.previewList) do
        v:Show()
    end
end

function AutoFarmWindow:setPoint()
    if self.remainText == nil then
        return
    end
    self.remainText.text = string.format("%s/%s",tostring(AgendaManager.Instance.double_point), tostring(AgendaManager.Instance.max_double_point))
end

function AutoFarmWindow:GetPoint()
    AgendaManager.Instance:Require12002()
end

function AutoFarmWindow:FreezPoint()
    AgendaManager.Instance:Require12003()
end

function AutoFarmWindow:InitSkillSet()
    -- local roleFirst = 10000* RoleManager.Instance.RoleData.classes +1
    local role = RoleManager.Instance.RoleData
    local skillList = SkillManager.Instance.model.role_skill
    local cur_petdata = PetManager.Instance.model.battle_petdata
    local currRole = SkillScriptManager.Instance.roleCurrIndex
    local currPet = SkillScriptManager.Instance.PetSet
    local currRoleGroup = SkillScriptManager.Instance.RoleSet[currRole]
    local NormalAtk = CombatUtil.GetNormalSKill(RoleManager.Instance.RoleData.classes)
    if currRoleGroup ~= nil and #currRoleGroup ~= 0 then
        if currRoleGroup[#currRoleGroup].skill_id == 1000 or currRoleGroup[#currRoleGroup].skill_id == 1001 or NormalAtk == currRoleGroup[#currRoleGroup].skill_id then
            if NormalAtk == currRoleGroup[#currRoleGroup].skill_id then

                -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(1000)
                self.roleItemSkillIconLoader:SetSprite(SingleIconType.SkillIcon, 1000)
            else
                -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(tostring(currRoleGroup[#currRoleGroup].skill_id))
                self.roleItemSkillIconLoader:SetSprite(SingleIconType.SkillIcon, currRoleGroup[#currRoleGroup].skill_id)
            end
        else
            local skillData = DataSkill.data_skill_role[currRoleGroup[#currRoleGroup].skill_id.."_1"]
            -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(skillData.icon))
            self.roleItemSkillIconLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
        end
    else
        local roleFirst = CombatUtil.GetFirstSkill(RoleManager.Instance.RoleData.classes)
        -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(roleFirst))
        self.roleItemSkillIconLoader:SetSprite(SingleIconType.SkillIcon, roleFirst)
    end
    self.RoleItembtn.gameObject.transform:Find("Text"):GetComponent(Text).text = SkillScriptManager.Instance:GetGroupName(currRole)
    self.RoleItem.gameObject:SetActive(true)
    if cur_petdata ~= nil then
        if currPet ~= 0 then
            local key = string.format("%s_1", currPet)
            local icondata = DataSkill.data_petSkill[key]
            if currPet == 1000 or currPet == 1001 then
                icondata = {icon = currPet}
            end
            local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(currPet, 1)
            if Gassest ~= "" then
                self.headLoader:SetSprite(SingleIconType.Pet, icondata.icon)
                -- self.PetItem:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(Gassest, icondata.icon)
            else
                -- self.PetItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(icondata.icon)
                self.headLoader:SetSprite(SingleIconType.SkillIcon, icondata.icon)
            end
        else
            local petdata = DataPet.data_pet[cur_petdata.base_id]
            self.headLoader:SetSprite(SingleIconType.Pet,petdata.head_id)
            -- self.PetItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petdata.head_id), tostring(petdata.head_id))
        end
        self.PetItem.gameObject:SetActive(true)
        local key = string.format("%s_1", currPet)
        local basedata = DataSkill.data_petSkill[key]
        local petsetName = ""
        if basedata ~= nil then
            petsetName = basedata.name
        elseif currPet == 1000 then
            petsetName = TI18N("普通攻击")
        elseif currPet == 1001 then
            petsetName = TI18N("防御")
        end

        if petsetName == "" then
            petsetName = TI18N("智能模式")
        end
        self.PetItembtn.gameObject.transform:Find("Text"):GetComponent(Text).text = petsetName
    else
        self.PetItem.gameObject:SetActive(false)
    end

    self.RoleItembtn.onClick:RemoveAllListeners()
    self.RoleItembtn.onClick:AddListener(function() SkillScriptManager.Instance.model:OpenRoleSelectPanel() end)
    self.PetItembtn.onClick:RemoveAllListeners()
    self.PetItembtn.onClick:AddListener(function() SkillScriptManager.Instance.model:OpenPetSelectPanel() end)
end
