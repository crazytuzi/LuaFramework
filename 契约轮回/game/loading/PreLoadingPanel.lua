--
-- @Author: LaoY
-- @Date:   2019-08-23 15:15:56
-- 预加载loading
PreLoadingPanel = PreLoadingPanel or class("PreLoadingPanel", BasePanel)

function PreLoadingPanel:ctor()
    self.abName = "loading"
    self.image_ab = "loading_image";
    self.assetName = "LoadingPanel"
    self.layer = "Max"

    self.use_background = false
    self.change_scene_close = false

    self.pre_load_count = 0
    self.pre_load_all_count = 1
    self.pre_object_count = 0
    self.pre_object_count_all_count = 0

    self.have_down_load_size = 0
    self.need_down_load_size = 0
    self.last_have_down_load_size = 0
    self.last_show_down_load_size = 0

    self.global_event_list = {}
end

function PreLoadingPanel:dctor()
    self:StopCheckTime()
    self.last_action = nil
    self.number_action = nil
    self:RemoveAction()
    self:StopTime()

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end
end

function PreLoadingPanel:Open()
    PreLoadingPanel.super.Open(self)
end

function PreLoadingPanel:LoadCallBack()
    self.nodes = {
        "bg", "desText", "Text", "progress", "progress/progress_bar", "loadingText",
        "progress/light",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()

    if CtrlManager.IsInit then
        self:InitProgress()
    end

    self:InitUI()
end

function PreLoadingPanel.GetLoadingImageDecText(level)
    level = level or 1
    local config
    for k, v in pairs(Config.db_loading) do
        if v.loading_type == 2 then
            local levelTab = String2Table(v.lv)
            if level >= levelTab[1] and level <= levelTab[1] then
                config = v
                break
            end
        end
    end
    local dec_cf = Config.db_loading_text[1]
    if not config then
        return "10000", dec_cf.dec
    end
    local randomTab = String2Table(config.image)
    local allWeight = 0
    local index = 0
    local len = #randomTab
    for i = 1, len do
        local cf = randomTab[i]
        allWeight = cf[1] + allWeight
    end
    local num = math.random(allWeight)
    for i = 1, len do
        local cf = randomTab[i]
        if num >= index and num <= index + cf[1] then
            if Config.db_loading_text[cf[3]] then
                dec_cf = Config.db_loading_text[cf[3]]
            end
            return cf[2], dec_cf.dec
        end
        index = index + cf[1]
    end
    return "10000", dec_cf.dec
end

function PreLoadingPanel:InitUI()
    self.bg = GetImage(self.bg)
    SetGameObjectActive(self.bg)
    self.desText = GetText(self.desText)
    self.Text = GetText(self.Text)
    self.progress_bar = GetImage(self.progress_bar)
    self.loadingText = GetText(self.loadingText)
    self.Text.text = "Entering game"

    self.lightx, self.lighty, self.lightz = GetLocalPosition(self.light)

    self.progress_bar.fillAmount = 0
    self.loadingText.text = string.format("%d/100", 0)

    local img, dec = PreLoadingPanel.GetLoadingImageDecText(level)
    self.desText.text = dec
    SetVisible(self.desText, false)

    local function callBack(sprite)
        if self.is_dctored then
            return
        end
        self.bg.sprite = sprite

        -- GlobalEvent:Brocast(EventName.HotUpdateSuccess)
        local go = find("layer/Top/updateview")
        if go then
            destroy(go)
        end
        -- self:Close()
    end
    lua_resMgr:SetImageTexture(self, self.bg, self.image_ab, "preloading_" .. tostring(img), false, callBack, true, Constant.LoadResLevel.Urgent);
end

function PreLoadingPanel:InitProgress()
    local PreloadMgr = PreloadManager:GetInstance()
    self.pre_object_count = PreloadMgr.preload_scene_object_load_count or 0
    self.pre_object_count_all_count = PreloadMgr.preload_scene_object_count or 0

    local pre_load_all_count = PreloadMgr.load_list and #PreloadMgr.load_list or 1
    self.pre_load_count = PreloadMgr.load_count or 0
    self.pre_load_all_count = pre_load_all_count
end

function PreLoadingPanel:AddEvent()
    local function call_back(pre_object_count, pre_object_count_all_count,need_down_load_size,have_down_load_size)
        self.pre_object_count = pre_object_count
        self.pre_object_count_all_count = pre_object_count_all_count
        self.need_down_load_size = need_down_load_size or self.need_down_load_size

        self.last_have_down_load_size = self.have_down_load_size
        self.have_down_load_size = have_down_load_size or self.have_down_load_size
        if self.last_have_down_load_size ~= self.have_down_load_size then
            self.last_update_view_time = Time.time
        end
        self:StartprogressTime()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.PreLoadObject, call_back)

    local function call_back(value, pre_load_count, pre_load_all_count)
        self.pre_load_count = pre_load_count
        self.pre_load_all_count = pre_load_all_count
        self:StartprogressTime()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.LoadComponent, call_back)
end

local show_down_load_progress_size = 1024 * 2.0
local add_progress = 0.012
function PreLoadingPanel:OpenCallBack()
    -- if not self.need_down_load_size or self.need_down_load_size <= show_down_load_progress_size then
    -- end
    self:StartTime()
    self:StartCheckTime()
end

