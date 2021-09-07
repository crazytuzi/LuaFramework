-- 公会宝箱分配面板
-- @author zgs
GuildfightGiveBoxPanel = GuildfightGiveBoxPanel or BaseClass(BasePanel)

function GuildfightGiveBoxPanel:__init(model)
    self.model = model
    self.name = "GuildfightGiveBoxPanel"

    self.resList = {
        {file = AssetConfig.guild_fight_givebox_panel, type = AssetType.Main},
        -- {file = AssetConfig.bible_textures, type = AssetType.Dep}

    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self:UpdatePanel()
        GuildfightManager.Instance:send15507()
    end)

    self.updateItemCount = 20
    self.countTotal = 0
    self.itemDic = {}
    self.localMenberData = nil --本地公会成员的数据，键值对
    -- self.OnHideEvent:AddListener(function()
    --     --self.showType = self.openArgs[1]
    --     self:RemovePanel()
    -- end)
    self.guildboxcountchange = function ()
        if self.localMenberData ~= nil then
            self:UpdateGuildBox()
        end
    end
    EventMgr.Instance:AddListener(event_name.guild_box_count_change, self.guildboxcountchange)

    self.guildfightRoleDataUpdateFun = function ()
        self:UpdatePanel()
    end
    EventMgr.Instance:AddListener(event_name.guild_war_role, self.guildfightRoleDataUpdateFun)

    self.score_sort = function(a, b)
        return a.guildWarScore > b.guildWarScore
    end

    self.score_sort2 = function(a, b)
        return a.guildWarScore < b.guildWarScore
    end

    self.imgLoader = {}
end


-- function GuildfightGiveBoxPanel:RemovePanel()
--     self:DeleteMe()
-- end

function GuildfightGiveBoxPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    -- self:UpdatePanel()
    GuildfightManager.Instance:send15507()
end

function GuildfightGiveBoxPanel:__delete()
    for k,v in pairs(self.imgLoader) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    EventMgr.Instance:RemoveListener(event_name.guild_war_role, self.guildfightRoleDataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.guild_box_count_change, self.guildboxcountchange)
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.guild_fight_givebox_panel = nil
    self.model = nil
end

function GuildfightGiveBoxPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_givebox_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.MainCon = self.transform:FindChild("MainCon")
    self.ConMember = self.MainCon:FindChild("ConMember")
    self.MemberList = self.ConMember:FindChild("MemberList")
    self.MaskLayer = self.MemberList:FindChild("MaskLayer")

    self.title_con = self.MemberList:FindChild("ImgTitle")
    self.title_lev = self.title_con:FindChild("TxtLev"):GetComponent(Button)
    self.title_gx = self.title_con:FindChild("TxtGx"):GetComponent(Button)
    self.title_pos = self.title_con:FindChild("TxtPosition"):GetComponent(Button)
    self.title_score = self.title_con:FindChild("TxtScore"):GetComponent(Button)
    -- self.title_cup = self.title_con:FindChild("ImgCup"):GetComponent(Button)
    self.title_lastlogin = self.title_con:FindChild("TxtLastLogin"):GetComponent(Button)

    self.title_lev.onClick:AddListener( function() self:on_mem_title_up_callback(1)  end)
    self.title_gx.onClick:AddListener( function() self:on_mem_title_up_callback(3)  end)
    self.title_pos.onClick:AddListener( function() self:on_mem_title_up_callback(2)  end)
    self.title_score.onClick:AddListener( function() self:on_mem_title_up_callback(4)  end)
    self.title_lastlogin.onClick:AddListener( function() self:on_mem_title_up_callback(5)  end)

    self.MainCon:Find("LeftDescText"):GetComponent(Text).text = TI18N("·公会战获得的珍稀产物，由会长分配 ·可分配给<color='#e8faff'>入会≥3天</color>的成员（每周最多1个）   ")
    self.remindText = self.MainCon:Find("RemindText"):GetComponent(Text) --库存
    self.boxImage = self.MainCon:Find("BoxImage"):GetComponent(Image)

    local idObj = self.boxImage.gameObject:GetInstanceID()
    if self.imgLoader[idObj] == nil then
        self.imgLoader[idObj] = SingleIconLoader.New(self.boxImage.gameObject)
    end
    self.imgLoader[idObj]:SetSprite(SingleIconType.Item, 22504)

    self.boxImage.gameObject:GetComponent(Button).onClick:AddListener( function() self:onClickShowReward() end)

    self.giveRecordBtn = self.ConMember:Find("GiveRecordBtn"):GetComponent(Button)
    self.giveBtn = self.ConMember:FindChild("GiveBtn"):GetComponent(Button)

    self.giveRecordBtn.onClick:AddListener( function() self:onClickGiveRecordBtn() end)
    self.giveBtn.onClick:AddListener( function() self:onClickGiveBtn() end)

    self.scroll_con = self.MaskLayer:Find("ScrollLayer")
    self.layoutContainer = self.MaskLayer:Find("ScrollLayer/Container")
    self.scroll = self.MaskLayer:Find("ScrollLayer"):GetComponent(RectTransform)
    self.memberLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})--,scrollRect = self.scroll})
    -- self.memberItem = self.layoutContainer:Find("Cloner").gameObject
    -- self.memberItem:SetActive(false)


    -- self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.layoutContainer:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        -- local obj = GameObject.Instantiate(self.memberItem)
        -- obj.name = tostring(i)
        -- self.memberLayout:AddCell(obj)
        -- local item = GuildFightBoxMenberItem.New(obj,self)
        -- table.insert(self.item_list, item)

        local obj = self.layoutContainer:Find("Cloner_"..i).gameObject
        -- self.memberLayout:AddCell(obj)
        local item = GuildFightBoxMenberItem.New(obj,self)
        table.insert(self.item_list, item)
    end

    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.scroll_con:GetComponent(RectTransform).sizeDelta.y
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.layoutContainer  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }


    --------------------

    self.recordMaskPanel = self.transform:FindChild("RecordMaskPanel").gameObject
    self.recordMaskPanel:GetComponent(Button).onClick:AddListener( function() self:onClickRecordMask() end)
    self.recordPanel = self.transform:FindChild("Record").gameObject
    self.recordMaskPanel:SetActive(false)
    self.recordPanel:SetActive(false)

    if self.recordPanel.transform:Find("Container").gameObject:GetComponent(Image) == nil then
        self.recordPanel.transform:Find("Container").gameObject:AddComponent(Image)
    end
    local recordLayoutContainer = self.recordPanel.transform:Find("Container/Grid")
    self.recordLayout = LuaBoxLayout.New(recordLayoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.contentTxt_go = self.recordPanel.transform:Find("Container/Grid/WaterContainText").gameObject --:GetComponent(Text)
    self.contentTxt_go:SetActive(false)
    -- self.contentTxt = MsgItemExt.New(self.contentTxt_go, 320, 18, 21)
    -- self.contentTxtRect = self.contentTxt_go.gameObject:GetComponent(RectTransform)

    self:DoClickPanel()
    self.MainCon:GetChild(7).gameObject:SetActive(true)
    self.icon7 = self.MainCon:GetChild(7):Find("icon"):GetComponent(Image)
    idObj = self.icon7.gameObject:GetInstanceID()
    if self.imgLoader[idObj] == nil then
        self.imgLoader[idObj] = SingleIconLoader.New(self.icon7.gameObject)
    end
    self.imgLoader[idObj]:SetSprite(SingleIconType.Item, 22504)

    self.MainCon:GetChild(8).gameObject:SetActive(true)
    self.icon8 = self.MainCon:GetChild(8):Find("icon"):GetComponent(Image)
    idObj = self.icon8.gameObject:GetInstanceID()
    if self.imgLoader[idObj] == nil then
        self.imgLoader[idObj] = SingleIconLoader.New(self.icon8.gameObject)
    end
    self.imgLoader[idObj]:SetSprite(SingleIconType.Item, 22505)

    self.MainCon:GetChild(8):GetComponent(Button).onClick:AddListener(function()
        self.model:InitGiveGuildLeagueBoxUI()
        self:OnClickClose()
    end)
end

function GuildfightGiveBoxPanel:onClickRecordMask()
    self.recordMaskPanel:SetActive(false)
    self.recordPanel:SetActive(false)
end

function GuildfightGiveBoxPanel:onClickShowReward()
    -- 显示宝箱物品
end

function GuildfightGiveBoxPanel:onClickGiveRecordBtn()
    if self.recordList == nil then
        self.recordList = {}
    else
        for i,v in ipairs(self.recordList) do
            if v[1].contentTxt ~= nil then
                v[1].contentTxt.gameObject:SetActive(false)
                -- v[2].contentTxt.gameObject:SetActive(false)
            end
        end
    end
    -- 分配记录
    -- NoticeManager.Instance:FloatTipsByString("暂未开放")
    self.recordMaskPanel:SetActive(true)
    self.recordPanel:SetActive(true)
    local msg = ""
    local timeMsg = ""
    -- print(self.model.guildLoot.log[1].msg)
    for i,v in ipairs(self.model.guildLoot.log) do

        local py = tostring(os.date("%Y", v.ctime))
        local pm = tostring(os.date("%m", v.ctime))
        local ph = tostring(os.date("%H", v.ctime))
        local pM = tostring(os.date("%M", v.ctime))
        -- msg = v.msg
        -- timeMsg = string.format("%s年%s月%s:%s　%s",py,pm,ph,pM,v.msg)
        msg = string.format(TI18N("%s年%s月%s:%s　%s"),py,pm,ph,pM,v.msg)

        local msgText = self.recordList[i]
        if msgText == nil then
            local obj = GameObject.Instantiate(self.contentTxt_go)
            local objText = obj:GetComponent(Text)
            msgText = MsgItemExt.New(objText, 250, 18, 21)
            msgText:SetData(msg)
            self.recordLayout:AddCell(obj)
            local contentRectTemp = objText.gameObject:GetComponent(RectTransform)
            contentRectTemp.sizeDelta = Vector2(250, objText.preferredHeight)

            -- local obj2 = GameObject.Instantiate(self.contentTxt_go)
            -- local objText2 = obj2:GetComponent(Text)
            -- local msgText2 = MsgItemExt.New(objText2, 250, 18, 21)
            -- msgText2:SetData(timeMsg)
            -- self.recordLayout:AddCell(obj2)
            -- local contentRectTemp2 = objText2.gameObject:GetComponent(RectTransform)
            -- contentRectTemp2.sizeDelta = Vector2(250, objText2.preferredHeight)

            self.recordList[i] = {msgText}--,msgText2}
        else
            -- print(i)
            -- BaseUtils.dump(self.recordList[i],"self.recordList[i]")
            -- BaseUtils.dump(self.recordList[i][1],"self.recordList[i][1]")
            self.recordList[i][1].contentTxt.gameObject:SetActive(true)
            -- self.recordList[i][2].contentTxt.gameObject:SetActive(true)
            self.recordList[i][1]:SetData(msg)
            -- self.recordList[i][2]:SetData(timeMsg)
            self.recordList[i][1].contentTxt.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(250, self.recordList[i][1].contentTxt.preferredHeight)
            -- self.recordList[i][2].contentTxt.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(250, self.recordList[i][2].contentTxt.preferredHeight)
        end

    end
    -- self.contentTxt:SetData(msg)
