-- 峡谷之巅-便捷组队
-- @author hze
-- @date 2018/08/09
CanyonMakeTeamPanel  =  CanyonMakeTeamPanel or BaseClass(BasePanel)

function CanyonMakeTeamPanel:__init(model)
    self.name  =  "CanyonMakeTeamPanel"
    self.model  =  model
    -- 缓存
    -- self.cacheMode = CacheMode.Visible

    self.resList  =  {
        {file  =  AssetConfig.canyon_make_team_panel, type  =  AssetType.Main}
        ,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
    }

    self.is_open = false
    self.list_has_init = false

    self.timerId = 0
    self.timeLong = 6

    self.needNum = 30

    self.item_list = {}
    self.selected_list = {}
    self.selected_num = 0

    self.isShowMain = false

    self.chatListener = function(mark)
        if mark then 
            self:Hiden()
        else
            self:Show()
        end
    end

    self.lev_sort_low = function(a, b)
        return a.lev > b.lev
    end
    self.lev_sort_up = function(a, b)
        return a.lev < b.lev
    end

    self.post_sort_low = function(a, b)
        return a.post > b.post
    end
    self.post_sort_up = function(a, b)
        return a.post < b.post
    end

    self.ability_sort_low = function(a, b)
        return a.ability > b.ability
    end
    self.ability_sort_up = function(a, b)
        return a.ability < b.ability
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
end

function CanyonMakeTeamPanel:OnShow()
    EventMgr.Instance:RemoveListener(event_name.chat_main_show, self.chatListener)
    CanYonManager.Instance.CanYonUpdateStatus:RemoveListener(function() self:ChangeEnterBtnIcon() end)

    EventMgr.Instance:AddListener(event_name.chat_main_show, self.chatListener)
    CanYonManager.Instance.CanYonUpdateStatus:AddListener(function() self:ChangeEnterBtnIcon() end)
    self:update_panel()
    self:ChangeEnterBtnIcon()
    self:StartDelaySure()
end

function CanyonMakeTeamPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.chat_main_show, self.chatListener)
    CanYonManager.Instance.CanYonUpdateStatus:RemoveListener(function() self:ChangeEnterBtnIcon() end)

    if self.timerId1 ~= nil then 
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil 
    end

    if self.effectBtn ~= nil then 
        self.effectBtn:DeleteMe()
        self.effectBtn = nil 
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    for i=1,#self.item_list do
        local item = self.item_list[i]
        if item ~= nil then
            item:Release()
        end
    end

    self.is_open = false
    self.list_has_init = false

    self.item_list = nil
    self.selected_list = nil
    GameObject.DestroyImmediate(self.gameObject)

    self.gameObject = nil
    self:AssetClearAll()
end

function CanyonMakeTeamPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyon_make_team_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "CanyonMakeTeamPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform:SetSiblingIndex(8)
    self:DoClickPanel()
    self.MainCon = self.transform:FindChild("MainCon")
    self.panelMain = self.transform:FindChild("Panel")
    self.TeamIconBtn = self.transform:FindChild("TeamIconBtn"):GetComponent(Button)
    self.TeamIconBtn.onClick:AddListener(function()
        self.panelMain.gameObject:SetActive(true)
        self.MainCon.gameObject:SetActive(true)
        self:update_mem_list()
    end)
    self.TeamIconBtn.gameObject:SetActive(false)
    self.TeamIconBtnIcon = self.TeamIconBtn.gameObject:GetComponent(Image)

    self.EnterIconBtn = self.transform:FindChild("EnterIconBtn"):GetComponent(Button)
    self.EnterIconBtn.onClick:AddListener(function()
        CanYonManager.Instance:Send21115()
    end)
    self.EnterIconBtn.gameObject:SetActive(false)

    self.titleText = self.transform:FindChild("MainCon/ImgTitle/Text"):GetComponent(Text)
    self.noDataObj = self.transform:FindChild("MainCon/NoData").gameObject
    self.noDataObj_txt = self.transform:FindChild("MainCon/NoData/Text"):GetComponent(Text)
    self.noDataObj:SetActive(false)

    local close_btn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function()
        self.panelMain.gameObject:SetActive(false)
        self.MainCon.gameObject:SetActive(false)
    end)

    self.ConMember = self.MainCon:FindChild("ConMember")
    self.MemberList = self.ConMember:FindChild("MemberList")
    self.MaskLayer = self.MemberList:FindChild("MaskLayer")
    self.MaskLayer.gameObject:SetActive(true)
    self.ScrollLayer = self.MaskLayer:FindChild("ScrollLayer")
    self.item_con = self.ScrollLayer:FindChild("Container")
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)

    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local go = self.item_con:FindChild(tostring(i)).gameObject
        local item = CanyonMakeTeamItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.ScrollLayer:GetComponent(RectTransform).sizeDelta.y


    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
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


    self.BtnIgnore = self.ConMember:FindChild("BtnIgnore"):GetComponent(Button)
    self.BtnRefresh = self.ConMember:FindChild("BtnRefresh"):GetComponent(Button)
    self.BtnRefresh_text = self.ConMember:FindChild("BtnRefresh/Text"):GetComponent(Text)
    self.BtnInviteAll = self.ConMember:FindChild("BtnInviteAll"):GetComponent(Button)
    self.BtnInviteAll_text = self.ConMember:FindChild("BtnInviteAll/Text"):GetComponent(Text)
    self.BtnIgnore.gameObject:SetActive(false)
    self.BtnInviteAll.gameObject:SetActive(false)
    self.BtnRefresh.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-186)

    self.title_con = self.MemberList:FindChild("ImgTitle")
    self.title_lev = self.title_con:FindChild("TxtLev"):GetComponent(Button)
    self.title_pos = self.title_con:FindChild("TxtPosition"):GetComponent(Button)
    self.title_pos_txt = self.title_pos.gameObject:GetComponent(Text)
    self.title_cup = self.title_con:FindChild("ImgCup"):GetComponent(Button)
    self.title_cup_txt = self.title_cup.gameObject:GetComponent(Text)

    -- self.title_lev.onClick:AddListener( function() self:on_mem_title_up_callback(1)  end)
    -- self.title_cup.onClick:AddListener( function() self:on_mem_title_up_callback(4)  end)

    self.BtnRefresh.onClick:AddListener(function()
        if self.timerId ==0 then
            self:update_mem_list()
            self.timerId = LuaTimer.Add(0, 1000, function()
                if self.timeLong > 1 then
                    self.timeLong = self.timeLong - 1
                    self.BtnRefresh_text.text= string.format(TI18N("%s 秒"),self.timeLong)
                else
                    self.timeLong = 6
                    LuaTimer.Delete(self.timerId)
                    self.timerId = 0
                    self.BtnRefresh_text.text= TI18N("刷 新")
                end
            end)
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s秒后再刷新"),self.timeLong))
        end

    end)

    self.BtnInviteAll.onClick:AddListener(function()
        if self.listData ~= nil and #self.listData  > 0 then
            if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
                --
                for i,v in ipairs(self.listData) do
                    TeamManager.Instance:Send11704(v.roleid, v.platform, v.zoneid)
                end
            elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
                --邀请入队
                local num = 5 - TeamManager.Instance:MemberCount()
                for i,v in ipairs(self.listData) do
                    if i <= num then
                        TeamManager.Instance:Send11702(v.roleid, v.platform, v.zoneid)
                    end
                end
            end
        end
    end)

    self:update_panel()
end

function CanyonMakeTeamPanel:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function CanyonMakeTeamPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.panelMain.gameObject:SetActive(false)
                    self.MainCon.gameObject:SetActive(false)
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

-- 取附近队伍或玩家信息
function CanyonMakeTeamPanel:GetListData()
    local addList = {}
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        addList = TeamManager.Instance:GetSceneTeam(self.needNum)
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        addList = TeamManager.Instance:GetSceneMember(self.needNum)
    end
    return addList
end

function CanyonMakeTeamPanel:update_panel()
    self.TeamIconBtnIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "I18NMakeTeam")
    self.panelMain.gameObject:SetActive(false)
    self.MainCon.gameObject:SetActive(false)
    self.TeamIconBtn.gameObject:SetActive(true)
end

--------------------------------------------更新成员列表
function CanyonMakeTeamPanel:update_mem_list()
    self.BtnInviteAll.gameObject:SetActive(false)
    self.BtnRefresh.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-186)
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.titleText.text = TI18N("申请队伍")
        self.BtnInviteAll_text.text = TI18N("申请全部")
        self.title_pos_txt.text = TI18N("队伍人数")
        -- self.title_cup_txt.text = TI18N("队伍成员")
        self.noDataObj_txt.text = TI18N("当前没有可申请的队伍")
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.titleText.text = TI18N("邀请玩家")
        self.BtnInviteAll_text.text = TI18N("一键邀请") -- TI18N("邀请全部")
        self.title_pos_txt.text = TI18N("职业")
        -- self.title_cup_txt.text = TI18N("职业标识")
        self.noDataObj_txt.text = TI18N("当前没有可邀请的玩家")
        self.BtnInviteAll.gameObject:SetActive(true)
        self.BtnInviteAll.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-115,-186)
        self.BtnRefresh.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(115,-186)
    end
    self.listData = self:GetListData()
    for i,v in ipairs(self.listData) do
        v.isOp = false
    end

    table.sort(self.listData, self.lev_sort_low)

    self.setting_data.data_list = self.listData
    BaseUtils.refresh_circular_list(self.setting_data)

    if #self.listData == 0 then
        self.noDataObj:SetActive(true)
    else
        self.noDataObj:SetActive(false)
    end
