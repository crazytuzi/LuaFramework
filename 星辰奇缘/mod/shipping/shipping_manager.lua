ShippingManager = ShippingManager or BaseClass(BaseManager)

function ShippingManager:__init()
    if ShippingManager.Instance then
        Logger.Error("单例不可重复实例化")
    end
    ShippingManager.Instance = self
    self.model = ShippingModel.New()
    self:AddAllHandlers()
    self.status = 3  -- [[1: 装货进行中 2: ？？ 3：今天未接取  4：今天完成了]]
    self.first = true
    self.shippingmaindata = nil     -- 任务数据
    self.shipinfodata = nil         -- 预览数据
    self.quest_track = nil
    self.friendhelp_info = nil      -- 收到好友请求好友标识
    self.guildhelp_info = nil      -- 收到公会请求好友标识
    self.friendhelp_data = nil      -- 收到好友求助详细信息
    self.updataquest = function ()
        self:UpdataQuest()
    end
    self.questteam_loaded = false
    self.updata_need_list_func = function ()
        self:UpdataNeedList()
    end
end

function ShippingManager:AddAllHandlers()
    self:AddNetHandler(13700, self.On13700)
    self:AddNetHandler(13701, self.On13701)
    self:AddNetHandler(13702, self.On13702)
    self:AddNetHandler(13703, self.On13703)
    self:AddNetHandler(13704, self.On13704)
    self:AddNetHandler(13705, self.On13705)
    self:AddNetHandler(13706, self.On13706)
    self:AddNetHandler(13707, self.On13707)
    self:AddNetHandler(13708, self.On13708)
    self:AddNetHandler(13709, self.On13709)
    self:AddNetHandler(13710, self.On13710)
    self:AddNetHandler(13711, self.On13711)
    self:AddNetHandler(13712, self.On13712)
    self:AddNetHandler(13713, self.On13713)
    self:AddNetHandler(13714, self.On13714)
    self:AddNetHandler(13715, self.On13715)
    self:AddNetHandler(13716, self.On13716)
    self:AddNetHandler(13717, self.On13717)

    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function ()
        if self.shippingmaindata ~= nil then
            self:On13700({shipping = self.shippingmaindata})
        else
            self:Req13708()
        end
        self:Req13709()
        self.questteam_loaded = true
        -- self:CreatQuest()
    end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, function ()
        self:UpdataNeedList()
    end)

end

function ShippingManager:__delete()
end

function ShippingManager:On13700(dat)
    self.shippingmaindata = dat.shipping
    -- BaseUtils.dump(self.shippingmaindata, "00")
    if math.ceil(36000 - (BaseUtils.BASE_TIME - self.shippingmaindata[1].start_time)) <0 then
        self:Req13712()
        return
    end
    self.status = 1
    self:SortBoxList()
    if self.questteam_loaded and not self.quest_track then
        self:CreatQuest()
    end
    if self.model.accept_and_open_main == true then
        self.model.accept_and_open_main = false
        self.model:CloseShipWin()
        self.model:OpenMain()
        -- print("WTF")
        -- self.model.mainpanel:LoadInfo()
    elseif self.model.mainpanel then
        self.model.mainpanel:LoadInfo()
    end
end

function ShippingManager:On13701(dat)
    -- "未开始时，远航商人数据"
    self.shipping_need = {}
    self.shipinfodata = dat
    self.shippingmaindata = nil
    self:DeleteQuest()
    if self.shipinfodata.flag == 0 then
        self.status = 4
    else
        self.status = 3
    end
    self.model:LoadAcceptPanel()
    -- BaseUtils.dump(dat, "01")
end

function ShippingManager:On13702(dat)
    -- "开始起航任务"
    -- BaseUtils.dump(dat, "02")
end

function ShippingManager:On13703(dat)
    -- "自己提交远航道具"
    -- BaseUtils.dump(dat, "03")
    local data = nil
    if self.shippingmaindata ~= nil then
        for i,v in ipairs(self.shippingmaindata[1].shipping_cell) do
            if v.id == dat.id then
                self.shippingmaindata[1].shipping_cell[i].help_type = dat.help_type
                self.shippingmaindata[1].shipping_cell[i].status = dat.status
                data = self.shippingmaindata[1].shipping_cell[i]
            end
        end
    end
    if self.model.mainpanel then
        SoundManager.Instance:Play(258)
        self.model.mainpanel.selectdata = nil
        self.model.mainpanel:SetBox(nil, data)
        self.model.mainpanel:UpdataHelpCon()
    end
end

