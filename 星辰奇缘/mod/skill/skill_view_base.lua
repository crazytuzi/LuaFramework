-- ----------------------------------------------------------
-- UI - 人物技能
-- ----------------------------------------------------------
SkillView_Base = SkillView_Base or BaseClass(BasePanel)

function SkillView_Base:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "SkillView_Base"
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effect = nil
    self.resList = {
        {file = AssetConfig.skill_window_base, type = AssetType.Main}
        , {file = AssetConfig.autofarm_textures, type = AssetType.Dep}
    }

    if RoleManager.Instance.RoleData.lev <= 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Main})
    end

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.container = nil
    self.skillobject = nil
    self.scrollrect = nil

    self.skillitemlist = {}
    self.skillitemiconloaderlist = {}
    self.selectbtn = nil
    self.skilldata = nil
    self.select_skilldata = nil

    self.giftIconList = {}

    self.descIcon = nil
    ------------------------------------------------
    self._updateSkillItem = function()
        self:updateSkillItem()
    end

    self.onLearnFinalSkill = function()
        self:OnLearnFinal()
    end

    self.onupdatefinalskill = function()
        self:OnUpdateFinalSkill()
    end

    self.setred = function()
        self:SetRed()
    end

    self.updateSpeedListener = function() self:UpdateSpeed() end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillView_Base:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.skillitemiconloaderlist) do
        v:DeleteMe()
    end
    self.skillitemiconloaderlist = {}
    if self.uniqueloader ~= nil then
        self.uniqueloader:DeleteMe()
        self.uniqueloader = nil
    end

    if self.uniqueloader2 ~= nil then
        self.uniqueloader2:DeleteMe()
        self.uniqueloader2 = nil
    end

    if self.finalSkillStudyPanel ~= nil then
        self.finalSkillStudyPanel:DeleteMe()
        self.finalSkillStudyPanel = nil
    end

    if self.finalSkillPanel ~= nil then
        self.finalSkillPanel:DeleteMe()
        self.finalSkillPanel = nil
    end

    for k,v in pairs(self.giftIconList) do
        v:DeleteMe()
    end
    self.giftIconList = {}
    self:AssetClearAll()
end

function SkillView_Base:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_window_base))
    self.gameObject.name = "SkillView_Base"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
    self.container = transform:FindChild("SkillBar/mask/Container").gameObject
    self.skillobject = self.container.transform:FindChild("SkillItem").gameObject

    self.scrollrect = transform:FindChild("SkillBar/mask"):GetComponent(ScrollRect)

    self.info_panel = transform:FindChild("InfoPanel").gameObject
    -- 按钮功能绑定

    local btn
    btn = transform:FindChild("InfoPanel/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:okbuttonclick() end)

    self.SetButton = transform:FindChild("InfoPanel/SetButton"):GetComponent(Button)
    self.SetButton.onClick:AddListener(function() SkillScriptManager.Instance.model:OpenEditWindow(1) end)
    self.SetButton.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= 50)

    btn = transform:FindChild("InfoPanel/OneKeyButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onekeybuttonclick() end)
    self.onkeyObj = btn.gameObject

    self.descIcon = transform:FindChild("InfoPanel/DescIcon"):GetComponent(Button)
    self.descIcon.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.descIcon.gameObject
            , itemData = { TI18N("由于你当前技能等级小于世界等级<color='#ffff00'>-5</color>，学习技能消耗降低为原来的<color='#ffff00'>50%</color>") }}) end)

    if RoleManager.Instance.RoleData.lev <= 20 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        if self.effect ~= nil then
            self.effect.name = "GuideEffect"
            local etras = self.effect.transform
            etras:SetParent(self.onkeyObj.transform)
            etras.localScale = Vector3.one
            etras.localPosition = Vector3(0,0,-500)
            Utils.ChangeLayersRecursively(etras, "UI")
            self.effect:SetActive(false)
        end
    end

    self.toggle = transform:Find("InfoPanel/SpeedToggle"):GetComponent(Button)
    self.toggleTick = transform:Find("InfoPanel/SpeedToggle/Tick").gameObject

    self.toggle.onClick:AddListener(function() self:OnSpeed() end)

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function SkillView_Base:OnInitCompleted()
    GuideManager.Instance:OpenWindow(self.parent.windowId)
end

function SkillView_Base:OnShow()
    if self.SetButton ~= nil then
        self.SetButton.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= 50)
    end
    self:addevents()
    self:updateSkillItem()
    GuideManager.Instance:OpenWindow(self.parent.windowId)

    self:ShowGuide()
