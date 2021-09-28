-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_dengmi = i3k_class("wnd_dengmi", ui.wnd_base)

function wnd_dengmi:ctor()
    self.config = i3k_db_dengmi_content
    self.index = 1
    self.day = 1
    self.batch = 1
    self.questions = {}
    self.question = nil
    self.haveChose = false
    self.state = 0
end

function wnd_dengmi:configure()
    self.ui = self._layout.vars
    self.ui.close:onClick(self, self.onCloseUI)
    self.ui.help:onClick(
        self,
        function()
            g_i3k_ui_mgr:ShowHelp(i3k_get_string(17004))
        end
    )
    self.ui.des:setText(i3k_get_string(17004))
    self.ui.des3:setText(i3k_get_string(17006))
    self.ui.endDesc:setText(i3k_get_string(17002))
    self.ui.endDesc2:setText(i3k_get_string(17054))
end

local getWorldCfg = function(id)
    local ret = {}
    for i, v in ipairs(i3k_db_dengmi_world_award) do
        if id == v.id then
            table.insert(ret, v)
        end
    end
    return ret
end

local getRoleCfg = function(id)
    local ret = {}
    for i, v in ipairs(i3k_db_dengmi_role_award) do
        if id == v.id then
            table.insert(ret, v)
        end
    end
    return ret
end

function wnd_dengmi:refresh(data)
    self.haveChose = false
    local roleInfo = data.roleInfo

    self.index = roleInfo.curIndex + 1
    self.day = roleInfo.curDay + 1
    self.batch = roleInfo.batch

    self.ui.worldScore:setText(data.worldScore)
    self.ui.personScore:setText(roleInfo.score)
    --世界奖励
    local worldCfg = getWorldCfg(roleInfo.batch)
    local worldPercent = 0
    for i, v in ipairs(worldCfg) do
        if data.worldScore >= v.needScore then
            worldPercent = i * 20
        else
            local lastScore = 0
            if i > 1 then
                lastScore = worldCfg[i - 1].needScore
            end
            local total = v.needScore - lastScore
            local off = data.worldScore - lastScore
            if off > 0 then
                worldPercent = worldPercent + off / total * 100 * 0.2
            end
        end

        self.ui["reward_txt1" .. i]:setText(v.needScore)
        if roleInfo.worldReward[v.needScore] then
            -- self.ui["reward_icon1" .. i]:setVisible(false)
            self.ui["reward_get_icon1" .. i]:setVisible(true)
            self._layout.anis["c_fudai" .. i]:stop()
            self.ui["reward_btn1" .. i]:onClick(
                self,
                function()
                    if roleInfo.worldReward[v.needScore] then
                        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17005))
                    end
                end
            )
        else
            if data.worldScore >= v.needScore then
                self._layout.anis["c_fudai" .. i]:play()
            end

            self:setFinishState(self.ui["value_img1" .. i], self.ui["reward_txt1" .. i], roleInfo.score >= v.needScore)

            self.ui["reward_btn1" .. i]:onClick(
                self,
                function()
                    local awardData = {}
                    local checkData = {}

                    for awardIndex, awardValue in ipairs(v.award) do
                        if awardValue.id ~= 0 then
                            table.insert(awardData, {id = awardValue.id, num = awardValue.count})
                            checkData[awardValue.id] = awardValue.count
                        end
                    end

                    if data.worldScore >= v.needScore then
                        if g_i3k_game_context:IsBagEnough(checkData) then
                            i3k_sbean.request_light_secret_world_take_req(
                                v.needScore,
                                function(isOk)
                                    if isOk == 1 then
                                        g_i3k_ui_mgr:ShowGainItemInfo(v.award)
                                    else
                                        g_i3k_ui_mgr:PopupTipMessage("领取失败")
                                    end
                                    i3k_sbean.request_light_secret_sync_req()
                                end
                            )
                        else
                            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
                        end
                    else
                        g_i3k_ui_mgr:OpenUI(eUIID_CallBackTips)
                        g_i3k_ui_mgr:RefreshUI(eUIID_CallBackTips, awardData)
                    end
                end
            )
        end
    end
    self.ui.worldProcess:setPercent(worldPercent)
    --个人奖励
    local roleCfg = getRoleCfg(roleInfo.batch)
    local rolePercent = 0
    for i, v in ipairs(roleCfg) do
        if roleInfo.score >= v.needScore then
            rolePercent = i * 20
        else
            local lastScore = 0
            if i > 1 then
                lastScore = roleCfg[i - 1].needScore
            end
            local total = v.needScore - lastScore
            local off = roleInfo.score - lastScore
            if off > 0 then
                rolePercent = rolePercent + off / total * 100 * 0.2
            end
        end
        self.ui["reward_txt" .. i]:setText(v.needScore)
        if roleInfo.roleReward[v.needScore] then
            -- self.ui["reward_icon" .. i]:setVisible(false)
            self.ui["reward_get_icon" .. i]:setVisible(true)
            self._layout.anis["c_bx" .. i]:stop()
            self.ui["reward_btn" .. i]:onClick(
                self,
                function()
                    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17005))
                end
            )
        else
            if roleInfo.score >= v.needScore then
                self._layout.anis["c_bx" .. i]:play()
            end

            self:setFinishState(self.ui["value_img" .. i], self.ui["reward_txt" .. i], roleInfo.score >= v.needScore)

            self.ui["reward_btn" .. i]:onClick(
                self,
                function()
                    if roleInfo.score >= v.needScore then
                        local leftBagSize = g_i3k_game_context:GetBagSize() - g_i3k_game_context:GetBagUseCell()
                        if leftBagSize < v.needBag then
                            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
                            return
                        end
                        i3k_sbean.request_light_secret_role_take_req(
                            v.needScore,
                            function(data)
                                if data.ok == 1 then
                                    local rewards = {}
                                    for k, v in pairs(data.drops) do
                                        table.insert(rewards, {id = k, count = v})
                                    end
                                    g_i3k_ui_mgr:ShowGainItemInfo(rewards)
                                else
                                    g_i3k_ui_mgr:PopupTipMessage("领取失败")
                                end
                                i3k_sbean.request_light_secret_sync_req()
                            end
                        )
                    else
                        local data = {{isRandom = true}}
                        g_i3k_ui_mgr:OpenUI(eUIID_CallBackTips)
                        g_i3k_ui_mgr:RefreshUI(eUIID_CallBackTips, data)
                    end
                end
            )
        end
    end
    self.ui.personProcess:setPercent(rolePercent)
    local state = g_i3k_db.i3k_db_get_dengmi_ui_state()
    self.state = state
    self.ui.endUI:setVisible(state == g_TYPE_END)
    self.ui.readyUI:setVisible(state == g_TYPE_PRE)
    self.ui.startUI:setVisible(state == g_TYPE_VALID)

    self.questions = self:getQuestions()
    self:showQuestion()
