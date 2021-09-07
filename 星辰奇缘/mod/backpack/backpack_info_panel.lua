BackpackInfoPanel = BackpackInfoPanel or BaseClass(BasePanel)

function BackpackInfoPanel:__init(model)
    self.model = model
    self.parent = nil
    self.resList = {
        {file = AssetConfig.backpack_info, type = AssetType.Main}
        ,{file = AssetConfig.skill_life_icon, type = AssetType.Dep}
        ,{file = AssetConfig.skill_life_name, type = AssetType.Dep}
        ,{file = AssetConfig.skill_life_shovel_bg, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
    }

    self.transform = nil
    self.honor_obj = nil --称号
    self.juewei_obj = nil -- 爵位
    self.huoli_obj = nil -- 活力
    self.couple_obj = nil --伴侣
    self.brother_obj = nil --结拜
    self.obj_table = nil
    self.model.info_current_index = 0

    --监听回调
    --称号更新
    self.on_honor_update = function()
        self:on_update_honors()
    end

    --活力更新
    self.on_life_skill_update = function()
        self:update_huoli()
    end

    self.on_couple_update = function()
        self:update_couple()
    end


    --称号
    self.honor_has_init = false
    self.honor_unopen_con = nil
    self.honor_mask_con = nil
    self.honor_origin_item = nil
    self.TabButtonGroup = nil
    self.current_honor_data_list = nil
    self.honor_current_tab = 1
    self.honor_list_has_init = false

    --活力值
    self.huoli_has_init = false
    self.huoli_ImgShovel = nil
    self.MaskLayer = nil
    self.Con_scroll_layer = nil
    self.huoli_BtnLeft = nil
    self.huoli_BtnRight = nil
    self.huoli_item_list = nil
    self.huoli_list_has_init = false
    self.current_data_huoli_list = {}

    self.juewei_has_init = false
    --伴侣信息
    self.couple_has_init = false
    self.cp_head = nil
    self.cp_name = nil
    self.cp_class = nil
    self.cp_lev = nil
    self.cp_fight = nil
    self.cp_relationship = nil
    self.cp_friendship = nil
    self.cp_merryday = nil
    self.cp_chat_btn = nil
    self.cp_team_btn = nil
    self.cp_flower_btn = nil

    self.OnOpenEvent:Add(function() self:on_window_show() end)
    self.OnHideEvent:Add(function() self:on_window_hide() end)
    self.slotList = {}
end

function BackpackInfoPanel:__delete()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    self.slotList = {}
    self.honor_has_init = false
    self.honor_current_tab = 1

    self.huoli_has_init = false
    self.huoli_item_list = nil

    self.couple_has_init = false

    self:RemoveListeners()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function BackpackInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_info))
    self.gameObject.name = "BackpackInfoPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(189, -8, 0)

    -- local close_btn = self.transform:Find("CloseButton"):GetComponent(Button)
    -- close_btn.onClick:AddListener(function() WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack) end)

    self.honor_obj = self.transform:Find("Con_chenhao").gameObject
    self.juewei_obj = self.transform:Find("Con_juewei").gameObject
    self.huoli_obj = self.transform:Find("Con_huoli").gameObject
    self.couple_obj = self.transform:Find("Con_love").gameObject
    self.brother_obj = self.transform:Find("Con_jiebai").gameObject
    self.obj_table = {self.honor_obj, self.juewei_obj, self.huoli_obj, self.couple_obj, self.brother_obj}
    for k,v in pairs(self.obj_table) do
        v:SetActive(false)
    end

    if self.model.info_current_index ~= 0 then
        self.obj_table[self.model.info_current_index]:SetActive(true)
        self:update_tab_data()
    else
        self:change_view(1)
    end

    self:AddListeners()

    self.is_open = true
end

function BackpackInfoPanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.life_skill_update, self.on_life_skill_update)
    EventMgr.Instance:AddListener(event_name.honor_update, self.on_honor_update)
    EventMgr.Instance:AddListener(event_name.lover_data, self.on_couple_update)
end

function BackpackInfoPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.life_skill_update, self.on_life_skill_update)
    EventMgr.Instance:RemoveListener(event_name.honor_update, self.on_honor_update)
    EventMgr.Instance:RemoveListener(event_name.lover_data, self.on_couple_update)
end

--角色信息界面调用切换信息展示
function BackpackInfoPanel:change_view(index)
    if index ~= self.model.info_current_index then
        if self.model.info_current_index ~= 0 then
            self.obj_table[self.model.info_current_index]:SetActive(false)
        end
        self.obj_table[index]:SetActive(true)
        self.model.info_current_index = index
        self:update_tab_data()
    end
end

--根据选择的tab，更新显示
function BackpackInfoPanel:update_tab_data()
    if self.model.info_current_index == 1 then --称号
        self:init_honor()
    -- elseif self.model.info_current_index == 2 then --爵位
    --     self:init_juewei()
    elseif self.model.info_current_index == 3 then --活力
        self:init_huoli()
    elseif self.model.info_current_index == 4 then --伴侣
        self:init_couple()
    elseif self.model.info_current_index == 5 then  --结拜

    end
end


--------------------------------------------------------------称号逻辑
function BackpackInfoPanel:init_honor()
    if self.honor_has_init == false then
        self.honor_unopen_con = self.honor_obj.transform:Find("UnOpen_con").gameObject
        self.honor_mask_con = self.honor_obj.transform:Find("Mask_con").gameObject
        self.honor_unopen_con:SetActive(false)
        self.honor_mask_con:SetActive(true)
         self.honor_vScroll = self.honor_mask_con.transform:Find("Scroll_con"):GetComponent(LVerticalScrollRect)

        self.honor_has_init = true
    end

    self:on_update_honors()
end

function BackpackInfoPanel:on_update_honors()
    if self.honor_has_init == false then
        return
    end

    if HonorManager.Instance.model.mine_honor_list == nil then
        -- HonorManager.Instance:request12700()
        return
    end

    self.honor_unopen_con:SetActive(false)
    self.honor_mask_con:SetActive(true)
    self.current_honor_data_list = BaseUtils.copytab(HonorManager.Instance.model.mine_honor_list)
    for k,v in pairs(DataHonor.data_get_honor_list) do
        if v.show_sort ~= 0 then
            if v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes then --无职业限制，或者职业相同
                if v.sex == 2 or v.sex == RoleManager.Instance.RoleData.sex then --无性别限制或者性别相同
                    if not HonorManager.Instance.model:check_has_honor(v.id) then
                        table.insert(self.current_honor_data_list, v)
                    end
                end
            end
        end
    end
    local show_sort = function(a, b)
        if a.show_sort == nil or b.show_sort == nil then return true end

        return a.id == HonorManager.Instance.model.current_honor_id
            or (a.has and not b.has)
            or (not a.has and not b.has and a.show_sort < b.show_sort)
    end
    table.sort(self.current_honor_data_list, show_sort )
    HonorManager.Instance.model.current_honor_data_list = self.current_honor_data_list
    self:update_honors()
end

