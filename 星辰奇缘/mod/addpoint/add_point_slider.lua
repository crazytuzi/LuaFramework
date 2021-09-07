-- --------------------
-- 加点滑动操作
-- hosr
-- -----------------------
AddPointSlider = AddPointSlider or BaseClass()

function AddPointSlider:__init(gameObject, main,type)
    self.type = type
    self.main = main
    self.gameObject = gameObject
    self.valueTab = {}
    self.addTab = {}
    self.sliderTab = {}
    self.secFillTab = {}
    self.equipsAddTab = {}

    --自动加点的配置
    self.__set_points = nil
    --配置自动加点时的最大点数
    self.__setting_point = 5

    --当前可操作的总点数
    self.__distribute = 0
    --剩余可操作的点数
    self.distribute = 0

    --原本有的点数
    self.__corporeity = 0
    self.__force = 0
    self.__brains = 0
    self.__agile = 0
    self.__endurance = 0

    --装备加成的点数, 分别对应体质， 力量， 智力，敏捷，耐力
    self.equipAdditonalPoints = {0, 0, 0, 0, 0}

    --宠物加成的点数, 分别对应体质， 力量， 智力，敏捷，耐力
    self.petAdditonalPoints = {0,0,0,0,0}

    --已经加的点数
    self.corporeity = 0
    self.force = 0
    self.brains = 0
    self.agile = 0
    self.endurance = 0

    self.code = {
        corporeity = 1 --体质
        ,force = 2 --力量
        ,brains = 3 --智力
        ,agile = 4 --敏捷
        ,endurance = 5 --耐力
    }

    self.tips_content = {
        TI18N("增加体质可提升生命、物防、攻速"),
        TI18N("增加力量可提升物攻、魔攻、攻速"),
        TI18N("增加智力可提升魔攻、魔防"),
        TI18N("增加敏捷可提升物防、魔防、攻速"),
        TI18N("增加耐力可提升物防、魔防、攻速")
    }

    self.descRole = {
        TI18N("1.提升每级可获得5点分配点"),
        TI18N("2.30级前由系统进行自动分配"),
        TI18N("3.分配后相应的属性可获得提升")
    }
    self.descPet = {
        TI18N("每提升一级，会获得10点属性点，系统自动分配5点，剩余5点自由分配")
        ,TI18N("")
        ,TI18N("体质影响：<color=#00ff00>大量生命+微量魔防+微量攻速</color>")
        ,TI18N("力量影响：<color=#00ff00>物攻+少量魔防+微量攻速</color>")
        ,TI18N("智力影响：<color=#00ff00>魔法+魔攻+魔防</color>")
        ,TI18N("敏捷影响：<color=#00ff00>大量攻速</color>")
        ,TI18N("耐力影响：<color=#00ff00>大量物防+微量魔防+微量攻速</color>")
    }
    self.descChild = {
        TI18N("孩子每级拥有10属性点，其中50%由系统默认分配，剩余50%将按照加点方案自动分配")
        ,TI18N("")
        ,TI18N("体质影响：<color=#00ff00>大量生命+微量魔防+微量攻速</color>")
        ,TI18N("力量影响：<color=#00ff00>物攻+少量魔防+微量攻速</color>")
        ,TI18N("智力影响：<color=#00ff00>魔法+魔攻+魔防</color>")
        ,TI18N("敏捷影响：<color=#00ff00>大量攻速</color>")
        ,TI18N("耐力影响：<color=#00ff00>大量物防+微量魔防+微量攻速</color>")
    }

    self.tips_equipPoint = {
        TI18N("该属性为装备附加属性值"),
        TI18N("可通过装备<color=#ffff00>重铸</color>进行改变")
    }
    self.guideRoleStep = 1
    self.guidePetStep = 1

    self:InitPanel()

    self.washFunc = function() self.main:Wash() end

    self.guideScript = nil
    self.guideEffect = nil
    self.guideEffect2 = nil
end

function AddPointSlider:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_point_preview_back, self.on_preview_back)
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end

    if self.guideEffect2 ~= nil then
        self.guideEffect2:DeleteMe()
        self.guideEffect2 = nil
    end
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end

