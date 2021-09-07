-- 战斗UI 头像部分
-- 2016-5-24 怒气技能扩充 huangzefeng
CombatHeadinfoPanel = CombatHeadinfoPanel or BaseClass()

function CombatHeadinfoPanel:__init(file, mainPanel)
    self.file = file
    self.ischild = false
    self.mainPanel = mainPanel

    self.adaptListener = function() self:AdaptIPhoneX() end
    self:InitPanel()
    self.headLoaderList = {}
end

function CombatHeadinfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform
    self.combatMgr = CombatManager.Instance
    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.accountInfo = RoleManager.Instance.RoleData

    self.roleLevText = nil
    self.roleHpImage = nil
    self.roleMpImage = nil

    self.roleLevText = self.transform:FindChild("RoleHeadInfoBg"):FindChild("RoleLevText"):GetComponent(Text)
    self.roleHpImage = self.transform:FindChild("RoleHeadInfoBg"):FindChild("RoleHpBarImage").gameObject
    self.roletmpHpImage = self.transform:FindChild("RoleHeadInfoBg"):FindChild("RoletmpHpBarImage").gameObject
    self.roleMpImage = self.transform:FindChild("RoleHeadInfoBg"):FindChild("RoleMpBarImage").gameObject
    self.roleExpImage = self.transform:FindChild("RoleHeadInfoBg"):FindChild("SpBar").gameObject
    -- self.roleExpImage:GetComponent(Image).sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.combat_texture, "ExpBar")
    self.SpNumText = self.transform:Find("RoleHeadInfoBg/SpNumPanel/Current"):GetComponent(Text)

    self.buffPanel = self.transform:Find("RoleHeadInfoBg/BuffsArea")
    self.buffPanel:GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.buffpanel)
    end)
    self.buffIcon1 = self.buffPanel.transform:FindChild("buff1").gameObject
    self.buffIcon2 = self.buffPanel.transform:FindChild("buff2").gameObject
    self.buffIcon3 = self.buffPanel.transform:FindChild("buff3").gameObject
    self.buffIconImage1 = self.buffIcon1.transform:FindChild("Image"):GetComponent(Image)
    self.buffIconImage2 = self.buffIcon2.transform:FindChild("Image"):GetComponent(Image)
    self.buffIconImage3 = self.buffIcon3.transform:FindChild("Image"):GetComponent(Image)
    self.buffArrow = self.buffPanel.transform:FindChild("arrow").gameObject

    self.RoleHeadInfoBg = self.transform:FindChild("RoleHeadInfoBg").gameObject
    self.PetHeadInfoBg = self.transform:FindChild ("PetHeadInfoBg").gameObject;

    self.RoleHpNumPanel = self.RoleHeadInfoBg.transform:FindChild ("HpNumPanel").gameObject;
    self.RoleMpNumPanel = self.RoleHeadInfoBg.transform:FindChild ("MpNumPanel").gameObject

    self.PetHpNumPanel = self.PetHeadInfoBg.transform:FindChild ("HpNumPanel").gameObject;
    self.PetMpNumPanel = self.PetHeadInfoBg.transform:FindChild ("MpNumPanel").gameObject;
    self.PetHpBarImage = self.PetHeadInfoBg.transform:FindChild ("HpBarImage").gameObject;
    self.PettmpHpBarImage = self.PetHeadInfoBg.transform:FindChild ("tmpHpBarImage").gameObject;
    self.PetMpBarImage = self.PetHeadInfoBg.transform:FindChild ("MpBarImage").gameObject;
    self.PetExpBarImage = self.PetHeadInfoBg.transform:FindChild ("ExpBar").gameObject;
    self.PetLevText = self.PetHeadInfoBg.transform:FindChild ("PetLevText").gameObject;

    self.roleImage = self.RoleHeadInfoBg.transform:FindChild ("RoleHeadImage/Image").gameObject;
    self.roleImage:SetActive(false)
    self.petImage = self.PetHeadInfoBg.transform:FindChild ("PetHeadImage/Image").gameObject

    self.roleImage.transform:GetComponent(Button).onClick:AddListener(function() self:ShowFighterInfo("role") end);
    self.petImage.transform:GetComponent(Button).onClick:AddListener(function() self:ShowFighterInfo("pet") end);
    self.PetHeadInfoBg:AddComponent(Button).onClick:AddListener(function() self:ShowFighterInfo("pet") end)
    self.buffPanel.gameObject:SetActive(true)

    self.RoleCurrHpText = self.RoleHpNumPanel.transform:Find("Current"):GetComponent(Text)
    self.RoleCurrMpText = self.RoleMpNumPanel.transform:Find("Current"):GetComponent(Text)
    self.PetCurrHpText = self.PetHpNumPanel.transform:Find("Current"):GetComponent(Text)
    self.PetCurrMpText = self.PetMpNumPanel.transform:Find("Current"):GetComponent(Text)

    self.RoleFaceImg = self.RoleHeadInfoBg.transform:FindChild("RoleHeadImage/Image"):GetComponent(Image)
    self.PetFaceImg = self.PetHeadInfoBg.transform:FindChild("PetHeadImage/Image"):GetComponent(Image)

    -- self.PetHpNumPanel:SetActive(false)
    -- self.PetMpNumPanel:SetActive(false)
    -- self.PetHpBarImage:SetActive(false)
    -- self.PetMpBarImage:SetActive(false)
    -- self.PetExpBarImage:SetActive(false)
    -- self.PetLevText:SetActive(false)
    -- self.petImage:SetActive(false)
    self.roleImage.transform.sizeDelta = Vector2(62,62)
    self.headSlot = HeadSlot.New()
    self.headSlot:SetRectParent(self.roleImage.transform)

    self:ClearPetInfo()
    self.PetHeadInfoBg:SetActive(true)

    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    self:AdaptIPhoneX()
