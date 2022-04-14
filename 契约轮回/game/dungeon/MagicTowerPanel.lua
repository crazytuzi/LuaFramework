--
-- @Author: LaoY
-- @Date:   2018-12-08 17:18:50
--
MagicTowerPanel = MagicTowerPanel or class("MagicTowerPanel", BaseItem)
local MagicTowerPanel = MagicTowerPanel

function MagicTowerPanel:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.assetName = "MagicTowerPanel"
    self.layer = layer

    self.model = DungeonModel:GetInstance()
    self.global_event_list = {}
    MagicTowerPanel.super.Load(self)

    self.item_list = {}
    self.next_reward_list = {}

    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER
    DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type)
    DungeonCtrl:GetInstance():RequestLotoInfo(self.dungeon_type)
    -- DungeonCtrl:GetInstance():RequestLotoInfo(self.dungeon_type)
end

function MagicTowerPanel:dctor()
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}

    for k, item in pairs(self.next_reward_list) do
        destroy(item.gameObject)
    end
    self.next_reward_list = {}

    if self.magic_card_item then
        self.magic_card_item:destroy()
        self.magic_card_item = nil
    end

    if self.btn_reward_reddot then
        self.btn_reward_reddot:destroy()
        self.btn_reward_reddot = nil
    end

    if self.tuantable_reddot then
        self.tuantable_reddot:destroy()
        self.tuantable_reddot = nil
    end
end

function MagicTowerPanel:LoadCallBack()
    self.nodes = {
        "text_cur_floor", "img_title_bg/text_title", "btn_reward", "btn_turn_table", "scroll/Viewport/Content",
        "text_tip", "img_bg_1", "scroll", "img_bg_2/img_magic_tower_pos_bg_1", "btn_go", "img_bg_2/con_card",
        "img_title_bg_1/text_next_reward", "img_have_clear_1", "img_have_clear_2", "power/powerTex",
        "power/Image1","power/Image2",
    }
    self:GetChildren(self.nodes)

    self.img_bg_1_component = self.img_bg_1:GetComponent('Image')
    self.text_cur_floor_component = self.text_cur_floor:GetComponent('Text')
    self.text_tip_component = self.text_tip:GetComponent('Text')
    self.text_title_component = self.text_title:GetComponent('Text')
    self.text_next_reward_component = self.text_next_reward:GetComponent('Text')

    self.btn_go_component = self.btn_go:GetComponent('Image')
    self.powerTex = GetText(self.powerTex)

    local res = "magic_tower_dungeon_bg"
    lua_resMgr:SetImageTexture(self, self.img_bg_1_component, "iconasset/icon_big_bg_" .. res, res, true)

    self.img_magic_tower_pos_bg_1_x = GetLocalPositionX(self.img_magic_tower_pos_bg_1)
    self.con_card_x = GetLocalPositionX(self.con_card)

    self.magic_card_item = MagicCardItem(self.con_card)
    self.magic_card_item:SetSiblingIndex(0)
    self.magic_card_item:SetScale(0.75)

    self.btn_reward_reddot = RedDot(self.btn_reward.transform, nil, RedDot.RedDotType.Nor)
    self.btn_reward_reddot:SetPosition(30, 28)
    --self.btn_reward_reddot:SetRedDotParam(true)
    self.tuantable_reddot = RedDot(self.btn_turn_table.transform, nil, RedDot.RedDotType.Nor)
    self.tuantable_reddot:SetPosition(30, 25)
    --self.tuantable_reddot:SetRedDotParam(true)

    self:UpdateReddot();
    -- SetLocalScale(self.con_card,0.75,0.75,0.75)

    -- 	local tip_str = [[
    -- 温馨提示：
    -- 1.每天<color=#6ce19b>0</color>点可领取3个铭文精华宝箱
    -- 2.每通关<color=#6ce19b>5</color>层可获得一次幸运转盘次数
    -- ]]
    local tip_str = [[
Reminder:
1. At 00:00 you can claim 3 seal essence chests
2. Each time you clear 5 stages, you will earn a free lucky wheel attempt
]]
    self.text_tip_component.text = tip_str

    self:AddEvent()
    self:SetData()

    local len = 3;--#list < 3 and 3 or #list
    SetSizeDeltaX(self.Content, 84 * len)
