-- 叛变播报
MutinyAction = MutinyAction or BaseClass(CombatBaseAction)

function MutinyAction:__init(brocastCtx, EnterData, moveType)
    self.brocastCtx = brocastCtx
    self.EnterData = EnterData
    self.fighter0ChangeList = {}
    self.fighter1ChangeList = {}
    self.mastername0 = ""
    self.mastername1 = ""
    local fighterList = self.EnterData.fighter_list
    for _,fighter in pairs(fighterList) do
        for k,v in pairs(fighter.looks) do
            if v.looks_type == 72 then
                if fighter.group == 0 then
                    self.mastername1 = v.looks_str
                    self.fighter0ChangeList[fighter.pos] = {id = fighter.id, group = v.looks_mode, pos = v.looks_val}
                else
                    self.mastername2 = v.looks_str
                    self.fighter1ChangeList[fighter.pos] = {id = fighter.id, group = v.looks_mode, pos = v.looks_val}
                end
            end
        end
    end
    self:Parse()
end

function MutinyAction:Parse()
    self.changeGroup = {}
    -- BaseUtils.dump(self.fighter0ChangeList, "000000")
    -- BaseUtils.dump(self.fighter1ChangeList, "111111")
    for k,v in pairs(self.fighter0ChangeList) do
        local selfid = v.id
        if self.fighter1ChangeList[v.pos] ~= nil then
            local targetid = self.fighter1ChangeList[v.pos].id
            local selfctr = self.brocastCtx:FindFighter(selfid)
            local targetctr = self.brocastCtx:FindFighter(targetid)
            table.insert(self.changeGroup, {self.brocastCtx:FindFighter(selfid), self.brocastCtx:FindFighter(targetid)})
        else
            print("table1的"..tostring(v.pos))
        end
    end
end

function MutinyAction:Play()
    if next(self.fighter0ChangeList) == nil then
        self:InvokeAndClear(CombatEventType.End)
    else
        local delayNum = 2000
        local name1 = ""
        local name2 = ""

        for _,v in pairs(self.changeGroup) do
            if name1 == "" then
                name1 = v[1].fighterData.name
                name2 = v[2].fighterData.name
            else
                name1 = string.format("%s、%s", name1, v[1].fighterData.name)
                name2 = string.format("%s、%s", name2, v[2].fighterData.name)
            end
            LuaTimer.Add(delayNum, function()
                local oldspeed = v[1].speed
                v[1].speed = oldspeed / 4
                v[2].speed = oldspeed / 4
                local mList1 = {
                     {eventType = CombatEventType.MoveEnd, func = function() v[1].speed = oldspeed v[2].speed = oldspeed self.brocastCtx.controller.mainPanel:Relocatecombo() v[1]:FaceTo(v[1].originFaceToPos) end}
                }
                local mList2 = {
                     {eventType = CombatEventType.MoveEnd, func = function()v[1].speed = oldspeed v[2].speed = oldspeed self.brocastCtx.controller.mainPanel:Relocatecombo() v[2]:FaceTo(v[2].originFaceToPos) end}
                }
                local topos1 = v[2].originPos
                local topos2 = v[1].originPos
                v[1]:MoveTo(topos1, mList1)
                v[2]:MoveTo(topos2, mList2)
                v[1].originPos, v[2].originPos = v[2].originPos, v[1].originPos
                v[1].regionalPoint, v[2].regionalPoint = v[2].regionalPoint, v[1].regionalPoint
                v[1].originFaceToPos, v[2].originFaceToPos = v[2].originFaceToPos, v[1].originFaceToPos
                v[1].midPoint, v[2].midPoint = v[2].midPoint, v[1].midPoint
                self:DealRandomTalk(v[1])
                self:DealRandomTalk(v[2])
            end)

            delayNum = delayNum + 500
        end
        local msgdata = {
            type = 3,
            msg = string.format(TI18N("<color='#00ff00'>%s</color>与<color='#00ff00'>%s</color>进行了对调{face_1,16}"), name1, name2),
            limit = {}
        }
        NoticeManager.Instance.dispatcher:Dispatch(msgdata)
        LuaTimer.Add(delayNum+20, function()
            self:InvokeAndClear(CombatEventType.End)
        end)
    end
end

function MutinyAction:DealRandomTalk(fighter)
    local random1 = Random.Range(1, 100)
    if DataWarrior.data_guard_talk[fighter.fighterData.base_id] ~= nil then
        local data = DataWarrior.data_guard_talk[fighter.fighterData.base_id]
        local talknum = #data.talk
        local random2 = Random.Range(1, talknum)
        local random3 = Random.Range(1, talknum)
        local msg = ""
        if data.talk[random2].weight > data.talk[random3].weight then
            msg = data.talk[random2].sentence
        else
            msg = data.talk[random3].sentence
        end
        local action = TalkBubbleAction.New(self.brocastCtx, fighter.fighterData.id, msg)
        action:Play()
    end
end