function PreLoadingPanel:StartCheckTime()
    local function step()
        local load_count = self.pre_load_count + self.pre_object_count
        local all_count = self.pre_load_all_count + self.pre_object_count_all_count
        if load_count ~= 0 and load_count >= all_count then
            self:StopCheckTime()
            return
        end
        if self.last_update_view_time and Time.time - self.last_update_view_time > 0.8 then
            if self.need_down_load_size > show_down_load_progress_size and self.last_have_down_load_size == self.have_down_load_size and self.last_show_down_load_size < self.need_down_load_size then
                self:StopTime()
                self.last_show_down_load_size = self.last_show_down_load_size + self.need_down_load_size * add_progress
                if self.last_show_down_load_size >= self.need_down_load_size then
                    self.last_show_down_load_size = self.need_down_load_size
                end
                local str = string.format("Download latest resources: %s/%s kb",self.last_show_down_load_size * 1.5,self.need_down_load_size * 1.5)
                self.Text.text = str
                self:UpdateView()
            end
        end
    end
    self.check_time_id = GlobalSchedule:Start(step,1.0)
    -- step()
end

function PreLoadingPanel:StopCheckTime()
    if self.check_time_id then
        GlobalSchedule:Stop(self.check_time_id)
        self.check_time_id = nil
    end
end

function PreLoadingPanel:StartprogressTime()
    if self.preo_gress_time_id then
        return
    end
        
    local function step()
        if self.need_down_load_size and self.need_down_load_size > show_down_load_progress_size then
            self.last_update_view_time = Time.time
            self:StopTime()
            local cur_have_down_load_size = self.have_down_load_size
            if self.have_down_load_size > self.last_show_down_load_size then
                self.last_show_down_load_size = self.have_down_load_size
            else
                self.last_show_down_load_size = self.last_show_down_load_size + self.need_down_load_size * add_progress
            end
            if self.last_show_down_load_size >= self.need_down_load_size then
                self.last_show_down_load_size = self.need_down_load_size
            end
            local cur_have_down_load_size = self.last_show_down_load_size
            local str
            if cur_have_down_load_size >= self.need_down_load_size then
                str = "Initializing"
            else
                str = string.format("Download latest resources: %s/%s kb",cur_have_down_load_size * 1.5,self.need_down_load_size * 1.5)
            end
            self.Text.text = str
        end

        self:UpdateView()
        if self.preo_gress_time_id then
            GlobalSchedule:Stop(self.preo_gress_time_id)
            self.preo_gress_time_id = nil
        end
    end
    self.preo_gress_time_id = GlobalSchedule:StartOnce(step, 1.0)
end

local space_count = 0
function PreLoadingPanel:StartTime()
    self:StopTime()
    local str = ""
    local function step()
        str = ""
        for i = 1, space_count do
            str = str .. "."
        end
        self.Text.text = "Entering game" .. str
        space_count = space_count + 1
        if space_count > 3 then
            space_count = 0
        end
    end
    self.time_id = GlobalSchedule:Start(step, 0.2)
end

function PreLoadingPanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = 0
    end
end

local allTime = 2.0
function PreLoadingPanel:UpdateView()
    local load_count = self.pre_load_count + self.pre_object_count
    local all_count = self.pre_load_all_count + self.pre_object_count_all_count

    local load_count_1 = self.pre_load_count + self.pre_object_count
    local all_count_1 = self.pre_load_all_count + self.pre_object_count_all_count
    if self.need_down_load_size and self.need_down_load_size > show_down_load_progress_size then
        -- load_count = self.have_down_load_size
        load_count = self.last_show_down_load_size
        all_count = self.need_down_load_size
    end
    local value = load_count / all_count
    if value > 0.4 then
        add_progress = 0.01
    elseif value > 0.8 then
        add_progress = 0.008
    end
    if self.last_value and self.last_value >= value then
        value = self.last_value + add_progress
    end
    value = Mathf.Clamp01(value)

    local time
    if self.last_value and self.last_time then
        time = allTime * (value - self.last_value) + self.last_time * (1 - self.last_action:getProgress())
    else
        time = allTime * value
    end

    local show_last_value = self.last_value and self.last_value * 100 or 0
    if self.number_action and not self.number_action:isDone() then
        show_last_value = self.number_action.cur_num
    end

    self:RemoveAction()
    local pregress_bar_action = cc.ValueTo(time, value, self.progress_bar, "fillAmount")
    -- self.loadingText.text = string.format("%d/100", value * 100)

    local number_action = cc.NumberTo(time, show_last_value, value * 100, true, "%d/100", self.loadingText)
    local targetx = (self.lightx or 0) + (value * 828)

    local move_action = cc.MoveTo(time, targetx, self.lighty, 0)
    local action = cc.Spawn(pregress_bar_action, move_action, number_action)
    action = cc.Sequence(action, cc.DelayTime(0.2), cc.CallFunc(function()
        if load_count_1/all_count_1 == 1.0 then
            GlobalEvent:Brocast(LoginEvent.OpenLoginPanel)
        end
    end))
    cc.ActionManager:GetInstance():addAction(action, self.light)
    self.last_value = value
    self.last_time = time
    self.last_action = move_action
    self.number_action = number_action
end

function PreLoadingPanel:RemoveAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.light)
end

function PreLoadingPanel:CloseCallBack()
end