function AddPointSlider:InitPanel()
    self.transform = self.gameObject.transform
    self.RightBottomCon = self.transform:Find("RightBottomCon")
    self.UnOpenCon = self.RightBottomCon:Find("UnOpenCon")
    self.OpenCon = self.RightBottomCon:Find("OpenCon")
    self.OpenCon = self.RightBottomCon:Find("OpenCon")
    self.OpenCon:Find("SetButton"):GetComponent(Button).onClick:AddListener(function() self:OnSet() end)
    self.OpenCon:Find("SureButton"):GetComponent(Button).onClick:AddListener(function() self:OnSure() end)
    self.OpenCon:Find("AutoButton"):GetComponent(Button).onClick:AddListener(function() self:OnAuto() end)
    self.childDescObj = self.RightBottomCon:Find("Desc").gameObject
    self.childDescObj:SetActive(false)
    self.childDescTxt = self.childDescObj:GetComponent(Text)

    self.autoBtn = self.OpenCon:Find("AutoButton").gameObject
    self.autoBtntxt = self.OpenCon:Find("AutoButton/Text"):GetComponent(Text)
    self.setBtn = self.OpenCon:Find("SetButton").gameObject
    self.sureBtn = self.OpenCon:Find("SureButton").gameObject
    self.sureBtntxt = self.OpenCon:Find("SureButton/Text"):GetComponent(Text)

    local distribute = self.transform:Find("Distribute").gameObject.transform
    self.helpBtn = distribute:Find("HelpButton").gameObject
    self.helpBtn:GetComponent(Button).onClick:AddListener(function() self:OnHelp() end)
    self.roleHelpBtn = distribute:Find("RoleHelpButton").gameObject
    self.roleHelpBtn:GetComponent(Button).onClick:AddListener(function() self:OnHelp() end)
    self.roleHelpBtn:SetActive(false)

    self.container = distribute:Find("Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.distTxt = distribute:Find("Container/Value"):GetComponent(Text)
    self.distTxt.text = "0"
    self.descTxt = distribute:Find("Container/Desc"):GetComponent(Text)
    self.descTxt.text = TI18N("当前已分配点数:<color='#8de92a'>0</color>")

    self.washBtn = distribute:Find("Container/WashButton").gameObject
    self.washBtn:GetComponent(Button).onClick:AddListener(function() self:OnWash() end)

    self.washRedPoint = self.washBtn.transform:Find("RedPoint").gameObject
    self.washTextObj = self.washBtn.transform:Find("Text").gameObject

    local func = function(trans, _index)
        local index = _index
        trans:Find("MinusButton"):GetComponent(Button).onClick:AddListener(function() self:Minus(index) end)
        trans:Find("PlusButton"):GetComponent(Button).onClick:AddListener(function() self:Plus(index) end)
        self.valueTab[index] = trans:Find("Value"):GetComponent(Text)
        self.addTab[index] = trans:Find("AddedPoints"):GetComponent(Text)
        self.equipsAddTab[index] = trans:Find("EquipsAdditions").gameObject
        --self.equipsAddTab[index].transform.anchoredPosition = Vector3(440, 0 ,0)
        --self.equipsAddTab[index].transform.sizeDelta = Vector2(70, 30)
        self.equipsAddTab[index]:GetComponent(Button).onClick:AddListener(function () self:OnAdditionalPointClick( index ) end)
        self.sliderTab[index] = trans:Find("Slider"):GetComponent(Slider)
        self.sliderTab[index].onValueChanged:AddListener(function (val) self:Slide(index, val) end)
        self.secFillTab[index] = trans:Find("Slider/Fill Area/Fill2"):GetComponent(RectTransform)
        trans:Find("Image"):GetComponent(Button).onClick:AddListener(function() print(self.tips_content[index]) end)
    end
    local option = self.transform:Find("Option").gameObject.transform
    func(option:Find("Corporeity"), 1)
    func(option:Find("Force"), 2)
    func(option:Find("Brains"), 3)
    func(option:Find("Agile"), 4)
    func(option:Find("Endurance"), 5)

    self.gameObject:SetActive(true)

    self.on_preview_back = function(data)
        self:update_preview(data)
    end
    EventMgr.Instance:AddListener(event_name.role_point_preview_back, self.on_preview_back)
end

function AddPointSlider:OnSure()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
    if self.type == AddPointEumn.Type.Child then
        if self.__distribute == 0 then
            -- 没有可分配点，是重置操作
            self:OnWash()
        else
            local all = self.corporeity + self.force + self.brains + self.agile + self.endurance
            if all == 10 then
                self.main:SureAddPoint({self.corporeity * 5, self.force * 5, self.brains * 5, self.agile * 5, self.endurance * 5})
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("总分配达100%才能保存"))
            end
        end
    else
        self.main:SureAddPoint({self.corporeity, self.force, self.brains, self.agile, self.endurance})
        if self.type == AddPointEumn.Type.Role then
           self:ShowAllEquipPoint(true)
        end
    end
    self.guideRoleStep = 4
    self.guidePetStep = 4
    self:CheckGuideAddPoint()
end

function AddPointSlider:OnAuto()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
    self:Auto()
    self.guideRoleStep = 3
    self.guidePetStep = 3
    self:CheckGuideAddPoint()
end

function AddPointSlider:OnSet()
    self.main:OpenSet()
end

