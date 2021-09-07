-- 辅助技能
-- @LJH
-- 20160517
SkillView_Assist = SkillView_Assist or BaseClass(BasePanel)

function SkillView_Assist:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "SkillView_Assist"
    self.resList = {
        {file = AssetConfig.skill_assist, type = AssetType.Main}
        , {file = AssetConfig.skill_life_icon, type = AssetType.Dep}
        , {file = AssetConfig.skill_life_name, type = AssetType.Dep}
        , {file = AssetConfig.skill_life_shovel_bg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.container = nil
    self.skillobject = nil
    self.scrollrect = nil

    self.skillitemlist = {}
    self.selectbtn = nil
    self.skilldata = nil
    self.select_skilldata = nil

    self.button = nil

    self.descIcon = nil

    self.more_show = false
    self.l_item_list = {}
    self.l_item_slots = {}
    self.more_item_slots = {}
    self.skillitemloaderlist = {}
    self.last_exp = nil
    self.lossGuild = false   --记录公会贡献够不够（false 足够）
    self.lossGuildTen = false   --记录公会贡献够不够（10连抽哟）（false 足够）
    ------------------------------------------------
    self._updateSkillItem = function()
        self:updateSkillItem()
    end

    self.updateItemListener = function() self:updateSkill_Life() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillView_Assist:__delete()
    self.OnHideEvent:Fire()

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.info_panel_iconloader ~= nil then
        self.info_panel_iconloader:DeleteMe()
        self.info_panel_iconloader = nil
    end

    for k, v in pairs(self.skillitemloaderlist) do
        v:DeleteMe()
        v = nil
    end

    for k, v in pairs(self.l_item_slots) do
        v:DeleteMe()
        v = nil
    end

    for k, v in pairs(self.more_item_slots) do
        v:DeleteMe()
        v = nil
    end

    if self.Item3_Slot1 ~= nil then
        self.Item3_Slot1:DeleteMe()
        self.Item3_Slot1 = nil
    end
end

function SkillView_Assist:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_assist))
    self.gameObject.name = "SkillView_Assist"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
    self.container = transform:FindChild("SkillBar/mask/Container").gameObject
    self.skillobject = self.container.transform:FindChild("SkillItem").gameObject

    self.scrollrect = transform:FindChild("SkillBar/mask"):GetComponent(ScrollRect)

    self.marryInfoPanel = transform:FindChild("MarryInfoPanel").gameObject
    self.lifeInfoPanel = transform:FindChild("LifeInfoPanel").gameObject
    self.info_panel_iconloader = SingleIconLoader.New(self.marryInfoPanel.transform:FindChild("Icon").gameObject)

    -- 按钮功能绑定
    self.button = self.marryInfoPanel.transform:FindChild("OkButton"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:okbuttonclick() end)

	-- local btn
    -- btn = transform:FindChild("InfoPanel/OneKeyButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:onekeybuttonclick() end)

    -- self.descIcon = transform:FindChild("InfoPanel/DescIcon"):GetComponent(Button)
    -- self.descIcon.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.descIcon.gameObject
    --         , itemData = { TI18N("由于你当前技能等级小于服务器等级-10，学习技能消耗降低为原来的70%") }}) end)
    self.TopCon = self.lifeInfoPanel.transform:FindChild("TopCon").gameObject
    self.ConDesc = self.TopCon.transform:FindChild("ConDesc").gameObject
    self.ConDesc_txt_1 = self.ConDesc.transform:FindChild("TxtVal1"):GetComponent(Text)
    self.ConDesc_txt_2 = self.ConDesc.transform:FindChild("TxtVal2"):GetComponent(Text)

    self.Exp = self.TopCon.transform:FindChild("Exp").gameObject
    self.ExpSlider = self.Exp.transform:FindChild("ExpSlider"):GetComponent(Slider)
    self.ExpText = self.Exp.transform:FindChild("ExpText"):GetComponent(Text)

    self.ConItems = self.TopCon.transform:FindChild("ConItems").gameObject
    self.ConItems_Bg = self.ConItems.transform:FindChild("Bg").gameObject
    self.ConItems_TipsText = self.ConItems.transform:FindChild("TipsText").gameObject
    self.LayoutLayer = self.ConItems.transform:FindChild("LayoutLayer").gameObject
    self.l_Item1 = self.LayoutLayer.transform:FindChild("Item1").gameObject
    self.l_Item2 = self.LayoutLayer.transform:FindChild("Item2").gameObject
    self.l_Item3 = self.LayoutLayer.transform:FindChild("Item3").gameObject
    self.l_Item4 = self.LayoutLayer.transform:FindChild("Item4").gameObject
    -- self.l_Item5 = self.LayoutLayer.transform:FindChild("Item5").gameObject
    -- self.l_Item6 = self.LayoutLayer.transform:FindChild("Item6").gameObject
    -- self.l_Item7 = self.LayoutLayer.transform:FindChild("Item7").gameObject
    -- self.l_Item8 = self.LayoutLayer.transform:FindChild("Item8").gameObject
    -- self.l_Item9 = self.LayoutLayer.transform:FindChild("Item9").gameObject
    self.ItemBtn = self.LayoutLayer.transform:FindChild("ItemBtn"):GetComponent(Button)
    self.l_item_list = {}
    table.insert(self.l_item_list, self.l_Item1)
    table.insert(self.l_item_list, self.l_Item2)
    table.insert(self.l_item_list, self.l_Item3)
    table.insert(self.l_item_list, self.l_Item4)
    -- table.insert(self.l_item_list, self.l_Item5)
    -- table.insert(self.l_item_list, self.l_Item6)
    -- table.insert(self.l_item_list, self.l_Item7)
    -- table.insert(self.l_item_list, self.l_Item8)
    -- table.insert(self.l_item_list, self.l_Item9)
    self.l_item_slots = {}
    self.more_item_slots = {}

    self.ConMore = self.TopCon.transform:FindChild("ConMore").gameObject
    self.ConMore_line = self.ConMore.transform:FindChild("LineCon").gameObject
    self.ConMore_item = self.ConMore_line.transform:FindChild("Item").gameObject
    self.ConMore:SetActive(false)
    self.Item1 = self.TopCon.transform:FindChild("Item1").gameObject
    self.ImgTxtVal =  self.Item1.transform:FindChild("ImgTxtVal").gameObject
    self.TxtVal =self.ImgTxtVal.transform:FindChild("TxtVal"):GetComponent(Text)
    self.Item2 = self.TopCon.transform:FindChild("Item2").gameObject
    self.ImgTxtVal2 = self.Item2.transform:FindChild("ImgTxtVal").gameObject
    self.ImgTanHao = self.Item2.transform:FindChild("ImgTanHao"):GetComponent(Button)

    self.ImgTanHao.onClick:AddListener(function() self:on_click_tanhao() end)

    self.Item3 = self.TopCon.transform:FindChild("Item3").gameObject
    self.Item3_SlotCon1 = self.Item3.transform:FindChild("SlotCon1").gameObject
    self.Item3_Slot1 = self:create_slot(self.Item3_SlotCon1)
    self.TxtVal2 = self.ImgTxtVal2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.ImgShovel = self.TopCon.transform:FindChild("ImgShovel"):GetComponent(Image)

    self.ImgShovel.gameObject:SetActive(false)
    self.Item3:SetActive(false)

    self.BtnStudy = self.lifeInfoPanel.transform:FindChild("BtnCon"):FindChild("BtnStudy"):GetComponent(Button)
    self.BtnOneKey = self.lifeInfoPanel.transform:FindChild("BtnCon"):FindChild("BtnOneKey"):GetComponent(Button)
    self.BtnProduce = self.lifeInfoPanel.transform:FindChild("BtnCon"):FindChild("BtnProduce"):GetComponent(Button)
    self.BtnProduce_txt = self.BtnProduce.transform:FindChild("Text"):GetComponent(Text)
    self.BtnProduce_ImgNormal = self.BtnProduce.transform:FindChild("ImgNormal"):GetComponent(Image)
    self.BtnProduce_ImgGrey = self.BtnProduce.transform:FindChild("ImgGrey"):GetComponent(Image)
    self.BtnProduce_button = self.BtnProduce.transform:GetComponent(Button)


    self.BtnProduce.onClick:AddListener(function() self:on_click_produce_btn() end) --BtnRest
    self.ItemBtn.onClick:AddListener(function() self:on_show_more_items() end)
    self.BtnStudy.onClick:AddListener(function() self:on_click_study_btn() end) --BtnRest
    self.BtnOneKey.onClick:AddListener(function() self:on_click_onekey_study_btn() end)
    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function SkillView_Assist:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        self.selectskillid = self.openArgs[2]
    end
    self.lossGuild = false
    self.lossGuildTen = false
    self:addevents()
    self:updateSkillItem()
