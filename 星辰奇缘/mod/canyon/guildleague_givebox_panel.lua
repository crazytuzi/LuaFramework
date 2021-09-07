-- 冠军联赛宝箱分配面板
-- @author hzf
GuildLeagueGiveBoxPanel = GuildLeagueGiveBoxPanel or BaseClass(BasePanel)

function GuildLeagueGiveBoxPanel:__init(model)
    self.model = GuildManager.Instance.model
    self.name = "GuildLeagueGiveBoxPanel"

    self.resList = {
        {file = AssetConfig.guildleaguegiveboxpanel, type = AssetType.Main},
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
    self.iconloader = {}
end


-- function GuildLeagueGiveBoxPanel:RemovePanel()
--     self:DeleteMe()
-- end

function GuildLeagueGiveBoxPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    -- self:UpdatePanel()
    GuildfightManager.Instance:send15507()
end

function GuildLeagueGiveBoxPanel:__delete()
    if self.boxiconloader ~= nil then
        self.boxiconloader:DeleteMe()
    end
    self.boxiconloader = nil
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    self.boxImage.sprite = nil
    self.boxImage = nil
    EventMgr.Instance:RemoveListener(event_name.guild_war_role, self.guildfightRoleDataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.guild_box_count_change, self.guildboxcountchange)
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function GuildLeagueGiveBoxPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleaguegiveboxpanel))
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

    self.MainCon:Find("LeftDescText"):GetComponent(Text).text = TI18N("·<color='#ffff00'>冠军联赛</color>获得的珍稀产物，由会长分配 ·可分配给<color='#e8faff'>入会≥3天</color>的成员（每周最多1个）")
    self.remindText = self.MainCon:Find("RemindText"):GetComponent(Text) --库存
    self.boxImage = self.MainCon:Find("BoxImage"):GetComponent(Image)
    self.boxiconloader = SingleIconLoader.New(self.boxImage.gameObject)
    self.boxiconloader:SetSprite(SingleIconType.Item, 22505)
    self.boxImage.gameObject:GetComponent(Button).onClick:AddListener( function() self:onClickShowReward() end)

    local fun = function(effectView)
        if not BaseUtils.isnull(self.boxImage) then
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(self.boxImage.gameObject.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3(-26, -18, -500)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        else

        end
    end
    BaseEffectView.New({effectId = 20054, callback = fun})

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

        local obj = self.layoutContainer:Find("Cloner_"..i).gameObject
        -- self.memberLayout:AddCell(obj)
        local item = GuildFightBoxMenberItem.New(obj,self, true)
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
    local id = self.MainCon:GetChild(7):Find("icon").gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(self.MainCon:GetChild(7):Find("icon").gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, 22504)
    self.MainCon:GetChild(8).gameObject:SetActive(true)
    local id = self.MainCon:GetChild(8):Find("icon").gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(self.MainCon:GetChild(8):Find("icon").gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, 22505)
    self.MainCon:GetChild(7):GetComponent(Button).onClick:AddListener(function()
        self.model:InitGiveGuildFightBoxUI()
        self:OnClickClose()
    end)
end

function GuildLeagueGiveBoxPanel:onClickRecordMask()
    self.recordMaskPanel:SetActive(false)
    self.recordPanel:SetActive(false)
end

function GuildLeagueGiveBoxPanel:onClickShowReward()
    -- 显示宝箱物品
end

function GuildLeagueGiveBoxPanel:onClickGiveRecordBtn()
    if self.model.guildLeagueLoot == nil then
        -- NoticeManager.Instance:FloatTipsByString(TI18N(""))
        return
    end

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
    for i,v in ipairs(self.model.guildLeagueLoot.log) do

        local py = tostring(os.date("%Y", v.ctime))
        local pm = tostring(os.date("%m", v.ctime))
        local ph = tostring(os.date("%H", v.ctime))
        local pM = tostring(os.date("%M", v.ctime))
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


            self.recordList[i] = {msgText}--,msgText2}
        else
            self.recordList[i][1].contentTxt.gameObject:SetActive(true)
            self.recordList[i][1]:SetData(msg)
            self.recordList[i][1].contentTxt.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(250, self.recordList[i][1].contentTxt.preferredHeight)
        end

    end
end

function GuildLeagueGiveBoxPanel:onClickGiveBtn()
    -- 确定分配
    local tableTemp = {}
    for k,v in pairs(self.localMenberData) do
        if v.isTogOn == true then
            local dataTemp = {rid=v.Rid,r_platform=v.PlatForm,r_zone_id=v.ZoneId,base_id=self.model.guildLeagueLoot.items[1].base_id,num=1}
            table.insert(tableTemp,dataTemp)
            -- v.isTogOn = false
        end
    end
    GuildManager.Instance:request11181(tableTemp)

end

function GuildLeagueGiveBoxPanel:ReSetSelectedMember()
    local tableTemp = {}
    for k,v in pairs(self.localMenberData) do
        if v.isTogOn == true then
            v.isTogOn = false
        end
    end
end

----------------------------------------------------列表排序逻辑
--点击成员列表标题，进行列表排序
function GuildLeagueGiveBoxPanel:on_mem_title_up_callback(index)
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
            -- print("GuildLeagueGiveBoxPanel:on_mem_title_up_callback(index) key="..key)
        end
    end
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,false)

end


function GuildLeagueGiveBoxPanel:OnClickClose()
    self.model:CloseGiveGuildLeagueBoxUI()
end

function GuildLeagueGiveBoxPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.model:CloseGiveGuildLeagueBoxUI()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function GuildLeagueGiveBoxPanel:CalNum()
    local count = 0
    -- for i,v in ipairs(self.model.guildLeagueLoot.items) do
    --     count = count + v.num
    -- end
    if self.model.guildLeagueLoot ~= nil and self.model.guildLeagueLoot.items[1] ~= nil then
        count = self.model.guildLeagueLoot.items[1].num
    end
    return count
end

function GuildLeagueGiveBoxPanel:UpdatePanel()
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
        -- print("GuildLeagueGiveBoxPanel:UpdatePanel(index) key="..key)
    end
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,true)
end

function GuildLeagueGiveBoxPanel:UpdateGuildBox()
    -- body
    self.countTotal = self:CalNum()
    self.remindText.text = string.format(TI18N("库存:<color='#e8faff'>%d</color>/50"),self.countTotal)
    self:SetItemsFalse()
    self:UpdateList(self.current_mem_data_list,true)
end

function GuildLeagueGiveBoxPanel:SetItemsFalse()
    for i,v in pairs(self.itemDic) do
        if v ~= nil and v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
end

function GuildLeagueGiveBoxPanel:UpdateList(dataList,isNeedReset)
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
end