function AddPointSlider:OnWash()
    if self.type == AddPointEumn.Type.Role then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal

        local role = RoleManager.Instance.RoleData
        table.sort(RoleManager.Instance.RoleData.plan_data, function(a,b) return a.index < b.index end)
        local currPlan = RoleManager.Instance.RoleData.plan_data[RoleManager.Instance.RoleData.valid_plan]
        -- 已经加过的点数
        local alreadyPoint = currPlan.strength + currPlan.constitution + currPlan.magic + currPlan.agility + currPlan.endurance
        if alreadyPoint == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有分配过点数，无需洗点"))
        else
            if role.first_free == 1 or role.lev >= 40 then
                data.content = string.format(TI18N("花费{assets_1,90002,%s}进行洗点，将返还<color='#ffff00'>%s</color>可分配点数，是否继续？"), math.floor(alreadyPoint * 2.5), alreadyPoint)
                data.sureLabel = TI18N("确 定")
            else
                data.content = TI18N("你的当前等级<color='#00ff00'><40级</color>，可以<color='#00ff00'>免费</color>进行一次洗点。")
                data.sureLabel = TI18N("免费洗点")
            end
            data.cancelLabel = TI18N("取 消")
            data.sureCallback = self.washFunc
            NoticeManager.Instance:ConfirmTips(data)
        end
    elseif self.type == AddPointEumn.Type.Pet then
        local petData = self.main.openArgs[2]

        if petData.lev * 5 - petData.point + petData.feed_point == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有分配过点数，无需洗点"))
        else
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            if petData.free_reset_flag == 1 or petData.lev >= 40 then
                local point = petData.lev * 5 - petData.point + petData.feed_point
                data.content = string.format(TI18N("花费{assets_1,90000,%s}进行洗点，将返还<color='#ffff00'>%s</color>可分配点数，是否继续？"), math.floor(point * 1000), point)
                data.sureLabel = TI18N("确 定")
            else
                data.content = TI18N("该宠物等级<color='00ff00'>＜40级</color>，可以<color='00ff00'>免费</color>进行一次洗点。")
                data.sureLabel = TI18N("免费洗点")
            end
            data.cancelLabel = TI18N("取 消")
            data.sureCallback = self.washFunc
            NoticeManager.Instance:ConfirmTips(data)
        end
    elseif self.type == AddPointEumn.Type.Child then
        if self.__distribute == 20 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有设置过加点，无需重置"))
        else
            local petData = self.main.openArgs[2]
            local all = petData.lev * 5
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("花费{assets_1,90000,500000}进行重置，将返还<color='#ffff00'>50%</color>可分配点数，是否继续？")
            data.sureLabel = TI18N("确 定")
            data.cancelLabel = TI18N("取 消")
            data.sureCallback = self.washFunc
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
end

function AddPointSlider:OnHelp()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
    if self.type == AddPointEumn.Type.Role then
        self.main:ShowTips()
        self.guideRoleStep = 2
    elseif self.type == AddPointEumn.Type.Pet then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.descPet})
        self.guidePetStep = 2
        self:CheckGuideAddPoint()
    elseif self.type == AddPointEumn.Type.Child then
        TipsManager.Instance:ShowText({gameObject = self.helpBtn, itemData = self.descChild})
    end



end

--减1更新
function AddPointSlider:Minus(index)
    if self.distribute < self.__distribute and self.distribute >= 0 then
        if index == self.code.corporeity then
            self.corporeity = self.corporeity - 1
            self.corporeity = self.corporeity > 0 and self.corporeity or 0
        elseif index == self.code.force then
            self.force = self.force - 1
            self.force = self.force > 0 and self.force or 0
        elseif index == self.code.brains then
            self.brains = self.brains - 1
            self.brains = self.brains > 0 and self.brains or 0
        elseif index == self.code.agile then
            self.agile = self.agile - 1
            self.agile = self.agile > 0 and self.agile or 0
        elseif index == self.code.endurance then
            self.endurance = self.endurance - 1
            self.endurance = self.endurance > 0 and self.endurance or 0
        end
        self:UpdateVal()
    end
end

--加1更新
function AddPointSlider:Plus(index)
    if self.distribute > 0 then
        if index == self.code.corporeity then
            self.corporeity = self.corporeity + 1
        elseif index == self.code.force then
            self.force = self.force + 1
        elseif index == self.code.brains then
            self.brains = self.brains + 1
        elseif index == self.code.agile then
            self.agile = self.agile + 1
        elseif index == self.code.endurance then
            self.endurance = self.endurance + 1
        end
        self:UpdateVal()
    end
end

--滑动更新
function AddPointSlider:Slide(index, value)
    local unchange = true
    if index == self.code.corporeity then
        if value < self.__corporeity then
            self.corporeity = 0
        elseif value > self.__corporeity + self.corporeity + self.distribute then
            self.corporeity = self.corporeity + self.distribute
        else
            self.corporeity = value - self.__corporeity
        end
        if self.__corporeity == 0 then unchange = false end
    elseif index == self.code.force then
        if value < self.__force then
            self.force = 0
        elseif value > self.__force + self.force + self.distribute then
            self.force = self.force + self.distribute
        else
            self.force = value - self.__force
        end
        if self.__force == 0 then unchange = false end
    elseif index == self.code.brains then
        if value < self.__brains then
            self.brains = 0
        elseif value > self.__brains + self.brains + self.distribute then
            self.brains = self.brains + self.distribute
        else
            self.brains = value - self.__brains
        end
        if self.__brains == 0 then unchange = false end
    elseif index == self.code.agile then
        if value < self.__agile then
            self.agile = 0
        elseif value > self.__agile + self.agile + self.distribute then
            self.agile = self.agile + self.distribute
        else
            self.agile = value - self.__agile
        end
        if self.__agile == 0 then unchange = false end
    elseif index == self.code.endurance then
        if value < self.__endurance then
            self.endurance = 0
        elseif value > self.__endurance + self.endurance + self.distribute then
            self.endurance = self.endurance + self.distribute
        else
            self.endurance = value - self.__endurance
        end
        if self.__endurance == 0 then unchange = false end
    end
    self:UpdateVal(true)