end

function SkillView_Assist:OnHide()
    self:removeevents()
end

function SkillView_Assist:addevents()
    SkillManager.Instance.OnUpdateMarrySkill:Add(self._updateSkillItem)
    EventMgr.Instance:AddListener(event_name.life_skill_update, self._updateSkillItem)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateItemListener)
end

function SkillView_Assist:removeevents()
    SkillManager.Instance.OnUpdateMarrySkill:Remove(self._updateSkillItem)
    EventMgr.Instance:RemoveListener(event_name.life_skill_update, self._updateSkillItem)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateItemListener)
end

-- 更新技能列表 Mark
function SkillView_Assist:updateSkillItem()
	local skilllist = {}

    for _,value in ipairs(self.model.life_skills) do
        if value.id == 10008 then
            skilllist[1] = {data = value, type = 1}
        elseif value.id == 10009 then
            skilllist[2] = {data = value, type = 1}
        end
    end

    if RoleManager.Instance.RoleData.wedding_status == 3 then
        for _,value in ipairs(self.model.marry_skill) do
            table.insert(skilllist, {data = value, type = 2})
        end
    end

    local skillitem
    local data
    local type
    for i = 1, #skilllist do
        skillitem = self.skillitemlist[i]
        data = skilllist[i].data
        type = skilllist[i].type

        if skillitem == nil then
            local item = GameObject.Instantiate(self.skillobject)
            item:SetActive(true)
            item.transform:SetParent(self.container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:onskillitemclick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            self.skillitemlist[i] = item
            skillitem = item
        end

        self:setskillitem(skillitem, data, type, i)

        if nil ~= self.skilldata and self.skilldata.id == data.id then self.selectbtn = skillitem end
        if self.selectskillid == data.id then
            self.selectskillid = nil
            if self.selectbtn ~= nil then self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) end
            self.selectbtn = skillitem
        end
    end

    for i = #skilllist + 1, #self.skillitemlist do
        skillitem = self.skillitemlist[i]
        skillitem:SetActive(false)
    end

    if #skilllist > 0 then
        if self.selectbtn == nil then
            self:onskillitemclick(self.skillitemlist[1])
        else
            self:onskillitemclick(self.selectbtn)
        end
    end
