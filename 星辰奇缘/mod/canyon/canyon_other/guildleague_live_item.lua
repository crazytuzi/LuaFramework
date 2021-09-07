
GuildLeagueLiveItem = GuildLeagueLiveItem or BaseClass()

function GuildLeagueLiveItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.data = nil
    self.index = 1

    self.parent = parent

    self.Item = self.transform
    self.bg = self.transform:Find("bg")
    self.Text = self.transform:Find("Text"):GetComponent(Text)
    self.Time = self.transform:Find("Time"):GetComponent(Text)
    self.LookButton = self.transform:Find("LookButton"):GetComponent(Button)
    self.strExt =  MsgItemExt.New(self.Text, 384)
    -- self.Text = self.transform("LookButton/Text"):GetComponent(Text)
    -- self.Image = self.transform("LookButton/Image"):GetComponent(Image)
    -- self.headbg = self.transform("headbg")
    self.head = self.transform:Find("headbg/head")
end


function GuildLeagueLiveItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueLiveItem:set_my_index(_index)
    self.index = _index

end

--更新内容
function GuildLeagueLiveItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    if _data == nil then return end
    self.strExt:SetData(_data.log_msg)
    local Hour = tonumber(os.date("%H", _data.log_time))
    local Min = tonumber(os.date("%M", _data.log_time))
    if Hour < 10 then
        Hour = "0"..tostring(Hour)
    end
    if Min < 10 then
        Min = "0"..tostring(Min)
    end
    self.Time.text = string.format("%s:%s", Hour, Min)
    -- self.Time.text = BaseUtils.formate_time_gap(BaseUtils.BASE_TIME - _data.log_time, ":", 0, BaseUtils.time_formate.MIN)
    -- self.Text.text = _data.log_msg
end