end

function GuildfightGiveBoxPanel:onClickGiveBtn()
    -- 确定分配
    local tableTemp = {}
    for k,v in pairs(self.localMenberData) do
        if v.isTogOn == true then
            local dataTemp = {rid=v.Rid,r_platform=v.PlatForm,r_zone_id=v.ZoneId,base_id=self.model.guildLoot.items[1].base_id,num=1}
            table.insert(tableTemp,dataTemp)
            -- v.isTogOn = false
        end
    end
    GuildManager.Instance:request11181(tableTemp)
    -- local selectItems = {}
    --  for i,v in pairs(self.item_list) do
    --     if v ~= nil and v.gameObject ~= nil then
    --         if v.tog.isOn == true then
    --             table.insert(selectItems,v.data)
    --         end
    --     end
    -- end
    -- if #selectItems > 0 then
    --     local tableTemp = {}
    --     for i,v in ipairs(selectItems) do
    --         -- BaseUtils.dump(v," GuildfightGiveBoxPanel:onClickGiveBtn()selectItems=")
    --         local dataTemp = {rid=v.Rid,r_platform=v.PlatForm,r_zone_id=v.ZoneId,base_id=self.model.guildLoot.items[1].base_id,num=1}
    --         table.insert(tableTemp,dataTemp)
    --         -- GuildManager.Instance:request11181()
    --     end
    --     GuildManager.Instance:request11181(tableTemp)
    --     for i,v in pairs(self.item_list) do
    --     if v ~= nil and v.gameObject ~= nil then
    --         if v.tog.isOn == true then
    --             v.tog.isOn = false
    --         end
    --         v.lastTogOn = false
    --     end
    -- end
    -- end