function BackpackInfoPanel:update_honors()
    if self.honor_list_has_init == false  then
        self.honor_list_has_init = true
        local GetData = function(index)
            return {item_index = index+1, data = self.current_honor_data_list[index+1]}
        end
        local callBack = function(item)
            if self.last_selected_item ~= nil then
                self.last_selected_item.selectBg:SetActive(false)
            end
            self.last_selected_item = item
            self.last_selected_item.selectBg:SetActive(true)
        end
        self.honor_vScroll:SetPoolInfo(#self.current_honor_data_list, "BackPackHonorItem", GetData, {onClick = callBack, assetWrapper = self.assetWrapper})
    else
        self.honor_vScroll:RefreshList(#self.current_honor_data_list)
    end
end


------------------------------------活力逻辑
function BackpackInfoPanel:init_huoli()
    if self.huoli_has_init == false then
        self.huoli_ImgShovel = self.huoli_obj.transform:Find("ImgShovel"):GetComponent(Image)
        self.MaskLayer = self.huoli_obj.transform:Find("MaskLayer").gameObject
        self.Con_scroll_layer = self.MaskLayer.transform:Find("Con_scroll_layer")
        self.huoli_vScroll = self.MaskLayer.transform:Find("Con_scroll_layer"):GetComponent(LVerticalScrollRect)

        self.huoli_BtnLeft = self.huoli_obj.transform:Find("BtnLeft"):GetComponent(Button)
        self.huoli_BtnRight = self.huoli_obj.transform:Find("BtnRight"):GetComponent(Button)

        self.huoli_BtnLeft.onClick:AddListener(function() self:on_cllick_huoli_btn(1)  end)
        self.huoli_BtnRight.onClick:AddListener(function() self:on_cllick_huoli_btn(2)  end)

        self.huoli_has_init = true
    end

    SkillManager.Instance:Send10808()
end


function BackpackInfoPanel:on_cllick_huoli_btn(index)
    if index == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain)
    elseif index == 2 then
        --打开生活技能面板
        local firstData = self.current_data_huoli_list[1]
        if firstData ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {3, firstData.id})
        end
    end
end