end

function AddPointSlider:UpdateVal(bySlider)
    self.distribute = self.__distribute - self.corporeity - self.force - self.brains - self.agile - self.endurance
    local val1 =  self.__corporeity + self.corporeity
    local val2 =  self.__force + self.force
    local val3 =  self.__brains + self.brains
    local val4 =  self.__agile + self.agile
    local val5 =  self.__endurance + self.endurance

    if self.type == AddPointEumn.Type.Child then
        self.distTxt.text = string.format("%s%%", self.distribute * 5)
        self.valueTab[1].text = string.format("%s%%", self.__corporeity * 5 + self.corporeity * 5)
        self.valueTab[2].text = string.format("%s%%", self.__force * 5 + self.force * 5)
        self.valueTab[3].text = string.format("%s%%", self.__brains * 5 + self.brains * 5)
        self.valueTab[4].text = string.format("%s%%", self.__agile * 5 + self.agile * 5)
        self.valueTab[5].text = string.format("%s%%", self.__endurance * 5 + self.endurance * 5)
    elseif self.type == AddPointEumn.Type.Pet then
        self.distTxt.text = tostring(self.distribute)
        local petData = self.main.openArgs[2]
        local attr = PetManager.Instance.model:GetPetGradeAttr(petData)
        for k, v in pairs(self.petAdditonalPoints) do
            attr[k] = attr[k] + self.petAdditonalPoints[k]
        end
        self.valueTab[1].text = tostring(val1) + attr[1]
        self.valueTab[2].text = tostring(val2) + attr[2]
        self.valueTab[3].text = tostring(val3) + attr[3]
        self.valueTab[4].text = tostring(val4) + attr[4]
        self.valueTab[5].text = tostring(val5) + attr[5]
    else
        self.distTxt.text = tostring(self.distribute)
        self.valueTab[1].text = tostring(val1)
        self.valueTab[2].text = tostring(val2)
        self.valueTab[3].text = tostring(val3)
        self.valueTab[4].text = tostring(val4)
        self.valueTab[5].text = tostring(val5)
    end

    -- if not bySlider then
        self.sliderTab[1].value =  val1
        self.sliderTab[2].value =  val2
        self.sliderTab[3].value =  val3
        self.sliderTab[4].value =  val4
        self.sliderTab[5].value =  val5
    -- end

    -- 如果是角色加点界面就显示装备加成点数

     local show = true
     if self.type == AddPointEumn.Type.Role then
       if self.corporeity ~= 0 then
          show = false
       elseif self.force ~= 0 then
          show = false
       elseif  self.brains ~= 0 then
          show = false
       elseif self.agile ~= 0 then
          show = false
       elseif self.endurance ~= 0 then
          show = false
       end
       self:ShowAllEquipPoint(show)
     end

     local show = true
     if self.type == AddPointEumn.Type.Pet then
       if self.corporeity ~= 0 then
          show = false
       elseif self.force ~= 0 then
          show = false
       elseif  self.brains ~= 0 then
          show = false
       elseif self.agile ~= 0 then
          show = false
       elseif self.endurance ~= 0 then
          show = false
       end
       self:ShowAllEquipPoint(show)
     end


    if self.type == AddPointEumn.Type.Child then
        self.addTab[1].text = (self.corporeity == 0 and "" or "+"..(self.corporeity*5).."%")
        self.addTab[2].text = (self.force == 0 and "" or "+"..(self.force*5).."%")
        self.addTab[3].text = (self.brains == 0 and "" or "+"..(self.brains*5).."%")
        self.addTab[4].text = (self.agile == 0 and "" or "+"..(self.agile*5).."%")
        self.addTab[5].text = (self.endurance == 0 and "" or "+"..(self.endurance*5).."%")
    else
        self.addTab[1].text = tostring((self.corporeity == 0 and "" or "+"..self.corporeity))
        self.addTab[2].text = tostring((self.force == 0 and "" or "+"..self.force))
        self.addTab[3].text = tostring((self.brains == 0 and "" or "+"..self.brains))
        self.addTab[4].text = tostring((self.agile == 0 and "" or "+"..self.agile))
        self.addTab[5].text = tostring((self.endurance == 0 and "" or "+"..self.endurance))
    end

    --通知外部更新
    self.main:PointChange({self.corporeity, self.force, self.brains, self.agile, self.endurance})

    self:UpdataDesc()
end

--更新预览显示
function AddPointSlider:update_preview(data)
    self:Show(AddPointEumn.Type.Role, self.main.attr.cur_select_option, data)
end

