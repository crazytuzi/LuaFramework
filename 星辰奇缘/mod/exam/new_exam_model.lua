NewExamModel = NewExamModel or BaseClass(BaseModel)

function NewExamModel:__init()
    self.newExamDescWindow = nil
    self.newExamTopWindow = nil
    self.newExamRankWindow = nil
    self.localSavekey = "NewExamModel_Limit"

    self.limitStatus = PlayerPrefs.GetInt(self.localSavekey) or 0
    
    self:RequestInitData()
end

function NewExamModel:__delete()

end

function NewExamModel:RequestInitData()
    self.status = 0
    self.endtime = 0
    self.questionData = nil
    self.chooseA_count = 0
    self.chooseB_count = 0
    self.myQuestionData = nil
    self.questionRankData = {}
    self.rank_list = {}
    self.self_rank = 0
    self.last_choose = 0

    self.lessTime = 0
end

--开启答题说明界面
function NewExamModel:OpenDescPanel(args)
    if self.newExamDescWindow == nil then
        self.newExamDescWindow = NewExamDescWindow.New(self)
    end
    self.newExamDescWindow:Show(args)
end

--关闭答题说明界面
function NewExamModel:CloseDescPanel()
    if self.newExamDescWindow ~= nil then
        self.newExamDescWindow:DeleteMe()
        self.newExamDescWindow = nil
    end
end

--开启答题界面
function NewExamModel:OpenNewExamTop()
    if self.newExamTopWindow == nil then
        self.newExamTopWindow = NewExamTopWindow.New(self)
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.limitStatus == 1)
    end
    self.newExamTopWindow:Show()
end

function NewExamModel:SetLimitLocal(bool)
    if bool then
        PlayerPrefs.SetInt(self.localSavekey, 1)
    else
        PlayerPrefs.SetInt(self.localSavekey, 0)
    end
end

--关闭答题界面
function NewExamModel:CloseNewExamTop()
    if self.newExamTopWindow ~= nil then
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)

        self.newExamTopWindow:DeleteMe()
        self.newExamTopWindow = nil
    end

end

--开启答题排行界面
function NewExamModel:OpenNewExamRank()
    if self.newExamRankWindow == nil then
        self.newExamRankWindow = NewExamRankWindow.New(self)
    end
    self.newExamRankWindow:Show()
end

--关闭答题排行界面
function NewExamModel:CloseNewExamRank()
    if self.newExamRankWindow ~= nil then
        self.newExamRankWindow:DeleteMe()
        self.newExamRankWindow = nil
    end
end

function NewExamModel:UpdateIcon()
    local cfg_data = DataSystem.data_daily_icon[345]
    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)

    if self.status == 1 then
        local click_callback = function()
            self:OpenNewExamDesc()
        end

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.text = TI18N("报名中")
        MainUIManager.Instance:AddAtiveIcon(iconData)

        LuaTimer.Add(5000, function()
            if RoleManager.Instance.RoleData.lev > cfg_data.lev and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.NewQuestionMatch then
                self:OpenNewExamDesc()
            end
        end)
    elseif self.status == 2 then
        local click_callback = function()
            self:OpenNewExamDesc()
        end

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = self.endtime - BaseUtils.BASE_TIME + Time.time
        MainUIManager.Instance:AddAtiveIcon(iconData)

        LuaTimer.Add(5000, function()
            if RoleManager.Instance.RoleData.lev > cfg_data.lev and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.NewQuestionMatch then
                self:OpenNewExamDesc()
            end
        end)
    else
        self.questionData = nil
        self.myQuestionData = nil
        self.questionRankData = {}
    end
end

--开启答题说明界面
function NewExamModel:OpenNewExamDesc()
    if self.status == 1 or self.status == 2 then
        local data = {}
        data.agenda_id = 2054
        data.title_text = TI18N("小猪快跳开始啦{face_1,1}")
        -- data.desc_text = TI18N("1.根据题目<color='#ffff00'>点击答案</color>，即可跳跃到<color='#ffff00'>对应平台</color>\n2.越早进入<color='#ffff00'>正确答案平台</color>积分越多\n3.<color='#ffff00'>答错的玩家</color>将会变成<color='#ffff00'>小猪</color>，直到答对题目\n4.获得本场比赛的<color='#ffff00'>前三名</color>可以获得<color='#ffff00'>[跳跃吧！智者猪]</color>称号\n5.每天只能获得<color='#ffff00'>一次</color>小猪快跳奖励")
        data.desc_text = TI18N("1.根据题目<color='#ffff00'>点击答案</color>，即可跳跃到<color='#ffff00'>对应平台</color>\n2.越早进入<color='#ffff00'>正确答案平台</color>积分越多\n3.<color='#ffff00'>答错的玩家</color>将会变成<color='#ffff00'>小猪</color>，直到答对题目\n4.获得本场比赛的<color='#ffff00'>前三名</color>可以获得<color='#ffff00'>[跳跃吧！智者猪]</color>称号")
        if self.status == 1 then
            data.endtime = self.endtime + 600
        else
            data.endtime = self.endtime
        end
        data.callback = function ()
            NewExamManager.Instance:send20103()
        end
        self:OpenDescPanel(data)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开始"))
    end
end