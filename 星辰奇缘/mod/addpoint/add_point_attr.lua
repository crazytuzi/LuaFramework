-- ---------------------
-- 加点属性展示
-- hosr
-- -----------------------
AddPointAttr = AddPointAttr or BaseClass()

function AddPointAttr:__init(gameObject, main)
    self.main = main
    self.gameObject = gameObject
    self.valueTab = {}
    self.upObjTab = {}
    self.upValTab = {}

    -- self:CheckGuideBreak()

    -- self.helpNormal = {
    --     --TI18N("完成<color='#ffff00'>爵位挑战</color>特定关卡"),
    --     --TI18N("可获得额外属性点奖励"),
    --     string.format(TI18N("1、爵位已获得加点：%s\n（完成爵位挑战特定关卡，可获得额外属性点奖励）\n2、道具已获得加点：%s\n（使用仙品水晶粽、部分时装等可获得额外属性点奖励）\n3、收藏图鉴碎片已获得加点：%s\n（通过收藏部分图鉴碎片，可获得额外属性点奖励）\n4、等级突破获得加点：%s\n（角色等级突破后，可获得额外属性点奖励）\n5、兑换点数：%s\n（角色突破后，可通过消耗经验兑换属性点"),role.honorPoint, role.itemPoint ,role.handbookPoint, role.levbreakPoint, role.levbreakExchangePoint)
    -- }

    self.helpNormal1 = {
        TI18N("完成<color='#ffff00'>爵位挑战</color>特定关卡，可获得额外属性点奖励"),
        TI18N("成功<color='#ffff00'>突破等级</color>限制后，可用人物经验兑换属性点"),
    }

    self.helpPet = {
        TI18N("使用兽王丹可以增加额外增加宠物<color='#ffff00'>可分配属性点</color>。"),
        TI18N("同一只宠物最多可使用<color='#00ff00'>20次</color>"),
    }

    self.helpChild = {
        TI18N("使用<color='#00ff00'>[掌上明珠]</color>可以额外增加孩子属性点，并按照加点方案自动分配。"),
        TI18N("同一名孩子最多可使用<color='#00ff00'>20次</color>"),
    }

    self.switchOption = function() self:Switch_Option(3) end  --刷新方案三用

    self:InitPanel()
end

function AddPointAttr:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_attr_option_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_point_preview_back, self.on_preview_back)
    RoleManager.Instance.updateAddPointPlan3:RemoveListener(self.switchOption)
    if self.guideBreak ~= nil then
        self.guideBreak:DeleteMe()
        self.guideBreak = nil
    end

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
end

