ShouhuMainWindow  =  ShouhuMainWindow or BaseClass(BaseWindow)

function ShouhuMainWindow:__init(model)
    self.name  =  "ShouhuMainWindow"
    self.windowId = WindowConfig.WinID.guardian
    self.model  =  model
    -- 缓存
    self.effectPath1 = "prefabs/effect/20107.unity3d"
    self.guideEffect1 = nil

    self.cacheMode = CacheMode.Visible

    self.resList  =  {
        {file = AssetConfig.shouhu_main_win, type = AssetType.Main}
        ,{file = self.effectPath1, type = AssetType.Main}
        ,{file = AssetConfig.guard_head, type = AssetType.Dep}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
    }

    self.subFirst = nil
    self.zhuzhenTab = nil
    self.wakeUpTab = nil
    self.transferTab = nil  --转换窗口
    self.mainObj = nil
    self.is_force_open_tab = false
    self.zhuzhen_open_lev = 45
    self.transfer_open_lev = 82
    self.curSelectedBtn = nil
    self.list_item_select_id = 0
    self.shItemList = {}

    self.hasInit = false

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.OnWakeupListener = function(data)
        if self.hasInit == false then
            return
        end
        --不能直接调用init_left_list方法
        for i=1,#self.shItemList do
            local item = self.shItemList[i]
            if item.data ~= nil and item.data.base_id == data.base_id and item.showState then
                item:CheckRedPointState()
            end
        end
        self:update_wakeup_red_point()
    end
    self.OnBackpackChange = function(data)
        if self.curSelectedBtn == 2 then
            self:init_left_list()
        end
    end
    -- self._OnTransferSuccess = function()
    --     print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    --     if self.curSelectedBtn == 4 and self.transferTab ~= nil then
    --         print("事件回调-------")
    --         self:init_left_list()
    --     end
    -- end

    self.guideScript = nil
    self.guideTimeId = nil

    return self
end

function ShouhuMainWindow:OnShow()
    self.hasInit = true
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.OnBackpackChange)
    --ShouhuManager.Instance.OnTransferSuccess:AddListener(self._OnTransferSuccess)
    if RoleManager.Instance.RoleData.lev >= self.zhuzhen_open_lev then --大于等于self.zhuzhen_open_lev才开启助阵
        self.tab_btn3.gameObject:SetActive(true)
    else
        self.tab_btn3.gameObject:SetActive(false)
    end

    if RoleManager.Instance.RoleData.lev >= self.transfer_open_lev then --大于等于self.transfer_open_lev才开启转换
        self.tab_btn4.gameObject:SetActive(true)
    else
        self.tab_btn4.gameObject:SetActive(false)
    end
    self.tab_btn2.gameObject:SetActive(self.model:CheckWakeUpIsOpen())

    self:tabChange(self.curSelectedBtn)
    self:update_left_list()

    --检查下是否有阵位可助战
    self:update_help_fight_red_point()

    self:update_red_point()
end

function ShouhuMainWindow:OnHide()
    self.hasInit = false
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.OnBackpackChange)
    --ShouhuManager.Instance.OnTransferSuccess:RemoveListener(self._OnTransferSuccess)
    if self.guideTimeId ~= nil then
        LuaTimer.Delete(self.guideTimeId)
        self.guideTimeId = nil
    end
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    if self.wakeUpTab ~= nil then
        self.wakeUpTab:Hiden()
    end

    if self.transferTab ~= nil then
        self.transferTab:Hiden()
    end

    self.model.main_tab_first_opera_type = 0
     if self.help_change_panel ~= nil then
        self.help_change_panel:Hiden()
    end
    GuideManager.Instance:CloseWindow(self.windowId)
end

function ShouhuMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.OnBackpackChange)
    EventMgr.Instance:RemoveListener(event_name.shouhu_wakeup_update, self.OnWakeupListener)
    if self.shItemList ~= nil then
        for k, v in pairs(self.shItemList) do
            v:Release()
        end
    end

    if self.guideTimeId ~= nil then
        LuaTimer.Delete(self.guideTimeId)
        self.guideTimeId = nil
    end

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end

    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    if self.zhuzhenTab ~= nil then
        self.zhuzhenTab:DeleteMe()
        self.zhuzhenTab = nil
    end
    if self.wakeUpTab ~= nil then
        self.wakeUpTab:DeleteMe()
        self.wakeUpTab = nil
    end

    if self.transferTab ~= nil then
        self.transferTab:DeleteMe()
        self.transferTab = nil
    end

    if self.help_change_panel ~= nil then
        self.help_change_panel:DeleteMe()
        self.help_change_panel = nil
    end

    self.curSelectedBtn = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_main_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")
    self.mainObj = self.MainCon.gameObject
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseShouhuMainUI() end)

    local tabGroup = self.MainCon:FindChild("TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:tabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:tabChange(2) end)
    self.tab_btn3 = tabGroup.transform:GetChild(2):GetComponent(Button)
    self.tab_btn3.onClick:AddListener(function() self:tabChange(3) end)
    self.tab_btn4 = tabGroup.transform:GetChild(3):GetComponent(Button)
    self.tab_btn4.onClick:AddListener(function() self:tabChange(4) end)

    tabGroup.transform:GetChild(0):Find("Normal/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)
    tabGroup.transform:GetChild(1):Find("Normal/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)
    tabGroup.transform:GetChild(2):Find("Normal/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)
    tabGroup.transform:GetChild(0):Find("Select/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)
    tabGroup.transform:GetChild(1):Find("Select/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)
    tabGroup.transform:GetChild(2):Find("Select/Text"):GetComponent(RectTransform).sizeDelta = Vector2(20, 137)

    self.tab_btn1.gameObject:SetActive(false)
    self.tab_btn2.gameObject:SetActive(false)
    self.tab_btn3.gameObject:SetActive(false)
    self.tab_btn4.gameObject:SetActive(false)

    self.tab_btn_red_point_1 = self.tab_btn1.transform:FindChild("NotifyPoint").gameObject
    self.tab_btn_red_point_2 = self.tab_btn2.transform:FindChild("NotifyPoint").gameObject
    self.tab_btn_red_point_3 = self.tab_btn3.transform:FindChild("NotifyPoint").gameObject
    self.tab_btn_red_point_4 = self.tab_btn4.transform:FindChild("NotifyPoint").gameObject

    self.Con_left = self.MainCon:FindChild("Con_left").gameObject
    self.ItemMaskCon = self.Con_left.transform:FindChild("ItemMaskCon").gameObject
    self.ScrollLayer = self.ItemMaskCon.transform:FindChild("ScrollLayer").gameObject
    self.scroll_rect = self.ScrollLayer.transform:GetComponent(ScrollRect)
    self.ItemCon = self.ScrollLayer.transform:FindChild("ItemCon").gameObject
    self.ShouhuItem = self.ItemCon.transform:FindChild("ShouhuItem").gameObject
    self.ShouhuItem:SetActive(false)

    self.guideEffect1 = GameObject.Instantiate(self:GetPrefab(self.effectPath1))
    self.guideEffect1.name = "GuideEffect1"
    local trans = self.guideEffect1.transform
    trans:SetParent(self.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(trans, "UI")
    self.guideEffect1:SetActive(false)
    self.hasInit = true
    ShouhuManager.Instance:request10901()
    ShouhuManager.Instance:Send10921()
    self.help_change_panel = ShouhuHelpChangePanel.New(self)

    EventMgr.Instance:AddListener(event_name.shouhu_wakeup_update, self.OnWakeupListener)
end

--设置下助战红点
function ShouhuMainWindow:update_help_fight_red_point()
    if self.hasInit == false then
        return
    end
    if self.model:check_can_help_fight() then
        self.tab_btn_red_point_3:SetActive(true)
    else
        self.tab_btn_red_point_3:SetActive(false)
    end
end

--设置下守护红点
function ShouhuMainWindow:update_red_point(args)
    if self.tab_btn_red_point_1 ~= nil then
        if self.model:check_has_shouhu_up_stone() then
            self.tab_btn_red_point_1:SetActive(true)
        else
            self.tab_btn_red_point_1:SetActive(false)
        end
    end
    self:update_wakeup_red_point()
    self:update_left_list(args)
end

--检查觉醒页签是否要显示红点
function ShouhuMainWindow:update_wakeup_red_point()
    if self.model:CheckHasShouhuCanWakeup() then
        self.tab_btn_red_point_2:SetActive(true)
    else
        if self.tab_btn_red_point_2 ~= nil then
            self.tab_btn_red_point_2:SetActive(false)
        end
    end

    if RoleManager.Instance.RoleData.lev >= 55 then
        local maxActive = 0
        for key, value in pairs(self.model.wakeUpDataSocketDic) do
            if value.active ~= nil and maxActive < value.active then
                maxActive = value.active
            end
        end
        if maxActive == 0 then
            self.tab_btn_red_point_2:SetActive(true)
        end
    end
end

function ShouhuMainWindow:update_left_list(args)
    ShouhuManager.Instance:on_show_red_point()
    self:destory_left_items()
    self:init_left_list(args)
end

function ShouhuMainWindow:destory_left_items()
    local i = 0
    self.last_selected_item = nil
    if self.shItemList == nil then
        self.shItemList = {}
    end
    if self.shItemList ~= nil then
        for i=1, #self.shItemList do
            if self.shItemList[i] ~= nil then
                self.shItemList[i].ImgSelected.gameObject:SetActive(false)
                self.shItemList[i]:SetActive(false)
            end
        end
    end
end

--初始化左边列表
function ShouhuMainWindow:init_left_list(args)
    --print(debug.traceback())
    -- 出战 -> 助阵 -> 已招募 -> 招募等级
    local has_recruit_list = {} --已招募
    local has_recruit_key_list = {}
    for i=1,#self.model.my_sh_list do
        has_recruit_key_list[self.model.my_sh_list[i].base_id] = 1
        table.insert(has_recruit_list, self.model.my_sh_list[i])
    end

    if self.curSelectedBtn == 4 then
        --按品质高到低来排序
        --当两个数相等的时候，比较函数一定要返回false
        --print("######################")
        --BaseUtils.dump(has_recruit_list,"has_recruit_list:")
        --print(self.list_item_select_id.."self.list_item_select_id")
        local selected_item = nil
        if self.shItemList ~= nil then
            for i=1,#self.shItemList do
                local item = self.shItemList[i]
                item:SetActive(false)
            end
        end
        local not_recruit_list = {} --未招募列表
        local quality_sort = function(a, b)
            if (a.quality >= 4 and self.model:CheckAllGemsBiggerOne(a)) and (b.quality >= 4 and self.model:CheckAllGemsBiggerOne(b)) then
                return a.score > b.score
            elseif (a.quality >= 4 and b.quality >= 4) and (self.model:CheckAllGemsBiggerOne(a) == false or self.model:CheckAllGemsBiggerOne(b) == false) then
                return self.model:GetLowerGemsLevel(a) > self.model:GetLowerGemsLevel(b)
            elseif a.quality < 4 and a.quality < 4 then
                return a.war_id > b.war_id
            end
        end
        table.sort(has_recruit_list, quality_sort)

        --先排品质大于紫色
        local index = 1
        for k, v in pairs(has_recruit_list) do
            if v ~= nil and v.quality >= 4 and self.model:CheckAllGemsBiggerOne(v) and v.quality ~= nil then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end
        --再排 品质大于紫色但宝石等级不足
        for k, v in pairs(has_recruit_list) do
            if v ~= nil and v.quality >= 4 and self.model:CheckAllGemsBiggerOne(v) == false and v.quality ~= nil then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end

        --再排 品质小于紫色
        for k, v in pairs(has_recruit_list) do
            if v ~= nil and v.quality < 4 and v.quality ~= nil then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end

        if selected_item == nil then
            selected_item = self.shItemList[1]
        end

        self:update_right_content(selected_item, args)--默认选中第一条
        local newH = 80*(#has_recruit_list+#not_recruit_list)
        local rect = self.ItemCon.transform:GetComponent(RectTransform)
        rect.sizeDelta = Vector2(0, newH)
        return
    end

    local war_sort = function(a, b)
        if a.war_id ~= 0 and b.war_id ~= 0 then
            return a.score > b.score
        elseif a.war_id ~= b.war_id and (a.war_id == 0 or b.war_id == 0) then
            return a.war_id > b.war_id --根据index从大到小排序
        elseif a.guard_fight_state ~= b.guard_fight_state then
            return a.guard_fight_state > b.guard_fight_state --根据index从大到小排序
        else
            return a.score > b.score
        end
    end
    table.sort(has_recruit_list, war_sort)

    if self.curSelectedBtn == 2 then
        --按品质来排序
        local quality_sort = function(a, b)
            return a.quality < b .quality
        end
        table.sort(has_recruit_list, quality_sort)
    end



    local selected_item = nil
    if self.shItemList ~= nil then
        for i=1,#self.shItemList do
            local item = self.shItemList[i]
            item:SetActive(false)
        end
    end

    local not_recruit_list = {} --未招募列表
    if self.curSelectedBtn == 1 or self.curSelectedBtn == nil then --只有守护招募页签要显示未招募的
        local index = 1
        for k,v in pairs(DataShouhu.data_guard_base_cfg) do
            if has_recruit_key_list[k] == nil and v.display_lev <= RoleManager.Instance.RoleData.lev then

                not_recruit_list[index] = BaseUtils.copytab(v)

                --装备处理
                self.model:init_equip_list(not_recruit_list[index],1)

                --如果角色等级大于招募等级，则按角色等级来取配置算，如果角色等级小于招募等级，则按招募等级来取配置算
                local cfg_lev = 1
                local cfg_data = DataShouhu.data_guard_lev_prop[string.format("%s_%s", not_recruit_list[index].base_id, cfg_lev)]
                not_recruit_list[index].sh_attrs_list = BaseUtils.copytab(cfg_data.base_attrs_cli)
                for k, v in pairs(cfg_data.extra_attrs) do
                    table.insert(not_recruit_list[index].sh_attrs_list, BaseUtils.copytab(v))
                end
                index = index + 1
            end
        end

        local recruit_lev_sort = function(a, b)
            return a.recruit_lev < b.recruit_lev --recruit_lev
        end
        table.sort(not_recruit_list, recruit_lev_sort)
    end

    local index = 1
    if self.curSelectedBtn == 2 then
        for k, v in pairs(has_recruit_list) do
            local item = self.shItemList[index]
            if item == nil then
                item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                table.insert(self.shItemList, item)
            end
            item:set_list_sh_base_data(v)
            item:SetActive(true)
            if self.list_item_select_id == v.base_id then
                selected_item = item
            end
            index = index + 1
        end
    else
        --再排已招募的上阵的
        for k, v in pairs(has_recruit_list) do
            if v ~= nil and v.war_id ~= 0 and v.war_id ~= nil then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end


        --再排待招募
        for k, v in pairs(not_recruit_list) do
            if v ~= nil and v.recruit_lev <= RoleManager.Instance.RoleData.lev then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end


        --再排已招募的未出战同时未上阵的
        for k, v in pairs(has_recruit_list) do
            if v ~= nil and (v.war_id == 0 or v.war_id == nil) then
                local item = self.shItemList[index]
                if item == nil then
                    item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                    table.insert(self.shItemList, item)
                end
                item:set_list_sh_base_data(v)
                item:SetActive(true)
                if self.list_item_select_id == v.base_id then
                    selected_item = item
                end
                index = index + 1
            end
        end
    end

    --最后排未招募的
    for k, v in pairs(not_recruit_list) do
        if v ~= nil and v.recruit_lev > RoleManager.Instance.RoleData.lev  then
            local item = self.shItemList[index]
            if item == nil then
                item = ShouhuMainItem.New(self, self.ShouhuItem, v, index)
                table.insert(self.shItemList, item)
            end
            item:set_list_sh_base_data(v)
            item:SetActive(true)
            if self.list_item_select_id == v.base_id then
                selected_item = item
            end
            index = index + 1
        end
    end

    if self.model.main_tab_first_opera_type == 0 then
         if self.openArgs ~= nil and #self.openArgs > 0 then
            --选中指定的外界指定的守护
            local sh_id = self.openArgs[1]
            for i=1,#self.shItemList do
                local item = self.shItemList[i]
                if item.data.base_id == sh_id then
                    selected_item = item
                    break
                end
            end
        end
    elseif self.model.main_tab_first_opera_type == 1 then
        --如果选中一个守护休息后 则选中下一个可休息的
        for i=1,#self.shItemList do
            local item = self.shItemList[i]
            if item.data.war_id ~= 0 then
                selected_item = item
                break
            end
        end
    elseif self.model.main_tab_first_opera_type == 2 then
        --如果选中一个守护上阵后 则选中下一个可上阵的
        for i=1,#self.shItemList do
            local item = self.shItemList[i]
            if item.data.war_id == 0 and item.data.guard_fight_state == self.model.guard_fight_state.idle then
                selected_item = item
                break
            end
        end
    end
    if selected_item == nil then
        selected_item = self.shItemList[1]
    end

    self:update_right_content(selected_item, args)--默认选中第一条
    local newH = 80*(#has_recruit_list+#not_recruit_list)
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)

    self.model.main_tab_first_opera_type = 0
end


-----------------上阵拖动辅助逻辑
-- 记录拖动对象
function ShouhuMainWindow:record_drag_item(item)
    self.enter_drag_item = item
end

-- 上阵逻辑
function ShouhuMainWindow:do_shang_zhen(dragItem)
    if self.enter_drag_item ~= nil then
        if self.enter_drag_item.has_act == false then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前阵位尚未激活"))
            self.enter_drag_item = nil
            return
        end
        local enter_data = self.enter_drag_item.myShData
        local enter_pos_data = self.enter_drag_item.myData
        self.enter_drag_item = nil

        -- dragItem.data.guard_fight_state ==nil  是配置的没招募的，这个值就是nil
        if dragItem.data.guard_fight_state ~= self.model.guard_fight_state.idle and dragItem.data.guard_fight_state ~= nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该守护已助战"))
            return
        end
        if enter_data ~= nil and dragItem.data.base_id == enter_data.base_id then
            return
        end
        if enter_pos_data == nil then
            return
        end
        ShouhuManager.Instance:request10905(enter_pos_data.act_pos, dragItem.data.base_id)
    end
end

--切换阵位逻辑
function ShouhuMainWindow:switch_tatic_pos(dragItem)
    if self.enter_drag_item ~= nil and self.enter_drag_item.has_act == false then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前阵位尚未激活"))
        self.enter_drag_item = nil
        return
    end
    if self.enter_drag_item == nil or self.enter_drag_item == dragItem then
        ShouhuManager.Instance:request10909(dragItem.myShData.base_id) --离阵
        return
    else
        local enter_data = self.enter_drag_item.myShData
        local enter_pos_data = self.enter_drag_item.myData
        self.enter_drag_item = nil
        if enter_data ~= nil and dragItem.data ~= nil and dragItem.data.base_id == enter_data.base_id then
            return
        end
        --交换
        ShouhuManager.Instance:request10905(enter_pos_data.act_pos, dragItem.myShData.base_id)
    end
end


-- 更新界面逻辑
function ShouhuMainWindow:update_view()
    if (#self.model.my_sh_list >0 and self.model.shouhu_icon_effect == false) or self.is_force_open_tab == true then
        self.tab_btn1.gameObject:SetActive(true)
        if RoleManager.Instance.RoleData.lev >= self.zhuzhen_open_lev then --大于等于self.zhuzhen_open_lev才开启助阵
            self.tab_btn3.gameObject:SetActive(true)
        end
        if RoleManager.Instance.RoleData.lev >= self.transfer_open_lev then --大于等于self.transfer_open_lev才开启转换
            self.tab_btn4.gameObject:SetActive(true)
        else
            self.tab_btn4.gameObject:SetActive(false)
        end
        self.tab_btn2.gameObject:SetActive(self.model:CheckWakeUpIsOpen())
        self.curSelectedBtn = self.curSelectedBtn == nil and 1 or self.curSelectedBtn
        self:tabChange(self.curSelectedBtn)
    else
        self.tab_btn1.gameObject:SetActive(true)
        self.tab_btn2.gameObject:SetActive(false)
        self.tab_btn3.gameObject:SetActive(false)
        self.tab_btn4.gameObject:SetActive(false)
        if RoleManager.Instance.RoleData.lev >= self.zhuzhen_open_lev then --大于等于self.zhuzhen_open_lev才开启助阵
            self.tab_btn3.gameObject:SetActive(true)
        end
        if RoleManager.Instance.RoleData.lev >= self.transfer_open_lev then --大于等于self.transfer_open_lev才开启转换
            self.tab_btn4.gameObject:SetActive(true)
        else
            self.tab_btn4.gameObject:SetActive(false)
        end
        self.tab_btn2.gameObject:SetActive(self.model:CheckWakeUpIsOpen())
        self:tabChange(1)
    end

    self.is_force_open_tab = false
end

--更新助阵信息
function ShouhuMainWindow:update_star_view()
    if self.zhuzhenTab ~= nil then
        self.zhuzhenTab:update_star_tactic()
    end
end


--更新主界面
function ShouhuMainWindow:update_first_sh_equip()
    if self.subFirst ~= nil then
        self.subFirst:update_sh_equip()
    end
end

--更新右边内容
function ShouhuMainWindow:update_right_content(item, args)
    --print(debug.traceback())
    if not BaseUtils.is_null(self.guideEffect1) then
        self.guideEffect1:SetActive(false)
    end

    if self.last_selected_item ~= nil then
        self:set_list_selected_sate(self.last_selected_item, false)
    end
    self.list_item_select_id = item.data.base_id
    self:set_list_selected_sate(item, true)
    self.last_selected_item = item
    --print(self.last_selected_item.data.base_id)

    if args == nil then
        if self.curSelectedBtn == 1 then
            if self.subFirst ~= nil then
                self.subFirst:update_content(item.data)
            end
        elseif self.curSelectedBtn == 2 then
            self.wakeUpTab:UpdateContent(item.data)
        elseif self.curSelectedBtn == 3 then
            self.zhuzhenTab:update_star_tactic()
        elseif self.curSelectedBtn == 4 then
            if self.transferTab ~= nil then
                self.transferTab:UpdateContent(item.data)
            end
        elseif self.curSelectedBtn == nil then
            self:update_view()
        end
    else
        if self.curSelectedBtn == 1 and args[self.curSelectedBtn] then
            if self.subFirst ~= nil then
                self.subFirst:update_content(item.data)
            end
        elseif self.curSelectedBtn == 2 and args[self.curSelectedBtn] then
            self.wakeUpTab:UpdateContent(item.data)
        elseif self.curSelectedBtn == 3 and args[self.curSelectedBtn] then
            self.zhuzhenTab:update_star_tactic()
        elseif self.curSelectedBtn == 4 and args[self.curSelectedBtn] then
            if self.transferTab ~= nil then
                self.transferTab:UpdateContent(item.data)
            end
        elseif self.curSelectedBtn == nil then
            self:update_view()
        end
    end

    if self.guideTimeId ~= nil then
        LuaTimer.Delete(self.guideTimeId)
        self.guideTimeId = nil
    end
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    -- TipsManager.Instance:HideGuide()

    if self.curSelectedBtn == 1 then
        -- 出战。替换。装备升级引导
        if item.data.war_id ~= nil then
            self:CheckGuide()
        else
            if self.guideTimeId ~= nil then
                LuaTimer.Delete(self.guideTimeId)
                self.guideTimeId = nil
            end
            if self.guideScript ~= nil then
                self.guideScript:DeleteMe()
                self.guideScript = nil
            end
        end

        if ShouhuManager.Instance.needGuide then
            if ShouhuManager.Instance:HasEmpty() then
                -- 有空位，直接引导阿瑞斯上阵
                if self.last_selected_item.data.base_id ~= 1020 then
                    self:GuideLeft2()
                end
            else
                -- 没空位，先引导菲亚下阵
                if self.last_selected_item.data.base_id ~= 1002 then
                    self:GuideLeft1()
                end
            end
        else
            if ShouhuManager.Instance:Checkaien() then
                if self.last_selected_item.data.base_id ~= 1018 then
                    self:GuideLeft()
                end
            end
        end
    elseif self.curSelectedBtn == 2 then
        if self.model:GuideGuardWakeup() then
            if self.last_selected_item.data.base_id ~= 1002 then
                self:GuideLeft3()
            else
                self:GuideGuardWakeupSec()
            end
        end
    end

    if self.curSelectedBtn ~= 3 then
        if ShouhuManager.Instance:CheckHelpGuide() then
            self:GuideHelpTabChange()
        end
    end
end

--设置守护条目选中状态
function ShouhuMainWindow:set_list_selected_sate(item, state)
    item.ImgSelected.gameObject:SetActive(state)
end

function ShouhuMainWindow:switch_tab_btn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn3.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn4.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn3.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn4.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

 -- 切换tab逻辑
function ShouhuMainWindow:tabChange(index)
    if self.hasInit == false then
        return
    end
    self.curSelectedBtn = index
    if index == 1 then
        self:switch_tab_btn(self.tab_btn1)
        self:ShowFirst(true)
        self:ShowZhuZhen(false)
        self:ShowWakeUp(false)
        self:ShowTransfer(false)
    elseif index == 2 then
        self:switch_tab_btn(self.tab_btn2)
        self:ShowFirst(false)
        self:ShowZhuZhen(false)
        self:ShowWakeUp(true)
        self:ShowTransfer(false)
    elseif index == 3 then
        self:switch_tab_btn(self.tab_btn3)
        self:ShowFirst(false)
        self:ShowZhuZhen(true)
        self:ShowWakeUp(false)
        self:ShowTransfer(false)
    elseif index == 4 then
        ShouhuManager.Instance:Send10921()
        --ShouhuManager.Instance:request10901()
        self:switch_tab_btn(self.tab_btn4)
        self:ShowFirst(false)
        self:ShowZhuZhen(false)
        self:ShowWakeUp(false)
        self:ShowTransfer(true)
    end
    self:init_left_list()
end

function ShouhuMainWindow:ShowFirst(IsShow)
    if IsShow then
        if self.subFirst == nil then
            self.subFirst = ShouhuMainTabFirst.New(self)
            self.subFirst:Show()
        else
            self.subFirst:Show()
            self.subFirst:update_content(self.last_selected_item.data)
        end
    else
        if self.subFirst ~= nil then
            self.subFirst:Hiden()
        end
    end
end

function ShouhuMainWindow:ShowZhuZhen(IsShow)
    if IsShow then
        if self.zhuzhenTab == nil then
            self.zhuzhenTab = ShouhuMainTabSecond.New(self)
        end
        self.zhuzhenTab:Show()
    else
        if self.zhuzhenTab ~= nil then
            self.zhuzhenTab:Hiden()
        end
    end
end

function ShouhuMainWindow:ShowWakeUp(IsShow)
    if IsShow then
        if self.wakeUpTab == nil then
            self.wakeUpTab = ShouhuWakeUpPanel.New(self)
            self.wakeUpTab:Show()
        else
            self.wakeUpTab:Show()
            self.wakeUpTab:UpdateContent(self.last_selected_item.data)
        end
    else
        if self.wakeUpTab ~= nil then
            self.wakeUpTab:Hiden()
        end
    end
end

function ShouhuMainWindow:ShowTransfer(IsShow)
    if IsShow then
        if self.transferTab == nil then
            self.transferTab = ShouhuTransferTab.New(self)
            self.transferTab:Show()
        else
            self.transferTab:Show()
            self.transferTab:UpdateContent(self.last_selected_item.data)
        end
    else
        if self.transferTab ~= nil then
            self.transferTab:Hiden()
        end
    end
end

function ShouhuMainWindow:ShowHelpChangePanel(args, _type)
    local args_table = {index = args, type = _type}
    self.help_change_panel:Show(args_table)
end

function ShouhuMainWindow:CheckGuide()
    local role = RoleManager.Instance.RoleData
    if role.lev >= 40 and role.lev < 50
        and role.coin >= 50000
        and QuestManager.Instance.questTab[41570] ~= nil and QuestManager.Instance.questTab[41570].finish ~= QuestEumn.TaskStatus.Finish
        and ShouhuManager.Instance.model:check_all_shangzhen_no_up()
    then
        -- 装备升级
        if self.guideScript == nil then
            self.guideScript = GuideGuardUpgrade.New(self)
            self.guideTimeId = LuaTimer.Add(500, function() self.guideScript:Show() end)
        end
    end

    if self.model:GuideGuardWakeup() then
        -- 魂石激活
        if self.guideScript == nil then
            self.guideScript = GuideGuardWakeup.New(self)
            self.guideTimeId = LuaTimer.Add(500, function() self.guideScript:Show() end)
        end
    end
end

function ShouhuMainWindow:GuideExtra()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    self.guideScript = GuideGuardUpgradeThird.New(self)
    self.guideScript:Show()
end

-- 凯恩 招募引导
function ShouhuMainWindow:GuideLeft()
    if BaseUtils.is_null(self.guideEffect1) then
        return
    end

    local parent = nil
    for i,item in ipairs(self.shItemList) do
        if item.data ~= nil and item.data.base_id == 1018 then
            parent = item.transform
            break
        end
    end

    local trans = self.guideEffect1.transform
    trans:SetParent(parent)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3(110, -35, -500)
    self.guideEffect1:SetActive(true)
    LuaTimer.Add(200, function()
        TipsManager.Instance:ShowGuide({gameObject = parent.gameObject, data = TI18N("选择<color='#ffff00'>凯恩</color>，他可以<color='#ffff00'>控制敌人</color>哦"), forward = TipsEumn.Forward.Right})
    end)
end

-- 菲雅休息引导
function ShouhuMainWindow:GuideLeft1()
    if BaseUtils.is_null(self.guideEffect1) then
        return
    end

    local parent = nil
    for i,item in ipairs(self.shItemList) do
        if item.data ~= nil and item.data.base_id == 1002 then
            parent = item.transform
            break
        end
    end

    local trans = self.guideEffect1.transform
    trans:SetParent(parent)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3(110, -35, -500)
    self.guideEffect1:SetActive(true)
    LuaTimer.Add(200, function()
        TipsManager.Instance:ShowGuide({gameObject = parent.gameObject, data = TI18N("选择被替换的守护"), forward = TipsEumn.Forward.Right})
    end)
end

-- 阿瑞斯上阵引导
function ShouhuMainWindow:GuideLeft2()
    if BaseUtils.is_null(self.guideEffect1) then
        return
    end

    local parent = nil
    for i,item in ipairs(self.shItemList) do
        if item.data ~= nil and item.data.base_id == 1020 then
            parent = item.transform
            break
        end
    end

    local trans = self.guideEffect1.transform
    trans:SetParent(parent)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3(110, -35, -500)
    self.guideEffect1:SetActive(true)
    LuaTimer.Add(200, function()
        TipsManager.Instance:ShowGuide({gameObject = parent.gameObject, data = TI18N("选择需上阵的守护"), forward = TipsEumn.Forward.Right})
    end)
end

-- 菲亚魂石引导
function ShouhuMainWindow:GuideLeft3()
    if BaseUtils.is_null(self.guideEffect1) then
        return
    end

    local parent = nil
    for i,item in ipairs(self.shItemList) do
        if item.data ~= nil and item.data.base_id == 1002 then
            parent = item.transform
            break
        end
    end

    local trans = self.guideEffect1.transform
    trans:SetParent(parent)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3(110, -35, -500)
    self.guideEffect1:SetActive(true)
    LuaTimer.Add(200, function()
        TipsManager.Instance:ShowGuide({gameObject = parent.gameObject, data = TI18N("选择守护"), forward = TipsEumn.Forward.Right})
    end)
end

-- 菲亚魂石引导2
function ShouhuMainWindow:GuideGuardWakeupSec()
    -- 魂石激活
    if self.guideScript == nil then
        self.guideScript = GuideGuardWakeupSec.New(self)
        self.guideTimeId = LuaTimer.Add(500, function() self.guideScript:Show() end)
    end
end

function ShouhuMainWindow:GuideHelpTabChange()
    if self.guideScript == nil then
        self.guideScript = GuideGuardHelpTab.New(self)
        self.guideTimeId = LuaTimer.Add(200, function() self.guideScript:Show() end)
    end
end