end

function SkillView_Base:OnHide()
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
    end
     if self.finalSkillStudyPanel ~= nil then
        self.finalSkillStudyPanel:Hiden()
    end
    if self.finalSkillPanel ~= nil then
        self.finalSkillPanel:Hiden()
    end
    self:removeevents()
end

function SkillView_Base:addevents()
    SkillManager.Instance.OnUpdateRoleSkill:Add(self._updateSkillItem)
    SkillManager.Instance.OnUpdateRoleSkill:AddListener(self.updateSpeedListener)
    SkillManager.Instance.OnLearnFinalSkill:AddListener(self.onLearnFinalSkill)
    SkillManager.Instance.OnGetFinalInfo:AddListener(self.onupdatefinalskill)
    SkillManager.Instance.OnUpdateRoleSkill:AddListener(self.setred)
end

function SkillView_Base:removeevents()
    SkillManager.Instance.OnUpdateRoleSkill:Remove(self._updateSkillItem)
    SkillManager.Instance.OnUpdateRoleSkill:RemoveListener(self.updateSpeedListener)
    SkillManager.Instance.OnLearnFinalSkill:RemoveListener(self.onLearnFinalSkill)
    SkillManager.Instance.OnGetFinalInfo:RemoveListener(self.onupdatefinalskill)
    SkillManager.Instance.OnUpdateRoleSkill:RemoveListener(self.setred)
end

