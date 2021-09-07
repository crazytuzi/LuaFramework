BuffPanelWindow = BuffPanelWindow or BaseClass(BasePanel)

function BuffPanelWindow:__init(model)
    self.model = model
    self.name = "BuffPanelWindow"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.buffpanel, type = AssetType.Main}
        ,{file  =  AssetConfig.normalbufficon, type  =  AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.freezBtn = nil

    self._UpdateWindow = function() self:UpdateWindow() end
end

function BuffPanelWindow:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function BuffPanelWindow:__delete()
    if self.bufflistLayout ~= nil then
        self.bufflistLayout:DeleteMe()
        self.bufflistLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil

    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._UpdateWindow)
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self._UpdateWindow)
    EventMgr.Instance:RemoveListener(event_name.buff_update, self._UpdateWindow)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateWindow)
    SkillManager.Instance.OnUpdateSkillEnergy:RemoveListener(self._UpdateWindow)
    SkillManager.Instance.OnUpdateDoublePoint:RemoveListener(self._UpdateWindow)
    -- SkillManager.Instance.OnUpdateDoublePoint:RemoveListener(self._UpdateWindow)
end

function BuffPanelWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buffpanel))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    local layoutContainer = self.transform:Find("Main/Mask/ItemGrid")
    self.bufflistLayout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.bufflistItem = layoutContainer:GetChild(0).gameObject
    self.bufflistItem:SetActive(false)

    self:DoClickPanel()

    EventMgr.Instance:AddListener(event_name.role_asset_change, self._UpdateWindow)
    EventMgr.Instance:AddListener(event_name.buff_update, self._UpdateWindow)
    EventMgr.Instance:AddListener(event_name.role_wings_change, self._UpdateWindow)
    SkillManager.Instance.OnUpdateSkillEnergy:AddListener(self._UpdateWindow)
    SkillManager.Instance.OnUpdateDoublePoint:AddListener(self._UpdateWindow)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,self._UpdateWindow)
    -- SkillManager.Instance.OnUpdateDoublePoint:AddListener(self._UpdateWindow)
    GuildManager.Instance:request11192()
end

