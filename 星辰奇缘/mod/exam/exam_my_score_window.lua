ExamMyScoreWindow  =  ExamMyScoreWindow or BaseClass(BaseWindow)

function ExamMyScoreWindow:__init(model)
    self.name  =  "ExamMyScoreWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.exam_my_score_win, type  =  AssetType.Main}
    }
    return self
end

function ExamMyScoreWindow:__delete()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ExamMyScoreWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.exam_my_score_win))
    self.gameObject.name  =  "ExamMyScoreWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.MainCon = self.transform:FindChild("MainCon")
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseMyScoreUI() end)

    self.TxtDesc1 = self.MainCon:FindChild("Text1"):GetComponent(Text)
    self.TxtDesc2 = self.MainCon:FindChild("Text2"):GetComponent(Text)
    self.TxtDesc3 = self.MainCon:FindChild("Text3"):GetComponent(Text)
    self.TxtDesc4 = self.MainCon:FindChild("Text4"):GetComponent(Text)
    self.TxtDesc5 = self.MainCon:FindChild("Text5"):GetComponent(Text)
    self.TxtDesc6 = self.MainCon:FindChild("Text6"):GetComponent(Text)
    self.TxtMyCurrentScore = self.MainCon:FindChild("TxtMyCurrentScore"):GetComponent(Text)
    self.TxtPercentScore = self.MainCon:FindChild("TxtPercentScore"):GetComponent(Text)
    self.TxtWeekScore = self.MainCon:FindChild("TxtWeekScore"):GetComponent(Text)
    self.TxtMyCurrentScore.text = ""
    self.TxtPercentScore.text = ""
    self.TxtWeekScore.text = ""
    self.TxtDesc1.text = ""
    self.TxtDesc2.text = ""
    self.TxtDesc3.text = ""
    self.TxtDesc4.text = ""
    self.TxtDesc5.text = ""
    self.TxtDesc6.text = ""

    self:update_my_score()
end

--更新我的答题成绩
function ExamMyScoreWindow:update_my_score()
    self.TxtMyCurrentScore.text = string.format("%s<color='#c7f9ff'>%s%s</color>", TI18N("我的当前总成绩："), self.model.my_score_data.score, TI18N("分"))
    self.TxtPercentScore.text = string.format("%s<color='#c7f9ff'>%s%s</color>", TI18N("当前决赛资格线："), self.model.my_score_data.bottom_rank_score, TI18N("分"))

    if self.model.my_score_data.rank ~= 0 then
        self.TxtWeekScore.text = string.format("%s<color='#c7f9ff'>%s%s</color>", TI18N("本周决赛成绩："), self.model.my_score_data.rank, TI18N("名"))
    else
        self.TxtWeekScore.text = string.format("%s<color='#c7f9ff'>%s</color>", TI18N("本周决赛成绩："), TI18N("暂无"))
    end

    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    week_day = week_day == 0 and 7 or week_day
    if week_day == 6 then
        self.TxtWeekScore.text = string.format("%s<color='#c7f9ff'>%s</color>", TI18N("本周决赛成绩："), TI18N("暂无"))
    end

    self.TxtDesc1.text = TI18N("<color='#98B5D4'>暂无</color>")
    self.TxtDesc2.text = TI18N("<color='#98B5D4'>暂无</color>")
    self.TxtDesc3.text = TI18N("<color='#98B5D4'>暂无</color>")
    self.TxtDesc4.text = TI18N("<color='#98B5D4'>暂无</color>")
    self.TxtDesc5.text = TI18N("<color='#98B5D4'>暂无</color>")
    self.TxtDesc6.text = TI18N("<color='#98B5D4'>暂无</color>")

    for i=1,#self.model.my_score_data.results do
        local dat = self.model.my_score_data.results[i]
        if dat.day == 1 then
            self.TxtDesc1.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        elseif dat.day == 2 then
            self.TxtDesc2.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        elseif dat.day == 3 then
            self.TxtDesc3.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        elseif dat.day == 4 then
            self.TxtDesc4.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        elseif dat.day == 5 then
            self.TxtDesc5.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        elseif dat.day == 6 then
            self.TxtDesc6.text = string.format(TI18N("<color='#8DE92A'>%s分</color>"), dat.day_score)
        end
    end
end