-- 更新技能列表 Mark
function SkillView_Base:updateSkillItem()
    local skilllist = self.model.role_skill

    local skillitem
    local skillitemiconloader
    local data

    local roleData = RoleManager.Instance.RoleData


    if self.model.finalSkill ~= nil and self.model.finalSkill.flag == 1 and self.uniqueskillitem == nil then
        local item = GameObject.Instantiate(self.skillobject)
        item:SetActive(true)
        item.transform:SetParent(self.container.transform)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        local fun = function() self:onskillitemclick(item) end
        item:GetComponent(Button).onClick:AddListener(fun)
        self.uniqueskillitem = item
        self.redPoint = item.transform:Find("RedPoint").gameObject
    elseif roleData.lev > 87 and self.uniqueskillitem == nil and self.uniqueskillitem2 == nil then
        local item = GameObject.Instantiate(self.skillobject)
        item:SetActive(true)
        item.transform:SetParent(self.container.transform)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        item:GetComponent(Button).onClick:AddListener(function()
            NoticeManager.Instance:FloatTipsByString(TI18N("完成90级剧情<color='#ffff00'>[职业奥秘]</color>，领悟<color='#00ff00'>职业绝招</color>{face_1,3}"))
            local roledata = RoleManager.Instance.RoleData
            local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,"finalSkillGuide1")
            local str = PlayerPrefs.GetString(key,"never")
            if str ~= "clicked" then
                PlayerPrefs.SetString(key,"clicked")
            end
            self:RefreshRed()
        end)
        item.transform:FindChild("LVText"):GetComponent(Text).text = ""
        item.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("职业绝招")
        item.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("技能未开启")

        local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].id
        local data = DataSkill.data_skill_role[string.format("%s_1", skill)]
        if self.uniqueloader2 == nil then
            self.uniqueloader2 = SingleIconLoader.New(item.transform:FindChild("SkillIcon").gameObject)
        end
        self.uniqueloader2:SetSprite(SingleIconType.SkillIcon, data.icon)
        self.uniqueskillitem2 = item
        self.redPoint = item.transform:Find("RedPoint").gameObject
    end

    if self.uniqueskillitem ~= nil then
        if #self.model.finalSkill.skill_unique > 0 then
            local skill = self.model.finalSkill.skill_unique[1].id
            local lev = self.model.finalSkill.skill_unique[1].lev
            local data = DataSkill.data_skill_role[string.format("%s_%s", skill,lev)]
            local max_lev = RoleManager.Instance.RoleData.lev - 60
            if DataSkillUnique.data_unique_skill[skill] ~= nil and max_lev > DataSkillUnique.data_unique_skill[skill].lev then
                max_lev = DataSkillUnique.data_unique_skill[skill].lev
            end
            self.uniqueskillitem.transform:FindChild("LVText"):GetComponent(Text).text = lev.."/"..max_lev
            self.uniqueskillitem.transform:FindChild("NameText"):GetComponent(Text).text = StringHelper.Split(data.name, "·")[1]
            self.uniqueskillitem.transform:FindChild("DescText"):GetComponent(Text).text = data.about
            if self.uniqueloader == nil then
                self.uniqueloader = SingleIconLoader.New(self.uniqueskillitem.transform:FindChild("SkillIcon").gameObject)
            end
            self.uniqueloader:SetSprite(SingleIconType.SkillIcon, data.icon)
        else
            self.uniqueskillitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            self.uniqueskillitem.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("职业绝招")
            self.uniqueskillitem.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("技能领悟中")
            local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].id
            local data = DataSkill.data_skill_role[string.format("%s_1", skill)]
            if self.uniqueloader == nil then
                self.uniqueloader = SingleIconLoader.New(self.uniqueskillitem.transform:FindChild("SkillIcon").gameObject)
            end
            self.uniqueloader:SetSprite(SingleIconType.SkillIcon, data.icon)
        end
    end

    for i = 1, #skilllist do
        data = skilllist[i]
        skillitem = self.skillitemlist[i]
        skillitemiconloader = self.skillitemiconloaderlist[i]

        if skillitem == nil then
            local item = GameObject.Instantiate(self.skillobject)
            item:SetActive(true)
            item.transform:SetParent(self.container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:onskillitemclick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            self.skillitemlist[i] = item
            skillitem = item

            skillitemiconloader = SingleIconLoader.New(skillitem.transform:FindChild("SkillIcon").gameObject)
            self.skillitemiconloaderlist[i] = skillitemiconloader
        end

        local roleskill
        if data.lev == 0 then
            roleskill = self.model:getroleskilldata(data.id, 1)
            if roleskill ~= nil and not BaseUtils.isnull(skillitem) then
                skillitem.name = tostring(roleskill.id)

                if roleskill.study_lev > roleData.lev then
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("%s级开启"), tostring(roleskill.study_lev))
                    skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.grey
                else
                    local maxLevel = roleData.lev
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = data.lev.."/"..maxLevel
                    skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.white
                end

                -- skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
                --     = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(roleskill.icon))
                skillitemiconloader:SetSprite(SingleIconType.SkillIcon, roleskill.icon)
                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = roleskill.name
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = roleskill.about
            end
        else
            roleskill = self.model:getroleskilldata(data.id, data.lev)
            if roleskill ~= nil and not BaseUtils.isnull(skillitem) then
                skillitem.name = tostring(roleskill.id)

                -- skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(roleskill.icon))
                skillitemiconloader:SetSprite(SingleIconType.SkillIcon, roleskill.icon)
                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = roleskill.name
                local maxLevel = roleData.lev
                if roleData.lev_break_times == 1 and roleData.lev < 100 then 
                    maxLevel = 100
                end
                skillitem.transform:FindChild("LVText"):GetComponent(Text).text = data.lev.."/"..maxLevel
                skillitem.transform:FindChild("LVText"):GetComponent(Text).color = Color(1/255, 125/255, 215/255)
                -- if data.lev >= maxLevel then
                --     skillitem.transform:FindChild("LVText"):GetComponent(Text).color = ColorHelper.colorObject[1]
                -- else
                --     skillitem.transform:FindChild("LVText"):GetComponent(Text).color = ColorHelper.Default
                -- end
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = roleskill.about
            end
        end
        if nil ~= self.skilldata and self.skilldata.id == data.id then self.selectbtn = skillitem end
    end


    for i = #skilllist + 1, #self.skillitemlist do
        skillitem = self.skillitemlist[i]
        skillitem:SetActive(false)
    end

    if #skilllist > 0 then
        if self.selectbtn == nil then
            if self.uniqueskillitem ~= nil then
                self:onskillitemclick(self.uniqueskillitem)
            else
                self:onskillitemclick(self.skillitemlist[1])
            end
        else
            self:onskillitemclick(self.selectbtn)
        end
    end

    self:RefreshRed()
end

