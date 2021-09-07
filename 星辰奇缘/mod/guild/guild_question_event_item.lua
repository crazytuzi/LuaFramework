GuildQuestionEventItem = GuildQuestionEventItem or BaseClass()

function GuildQuestionEventItem:__init(parent, originItem, data, index)


    self.args = args

    self.index = index
    self.gameObject = ctx:InstantiateAndSet(originItem.transform.parent.gameObject, originItem)
    self.gameObject:SetActive(true)
    self.bg = self.gameObject:GetComponent(Image)
    self.TxtCon = self.gameObject.transform:FindChild("TxtCon"):GetComponent(Text)
    self.ImgLook = self.gameObject.transform:FindChild("ImgLook").gameObject
    self.TxtAnswer = self.gameObject.transform:FindChild("TxtAnswer"):GetComponent(Text)
    self.TxtAnswer.gameObject:SetActive(false)
    self.ImgLook:SetActive(false)

    if index%2 == 0 then
        --偶数
        self.bg.color = ColorHelper.ListItem1
    else
        --单数
        self.bg.color = ColorHelper.ListItem2
    end

    self:set_event_item_data(data)
end

function GuildQuestionEventItem:Release()

end


function GuildQuestionEventItem:set_event_item_data(data)
    self.data = data

    local answer = "A"
    if self.data.option == 1 then
        answer = "A"
    elseif self.data.option == 2 then
        answer = "B"
    elseif self.data.option == 3 then
        answer = "C"
    elseif self.data.option == 4 then
        answer = "D"
    end

    local txt_str = ""
    if self.data.result == 0 then
        --错误
        txt_str = string.format("<color='#4dd52b'>%s</color>%s%s <color='#cc3333'>%s</color>", self.data.name, TI18N("的答案："), answer, TI18N("【错误】"))
    else
        --正确
        txt_str = string.format("%s<color='#4dd52b'>%s</color>%s", TI18N("恭喜"), self.data.name, TI18N("作答正确"))

        if self.data.rid == RoleManager.Instance.RoleData.id and self.data.platform == RoleManager.Instance.RoleData.platform and self.data.zone_id ==  RoleManager.Instance.RoleData.zone_id then
            self.ImgLook:SetActive(false)
            self.TxtAnswer.gameObject:SetActive(true)
            if self.data.option == 1 then
                self.TxtAnswer.text ="A"
            elseif self.data.option == 2 then
                self.TxtAnswer.text ="B"
            elseif self.data.option == 3 then
                self.TxtAnswer.text ="C"
            elseif self.data.option == 4 then
                self.TxtAnswer.text ="D"
            end
        else
            self.ImgLook:SetActive(true)
            utils.add_down_up_scale(self.ImgLook, "on_click_look_item")
        end
    end
    self.TxtCon.text = txt_str
end


function GuildQuestionEventItem:on_click_look_item(g)
    if self.has_answer_this_question == true then
        -- mod_notify.append_scroll_win(TI18N("你已经作答，无法查看答案"))
        return
    end
    if event_item_list == nil then
        return
    end
    if #event_item_list == 0 then
        return
    end
    for i=1,#event_item_list do
        local item = event_item_list[i]
        if item.ImgLook == g then

            if self.model.current_guild_question_data.cheat_num > 0 then
                local cost = self.model.current_guild_question_data.cheat_num*10000
                local str = string.format("%s%s%s", TI18N("消耗"), cost, TI18N("银币查看答案？"))
                local confirm_callback = function()
                    --发送消耗协议
                    GuildManager.Instance:request11152(item.data.rid, item.data.platform , item.data.zone_id)
                end

                mod_notify.open_confirm_win(str, TI18N("提示"), confirm_callback, 0, TI18N("确定"), TI18N("取消"), nil)
            else
                GuildManager.Instance:request11152(item.data.rid, item.data.platform , item.data.zone_id)
            end
            return
        end
    end
end