end

--选中某一条
function CanyonMakeTeamPanel:on_click_mem_item(item)
    if self.selectedItem ~= nil then
        self.selectedItem.ImgSelected.gameObject:SetActive(false)
    end
    self.selectedItem = item
    self.selectedItem.ImgSelected.gameObject:SetActive(true)
    -- if item.selected_state then
    --     self.selected_mem_data = item.data
    --     self.selected_list[item.item_index] = item.data
    -- else
    --     self.selected_mem_data = nil
    --     self.selected_list[item.item_index] = nil
    --     if self.model.update_mem_mange_data ~= nil then
    --         if item.data.Rid == self.model.update_mem_mange_data.Rid and item.data.PlatForm == self.model.update_mem_mange_data.PlatForm and item.data.ZoneId == self.model.update_mem_mange_data.ZoneId then
    --             self.model.update_mem_mange_data = nil
    --         end
    --     end
    -- end
end

----------------------------------------------------列表排序逻辑
--点击成员列表标题，进行列表排序
function CanyonMakeTeamPanel:on_mem_title_up_callback(index)
    --公会成员列表排序逻辑

    if index == 1 then --按钮等级进行排序
        if self.sortType == 1 then
            table.sort(self.listData, self.lev_sort_up)
            self.sortType = 11
        else
            table.sort(self.listData, self.lev_sort_low)
            self.sortType = 1
        end
    -- elseif index == 2 then--按职位进行排序
    --     if self.sortType == 2 then
    --         table.sort(self.listData, self.post_sort_up)
    --         self.sortType = 21
    --     else
    --         table.sort(self.listData, self.post_sort_low)
    --         self.sortType = 2
    --     end
    elseif index == 4 then
        if self.sortType == 4 then
            table.sort(self.listData, self.ability_sort_up)
            self.sortType = 41
        else
            table.sort(self.listData, self.ability_sort_low)
            self.sortType = 4
        end
    end

    for k, v in pairs(self.selected_list) do
        self.selected_list[k] = nil
    end

    self.setting_data.data_list = self.listData
    BaseUtils.refresh_circular_list(self.setting_data)
end

function CanyonMakeTeamPanel:ChangeEnterBtnIcon()
    if self.EnterIconBtn == nil then return  end
    if CanYonManager.Instance.currstatus == CanYonEumn.Status.Preparing then 
            self.EnterIconBtn.gameObject:SetActive(true)
            if self.effectBtn ~= nil then 
                self.effectBtn:DeleteMe()
                self.effectBtn = nil 
            end
            self.effectBtn = BaseUtils.ShowEffect(20121, self.EnterIconBtn.transform, Vector3(1,1,1), Vector3(0,0,-400))
    else
        self.EnterIconBtn.gameObject:SetActive(false)
    end
end

function CanyonMakeTeamPanel:StartDelaySure()
    if self.timerId1 ~= nil then 
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil 
    end

    local callback = function ()
        for i = 1,3 do 
            local time_tl = CanYonManager.Instance.activity_time - BaseUtils.BASE_TIME
            if time_tl == CanYonManager.Instance.delayTimeSure[i] - 1 then 
                local Confirmdata = NoticeConfirmData.New()
                Confirmdata.type = ConfirmData.Style.Sure
                Confirmdata.sureSecond = 30
                if RoleManager.Instance.RoleData.team_status == RoleEumn.TeamStatus.Away then
                    Confirmdata.sureCallback = function() TeamManager.Instance:Send11707() end
                    Confirmdata.sureLabel = TI18N("立即归队")
                    Confirmdata.content = TI18N("峡谷之巅<color='#ffff00'>即将开始</color>，暂离会导致无法参与峡谷之巅，尽快<color='#ffff00'>归队</color>吧！{face_1,3}")
                    NoticeManager.Instance:ConfirmTips(Confirmdata)
                elseif TeamManager.Instance.teamNumber < 5  then
                    Confirmdata.sureLabel = TI18N("确定")
                    Confirmdata.content = TI18N("峡谷之巅<color='#ffff00'>即将开始</color>，战场内<color='#ffff00'>队伍人数越多</color>越有优势，尽快组满5人吧！")
                    NoticeManager.Instance:ConfirmTips(Confirmdata)
                end
            end
        end
    end
    self.timerId1 = LuaTimer.Add(0,1000,callback)
end