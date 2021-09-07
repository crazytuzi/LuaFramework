-- -------------------------------
-- 诸神膜拜之战录像观看元素
-- hosr
-- -------------------------------
GodsWarWorShipVideoItem = GodsWarWorShipVideoItem or BaseClass()

function GodsWarWorShipVideoItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent

    self:InitPanel()
end

function GodsWarWorShipVideoItem:__delete()
end

function GodsWarWorShipVideoItem:InitPanel()
    self.transform = self.gameObject.transform
    self.index = self.transform:Find("Index"):GetComponent(Text)
    self.name1 = self.transform:Find("Name1"):GetComponent(Text)
    self.name2 = self.transform:Find("Name2"):GetComponent(Text)
    self.type = self.transform:Find("Type"):GetComponent(Text)
    self.tiemDate = self.transform:Find("Date"):GetComponent(Text)
    self.playTimesButton = self.transform:Find("PlayButton"):GetComponent(Button)
    self.transform:GetComponent(Button).onClick:AddListener(function() self:PalyVedio() end)
    self.playTimesButton.onClick:AddListener(function() self:PalyVedio() end)
    self.playTimesText = self.transform:Find("PlayText"):GetComponent(Text)
    -- self.collect = self.transform:Find("Cancel").gameObject
    -- self.collect:GetComponent(Button).onClick:AddListener(function() self:ClickCollect() end)
    -- self.replay = self.transform:Find("Sure").gameObject
    -- self.replay:GetComponent(Button).onClick:AddListener(function() self:ClickWatch() end)
    -- self.watch = self.transform:Find("Button").gameObject
    -- self.watch:GetComponent(Button).onClick:AddListener(function() self:ClickWatch() end)
end

-- {uint32, id, "战斗id,用于查看录像用"}
-- ,{uint16,  season_id , "赛季id"}
-- ,{uint8, match_round, "赛季场次 3：16进8 4：8进4 5：半决赛 6：季军赛 7：决赛"}
-- ,{uint8, match_type, "赛程类型1：小组赛 2：淘汰赛"}
-- ,{uint8, combat_type, "战斗类型"}
-- ,{uint8, group_id, "比赛分组"}
-- ,{uint8, is_over, "战斗是否结束 0：未结束 1：已经结束"}
-- ,{string, atk_name, "攻方名字"}
-- ,{string, dfd_name, "守方名字"}
-- ,{uint32,  time, "战斗时间戳"}
function GodsWarWorShipVideoItem:PalyVedio()
    if self.data ~= nil then
        CombatManager.Instance:Send10753(13, self.data.id, self.data.platform, self.data.zone_id)
    end
end
function GodsWarWorShipVideoItem:update_my_self(data, index)
    self.data = data

    self.index.text = GodsWarWorShipManager.Instance.model.vedioGroup[data.group_id].name

    if self.data.niceType == nil then
        if self.data.match_round == 7 then
            self.tiemDate.text = string.format("%s最强对决",GodsWarWorShipManager.Instance.model.vedioGroup[data.group_id].name)
        else
            self.tiemDate.text = string.format("巅峰对决%s级",GodsWarWorShipManager.Instance.model.vedioGroup[data.group_id].minLev)
        end
    else
        if self.data.niceType == 1 then
            self.tiemDate.text = string.format("最持久战",data.round)
        elseif self.data.niceType == 2 then
            self.tiemDate.text = string.format("最受欢迎")
        elseif self.data.niceType == 3 then
            self.tiemDate.text = string.format("以弱胜强")
        end
    end

    self.playTimesText.text = data.replayed


    if self.data == nil then
        self.gameObject:SetActive(false)
    else
        self.name1.text = self.data.atk_name
        self.name2.text = self.data.dfd_name


        if self.data.match_round == 3 then
                self.type.text = TI18N("16进8")
        elseif self.data.match_round == 4 then
                self.type.text = TI18N("8进4")
        elseif self.data.match_round == 5 then
                self.type.text = TI18N("半决赛")
        elseif self.data.match_round == 6 then
                self.type.text = TI18N("季军赛")
        elseif self.data.match_round == 7 then
                self.type.text = TI18N("决赛")
        end

        -- if self.data.is_over == 1 then
        --     -- self.watch:SetActive(false)
        --     -- self.collect:SetActive(true)
        --     -- self.replay:SetActive(true)
        -- else
        --     -- self.watch:SetActive(true)
        --     self.collect:SetActive(false)
        --     self.replay:SetActive(false)
        -- end
        self.gameObject:SetActive(true)
    end
end

-- function GodsWarWorShipVideoItem:ClickCollect()
--     if self.data ~= nil then
--         local platform = GodsWarManager.Instance.videoPlatform
--         local zone_id = GodsWarManager.Instance.videoZondId
--         CombatManager.Instance:Send10750(13, self.data.id, platform, zone_id)
--     end
-- end

-- function GodsWarWorShipVideoItem:ClickWatch()
--     if self.data ~= nil then
--         GodsWarManager.Instance:Send17929(self.data.id)
--         self.parent:Close(false)
--     end
-- end