end

function CombatHeadinfoPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoader2 ~= nil then
        self.headLoader2:DeleteMe()
        self.headLoader2 = nil
    end


    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    BaseUtils.CancelIPhoneXTween(self.transform)
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatHeadinfoPanel:Show()
    self:ClearPetInfo()
end

function CombatHeadinfoPanel:UpdateRoleInfo(data)
    local _data = BaseUtils.copytab(data)
    if self.combatMgr.isWatching then
        _data.hpMax = self.accountInfo.hp_max
        _data.mpMax = self.accountInfo.mp_max
        _data.hp = self.accountInfo.hp_max
        _data.mp = self.accountInfo.mp_max
    end
    self:UpdateHp(self.roleHpImage, _data)
    self:UpdateTmpHp(self.roletmpHpImage, _data)
    self:UpdateMp(self.roleMpImage, _data)
    self:SetRoleBar(_data)
    self:UpdateExp(self.roleExpImage, "Role", self.mainPanel.controller.enterData)
    self:update_buff()
    -- if self.mainPanel.controller.selfPetData == nil then
        -- self.PetHeadInfoBg:SetActive(false)
    -- end
end

function CombatHeadinfoPanel:UpdatePetInfo(data)
    if self.combatMgr.isWatching then
        if PetManager.Instance.model.battle_petdata ~= nil then
            data.hpMax = PetManager.Instance.model.battle_petdata.hp_max
            data.mpMax = PetManager.Instance.model.battle_petdata.mp_max
            data.hp = PetManager.Instance.model.battle_petdata.hp_max
            data.mp = PetManager.Instance.model.battle_petdata.mp_max
        end
    end
    self.PetHeadInfoBg:SetActive(true)
    self:UpdateHp(self.PetHpBarImage, data)
    self:UpdateTmpHp(self.PettmpHpBarImage, data)
    self:UpdateMp(self.PetMpBarImage, data)
    self:UpdateExp(self.PetExpBarImage, "Pet", data)
    if self.PetHpNumPanel.activeSelf == false then
        self.PetHpNumPanel:SetActive(true)
        self.PetMpNumPanel:SetActive(true)
        self.PetHpBarImage:SetActive(true)
        self.PetMpBarImage:SetActive(true)
        self.PetExpBarImage:SetActive(true)
        self.PetLevText:SetActive(true)
        self.petImage:SetActive(true)
    end
    self:SetPetBar(data)
end