function ShippingManager:On13704(dat)
    -- "提交求助道具"
    --BaseUtils.dump(dat, "04")
    if self.model.mainpanel then
        SoundManager.Instance:Play(258)
        self.model.mainpanel.selectdata = nil
        self.model.mainpanel:SetBox(nil, dat)
        self.model.mainpanel:UpdataHelpCon()
    end
    -- for i,v in ipairs(self.shippingmaindata[1].shipping_cell) do
    --     if v.id == dat.id then
    --         self.shippingmaindata[1].shipping_cell[i] = dat
    --     end
    -- end
end

function ShippingManager:On13705(dat)
    -- "起航"
    -- BaseUtils.dump(dat, "05")
    if dat.op_code == 1 then
        SoundManager.Instance:Play(259)
        self.shippingmaindata = nil
        self.status = 4
        self:DeleteQuest()
        -- self:Req13709()
        if not BaseUtils.isnull(self.model.mainpanel) then
            self.model.mainpanel:GoEffect()
        end
    end
end

function ShippingManager:On13706(dat)
    -- "公会求助"
    -- BaseUtils.dump(dat, "06")
    if dat.op_code == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经向公会成员发出求助"))
        for i,v in ipairs(self.shippingmaindata[1].shipping_cell) do
            if v.id == dat.cell_id then
                if self.shippingmaindata[1].shipping_cell[i].help_type == 2 then
                    self.shippingmaindata[1].shipping_cell[i].help_type = 3
                else
                    self.shippingmaindata[1].shipping_cell[i].help_type = 1
                end
                if self.model.mainpanel then
                    self.model.mainpanel:SetBox(nil, self.shippingmaindata[1].shipping_cell[i])
                end
            end
        end
    else
        -- NoticeManager.Instance:FloatTipsByString(TI18N("求助失败"))
    end
end

function ShippingManager:On13707(dat)
    -- "好友求助"
    -- BaseUtils.dump(dat, "07")
    if dat.op_code == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经向指定好友发出求助"))
        for i,v in ipairs(self.shippingmaindata[1].shipping_cell) do
            if v.id == dat.cell_id then
                if self.shippingmaindata[1].shipping_cell[i].help_type == 2 then
                    self.shippingmaindata[1].shipping_cell[i].help_type = 3
                else
                    self.shippingmaindata[1].shipping_cell[i].help_type = 1
                end
                if self.model.mainpanel then
                    self.model.mainpanel:SetBox(nil, self.shippingmaindata[1].shipping_cell[i])
                end
            end
        end
    end
end

function ShippingManager:On13708(dat)
    -- "获取远航商人数据"
    -- BaseUtils.dump(dat, "08!!!!!!!!")
end

function ShippingManager:On13709(dat)
    -- "推送远航商人状态"
    self.status = dat.status
    if dat.status == 1 then
        self:Req13708()
    end
    --BaseUtils.dump(dat, "09")
end

function ShippingManager:On13710(dat)
    -- "求助详细信息"
    -- BaseUtils.dump(dat, "10")
    self.friendhelp_data = dat
    if dat.op_code == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("真可惜,该求助信息已过期或被别人抢先一步了哦～"))
        return
    end
    self.model:OpenToHelpWin()
end

function ShippingManager:On13711(dat)
    -- "推送好友求助信息"
    self.friendhelp_info = dat
    -- ui_notice.set_shipnotice_num(1)
    -- BaseUtils.dump(dat, "11")
end


function ShippingManager:On13712(dat)
    -- "超时信息"
    self:DeleteQuest()
    self:Req13708()
    -- BaseUtils.dump(dat, "12")
end


function ShippingManager:On13713(dat)
    -- "超时信息"

    --BaseUtils.dump(dat, "123333333333333")
    local cfg = DataShipping.data_quest_end[dat.type]
    if cfg ~= nil then
        if dat.op_code == 1 then
            local valdes = ""
            if TeamManager.Instance:HasTeam() then
                for i,v in ipairs(cfg.args) do
                    if v.num == TeamManager.Instance.teamNumber then
                        valdes = string.format(TI18N("<color='#ffff00'>（邀请小伙伴%s人，%s）</color>"), v.num, v.desc)
                    end
                end
            end
            FinishCountManager.Instance.model.reward_win_data = {
                titleTop = cfg.qname
                , val = valdes
                , val1 = ""
                , val2 = string.format("<color='#225ee7'>%s</color>", cfg.fdesc)
                -- , val2 = string.format("<size=16><color='#225ee7'>%s</color></size>", cfg.fdesc)
                , title = cfg.ftitle2
                -- , confirm_str = "确定"
                , share_str = TI18N("确定")
                , reward_list = dat.item
                , share_callback = function()
                        self.model:OpenMain()
                    end
            }
            FinishCountManager.Instance.model:InitRewardWin_Common()
        else
            FinishCountManager.Instance.model.reward_win_data = {
                titleTop = cfg.qname
                -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                , val1 = cfg.fdesc
                -- , val2 = (dat.op_code == 1 and TeamManager.Instance.teamNumber >= 3) and "<color='#ffff00'>（邀请小伙伴3人，奖励加成10%）</color>" or ""
                , title = cfg.ftitle2
                -- , confirm_str = "确定"
                , share_str = TI18N("确定")
                , reward_list = dat.item
                , share_callback = function()

                    end
            }
            FinishCountManager.Instance.model:InitRewardWin_Common()
        end
    end