function BuffPanelWindow:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function BuffPanelWindow:UpdateWindow()
    -- body
    for i,v in ipairs(self.buffItemObjList) do
        if v ~= nil and v.buffItem ~= nil then
            GameObject.Destroy(v.buffItem)
        end
    end
    self.bufflistLayout:ReSet()
    local roledata = RoleManager.Instance.RoleData
    local buffList = {}
    for k,v in pairs(self.model.buffDic) do
        if not (k == 99998 and roledata.lev < 15 ) and not(k == 100000 and CombatManager.Instance.isFighting == false) and not(k == 31001 and not GuildManager.Instance.model:CheckPrayElementLev())  and not(k == 31000 and not( RoleManager.Instance.world_lev >= 70)) and not (k == 100001 and not WingsManager.Instance:IsNeedEnergy()) and not (k == 100002 and not SkillManager.Instance:NeedEnergyBuff())  then
        -- if not (k == 99998 and roledata.lev < 15) and k ~= 100000 then
            table.insert(buffList, v)
        end
    end
    -- BaseUtils.dump(self.model.buffDic,"初始buff效果==========================================")
    local function sortfun(a,b)
        if a.sort ~= nil then
            if b.sort ~= nil then
                return a.sort < b.sort
            else
                return true
            end
        else
            if b.sort ~= nil then
                return false
            else
                local atrue = a.icon_member == 10100
                local btrue = b.icon_member == 10100
                if atrue == btrue then
                    return a.id < b.id
                else
                    return atrue
                end
            end
        end
    end
    table.sort(buffList, sortfun)
    local hasdiaowen = false
    for k,v in pairs(buffList) do
        local buffTplData = DataBuff.data_list[v.id]
        if buffTplData.icon_member == 10100 then
            hasdiaowen = true
            break
        end
    end
    local isNeedChangeLine = false


    for i=1, #buffList do
        isNeedChangeLine = false
        local buffTplData = DataBuff.data_list[buffList[i].id]
        local obj = GameObject.Instantiate(self.bufflistItem)
        local isdiaowe = buffTplData.icon_member == 10100
        obj:SetActive(true)
        obj.name = tostring(i)

        local itemDic = {
             data = buffList[i]
            ,dataTpl = buffTplData
            ,index = i
            ,buffItem = obj
            ,buffIcon = obj.transform:Find("Top/Buffbg/BuffIcon"):GetComponent(Image)
            ,buffName = obj.transform:Find("Top/BuffName"):GetComponent(Text)
            ,buffDesc = obj.transform:Find("DescText"):GetComponent(Text)
            ,attrDesc = obj.transform:Find("AttrText"):GetComponent(Text) --attr = {{attr_type = 54,val = 25}}
            ,skillDesc = obj.transform:Find("SkillText"):GetComponent(Text) --effect = {{effect_type = 1,val = 82000,co_val = 1}}
            ,buffDataText = obj.transform:Find("dataText"):GetComponent(Text)
            ,buffBtn = obj.transform:Find("Top/Button"):GetComponent(Button)
            ,buffspBtn = obj.transform:Find("Top/SPButton"):GetComponent(Button)
            ,buffBtnText = obj.transform:Find("Top/Button/Text"):GetComponent(Text)
            ,buffspBtnText = obj.transform:Find("Top/SPButton/Text"):GetComponent(Text)
        }
        self.buffItemObjList[i] = itemDic

        itemDic.buffName.text = buffTplData.name

        local sizeDelta = obj:GetComponent(RectTransform).sizeDelta
        local line = 0
        local buffDescHeight = 10

        if itemDic.data.cancel == 1 then
            itemDic.buffBtn.gameObject:SetActive(true)

            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        else
            itemDic.buffBtn.gameObject:SetActive(false)
        end

        if buffTplData.desc ~= "" then
            itemDic.buffDesc.text = buffTplData.desc
            buffDescHeight = buffDescHeight + itemDic.buffDesc.preferredHeight
            itemDic.buffDesc.gameObject.transform.sizeDelta = Vector2(298, itemDic.buffDesc.preferredHeight)
        else
            itemDic.buffDesc.gameObject:SetActive(false)
        end

        if buffTplData.sub_type == 1 then
            local btn = itemDic.skillDesc.transform:Find("Button")
            self:GetSkillDes(buffTplData.effect, btn)
            itemDic.skillDesc.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            buffDescHeight = buffDescHeight + 21.5
            itemDic.attrDesc.text = self:GetAttrDes(buffTplData.attr)
            itemDic.attrDesc.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            buffDescHeight = buffDescHeight + itemDic.attrDesc.preferredHeight
            itemDic.skillDesc.gameObject:SetActive(true)
            itemDic.attrDesc.gameObject:SetActive(true)
        else
            itemDic.skillDesc.gameObject:SetActive(false)
            itemDic.attrDesc.gameObject:SetActive(false)
        end

        if itemDic.data.id == 100000 then
            if CombatManager.Instance.controller ~= nil then
                local rData = CombatManager.Instance.controller.enterData
                itemDic.buffDataText.text = string.format(TI18N("当前怒气值：%s/%s "), tostring(rData.anger), CombatManager.Instance.MaxAnger)
                itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
                line = line + 1
                itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "21003")

                itemDic.buffBtnText.text = TI18N("介绍")
                itemDic.buffBtn.gameObject:SetActive(true)
                itemDic.buffBtn.onClick:AddListener(function ()
                    self:onClickBuffBtn(itemDic)
                end)
            end
        elseif itemDic.data.id == 100001 then
            local rData = (CombatManager.Instance.controller or {}).enterData or {}
            itemDic.buffDataText.text = string.format(TI18N("当前能量值：%s/100"), tostring(rData.energy or WingsManager.Instance.wing_power or 0))
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "wing_energy")

            itemDic.buffBtnText.text = TI18N("补充")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        elseif itemDic.data.id == 100002 then
            local rData = (CombatManager.Instance.controller or {}).enterData or {}
            itemDic.buffDataText.text = string.format(TI18N("当前灵气值：%s/100"), tostring(rData.energy or SkillManager.Instance.sq_point or 0))
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "final_skill_energy")

            itemDic.buffBtnText.text = TI18N("补充")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        elseif itemDic.data.id == 100003 then
            local time = SkillManager.Instance.sq_double - BaseUtils.BASE_TIME
            if time > 0 then
                    if time < 3600 then
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
                    elseif time < 3600 * 10 then
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
                    elseif time < 3600 * 24 then
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
                    else
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
                    end
                    itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
                    line = line + 1

                    itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "exercise")


                    itemDic.buffBtn.onClick:RemoveAllListeners()

                    itemDic.buffIcon.color = Color.white
            else
                    itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "exercise")
                    itemDic.buffIcon.color = Color(0.4,0.4,0.4)
                    itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
                    itemDic.buffDataText.text = TI18N("当前没有历练加成效果，请前往补充")
                    line = line + 1
            end
            local num = BackpackManager.Instance:GetItemCount(23838)
            if num > 0 then
                    itemDic.buffBtnText.text = TI18N("补充")
            else
                    itemDic.buffBtnText.text = TI18N("购买")
            end

            itemDic.buffBtn.gameObject:SetActive(true)

            itemDic.buffBtn.onClick:AddListener(function ()
                num = BackpackManager.Instance:GetItemCount(23838)
                if num > 0 then
                    local item_data = BackpackManager.Instance:GetItemByBaseid(23838)
                     BackpackManager.Instance:Use(item_data[1].id, 1,23838)
                else
                    BuyManager.Instance:ShowQuickBuy({[23838] = {need = 1}})
                end
            end)

        elseif itemDic.data.id == 99999 then
            itemDic.buffDataText.text = string.format(TI18N("当前饱食度：%s/200 "),roledata.satiety)
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            if roledata.satiety < 50 then
                itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hunger")
            else
                itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hungernot")
            end

            itemDic.buffBtnText.text = TI18N("补充")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        elseif itemDic.data.id == 99998 then
            itemDic.buffDataText.text = string.format(TI18N("剩余点数：%s/%s"), AgendaManager.Instance.double_point, tostring(AgendaManager.Instance.max_double_point))
            -- itemDic.buffDataText.text = string.format(TI18N("剩余点数：%s"), AgendaManager.Instance.double_point)
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            if AgendaManager.Instance.double_point == 0 then
                itemDic.buffspBtn.gameObject:SetActive(false)
                itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
            else
                itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
                itemDic.buffspBtn.gameObject:SetActive(true)
            end

            itemDic.buffBtnText.text = TI18N("补充")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
            itemDic.buffspBtn.onClick:AddListener(function ()
                AgendaManager.Instance:Require12003()
            end)
            self.freezBtn = itemDic.buffspBtn
        elseif itemDic.data.id == 99997 then
            itemDic.buffDataText.gameObject:SetActive(false)
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))
            itemDic.buffBtnText.text = TI18N("查看")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.starchallengewindow, {1, 1, -1, 1})
            end)
        elseif itemDic.data.id == 99996 then
            if hasdiaowen then
                itemDic.buffDataText.gameObject:SetActive(false)
            else
                itemDic.buffDataText.text = TI18N("当前没有雕文效果，请前往市场购买")
                itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
                line = line + 1
            end
            if hasdiaowen then
                itemDic.buffIcon.color = Color.white
            else
                itemDic.buffIcon.color = Color(0.4,0.4,0.4)
            end
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "12004")

            itemDic.buffBtnText.text = TI18N("购买")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {2, 6})
            end)
        elseif itemDic.data.id == 99995 then
            itemDic.buffDataText.gameObject:SetActive(false)
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))
            itemDic.buffBtnText.text = TI18N("查看")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ApocalypseLordwindow, {1, 1, -1, 1})
            end)
        elseif itemDic.data.id == 23112 then
            local chidldata = ChildrenManager.Instance:GetChildFetus()
            if chidldata ~= nil then
                itemDic.buffDataText.text = string.format(TI18N("当前孕育值：%s/1000 "), chidldata.maturity)
            end
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))

            itemDic.buffBtnText.text = TI18N("查看")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        elseif itemDic.data.id == 23111 then
            local chidldata = ChildrenManager.Instance:GetChildFetus()
            if chidldata ~= nil then
                itemDic.buffDataText.text = string.format(TI18N("当前孕育值：%s/1000 "), chidldata.maturity)
            end
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))

            itemDic.buffBtnText.text = TI18N("查看")
            itemDic.buffBtn.gameObject:SetActive(true)
            itemDic.buffBtn.onClick:AddListener(function ()
                self:onClickBuffBtn(itemDic)
            end)
        elseif itemDic.data.id == 31010 then
            local model = StarChallengeManager.Instance.model
            if model.myRank ~= 0 then
                itemDic.buffDataText.text = string.format(TI18N("%s资格:%s%s"), model.myRankFormUnitConfigData.name, model.myRank)
            end
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))

            itemDic.buffBtn.gameObject:SetActive(false)
        elseif itemDic.data.id == 31000 or itemDic.data.id == 31001 then
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))
            local tempData = GuildManager.Instance.model.prayElementData
            if tempData ~= nil then
                local end_time = 0
                for k, v in pairs(tempData.element_attr) do
                    if (itemDic.data.id == 31000 and v.effect_obj == 1) or (itemDic.data.id == 31001 and v.effect_obj == 2) then
                        end_time  = v.end_time - BaseUtils.BASE_TIME
                        break
                    end
                end
                local roleCurList, roleNewList, petCurList, petNewList =  GuildManager.Instance.model:GetPrayList(tempData)
                if end_time > 2 and ((#roleCurList > 0 and itemDic.data.id == 31000) or (#petCurList > 0 and itemDic.data.id == 31001)) then
                    -- itemDic.buffDesc.gameObject:SetActive(false)
                    -- buffDescHeight = 0
                    -- itemDic.buffDataText.text = ""
                    --还有剩余时间
                    -- line = line + 2
                    local tempList = nil
                    if itemDic.data.id == 31000 then
                        tempList = roleCurList
                    elseif itemDic.data.id == 31001 then
                        tempList = petCurList
                    end
                    BaseUtils.dump(tempList, "属性")
                    itemDic.data.dynamic_attr = {}
                    itemDic.data.dynamic_skill_attr = {}
                    for k, v in pairs(tempList) do
                        if v.effect_type ~= nil then
                            --属性效果
                            table.insert(itemDic.data.dynamic_attr, {attr = v.effect_type, value = v.val})
                        else
                            --附加技能
                            table.insert(itemDic.data.dynamic_skill_attr, {skill_id = v.skill_id, lev = v.lev})
                        end
                    end
                    local time = end_time
                    if time < 3600 then
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
                    elseif time < 3600 * 10 then
                        line = line + 1
                        isNeedChangeLine = true
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
                    else --if time < 3600 * 24 then
                        itemDic.buffDataText.text = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
                    -- else
                    --     itemDic.buffDataText.text = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
                    end
                    local ypos = itemDic.buffDataText.gameObject.transform.anchoredPosition.y + 25
                    itemDic.buffDataText.gameObject.transform.anchoredPosition = Vector2(318-itemDic.buffDataText.preferredWidth, ypos)
                    itemDic.buffBtnText.text = TI18N("祈福")
                    itemDic.buffBtn.gameObject:SetActive(true)
                    itemDic.buffBtn.onClick:RemoveAllListeners()
                    itemDic.buffBtn.onClick:AddListener(function ()
                        self:onClickBuffBtn(itemDic)
                    end)
                else
                    --没有属性
                    itemDic.data.dynamic_attr = {}
                    itemDic.data.dynamic_skill_attr = {}
                    itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
                    -- line = line + 1
                    itemDic.buffBtnText.text = TI18N("祈福")
                    itemDic.buffBtn.gameObject:SetActive(true)
                    itemDic.buffBtn.onClick:RemoveAllListeners()
                    itemDic.buffBtn.onClick:AddListener(function ()
                        self:onClickBuffBtn(itemDic)
                    end)
                    itemDic.buffDataText.text = ""
                end
            end
        elseif buffTplData.type == 2 then --不计时
            itemDic.buffDataText.text = ""
            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))
        else --if buffTplData.type == 3 or buffTplData.type == 1 then
            local time = (itemDic.data.duration- BaseUtils.BASE_TIME + itemDic.data.start_time)
            if time < 3600 then
                itemDic.buffDataText.text = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
            elseif time < 3600 * 10 then
                -- line = line + 1
                -- isNeedChangeLine = true
                itemDic.buffDataText.text = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
            elseif time < 3600 * 24 then
                itemDic.buffDataText.text = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
            else
                itemDic.buffDataText.text = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
            end
            itemDic.buffDataText.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)
            line = line + 1

            itemDic.buffIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffTplData.icon))
            if buffTplData.cancel == 1 then
                itemDic.buffBtnText.text = TI18N("取消")
                itemDic.buffBtn.gameObject:SetActive(true)
                itemDic.buffBtn.onClick:RemoveAllListeners()
                itemDic.buffBtn.onClick:AddListener(function ()
                    self:onClickBuffBtn(itemDic)
                end)
            end
        end

        -- 动态属性显示
        if (itemDic.data.dynamic_attr ~= nil and next(itemDic.data.dynamic_attr) ~= nil) or itemDic.data.dynamic_skill_attr ~= nil then
            if isdiaowe then
                local xpos = 0
                local ypos = itemDic.buffDataText.gameObject.transform.anchoredPosition.y
                -- line = line + 1
                if isNeedChangeLine == true then
                    ypos = ypos + 25
                end
                for i,v in ipairs(itemDic.data.dynamic_attr) do
                    local name = KvData.attr_name[v.attr]
                    local attrtxt = GameObject.Instantiate(itemDic.buffDataText)
                    local attrtxtComponent = attrtxt.transform:GetComponent(Text)
                    attrtxtComponent.text = KvData.GetAttrStringNoColor(v.attr, v.value, 1)
                    attrtxt.transform:SetParent(obj.transform)
                    attrtxt.transform.localScale = Vector3(1, 1, 1)
                    attrtxt.transform.anchoredPosition = Vector2(xpos, ypos- 25*(i-1))
                    -- xpos = xpos + attrtxtComponent.preferredWidth+10
                end
                line = line + #itemDic.data.dynamic_attr -1
                if isNeedChangeLine == true then
                    ypos = ypos - 25
                    isNeedChangeLine = false
                    itemDic.buffDataText.gameObject.transform.anchoredPosition = Vector2(0, ypos)
                else
                    itemDic.buffDataText.gameObject.transform.anchoredPosition = Vector2(318-itemDic.buffDataText.preferredWidth, ypos)
                end
            else
                for i,v in ipairs(itemDic.data.dynamic_attr) do
                    local name = KvData.attr_name[v.attr]
                    local value = v.value
                    local attrtxt = GameObject.Instantiate(itemDic.buffDataText)
                    if v.attr == 30 or v.attr == 31 or v.attr == 45 or v.attr == 46 then
                        value = string.format("%s%s", v.value/10, "%")
                    end
                    attrtxt.transform:GetComponent(Text).text = string.format("%s +%s", tostring(name), tostring(value))

                    attrtxt.transform:SetParent(obj.transform)
                    attrtxt.transform.localScale = Vector3(1, 1, 1)
                    attrtxt.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)

                    line = line + 1
                end
                if itemDic.data.dynamic_skill_attr ~= nil then
                    for i,v in ipairs(itemDic.data.dynamic_skill_attr) do
                        local name = DataSkillPrac.data_skill[v.skill_id].name
                        local value = v.lev
                        local attrtxt = GameObject.Instantiate(itemDic.buffDataText)
                        attrtxt.transform:GetComponent(Text).text = string.format("%s +%s", tostring(name), tostring(value))

                        attrtxt.transform:SetParent(obj.transform)
                        attrtxt.transform.localScale = Vector3(1, 1, 1)
                        attrtxt.transform.localPosition = Vector3(-166, -(sizeDelta.y + buffDescHeight + line * 25), 0)

                        line = line + 1
                    end
                end
            end
        end

        obj:GetComponent(RectTransform).sizeDelta = Vector2(sizeDelta.x , sizeDelta.y + buffDescHeight + line * 25)
        self.bufflistLayout:AddCell(obj)

        i = i + 1
    end
