-- 
-- @Author: LaoY
-- @Date:   2018-08-20 11:18:25
-- 
DialogPanel = DialogPanel or class("DialogPanel", BasePanel)
local DialogPanel = DialogPanel

function DialogPanel:ctor()
    self.abName = "system"
    self.assetName = "DialogPanel"
    self.layer = "Top"

    self.is_show_open_action = true
    self.use_background = true
    self.change_scene_close = false
    self.is_singleton = true
end

function DialogPanel:dctor()
end

function DialogPanel:Open(data)
    self.data = data
    if not data then
        return
    end
    DialogPanel.super.Open(self)
end

function DialogPanel:Close()
    self.cancel_text_component.text = "Cancel"
    self.sure_text_component.text = "Confirm"

    self.isShow = false
    self:StopTime()
    self:SetVisible(false)
end

function DialogPanel:LoadCallBack()
    self.nodes = {
        "title", "content", "sure_btn", "sure_btn/sure_text", "cancel_btn", "cancel_btn/cancel_text", "auto_text", "btn_close",
        "saveTog", "saveTog/Label", --"saveTog/Background/Checkmark","saveTog/Background",
        "img_bg_3", "bg_1", "bg_1/bg_one_Text", "centerContent", "cd_con", "cd_con/countdowntext",
    }
    self:GetChildren(self.nodes)
    self.title_text_component = self.title:GetComponent('Text')
    self.content_text_component = self.content:GetComponent('Text')
    self.centerContent_text_component = self.centerContent:GetComponent('Text')
    self.sure_text_component = self.sure_text:GetComponent('Text')
    self.cancel_text_component = self.cancel_text:GetComponent('Text')
    self.auto_text_component = self.auto_text:GetComponent('Text')
    self.content_text_rect = self.content:GetComponent('RectTransform')
    self.img_bg_3_rect = self.img_bg_3:GetComponent('RectTransform')
    self.saveTog = GetToggle(self.saveTog);
    self.saveTog.gameObject:SetActive(false);
    self.tog_rect = GetRectTransform(self.saveTog)
    self.cd_text = GetText(self.countdowntext)

    --SetVisible(self.btn_close, false)
    self.Label_component = self.Label:GetComponent('Text')
    self:AddEvent()
end

function DialogPanel:AddEvent()
    local function call_back(target, x, y)
        self:SureCallBack()
    end
    AddClickEvent(self.sure_btn.gameObject, call_back)

    local function call_back(target, x, y)
        self:CancelCallBack()
    end
    AddClickEvent(self.cancel_btn.gameObject, call_back)

    local function call_back(target, x, y)
        self:Close()
        if self.data.close_func then
            self.data.close_func()
        end
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
end

function DialogPanel:SureCallBack()
    if self.data.message_lst then
        local msg = table.remove(self.data.message_lst, 1)
        if msg ~= nil then
            if self.data.isLoacteCenterLeft then
                self.centerContent_text_component.text = msg
            else
                self.content_text_component.text = msg
                if self.content_text_component.preferredHeight < 136 and not self.data.isCheck then
                    self.img_bg_3_rect.sizeDelta = Vector2(self.img_bg_3_rect.sizeDelta.x, 196)
                end
            end
            self.title_text_component.text = table.remove(self.data.title_str_lst, 1) or ConfigLanguage.Mix.Tips
            return
        else
            self:Close()
            if self.data.ok_func then
                self.data.ok_func()
            end
        end
    elseif self.data.ok_func then
        self:Close()
        if self.data and self.data.isCheck then
            self.data.ok_func(self.saveTog.isOn)
        else
            self.data.ok_func()
        end
    else
        self:Close()
    end
end

function DialogPanel:CancelCallBack()
    self:Close()
    if self.data.cancel_func then
        self.data.cancel_func()
    end
end

function DialogPanel:OpenCallBack()
    self:UpdateView()
end