end



function ShippingManager:On13714(dat)
    -- "超时信息"
    --BaseUtils.dump(dat, "144444444444")
    -- self:DeleteQuest()
    -- self:Req13708()
    self.model:UpdateFrightPanel(dat)
end



function ShippingManager:On13715(dat)
    -- "超时信息"
    --BaseUtils.dump(dat, "155555555555")
end

function ShippingManager:On13716(dat)
    -- "超时信息"
    --BaseUtils.dump(dat, "1666666666666666")
    self.model:ShowBoxResult(dat)
end

function ShippingManager:On13717()
    -- "超时信息"
    --BaseUtils.dump(dat, "13717777777777777777777777777777777777777777777")
    self:BeginPickUp()
end



function ShippingManager:Req13700(_rid, _platform, _zone_id)
    Connection.Instance:send(13700,{role_id = rid, platform = _platform, zone_id = _zone_id})
end

function ShippingManager:Req13701()
    Connection.Instance:send(13701,{})
end

function ShippingManager:Req13702()
    Connection.Instance:send(13702,{})
end

function ShippingManager:Req13703(_cell_id)
    Connection.Instance:send(13703,{cell_id = _cell_id})
end

function ShippingManager:Req13704(_tag, _rid, _platform, _zone_id, _cell_id)
    -- print("13704!!!!!!!!!!")
    -- print("tag="..tostring(_tag))
    -- print("_rid="..tostring(_rid))
    -- print("_platform="..tostring(_platform))
    -- print("_zone_id="..tostring(_zone_id))
    -- print("_cell_id="..tostring(_cell_id))
    Connection.Instance:send(13704,{tag = _tag, role_id = _rid, platform = _platform, zone_id = _zone_id, cell_id = _cell_id})
end

function ShippingManager:Req13705()
    Connection.Instance:send(13705,{})
end

function ShippingManager:Req13706(_cell_id)
    Connection.Instance:send(13706,{cell_id = _cell_id})
end

function ShippingManager:Req13707(_ids, _cell_id)
    local online = FriendManager.Instance:GetOnlineList()
    if #_ids < 1 and #online > 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要求助的好友"))
        return
    elseif #online < 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有在线的好友"))
        return
    end
    Connection.Instance:send(13707,{ids = _ids, cell_id = _cell_id})
end

function ShippingManager:Req13708()
    Connection.Instance:send(13708,{})
end

function ShippingManager:Req13709()
    Connection.Instance:send(13709,{})
end

function ShippingManager:Req13710(_flag, _role_id, _platform, _zone_id, _cell_id)
    self.currHelpType = _flag
    Connection.Instance:send(13710,{flag = _flag, role_id = _role_id, platform = _platform, zone_id = _zone_id, cell_id = _cell_id})
end

function ShippingManager:Req13711()
    Connection.Instance:send(13711,{})
end

function ShippingManager:Req13712()
    Connection.Instance:send(13712,{})
end

function ShippingManager:Req13715(id)
    Connection.Instance:send(13715,{cell_id = id})
end

function ShippingManager:Req13716(args)
    Connection.Instance:send(13716,args)
end

function ShippingManager:CreatQuest()
    if self.shippingmaindata == nil or self.quest_track then
        return
    end
    self.quest_track, self.quest_item = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
    local time = math.ceil(36000 - (BaseUtils.BASE_TIME - self.shippingmaindata[1].start_time))
    local h = math.floor(time/3600)>9 and math.floor(time/3600) or string.format("0%s", tostring(math.floor(time/3600)))
    local m = math.floor(time%3600/60)>9 and math.floor(time%3600/60) or string.format("0%s", tostring(math.floor(time%3600/60)))

    self.quest_track.callback = function ()
            self.model:OpenMain()
        end
    self.quest_track.type = CustomTraceEunm.Type.Shipping
    self.quest_track.title = TI18N("[日常]远航商人")
    self.quest_track.Desc = string.format(TI18N("剩余<color='#00ff12'>%s小时%s分</color>"), tostring(h), tostring(m))

    MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
    self:UpdataQuest()
end

function ShippingManager:DeleteQuest()
    if self.questTimeId ~= nil then
        LuaTimer.Delete(self.questTimeId)
        self.questTimeId = nil
    end

    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
        self.quest_item = nil
    end
    -- windows.close_window(windows.panel.shippingwindow)
    self.model:CloseMain()
    -- self:Req13708()