-- info = {_dis, _cor, _for, _bra, _agi, __end}
function AddPointSlider:Show(type, valid_plan, valid_plan_temp_data)

    self.type = type
    local canGuide = false
    local info = {}
    self.setBtn:SetActive(true)
    self.autoBtn:SetActive(true)
    self.childDescObj:SetActive(false)
    self.autoBtntxt.text = TI18N("智能加点")
    self.sureBtntxt.text = TI18N("确认加点")
    if self.type == AddPointEumn.Type.Role then
        BaseUtils.dump(RoleManager.Instance.RoleData,"人物所有属性=====================================")
        local role = RoleManager.Instance.RoleData
        local option = nil
        local point = role.point

        if valid_plan ==nil then
            valid_plan = RoleManager.Instance.RoleData.valid_plan
        end

        for i=1,#RoleManager.Instance.RoleData.plan_data do
            if RoleManager.Instance.RoleData.plan_data[i].index == valid_plan then
                option = RoleManager.Instance.RoleData.plan_data[i]
                break
            end
        end

        if option == nil then
            --空方案
            option = {}
            option.constitution = 0
            option.strength = 0
            option.magic = 0
            option.agility = 0
            option.endurance = 0
            option.pre_con = 0
            option.pre_str = 0
            option.pre_magic = 0
            option.pre_agi = 0
            option.pre_end = 0
        end


        if RoleManager.Instance.RoleData.point_data ~= nil then
            for i=1,#RoleManager.Instance.RoleData.point_data do
                if RoleManager.Instance.RoleData.point_data[i].index == valid_plan then
                    point = RoleManager.Instance.RoleData.point_data[i].point
                    break
                end
            end
        end

        if valid_plan_temp_data ~= nil then
            info = {point, valid_plan_temp_data.constitution, valid_plan_temp_data.strength, valid_plan_temp_data.magic, valid_plan_temp_data.agility, valid_plan_temp_data.endurance}
        elseif valid_plan == RoleManager.Instance.RoleData.valid_plan then
            --从10001取
            info = {point, role.constitution, role.strength, role.magic, role.agility, role.endurance}
        else
             --从10007取，旧的处理方式，客户端自己算
            local cur_option = nil
            for i=1,#RoleManager.Instance.RoleData.plan_data do
                if RoleManager.Instance.RoleData.plan_data[i].index == RoleManager.Instance.RoleData.valid_plan then
                    cur_option = RoleManager.Instance.RoleData.plan_data[i]
                    break
                end
            end

            local _constitution  = role.constitution - cur_option.constitution + option.constitution
            local _strength = role.strength - cur_option.strength + option.strength
            local _magic = role.magic - cur_option.magic + option.magic
            local _agility = role.agility - cur_option.agility + option.agility
            local _endurance = role.endurance - cur_option.endurance + option.endurance
            info = {point, _constitution, _strength, _magic, _agility, _endurance}
        end

        self.__set_points = {option.pre_con, option.pre_str, option.pre_magic, option.pre_agi, option.pre_end}


        local has_sign_point = role.lev * 10 + role:ExtraPoint() - point

        self.descTxt.text = string.format(TI18N("当前已分配点数:<color='#8de92a'>%s</color>"), has_sign_point)
        self.helpBtn:SetActive(false)
        self.roleHelpBtn:SetActive(true)
        self.containerRect.anchoredPosition = Vector2(15, 0)

        if RoleManager.Instance.RoleData.first_free == 0 and RoleManager.Instance.RoleData.lev < 40 then
            self.washTextObj:SetActive(true)
            self.washRedPoint:SetActive(true)
        else
            self.washTextObj:SetActive(false)
            self.washRedPoint:SetActive(false)
        end

        self:UpdateEquipAddPoints()
    elseif self.type == AddPointEumn.Type.Pet then
        self.washBtn:SetActive(true)
        self.autoBtntxt.text = TI18N("智能加点")

        local petData = self.main.openArgs[2]
        info = {petData.point, petData.p_con, petData.p_str, petData.p_mag, petData.p_agi, petData.p_end}

        if petData.pre_con == nil then
            self.__set_points = nil
            PetManager.Instance:Send10521(petData.id)
        else
            canGuide = true
            self.__set_points = {petData.pre_con, petData.pre_str, petData.pre_mag, petData.pre_agi, petData.pre_end}
        end
        self.descTxt.text = string.format(TI18N("当前已分配点数:<color='#8de92a'>%s</color>"), petData.lev * 10 - petData.point + petData.feed_point)
        self.helpBtn:SetActive(true)
        self.roleHelpBtn:SetActive(false)
        self.containerRect.anchoredPosition = Vector2(80, 0)

        if petData.free_reset_flag == 0 and petData.lev < 40 then
            self.washTextObj:SetActive(true)
            self.washRedPoint:SetActive(true)
        else
            self.washTextObj:SetActive(false)
            self.washRedPoint:SetActive(false)
        end

        self:ShowAllEquipPoint(false)
    elseif self.type == AddPointEumn.Type.Child then
        self.setBtn:SetActive(false)
        self.washBtn:SetActive(false)
        self.autoBtn:SetActive(false)
        self.childDescObj:SetActive(true)

        local petData = self.main.openArgs[2]
        local point = 50 - (petData.pre_con + petData.pre_str + petData.pre_mag + petData.pre_agi + petData.pre_end)
        info = {point / 5, 2 + petData.pre_con / 5, 2 + petData.pre_str / 5, 2 + petData.pre_mag / 5, 2 + petData.pre_agi / 5, 2 + petData.pre_end / 5}
        self.descTxt.text = ""
        self.helpBtn:SetActive(true)
        self.roleHelpBtn:SetActive(false)
        self.containerRect.anchoredPosition = Vector2(80, 0)

        self.descTxt.text = TI18N("默认已分配:<color='#8de92a'> 50%</color>")

        -- if petData.free_reset_flag == 0 and petData.lev < 40 then
        --     self.washTextObj:SetActive(true)
        --     self.washRedPoint:SetActive(true)
        -- else
            self.washTextObj:SetActive(false)
            self.washRedPoint:SetActive(false)
        -- end

        if point == 0 then
            self.sureBtntxt.text = TI18N("重置加点")
        else
            self.sureBtntxt.text = TI18N("确认加点")
        end

        self:ShowAllEquipPoint(false)
    end

    self.distribute = info[1]
    self.__distribute = info[1]
    self.__corporeity = info[2]
    self.__force = info[3]
    self.__brains =  info[4]
    self.__agile = info[5]
    self.__endurance = info[6]
    self.corporeity = 0
    self.force = 0
    self.brains = 0
    self.agile = 0
    self.endurance = 0


    local max = self.__distribute + self.__corporeity + self.__force + self.__brains + self.__agile + self.__endurance
    for _,slider in pairs(self.sliderTab) do
        if self.type == AddPointEumn.Type.Child then
            slider.maxValue = 12
        else
            slider.maxValue = max
        end
    end
    self:UpdateVal()
    for index,rect in pairs(self.secFillTab) do
        local slider = self.sliderTab[index]
        local val = 150 * (slider.value/slider.maxValue)
        rect.sizeDelta = Vector2(val ,21)
    end

    if canGuide then
        LuaTimer.Add(100, function() self:CheckGuide() end)
    end