function CombatHeadinfoPanel:UpdateHp(fighterBar, data)
    if data ~= nil then
        local hpMax = data.hp_max
        local hp = data.hp
        if self.combatMgr.isWatching then
            hp = hpMax
        end
        local hpx = hp / hpMax
        if hpx > 1 then
            hpx = 1
        elseif hpx < 0 then
            hpx = 0
        end
        fighterBar.transform.localScale = Vector3(hpx, 1, 1)
    end
end

function CombatHeadinfoPanel:UpdateMp(fighterBar, data)
    if data ~= nil then
        local mpMax = data.mp_max
        local mp = data.mp
        if self.combatMgr.isWatching then
            mp = mpMax
        end
        if mpMax == 0 then
            if mp <= 0 then
                mpMax = 1
            else
                mpMax = mp
            end
        end
        local mpx = mp / mpMax
        if mpx > 1 then
            mpx = 1
        elseif mpx < 0 then
            mpx = 0
        end
        fighterBar.transform.localScale = Vector3(mpx, 1, 1)
    -- print("mp = " .. tostring(mp))
    end
end

function CombatHeadinfoPanel:UpdateExp(fighterBar, type, rdata)
    if type == "Role" then
        local roleData = rdata
        if roleData == nil then return end
        if self.combatMgr.isWatching then
            roleData.anger = 0
            roleData.energy = 0
        end
        local max_anger = CombatManager.Instance.MaxAnger
        local tovalue = roleData.anger / max_anger
        tovalue = math.min(tovalue, 1)
        fighterBar.transform:GetComponent(Image).color = Color(1,1-0.44*tovalue,1-0.59*tovalue)
        fighterBar.transform.sizeDelta = Vector2(87*tovalue, 12)
        self.SpNumText.text = tostring(roleData.anger)
        -- fighterBar.transform:GetComponent(Image).color = Color(0.2, 1, 0)
        -- local roleData = RoleManager.Instance.RoleData
        -- if roleData == nil then return end
        -- local max_exp = DataLevup.data_levup[roleData.lev].exp
        -- local tovalue = roleData.exp/max_exp
        -- fighterBar.transform.sizeDelta = Vector2(87*tovalue, 12)
    elseif type == "Pet" then
        local data = PetManager.Instance.model.battle_petdata
        if rdata.type == FighterType.Child then
            for k, v in ipairs(rdata.looks) do
                if v.looks_type == SceneConstData.looktype_child_id then
                    local child_data = ChildrenManager.Instance:GetChild(v.looks_mode, v.looks_str, v.looks_val)
                    if child_data ~= nil then
                        local expX = child_data.hungry / 100
                        if expX > 1 then
                            expX = 1
                        elseif expX < 0 then
                            expX = 0
                        end
                        expX = math.min(expX, 1)
                        fighterBar.transform.sizeDelta = Vector2(expX*64, 12)
                    end
                end
            end
        else
            if data == nil then

            else
                local expX = data.exp / data.max_exp
                if expX > 1 then
                    expX = 1
                elseif expX < 0 then
                    expX = 0
                end
                expX = math.min(expX, 1)
                fighterBar.transform.sizeDelta = Vector2(expX*64, 12)
            end
        end
    end
end


function CombatHeadinfoPanel:UpdateTmpHp(fighterBar, data)
    if data ~= nil and data.tmp_hp_max ~= nil then
        local hpMax = data.hp_max
        local tmphp = data.tmp_hp_max
        if self.combatMgr.isWatching then
            tmphp = hpMax
        end
        local hpx = (hpMax - tmphp) / hpMax
        if hpx > 0.5 then
            hpx = 0.5
        elseif hpx < 0 then
            hpx = 0
        end
        fighterBar.transform.localScale = Vector3(hpx, 1, 1)
    end
end

function CombatHeadinfoPanel:SetRoleBar (data)
    local hp = data.hp
    local hpMax = data.hp_max
    local mp = data.mp
    local mpMax = data.mp_max
    local lev = data.lev
    if self.combatMgr.isWatching then
        hpMax = self.accountInfo.hp_max
        mpMax = self.accountInfo.mp_max
        hp = hpMax
        mp = mpMax
        lev = self.accountInfo.lev
    end
    self.roleLevText.text = tostring(lev)
    self.RoleCurrHpText.text = tostring(hp)
    self.RoleCurrMpText.text = tostring(mp)
end

