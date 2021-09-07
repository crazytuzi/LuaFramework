WorldBossKillRankWindow  =  WorldBossKillRankWindow or BaseClass(BaseWindow)

function WorldBossKillRankWindow:__init(model)
    self.name  =  "WorldBossKillRankWindow"
    self.model  =  model
    self.resList  =  {
        {file  =  AssetConfig.world_boss_rank_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.heads, type  =  AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.world_boss_honor_list

    self.item_list = nil

    self.curSelectedIndex = 0
    return self
end


function WorldBossKillRankWindow:__delete()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    self.is_open = false

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.item_list = nil
    self:AssetClearAll()
end


function WorldBossKillRankWindow:InitPanel()
     if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_boss_rank_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldBossKillRankWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.is_open = true
    self.MainCon = self.transform:FindChild("MainCon")

    local tabGroup = self.MainCon:FindChild("TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:tabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:tabChange(2) end)
    self.tab_btn3 = tabGroup.transform:GetChild(2):GetComponent(Button)
    self.tab_btn3.onClick:AddListener(function() self:tabChange(3) end)
    self.tab_btn_red_point_1 = self.tab_btn1.transform:FindChild("NotifyPoint").gameObject
    self.tab_btn_red_point_2 = self.tab_btn2.transform:FindChild("NotifyPoint").gameObject
    self.tab_btn_red_point_3 = self.tab_btn3.transform:FindChild("NotifyPoint").gameObject

    self.MaskLayer = self.MainCon:FindChild("Con_left"):FindChild("MaskLayer").gameObject
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer")
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)
    self.LayoutLayer = self.ScrollLayer:FindChild("LayoutLayer")
    self.item_con_last_y = self.LayoutLayer:GetComponent(RectTransform).anchoredPosition.y

    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,10 do
        local go = self.LayoutLayer:FindChild(tostring(i)).gameObject
        local item = WorldBossKillRankItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.ScrollLayer:GetComponent(RectTransform).sizeDelta.y


    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.LayoutLayer  --item列表的父容器
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

    self.CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseWorldBossRankUI() end)

    self:tabChange(1)
end

--切换选项卡
function WorldBossKillRankWindow:tabChange(index)
    if self.curSelectedIndex == index then
        return
    end
    self.curSelectedIndex = index
    if index == 1 then
        self:switch_tab_btn(self.tab_btn1)
        WorldBossManager.Instance:request13001(self.model.boss_rank_id)
    elseif index == 2 then
        self:switch_tab_btn(self.tab_btn2)
        self:update_view(self.model.world_boss_data.first_killer, 2)
    elseif index == 3 then
        self:switch_tab_btn(self.tab_btn3)
        WorldBossManager.Instance:request13004(self.model.boss_rank_id)
    end
end

function WorldBossKillRankWindow:switch_tab_btn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn3.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn3.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

function WorldBossKillRankWindow:update_view(data_list , _type)


    local current_data_list = {}
    if _type == 1 then
        local time_sort = function(a, b)
            return a.finished > b.finished --根据index从小到大排序
        end

        local round_sort = function(a, b)
            return a.rank_round < b.rank_round --根据index从小到大排序
        end

        table.sort(data_list, time_sort)
        table.sort(data_list, round_sort)

        local item_index = 1
        for i=1,#data_list do
            local data = data_list[i]
            for j=1,#data.team do
                local d = data.team[j]
                d.index = item_index
                d.type = _type
                d.finished = data.finished
                table.insert(current_data_list, d)
                item_index = item_index + 1
            end
        end
    elseif _type == 2 then
        local first_killer = nil
        for i=1,#self.model.world_boss_data.boss_list do
            local boss_data = self.model.world_boss_data.boss_list[i]
            if boss_data.id == self.model.boss_rank_id then
                first_killer = boss_data.first_killer
                break
            end
        end

        for i=1,#first_killer do
            first_killer[i].index = i
            first_killer[i].type = _type
        end

        current_data_list = first_killer
    elseif _type == 3 then
        for i=1,#data_list do
            data_list[i].index = i
            data_list[i].type = _type
        end

        current_data_list = data_list
    end

    self.setting_data.data_list = current_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
end