end

function AddPointSlider:UpdataDesc()
    if self.type ~= AddPointEumn.Type.Child then
        return
    end

    if self.__distribute == 0 then
        self.childDescObj:SetActive(false)
    else
        self.childDescObj:SetActive(true)
        if self.distribute == 0 then
            self.childDescTxt.text = string.format(TI18N("当前配点情况:\n%s"), self:GetStr())
        else
            self.childDescTxt.text = TI18N("总分配100%时可保存")
        end
    end
end

function AddPointSlider:GetStr()
    local str = ""
    local list = {}
    if self.corporeity ~= 0 then
        local s = string.format(TI18N("%s体质"), string.format("%.1f", (self.corporeity * 5 / 10)))
        table.insert(list, s)
    end
    if self.force ~= 0 then
        local s = string.format(TI18N("%s力量"), string.format("%.1f", (self.force * 5 / 10)))
        table.insert(list, s)
    end
    if self.brains ~= 0 then
        local s = string.format(TI18N("%s智力"), string.format("%.1f", (self.brains * 5 / 10)))
        table.insert(list, s)
    end
    if self.agile ~= 0 then
        local s = string.format(TI18N("%s敏捷"), string.format("%.1f", (self.agile * 5 / 10)))
        table.insert(list, s)
    end
    if self.endurance ~= 0 then
        local s = string.format(TI18N("%s耐力"), string.format("%.1f", (self.endurance * 5 / 10)))
        table.insert(list, s)
    end

    -- for i,v in ipairs(list) do
    --     if str == "" then
    --         str = v
    --     else
    --         str = str .. "、" .. v
    --     end
    -- end
    return table.concat(list, "、")
end

function AddPointSlider:Auto()
    -- BaseUtils.dump(self.__set_points)
    if self.__set_points ~= nil then
        if self.type ~= AddPointEumn.Type.Role then -- 如果是宠物
            if self.__set_points[1] + self.__set_points[2] + self.__set_points[3] + self.__set_points[4] + self.__set_points[5] == 0 then
                local petData = self.main.openArgs[2]
                local set_data = DataPet.data_pet_point_add[petData.base_id]
                self.__set_points = {set_data.p_con, set_data.p_str, set_data.p_mag, set_data.p_agi, set_data.p_end}
            end
        end

        local ratio = math.floor(self.__distribute / self.__setting_point)
        local lesspoint = self.__distribute % self.__setting_point

        local func = function(base, index)
            base = self.__set_points[index] * ratio
            if lesspoint > 0 then
                if lesspoint > self.__set_points[index] then
                    base = base + self.__set_points[index]
                else
                    base = base + lesspoint
                end
                lesspoint = lesspoint - self.__set_points[index]
            end
            return base,lesspoint
        end

        self.corporeity,lesspoint = func(self.corporeity, 1)
        self.force,lesspoint = func(self.force, 2)
        self.brains,lesspoint = func(self.brains, 3)
        self.agile,lesspoint = func(self.agile, 4)
        self.endurance,lesspoint = func(self.endurance, 5)
    else
        self.corporeity = 0
        self.force = 0
        self.brains = 0
        self.agile = 0
        self.endurance = 0
    end
    self:UpdateVal()
