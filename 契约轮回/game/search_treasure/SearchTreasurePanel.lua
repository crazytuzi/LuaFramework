SearchTreasurePanel = SearchTreasurePanel or class("SearchTreasurePanel", WindowPanel)
local SearchTreasurePanel = SearchTreasurePanel

function SearchTreasurePanel:ctor()
    self.abName = "search_treasure"
    self.assetName = "SearchTreasurePanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.panel_type = 7                              --窗体样式  1 1280*720  2 850*545
    self.use_camerablur = true
    self.show_sidebar = true        --是否显示侧边栏
    if self.show_sidebar then
        -- 侧边栏配置
        self.sidebar_data = {
            { text = ConfigLanguage.SearchT.Title, id = 1, img_title = "search_treasure:img_title", icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", },
            { text = ConfigLanguage.SearchT.Title2, id = 2, img_title = "search_treasure:img_title2", icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", show_lv = 371, open_lv = 371 },
            { text = ConfigLanguage.SearchT.Title4, id = 3, img_title = "search_treasure:img_title4", icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", show_lv = 180, open_lv = 180 },
            { text = ConfigLanguage.SearchT.Title5, id = 4, img_title = "search_treasure:img_title5", icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", show_lv = 450, open_lv = 450 },
            
            --积分商店
            { text = ConfigLanguage.SearchT.Title3, id = 5, img_title = "search_treasure:img_title3", icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", },
        }
    end
    self.table_index = nil
    self.model = SearchTreasureModel:GetInstance()
    --self.is_show_money = { self.model.gold_key_id, Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }

    self.type_id = 1
    self.item_list = {} --普通奖励
    self.item_list2 = {} --珍稀奖励
    self.msg_list = {}    --个人记录
    self.msg_list2 = {}   --全服记录
    self.global_events = {}

    self.ScoreShop = nil;

end

function SearchTreasurePanel:dctor()
    for i, v in pairs(self.item_list2) do
        v:destroy()
    end

    self.item_list2 = {}

    for i, v in pairs(self.item_list) do
        v:destroy()
    end

    self.item_list = {}

    if self.ScoreShop then
        self.ScoreShop:destroy()
        self.ScoreShop = nil
    end

end

function SearchTreasurePanel:Open(index)
    self.default_table_index = index
    SearchTreasurePanel.super.Open(self)
end

function SearchTreasurePanel:LoadCallBack()
    self.nodes = {
        "right/rare/rare1/icon1", "right/rare/rare2/icon2", "right/rare/rare3/icon3", "right/common/ScrollView/Viewport/Content",
        "right/common/bless_title/bless_scrolbar", "right/common/btnbuy", "record/storagebtn", "right/common/btnbuyten", "right/common/btnbuyfifty",
        "record/togglegroup/searchrecord", "record/togglegroup/myrecord", "record/recordcontent/ScrollView/Viewport/MsgContent",
        "record/recordcontent/ScrollView2/Viewport/MsgContent2", "record/recordcontent/ScrollView2", "record/recordcontent/ScrollView",
        "right/common/btnbuy/gold", "right/common/btnbuyten/gold10", "right/common/btnbuyfifty/gold50", "right/common/bless_title/bless_value",
        "right/common/bless_title/tipsbtn", "right/rare/rare1/name1", "right/rare/rare2/name2", "right/rare/rare3/name3",
        "right/common/ScrollView/Scrollbar", "record/recordcontent/tips", "right/common/first_turn",
        "right/common/btnbuy/zuanshi", "right/common/btnbuyten/zuanshi2", "right/common/btnbuyfifty/zuanshi3",
        "right/common/goods/goods_num", "right/common/goods/goods_icon", "right/common/bless_title/probbtn",
        "bg", "record", "right", "right/common/score/score_num", "right/common/score/score_icon",
        "record/togglegroup/myrecord/TextMy", "record/togglegroup/searchrecord/TextAll", "right/tips/tips_content3",

        --涉及寻宝类型切换需要修改的UI
        "bg/content_bg", "bg/content_bg2", "bg/content_bg3", "right/tips/tips_content4",
        "right/tips/tips_content2",
    }
    self:GetChildren(self.nodes)

    self.bless_scrolbar = self.bless_scrolbar:GetComponent('Scrollbar')
    self.searchrecord = GetToggle(self.searchrecord)
    self.myrecord = GetToggle(self.myrecord)
    self.gold = GetText(self.gold)
    self.gold10 = GetText(self.gold10)
    self.gold50 = GetText(self.gold50)
    self.bless_value = GetText(self.bless_value)
    --[[  self.name1 = GetText(self.name1)
     self.name2 = GetText(self.name2)
     self.name3 = GetText(self.name3) ]]
    self.Scrollbar = self.Scrollbar:GetComponent('Scrollbar')
    self.tips = GetImage(self.tips)
    self.zuanshi = GetImage(self.zuanshi)
    self.zuanshi2 = GetImage(self.zuanshi2)
    self.zuanshi3 = GetImage(self.zuanshi3)
    self.goods_icon = GetImage(self.goods_icon)
    self.goods_num = GetText(self.goods_num)
    self.TextMy = GetText(self.TextMy)
    self.TextAll = GetText(self.TextAll)

    self.bg = GetRectTransform(self.bg)
    self.record = GetRectTransform(self.record)
    self.right = GetRectTransform(self.right)
    self.score_num = GetText(self.score_num)

    self.score_icon = GetImage(self.score_icon)
    local icon = Config.db_item[self.model.score_key_id].icon
    GoodIconUtil.GetInstance():CreateIcon(self, self.score_icon, icon, true)

    self.img_ScrollView = GetImage(self.ScrollView)
    self.img_ScrollView2 = GetImage(self.ScrollView2)

    self:AddEvent()

    --获取相关信息
    --SearchTreasureController:GetInstance():RequestGetInfo(self.type_id)
    --SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 1)
    BagController:GetInstance():RequestBagInfo(BagModel.stHouseId)


end

function SearchTreasurePanel:DoSearch(num, need_gold)
    local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
    if not bo then
        return
    end
    SearchTreasureController:GetInstance():RequestSearch(self.type_id, num)
end

function SearchTreasurePanel:RequestSearch(num)

    local keyId
    local key
    if self.type_id == 1 then
        keyId = self.model.gold_key_id
        key = "Treasure Hunting Key"
    elseif self.type_id == 2 then
        keyId = self.model.silver_key_id
        key = "Peak Key"
    elseif self.type_id == 3 then
        keyId = self.model.gundam_key_id
        key = "Memory Chip"
    elseif self.type_id == 4 then
        keyId = self.model.supermecy_key_id
        key = "Ultimate Key"
    end

    --获取钥匙数量
    local had_num = BagController:GetInstance():GetItemListNum(keyId)
    local batch = Config.db_searchtreasure_batch[self.model.batch_id]
    local cost = String2Table(batch.cost)
    local need_num = 1
    for i = 1, #cost do
        if num == cost[i][1] then
            need_num = cost[i][3]
            break
        end
    end
    if had_num >= need_num then
        self:DoSearch(num, 0)
    else
        --钥匙数量不足 提示购买
        local gold_num = need_num - had_num

        local gold = Config.db_voucher[keyId].price * gold_num

        local message = ""
        if had_num > 0 then
            message = string.format(ConfigLanguage.SearchT.AlertMsg5, key, gold, key, gold_num)
        else
            message = string.format(ConfigLanguage.SearchT.AlertMsg4, key, gold, key, gold_num)
        end
        if self.model.is_check then
            self:DoSearch(num, gold)
        else
            local function ok_fun(is_check)
                self.model.is_check = is_check
                self:DoSearch(num, gold)
            end
            Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
        end
    end
end

--请求寻宝 num:寻宝次数
function SearchTreasurePanel:RequestSearch2(num)
    --[[local function ok_fun()
        self:RequestSearch(num)
    end
    local info = self.model:GetInfo(self.type_id)
    if info.turn == 1 and RoleInfoModel:GetInstance():GetRoleValue("viplv") < 4
            and info.bless_value == 0 then
        Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, ConfigLanguage.SearchT.AlertMsg3, nil, ok_fun)
    else--]]
    self:RequestSearch(num)
    --end
end

function SearchTreasurePanel:AddEvent()

    --处理基本信息刷新
    local function call_back()
        self:UpdateView()
        self:AutoScroll() --内部有判断 保证只会调用一次
    end
    self.event_id = self.model:AddListener(SearchTreasureEvent.UpdateInfo, call_back)

    --处理寻宝记录刷新
    local function call_back()
        local is_global = 0
        if self.searchrecord.isOn then
            is_global = 1
        end
        local messages = self.model:GetMessages(self.type_id, is_global)

        --判断个人记录还是全服记录
        if is_global == 1 then
            SetVisible(self.ScrollView, false)
            SetVisible(self.ScrollView2, true)
            self:UpdateMessages(self.msg_list2, self.MsgContent2, messages)
        else
            SetVisible(self.ScrollView, true)
            SetVisible(self.ScrollView2, false)
            self:UpdateMessages(self.msg_list, self.MsgContent, messages)
        end
    end
    self.event_id2 = self.model:AddListener(SearchTreasureEvent.UpdateMessages, call_back)

    --处理红点
    local function call_back()
        self:ShowRedDot()
        self:ShowStorageRedDot()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)

    local function call_back()
        self.score_num.text = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.STScore)
    end
    self.roledata_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.STScore, call_back)

    self.update_rd_event_id = self.model:AddListener(SearchTreasureEvent.UpdateSideRD, handler(self, self.HandleSideRDUpdate))

    --三个寻宝按钮
    local function call_back(target, x, y)
        self:RequestSearch2(1)
    end
    AddClickEvent(self.btnbuy.gameObject, call_back)

    local function call_back(target, x, y)
        self:RequestSearch2(10)
    end
    AddClickEvent(self.btnbuyten.gameObject, call_back)

    local function call_back(target, x, y)
        self:RequestSearch2(50)
    end
    AddClickEvent(self.btnbuyfifty.gameObject, call_back)

    --全服记录按钮
    local function call_back(target, value)
        if value then
            local messages = self.model:GetMessages(self.type_id, 1)
            if not messages then
                SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 1)
            else
                SetVisible(self.ScrollView, false)
                SetVisible(self.ScrollView2, true)
                self:UpdateMessages(self.msg_list2, self.MsgContent2, messages)
            end
            self.TextAll.text = string.format("<color=#7D8AB6>%s</color>", "Server Record")
            self.TextMy.text = string.format("<color=#FFFFFF>%s</color>", "Personal Record")
        end
    end
    AddValueChange(self.searchrecord.gameObject, call_back)

    --个人记录按钮
    local function call_back(target, value)
        if value then
            local messages = self.model:GetMessages(self.type_id, 0)
            if not messages then
                SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 0)
            else
                SetVisible(self.ScrollView, true)
                SetVisible(self.ScrollView2, false)
                self:UpdateMessages(self.msg_list, self.MsgContent, messages)
            end
            self.TextMy.text = string.format("<color=#7D8AB6>%s</color>", "Personal Record")
            self.TextAll.text = string.format("<color=#FFFFFF>%s</color>", "Server Record")
        end
    end
    AddValueChange(self.myrecord.gameObject, call_back)

    --寻宝仓库按钮
    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(STStoragePanel):Open()
    end
    AddClickEvent(self.storagebtn.gameObject, call_back)

    --问号按钮（游戏说明）
    local function call_back(target, x, y)
        ShowHelpTip(HelpConfig.SearchT.search)
    end
    AddClickEvent(self.tipsbtn.gameObject, call_back)

    --感叹号按钮（概率详情）
    local function call_back(target, x, y)
        local proba_id = 1
        if self.type_id == 2 then
            proba_id = 10
        elseif self.type_id == 3 then
            proba_id = 13
        elseif self.type_id == 4 then
            proba_id = 14
        end
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(proba_id)
    end
    AddClickEvent(self.probbtn.gameObject, call_back)
