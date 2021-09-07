--公会战对战列表面板
-- @author zgs
GuildfightListPanel = GuildfightListPanel or BaseClass(BasePanel)

function GuildfightListPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "GuildfightListPanel"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.guild_fight_list_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.guild_dep_res, type  =  AssetType.Dep}
        , {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self.tabgroup:ChangeTab(1)
        self:updateListPanel()
    end)

    self.itemDic = {}

    self.dateList = nil
end

function GuildfightListPanel:OnInitCompleted()
    self:updateListPanel()
end

function GuildfightListPanel:__delete()
    -- if self.tabgroup ~= nil then
    --     self.tabgroup:DeleteMe()
    --     self.tabgroup = nil
    -- end
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function GuildfightListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_list_panel))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.offsetMin = Vector2(0,-7)
    rect.offsetMax = Vector2(0,-7)
    self.transform = self.gameObject.transform

    local setting = {
            notAutoSelect = true,
            noCheckRepeat = true,
            openLevel = {0, 0, 0},
            perWidth = 215,
            perHeight = 50,
            isVertical = true
        }
    self.lastTogBtn = nil
    self.togBtnList = {}
    local go = self.transform:Find("TabButtonGroup").gameObject
    for i=1,4 do
        local btnDic = {}
        btnDic.btn = go.transform:Find("Button_"..i)
        btnDic.btn:GetComponent(Button).onClick:AddListener( function() self:OnTabChange(i) end)
        btnDic.normal = btnDic.btn:Find("Normal").gameObject
        btnDic.select = btnDic.btn:Find("Select").gameObject
        btnDic.txt = btnDic.btn:Find("Text"):GetComponent(Text)
        btnDic.flag = btnDic.btn:Find("FlagImage").gameObject

        table.insert(self.togBtnList,btnDic)
    end
    -- self.tabgroup = TabGroup.New(go, function (index) self:OnTabChange(index) end,setting)
    -- for i,v in ipairs(self.tabgroup.buttonTab) do
    --     v["flag"] = v.transform:Find("FlagImage").gameObject
    --     v["flag"]:SetActive(false)
    -- end
    -- local go2 = self.transform:Find("TabButtonGroup2").gameObject
    -- self.tabgroup2 = TabGroup.New(go2, function (index) self:OnTabChange(index + 2) end,setting)
    -- for i,v in ipairs(self.tabgroup2.buttonTab) do
    --     v["flag"] = v.transform:Find("FlagImage").gameObject
    --     v["flag"]:SetActive(false)
    -- end

    self.centerDesc = self.transform:Find("BCImage").gameObject
    self.centerDesc:SetActive(false)

    local layoutContainer = self.transform:Find("RightBgImage/InfoList/Grid")
    self.layout_1 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})
    self.layout_2 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})
    self.layout_3 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})
    self.layout_4 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})

    self.item = self.transform:Find("RightBgImage/InfoList/Grid/Item").gameObject
    self.item:SetActive(false)

    self.descImgObj = self.transform:Find("DescImage").gameObject
    self.descImgObj:GetComponent(Button).onClick:AddListener(function()
        self:OnClickShowRuleDesc()
    end)
    self.descText = self.descImgObj.transform:Find("DescText"):GetComponent(Text)
    self.descTextSec = self.transform:Find("DescText"):GetComponent(Text)
end

function GuildfightListPanel:OnClickShowRuleDesc()
    self.descRole = {
        TI18N("1.每两个星期为一个<color='#ffa500'>赛季</color>"),
        TI18N("2.第一个星期为<color='#ffa500'>预赛周</color>，系统自动根据公会活跃匹配对阵"),
        TI18N("3.第二个星期为<color='#ffa500'>决赛周</color>，结合公会战积分和活跃度匹配对阵"),
        TI18N("4.决赛周采用<color='#ffa500'>公会联合</color>的方式进行<color='#ffa500'>2V2</color>的公会较量"),
        TI18N("5.赛季结束根据<color='#ffa500'>积分排名</color>相应发放<color='#ffa500'>赛季奖励</color>"),
        TI18N("6.积分第一的公会将在赛季结束时获得“<color='#ffa500'>天下第一会</color>”的称号"),
    }
    TipsManager.Instance:ShowText({gameObject = self.descImgObj, itemData = self.descRole})