end

function GuildfightGiveBoxPanel:ReSetSelectedMember()
    local tableTemp = {}
    for k,v in pairs(self.localMenberData) do
        if v.isTogOn == true then
            -- local dataTemp = {rid=v.Rid,r_platform=v.PlatForm,r_zone_id=v.ZoneId,base_id=self.model.guildLoot.items[1].base_id,num=1}
            -- table.insert(tableTemp,dataTemp)
            v.isTogOn = false
        end
    end
end

----------------------------------------------------列表排序逻辑
--点击成员列表标题，进行列表排序
function GuildfightGiveBoxPanel:on_mem_title_up_callback(index)
    --公会成员列表排序逻辑

    if index == 1 then --按钮等级进行排序
        if self.sortType == 1 then
            table.sort(self.model.guild_member_list, self.model.lev_sort2)
            self.sortType = 11
        else
            table.sort(self.model.guild_member_list, self.model.lev_sort)
            self.sortType = 1
        end
    elseif index == 2 then--按职位进行排序
        if self.sortType == 2 then
            table.sort(self.model.guild_member_list, self.model.post_sort2)
            self.sortType = 21
        else
            table.sort(self.model.guild_member_list, self.model.post_sort)
            self.sortType = 2
        end
    elseif index == 3 then --按贡献进行排序
        if self.sortType == 3 then
            table.sort(self.model.guild_member_list, self.model.gx_sort2)
            self.sortType = 31
        else
            table.sort(self.model.guild_member_list, self.model.gx_sort)
            self.sortType = 3
        end
    elseif index == 4 then
        if self.sortType == 4 then
            table.sort(self.model.guild_member_list, self.score_sort2)
            self.sortType = 41
        else
            table.sort(self.model.guild_member_list, self.score_sort)
            self.sortType = 4
        end
    elseif index == 5 then
        if self.sortType == 5 then
            table.sort(self.model.guild_member_list, self.model.last_login_sort2)
            self.sortType = 51
        else
            table.sort(self.model.guild_member_list, self.model.last_login_sort)
            self.sortType = 5
        end
    end


        --把自己放到第一位
    local index = 2
    local myself = nil
    self.current_mem_data_list = nil
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
            self.current_mem_data_list[1] = d
        else
            self.current_mem_data_list[index] = d
            index = index + 1
        end
        local key = BaseUtils.Key(d.Rid, d.PlatForm, d.ZoneId)
        if self.localMenberData[key] ~= nil then
            d.isTogOn = self.localMenberData[key].isTogOn
            -- print(d.isTogOn)
            -- print("GuildfightGiveBoxPanel:on_mem_title_up_callback(index) key="..key)
        end
    end
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,false)

end


function GuildfightGiveBoxPanel:OnClickClose()
    self.model:CloseGiveGuildFightBoxUI()
end

function GuildfightGiveBoxPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.model:CloseGiveGuildFightBoxUI()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function GuildfightGiveBoxPanel:CalNum()
    local count = 0
    -- for i,v in ipairs(self.model.guildLoot.items) do
    --     count = count + v.num
    -- end
    if self.model.guildLoot ~= nil and self.model.guildLoot.items[1] ~= nil then
        count = self.model.guildLoot.items[1].num
    end
    return count
end

function GuildfightGiveBoxPanel:UpdatePanel()
    if GuildManager.Instance.model.guild_member_list ~= nil then
        local guildWarRoleKeyValue = GuildfightManager.Instance.guildWarRoleKeyValue
        local scoreData = nil
        for _, value in pairs(GuildManager.Instance.model.guild_member_list) do
            scoreData = guildWarRoleKeyValue[BaseUtils.Key(value.Rid, value.PlatForm, value.ZoneId)]
            if scoreData ~= nil then
                value.guildWarScore = scoreData.score
            end
        end
    end

    self.countTotal = self:CalNum()
    self.remindText.text = string.format(TI18N("库存:<color='#e8faff'>%d</color>/50"), self.countTotal)
    local member_list_post_sort = function(a, b)
        return a.Post > b.Post
    end

    local member_list_online_sort = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Post > b.Post
        end
    end

    table.sort(self.model.guild_member_list, member_list_post_sort)
    table.sort(self.model.guild_member_list, member_list_online_sort)

    local index = 2
    local myself = nil
    self.current_mem_data_list = nil
    self.current_mem_data_list = {}
    self.localMenberData = nil
    self.localMenberData = {}
    --把自己放到第一位
    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
            self.current_mem_data_list[1] = d
        else
            self.current_mem_data_list[index] = d
            index = index + 1
        end
        local key = BaseUtils.Key(d.Rid, d.PlatForm, d.ZoneId)
        d.isTogOn = false
        self.localMenberData[key] = d
        -- print("GuildfightGiveBoxPanel:UpdatePanel(index) key="..key)
    end
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,true)
end

function GuildfightGiveBoxPanel:UpdateGuildBox()
    -- body
    self.countTotal = self:CalNum()
    self.remindText.text = string.format(TI18N("库存:<color='#e8faff'>%d</color>/50"),self.countTotal)
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,true)
end

function GuildfightGiveBoxPanel:SetItemsFalse()
    for i,v in pairs(self.itemDic) do
        if v ~= nil and v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
end

