--2016/9/22
--xjlong
--国庆活动
NationalDayManager = NationalDayManager or BaseClass(BaseManager)

function NationalDayManager:__init()
    if NationalDayManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    NationalDayManager.Instance = self
    self:InitHandler()
    self.model = NationalDayModel.New()

    self.redPointDataDic = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
    } --model.tab_data_list里面的{id=true/false,}

    -- 彩虹七天乐奖池
    self.rainbow_prize_list = {}
    -- 彩虹七天乐公告列表
    self.rainbow_notice_list = {}
    -- 彩虹七天乐上传免费刷新时间
    self.last_free_time = 0
    -- 彩虹七天乐当前抽中的序号
    self.rainbow_id = 0
    -- 彩虹七天乐传闻展示序号
    self.rainbow_notice_index = 1
    --角色是否已加载完成
    self.isSelfLoaded = false
    -- 是否提示过抽奖消耗
    self.hasNoticeRoll1 = false
    self.hasNoticeRoll10 = false
    self.hasNoticeRollRefresh = false
    self.hasNoticeRollRefreshFree = false

    self.selfRoleLoaded = function()
        self.isSelfLoaded = true
    end
    EventMgr.Instance:AddListener(event_name.self_loaded, self.selfRoleLoaded)
end

function NationalDayManager:__delete()
    self.model:DeleteMe()
    self.model = nil
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.selfRoleLoaded)
end

function NationalDayManager:InitHandler()
    self:AddNetHandler(14809, self.On14809)
    self:AddNetHandler(14810, self.On14810)
    self:AddNetHandler(14811, self.On14811)

    self:AddNetHandler(14070, self.On14070)
    self:AddNetHandler(14071, self.On14071)
    self:AddNetHandler(14072, self.On14072)

    self:AddNetHandler(14073, self.On14073)
    self:AddNetHandler(14074, self.On14074)
    self:AddNetHandler(14075, self.On14075)
    self:AddNetHandler(14076, self.On14076)
    self:AddNetHandler(14077, self.On14077)
    self:AddNetHandler(14078, self.On14078)
    self:AddNetHandler(14079, self.On14079)

    self:AddNetHandler(14080, self.On14080)
    self:AddNetHandler(14081, self.On14081)
    self:AddNetHandler(14082, self.On14082)
    self:AddNetHandler(14083, self.On14083)
    self:AddNetHandler(14084, self.On14084)
    self:AddNetHandler(14085, self.On14085)
    self:AddNetHandler(14086, self.On14086)

    EventMgr.Instance:AddListener(event_name.mainui_notice_init, function()
        self:Send14070()
    end)
end

--狂欢活动
function NationalDayManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(313)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.NationalDay]
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NationalDay] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[313]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.national_day_window)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
end

function NationalDayManager:RequestInitData()
    self.hasNoticeRoll1 = false
    self.hasNoticeRoll10 = false
    self.hasNoticeRollRefresh = false
    self.hasNoticeRollRefreshFree = false
    self.rainbow_id = 0
    self:Send14070()
end

----------------------检查是否显示红点
--各个自功能检查是否图标需要显示红点
function NationalDayManager:check_red_point()
    local state = false
    state = self.redPointDataDic[1]
--    state = state or self.redPointDataDic[2]
--    state = state or self.redPointDataDic[3]
--    state = state or self.redPointDataDic[4]
--    state = state or self.redPointDataDic[5]
--    state = state or self.redPointDataDic[6]
    -- local cfg_data = DataSystem.data_daily_icon[NewLabourManager.SYSTEM_ID]
    -- if MainUIManager.Instance.MainUIIconView ~= nil then
    --     MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, state)
    -- end
end

-- 获取抽奖传闻序号
function NationalDayManager:GetRollNoticeIndex()
    self.rainbow_notice_index = self.rainbow_notice_index + 1
    if self.rainbow_notice_index >= #self.rainbow_notice_list then
        self.rainbow_notice_index = 1
    end
    return self.rainbow_notice_index
end

-------------------协议接收逻辑
--查看五彩便河山当前状态
function NationalDayManager:On14809(data)
    self.model:On14809(data)
end

--参与五彩便河山试炼
function NationalDayManager:On14810(data)
    self.model:On14810(data)
end

function NationalDayManager:On14811(data)
    self.model:On14811(data)
end

--通知智多星活动状态(主界面显示用)
function NationalDayManager:On14070(data)
    -- print("-------------------收到14070")
    -- BaseUtils.dump(data)
    self.model:On14070(data)
end

--获取题目信息
function NationalDayManager:On14071(data)
    -- print("-------------------收到14071")
    -- BaseUtils.dump(data)
    self.model:On14071(data)
end

--智多星答题
function NationalDayManager:On14072(data)
    -- print("-------------------收到14072")
    -- BaseUtils.dump(data)
    self.model:On14072(data)
end

function NationalDayManager:On14080(data)
    self.model:On14080(data)
end

function NationalDayManager:On14081(data)
    self.model:On14081(data)
end

function NationalDayManager:On14082(data)
    self.model:On14082(data)
end