-- 选中技能 Mark
function SkillView_Base:onskillitemclick(item)
    self.select_skilldata = self.model:getroleskill(item.name)

    if self.select_skilldata ~= nil then
        if self.select_skilldata.lev == 0 then
            self.skilldata = self.model:getroleskilldata(item.name, 1)
        else
            self.skilldata = self.model:getroleskilldata(item.name, self.select_skilldata.lev)
        end
        self.info_panel:SetActive(true)
        if self.finalSkillStudyPanel ~= nil then
            self.finalSkillStudyPanel:Hiden()
        end
        if self.finalSkillPanel ~= nil then
            self.finalSkillPanel:Hiden()
        end
        self:updateSkill()
    else
        self.skilldata = nil
        self.info_panel:SetActive(false)
        if #self.model.finalSkill.skill_unique > 0 then
            if self.finalSkillPanel == nil then
            -- self.model:OpenFinalSkillPanel(self)
                self.finalSkillPanel = SkillFinalPanel.New(self.model,self)
            end
            self.finalSkillPanel:Show()
            if self.model:checkfinalskillcanup() then
                SkillManager.Instance.finalSkillUp = true
                self:RefreshRed()
            end
        else
            -- self.model:OpenFinalSkillStudyPanel(self)
            if self.finalSkillStudyPanel == nil then
                self.finalSkillStudyPanel = SkillFinalStudyPanel.New(self.model,self)
            end
            self.finalSkillStudyPanel:Show()
            local roledata = RoleManager.Instance.RoleData
            local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,"finalSkillGuide2")
            local str = PlayerPrefs.GetString(key,"never")
            if str ~= "clicked" then
                PlayerPrefs.SetString(key,"clicked")
            end
            self:RefreshRed()
        end
    end

    if self.selectbtn ~= nil then self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    self.selectbtn = item
end

-- 更新技能信息 Mark
function SkillView_Base:updateSkill()
    local skilldata = self.skilldata
    local transform = self.transform

    if nil == skilldata then return end
    local info_panel = transform:FindChild("InfoPanel").gameObject
    info_panel.transform:FindChild("NameText"):GetComponent(Text).text = skilldata.name.."  LV."..skilldata.lev

    info_panel.transform:FindChild("DescText"):GetComponent(Text).text = skilldata.desc

    self:UpdateSpeed()

    local attrstr = "";
    local has_speed_attr = false
    for attrindex = 1, #skilldata.attr do
        local attrdata = skilldata.attr[attrindex]
        if attrindex ~= 1 then attrstr = attrstr.."; " end
        if attrdata.name == 3 and self.speedStatus then
            attrstr = string.format("%s%s%s", attrstr, 0, KvData.GetAttrName(attrdata.name))
        else
            attrstr = string.format("%s%s%s", attrstr, attrdata.val, KvData.GetAttrName(attrdata.name))
        end
        if attrdata.name == 3 then
            has_speed_attr = true
        end
    end

    info_panel.transform:FindChild("AttrsDescText"):GetComponent(Text).text = attrstr
    if attrstr == "" then
        info_panel.transform:FindChild("AttrsDescText_Front").gameObject:SetActive(false)
    else
        info_panel.transform:FindChild("AttrsDescText_Front").gameObject:SetActive(true)
    end

    self.toggle.gameObject:SetActive(has_speed_attr)

    info_panel.transform:FindChild("DescObject1/DescText"):GetComponent(Text).text = skilldata.locate
    info_panel.transform:FindChild("DescObject2/DescText"):GetComponent(Text).text = skilldata.dmg
    info_panel.transform:FindChild("DescObject3/DescText"):GetComponent(Text).text = string.format(TI18N("%s回合"), tostring(skilldata.cooldown))
    info_panel.transform:FindChild("DescObject4/DescText"):GetComponent(Text).text = string.format(TI18N("%s魔法"), tostring(skilldata.cost_mp))

    info_panel.transform:FindChild("DescObject1/DescText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    info_panel.transform:FindChild("DescObject2/DescText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    info_panel.transform:FindChild("DescObject3/DescText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    info_panel.transform:FindChild("DescObject4/DescText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    if skilldata.type == 0 then
        info_panel.transform:FindChild("GiftPanel").gameObject:SetActive(true)

        local talent = self.model:getroleskill_talent(skilldata.id)
        local giftIcon
        for i = 1, 3 do
            local open
            local lev = i
            giftIcon = info_panel.transform:FindChild("GiftPanel/GiftImage"..i).gameObject
            if self.giftIconList[i] == nil then
                self.giftIconList[i] = SingleIconLoader.New(giftIcon.transform:FindChild("GiftImage").gameObject)
            end

            if (i ~= 3 and talent["talent"..i.."_lev"] <= skilldata.lev)
                or (i == 3 and self.model.talent_3[skilldata.id]) then
                giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).color = Color.white
                if i == 3 then
                    giftIcon.transform:FindChild("Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>已激活</color>")

                    -- giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).sprite
                    --     = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(talent["talent"..i.."_icon"]))
                    self.giftIconList[i]:SetSprite(SingleIconType.SkillIcon, talent["talent"..i.."_icon"])
                else
                    giftIcon.transform:FindChild("Text"):GetComponent(Text).text
                        = "<color='#ace92a'>Lv."..talent["talent"..i.."_lev"].."</color>"
                end
                open = true
            else
                -- Utils.setGreyMaterial(giftIcon.transform:FindChild("GiftImage"):GetComponent(Image), true);
                giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).color = Color.grey
                if i == 3 then
                    -- giftIcon.transform:FindChild("Text"):GetComponent(Text).text
                    --     = "<color='#91b1b8'>"..talent["talent"..i.."_cond"].."</color>"
                    giftIcon.transform:FindChild("Text"):GetComponent(Text).text = TI18N("<color='#ff0000'>未激活</color>")

                    -- giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).sprite
                    --     = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(talent["talent"..i.."_icon"]))
                    self.giftIconList[i]:SetSprite(SingleIconType.SkillIcon, talent["talent"..i.."_icon"])
                else
                    giftIcon.transform:FindChild("Text"):GetComponent(Text).text
                        = "<color='#91b1b8'>Lv."..talent["talent"..i.."_lev"].."</color>"
                end
                open = false
            end

            local talentTipsData = { id = talent.id, lev = lev, name = talent["talent"..lev.."_name"], icon = talent["talent"..lev.."_icon"]
                                , desc = talent["talent"..lev.."_desc"], desc2 = talent["talent"..lev.."_desc2"], open = open }
            local btn = giftIcon:GetComponent(Button)
            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = giftIcon, type = Skilltype.roletalent, skillData = talentTipsData}) end)
        end
    else
        info_panel.transform:FindChild("GiftPanel").gameObject:SetActive(false)
    end

    if skilldata.max_lev > skilldata.lev then
        local cost_skilldata
        if self.select_skilldata.lev == 0 then
            cost_skilldata = skilldata
        else
            cost_skilldata = self.model:getroleskilldata(self.select_skilldata.id, self.select_skilldata.lev+1)
        end
        info_panel.transform:FindChild("CostText").gameObject:SetActive(true)

        if #cost_skilldata.cost > 0 then
            if RoleManager.Instance.world_lev - RoleManager.Instance.RoleData.lev >= 10 then
                self.descIcon.gameObject:SetActive(true)
                info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).text = tostring(math.floor(cost_skilldata.cost[1][2] * 0.5))
            else
                self.descIcon.gameObject:SetActive(false)
                info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).text = tostring(cost_skilldata.cost[1][2])
            end
            info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).color = Color.white;
            -- if roleManager.Property.Coin >= cost_skilldata.cost[0].itemNum then
            --     info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).color = Color.white;
            -- else
            --     info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).color = Color.red;
            -- end
            info_panel.transform:FindChild("CostItem").gameObject:SetActive(true)
        else
            info_panel.transform:FindChild("CostItem").gameObject:SetActive(false)
        end
    else
        info_panel.transform:FindChild("CostText").gameObject:SetActive(false)
        info_panel.transform:FindChild("CostItem").gameObject:SetActive(false)
    end