end

function SkillView_Assist:setskillitem(skillitem, data, type, index)
    skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(false)

    if type == 1 then
        skillitem.name = tostring(data.id)

        if self.skillitemloaderlist[index] ~= nil then
            self.skillitemloaderlist[index]:DeleteMe()
            self.skillitemloaderlist[index] = nil
        end
        skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.skill_life_icon, tostring(data.id))
        skillitem.transform:FindChild("NameText"):GetComponent(Text).text = data.name
        skillitem.transform:FindChild("DescText"):GetComponent(Text).text = data.introduction
        skillitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("Lv.%s", tostring(data.lev))
        skillitem.transform:FindChild("LVText"):GetComponent(Text).color = Color(1/255, 125/255, 215/255)
    elseif type == 2 then
        local marryskill
        if data.lev == 0 then
            marryskill = self.model:getmarryskilldata(data.id, 1)
            if marryskill ~= nil then
                skillitem.name = tostring(marryskill.id)

                -- skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
                --     = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(marryskill.icon))
                if self.skillitemloaderlist[index] == nil then
                    self.skillitemloaderlist[index] = SingleIconLoader.New(skillitem.transform:FindChild("SkillIcon").gameObject)
                end
                self.skillitemloaderlist[index]:SetSprite(SingleIconType.SkillIcon, tostring(marryskill.icon))


                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = marryskill.name
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = marryskill.about

                local roleData = RoleManager.Instance.RoleData
                if marryskill.love_var <= roleData.love and marryskill.intimacy <= FriendManager.Instance:GetIntimacy(roleData.lover_id, roleData.lover_platform, roleData.lover_zone_id) then
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("可激活")
                    skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(true)
                else
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("未激活")
                    skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(false)
                end
                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.grey
            end
        else
            marryskill = self.model:getmarryskilldata(data.id, data.lev)
            if marryskill ~= nil then
                skillitem.name = tostring(marryskill.id)

                -- skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
                    -- = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(marryskill.icon))
                if self.skillitemloaderlist[index] == nil then
                    self.skillitemloaderlist[index] = SingleIconLoader.New(skillitem.transform:FindChild("SkillIcon").gameObject)
                end
                self.skillitemloaderlist[index]:SetSprite(SingleIconType.SkillIcon, tostring(marryskill.icon))

                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = marryskill.name

                skillitem.transform:FindChild("LVText"):GetComponent(Text).text =  ""--string.format("Lv.%s", data.lev)
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = marryskill.about
                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.white
            end
        end
    end
end