end

function AddPointSlider:CheckGuide()
    local num = DramaManager.Instance.onceDic[DramaEumn.OnceGuideType.PetAddpoint] or 0
    if not self.type == AddPointEumn.Type.Role and self.distribute > 0 and RoleManager.Instance.RoleData.lev < 40 and num == 0 then
        -- 宠物引导
        if self.guideScript == nil then
            self.guideScript = GiudeAddpointPet.New(self)
            self.guideScript:Show()
        end
    end
end


--切换底部加点方案开启状态
function AddPointSlider:Switch_bottom_state(state)
    if self.type == AddPointEumn.Type.Child then
        return
    end

    if state then
        self.UnOpenCon.gameObject:SetActive(false)
        self.OpenCon.gameObject:SetActive(true)
        self.washBtn:SetActive(true)
    else
        self.UnOpenCon.gameObject:SetActive(true)
        self.OpenCon.gameObject:SetActive(false)
        self.washBtn:SetActive(false)
    end
end

--更新装备附加点数
function AddPointSlider:UpdateEquipAddPoints()
    for k, v in pairs(self.equipAdditonalPoints) do
        if self.equipAdditonalPoints[k] < 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = "(" .. tostring(self.equipAdditonalPoints[k]) .. ")"
           self.equipsAddTab[k]:GetComponent(Text).color = Color.red
        elseif self.equipAdditonalPoints[k] > 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = "(+" .. tostring(self.equipAdditonalPoints[k]) .. ")"
        end

        if self.equipAdditonalPoints[k] == 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = " "
        end
    end
end

--更新宠物附加点数
function AddPointSlider:UpdatePetAddPoints()
     self.distribute = self.__distribute - self.corporeity - self.force - self.brains - self.agile - self.endurance
    local val1 =  self.__corporeity + self.corporeity
    local val2 =  self.__force + self.force
    local val3 =  self.__brains + self.brains
    local val4 =  self.__agile + self.agile
    local val5 =  self.__endurance + self.endurance

    self.valueTab[1].text = tostring(val1)
    self.valueTab[2].text = tostring(val2)
    self.valueTab[3].text = tostring(val3)
    self.valueTab[4].text = tostring(val4)
    self.valueTab[5].text = tostring(val5)

    local petData = self.main.openArgs[2]
    local attr = PetManager.Instance.model:GetPetGradeAttr(petData)
    for k, v in pairs(self.petAdditonalPoints) do
        attr[k] = attr[k] + self.petAdditonalPoints[k]
    end

    for k, v in pairs(attr) do
        if attr[k] < 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = "(" .. tostring(attr[k]) .. ")"
           self.equipsAddTab[k]:GetComponent(Text).color = Color.red
        elseif attr[k] > 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = "(+" .. tostring(attr[k]) .. ")"
        end

        if attr[k] == 0 then
           self.equipsAddTab[k]:GetComponent(Text).text = " "
        end

        self.valueTab[k].text =tostring(tonumber(self.valueTab[k].text) + attr[k])
    end
end

--点击装备附加点数时显示文字提示
function AddPointSlider:OnAdditionalPointClick( id )
    if self.equipsAddTab[id]:GetComponent(Text).text ~= " " then
        if self.type == AddPointEumn.Type.Pet then
            TipsManager.Instance:ShowText({gameObject = self.equipsAddTab[id], itemData = {TI18N("<color='#ffff00'>符石和宝物</color>等额外附加属性")}})
        else
            TipsManager.Instance:ShowText({gameObject = self.equipsAddTab[id], itemData = self.tips_equipPoint})
        end
    end
end


--显示/隐藏所有装备附加点数
function AddPointSlider:ShowAllEquipPoint( show )
    self.equipsAddTab[1]:SetActive(show)
    self.equipsAddTab[2]:SetActive(show)
    self.equipsAddTab[3]:SetActive(show)
    self.equipsAddTab[4]:SetActive(show)
    self.equipsAddTab[5]:SetActive(show)
end