end

function SkillView_Base:okbuttonclick()
    -- print("ui_skill_base.okbuttonclick")
    if 0 == self.select_skilldata.lev then
        local study_lev = self.model:getroleskilldata(self.select_skilldata.id, 1).study_lev
        if study_lev > RoleManager.Instance.RoleData.lev then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s级开启"), study_lev))
            return
        end
    end
    SkillManager.Instance:Send10801(self.select_skilldata.id)
    if GuideManager.Instance.guide ~= nil and GuideManager.Instance.guide.id == 10001 then
        -- 技能引导特殊处理
        GuideManager.Instance:Finish()
    end
end

function SkillView_Base:onekeybuttonclick()
    -- print("ui_skill_base.okbuttonclick")

    -- ui_skill_base.findNewSkill()
    SkillManager.Instance:Send10803()

    -- connection.send(9900, {cmd = "设等级 35"})
    -- connection.send(9900, {cmd = "获取物品 90000 9999999"})
    -- connection.send(9900, {cmd = "获取物品 90001 9999999"})
    -- connection.send(9900, {cmd = "获取物品 90002 9999999"})
    -- connection.send(9900, {cmd = "获取物品 90003 9999999"})
end

function SkillView_Base:findNewSkill()
    self.newskillid = 10005

    if 0 == self.newskillid then return end

    local newskillobject
    for i = 1, #self.skillitemlist do
        if tonumber(self.skillitemlist[i].name) == self.newskillid then
            -- print("newskillid "..newskillid)
            newskillobject = self.skillitemlist[i].gameObject
            local newskill_rect = newskillobject.transform:GetComponent(RectTransform)
            local ty = -(newskill_rect.rect.height / 2) - newskill_rect.anchoredPosition.y
            if ty > (newskill_rect.rect.height / 2) then
                ty = ty - (newskill_rect.rect.height / 2)
            else
                ty = 0
            end
            newskillobject.transform.parent:GetComponent(RectTransform).anchoredPosition
                = Vector2(newskillobject.transform.parent:GetComponent(RectTransform).anchoredPosition.x, ty)

            self:onskillitemclick(newskillobject)
        end
    end
    newskillid = 0