function AddPointAttr:InitPanel()
    self.transform = self.gameObject.transform
    self.BottomCon = self.transform:Find("BottomCon")
    self.OpenCon_btn = self.BottomCon:Find("OpenButton"):GetComponent(Button)
    self.OpenCon_btn.onClick:AddListener(function() self:ClickOpenPlan() end)

    self.NormalCon = self.BottomCon:Find("NormalCon")
    self.helpBtn = self.NormalCon:Find("HelpButton").gameObject
    self.helpBtn:GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)
    self.descTxt = self.NormalCon:Find("HonorTxt"):GetComponent(Text)

    self.ExchangeCon = self.BottomCon:Find("ExchangeCon")
    self.helpBtn1 = self.ExchangeCon:Find("HelpButton").gameObject
    self.helpBtn1:GetComponent(Button).onClick:AddListener(function() self:ClickHelp1() end)
    self.descTxt1 = self.ExchangeCon:Find("HonorTxt"):GetComponent(Text)
    self.exchangeBtn = self.ExchangeCon:Find("ExchangeBtn").gameObject
    self.exchangeBtn:GetComponent(Button).onClick:AddListener(function() self:ClickExchangePoint() end)
    self.exchangeTxt = self.ExchangeCon:Find("ExchangeTxt"):GetComponent(Text)
    self.exchangeBtnObj = self.ExchangeCon:Find("ExchangeBtn").gameObject

    self.headImg = self.transform:Find("Top/Head/Image"):GetComponent(Image)
    self.headImg.gameObject:SetActive(true)
    self.nameTxt = self.transform:Find("Top/Name"):GetComponent(Text)
    self.levTxt = self.transform:Find("Top/Lev"):GetComponent(Text)
    self.bgImgRect = self.transform:Find("Image"):GetComponent(RectTransform)

    local func = function(trans, key)
        -- 都用属性值做Key，方便查询读取
        self.valueTab[key] = trans:Find("Value"):GetComponent(Text)
        self.upObjTab[key] = trans:Find("UpImg").gameObject
        self.upValTab[key] = self.upObjTab[key].transform:Find("Text"):GetComponent(Text)
    end

    local container = self.transform:Find("Container").gameObject.transform
    func(container:Find("HP").gameObject.transform, 1)
    func(container:Find("MP").gameObject.transform, 2)
    func(container:Find("AttackSpeed").gameObject.transform, 3)
    func(container:Find("PhyAttack").gameObject.transform, 4)
    func(container:Find("MagAttack").gameObject.transform, 5)
    func(container:Find("PhyDefense").gameObject.transform, 6)
    func(container:Find("MagDefense").gameObject.transform, 7)
    self.gameObject:SetActive(true)

    self.OptionCon = self.transform:Find("OptionCon")
    self.CurButton = self.OptionCon:Find("OpenButton"):GetComponent(Button)
    self.CurButton_txt = self.OptionCon:Find("OpenButton"):Find("Text"):GetComponent(Text)
    self.Options = self.OptionCon:Find("Options")
    self.OpenButton1 = self.Options:Find("OpenButton1"):GetComponent(Button)
    self.OpenButton2 = self.Options:Find("OpenButton2"):GetComponent(Button)
    self.OpenButton3 = self.Options:Find("OpenButton3"):GetComponent(Button)
    self.OptionConShow = false
    self.CurButton.onClick:AddListener(function()
        self.OptionConShow = not self.OptionConShow
        self.Options.gameObject:SetActive(self.OptionConShow)
    end)
    self.OpenButton1.onClick:AddListener(function()
        self:Switch_Option(1)
    end)
    self.OpenButton2.onClick:AddListener(function()
        self:Switch_Option(2)
    end)
    self.OpenButton3.onClick:AddListener(function()
        self:Switch_Option(3)
    end)

    self:Switch_Option(RoleManager.Instance.RoleData.valid_plan)

    self.listener = function()
        self:Switch_Option(RoleManager.Instance.RoleData.valid_plan)
    end
    EventMgr.Instance:AddListener(event_name.role_attr_option_change, self.listener)

    self.on_preview_back = function(data)
        self:update_preview(data)
    end
    EventMgr.Instance:AddListener(event_name.role_point_preview_back, self.on_preview_back)
    RoleManager.Instance.updateAddPointPlan3:AddListener(self.switchOption)
    RoleManager.Instance.updateAddPointPlan3:AddListener(BibleManager.Instance.rechargeRedPointListerner)
end

--更新显示预览属性
function AddPointAttr:update_preview(data)
    local _list = {}
    _list = {data.hp_max, data.mp_max, data.atk_speed, data.phy_dmg, data.magic_dmg, data.phy_def, data.magic_def}
    self:UpdateInfo(AddPointEumn.Type.Role, _list)
end


--切换加点方案
function AddPointAttr:Switch_Option(_index)
    local open_lev = 1
    local has_active = RoleManager.Instance.RoleData.valid_plan == _index
    local CurButton_txt_str = ""
    if _index == 1 then
        open_lev = 1
        CurButton_txt_str = TI18N("加点方案一")
    elseif _index == 2 then
        open_lev = 50
        CurButton_txt_str = TI18N("加点方案二")
    elseif _index == 3 then
        open_lev = 90
        CurButton_txt_str = TI18N("加点方案三")
    end

    if RoleManager.Instance.RoleData.lev < 50 and RoleManager.Instance.RoleData.lev < open_lev then
        NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#2fc823'>%s</color>%s", TI18N("该方案"), open_lev, TI18N("级开启")))
        return
    end


    self.CurButton_txt.text = CurButton_txt_str
    self.cur_select_option = _index

    if self.OptionConShow then
        self.OptionConShow = false
        self.Options.gameObject:SetActive(self.OptionConShow)
    end

    --更新右边底部
    if self.main.slider ~= nil then
        self.main.slider:Switch_bottom_state(has_active)
    end

    if _index ~= RoleManager.Instance.RoleData.valid_plan then
        --不是当前方案则请求预览
        RoleManager.Instance:Send10025(_index)
    else
        if self.main.slider ~= nil then
            self.main.slider:Show(AddPointEumn.Type.Role, _index)
        end
        self:UpdateInfo(AddPointEumn.Type.Role)
    end
end


