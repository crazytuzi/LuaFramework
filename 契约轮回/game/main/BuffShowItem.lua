--
-- @Author: LaoY
-- @Date:   2018-11-24 15:52:17
--
BuffShowItem = BuffShowItem or class("BuffShowItem", BaseCloneItem)
local BuffShowItem = BuffShowItem

function BuffShowItem:ctor(obj, parent_node, layer)
    BuffShowItem.super.Load(self)
end

function BuffShowItem:dctor()
    self:StopTime()
end

function BuffShowItem:LoadCallBack()
    self.nodes = {
        "img_bg/text_name", "img_bg/img_icon", "img_bg/text_time", "img_bg/text_des",
        "img_bg/img_icon/text_num",
    }
    self:GetChildren(self.nodes)
    self.img_icon_component = self.img_icon:GetComponent('Image')

    self.text_num_component = self.text_num:GetComponent('Text')
    self.text_num_component.text = ""

    self.text_name_component = self.text_name:GetComponent('Text')
    self.text_time_component = self.text_time:GetComponent('Text')
    self.text_des_component = self.text_des:GetComponent('Text')
    self:AddEvent()
end

function BuffShowItem:AddEvent()
end

function BuffShowItem:SetData(data)
    self.data = data
    if not self.data then
        return
    end
    self.config = Config.db_buff[self.data.id]
    if self.config then
        self:SetRes(self.config.icon)
    end
    self:SetInfo()
    self:StartTime()
end

function BuffShowItem:SetInfo()
    if not self.config then
        return
    end

    if self.config.add_time == 1 then
        self.text_num_component.text = self.data.value
    else
        self.text_num_component.text = ""
    end

    self.text_name_component.text = self.config.name
    self.text_des_component.text = self.config.desc
    local item_height = self:GetItemHeight()
    SetSizeDeltaY(self.transform, item_height)
end

function BuffShowItem:StartTime()
    self:StopTime()
    local function step()
        local last_time = self.data.etime - os.time()
        local str = ""
        if last_time <= 0 then
            if self.data.etime == 0 then
                str = "Always valid"
            else
                str = "Invalid"
            end
            self:StopTime()
        else
            local last_time_data = TimeManager:GetLastTimeData(os.time(), self.data.etime)
            if last_time_data.day then
                str = string.format("%dday%0dh%02dmin%02dsec", last_time_data.day, last_time_data.hour, last_time_data.min, last_time_data.sec)
            elseif last_time_data.hour then
                str = string.format("%0dh%02dmin%02dsec", last_time_data.hour, last_time_data.min, last_time_data.sec)
            elseif last_time_data.min then
                str = string.format("%02dmin%02dsec", last_time_data.min, last_time_data.sec)
            else
                str = string.format("%d sec", last_time_data.sec)
            end
        end
        self.text_time_component.text = str
    end
    self.time_id = GlobalSchedule:Start(step, 1.0)
    step()
end

function BuffShowItem:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
end

function BuffShowItem:SetRes(res)
    if self.res == res then
        return
    end
    self.res = res
    lua_resMgr:SetImageTexture(self, self.img_icon_component, "iconasset/icon_leftbig", tostring(res), true)
end

function BuffShowItem:GetItemHeight()
    return 102
end