function BackpackInfoPanel:update_huoli()
    if self.huoli_has_init == false then
        return
    end

    self.huoli_ImgShovel.sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_shovel_bg, tostring(10000))
    self.huoli_ImgShovel.gameObject:SetActive(true)

    self.current_data_huoli_list = {}
    local index = 3
    for i=1,#SkillManager.Instance.model.life_skills do
        --构造数据列表，只需要三个数据，栽培，研制，工艺设计
        local data = SkillManager.Instance.model.life_skills[i]
        if data.id == 10007 then
            self.current_data_huoli_list[1] = data
        elseif data.id == 10000 then
            self.current_data_huoli_list[2] = data
        elseif data.id == 10001 or data.id == 10002 or data.id == 10005 or data.id == 10006 then
            self.current_data_huoli_list[index] = data
            index = index + 1
        end
    end

    -- local temp = self.current_data_huoli_list[1]
    -- local temp2 = self.current_data_huoli_list[2]
    -- local index1 = 0
    -- local index2 = 0
    -- for i=1,#self.current_data_huoli_list do
    --     local data = self.current_data_huoli_list[i]
    --     if data.id == 10007 then
    --         index1 = i
    --     elseif data.id == 10000 then
    --         index2 = i
    --     end
    -- end


    -- self.current_data_huoli_list[1] = self.current_data_huoli_list[index1]
    -- self.current_data_huoli_list[2] = self.current_data_huoli_list[index2]
    -- self.current_data_huoli_list[index1] = temp
    -- self.current_data_huoli_list[index2] = temp2

    -- print(index1)
    -- print(index2)
    BaseUtils.dump(self.current_data_huoli_list)

    if self.huoli_list_has_init == false  then
        self.huoli_list_has_init = true
        local GetData = function(index)
            return {item_index = index+1, data = self.current_data_huoli_list[index+1]}
        end
        self.huoli_vScroll:SetPoolInfo(#self.current_data_huoli_list, "BackPackHuoLiItem", GetData, {assetWrapper = self.assetWrapper})
    else
        self.huoli_vScroll:RefreshList(#self.current_data_huoli_list)
    end
end

function BackpackInfoPanel:init_juewei()
    if self.juewei_has_init ~= true then
        local t = self.juewei_obj.transform
        self.currentTitleText = t:Find("Title/Text"):GetComponent(Text)
        self.currentAttrText = t:Find("Info/Container/Current/AttrContainer/Attr"):GetComponent(Text)
        -- self.currentSkillText = t:Find("Info/Container/Current/SkillContainer/Skill/Text"):GetComponent(Text)

        -- 当前属性
        self.currentAttrObjList = {}
        -- 当前技能
        self.currentSkillObjList = {}

        self.nextTitleText = t:Find("Info/Container/Next/Title"):GetComponent(Text)
        self.nextAttrText = t:Find("Info/Container/Next/Attr"):GetComponent(Text)
        self.nextSkillText = t:Find("Info/Container/Next/Skill/Text"):GetComponent(Text)

        -- 下阶技能查看
        t:Find("Info/Container/Next/Skill/Eye"):GetComponent(Button).onClick:AddListener(function ()
            GloryManager.Instance:ShowSkillTips({2, GloryManager.Instance.model.title_id + 1})
        end)

        -- 晋升按钮
        t:Find("Condition/Button"):GetComponent(Button).onClick:AddListener(function()
            local lev = RoleManager.Instance.RoleData.lev
            local title_id = GloryManager.Instance.model.title_id + 1
            if lev < DataGlory.data_level[title_id].need_lev then
                NoticeManager.Instance:FloatTipsByString(TI18N("等级不足，无法晋升"))
            else
                if DataGlory.data_title[title_id].skill_order == 0 then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
                else
                    GloryManager.Instance:ShowSkillTips({1, title_id})
                end
            end
        end)

        self.juewei_has_init = true
    end
    self:update_juewei()
end

function BackpackInfoPanel:update_juewei()
    if self.juewei_has_init == false then
        return
    end
    local gloryMgr = GloryManager.Instance
    local model = gloryMgr.model
    local t = self.juewei_obj.transform

    local h = 0

    local classes = RoleManager.Instance.RoleData.classes

    local currentTitle = DataGlory.data_title[model.title_id]
    -- BaseUtils.dump(currentTitle, "当前爵位信息")

    self.currentTitleText.text = currentTitle.title_name

    -- 当前拥有的属性加强列表
    local attrContainer = t:Find("Info/Container/Current/AttrContainer")
    local attrTemplate = attrContainer:Find("Attr").gameObject
    attrTemplate:SetActive(false)
    local attrLayout = LuaBoxLayout.New(attrContainer, {axis = BoxLayoutAxis.Y, rspacing = 0})
    if model.attrList == nil then
        model.attrList = {}
    end

    for i=1,#model.attrList do
        local obj = attrContainer:Find(tostring(i))
        if obj == nil then
            obj = GameObject.Instantiate(attrTemplate)
            obj.name = tostring(i)
            self.currentAttrObjList[i] = obj
            attrLayout:AddCell(obj)
        else
            obj = obj.gameObject
        end
        if model.attrList[i].val > 0 then
            obj:GetComponent(Text).text = TI18N("角色")..KvData.attr_name[model.attrList[i].name].. TI18N("永久+")..model.attrList[i].val.."%"
        else
            obj:GetComponent(Text).text = TI18N("角色")..KvData.attr_name[model.attrList[i].name].. TI18N("永久-")..model.attrList[i].val.."%"
        end
        obj:SetActive(true)
    end

    for i=#model.attrList + 1, #self.currentAttrObjList do
        self.currentAttrObjList[i]:SetActive(false)
    end

    -- 当前拥有的技能列表

    local skillContainer = t:Find("Info/Container/Current/SkillContainer")
    local skillTemplate = skillContainer:Find("Skill").gameObject
    skillTemplate:SetActive(false)
    local skillLayout = LuaBoxLayout.New(skillContainer, {axis = BoxLayoutAxis.Y, rspacing = 0})
    if model.skillList == nil then
        model.skillList = {}
    end

    for i = 1,#model.skillList do
        local obj = skillContainer:Find(tostring(i))
        if obj == nil then
            obj = GameObject.Instantiate(skillTemplate)
            obj.name = tostring(i)
            self.currentSkillObjList[i] = obj
            skillLayout:AddCell(obj)
        else
            obj = obj.gameObject
        end
        local skilldata = DataGlory.data_skill[model.skillList[i].skill_order.."_"..classes]
        obj.transform:Find("Text"):GetComponent(Text).text = skilldata["skill_name_"..model.skillList[i].skill_id]
        obj:SetActive(true)
        obj.transform:Find("Eye"):GetComponent(Button).onClick:RemoveAllListeners()
        obj.transform:Find("Eye"):GetComponent(Button).onClick:AddListener(function() self:on_click_skill_reset(model.skillList[i].skill_order) end)
    end

    for i=#model.skillList + 1, #self.currentSkillObjList do
        self.currentSkillObjList[i]:SetActive(false)
    end

    h = h + 35 + 20 * #model.attrList
    skillContainer.anchoredPosition = Vector2(16, -h)

    h = h + 20 * #model.skillList

    local nextTitle = DataGlory.data_title[model.title_id + 1]
    self.nextTitleText.text = nextTitle.title_name
    local nextAttr = nextTitle.attr[1]
    if nextAttr ~= nil then
        if nextAttr.val > 0 then
            t:Find("Info/Container/Next/Attr"):GetComponent(Text).text = TI18N("角色") .. KvData.attr_name[nextAttr.attr_name] .. TI18N("永久+") ..nextAttr.val.."%"
        else
            t:Find("Info/Container/Next/Attr"):GetComponent(Text).text = TI18N("角色") .. KvData.attr_name[nextAttr.attr_name] .. TI18N("永久-") ..nextAttr.val.."%"
        end
    end
    local skilldata = DataGlory.data_skill[nextTitle.skill_order.."_"..classes]
    h = h + 100
    if skilldata ~= nil then
        t:Find("Info/Container/Next/Skill/Text"):GetComponent(Text).text = skilldata["skill_name_1"].."/"..skilldata["skill_name_2"]
        t:Find("Info/Container/Next/Skill").gameObject:SetActive(true)
        h = h + 20
    else
        -- t:Find("Info/Container/Next/Skill/Text"):GetComponent(Text).text = ""
        t:Find("Info/Container/Next/Skill").gameObject:SetActive(false)
    end

    local rect = t:Find("Info/Container"):GetComponent(RectTransform)
    local w = rect.sizeDelta.x
    rect.sizeDelta = Vector2(w, h)
    rect.anchoredPosition = Vector2(0, 0)

    local needList = nextTitle.need_item
    for i=1,2 do
        local obj = t:Find("Condition/Slot"..i).gameObject
        if needList[i] == nil then
            obj:SetActive(false)
            break
        else
            obj:SetActive(true)
        end

        local slotItem = nil
        if obj.transform.childCount > 0 then
            slotItem = obj.transform:GetChild(0)
        end

        local slot = nil
        if slotItem == nil then
            slot = ItemSlot.New()
        else
            slot = ItemSlot.New(slotItem.gameObject)
        end
        table.insert(self.slotList, slot)
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[needList[i][1]])
        itemData.quantity = needList[i][2]
        slot:SetAll(itemData, {inbag = false, nobutton = true})
        NumberpadPanel.AddUIChild(obj, slot.gameObject)
    end
end

function BackpackInfoPanel:on_click_skill_reset(index)
    GloryManager.Instance:ShowSkillTips({3, i})
end

--背包界面销毁时，销毁子界面脚本数据
function BackpackInfoPanel:destory()
    self.transform = nil

    self.honor_has_init = false
    self.honor_current_tab = 1

    self.huoli_has_init = false
    self.huoli_item_list = nil
end

function BackpackInfoPanel:on_window_hide()
    self:RemoveListeners()
end

function BackpackInfoPanel:on_window_show()
    self:AddListeners()

    self:update_tab_data()
end

function BackpackInfoPanel:init_couple()
    if self.couple_has_init == true then
        return
    end

    self.cp_head = self.couple_obj.transform:Find("Top/head"):GetComponent(Image)
    self.cp_name = self.couple_obj.transform:Find("Top/name"):GetComponent(Text)
    self.cp_class = self.couple_obj.transform:Find("Top/class"):GetComponent(Text)
    self.cp_lev = self.couple_obj.transform:Find("Top/level"):GetComponent(Text)
    self.cp_fight = self.couple_obj.transform:Find("Fight/value"):GetComponent(Text)

    self.cp_relationship = self.couple_obj.transform:Find("relationship/value"):GetComponent(Text)
    self.cp_friendship = self.couple_obj.transform:Find("friendship/value"):GetComponent(Text)
    self.cp_merryday = self.couple_obj.transform:Find("merryday/value"):GetComponent(Text)

    self.cp_chat_btn = self.couple_obj.transform:Find("Btn_chat"):GetComponent(Button)
    self.cp_team_btn = self.couple_obj.transform:Find("Btn_team"):GetComponent(Button)
    self.cp_flower_btn = self.couple_obj.transform:Find("Btn_flower"):GetComponent(Button)

    if MarryManager.Instance.loverData ~= nil then
        local data = MarryManager.Instance.loverData
        local headid = tostring(data.classes)..tostring(data.sex)
        self.cp_head.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, headid)
        self.cp_name.text = data.name
        self.cp_class.text = string.format(TI18N("职业：%s"),KvData.classes_name[data.classes])
        self.cp_lev.text = string.format(TI18N("等级：%s"), tostring(data.lev))
        self.cp_fight.text = string.format(TI18N("个性签名：%s"), (data.str ~= "" and data.str or TI18N("无")))
        self.cp_relationship.text = TI18N("伴侣")
        self.cp_friendship.text = tostring(data.intimacy)
        self.cp_merryday.text = tostring(math.floor((BaseUtils.BASE_TIME-data.time)/3600/24))
        self.cp_chat_btn.onClick:AddListener(function() FriendManager.Instance:TalkToUnknowMan(data) end)
        self.cp_team_btn.onClick:AddListener(function() TeamManager.Instance:Send11702(data.id, data.platform, data.zone_id) end)
        self.cp_flower_btn.onClick:AddListener(function() GivepresentManager.Instance:OpenGiveWin(data) end)
    end
    self.couple_has_init = true

    self:update_couple()