-- 外部调用初始化
function AddPointAttr:UpdateInfo(type, _list)
    self.type = type

    for _,obj in pairs(self.upObjTab) do
        obj:SetActive(false)
    end

    local times = RoleManager.Instance.RoleData.lev_break_times
    local has_active = RoleManager.Instance.RoleData.valid_plan == self.cur_select_option
    --更新底部
    if has_active then
        self.OpenCon_btn.gameObject:SetActive(false)
        if self.type == AddPointEumn.Type.Role and times > 0 then
            self.NormalCon.gameObject:SetActive(true)
            self.ExchangeCon.gameObject:SetActive(false)
        else
            self.NormalCon.gameObject:SetActive(true)
            self.ExchangeCon.gameObject:SetActive(false)
        end
    else
        self.OpenCon_btn.gameObject:SetActive(true)
        self.NormalCon.gameObject:SetActive(false)
        self.ExchangeCon.gameObject:SetActive(false)
    end

    local list = nil
    if self.type == AddPointEumn.Type.Role then
        self.OptionCon.gameObject:SetActive(true)
        self.transform:Find("Top"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -55)
        self.transform:Find("Container"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -139.5)

        local role = RoleManager.Instance.RoleData
        if _list == nil then
            list = {role.hp_max, role.mp_max, role.atk_speed, role.phy_dmg, role.magic_dmg, role.phy_def, role.magic_def}
        else
            list = _list
        end
        self.nameTxt.text = role.name
        self.levTxt.text = "Lv."..tostring(role.lev)
        self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", role.classes, role.sex))
        self.descTxt.text = string.format(TI18N("额外获得属性点:<color='%s'>%s</color>"), "#e8faff", role:ExtraPoint())
        self.descTxt1.text = string.format(TI18N("爵位已获得加点:<color='%s'>%s</color>"), "#e8faff", role.honorPoint)
        if times > 0 then
            self.exchangeTxt.text = string.format(TI18N("已兑换点数:<color='%s'>%s/%s</color>"), "#e8faff", role.levbreakExchangePoint, DataLevBreak.data_lev_break_times[times].max_exchange)
        end
    elseif self.type == AddPointEumn.Type.Pet then
        self.OptionCon.gameObject:SetActive(false)
        self.transform:Find("Top"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -13)
        self.transform:Find("Container"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -97)

        local petData = self.main.openArgs[2]
        list = {petData.hp_max, petData.mp_max, petData.atk_speed, petData.phy_dmg, petData.magic_dmg, petData.phy_def, petData.magic_def}
        self.nameTxt.text = petData.name
        self.levTxt.text = "Lv."..tostring(petData.lev)
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.headImg.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet, petData.base.head_id)
        -- self.headImg.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), tostring(petData.base.head_id))
        self.descTxt.text = string.format(TI18N("已使用兽王丹:<color='%s'>%s/20</color>"), "#e8faff", petData.feed_point)
    elseif self.type == AddPointEumn.Type.Child then
        self.OptionCon.gameObject:SetActive(false)
        self.transform:Find("Top"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -13)
        self.transform:Find("Container"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -97)

        local petData = self.main.openArgs[2]
        list = {petData.hp_max, petData.mp_max, petData.atk_speed, petData.phy_dmg, petData.magic_dmg, petData.phy_def, petData.magic_def}
        local base = DataChild.data_child[petData.base_id]
        self.nameTxt.text = petData.name
        self.levTxt.text = "Lv."..tostring(petData.lev)
        self.headImg.sprite = self.main.assetWrapper:GetSprite(AssetConfig.childhead, string.format("%s%s", petData.classes_type, petData.sex))
        self.descTxt.text = ""
    end

    for i,val in ipairs(list) do
        if self.valueTab[i] ~= nil then
            self.valueTab[i].text = tostring(val)
        end
    end
end