end

function SearchTreasurePanel:HandleSideRDUpdate(type_id, is_show)
    self:SetIndexRedDotParam(type_id, is_show)
end

function SearchTreasurePanel:OpenCallBack()
    self:ShowRedDot()
    self:ShowStorageRedDot()
end

function SearchTreasurePanel:UpdateView()

    local info = self.model:GetInfo(self.type_id)

    if info.batch_id then

        local batch_id = info.batch_id

        local batch = Config.db_searchtreasure_batch[batch_id]

        self.model.batch_id = batch_id

        local rewards = self.model:GetRewardIds(self.type_id, batch_id)
        local rare_rewards = self.model:GetRareRewardIds(self.type_id, batch_id)

        local icon1 = self.icon1
        local icon2 = self.icon2
        local icon3 = self.icon3
        local index1 = 1;
        local index2 = 2;
        local index3 = 3;



        --三件珍稀物品
        self.item_list2[index1] = self:AddReward(icon1, rare_rewards[1], self.item_list2[index1], nil, nil, true)
        self.item_list2[index2] = self:AddReward(icon2, rare_rewards[2], self.item_list2[index2], { x = 100, y = 100 }, nil, true)
        self.item_list2[index3] = self:AddReward(icon3, rare_rewards[3], self.item_list2[index3], nil, nil, true)

        for i = 1, #rewards do
            local item = self:AddReward(self.Content, rewards[i], self.item_list[i])
            self.item_list[i] = item
        end

        --多出来的销毁掉
        if #self.item_list > #rewards then
            for i = #self.item_list, #rewards + 1, -1 do
                self.item_list[i]:destroy()
                self.item_list[i] = nil
            end
        end

        self:SortScroll()

        --显示消耗
        local cost = String2Table(batch.cost)
        self.gold.text = string.format(ConfigLanguage.SearchT.GoldNum, cost[1][3])
        self.gold10.text = string.format(ConfigLanguage.SearchT.GoldNum, cost[2][3])
        self.gold50.text = string.format(ConfigLanguage.SearchT.GoldNum, cost[3][3])

        local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
        --if viplv >= 5 then
        --	lua_resMgr:SetImageTexture(self,self.tips,"search_treasure_image","v5tips")
        --elseif viplv == 4 then
        --	lua_resMgr:SetImageTexture(self,self.tips,"search_treasure_image","v4tips")
        --else
        lua_resMgr:SetImageTexture(self, self.tips, "search_treasure_image", "viptips")
        --end



        --祝福值
        local max_value = batch.max_bless_value
        local bless_value = info.bless_value
        self.bless_scrolbar.size = bless_value / max_value
        if info.show_add == 1 and bless_value > 0 then
            ShiftWord(self.bless_scrolbar.transform, "top", '+' .. bless_value)
        end
        SetVisible(self.first_turn, info.turn == 1)
        self.bless_value.text = string.format(ConfigLanguage.Common.TwoNum, bless_value, max_value)

        --寻宝记录
        local is_global = 0
        if self.searchrecord.isOn then
            is_global = 1
        end
        local messages = self.model:GetMessages(self.type_id, is_global)
        if not messages then
            SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 0)
        end

    end

    --这里需要根据寻宝类型替换下icon
    local icon
    local is_show_gundam_tips = false

    if self.type_id == 1 then
        icon = Config.db_item[self.model.gold_key_id].icon
        SetVisible(self.tips_content3, true)
    elseif self.type_id == 2 then
        icon = Config.db_item[self.model.silver_key_id].icon
        SetVisible(self.tips_content3, false)
    elseif self.type_id == 3 then
        icon = Config.db_item[self.model.gundam_key_id].icon
        SetVisible(self.tips_content3, false)
        is_show_gundam_tips = true
    elseif self.type_id == 4 then
        icon = Config.db_item[self.model.supermecy_key_id].icon
        SetVisible(self.tips_content3, false)
    end
    SetVisible(self.tips_content4, is_show_gundam_tips)
    SetVisible(self.tips_content2, not is_show_gundam_tips)

    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi, icon, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi2, icon, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.zuanshi3, icon, true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.goods_icon, icon, true)

    self.score_num.text = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.STScore)
