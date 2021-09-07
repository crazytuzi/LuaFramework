-- 峡谷之巅排行榜
-- @author hze
-- @date 2018/07/20


CanYonMemberFightRankPanel = CanYonMemberFightRankPanel or BaseClass(BasePanel)

function CanYonMemberFightRankPanel:__init(model)
    self.model = model
    self.name = "CanYonMemberFightRankPanel"

    self.resList = {
        {file = AssetConfig.canyon_member_fight_rank_panel, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep}

    }

    self.canyon_fightRoleDataUpdateFun = function ()
        self:UpdatePanel()
    end

    self.showTeamInfo = false
    self.index = 1

    self.titleObjList = {}
    self.titleTxtList =
    {
        {TI18N("排名"), TI18N("角色名"), TI18N("战场积分"), TI18N("剩余行动力"), TI18N("阵营")},
        {TI18N("编号"), TI18N("队长"), TI18N("队伍人数"), TI18N("平均剩余行动力"), TI18N("成员")},
    }

    --个人信息排序
    self.sort_fun1 = function(a,b)
        if a.score ~= b.score then return a.score > b.score end
        if a.movability ~= b.movability  then return a.movability > b.movability end
        return a.side < b.side
    end

    --队伍信息排序
    self.sort_fun2 = function(a,b)
        -- if a.order ~= b.order then return a.order > b.order end
        if a.avg_mov ~= b.avg_mov  then return a.avg_mov > b.avg_mov end
        return a.side < b.side
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CanYonMemberFightRankPanel:__delete()
    self.OnHideEvent:Fire()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.memberLayout ~= nil then 
        self.memberLayout:DeleteMe()
        self.memberLayout = nil
    end
end

function CanYonMemberFightRankPanel:OnHide()
    self:RemoveListeners()
end

function CanYonMemberFightRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyon_member_fight_rank_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local mainCon = self.transform:FindChild("MainCon")
    mainCon:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMemberFightInfoRankPanel() end)

    local toggle = mainCon:Find("SpeedToggle")
    toggle:GetComponent(Button).onClick:AddListener(function() self:ShowTeamInfo() end)
    self.tickObj = toggle:Find("Tick").gameObject

    self.noticeBtn = mainCon:Find("NoticeBtn"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() 
            local desc = {
                TI18N("1、根据阵营队伍情况，合理统筹分配，积极<color='#ffff00'>推塔</color>"),
                TI18N("2、战场上，只有团队合作才能走向<color='#ffff00'>胜利</color>")
            }
            TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = desc})
        end)
    self.ConMember = mainCon:FindChild("ConMember")
    self.ImgTitle = self.ConMember:FindChild("ImgTitle")

    local count = self.ImgTitle.childCount
    for i=1,count do 
        self.titleObjList[i] = self.ImgTitle:GetChild(i-1):GetComponent(Text)
    end

    self.MemberList = self.ConMember:FindChild("MemberList")
    self.MaskLayer = self.MemberList:FindChild("MaskLayer")

    self.scroll_con = self.MaskLayer:Find("ScrollLayer")
    self.layoutContainer = self.MaskLayer:Find("ScrollLayer/Container")
    self.scroll = self.MaskLayer:Find("ScrollLayer"):GetComponent(RectTransform)
    self.memberLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.memberItem = self.layoutContainer:Find("Cloner").gameObject
    self.memberItem:SetActive(false)

    self.tipsTxt = mainCon:FindChild("TipsText"):GetComponent(Text)

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
        local item = CanYonMemberFightRankItem.New(obj,self)
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

    self.tabGroupObj = mainCon:FindChild("TabButtonGroup")
    local tabGroupSetting = {
        notAutoSelect = false,
        openLevel = {0, 30, 25, 25},
        perWidth = 62,
        perHeight = 112,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index)
        self:ChangeTab(index)
    end, tabGroupSetting)


    self:DoClickPanel()
end

function CanYonMemberFightRankPanel:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function CanYonMemberFightRankPanel:OnOpen()
    self:RemoveListeners()
    CanYonManager.Instance.CanYonMemberFightInfoChange:AddListener(self.canyon_fightRoleDataUpdateFun)
    CanYonManager.Instance.CanYonTeamFightInfoChange:AddListener(self.canyon_fightRoleDataUpdateFun)

    CanYonManager.Instance:Send21107()
end

function CanYonMemberFightRankPanel:RemoveListeners()
    CanYonManager.Instance.CanYonMemberFightInfoChange:RemoveListener(self.canyon_fightRoleDataUpdateFun)
    CanYonManager.Instance.CanYonTeamFightInfoChange:RemoveListener(self.canyon_fightRoleDataUpdateFun)
end

function CanYonMemberFightRankPanel:ChangeTab(index)
    self.index = index
    self:UpdatePanel()
end

function CanYonMemberFightRankPanel:UpdatePanel()
    local sortFun = nil
    local list = {}
    if not self.showTeamInfo then
        sortFun = self.sort_fun1
        list = CanYonManager.Instance.Instance.memberFigthInfo
    else
        sortFun = self.sort_fun2
        list = CanYonManager.Instance.Instance.teamFigthInfo
    end

    if list == nil then return end

    local templist = {}
    if self.index == 1 then 
        templist = BaseUtils.copytab(list)
    elseif self.index == 2 then 
        for k,v in ipairs(list) do
            if v.side == 1 then 
                table.insert(templist,v)
            end
        end
    elseif self.index == 3 then 
        for k,v in ipairs(list) do
            if v.side == 2 then 
                table.insert(templist,v)
            end
        end
    end
    table.sort(templist, sortFun)
    self:UpdateList(templist)
end

function CanYonMemberFightRankPanel:UpdateList(dataList)
    self.setting_data.data_list = dataList
    BaseUtils.refresh_circular_list(self.setting_data)

    local num = 0
    local score = 0
    for k,v in ipairs(dataList) do
        local uniqued =  BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
        if uniqued == BaseUtils.get_self_id() then 
            num = k
            score = v.score
            break
        end
    end

    if num == 0 then num = TI18N("未上榜") end
    self.tipsTxt.text = string.format( TI18N("我的排名：<color='#ffff00'>%s</color>      我的积分：<color='#ffff00'>%s</color>"),num,score)
end

function CanYonMemberFightRankPanel:ShowTeamInfo()
    self.showTeamInfo = not self.showTeamInfo
    self.tickObj:SetActive(self.showTeamInfo)
    local order = self.showTeamInfo and 2 or 1
    for k,v in ipairs(self.titleObjList) do
        v.text = self.titleTxtList[order][k]
    end

    if not self.showTeamInfo then
         CanYonManager.Instance:Send21107()
    else
         CanYonManager.Instance:Send21108()
    end
end

function CanYonMemberFightRankPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.model:CloseMemberFightInfoRankPanel()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end