end

function wnd_dengmi:getQuestions()
    local questions = {}
    for i, v in ipairs(i3k_db_dengmi_content) do
        if v.id == self.batch and v.groupId == self.day then
            table.insert(questions, v)
        end
    end
    return questions
end

function wnd_dengmi:chose(id)
    self.ui["rightChose" .. self.question.rightChose]:setVisible(true)
    if id ~= self.question.rightChose then
        self.ui["wrongChose" .. id]:setVisible(true)
    end
    self._layout.rootVar:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(
                function()
                    i3k_sbean.request_light_secret_sync_req()
                end
            )
        )
    )
end

function wnd_dengmi:showQuestion()
    local question = self.questions[self.index]
    local totalNum = #self.questions
    if not question then
        if self.state == g_TYPE_VALID then
            self.ui.startUI:setVisible(false)
            self.ui.endUI:setVisible(true)
            self.ui.des3:setText(i3k_get_string(17007))
        end
        return
    end

    self.question = question

    self.ui.questionNum:setText(totalNum - self.index + 1 .. "/" .. totalNum)
    self.ui.score:setText("题目积分" .. i3k_db_dengmi_common.score)
    self.ui.question:setText(question.content)
    for i = 1, 4, 1 do
        self.ui["answer" .. i]:setText(question.chose[i])
        self.ui["chose" .. i]:setVisible(false)
        self.ui["rightChose" .. i]:setVisible(false)
        self.ui["wrongChose" .. i]:setVisible(false)
        self.ui["an" .. i]:onClick(
            self,
            function()
                if self.haveChose then
                    return
                end
                self.haveChose = true
                self.ui["chose" .. i]:setVisible(true)
                i3k_sbean.request_light_secret_answer_req(
                    question.itemId,
                    i,
                    function()
                        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dengmi, "chose", i)
                    end
                )
            end
        )
    end
end

function wnd_dengmi:getImage(bValue)
    return bValue and 7405 or 7406
end

function wnd_dengmi:getTextColor(bValue)
    return bValue and "ff094020" or "fff8eba3"
end

function wnd_dengmi:setImage(widget, bValue)
    local imageID = self:getImage(bValue)
    widget:setImage(g_i3k_db.i3k_db_get_icon_path(imageID))
end

function wnd_dengmi:setTextColor(widget, bValue)
    local textColor = self:getTextColor(bValue)
    widget:setTextColor(textColor)
end

function wnd_dengmi:setFinishState(image, text, bValue)
    self:setTextColor(text, bValue)
    self:setImage(image, bValue)
end


function wnd_create(layout, ...)
    local wnd = wnd_dengmi.new()
    wnd:create(layout, ...)
    return wnd
end