end

function ShippingManager:UpdataQuest()
    if self.quest_track and self.shippingmaindata then
        local time = math.ceil(36000 - (BaseUtils.BASE_TIME - self.shippingmaindata[1].start_time))
        if time <= 0 and self.quest_track then
            self:DeleteQuest()
            return
        end
        local h = math.floor(time/3600)>9 and math.floor(time/3600) or string.format("0%s", tostring(math.floor(time/3600)))
        local m = math.floor(time%3600/60)>9 and math.floor(time%3600/60) or string.format("0%s", tostring(math.floor(time%3600/60)))

        self.quest_track.Desc = string.format(TI18N("剩余<color='#00ff12'>%s小时%s分</color>"), tostring(h), tostring(m)),
        self.quest_item:UpdateShippingCountDown(self.shippingmaindata[1].start_time)
        -- MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
        self.questTimeId = LuaTimer.Add(5000, self.updataquest)
    elseif self.shippingmaindata == nil then
        self:DeleteQuest()
    end
    -- ctx:InvokeDelay(self.updataquest, 61)
end

function ShippingManager:SortBoxList()
    local datalist = self.shippingmaindata[1].shipping_cell
    table.sort( datalist, function (a, b) return a.id < b.id end )
    self.shippingmaindata[1].shipping_cell = datalist
    local needtabel = {}
    for k,v in pairs(datalist) do
        if v.status ~= 2 then
            local has = BackpackManager.Instance:GetItemCount(v.item_base_id)
            if has < v.need_num then
                needtabel[v.item_base_id] = {id = v.item_base_id, num = v.need_num}
                -- table.insert(needtabel, {id = v.item_base_id, num = v.need_num})
            end
            -- local _type = data_item.data_get[v.item_base_id].type
            -- if not table.containValue( self.shipping_type, _type) then
            --     table.insert(self.shipping_type, _type)
            -- end
        end
    end
    self.shipping_need = needtabel
    self:UpdataNeedList()

end

function ShippingManager:UpdataNeedList()
    self:UpdateNeedTable()
    if self.shipping_need ~= nil then
        for k,v in pairs(self.shipping_need) do
            local has = BackpackManager.Instance:GetItemCount(v.id)
            if has < v.num then

            else
                self.shipping_need[k] = nil
            end
        end
    end
end

function ShippingManager:IsCanGoShip()
    if self.shippingmaindata ~= nil then
        for k,v in pairs(self.shippingmaindata[1].shipping_cell) do
            local has = BackpackManager.Instance:GetItemCount(v.item_base_id)
            if v.need_num > has then
                return false
            end
        end
        return true
    end
    return false
end

function ShippingManager:IsShippingNeed(baseid)
    if self.shipping_need == nil or next(self.shipping_need) == nil then return false end
    for k,v in pairs(self.shipping_need) do
        if baseid == v.id then
            return true
        end
    end
    return false
end

function ShippingManager:UpdateNeedTable()
    if self.shippingmaindata == nil or self.shippingmaindata[1].shipping_cell == nil then return end
    local datalist = self.shippingmaindata[1].shipping_cell
    local needtabel = {}
    for k,v in pairs(datalist) do
        if v.status ~= 2 then
            local has = BackpackManager.Instance:GetItemCount(v.item_base_id)
            if has < v.need_num then
                needtabel[v.item_base_id] = {id = v.item_base_id, num = v.need_num}
                -- table.insert(needtabel, {id = v.item_base_id, num = v.need_num})
            end
        end
    end
    self.shipping_need = needtabel
end

function ShippingManager:On_Reconnect()
    self.shipping_need = nil
    self.shippingmaindata = nil
    self:DeleteQuest()
    self:Req13708()
    -- self:Req13709()
end

function ShippingManager:AutoTeam()
    local Cycledata = DataShipping.data_quest[self.qbox.quest_id]
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能完成此任务"))
    else
        TeamManager.Instance:Send11701()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[10] = ShipMatchEumn[Cycledata.type]
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
    end
end

function ShippingManager:BeginPickUp()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("宝箱将在<color='#ffff00'>30</color>秒后出现，是否<color='#ffff00'>暂离</color>拾取宝箱")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.cancelSecond = 180
    data.sureCallback = function()
        TeamManager.Instance:Send11706()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

-- -define(combat_type_shipping,       34).            %% 远航
-- -define(dungeon_type_shipping, 4).   %% 远航


-- -define(dungeon_extra_count_down,   1).   %%  倒计时参数 {key, num, 0, "", ""}
-- -define(dungeon_extra_box_score,    2).   %%  宝箱积分  {key, num, 0, "", ""}
-- -define(dungeon_extra_box_num,      3).   %%  宝箱数量  {key, baseid, num, "", ""}