--传人的points列表是 体质，力量，智力，敏捷，耐力
function AddPointAttr:UpdateUpInfo(type, points)
    self.type = type

    local corporeity = points[1]
    local force = points[2]
    local brains = points[3]
    local agile = points[4]
    local endurance = points[5]

    if self.type == AddPointEumn.Type.Child then
        local petData = self.main.openArgs[2]
        local all = petData.lev * 5
        corporeity = Mathf.Round(((corporeity * 5)/50) * all)
        force = Mathf.Round(((force * 5)/50) * all)
        brains = Mathf.Round(((brains * 5)/50) * all)
        agile = Mathf.Round(((agile * 5)/50) * all)
        endurance = Mathf.Round(((endurance * 5)/50) * all)
    end

    local vals = {}
    local attrs = {}
    if corporeity ~= 0 then
        if self.type == AddPointEumn.Type.Role then
            attrs = DataAttr.data_get_point_attr[string.format("%d_%d_%d", 102, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.lev)].base_attr
            vals = self:Calculate(attrs, corporeity, vals)
        elseif self.type == AddPointEumn.Type.Pet then
            local petData = self.main.openArgs[2]
            attrs = DataPet.data_pet_point_attr[string.format("%d_%d", 102, petData.lev)].base_attr
            vals = self:Calculate(attrs, corporeity * petData.growth / 1000, vals)
        elseif self.type == AddPointEumn.Type.Child then
            local petData = self.main.openArgs[2]
            attrs = DataChild.data_point_attr[string.format("%d_%d", 102, petData.lev)].base_attr
            vals = self:Calculate(attrs, corporeity * petData.growth / 1000, vals)
        end
    end
    if force ~= 0 then
        if self.type == AddPointEumn.Type.Role then
            attrs = DataAttr.data_get_point_attr[string.format("%d_%d_%d", 101, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.lev)].base_attr
            vals = self:Calculate(attrs, force, vals)
        elseif self.type == AddPointEumn.Type.Pet then
            local petData = self.main.openArgs[2]
            attrs = DataPet.data_pet_point_attr[string.format("%d_%d", 101, petData.lev)].base_attr
            vals = self:Calculate(attrs, force * petData.growth / 1000, vals)
        elseif self.type == AddPointEumn.Type.Child then
            local petData = self.main.openArgs[2]
            attrs = DataChild.data_point_attr[string.format("%d_%d", 101, petData.lev)].base_attr
            vals = self:Calculate(attrs, force * petData.growth / 1000, vals)
        end
    end
    if brains ~= 0 then
        if self.type == AddPointEumn.Type.Role then
            attrs = DataAttr.data_get_point_attr[string.format("%d_%d_%d", 103, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.lev)].base_attr
            vals = self:Calculate(attrs, brains, vals)
        elseif self.type == AddPointEumn.Type.Pet then
            local petData = self.main.openArgs[2]
            attrs = DataPet.data_pet_point_attr[string.format("%d_%d", 103, petData.lev)].base_attr
            vals = self:Calculate(attrs, brains * petData.growth / 1000, vals)
        elseif self.type == AddPointEumn.Type.Child then
            local petData = self.main.openArgs[2]
            attrs = DataChild.data_point_attr[string.format("%d_%d", 103, petData.lev)].base_attr
            vals = self:Calculate(attrs, brains * petData.growth / 1000, vals)
        end
    end
    if agile ~= 0 then
        if self.type == AddPointEumn.Type.Role then
            attrs = DataAttr.data_get_point_attr[string.format("%d_%d_%d", 104, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.lev)].base_attr
            vals = self:Calculate(attrs, agile, vals)
        elseif self.type == AddPointEumn.Type.Pet then
            local petData = self.main.openArgs[2]
            attrs = DataPet.data_pet_point_attr[string.format("%d_%d", 104, petData.lev)].base_attr
            vals = self:Calculate(attrs, agile * petData.growth / 1000, vals)
        elseif self.type == AddPointEumn.Type.Child then
            local petData = self.main.openArgs[2]
            attrs = DataChild.data_point_attr[string.format("%d_%d", 104, petData.lev)].base_attr
            vals = self:Calculate(attrs, agile * petData.growth / 1000, vals)
        end
    end
    if endurance ~= 0 then
        if self.type == AddPointEumn.Type.Role then
            attrs = DataAttr.data_get_point_attr[string.format("%d_%d_%d", 105, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.lev)].base_attr
            vals = self:Calculate(attrs, endurance, vals)
        elseif self.type == AddPointEumn.Type.Pet then
            local petData = self.main.openArgs[2]
            attrs = DataPet.data_pet_point_attr[string.format("%d_%d", 105, petData.lev)].base_attr
            vals = self:Calculate(attrs, endurance * petData.growth / 1000, vals)
        elseif self.type == AddPointEumn.Type.Child then
            local petData = self.main.openArgs[2]
            attrs = DataChild.data_point_attr[string.format("%d_%d", 105, petData.lev)].base_attr
            vals = self:Calculate(attrs, endurance * petData.growth / 1000, vals)
        end
    end

    for name,obj in pairs(self.upObjTab) do
        if vals[name] ~= nil then
            local value = math.floor(vals[name] / 10) /10
            if value > 0 then
                self.upValTab[name].text = tostring(value)
                obj:SetActive(true)
            else
                obj:SetActive(false)
            end
        else
            obj:SetActive(false)
        end
    end
end

