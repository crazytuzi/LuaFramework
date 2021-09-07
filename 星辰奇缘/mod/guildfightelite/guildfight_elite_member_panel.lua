-- 公会英雄战，领队选择面板
-- @author zgs
GuildFightEliteMemberPanel = GuildFightEliteMemberPanel or BaseClass(BasePanel)

function GuildFightEliteMemberPanel:__init(model)
    self.model = model
    self.name = "GuildFightEliteMemberPanel"

    self.resList = {
        {file = AssetConfig.guild_fight_elite_member_panel, type = AssetType.Main},

    }
    self.pos = 0
    self.OnOpenEvent:AddListener(function()
        self.pos = self.openArgs[1]
        -- GuildfightManager.Instance:send15507()
        self:UpdatePanel()
    end)

    self.updateItemCount = 20
    self.countTotal = 0

    self.localMenberData = nil --本地公会成员的数据，键值对
    self.OnHideEvent:AddListener(function()
        self:DeleteMe()
    end)
    -- self.guildfightRoleDataUpdateFun = function ()
    --     self:UpdatePanel()
    -- end
    -- EventMgr.Instance:AddListener(event_name.guild_war_role, self.guildfightRoleDataUpdateFun)

    self.sort_Lev_ud = function (a,b)
        return a.Lev > b.Lev
    end
    self.sort_Lev_du = function (a,b)
        return a.Lev < b.Lev
    end
    self.sort_post_ud = function (a,b)
        return a.Post > b.Post
    end
    self.sort_post_du = function (a,b)
        return a.Post < b.Post
    end
    self.sort_fc_ud = function (a,b)
        return a.fc > b.fc
    end
    self.sort_fc_du = function (a,b)
        return a.fc < b.fc
    end
    self.sort_lastlogin_ud = function (a,b)
        return a.Status > b.Status
    end
    self.sort_lastlogin_du = function (a,b)
        return a.Status < b.Status
    end

    self.lastSortFun = self.sort_lastlogin_ud
    self.lastChooseItem = nil
end

function GuildFightEliteMemberPanel:OnInitCompleted()
    self.pos = self.openArgs[1]
    -- GuildfightManager.Instance:send15507()
    self:UpdatePanel()
end

function GuildFightEliteMemberPanel:__delete()
    -- EventMgr.Instance:RemoveListener(event_name.guild_war_role, self.guildfightRoleDataUpdateFun)
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.gfemp = nil
    self.model = nil
end

function GuildFightEliteMemberPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_elite_member_panel))
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

    self.title_con = self.ConMember:FindChild("ImgTitle")
    -- self.title_pos = self.title_con:FindChild("TxtPosition"):GetComponent(Button) --排名
    self.title_wincnt = self.title_con:FindChild("TxtWinCnt"):GetComponent(Button) --等级
    self.title_integral = self.title_con:FindChild("TxtIntegral"):GetComponent(Button) --芭蕾舞
    -- self.title_cup = self.title_con:FindChild("ImgCup"):GetComponent(Button)
    self.title_lastlogin = self.title_con:FindChild("TxtLastLogin"):GetComponent(Button) --综合战力
    self.title_lastloginState = self.title_con:FindChild("TxtLastLoginState"):GetComponent(Button) --在线

    -- self.title_pos.onClick:AddListener( function() self:on_mem_title_up_callback(0)  end)
    self.title_wincnt.onClick:AddListener( function() self:on_mem_title_up_callback(1)  end)
    self.title_integral.onClick:AddListener( function() self:on_mem_title_up_callback(2)  end)
    self.title_lastlogin.onClick:AddListener( function() self:on_mem_title_up_callback(3)  end)
    self.title_lastloginState.onClick:AddListener( function() self:on_mem_title_up_callback(4)  end)

    self.scroll_con = self.MaskLayer:Find("ScrollLayer")
    self.layoutContainer = self.MaskLayer:Find("ScrollLayer/Container")
    self.scroll = self.MaskLayer:Find("ScrollLayer"):GetComponent(RectTransform)
    self.memberLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})--,scrollRect = self.scroll})
    self.memberItem = self.layoutContainer:Find("Cloner").gameObject
    self.memberItem.transform:Find("Toggle"):GetComponent(Toggle).group = nil
    self.memberItem:SetActive(false)

    self.sureBtn = self.ConMember:Find("SureBtn"):GetComponent(Button)
    self.sureBtn.onClick:AddListener( function() self:onClickSureBtn() end)


    self.item_con_last_y = self.layoutContainer:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local obj = GameObject.Instantiate(self.memberItem)
        obj.name = tostring(i)
        self.memberLayout:AddCell(obj)
        local item = GuildFightEliteMemberItem.New(obj,self)
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

    self:DoClickPanel()
