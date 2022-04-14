-- @Author: lwj
-- @Date:   2019-02-12 15:53:17
-- @Last Modified time: 2019-02-12 15:53:19

WeeklyPanelItem = WeeklyPanelItem or class("WeeklyPanelItem", BaseCloneItem)
local WeeklyPanelItem = WeeklyPanelItem

function WeeklyPanelItem:ctor(parent_node, layer)
    WeeklyPanelItem.super.Load(self)

    self.reward_items = {}
    self.isCanFetch = false
end

function WeeklyPanelItem:dctor()
    for i, v in pairs(self.reward_items) do
        if v then
            v:destroy()
        end
    end
    self.reward_items = {}
end

function WeeklyPanelItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "btn_go", "btn_go/btn_text", "Scroll/Viewport/rewardContent", "flag", "name", "times", "des", "icon",
        "rewarded_img", "lock", "lock/limit", "bg",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.flag = GetImage(self.flag)
    self.name = GetText(self.name)
    self.times = GetText(self.times)
    self.des = GetText(self.des)
    self.btn_text = GetText(self.btn_text)
    self.btn_rect = GetRectTransform(self.btn_go)
    self.limit = GetText(self.limit)
    self:AddEvent()
end

function WeeklyPanelItem:AddEvent()

    local function call_back()
        if self.isCanFetch then
            self.model:Brocast(DailyEvent.RequestGetWeekTaskReward, self.data.conData.id)
            self.model.cur_btn_anchored_pos = { x = self.btn_rect.position.x, y = self.btn_rect.position.y - 30 }
        else
            local type = self.data.conData.link_type
            if type == 1 then
                --任务
                if self.data.conData.link then
                    local link_id = tonumber(String2Table(self.data.conData.link)[1])
                    if link_id == 930000 then
                        if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                            Notify.ShowText("Please join the guild first")
                            return
                        end
                    end
                    TaskModel.GetInstance():DoTask(link_id)
                end
            elseif type == 2 then
                if self.hookData then
                    SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.id)
                end
            elseif type == 3 then
                --界面跳转
                if self.data.conData.link ~= "" then
                    local pTab = String2Table(self.data.conData.link)
                    OpenLink(unpack(pTab[1]))
                end
            elseif type == 4 then
                --挂机
                if self.hookData then
                    SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.id)
                end
            end
        end
    end
    AddButtonEvent(self.btn_go.gameObject, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ActivityTips):Open(self.data.conData.id, self.bg.transform)
    end
    AddClickEvent(self.bg.gameObject, call_back)
end

function WeeklyPanelItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function WeeklyPanelItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", tostring(self.data.conData.pic), true, nil, false)
    lua_resMgr:SetImageTexture(self, self.flag, "iconasset/icon_daily", self.data.conData.tips, true, nil, false)
    self.name.text = self.data.conData.name
    self.des.text = self.data.conData.desc
    local restTimes = self.data.conData.count
    local isRewarded = false
    local is_can_show_btn = false
    if self.data.serData then
        restTimes = self.data.conData.count - self.data.serData.progress
        if restTimes <= 0 then
            restTimes = 0
            self.isCanFetch = true
        end
        if self.data.serData.rewarded then
            isRewarded = true
            SetVisible(self.btn_go, false)
            SetVisible(self.rewarded_img, true)
        end
    end
    if not isRewarded then
        is_can_show_btn = true
        SetVisible(self.btn_go, true)
        SetVisible(self.rewarded_img, false)
    end
    self.times.text = "（" .. restTimes .. "/" .. self.data.conData.count .. "）"
    local rewardTbl = String2Table(self.data.conData.reward)
    for i = 1, #rewardTbl do
        local cfg = Config.db_item[rewardTbl[i][1]]
        if cfg then
            local param = {}
            local operate_param = {}
            param["cfg"] = cfg
            param["model"] = self.model
            param["can_click"] = true
            param["operate_param"] = operate_param
            param["size"] = { x = 60, y = 60 }
            param["num"] = rewardTbl[i][2]
            local goodsItem = GoodsIconSettorTwo(self.rewardContent)
            goodsItem:SetIcon(param)
            self.reward_items[#self.reward_items + 1] = goodsItem
        end
    end
    if self.isCanFetch and self.data.conData.name ~= "Soul Card Realm" then
        self.btn_text.text = "Claim"
    end
    if self.data.isLock then
        SetVisible(self.btn_go, false)
        SetVisible(self.times, false)
        SetVisible(self.lock, true)
        self.limit.text = string.format("Unlock\nat Lv.%s", tostring(String2Table(self.data.conData.reqs)[1][2]))
    elseif is_can_show_btn then
        SetVisible(self.btn_go, true)
        SetVisible(self.times, true)
        SetVisible(self.lock, false)
    end
end