-- 选中技能 Mark
function SkillView_Assist:onskillitemclick(item)
    if item.name == "10008" then
        for _,value in ipairs(self.model.life_skills) do
            if value.id == 10008 then
                self.select_skilldata = value
            end
        end

        self.skilldata = self.select_skilldata
        self.last_exp = nil
    elseif item.name == "10009" then
        for _,value in ipairs(self.model.life_skills) do
            if value.id == 10009 then
                self.select_skilldata = value
            end
        end

        self.skilldata = self.select_skilldata
    else
    	self.select_skilldata = self.model:getmarryskill(item.name)

        if self.select_skilldata.lev == 0 then
            self.skilldata = self.model:getmarryskilldata(item.name, 1)
        else
            self.skilldata = self.model:getmarryskilldata(item.name, self.select_skilldata.lev)
        end

        self.last_exp = nil
    end

    self:updateSkill()

    if self.selectbtn ~= nil then self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    self.selectbtn = item
end

-- 更新技能信息 Mark
function SkillView_Assist:updateSkill()
    if self.more_show then
        self:on_show_more_items()
    end
    if self.select_skilldata.id == 10008 or self.select_skilldata.id == 10009 then
        self:updateSkill_Life()
    else
        self:updateSkill_Marry()
    end
end

function SkillView_Assist:updateSkill_Life()
    self.lossGuild = false
    self.lossGuildTen = false
    local skilldata = self.skilldata
    local transform = self.transform

    if nil == skilldata then return end

    self.marryInfoPanel:SetActive(false)
    self.lifeInfoPanel:SetActive(true)

    local info_panel = self.lifeInfoPanel
    -- local ImgName = info_panel.transform:FindChild("TopCon/ImgTitle/ImgName"):GetComponent(Image)
    -- ImgName.sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_name, tostring(skilldata.id))
    -- ImgName:SetNativeSize()
    -- ImgName.gameObject:SetActive(true)
    -- info_panel.transform:FindChild("TopCon/ImgTitle/TxtLev"):GetComponent(Text).text = string.format("Lv.%s", tostring(skilldata.lev))
    info_panel.transform:FindChild("TopCon/ImgTitle/NameText"):GetComponent(Text).text
        = string.format("%s Lv.%s", skilldata.name, tostring(skilldata.lev))
    --BaseUtils.dump(skilldata,"skilldata")
    local str = skilldata.desc
    str = string.gsub(str, "%[attr2%]", skilldata.lev+1)
    if skilldata.lev > 0 then
        str = string.gsub(str, "%[attr1%]", skilldata.lev)
    end
    info_panel.transform:FindChild("TopCon/TxtDesc"):GetComponent(Text).text = str

    if skilldata.id == 10009 then
        if DataSkillLife.data_data[string.format("%s_%s", skilldata.id, skilldata.lev+1)] == nil then
            self.ExpText.text = "--/--"
            BaseUtils.tweenDoSlider(self.ExpSlider, self.ExpSlider.value, 1, 0.5)
        else
            -- self.ExpSlider.value = skilldata.exp / skilldata.exp_max
            self.ExpText.text = string.format("%s/%s", skilldata.exp, skilldata.exp_max)

            if self.last_exp == nil then
                self.ExpSlider.value = skilldata.exp / skilldata.exp_max
            elseif self.last_exp ~= skilldata.exp then
                if skilldata.exp < self.last_exp or skilldata.exp == skilldata.exp_max then
                    local fun = function() BaseUtils.tweenDoSlider(self.ExpSlider, 0, skilldata.exp / skilldata.exp_max, 0.5) end
                    BaseUtils.tweenDoSlider(self.ExpSlider, self.ExpSlider.value, 1, 0.5, fun)
                else
                    BaseUtils.tweenDoSlider(self.ExpSlider, self.ExpSlider.value, skilldata.exp / skilldata.exp_max, 0.5, fun)
                end
            end
        end
        self.last_exp = skilldata.exp
    end

    for i=1,#self.l_item_list do
        local itemGo = self.l_item_list[i]
        itemGo:SetActive(false)
    end

    local max_lev_key = ""
    if skilldata.id == 10008 then
        max_lev_key = string.format("%s_%s", skilldata.id, 50)
    elseif skilldata.id == 10009 then
        max_lev_key = string.format("%s_%s", skilldata.id, skilldata.lev)
    end

    local max_lev_cfg_data = nil
    local product_list = nil
    max_lev_cfg_data = DataSkillLife.data_data[max_lev_key]
    product_list = max_lev_cfg_data.product

    if #product_list == 0 then
        self.ConItems:SetActive(false)
        self.ConDesc:SetActive(false)

        if skilldata.id == 10009 then
            if DataSkillLife.data_data[string.format("%s_%s", skilldata.id, skilldata.lev + 1)] == nil then
                self.ConItems_TipsText:SetActive(true)
                self.ConItems:SetActive(true)

            end
            self.Exp:SetActive(true)
        else
            self.ConItems_TipsText:SetActive(false)
            self.Exp:SetActive(false)
        end
    elseif skilldata.id == 10008 then
        self.ConItems:SetActive(false)
        self.ConDesc:SetActive(true)
        self.Exp:SetActive(false)
    elseif skilldata.id == 10009 then
        self.ConDesc:SetActive(false)
        self.ConItems:SetActive(true)
        self.Exp:SetActive(true)
        if #product_list > #self.l_item_list then
            self.ItemBtn.gameObject:SetActive(true)
            self.current_more_data_list = {}
        else
            self.ItemBtn.gameObject:SetActive(false)
        end

        for i=1,#product_list do
            local p = product_list[i]
            if i <= #self.l_item_list then
                local open_data = DataSkillLife.data_product_open[p.key]
                local it = self.l_item_list[i]
                self:set_slot_item_data(it, i, open_data.base_id, open_data.open_lev)
            else
                table.insert(self.current_more_data_list, p)
            end
        end
        --更新“更多面板”
        self:update_more_slot_items()

        if skilldata.id == 10009 then
            if DataSkillLife.data_data[string.format("%s_%s", skilldata.id, skilldata.lev + 1)] == nil then
                self.ConItems_TipsText:SetActive(true)
                self.ConItems:SetActive(true)

            end
            self.Exp:SetActive(true)
        else
            self.ConItems_TipsText:SetActive(false)
            self.Exp:SetActive(false)
        end
    else
        self.ConDesc:SetActive(false)
        self.ConItems:SetActive(true)
        if #product_list > #self.l_item_list then
            self.ItemBtn.gameObject:SetActive(true)
            self.current_more_data_list = {}
        else
            self.ItemBtn.gameObject:SetActive(false)
        end

        for i=1,#product_list do
            local p = product_list[i]
            if i <= #self.l_item_list then
                local open_data = DataSkillLife.data_product_open[p.key]
                local it = self.l_item_list[i]
                self:set_slot_item_data(it, i, open_data.base_id, open_data.open_lev)
            else
                table.insert(self.current_more_data_list, p)
            end
        end
        --更新“更多面板”
        self:update_more_slot_items()
    end

    self.Item3:SetActive(false)
    self.Item1:SetActive(false)
    self.Item2:SetActive(true)
    local next_lev = skilldata.lev+1
    local next_lev_key = string.format("%s_%s", skilldata.id, next_lev)
    local next_lev_cfg_data = nil
    if skilldata.id == 10007 then
        next_lev_cfg_data = DataSkillLife.data_diao_wen[next_lev_key]
    else
        next_lev_cfg_data = DataSkillLife.data_data[next_lev_key]
    end

    if next_lev_cfg_data == nil then
        next_lev = skilldata.lev
        next_lev_key = string.format("%s_%s", skilldata.id, next_lev)
        next_lev_cfg_data = nil
        if skilldata.id == 10007 then
            next_lev_cfg_data = DataSkillLife.data_diao_wen[next_lev_key]
        else
            next_lev_cfg_data = DataSkillLife.data_data[next_lev_key]
        end
    end

    if next_lev_cfg_data ~= nil then
        local data1 = next_lev_cfg_data.levup_cost[1]
        local data2 = next_lev_cfg_data.levup_cost[2]

        if self.imgLoader == nil then
            local go = self.ImgTxtVal.transform:FindChild("ImgIcon").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, data1[1])


        if next_lev_cfg_data.id == 10008 and next_lev_cfg_data.lev >= 51 then
            self:set_stone_slot_data(self.Item3_Slot1, DataItem.data_get[data2[1]], false)

            local need1 = data1[2]
            local need2 = data2[2]
            local has1 = RoleManager.Instance.RoleData.guild--RoleManager.Instance.RoleData.coin
            local has2 = BackpackManager.Instance:GetItemCount(data2[1])
            self.TxtVal.text = need1 > has1 and string.format("<color='#E7582B'>%s</color><color='#e8faff'>/%s</color>", has1, need1)  or string.format("<color='#13fc60'>%s</color><color='#e8faff'>/%s</color>", has1, need1)

            self.Item3_Slot1:SetNum(has2, need2)

            self.Item3:SetActive(true)
            self.Item1:SetActive(true)
            self.Item2:SetActive(false)

            if data1[1] == 90011 and need1 > has1 then
                self.lossGuild = true
            else
                self.lossGuild = false
            end

            if data1[1] == 90011 and need1 * 10 > has1 then
                self.lossGuildTen = true
            else
                self.lossGuildTen = false
            end
        elseif next_lev_cfg_data.id == 10009 then
            if data2 ~= nil then
                self:set_stone_slot_data(self.Item3_Slot1, DataItem.data_get[data2[1]], false)
                local need2 = data2[2]
                local has2 = BackpackManager.Instance:GetItemCount(data2[1])
                self.Item3_Slot1:SetNum(has2, need2)
                self.Item3:SetActive(true)

                self.needItem = data2
            else
                self.Item3:SetActive(false)

                self.needItem = nil
            end

            local need1 = data1[2]
            local has1 = RoleManager.Instance.RoleData.coin
            self.TxtVal.text = need1 > has1 and string.format("<color='#E7582B'>%s</color><color='#e8faff'>/%s</color>", has1, need1)  or string.format("<color='#13fc60'>%s</color><color='#e8faff'>/%s</color>", has1, need1)

            self.Item1:SetActive(true)
            self.Item2:SetActive(false)

            self.BtnOneKey.transform:FindChild("Text"):GetComponent(Text).text = TI18N("一键升级")
        elseif #next_lev_cfg_data.levup_cost == 1 then
            self.Item1:SetActive(true)
            local has_num1 = 0

            if data1[1] == 90000 then
                has_num1 = data1[2] -- RoleManager.Instance.RoleData.coin
            end
            self.TxtVal.text = has_num1 > RoleManager.Instance.RoleData.coin and tostring(has_num1) or string.format("<color='#13fc60'>%s</color>", has_num1)
            self.TxtVal2.text = "<color='#13fc60'>0</color><color='#e8faff'>/0</color>"
        elseif #next_lev_cfg_data.levup_cost == 2 then
            self.Item1:SetActive(true)
            self.Item2:SetActive(true)
            local has_num1 = 0
            local has_num2 = 0
            if data1[1] == 90000 then
                has_num1 = data1[2] --RoleManager.Instance.RoleData.coin
            end
            if data2[1] == 90011 then
                --公会贡献
                has_num2 = RoleManager.Instance.RoleData.guild
            end

            self.TxtVal.text = has_num1 > RoleManager.Instance.RoleData.coin and tostring(has_num1) or string.format("<color='#13fc60'>%s</color>", has_num1)
            self.TxtVal2.text = data2[2] > has_num2 and string.format("<color='#E7582B'>%s</color><color='#e8faff'>/%s</color>", has_num2, data2[2])  or string.format("<color='#13fc60'>%s</color><color='#e8faff'>/%s</color>", has_num2, data2[2])
            if data2[1] == 90011 and data2[2] > has_num2 then
                self.lossGuild = true
            else
                self.lossGuild = false
            end

            if data2[1] == 90011 and data2[2] * 10 > has_num2 then
                self.lossGuildTen = true
            else
                self.lossGuildTen = false
            end
        end
    end

    self.ImgShovel.sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_shovel_bg, tostring(skilldata.id))

    self.ImgShovel.gameObject:SetActive(true)

    --最高级有产出的就两个按钮，只有附加属性的就只有一个按钮 ， 没产出，就是只有 学习技能
    self.BtnStudy.gameObject:SetActive(false)
    self.BtnProduce.gameObject:SetActive(false)
    self.BtnOneKey.gameObject:SetActive(false)

    if next_lev_cfg_data ~=nil and #next_lev_cfg_data.levup_cost ~= 0 then
        self.BtnStudy.gameObject:SetActive(true) --升级
        self.BtnOneKey.gameObject:SetActive(true)
    end

    self.ConDesc_txt_1.text = ""
    self.ConDesc_txt_2.text = ""
    if skilldata.id == 10008 then
        self.ConDesc:SetActive(true)
        if #skilldata.attr > 0 then
            local val_1 = skilldata.attr[1].val
            self.ConDesc_txt_1.text = string.format("<color='#3166ad'>%s</color><color='#205696'>%s</color><color='#13fc60'>+%s</color>", TI18N("当前效果："), TI18N("角色生命值"),     val_1)

            if next_lev_cfg_data ~= nil then
                local val_2 = next_lev_cfg_data.attr[1].val
                self.ConDesc_txt_2.text = string.format("<color='#3166ad'>%s</color><color='#205696'>%s</color><color='#13fc60'>+%s</color>", TI18N("下级效果："), TI18N("角色生命值"),     val_2)

            end
        elseif #next_lev_cfg_data.attr > 0 then
            local val_1 = next_lev_cfg_data.attr[1].val
            self.ConDesc_txt_1.text = string.format("<color='#3166ad'>%s</color><color='#205696'>%s</color><color='#13fc60'>+%s</color>", TI18N("当前效果："), TI18N("角色生命值"),     val_1)
        end
    end

    if skilldata.id == 10008 then
        self.BtnProduce.gameObject:SetActive(false)
    elseif skilldata.id == 10009 then
        self.BtnProduce.gameObject:SetActive(false)
        if #skilldata.product == 0 then
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgGrey.sprite
            self.BtnProduce_button.enabled = false
        else
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgNormal.sprite
            self.BtnProduce_button.enabled = true
        end
    else
        self.BtnProduce.gameObject:SetActive(true)
        if #skilldata.product == 0 then
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgGrey.sprite
            self.BtnProduce_button.enabled = false
        else
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgNormal.sprite
            self.BtnProduce_button.enabled = true
        end
    end