function DialogPanel:UpdateView()
    if not self.data then
        self:Close()
        return
    end
    self:StopTime()

    if self.data.dialog_type == Dialog.Type.One then

        SetLocalPositionX(self.sure_btn, 0)
        SetVisible(self.cancel_btn, false)
    elseif self.data.dialog_type == Dialog.Type.Two then
        SetLocalPositionX(self.sure_btn, 100)
        SetLocalPositionX(self.cancel_btn, -100)
        SetVisible(self.cancel_btn, true)
    elseif self.data.dialog_type == Dialog.Type.ShowBGOne then
        SetVisible(self.img_bg_3.gameObject, false)
        SetVisible(self.bg_1.gameObject, true)
        SetVisible(self.content.gameObject, true)
    end
    if self.data.isLoacteCenterLeft then
        SetVisible(self.content.gameObject, false)
        SetVisible(self.centerContent.gameObject, true)
    else
        SetVisible(self.content.gameObject, true)
        SetVisible(self.centerContent.gameObject, false)
    end
    if self.data.title_str then
        self.title_text_component.text = self.data.title_str
    end
    if self.data.message then
        if self.data.isLoacteCenterLeft then
            self.centerContent_text_component.text = self.data.message
        else
            self.content_text_component.text = self.data.message
            if self.content_text_component.preferredHeight < 136 and not self.data.isCheck then
                self.img_bg_3_rect.sizeDelta = Vector2(self.img_bg_3_rect.sizeDelta.x, 196)
            end
        end
    elseif self.data.message_lst then
        self.content_text_component.text = table.remove(self.data.message_lst, 1)
        self.title_text_component.text = table.remove(self.data.title_str_lst, 1)

        if self.content_text_component.preferredHeight < 136 and not self.data.isCheck then
            self.img_bg_3_rect.sizeDelta = Vector2(self.img_bg_3_rect.sizeDelta.x, 196)
        end
    elseif self.data.bg_one_message then
        self.bg_one_Text.GetComponent('Text').text = self.data.bg_one_message
    end

    if self.data.ok_str then
        self.sure_text_component.text = self.data.ok_str
    end
    if self.data.cancel_str then
        self.cancel_text_component.text = self.data.cancel_str
    end

    if self.data.isCheck then
        self.saveTog.gameObject:SetActive(true);
        -- self.content_text_rect.anchoredPosition = Vector2(self.content_text_rect.anchoredPosition.x,54.4)
        if self.data.checkText then
            self.Label_component.text = self.data.checkText;
        end
        if self.data.isNeedOn == false then
            self.saveTog.isOn = false
        else
            self.saveTog.isOn = true
        end

        self.content_text_rect.anchoredPosition = Vector2(self.content_text_rect.anchoredPosition.x, 27)
    else

        if self.data.dialog_type == Dialog.Type.One then
            SetAnchoredPosition(self.content_text_rect, self.content_text_rect.anchoredPosition.x, 4.6)
        else
            self.content_text_rect.anchoredPosition = Vector2(self.content_text_rect.anchoredPosition.x, 5)
        end

        self.saveTog.gameObject:SetActive(false);
    end

    SetVisible(self.auto_text, false)
    if not self.time_id and self.data.ok_time then
        SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.ok_time - os.time()
            local str = string.format("In %s sec, auto %s", last_time, self.data.ok_str or "Confirm")
            self.auto_text_component.text = str
            if last_time <= 0 then
                self:StopTime()
                self:SureCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end

    if not self.time_id and self.data.cancel_time then
        SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.cancel_time - os.time()
            local str = string.format("In %s sec, auto %s", last_time, self.data.cancel_str or "Cancel")
            self.auto_text_component.text = str
            if last_time <= 0 then
                self:StopTime()
                self:CancelCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end

    if self.data.content_Data then
        if self.data.content_Data.pos then
            self:SetContentPos(self.data.content_Data.pos[1], self.data.content_Data.pos[2])
        end
        if self.data.content_Data.size then
            self:SetContentSizeDelta(self.data.content_Data.size[1], self.data.content_Data.size[2])
        end
    end
    if self.data.toggle_Data then
        self:SetTogglePos(self.data.toggle_Data[1], self.data.toggle_Data[2])
    end

    if self.data.cd_data and (not table.isempty(self.data.cd_data)) then
        if not self.CDT then
            self.CDT = CountDownText(self.cd_con, self.data.cd_data)
        end
        local function end_call()
            if self.data.cd_data.show_str_after_end then
                SetVisible(self.cd_con, true)
                self.cd_text.text = self.data.cd_data.show_str_after_end
            else
                SetVisible(self.cd_con, false)
            end
        end
        if not self.data.cd_data.end_time then
            logError("end_time is nil")
            return
        end
        self.CDT:StartSechudle(self.data.cd_data.end_time, end_call)
        SetVisible(self.cd_con, true)
    else
        if self.CDT then
            SetVisible(self.cd_con, false)
            self.CDT:StopSchedule()
        end
    end
end

function DialogPanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function DialogPanel:SetContentPos(x, y)
    SetAnchoredPosition(self.content_text_rect, x, y)
end

function DialogPanel:SetContentSizeDelta(width, height)
    SetSizeDelta(self.content_text_rect, width, height)
end

function DialogPanel:SetTogglePos(x, y)
    SetAnchoredPosition(self.tog_rect, x, y)
end

function DialogPanel:CloseCallBack()
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
end