end

function MagicTowerPanel:AddEvent()

    AddEventListenerInTab(DungeonEvent.UpdateReddot , handler(self,self.UpdateReddot) , self.global_event_list);
    local function call_back(target, x, y)
        -- Notify.ShowText("转盘")
        lua_panelMgr:OpenPanel(MagicTowerTurnTablePanel, self.dungeon_type)
    end
    AddClickEvent(self.btn_turn_table.gameObject, call_back)

    local function call_back(target, x, y)
        if not self.data or not self.data.info then
            return
        end
        if self.data.info.cur_floor <= 1 then
            Notify.ShowText("You need to clear Magic Tower F1 first")
            return
        end
        if self.data.info.daily_gift == 1 then
            Notify.ShowText("Today's rewards have been claimed")
            return
        end
        DungeonCtrl:GetInstance():RequestFetch(self.dungeon_type, 1)
    end
    AddClickEvent(self.btn_reward.gameObject, call_back)

    local function call_back(target, x, y)
        if not self.data then
            return
        end

        if Config.db_game["dunge_magic"] and Config.db_game["dunge_magic"].val then
            local tab = String2Table(Config.db_game["dunge_magic"].val)
            if tab and tab[1] and self.data.info.cur_floor > tonumber(tab[1]) then
                return
            end
        end
        local dungeConfig = self.dungeConfig
        local role = RoleInfoModel.GetInstance():GetMainRoleData()
        if role.level >= dungeConfig.level then
            DungeonCtrl:GetInstance():RequestEnterDungeon(self.dungeon_type, self.data.info.cur_floor)
        else
            local str = string.format("To challenge Tower of Judgment <color=#3ab60e>%d stage</color> needs <color=#e63232>%d LvL</color>", self.data.info.cur_floor, dungeConfig.level)
            Notify.ShowText(str)
        end
    end
    AddClickEvent(self.btn_go.gameObject, call_back)

    local function call_back(dungeon_type, data)
        if dungeon_type == self.dungeon_type then
            -- self:UpdateData(data)
            self:SetData()
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    local function call_back(dungeon_type)
        if dungeon_type == self.dungeon_type then
            self:UpdateReddot();
        end
    end
    self.model_event_list = self.model_event_list or {}
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(DungeonEvent.FetchResult, call_back)

    local function call_back(dungeon_type)
        if dungeon_type == self.dungeon_type then
            self:UpdateReddot();
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(DungeonEvent.LotoInfoUpdate, call_back)
end

function MagicTowerPanel:InitUI()

end