end

function SkillView_Assist:set_slot_item_data(go, index, base_id, open_lev, _type)
    local slot = nil
    if _type == nil then
        slot = self.l_item_slots[index]
    else
        slot = self.more_item_slots[index]
    end

    go:SetActive(true)
    local txtLev = go.transform:FindChild("TxtLev"):GetComponent(Text)
    local imgFrame = go.transform:FindChild("ImgFrame").gameObject
    local cg = txtLev.transform:GetComponent(CanvasGroup)
    cg.blocksRaycasts = false

    local itemData = DataItem.data_get[base_id] --设置数据
    imgFrame.gameObject:SetActive(false)
    txtLev.gameObject:SetActive(false)
    if open_lev > self.skilldata.lev then
        txtLev.gameObject:SetActive(true)
        txtLev.text = string.format("Lv.%s", open_lev)
        txtLev.transform:SetAsLastSibling()
    else
        local key = string.format("%s_%s", self.skilldata.lev, base_id)
        local d = DataSkillLife.data_product_frame_lev[key]
        if d ~= nil then
            local step = d.odds[#d.odds].step
            itemData.step = step
            local txtLev = imgFrame.transform:FindChild("TxtLev"):GetComponent(Text)
            txtLev.text = string.format("<color='#ACE92A'>%s</color>", step)
            imgFrame.gameObject:SetActive(true)
        end
    end



    if slot == nil then
        slot = ItemSlot.New()
        slot.gameObject.transform:SetParent(go.transform)
        slot.gameObject.transform.localScale = Vector3.one
        slot.gameObject.transform.localPosition = Vector3.zero
        slot.gameObject.transform.localRotation = Quaternion.identity
        slot.gameObject.transform:SetAsFirstSibling()
        local rect = slot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one

        if _type == nil then
            self.l_item_slots[index] = slot
        else
            self.more_item_slots[index] = slot
        end
    end
    local cell = ItemData.New()
    cell:SetBase(itemData)
    slot:SetAll(cell, { nobutton = true })
end

--更新多余的
function SkillView_Assist:update_more_slot_items()
    if self.current_line_list ~= nil then
        for k, v in pairs(self.more_item_slots) do
            v:DeleteMe()
            v = nil
        end
        self.more_item_slots = {}

        for i=1,#self.current_line_list do
            local it = self.current_line_list[i]
            if it ~= nil then
                it:SetActive(false)
                GameObject.DestroyImmediate(it)
            end
        end
    end

    self.current_line_list = {}
    if self.current_more_data_list ~= nil and #self.current_more_data_list ~= 0 then
        local current_line_con = nil
        local current_item = nil
        for i=1,#self.current_more_data_list do
            local data = self.current_more_data_list[i]
            if i%2 ~= 0 then --奇数，新开i
                current_line_con = GameObject.Instantiate(self.ConMore_line)
                UIUtils.AddUIChild(self.ConMore_line.transform.parent.gameObject, current_line_con)

                current_item = current_line_con.transform:FindChild("Item").gameObject
                table.insert(self.current_line_list, current_line_con)
            end

            local open_data = DataSkillLife.data_product_open[data.key]
            if open_data == nil then
                open_data = data
            end
            local it = GameObject.Instantiate(current_item)
            UIUtils.AddUIChild(current_item.transform.parent.gameObject, it)
            self:set_slot_item_data(it, i,open_data.base_id, open_data.open_lev, 1)
        end
    end
end

function SkillView_Assist:create_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end


function SkillView_Assist:set_stone_slot_data(slot, data, nb)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nb == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {_nobutton = false})
    end