function NationalDayManager:On14083(data)
    -- print("-------------------收到14083")
    if data.err_code == 1 then
        QuestManager.Instance.model:RemoveDefenseCakeNpc()
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalDayManager:On14084(data)
    -- BaseUtils.dump(data,"NationalDayManager:On14084(data)")

    local reward_list = {}
    local count = 0
    for i,v in ipairs(data.reward_list) do
        if v.item_id == 1 then
            count = v.num
        else
            v.id = v.item_id
            table.insert(reward_list, BaseUtils.copytab(v))
        end
    end

    local btnStr = ""
    if self.model.defensecake_data.max > self.model.defensecake_data.times then
        btnStr = TI18N("继续护送")
    else
        btnStr = TI18N("回到主城")
    end

    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("保卫蛋糕")
                        -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                        , val1 = ""
                        , val2 = string.format(TI18N("蛋糕已经成功分享给大家，并为节日增加了%s点祝福值(节日祝福值达到1000可额外获得奖励)"), count)
                        , title = TI18N("保卫蛋糕奖励")
                        -- , confirm_str = "查看排名"
                        , share_str = btnStr
                        , reward_list = reward_list
                        -- , confirm_callback = function() ClassesChallengeManager.Instance:Send14805() end
                        , share_callback = function()
                                if self.model.defensecake_data.max > self.model.defensecake_data.times then
                                    local key = BaseUtils.get_unique_npcid(65, 1)
                                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, key, nil, nil, true)
                                else
                                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
                                    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
                                end

                                self.model:CheckOpenSuccessWin()
                            end
                    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end

function NationalDayManager:On14085(data)
    self.model:On14085(data)
end

function NationalDayManager:On14086(data)
    self.model:On14086(data)
end

-------------------协议发送逻辑
--查看五彩便河山当前状态
function NationalDayManager:Send14809()
    -- print("发送14809")
    Connection.Instance:send(14809, { })
end

--参与五彩便河山试炼
function NationalDayManager:Send14810()
    -- print("发送14810")
    Connection.Instance:send(14810, { })
end

--查看五彩便河山成绩
function NationalDayManager:Send14811()
    -- print("发送14811")
    Connection.Instance:send(14811, { })
end

--通知智多星活动状态(主界面显示用)
function NationalDayManager:Send14070()
    -- print("发送14070")
    Connection.Instance:send(14070, { })
end

--获取题目信息
function NationalDayManager:Send14071()
    -- print("发送14071")
    Connection.Instance:send(14071, { })
end

--智多星答题
function NationalDayManager:Send14072(anwer, isWorld)
    -- print("发送14072")
    local is_world = 0
    if isWorld ~= nil then
        is_world = 1
    end
    Connection.Instance:send(14072, {anwer = anwer, is_world = is_world})
end

-- 彩虹七天乐奖池数据
function NationalDayManager:Send14073()
    self:Send(14073, {})
end

function NationalDayManager:On14073(data)
    self.rainbow_prize_list = data.rainbow_prize_list
    self.rainbow_notice_list = data.notice_msg
    self.last_free_time = data.last_free_time
    table.sort(self.rainbow_prize_list, function(a,b) return a.id < b.id end)

    EventMgr.Instance:Fire(event_name.nationalday_rewardpool_update, {isInit = true})
end

-- 抽奖1次
function NationalDayManager:Send14074()
    self:Send(14074, {})
end

function NationalDayManager:On14074(data)
    for i,v in ipairs(self.rainbow_prize_list) do
        if v.id == data.id then
            self.rainbow_id = i
            break
        end
    end
    EventMgr.Instance:Fire(event_name.nationalday_rewardresult_update)
end

-- 进行彩虹发奖
function NationalDayManager:Send14075()
    self:Send(14075, {})
end

function NationalDayManager:On14075(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- 拿到奖励列表进行展示
    if #data.result > 1 then
        local list = {}
        for i,v in ipairs(data.result) do
            table.insert(list, {base_id = v.assets, num = v.val})
        end
        self.model:ShowRewardPanel(list)
    end
end

-- 刷新奖池
function NationalDayManager:Send14076()
    self:Send(14076, {})
end

function NationalDayManager:On14076(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 彩虹7天乐10连抽
function NationalDayManager:Send14077()
    self:Send(14077, {})
end

function NationalDayManager:On14077(data)
    for i,v in ipairs(self.rainbow_prize_list) do
        if v.id == data.id then
            self.rainbow_id = i
            break
        end
    end
    EventMgr.Instance:Fire(event_name.nationalday_rewardresult_update)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalDayManager:On14078(data)
    self.model:On14078(data)
end

--请求保卫蛋糕数据
function NationalDayManager:Send14080()
    -- print("发送14080")
    Connection.Instance:send(14080, { })
end

function NationalDayManager:Send14081()
    -- print("发送14081")
    Connection.Instance:send(14081, { })
end

--发送保卫蛋糕答题
function NationalDayManager:Send14082(_id, _answer)
    -- print("发送14082")
    Connection.Instance:send(14082, { id = _id, answer = _answer})
end

--取消保卫蛋糕任务
function NationalDayManager:Send14083()
    -- print("发送14083")
    Connection.Instance:send(14083, { })
end

function NationalDayManager:Send14086()
    -- print("发送14086")
    Connection.Instance:send(14086, { })
end