function CombatHeadinfoPanel:SetPetBar (data)
    local hp = data.hp
    local hpMax = data.hp_max
    local mp = data.mp
    local mpMax = data.mp_max
    local lev = data.lev
    if self.combatMgr.isWatching then
        if PetManager.Instance.model.battle_petdata ~= nil then
            hpMax = PetManager.Instance.model.battle_petdata.hp_max
            mpMax = PetManager.Instance.model.battle_petdata.mp_max
            hp = hpMax
            mp = mpMax
            lev = PetManager.Instance.model.battle_petdata.lev ~= nil and PetManager.Instance.model.battle_petdata.lev or 0
        else
            self:ClearPetInfo()
        end
    end
    self.PetLevText:GetComponent(Text).text = tostring(lev)
    self.PetCurrHpText.text = tostring(hp)
    self.PetCurrMpText.text = tostring(mp)
end

function CombatHeadinfoPanel:SetRoleFace(data)
    -- local name = self.accountInfo.classes .. "_" .. self.accountInfo.sex
    -- local name = data.classes .. "_" .. data.sex
    -- local sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.heads, name)
    -- if sprite ~= nil then
    --     self.RoleFaceImg.sprite = sprite
    --     self.roleImage:SetActive(true)
    -- end
    self.roleImage.gameObject:SetActive(true)
    self.RoleFaceImg.enabled = false
    self.headSlot:HideSlotBg(true, 0)

    local dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
    if self.combatMgr.isWatching then
        dat = {id = self.accountInfo.id, platform = self.accountInfo.platform, zone_id = self.accountInfo.zone_id, classes = self.accountInfo.classes, sex = self.accountInfo.sex}
    end
    self.headSlot:SetAll(dat, {isSmall = true, clickCallback = function() self:ShowFighterInfo("role") end})
end

function CombatHeadinfoPanel:SetPetFace(data)
    local BaseData = DataPet.data_pet[data.base_id]
    local showChild = (data.type == FighterType.Child)
    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.PetFaceImg.gameObject)
    end
    self.ischild = false
    if data.type == FighterType.Child then
        BaseData = DataChild.data_child[data.base_id]
        self.ischild = true
    end
    if self.combatMgr.isWatching then
        showChild = false
        local mydata = PetManager.Instance.model.battle_petdata
        if mydata == nil or mydata.base_id == nil then
            BaseData = nil
        else
            BaseData = DataPet.data_pet[mydata.base_id]
        end
    end
    if BaseData ~= nil then
        local assestpath = ""
        local iconid = ""
        if data.type == FighterType.Child then
            assestpath = AssetConfig.childhead
            iconid = tostring(BaseData.head_id)
        else
            assestpath = BaseUtils.PetHeadPath(BaseData.head_id)
            iconid = tostring(BaseData.head_id)
        end
        -- local sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.PetHeadPath(BaseData.head_id), tostring(BaseData.head_id))
        -- if data.type == FighterType.Child then
        --     sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.childhead, tostring(BaseData.head_id))
        -- end
        -- if sprite ~= nil then
        if showChild then
            self.headLoader:SetOtherSprite(CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.childhead, tostring(BaseData.head_id)))
        else
            self.headLoader:SetSprite(SingleIconType.Pet,BaseData.head_id)
        end
        -- self.PetFaceImg.sprite = sprite
        -- end
    else
        self:ClearPetInfo()
    end
end

function CombatHeadinfoPanel:ShowFighterInfo(type)
    if type == "role" then
        -- windows.open_window(windows.panel.backpack, {tab_id = 1, panel1 = 1, panel2 = 5})
        -- ui_backpack.options = {0, 1, 5}
        -- windows.open_window(WindowConfig.WinID.backpack)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {1,2})
    else
        if self.ischild then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4})
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1})
        end
    end
end