end

function SkillView_Assist:updateSkill_Marry()
    local skilldata = self.skilldata
    local transform = self.transform

    if nil == skilldata then return end
    self.marryInfoPanel:SetActive(true)
    self.lifeInfoPanel:SetActive(false)

    local info_panel = self.marryInfoPanel
    -- info_panel.transform:FindChild("Icon"):GetComponent(Image).sprite
    --                 = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(skilldata.icon))
    self.info_panel_iconloader:SetSprite(SingleIconType.SkillIcon, tostring(skilldata.icon))

    info_panel.transform:FindChild("NameText"):GetComponent(Text).text = skilldata.name --.."  LV."..skilldata.lev

    info_panel.transform:FindChild("DescText"):GetComponent(Text).text = skilldata.desc

    info_panel.transform:FindChild("DescText1"):GetComponent(Text).text = skilldata.condition
    info_panel.transform:FindChild("DescText2"):GetComponent(Text).text = skilldata.desc2
    info_panel.transform:FindChild("DescText3"):GetComponent(Text).text = skilldata.location
    info_panel.transform:FindChild("DescText4"):GetComponent(Text).text = string.format(TI18N("%s魔法"), tostring(skilldata.cost_mp))
    info_panel.transform:FindChild("DescText5"):GetComponent(Text).text = string.format(TI18N("%s回合"), tostring(skilldata.cooldown))

    info_panel.transform:FindChild("Desc"):GetComponent(Text).text = skilldata.lev_desc

   	if self.select_skilldata.lev == 0 then
   		self.button.gameObject:SetActive(true)
   		info_panel.transform:FindChild("ActiveText").gameObject:SetActive(false)
   	else
   		self.button.gameObject:SetActive(false)
   		info_panel.transform:FindChild("ActiveText").gameObject:SetActive(true)
   	end