end

function GuildfightListPanel:checkMode(mode)
    local nowTime = BaseUtils.BASE_TIME
    local weekday = tonumber(os.date("%w", nowTime))
    -- print(weekday.."-----567567----"..mode)
    if weekday > 4 or weekday == 0 then
        if mode == 1 then
            mode = 2
        else
            mode = 1
        end
    elseif weekday == 4 then
        local agendaData = DataAgenda.data_list[2015]
        local currtime = BaseUtils.BASE_TIME
        local h = tonumber(os.date("%H", currtime))
        local m = tonumber(os.date("%M", currtime))
        local currtimenum = h*3600+m*60
        if currtimenum > agendaData.endtime then
            if mode == 1 then
                mode = 2
            else
                mode = 1
            end
        end
    end
    return mode
end

function GuildfightListPanel:GetDataInfo(mode)
    -- for i,v in ipairs(self.tabgroup.buttonTab) do
    --     v["flag"]:SetActive(false)
    -- end
    -- for i,v in ipairs(self.tabgroup2.buttonTab) do
    --     v["flag"]:SetActive(false)
    -- end
    for i,v in ipairs(self.togBtnList) do
        v.flag:SetActive(false)
    end
    local weekday_2 = nil
    local weekday_4 = nil
    local weekday_2_next = nil
    local weekday_4_next = nil
    local nowTime = BaseUtils.BASE_TIME
    local weekday = tonumber(os.date("%w", nowTime))
    mode = self:checkMode(mode)
    -- print(weekday.."-----4674564----"..mode)
    self.dateList = nil
    self.dateList = {}
    if mode == 1 then
        if weekday == 1 then
            nowTime = nowTime + 86400
            weekday_2 = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4 = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 2 then
            self.togBtnList[1].flag:SetActive(true)
            -- nowTime = nowTime + 86400
            weekday_2 = string.format(TI18N("<color='#906014'>周二 %s月%s日</color>"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4 = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 3 then
            nowTime = nowTime - 86400
            weekday_2 = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4 = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 4 then
            self.togBtnList[2].flag:SetActive(true)
            nowTime = nowTime - 172800
            weekday_2 = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4 = string.format(TI18N("<color='#906014'>周四 %s月%s日</color>"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        else
            if weekday == 0 then
                weekday = 7 --星期天
            end
            nowTime = nowTime - 86400 * (weekday - 2)
            weekday_2 = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4 = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        end
        nowTime = nowTime + 86400 * 5
        weekday_2_next = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
        table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        nowTime = nowTime + 172800
        weekday_4_next = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
        table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
    else
        if weekday == 1 then
            nowTime = nowTime + 86400
            weekday_2_next = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4_next = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 2 then
            self.togBtnList[3].flag:SetActive(true)
            -- nowTime = nowTime + 86400
            weekday_2_next = string.format(TI18N("<color='#906014'>周二 %s月%s日</color>"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4_next = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 3 then
            nowTime = nowTime - 86400
            weekday_2_next = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4_next = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        elseif weekday == 4 then
            self.togBtnList[4].flag:SetActive(true)
            nowTime = nowTime - 172800
            weekday_2_next = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4_next = string.format(TI18N("<color='#906014'>周四 %s月%s日</color>"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        else
            if weekday == 0 then
                weekday = 7 --星期天
            end
            nowTime = nowTime - 86400 * (weekday - 2)
            weekday_2_next = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
            nowTime = nowTime + 172800
            weekday_4_next = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
            table.insert(self.dateList,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        end
        nowTime = nowTime - 86400 * 9
        weekday_2 = string.format(TI18N("周二 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
        table.insert(self.dateList,1,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
        nowTime = nowTime + 172800
        weekday_4 = string.format(TI18N("周四 %s月%s日"),tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime)))
        table.insert(self.dateList,2,string.format("%s_%s",tostring(os.date("%m", nowTime)),tostring(os.date("%d", nowTime))))
    end
    return weekday_2,weekday_4,weekday_2_next,weekday_4_next
end

function GuildfightListPanel:updateListPanel()
    local realityMode = GuildfightManager.Instance.mode
    realityMode = self:checkMode(realityMode)
    local nowTime = BaseUtils.BASE_TIME
    local weekday = tonumber(os.date("%w", nowTime))
    local selectIndex = 1
    if realityMode == 1 then
        if weekday == 2 then
            selectIndex = 1
        elseif weekday == 4 then
            selectIndex = 2
        end
    elseif realityMode == 2 then
        if weekday == 2 then
            selectIndex = 3
        elseif weekday == 4 then
            selectIndex = 4
        end
    end
    self:updateLeftDateTimeText()

    self:OnTabChange(selectIndex)

    BaseUtils.dump(self.dateList,"self.dateList ===")
end

function GuildfightListPanel:updateLeftDateTimeText()
    self.descText.text = TI18N("<color='#ffa500'>预赛周</color>")
    self.descTextSec.text = TI18N("<color='#ffa500'>决赛周</color>")

    local weekday_2,weekday_4,weekday_2_next,weekday_4_next = self:GetDataInfo(GuildfightManager.Instance.mode)
    self.togBtnList[1].txt.text = weekday_2
    self.togBtnList[2].txt.text = weekday_4
    self.togBtnList[3].txt.text = weekday_2_next
    self.togBtnList[4].txt.text = weekday_4_next
end

function GuildfightListPanel:OnTabChange(index)
    if self.lastTogBtn ~= nil then
        self.lastTogBtn.normal:SetActive(true)
        self.lastTogBtn.select:SetActive(false)
    end
    self.lastTogBtn = self.togBtnList[index]
    self.lastTogBtn.normal:SetActive(false)
    self.lastTogBtn.select:SetActive(true)
    -- if GuildfightManager.Instance.mode == 1 then
    --     self.descText.text = "赛季阶段：<color='#ffa500'>预赛周</color>"
    -- else
    --      self.descText.text = "赛季阶段：<color='#ffa500'>决赛周</color>"
    -- end
    -- self.tabgroup:ResetText(1,weekday_2)
    -- self.tabgroup:ResetText(2,weekday_4)
    -- self.tabgroup2:ResetText(1,weekday_2_next)
    -- self.tabgroup2:ResetText(2,weekday_4_next)

    for i,v in pairs(self.itemDic) do
        v.thisObj:SetActive(false)
    end

    local dataGuildFightList = self:getDataByType(index)
    local indexTemp = 1
    local isEmpty = true
    for i,v in pairs(dataGuildFightList) do
        isEmpty = false
        local itemTemp = self.itemDic[i]
        if itemTemp == nil then
            local obj = GameObject.Instantiate(self.item)
            obj.name = tostring(i)

            local itemTable = {
                index = i,
                thisObj = obj,
                dataItem = v,
                leftNameText = obj.transform:Find("LText"):GetComponent(Text),
                rightNameText = obj.transform:Find("RText"):GetComponent(Text),
                -- leftResultText = obj.transform:Find("CLText"):GetComponent(Text),
                -- rightResultText = obj.transform:Find("CRText"):GetComponent(Text),
                leftResultImg = obj.transform:Find("CLRImage"):GetComponent(Image),
                rightResultImg = obj.transform:Find("CRRImage"):GetComponent(Image),
                leftImg = obj.transform:Find("LImage"):GetComponent(Image),
                rightImg = obj.transform:Find("RImage"):GetComponent(Image),
                bgImg = obj.transform:Find("BgImage"):GetComponent(Image),
            }
            itemTable.leftNameText.color = Color(49/255, 102/255, 173/255, 1)
            itemTable.rightNameText.color = Color(49/255, 102/255, 173/255, 1)
            itemTable.leftImg.gameObject:SetActive(false)
            itemTable.rightImg.gameObject:SetActive(false)
            if index == 1 then
                self.layout_1:AddCell(obj)
            elseif index == 2 then
                self.layout_2:AddCell(obj)
            elseif index == 3 then
                self.layout_3:AddCell(obj)
            elseif index == 4 then
                self.layout_4:AddCell(obj)
            end

            self.itemDic[i] = itemTable
            itemTemp = itemTable
        end
        itemTemp.thisObj:SetActive(true)

        local targetData = {[1] = {},[2] = {}}
        local name_1 = {}
        local name_2 = {}
        for i,vvv in ipairs(v) do
            if vvv.side == 1 then
                table.insert(name_1,vvv.name)
                table.insert(targetData[1],vvv)
            else
                table.insert(name_2,vvv.name)
                table.insert(targetData[2],vvv)
            end
        end

        itemTemp.leftNameText.text = table.concat( name_1, "、")
        itemTemp.rightNameText.text = table.concat( name_2, "、")
        -- itemTemp.leftImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(v[1].totem))
        -- itemTemp.leftImg:SetNativeSize()
        -- itemTemp.rightImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(v[2].totem))
        -- itemTemp.rightImg:SetNativeSize()
        if targetData[1] ~= nil and targetData[1][1] ~= nil and targetData[1][1].is_win ~= 0 then
             itemTemp.leftResultImg.gameObject:SetActive(true)
             itemTemp.rightResultImg.gameObject:SetActive(true)
            if targetData[1][1].is_win == 1 then
                itemTemp.leftResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nwin")
                itemTemp.rightResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nluse")
                -- itemTemp.leftResultText.text = ColorHelper.Fill(ColorHelper.color[1],"胜")
                -- itemTemp.rightResultText.text = ColorHelper.Fill(ColorHelper.color[6],"败")
            elseif targetData[1][1].is_win == 2 then
                itemTemp.leftResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nluse")
                itemTemp.rightResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nwin")
                -- itemTemp.leftResultText.text = ColorHelper.Fill(ColorHelper.color[6],"败")
                -- itemTemp.rightResultText.text = ColorHelper.Fill(ColorHelper.color[1],"胜")
            elseif targetData[1][1].is_win == 3 then
                itemTemp.leftResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nhe")
                itemTemp.rightResultImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res , "I18Nhe")
            end
        else
            itemTemp.leftResultImg.gameObject:SetActive(false)
             itemTemp.rightResultImg.gameObject:SetActive(false)
            -- itemTemp.leftResultText.text = ""
            -- itemTemp.rightResultText.text = ""
        end
        if indexTemp % 2 == 0 then
            itemTemp.bgImg.color = Color32(127,178,235,255)
        else
            itemTemp.bgImg.color = Color32(154,198,241,255)
        end
        indexTemp = indexTemp + 1
    end
    -- print("#dataGuildFightList = "..#dataGuildFightList)
    if isEmpty == false then
        self.centerDesc:SetActive(false)
    else
        self.centerDesc:SetActive(true)
    end
end

function GuildfightListPanel:getDataByType(typeTemp)
    -- local mode = 1
    -- if typeTemp > 2 then
    --     mode = 2
    --     typeTemp = typeTemp - 2
    -- end
    -- local nowTime = BaseUtils.BASE_TIME
    -- local weekday = tonumber(os.date("%w", nowTime))
    -- local realityMode = GuildfightManager.Instance.mode
    -- realityMode = self:checkMode(realityMode)
    -- print(weekday.."---------"..realityMode)
    local data = {}
    for i,v in ipairs(GuildfightManager.Instance.allguildFightList) do
        local str = string.format("%s_%s",tostring(os.date("%m", v.time)),tostring(os.date("%d", v.time)))
        -- if mode == realityMode and v.type == typeTemp then
        -- if self.dateList ~= nil and self.dateList[typeTemp] ~= nil and
        if self.dateList[typeTemp] == str then
            local idTemp = string.format("%s_%s_%s",tostring(v.type),tostring(v.match_type),tostring(v.match_local_id))
            if data[idTemp] == nil then
                data[idTemp] = {}
            end
            table.insert(data[idTemp],v)
        end
    end

    -- BaseUtils.dump(data,"GuildfightListPanel:getDataByType(type)")
    return data
end