function CombatHeadinfoPanel:update_buff()
    if CombatManager.Instance.assetWrapper == nil then
        return
    end
    local list = {}
    local sBuff = {}
    sBuff.id = 100000            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.start_time = 0        --开始时间
    sBuff.dynamic_attr = nil    --动态属性
    DataBuff.data_list[100000] = {id=100000,name = TI18N("怒气值"),icon = 21003,desc = TI18N("受到攻击或使用道具可以提升，用于使用觉醒技能")}
    table.insert(list, sBuff)
    for k,v in pairs(BuffPanelManager.Instance.model.buffDic) do
        if v.id < 90000 then table.insert(list, v) end
    end

    if SatiationManager:IsHunger() then
        self.buffIconImage1.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hunger")
    else
        self.buffIconImage1.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hungernot")
    end
    self.buffIcon1:SetActive(true)

    if RoleManager.Instance.RoleData.lev < 15 then --小于15级时显示两个Buff
        self.buffArrow:SetActive(#list>2)

        if list[1] ~= nil then
            local buffinfo = DataBuff.data_list[list[1].id]
            self.buffIconImage2.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
            self.buffIcon2:SetActive(true)
        else
            self.buffIcon2:SetActive(false)
        end

        if list[2] ~= nil then
            local buffinfo = DataBuff.data_list[list[2].id]
            self.buffIconImage3.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
            self.buffIcon3:SetActive(true)
        else
            self.buffIcon3:SetActive(false)
        end
    else  --大于等于15级时显示一个双倍点数一个Buff
        self.buffArrow:SetActive(#list>1)

        if AgendaManager.Instance.double_point == 0 then
            self.buffIconImage2.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
        else
            self.buffIconImage2.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
        end
        self.buffIcon2:SetActive(true)

        if list[1] ~= nil then
            local buffinfo = DataBuff.data_list[list[1].id]
            self.buffIconImage3.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
            self.buffIcon3:SetActive(true)
        else
            self.buffIcon3:SetActive(false)
        end
    end
    -- if AgendaManager.Instance.double_point > 0 then
    --     -- 有双倍点数出现3个固定图标，其它buff个数大于0显示箭头
    --     self.buffArrow:SetActive(#list>0)
    --     self.buffIconImage2.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
    --     self.buffIconImage2.color = Color.white
    --     self.buffIcon2:SetActive(true)
    --     self.buffIconImage3.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "12004")
    --     if hasdiaowen then
    --         self.buffIconImage3.color = Color.white
    --     else
    --         self.buffIconImage3.color = Color(0.4,0.4,0.4)
    --     end
    --     self.buffIcon3:SetActive(true)
    -- else
    --     -- 有双倍点数出现2个固定图标，其它buff个数大于1显示箭头
    --     self.buffArrow:SetActive(#list>1)
    --     self.buffIconImage2.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, "12004")
    --     if hasdiaowen then
    --         self.buffIconImage2.color = Color.white
    --     else
    --         self.buffIconImage2.color = Color(0.4,0.4,0.4)
    --     end
    --     self.buffIcon2:SetActive(true)
    --     if list[1] ~= nil then
    --         local buffinfo = DataBuff.data_list[list[1].id]
    --         self.buffIconImage3.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
    --         self.buffIcon3:SetActive(true)
    --         self.buffIconImage3.color = Color.white
    --     else
    --         self.buffIcon3:SetActive(false)
    --     end
    -- end
end

function CombatHeadinfoPanel:ClearPetInfo()
    self.ischild = false
    self.PetHpNumPanel:SetActive(false)
    self.PetMpNumPanel:SetActive(false)
    self.PetHpBarImage:SetActive(false)
    self.PetMpBarImage:SetActive(false)
    self.PetExpBarImage:SetActive(false)
    self.PetLevText:SetActive(false)
    self.petImage:SetActive(false)
    local face = self.PetHeadInfoBg.transform:FindChild("PetHeadImage/Image"):GetComponent(Image)
    if self.headLoader2 == nil then
        self.headLoader2 = SingleIconLoader.New(face.gameObject)
    end
    self.headLoader2:SetSprite(SingleIconType.Pet, 10099)

    -- local sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.PetHeadPath(10099), "10099")

    -- if sprite ~= nil then
    --     face.sprite = sprite
    -- end
end

function CombatHeadinfoPanel:AdaptIPhoneX()
    if self.mainPanel.InitFinish then
        -- if MainUIManager.Instance.adaptIPhoneX then
        --     self.transform.offsetMax = Vector2(-10, -5)
        --     self.transform.offsetMin = Vector2.zero
        -- else
        --     self.transform.offsetMax = Vector2.zero
        --     self.transform.offsetMin = Vector2.zero
        -- end
        BaseUtils.AdaptIPhoneX(self.transform)
    end
end