function MagicTowerPanel:SetData()
    if not self.is_loaded then
        return
    end
    local data = self.model.dungeon_info_list[self.dungeon_type]
    if not data then
        return
    end
    self.data = data
    local floor_str = ""
    local last_config = Config.db_dunge_magic[data.info.cur_floor - 1]

    local show_pass_floor = data.info.cur_floor
    if not Config.db_dunge_magic[data.info.cur_floor] then
        show_pass_floor = #Config.db_dunge_magic
        SetGray(self.btn_go_component, true)
    else
        SetGray(self.btn_go_component, false)
    end
    if Config.db_dunge_magic[show_pass_floor + 1] then
        floor_str = floor_str .. string.format("F%s\n", show_pass_floor + 1)
    else
        floor_str = floor_str .. "\n"
    end
    floor_str = floor_str .. string.format("F%s\n", show_pass_floor)

    if Config.db_dunge_magic[show_pass_floor - 1] then
        floor_str = floor_str .. string.format("F%s", show_pass_floor - 1)
    end
    self.text_cur_floor_component.text = floor_str

    local show_floor = self.data.clear and #Config.db_dunge_magic or data.info.cur_floor
    SetVisible(self.img_have_clear_1, self.data.clear)

    local title_str = string.format("F%s Cleared Reward", show_floor)
    self.text_title_component.text = title_str

    local config = Config.db_dunge_magic[show_floor]
    if not config then
        return
    end
    


    -----推荐战力
    local dungeID = config.dunge
    local dungeConfig = Config.db_dunge[dungeID]
    self.dungeConfig = dungeConfig
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    if role.level >= dungeConfig.level then
        SetVisible(self.Image1, true)
        SetVisible(self.Image2, false)
        local color = ""
        if role.power > dungeConfig.power then
            color = "43f673"
        else
            color = "e63232"
        end
        self.powerTex.text = string.format("<color=#%s>%s</color>", color, dungeConfig.power)
    else
        SetVisible(self.Image1, false)
        SetVisible(self.Image2, true)
        self.powerTex.text = string.format("Lv.<color=#e63232>%s</color>", dungeConfig.level)
    end


    -- SetLocalPositionX(self.Content,0)
    -- SetAnchoredPosition(self.Content, 0,0)

    -- 策划奖励换表了 
    -- local list = String2Table(config.gift) or {}
    local list = String2Table(dungeConfig.reward_show) or {}
    -- list[#list+1] = list[1]
    -- list[#list+1] = list[1]
    -- list[#list+1] = list[1]
    -- list[#list+1] = list[1]
    destroyTab(self.item_list);
    self.item_list = {};
    for i = 1, #list do
        local item = self.item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.Content)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local cf = list[i];
        local param = {}
        param["item_id"] = cf[1];
        param["can_click"] = true;
        param["num"] = cf[2];
        param["size"] = { x = 80, y = 80 }
        item:SetIcon(param);
        --item:UpdateIconByItemIdClick(cf[1], cf[2])--itemid , num
    end

    for i = #list + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end

    local next_reward_id = self:GetNextRewardFloor()
    if not next_reward_id then
        return
    end
    SetVisible(self.img_have_clear_2, self.data.clear or next_reward_id < data.info.cur_floor)

    -- next_reward_id = 15
    local next_cf = Config.db_dunge_magic[next_reward_id]
    local reward_info = String2Table(next_cf.extra_gift)
    local next_str = string.format("F%s Cleared Reward", next_reward_id)
    self.text_next_reward_component.text = next_str
    local reward_type_str = ""
    local reward_img_res = {}
    local len = #reward_info
    for i = 1, #reward_info do
        local info = reward_info[i]
        if info[1] == "pos" then
            SetVisible(self.img_magic_tower_pos_bg_1, true)
            -- setdata
            if len == 1 then
                SetVisible(self.con_card, false)
                SetLocalPositionX(self.img_magic_tower_pos_bg_1, 0)
            else
                SetLocalPositionX(self.img_magic_tower_pos_bg_1, self.img_magic_tower_pos_bg_1_x)
            end
        elseif info[1] == "card" then
            SetVisible(self.con_card, true)
            -- setdata
            local cf = Config.db_magic_card[info[2]]
            self.magic_card_item:UpdateData(cf)
            if len == 1 then
                SetVisible(self.img_magic_tower_pos_bg_1, false)
                SetLocalPositionX(self.con_card, 0)
            else
                SetLocalPositionX(self.con_card, self.con_card_x)
            end
        end
    end
end

function MagicTowerPanel:GetNextRewardFloor()
    if not self.data then
        return nil
    end

    local id = self.data.info.cur_floor
    local len = #Config.db_dunge_magic
    for i = id, len do
        local cf = Config.db_dunge_magic[i]
        if #string.trim(cf.extra_gift) > 2 then
            return i
        end
    end

    -- 如果没找到下一个，就把配置表最后一个显示出来
    for i = len, 1, -1 do
        local cf = Config.db_dunge_magic[i]
        if #string.trim(cf.extra_gift) > 2 then
            return i
        end
    end

    return nil
end

function MagicTowerPanel:UpdateReddot()
    local data = self.model.dungeon_info_list[self.dungeon_type];
    if not data then
        self.tuantable_reddot:SetRedDotParam(false);
        return
    end
    if data.info.daily_gift == 1 or data.info.cur_floor <= 1 then
        self.btn_reward_reddot:SetRedDotParam(false);
    else
        self.btn_reward_reddot:SetRedDotParam(true);
    end
    local info = data.info;
    if info and info.loto_times > 0 then
        self.tuantable_reddot:SetRedDotParam(true);
    else
        self.tuantable_reddot:SetRedDotParam(false);
    end

end