end

function GuildFightEliteMemberPanel:onClickSureBtn()
    local tableTemp = {}
    for k,v in pairs(self.localMenberData) do
        if v.isTogOn == true then
            local dataTemp = {rid=v.Rid,r_platform=v.PlatForm,r_zone_id=v.ZoneId}
            table.insert(tableTemp,dataTemp)
            v.isTogOn = false
            -- print(v.Name)
        end
    end
    if #tableTemp > 0 then
        BaseUtils.dump(tableTemp[1],"GuildFightEliteMemberPanel:onClickSureBtn() pos = "..self.pos)
        GuildFightEliteManager.Instance:send16202(tableTemp[1].rid,tableTemp[1].r_platform,tableTemp[1].r_zone_id,self.pos)
        -- self:Hiden()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要安排的领队队长"))
    end
end

----------------------------------------------------列表排序逻辑
--点击成员列表标题，进行列表排序
function GuildFightEliteMemberPanel:on_mem_title_up_callback(index)
    --公会成员列表排序逻辑

    if index == 1 then--按胜利次数进行排序
        if self.sortType == 1 then
            self.lastSortFun = self.sort_Lev_du
            self.sortType = 11
        else
            self.lastSortFun = self.sort_Lev_ud
            self.sortType = 1
        end
    elseif index == 2 then --按战绩积分进行排序
        if self.sortType == 2 then
            self.lastSortFun = self.sort_post_du
            self.sortType = 21
        else
            self.lastSortFun = self.sort_post_ud
            self.sortType = 2
        end
    elseif index == 3 then --按剩余行动力排序
        if self.sortType == 3 then
            self.lastSortFun = self.sort_fc_du
            self.sortType = 31
        else
            self.lastSortFun = self.sort_fc_ud
            self.sortType = 3
        end
    elseif index == 4 then --按在线排序
        if self.sortType == 4 then
            self.lastSortFun = self.sort_lastlogin_du
            self.sortType = 41
        else
            self.lastSortFun = self.sort_lastlogin_ud
            self.sortType = 4
        end
    end
    table.sort(GuildManager.Instance.model.guild_member_list, self.lastSortFun )

    --把自己放到第一位
    local index = 2
    local myself = nil
    self.current_mem_data_list = nil
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#GuildManager.Instance.model.guild_member_list do
        local d = GuildManager.Instance.model.guild_member_list[i]
        if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
            self.current_mem_data_list[1] = d
        else
            self.current_mem_data_list[index] = d
            index = index + 1
        end
        local key = BaseUtils.Key(d.Rid, d.PlatForm, d.ZoneId)
        if self.localMenberData[key] ~= nil then
            d.isTogOn = self.localMenberData[key].isTogOn
        end
    end
    self:UpdateList(self.current_mem_data_list)

end


function GuildFightEliteMemberPanel:OnClickClose()
    self:Hiden()
end

function GuildFightEliteMemberPanel:DoClickPanel()
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

function GuildFightEliteMemberPanel:UpdatePanel()

    table.sort(GuildManager.Instance.model.guild_member_list, self.lastSortFun)

    --把自己放到第一位
    local index = 2
    local myself = nil
    self.current_mem_data_list = nil
    self.current_mem_data_list = {}
    self.localMenberData = nil
    self.localMenberData = {}
    --把自己放到第一位
    for i=1,#GuildManager.Instance.model.guild_member_list do
        local d = GuildManager.Instance.model.guild_member_list[i]
        if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
            self.current_mem_data_list[1] = d
        else
            self.current_mem_data_list[index] = d
            index = index + 1
        end
        local key = BaseUtils.Key(d.Rid, d.PlatForm, d.ZoneId)
        d.isTogOn = false
        self.localMenberData[key] = d
    end
    self:UpdateList(self.current_mem_data_list)
end

function GuildFightEliteMemberPanel:UpdateList(dataList)
    -- print(#dataList)
    self.setting_data.data_list = dataList
    BaseUtils.refresh_circular_list(self.setting_data)
end
