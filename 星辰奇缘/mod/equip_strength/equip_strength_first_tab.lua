EquipStrengthFirstTab = EquipStrengthFirstTab or BaseClass(BasePanel)

function EquipStrengthFirstTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_tab1, type = AssetType.Main}
    }
    self.role_con = nil
    self.build_con = nil
    self.strength_con = nil
    self.dianhua_con = nil

    self.strengthTips = nil
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.checkGuidePoint = function() self:CheckGuidePoint() end

    return self
end

function EquipStrengthFirstTab:__delete()

    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkGuidePoint)
    if self.build_con ~= nil then
        self.build_con:DeleteMe()
    end
    if self.role_con ~= nil then
        self.role_con:DeleteMe()
    end
    if self.strength_con ~= nil then
        self.strength_con:DeleteMe()
    end
    if self.dianhua_con ~= nil then
        self.dianhua_con:DeleteMe()
    end

    if self.strengthTips ~= nil then
        self.strengthTips:DeleteMe()
    end

    self.build_con = nil
    self.role_con = nil
    self.strength_con = nil
    self.dianhua_con = nil
    self.strengthTips = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.has_init = false
    self:AssetClearAll()
end

function EquipStrengthFirstTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_tab1))
    self.gameObject.name = "EquipStrengthFirstTab"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self:ShowCon(self.parent.cur_index)
    self:OnOpen()

end

function EquipStrengthFirstTab:OnOpen()
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkGuidePoint)
    self:CheckGuidePoint()
end

--显示右边那个容器，外部父窗口调用
function EquipStrengthFirstTab:ShowCon(index)
    self.cur_tab_index = index
    self:hide_all()
    if index == 1 then
        --锻造
        if self.build_con == nil then
            self.build_con = EquipStrengthFirstBuild.New(self)
        else
            if self.cur_left_selected_data ~= nil then
                self.build_con:update_info(self.cur_left_selected_data)
            end
        end
        self.build_con:Show()
    elseif index == 2 then
        --重铸
        if self.build_con == nil then
            self.build_con = EquipStrengthFirstBuild.New(self)
        else
            if self.cur_left_selected_data ~= nil then
                self.build_con:update_info(self.cur_left_selected_data)
            end
        end
        self.build_con:Show()
    elseif index == 3 then
        --强化
        if self.strength_con == nil then
            self.strength_con = EquipStrengthFirstDo.New(self)
        else
            if self.cur_left_selected_data then
                self.strength_con:update_info(self.cur_left_selected_data)
            end
        end
        self.strength_con:Show()
    elseif index == 4 then
        --精炼
        if self.dianhua_con == nil then
            self.dianhua_con = EquipStrengthDianhuaTab.New(self)
        else
            if self.cur_left_selected_data then
                self.dianhua_con:update_info(self.cur_left_selected_data)
            end
        end
        self.dianhua_con:Show()
    end
    if self.role_con ~= nil and self.role_con.gameObject ~= nil then
        self.role_con:update_bottom_con()
        self.role_con:update_slot_redpoint()
        self.role_con:update_cur_selected_equip()
    else
        self.role_con = EquipStrengthFirstRole.New(self)
        self.role_con:Show()
    end

    self:HideStrengthTips()
end

--隐藏右边全部
function EquipStrengthFirstTab:hide_all()
    if self.build_con ~= nil then
        self.build_con:Hiden()
    end
    if self.strength_con ~= nil then
        self.strength_con:Hiden()
    end
    if self.dianhua_con ~= nil then
        self.dianhua_con:Hiden()
    end

    self:HideStrengthTips()
end

--更新当前选中的装备数据，协议调用
function EquipStrengthFirstTab:update_selected_data()
    -- self.cur_left_selected_data
end

--更新右边逻辑,被EquipStrengthFirstRole调用
function EquipStrengthFirstTab:update_right(data, is_item_update)
    self.cur_left_selected_data = data
    if self.cur_tab_index == 1 then
        --锻造
        if self.build_con ~= nil then
            self.build_con:update_info(data, is_item_update)
        end
    elseif self.cur_tab_index == 2 then
        --重铸
        if self.build_con ~= nil then
            self.build_con:update_info(data, is_item_update)
        end
    elseif self.cur_tab_index == 3 then
        --强化
        if self.strength_con ~= nil then
            self.strength_con:update_info(data)
        end
    elseif self.cur_tab_index == 4 then
        --电话
        if self.dianhua_con ~= nil then
            self.dianhua_con:update_info(data, 1, is_item_update)
        end
    end