end

function SearchTreasurePanel:CloseCallBack()
    if self.update_rd_event_id then
        self.model:RemoveListener(self.update_rd_event_id)
        self.update_rd_event_id = nil
    end
    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id)
    end
    if self.schedule_id2 then
        GlobalSchedule:Stop(self.schedule_id2)
    end
    self.model:ClearInfo()
    if self.event_id then
        self.model:RemoveListener(self.event_id)
    end
    if self.event_id2 then
        self.model:RemoveListener(self.event_id2)
    end
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end

    for i = 1, #self.msg_list do
        self.msg_list[i]:destroy()
    end
    for i = 1, #self.msg_list2 do
        self.msg_list2[i]:destroy()
    end

    for i = 1, #self.global_events do
        GlobalEvent:RemoveListener(self.global_events[i])
    end

    RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.roledata_event)

    if self.storage_reddot then
        self.storage_reddot:destroy()
        self.storage_reddot = nil
    end
    if self.reddot_1 then
        self.reddot_1:destroy()
        self.reddot_1 = nil
    end
    if self.reddot_2 then
        self.reddot_2:destroy()
        self.reddot_2 = nil
    end
    if self.reddot_3 then
        self.reddot_3:destroy()
        self.reddot_3 = nil
    end
end

function SearchTreasurePanel:SwitchCallBack(index)

    if self.table_index == index then
        return
    end
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.table_index = index

    --if self.table_index == 1 then
    -- if not self.show_panel then
    -- 	self.show_panel = ChildPanel(self.transform)
    -- end
    -- self:PopUpChild(self.show_panel)
    --end

    if index >= 1 and index <= 4 then

        --显示寻宝面板

        self:SetSTVisible(true)

        --切换寻宝类型
        self:ChangeSTType(index);

    else
        --隐藏寻宝面板 打开积分商城面板

        self:SetSTVisible(false)

        if not self.ScoreShop then
            self.ScoreShop = ScoreShopPanel(self.child_transform, "UI")
        end

        self:PopUpChild(self.ScoreShop)

        self:SetTitleImgPos(-340, 275)
    end