end

function BuffPanelWindow:onClickBuffBtn(itemDic)
    -- body
    if itemDic.dataTpl.id == 99999 then
        local roledata = RoleManager.Instance.RoleData
        if roledata.satiety >=200 then
            NoticeManager.Instance:FloatTipsByString(TI18N("饱食状态已满。"))
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.satiation_window, 99999)
            self:Hiden()
        end
    elseif itemDic.dataTpl.id == 99998 then
        AgendaManager.Instance:Require12002()
    elseif itemDic.dataTpl.id == 100000 then
        TipsManager.Instance:ShowText({gameObject = itemDic.buffBtn.gameObject, itemData = {
            TI18N("1.进入战斗后，随机获得<color='#00ff00'>10~15</color>点怒气"),
            TI18N("2.每次受到攻击，将根据所受<color='#00ff00'>伤害</color>占<color='#00ff00'>总生命</color>的<color='#00ff00'>比例</color>获得一定怒气"),
            string.format(TI18N("3.战斗中最多拥有<color='#00ff00'>%s</color>点怒气值。"),CombatManager.Instance.MaxAnger),
            TI18N("4.怒气技在<color='#00ff00'>被嘲讽、封印</color>状态下也可使用。"),
            }})
    elseif itemDic.dataTpl.id == 23112 or itemDic.dataTpl.id == 23111 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_get_win)
    elseif itemDic.data.id == 31000 or itemDic.data.id == 31001 then
        if GuildManager.Instance.model:has_guild() then
            --有公会
            if RoleManager.Instance.world_lev < 70 then
                NoticeManager.Instance:FloatTipsByString(TI18N("世界等级尚未达到70级"))
            else
                if #GuildManager.Instance.model.my_guild_data.element_info > 0 then
                    if itemDic.data.id == 31000 then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 1)
                    else
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 2)
                    end
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("您的公会现在还未开启元素祭坛"))
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("尚未加入公会，无法进行公会祈福"))
        end
    elseif itemDic.data.id == 100001 then
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.satiation_window)
        WingsManager.Instance.model:OpenEnergy()
    elseif itemDic.data.id == 100002 then
        local checkFun = function(data)
            local id = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1][1]
            if data.base_id == id then
                return true
            else
                return false
            end
        end
        local button3_callback = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, { 2, 4 })
        end
        BackpackManager.Instance.mainModel:OpenQuickBackpackWindow({ checkFun = checkFun, showButtonType = 2, button3_callback = button3_callback})
    elseif itemDic.data.id == 100003 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, { 1, 1 })
    else
        BuffPanelManager.Instance:send12801(itemDic.dataTpl.id)
    end