end

function SkillView_Base:CheckGuideOneKey()
    local quest = QuestManager.Instance:GetQuest(10170)
    if quest ~= nil and quest.finish == 1 then
        return true
    end

    local quest1 = QuestManager.Instance:GetQuest(22170)
    if quest1 ~= nil and quest1.finish == 1 then
        return true
    end
    return false
end

function SkillView_Base:ShowGuide()
    if self:CheckGuideOneKey() then
        if not BaseUtils.is_null(self.effect) then
            self.effect:SetActive(true)
            TipsManager.Instance:ShowGuide({gameObject = self.onkeyObj, data = TI18N("点这里<color='#ffff00'>升级所有技能等级</color>"), forward = TipsEumn.Forward.Left})
        end
    end
end

function SkillView_Base:UpdateSpeed()
    self.speedStatus = false
    for _,v in pairs(self.model.no_speed_list) do
        if v.skill_id == self.select_skilldata.id then
            self.speedStatus = true
        end
    end
    self.toggleTick:SetActive(self.speedStatus)
end

function SkillView_Base:OnSpeed()
    if self.speedStatus then
        SkillManager.Instance:Send10824(self.select_skilldata.id, 0)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("该操作将会屏蔽技能加成的攻速，该操作适用于<color='#ffff00'>龟速流派</color>，是否继续（再次勾选可恢复）？")
        confirmData.sureCallback = function() SkillManager.Instance:Send10824(self.select_skilldata.id, 1) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function SkillView_Base:OnLearnFinal()
    if self.model.finalSkillStudyPanel ~= nil then
        self.model.finalSkillStudyPanel:Hiden()
    end
    local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].id
    local data = DataSkill.data_skill_role[string.format("%s_1", skill)]
    local max_lev = RoleManager.Instance.RoleData.lev - 60
    if DataSkillUnique.data_unique_skill[skill] ~= nil and max_lev > DataSkillUnique.data_unique_skill[skill].lev then
        max_lev = DataSkillUnique.data_unique_skill[skill].lev
    end
    self.uniqueskillitem.transform:FindChild("LVText"):GetComponent(Text).text = "1/"..max_lev
    self.uniqueskillitem.transform:FindChild("NameText"):GetComponent(Text).text = StringHelper.Split(data.name, "·")[1]
    self.uniqueskillitem.transform:FindChild("DescText"):GetComponent(Text).text = data.about
    -- self.model:OpenFinalSkillPanel(self)
    if self.finalSkillPanel == nil then
        self.finalSkillPanel = SkillFinalPanel.New(self.model,self)
    end
    self.finalSkillPanel:Show()
end

function SkillView_Base:OnUpdateFinalSkill( )
    if self.uniqueskillitem ~= nil then
        if #self.model.finalSkill.skill_unique > 0 then
            local lev = self.model.finalSkill.skill_unique[1].lev
            local skill = self.model.finalSkill.skill_unique[1].id
            local max_lev = RoleManager.Instance.RoleData.lev - 60
            if DataSkillUnique.data_unique_skill[skill] ~= nil and max_lev > DataSkillUnique.data_unique_skill[skill].lev then
                max_lev = DataSkillUnique.data_unique_skill[skill].lev
            end
            self.uniqueskillitem.transform:FindChild("LVText"):GetComponent(Text).text = lev.."/"..max_lev
        end
    end
end

function SkillView_Base:SetRed()
    local t = self.model.finalskillred
    if self.uniqueskillitem ~= nil or self.uniqueskillitem2 ~= nil then
        self.redPoint:SetActive(t)
    end
end


function SkillView_Base:RefreshRed()
    local state = self.model:check_show_redpoint()
    MainUIManager.Instance.OnUpdateIcon:Fire(3, state)
    self.model.window:update_roleskill()
    self:SetRed()
end