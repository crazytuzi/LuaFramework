ClassesChallengeMyScoreWindow  =  ClassesChallengeMyScoreWindow or BaseClass(BaseWindow)

function ClassesChallengeMyScoreWindow:__init(model)
    self.name  =  "ClassesChallengeMyScoreWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.classes_challenge_my_score_win, type  =  AssetType.Main}
    }
    return self
end

function ClassesChallengeMyScoreWindow:__delete()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ClassesChallengeMyScoreWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.classes_challenge_my_score_win))
    self.gameObject.name  =  "ClassesChallengeMyScoreWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    local CloseBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseMainUI() end)

    self.MyRank = self.transform:FindChild("Main/MyRank"):GetComponent(Text)
    self.MyScore = self.transform:FindChild("Main/MyScore"):GetComponent(Text)

    self:update_my_score()
end

--更新我的答题成绩
function ClassesChallengeMyScoreWindow:update_my_score()
    local data = self.model

    local function sortfun(a,b)
        return a.rank < b.rank
    end

    if #data.rank_list > 0 then table.sort(data.rank_list, sortfun) end

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(data.time_span)
    my_minute = my_minute + 60 * my_hour
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.MyRank.text = string.format("%s<color='#c7f9ff'>%s</color>", TI18N("我当前的排名："), data.rank)
    self.MyScore.text = string.format("%s<color='#c7f9ff'>%s%s%s%s</color>", TI18N("我的用时："), my_minute, TI18N("分"), my_second, TI18N("秒"))

    local rank_panel_transform = self.transform:FindChild("Main/RankPanel")
    for i = 1, 10 do
        local rank_data = data.rank_list[i]
        if rank_data ~= nil then
            local rank_transform = rank_panel_transform:FindChild(string.format("Rank%s", i))
            rank_transform:FindChild("RankText"):GetComponent(Text).text = string.format("%s", i)
            local name = ""
            for _, v in pairs(data.rank_list[i].members) do
                if v.is_leader == 1 then
                    name = v.name
                end
            end
            rank_transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s", name)
            rank_transform:FindChild("StarText"):GetComponent(Text).text = string.format("%s★", rank_data.star)

            local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(data.rank_list[i].time_span)
            my_minute = my_minute + 60 * my_hour
            my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
            my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
            local time_str = string.format("%s%s%s%s", my_minute, TI18N("分"), my_second, TI18N("秒"))
            rank_transform:FindChild("TimeText"):GetComponent(Text).text = time_str
        else
            local rank_transform = rank_panel_transform:FindChild(string.format("Rank%s", i))
            rank_transform:FindChild("RankText"):GetComponent(Text).text = ""
            rank_transform:FindChild("NameText"):GetComponent(Text).text = ""
            rank_transform:FindChild("StarText"):GetComponent(Text).text = ""
            rank_transform:FindChild("TimeText"):GetComponent(Text).text = ""
            rank_transform:FindChild("I18NText"):GetComponent(Text).text = ""
        end
    end
end