end

function SkillView_Assist:okbuttonclick()
	SceneManager.Instance.sceneElementsModel:Self_PathToTarget("44_1")
	self.parent:OnClickClose()
end

function SkillView_Assist:on_click_win(g)
    if self.more_show == true then
        self.more_show = not self.more_show
        self.ConMore:SetActive(self.more_show)
    end
end

function SkillView_Assist:on_click_produce_btn(g)
    self:on_click_win()
    --打开产出
    self.model.life_produce_data = self.skilldata
    self.model:OpenSkillLifeProduceWindow()
end

function SkillView_Assist:on_show_more_items(g)
    self.more_show = not self.more_show
    self.ConMore:SetActive(self.more_show)
end

function SkillView_Assist:on_click_study_btn(g)
    self:on_click_win()
    if self.lossGuild == true then
        local itemData = ItemData.New()
        local basedata = DataItem.data_get[90011]
        itemData:SetBase(basedata)
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData})
    end
    if self.skilldata == nil then return end
    if self.skilldata.id == 10009 then
        if self.needItem ~= nil then
            local has_num = BackpackManager.Instance:GetItemCount(self.needItem[1])
            if has_num < self.needItem[2] then
                NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))

                -- local itembase = BackpackManager.Instance:GetItemBase(self.needItem[1])
                -- local itemData = ItemData.New()
                -- itemData:SetBase(itembase)
                -- local tipsData = { itemData = itemData, gameObject = self.BtnStudy.gameObject }
                -- TipsManager.Instance:ShowItem(tipsData)

                self:ShowQuickBuy(self.needItem[1], self.needItem[2] - has_num)

                return
            end
        end
        SkillManager.Instance:Send10823(self.skilldata.id, 1)
    else
        SkillManager.Instance:Send10809(self.skilldata.id)
    end