function GuildfightGiveBoxPanel:UpdateList(dataList,isNeedReset)
    self.setting_data.data_list = dataList
    if isNeedReset == true then
        for i=1,#self.model.guild_member_list do
            local d = self.model.guild_member_list[i]
            local key = BaseUtils.Key(d.Rid, d.PlatForm, d.ZoneId)
            if self.localMenberData[key] ~= nil then
                self.localMenberData[key].isTogOn = false
            end
        end
    end
    BaseUtils.refresh_circular_list(self.setting_data)
    -- local cnt = self.updateItemCount + index
    -- if cnt > #dataList then
    --     cnt = #dataList
    -- end
    -- local indexTemp = 0
    -- -- for i,v in pairs(dataList) do
    -- for i=index , cnt do
    --     local v = dataList[i]
    --     local itemTemp = self.itemDic[i]
    --     if itemTemp == nil then
    --         local obj = GameObject.Instantiate(self.memberItem)
    --         obj.name = tostring(i)

    --         local itemTable = {
    --             index = i,
    --             thisObj = obj,
    --             dataItem = v,
    --             nameText = obj.transform:Find("TxtName"):GetComponent(Text),
    --             levText = obj.transform:Find("TxtLev"):GetComponent(Text),
    --             posText = obj.transform:Find("TxtPos"):GetComponent(Text),
    --             gxText = obj.transform:Find("TxtGx"):GetComponent(Text),
    --             cupText = obj.transform:Find("TxtCup"):GetComponent(Text),
    --             lastLoginext = obj.transform:Find("TxtLastLogin"):GetComponent(Text),
    --             headImg = obj.transform:Find("ImgHead/Img"):GetComponent(Image),
    --             bgImg = obj.transform:Find("ImgOne"):GetComponent(Image),
    --             tog = obj.transform:Find("Toggle"):GetComponent(Toggle),
    --         }
    --         self.memberLayout:AddCell(obj)

    --         itemTable.tog.onValueChanged:AddListener(function(status) self:OnCheck(i,status) end)

    --         self.itemDic[i] = itemTable
    --         itemTemp = itemTable
    --     end
    --     itemTemp.thisObj:SetActive(true)
    --     itemTemp.tog.isOn = false
    --     itemTemp.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(v.Classes),tostring(v.Sex)))

    --     if v.Status == 1 then
    --         --在线啊
    --         itemTemp.nameText.text = v.Name
    --         itemTemp.levText.text = tostring(v.Lev)
    --         itemTemp.posText.text = GuildManager.Instance.model.member_position_names[v.Post]
    --         itemTemp.gxText.text = string.format("%s/%s", v.TotalGx , v.GongXian)
    --         itemTemp.cupText.text = tostring(v.cup)

    --         itemTemp.lastLoginext.text = TI18N("在线")
    --     else
    --         -- itemTemp.nameText.text = string.format("<color='#808080'>%s</color>", v.Name)
    --         -- itemTemp.levText.text = string.format("<color='#808080'>%s</color>", tostring(v.Lev))
    --         -- itemTemp.posText.text = string.format("<color='#808080'>%s</color>", GuildManager.Instance.model.member_position_names[v.Post])
    --         -- itemTemp.gxText.text = string.format("<color='#808080'>%s</color>", string.format("%s/%s",v.TotalGx, v.GongXian))
    --         -- itemTemp.cupText.text = string.format("<color='#808080'>%s</color>", tostring(v.cup))
    --         itemTemp.nameText.text = v.Name
    --         itemTemp.levText.text = tostring(v.Lev)
    --         itemTemp.posText.text = GuildManager.Instance.model.member_position_names[v.Post]
    --         itemTemp.gxText.text = string.format("%s/%s", v.TotalGx , v.GongXian)
    --         itemTemp.cupText.text = tostring(v.cup)

    --         local time = os.date("*t", v.LastLogin)
    --         itemTemp.lastLoginext.text = string.format("<color='#808080'>%s</color>", string.format("%s-%s-%s", time.year, time.month, time.day))
    --     end
    --     if self:CheckIsGet(v) == true then
    --         itemTemp.nameText.text = string.format("<color='#808080'>%s</color>", v.Name)
    --         itemTemp.levText.text = string.format("<color='#808080'>%s</color>", tostring(v.Lev))
    --         itemTemp.posText.text = string.format("<color='#808080'>%s</color>", GuildManager.Instance.model.member_position_names[v.Post])
    --         itemTemp.gxText.text = string.format("<color='#808080'>%s</color>", string.format("%s/%s",v.TotalGx, v.GongXian))
    --         itemTemp.cupText.text = string.format("<color='#808080'>%s</color>", tostring(v.cup))
    --     end

    --     if indexTemp % 2 == 0 then
    --         itemTemp.bgImg.color = Color32(43,74,105,255)
    --     else
    --         itemTemp.bgImg.color = Color32(50,91,131,255)
    --     end
    --     indexTemp = indexTemp + 1
    -- end
    -- if cnt < #dataList then
    --     LuaTimer.Add(20,function ()
    --         self:UpdateList(self.current_mem_data_list,cnt + 1)
    --     end)
    -- end
end

-- function GuildfightGiveBoxPanel:OnCheck(index,status)
--     if status == true then
--         if self.countTotal > 0 then
--             self.countTotal = self.countTotal - 1
--             self.remindText.text = string.format("库存:<color='#2fc823'>%d</color>/50",self.countTotal)
--         else
--             self.countTotal = self.countTotal - 2 --触发两次false??
--             self.itemDic[index].tog.isOn = false
--             NoticeManager.Instance:FloatTipsByString("库存都没可分配的宝箱")
--         end
--     else
--         self.countTotal = self.countTotal + 1
--         self.remindText.text = string.format("库存:<color='#2fc823'>%d</color>/50",self.countTotal)
--     end
-- end