end

--添加奖励（根据奖励数据创建对应UI）
function SearchTreasurePanel:AddReward(p_node, reward_id, old_item, size, name, has_effect)
    local rewarditem = Config.db_searchtreasure_rewards[reward_id]
    local rewards = String2Table(rewarditem.rewards)
    local item_id = rewards[1]
    local num = rewards[2]
    local bind = rewards[3] or 1

    local param = {}
    param["model"] = self.model
    param["item_id"] = item_id
    param["size"] = size
    param["num"] = num
    param["bind"] = bind
    param["can_click"] = true
    if has_effect then
        param["effect_type"] = 2
        param["color_effect"] = enum.COLOR.COLOR_PURPLE
    end
    local goods = old_item or GoodsIconSettorTwo(p_node)
    goods:SetIcon(param)
    if name then
        name.text = Config.db_item[item_id].name
    end
    return goods
end

--更新寻宝记录
function SearchTreasurePanel:UpdateMessages(msg_list, parent_node, messages)

    messages = messages or {}

    for i = 1, #messages do
        local item = msg_list[i] or STMessageItem(parent_node)
        item:SetData(messages[i], self.type_id)
        msg_list[i] = item
    end

    if #msg_list > #messages then
        for i = #msg_list, #messages + 1, -1 do
            msg_list[i]:destroy()
            msg_list[i] = nil
        end
    end