end

function SkillView_Assist:on_click_onekey_study_btn(g)
    self:on_click_win()
    if self.lossGuildTen == true then
        local itemData = ItemData.New()
        local basedata = DataItem.data_get[90011]
        itemData:SetBase(basedata)
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData})
    end
    if self.skilldata == nil then return end
    if self.skilldata.id == 10009 then
        if self.needItem ~= nil then
            local has_num = BackpackManager.Instance:GetItemCount(self.needItem[1])
            if has_num < self.needItem[2] then
                NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))

                -- local itembase = BackpackManager.Instance:GetItemBase(self.needItem[1])
                -- local itemData = ItemData.New()
                -- itemData:SetBase(itembase)
                -- local tipsData = { itemData = itemData, gameObject = self.BtnOneKey.gameObject }
                -- TipsManager.Instance:ShowItem(tipsData)
                self:ShowQuickBuy(self.needItem[1], self.needItem[2] - has_num)

                return
            end
        end
        SkillManager.Instance:Send10823(self.skilldata.id, 10)
    else
        SkillManager.Instance:Send10815(self.skilldata.id)
    end
end

function SkillView_Assist:on_click_tanhao(g)
    local tips = {}
    table.insert(tips, TI18N("<color='#00ff00'>公会贡献</color>：可通过<color='#00ff00'>公会任务</color>、<color='#00ff00'>公会强盗</color>、<color='#00ff00'>银币兑换贡献</color>以及使用<color='#00ff00'>荣耀徽章</color>获得"))
    -- local t = {trans=g.transform,content=tips}
    -- mod_tips.general_tips(t)
    TipsManager.Instance:ShowText({gameObject =  self.ImgTanHao.gameObject, itemData = tips})
end

function SkillView_Assist:ShowQuickBuy(base_id, num)
    BuyManager.Instance:ShowQuickBuy({[base_id] = {need = num}})
end