end

function BuffPanelWindow:OnClickClose()
    self.model:CloseMain()
end


function BuffPanelWindow:GetSkillDes(list, btn)
    local str = TI18N("附带技能：")
    if list == nil or #list == 0 then
        local textcom = btn:Find("Text"):GetComponent(Text)
        textcom.text = TI18N("无")
        -- return "附带技能：无"
    elseif list[1].effect_type == 1 then
        local skillname = DataSkill.data_skill_other[list[1].val].name
        local str = string.format("<color='#00ffff'>[%s]</color>", skillname)
        local textcom = btn:Find("Text"):GetComponent(Text)
        textcom.text = str
        btn.sizeDelta = Vector2(textcom.preferredWidth+16, btn.sizeDelta.y+20 )
        -- local data = DataSkill.data_skill_other[string.format("%s_1", list[1].val)]
        local data = DataSkill.data_skill_other[list[1].val]
        local info = {gameObject = btn.gameObject, skillData = data, type = Skilltype.petskill}
        btn:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowSkill(info, true) end)
    end
    -- end
    -- return str
end

function BuffPanelWindow:GetAttrDes(list) --attr = {{attr_type = 54,val = 25}}
    local str = TI18N("附带属性：")
    if #list == 0 then
        return TI18N("附带属性：无")
    end
    for i,v in ipairs(list) do
        if i == 1 then
            local attrname = KvData.attr_name[v.attr_type]
            local rate = v.val/10
            if rate > 0 then
                str = str..string.format("%s+%s%% ", attrname, tostring(rate))
            else
                str = str..string.format("%s%s%% ", attrname, tostring(rate))
            end
        else
            local attrname = KvData.attr_name[v.attr_type]
            local rate = v.val/10
            if rate > 0 then
                str = str..string.format(",%s+%s%% ", attrname, tostring(rate))
            else
                str = str..string.format(",%s%s%% ", attrname, tostring(rate))
            end
        end
    end
    return str
end

function BuffPanelWindow:UpdateFreezBtn()
    if self.freezBtn ~= nil then
        if AgendaManager.Instance.frightingFreez == true then
            self.freezBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("取消")
        else
            self.freezBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("冻结")
        end
    end
end