function AddPointSlider:CheckGuideAddPoint()
    if self.main.isStartGuide == true then
        if self.guideEffect == nil then
            self.guideEffect = BibleRewardPanel.ShowEffect(20104,self.roleHelpBtn.transform,Vector3(0.9,0.9,1), Vector3(60,0,-400))
        end

        if self.guideEffect ~= nil then
            self.guideEffect:SetActive(false)
        end

        if self.guideEffect2 ~= nil then
            self.guideEffect2:SetActive(false)
        end

        if self.type == AddPointEumn.Type.Role then
            -- if self.guideRoleStep == 1 then
            --     TipsManager.Instance:ShowGuide({gameObject = self.roleHelpBtn.gameObject, data = TI18N("看看加点说明吧"), forward = TipsEumn.Forward.Left})
            --     if self.guideEffect ~= nil then
            --         self.guideEffect.transform:SetParent(self.roleHelpBtn.transform)
            --         self.guideEffect.transform.localScale = Vector3(0.9,0.9,1)
            --         self.guideEffect.transform.localPosition = Vector3(60,0,-400)
            --         self.guideEffect.transform.localRotation = Quaternion.identity
            --         self.guideEffect:SetActive(true)
            --     end
            -- elseif self.guideRoleStep == 2 then
            --     TipsManager.Instance:ShowGuide({gameObject = self.OpenCon:Find("AutoButton").gameObject, data = TI18N("试试给角色加点吧"), forward = TipsEumn.Forward.Left})
            --     if self.guideEffect ~= nil then
            --         self.guideEffect.transform:SetParent(self.OpenCon:Find("AutoButton").transform)
            --         self.guideEffect.transform.localScale = Vector3(1,1,1)
            --         self.guideEffect.transform.localPosition = Vector3(0,0,-400)
            --         self.guideEffect.transform.localRotation = Quaternion.identity
            --         self.guideEffect:SetActive(true)
            --     end
            -- elseif self.guideRoleStep == 3 then
            --     TipsManager.Instance:ShowGuide({gameObject = self.OpenCon:Find("SureButton").gameObject, data = TI18N("确认加点可保存加点方案"), forward = TipsEumn.Forward.Left})
            --     if self.guideEffect ~= nil then
            --         self.guideEffect.transform:SetParent(self.OpenCon:Find("SureButton").transform)
            --         self.guideEffect.transform.localScale = Vector3(1,1,1)
            --         self.guideEffect.transform.localPosition = Vector3(0,0,-400)
            --         self.guideEffect.transform.localRotation = Quaternion.identity
            --         self.guideEffect:SetActive(true)
            --     end
            -- elseif self.guideRoleStep == 4 then
            --     if self.guideEffect2 == nil then
            --         self.guideEffect2 = BibleRewardPanel.ShowEffect(20103,self.main.transform:Find("Window/CloseButton").transform,Vector3(0.8,0.8,1), Vector3(0,0,-400))
            --     end
            --     self.guideEffect2:SetActive(true)
            -- end
        elseif self.type == AddPointEumn.Type.Pet and PetManager.Instance.model.cur_petdata.point > 0 then
            if self.guidePetStep == 1 then
                TipsManager.Instance:ShowGuide({gameObject = self.helpBtn.gameObject, data = TI18N("不同属性的作用天差地别呢"), forward = TipsEumn.Forward.Right})
                if self.guideEffect2 == nil then
                    self.guideEffect2 = BibleRewardPanel.ShowEffect(20103,self.helpBtn.transform,Vector3(0.8,0.8,1), Vector3(0,0,-400))
                end
                self.guideEffect2:SetActive(true)
            elseif self.guidePetStep == 2 then
                print("进入了这里这里")
                TipsManager.Instance:ShowGuide({gameObject = self.OpenCon:Find("AutoButton").gameObject, data = TI18N("选择智能加点自动分配"), forward = TipsEumn.Forward.Left})
                 if not BaseUtils.isnull(self.guideEffect) then
                    self.guideEffect.transform:SetParent(self.OpenCon:Find("AutoButton").transform)
                    self.guideEffect.transform.localScale = Vector3(1,1,1)
                    self.guideEffect.transform.localPosition = Vector3(0,0,-400)
                    self.guideEffect.transform.localRotation = Quaternion.identity
                    self.guideEffect:SetActive(true)
                end
            elseif self.guidePetStep == 3 then
                TipsManager.Instance:ShowGuide({gameObject = self.OpenCon:Find("SureButton").gameObject, data = TI18N("确认加点可保存加点方案"), forward = TipsEumn.Forward.Left})
                if not BaseUtils.isnull(self.guideEffect) then
                    self.guideEffect.transform:SetParent(self.OpenCon:Find("SureButton").transform)
                    self.guideEffect.transform.localScale = Vector3(1,1,1)
                    self.guideEffect.transform.localPosition = Vector3(0,0,-400)
                    self.guideEffect.transform.localRotation = Quaternion.identity
                    self.guideEffect:SetActive(true)
                end
            elseif self.guidePetStep == 4 then
                if not BaseUtils.isnull(self.guideEffect2) then
                    self.guideEffect2.transform:SetParent(self.main.transform:Find("Window/CloseButton").transform)
                    self.guideEffect2.transform.localScale = Vector3(0.8,0.8,1)
                    self.guideEffect2.transform.localPosition = Vector3(0,0,-400)
                    self.guideEffect2.transform.localRotation = Quaternion.identity
                end

                if self.guideEffect2 == nil then
                    self.guideEffect2 = BibleRewardPanel.ShowEffect(20103,self.main.transform:Find("Window/CloseButton").transform,Vector3(0.8,0.8,1), Vector3(0,0,-400))
                end
                self.guideEffect2:SetActive(true)
            end


        end
    end

end