end

function BackpackInfoPanel:update_couple()
    if self.couple_has_init ~= true then
        return
    end
    if MarryManager.Instance.loverData ~= nil then
        local data = MarryManager.Instance.loverData
        local headid = tostring(data.classes).."_"..tostring(data.sex)
        self.cp_head.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, headid)
        self.cp_head.gameObject:SetActive(true)
        self.cp_name.text = RoleManager.Instance.RoleData.lover_name
        self.cp_class.text = string.format(TI18N("职业：%s"), KvData.classes_name[data.classes])
        self.cp_lev.text = string.format(TI18N("等级：%s"), tostring(data.lev))
        self.cp_fight.text = string.format(TI18N("个性签名：%s"), (data.str ~= "" and data.str or "无"))
        if RoleManager.Instance.RoleData.wedding_status == 1 then
            if RoleManager.Instance.RoleData.sex == 1 then
                self.cp_relationship.text = TI18N("有缘人")
            else
                self.cp_relationship.text = TI18N("有缘人")
            end
            self.cp_merryday.text = TI18N("未举办典礼")
        else
            self.cp_relationship.text = TI18N("伴侣")
            self.cp_merryday.text = tostring(math.ceil((BaseUtils.BASE_TIME-data.time)/3600/24))
        end
        self.cp_friendship.text = tostring(data.intimacy)
        self.cp_chat_btn.onClick:RemoveAllListeners()
        self.cp_chat_btn.onClick:AddListener(function() FriendManager.Instance:TalkToUnknowMan(data) end)
        self.cp_team_btn.onClick:RemoveAllListeners()
        self.cp_team_btn.onClick:AddListener(function() TeamManager.Instance:Send11702(data.id, data.platform, data.zone_id) end)
        self.cp_flower_btn.onClick:RemoveAllListeners()
        self.cp_flower_btn.onClick:AddListener(function() GivepresentManager.Instance:OpenGiveWin(data) end)
    else
        self.cp_head.gameObject:SetActive(false)
        self.cp_name.text = TI18N("无")
        self.cp_class.text = string.format(TI18N("职业：%s"),"")
        self.cp_lev.text = string.format(TI18N("等级：%s"), "")
        self.cp_fight.text = tostring(0)
        self.cp_relationship.text = TI18N("伴侣")
        self.cp_friendship.text = ""
        self.cp_merryday.text = ""
        self.cp_chat_btn.onClick:RemoveAllListeners()
        self.cp_team_btn.onClick:RemoveAllListeners()
        self.cp_flower_btn.onClick:RemoveAllListeners()
    end
end