end

--排序奖励列表的UI位置
function SearchTreasurePanel:SortScroll()
    local function update_func()
        local c_item, p_item
        for i = 1, #self.item_list do
            c_item = self.item_list[i]
            if i == 1 then
                c_item.transform.anchoredPosition = Vector2(-250, 0)
            else
                p_item = self.item_list[i - 1]
                c_item.transform.anchoredPosition = Vector2(p_item.transform.anchoredPosition.x + 84, 0)
            end
        end
    end
    self.schedule_id2 = GlobalSchedule:StartOnce(update_func, 0)
end

--奖励列表自动循环滚动
function SearchTreasurePanel:AutoScroll()
    if self.schedule_id then
        return
    end
    local function update_func()
        local last_item = self.item_list[#self.item_list]
        if not last_item.transform then
            return
        end
        --所有奖励物品左移
        for i = 1, #self.item_list do
            local item = self.item_list[i]
            item.transform.anchoredPosition = Vector2(item.transform.anchoredPosition.x - 1, item.transform.anchoredPosition.y)
        end
        --最左边的奖励物品超出边界 移动到table末尾 并修改位置到最右边
        if self.item_list[1].transform.anchoredPosition.x <= -300 then
            local item = table.remove(self.item_list, 1)
            item.transform.anchoredPosition = Vector2(self.item_list[#self.item_list].transform.anchoredPosition.x + 84, item.transform.anchoredPosition.y)
            table.insert(self.item_list, item)
        end
    end
    self.schedule_id = GlobalSchedule:Start(update_func, 0.02)
end

function SearchTreasurePanel:ReLayout()
    local w = #self.item_list * 84
    self.Content.sizeDelta = Vector2(w, 76.5)

    self.Content.anchoredPosition = Vector2(0, 0)
end

--显示三个寻宝按钮上的红点（根据钥匙数量判断）
function SearchTreasurePanel:ShowRedDot(specified_id)
    local tar_id = specified_id or self.type_id
    local num

    local target_id
    if tar_id == 1 then
        target_id = self.model.gold_key_id
    elseif tar_id == 2 then
        target_id = self.model.silver_key_id
    elseif tar_id == 3 then
        target_id = self.model.gundam_key_id
    elseif tar_id == 4 then
        target_id = self.model.supermecy_key_id
    end
    num = BagModel:GetInstance():GetItemNumByItemID(target_id)

    self.goods_num.text = num
    self.reddot_1 = self.reddot_1 or RedDot(self.btnbuy.transform)
    SetLocalPosition(self.reddot_1.transform, 75, 14)
    self.reddot_2 = self.reddot_2 or RedDot(self.btnbuyten.transform)
    SetLocalPosition(self.reddot_2.transform, 75, 14)
    self.reddot_3 = self.reddot_3 or RedDot(self.btnbuyfifty.transform)
    SetLocalPosition(self.reddot_3.transform, 75, 14)
    SetVisible(self.reddot_1, num >= 1)
    SetVisible(self.reddot_2, num >= 10)
    SetVisible(self.reddot_3, num >= 45)
    self:SetIndexRedDotParam(tar_id, num >= 1)
end

function SearchTreasurePanel:ShowStorageRedDot()
    local bag = BagModel:GetInstance():GetBag(BagModel.stHouseId) or {}
    local storage_num = 0
    local items = bag.bagItems or {}
    for k, v in pairs(items) do
        if v ~= 0 then
            storage_num = storage_num + 1
        end
    end
    if not self.storage_reddot then
        self.storage_reddot = RedDot(self.storagebtn.transform)
        SetLocalPosition(self.storage_reddot.transform, 75, 14)
    end
    if storage_num > 0 then
        SetVisible(self.storage_reddot, true)
    else
        SetVisible(self.storage_reddot, false)
    end
end

--切换寻宝类型
function SearchTreasurePanel:ChangeSTType(newTypeId)
    self.type_id = newTypeId

    SearchTreasureController:GetInstance():RequestGetInfo(self.type_id)
    SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 1)

    self:ShowRedDot()

    --根据寻宝类型切换UI
    local isST1 = newTypeId == 1
    local isST2 = newTypeId == 2
    local issST3 = newTypeId == 3
    local issST4 = newTypeId == 4
    SetVisible(self.content_bg, isST1 or issST4)
    SetVisible(self.content_bg2, isST2)
    SetVisible(self.content_bg3, issST3)

    local nor_pos = { -315.15, 275 }
    local gundam_pos = { -361, 286 }
    local tbl = issST3 and gundam_pos or nor_pos
    self:SetTitleImgPos(tbl[1], tbl[2])
end

--设置寻宝界面的显示
function SearchTreasurePanel:SetSTVisible(visible)
    SetVisible(self.bg, visible)
    SetVisible(self.record, visible)
    SetVisible(self.right, visible)
end