end

-- 显示强化光环预览tips
function EquipStrengthFirstTab:ShowStrengthTips()
    if self.strengthTips == nil then
        self.strengthTips = EquipStrengthTips.New(self)
    end
    self.strengthTips:Show(args)
end

-- 隐藏强化光环预览tips
function EquipStrengthFirstTab:HideStrengthTips()
    if self.strengthTips ~= nil then
        self.strengthTips:DeleteMe()
        self.strengthTips = nil
    end
end

function EquipStrengthFirstTab:OnHide()
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkGuidePoint)
end
function EquipStrengthFirstTab:CheckGuidePoint()
    if MainUIManager.Instance.priority == 3 and self.parent.curSelectedBtn == 1 then
        local isGuidePoint = false
        local data = DataQuest.data_get[41021]
        local questData = QuestManager.Instance:GetQuest(data.id)
        if questData ~= nil and questData.finish == 1 then
            isGuidePoint = true
        end

        if isGuidePoint == true then
            if self.role_con ~= nil and self.role_con.selectIndex ~= 1 then
                if self.build_con ~= nil then
                    self.build_con:HideGuideEffect()
                end
                self.role_con:CheckGuidePoint()
            elseif self.build_con ~= nil and self.role_con.selectIndex == 1 then
                if self.role_con ~= nil then
                    self.role_con:HideGuideEffect()
                end

                self.build_con:CheckGuidePoint()
            end
        else
            if self.build_con ~= nil then
                self.build_con:HideGuideEffect()
            end

            if self.role_con ~= nil then
                self.role_con:HideGuideEffect()
            end

        end
    elseif MainUIManager.Instance.priority == 1 and self.parent.curSelectedBtn == 4 then
        local isGuidePoint = false
        local data = DataQuest.data_get[41310]
        local questData = QuestManager.Instance:GetQuest(data.id)
        if questData ~= nil and questData.finish == 1 then
            isGuidePoint = true
        end

        if isGuidePoint == true then
            if self.role_con ~= nil and self.role_con.selectIndex ~= 1 then
                if self.strength_con ~= nil then
                    self.strength_con:HideGuideEffect()
                end
                self.role_con:CheckGuidePoint()
            elseif self.strength_con ~= nil and self.role_con.selectIndex == 1 then
                if self.role_con ~= nil then
                    self.role_con:HideGuideEffect()
                end

                self.strength_con:CheckGuidePoint()
            end
        else
            if self.strength_con ~= nil then
                self.strength_con:HideGuideEffect()
            end

            if self.role_con ~= nil then
                self.role_con:HideGuideEffect()
            end
        end
    elseif MainUIManager.Instance.priority == -1 and self.parent.curSelectedBtn == 5 then
        local isGuidePoint = false
        local data = DataQuest.data_get[41640]
        local questData = QuestManager.Instance:GetQuest(data.id)
        if questData ~= nil and questData.finish == 1 then
            isGuidePoint = true
        end

         if isGuidePoint == true then
            if self.role_con ~= nil and self.role_con.selectIndex ~= 1 then
                if self.dianhua_con ~= nil then
                    self.dianhua_con:HideGuideEffect()
                end
                self.role_con:CheckGuidePoint()
            elseif self.dianhua_con ~= nil and self.role_con.selectIndex == 1 then
                if self.role_con ~= nil then
                    self.role_con:HideGuideEffect()
                end

                self.dianhua_con:CheckGuidePoint()
            end
        else
            if self.dianhua_con ~= nil then
                self.dianhua_con:HideGuideEffect()
            end

            if self.role_con ~= nil then
                self.role_con:HideGuideEffect()
            end
        end

    else
        if self.role_con ~= nil then
            self.role_con:HideGuideEffect()
        end

        if self.build_con ~= nil then
            self.build_con:HideGuideEffect()
        end

        if self.strength_con ~= nil then
            self.strength_con:HideGuideEffect()
        end

        if self.dianhua_con ~= nil then
            self.dianhua_con:HideGuideEffect()
        end

        GuideManager.Instance.effect:Hide()
    end

end