function AddPointAttr:Calculate(attrs, count, attr_val)
    for i,v in ipairs(attrs) do
        if attr_val[v.point_name] == nil then
            attr_val[v.point_name] = v.val * count
        else
            attr_val[v.point_name] = attr_val[v.point_name] + v.val * count
        end
    end
    return attr_val
end

function AddPointAttr:ClickHelp()
    --local role = RoleManager.Instance.RoleData
    if self.type == AddPointEumn.Type.Role then
        --chanceId 与 chanceData 互斥 提供外部直接写入文本接口  chanceId = 10002
        --TipsManager.Instance.model:ShowChance({gameObject = self.helpBtn,  chanceData = {string.format(TI18N("1、爵位已获得加点：<color='#ffff00'>%s</color>\n<color='#C7F9FF'>(完成<color='#ffff00'>爵位挑战</color>特定关卡，可获得额外属性点奖励)</color>\n2、道具已获得加点：<color='#ffff00'>%s</color>\n<color='#C7F9FF'>(使用<color='#ffff00'>仙品水晶粽</color>、部分<color='#ffff00'>时装</color>等可获得额外属性点奖励)</color>\n3、收藏图鉴碎片已获得加点：<color='#ffff00'>%s</color>\n<color='#C7F9FF'>(通过收藏部分<color='#ffff00'>图鉴碎片</color>，可获得额外属性点奖励)</color>\n4、等级突破获得加点：<color='#ffff00'>%s</color>\n<color='#C7F9FF'>(角色等级<color='#ffff00'>突破</color>后，可获得额外属性点奖励)</color>\n5、兑换点数：<color='#ffff00'>%s</color>\n<color='#C7F9FF'>(角色突破后，可通过消耗经验<color='#ffff00'>兑换属性点</color>)</color>"),role.honorPoint, role.itemPoint ,role.handbookPoint, role.levbreakPoint, role.levbreakExchangePoint),TI18N("属性点来源")}, special = true, isMutil = false})
        self.main:OpenRoleHelpTips()
    elseif self.type == AddPointEumn.Type.Pet then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpPet})
    elseif self.type == AddPointEumn.Type.Child then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpChild})
    end
end

function AddPointAttr:ClickHelp1()
    if self.type == AddPointEumn.Type.Role then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpNormal1})
    elseif self.type == AddPointEumn.Type.Pet then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpPet})
    elseif self.type == AddPointEumn.Type.Child then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.helpChild})
    end
end

function AddPointAttr:ClickExchangePoint()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exchangepointwindow)
end

-- 点击开启方案
function AddPointAttr:ClickOpenPlan()
    if RoleManager.Instance.RoleData.valid_plan == self.cur_select_option then
        NoticeManager.Instance:FloatTipsByString(TI18N("该方案已开启"))
        return
    end
    local str = ""
    if RoleManager.Instance.RoleData.change_plan_times == 0 then
        --是首次
        str = string.format(TI18N("今天<color='#ffff00'>首次</color>切换属性，不用消耗任何货币~\n确定要切换到<color='#ffff00'>方案%s</color>吗？"), self.cur_select_option)
    else
        local times = math.min(RoleManager.Instance.RoleData.change_plan_times + 1, 10)
        local cost = DataAttr.data_switch_attr_cost[times].coin
        local pstr = string.format(TI18N("，确认要切换到<color='#ffff00'>方案%s</color>吗？"), self.cur_select_option)
        if RoleManager.Instance.RoleData.change_plan_times > 10 then
            str = string.format(TI18N("今天切换属性次数超过<color='#ffff00'>10次</color>，需要消耗<color='#ffff00'>%s</color>{assets_2,90000}，确定要切换到<color='#ffff00'>方案%s</color>吗？"), cost, self.cur_select_option)
        else
            str = string.format(TI18N("今天第<color='#ffff00'>%s</color>次切换属性，需要消耗<color='#ffff00'>%s</color>{assets_2,90000}%s"), RoleManager.Instance.RoleData.change_plan_times + 1, cost, pstr)
        end
    end

    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.cancelSecond = 30
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function()
        RoleManager.Instance:Send10024(self.cur_select_option)
    end
    confirmData.content = str
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 检查突破属性点兑换引导
function AddPointAttr:CheckGuideBreak()
    -- if not RoleManager.Instance:CheckBreakGuide() then
    --     return
    -- end

    -- local func = function()
    --     if self.guideBreak == nil then
    --         self.guideBreak = GuideBreakPointSecond.New(self)
    --     end
    --     self.guideBreak:Show()
    -- end
    -- LuaTimer.Add(100, func)
end
