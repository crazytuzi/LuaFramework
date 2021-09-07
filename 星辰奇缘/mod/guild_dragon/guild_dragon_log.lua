-- @author 黄耀聪
-- @date 2017年11月14日, 星期二

GuildDragonLog = GuildDragonLog or BaseClass()

function GuildDragonLog:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.bgImage = t:Find("Bg"):GetComponent(Image)
    self.text = MsgItemExt.New(t:Find("Text"):GetComponent(Text), 300, 16, 21.89)
end

function GuildDragonLog:__delete()
    if self.text ~= nil then
        self.text:DeleteMe()
        self.text = nil
    end
    self.gameObject = nil
    self.model = nil
end

function GuildDragonLog:update_my_self(data, index)
    self.text:SetData(data.msg)
    self.text.contentTrans.anchoredPosition = Vector2(42, self.text.contentTrans.sizeDelta.y / 2)
end

function GuildDragonLog:SetData(data, index)
    self:update_my_self(data, index)
end

function GuildDragonLog:SetActive(bool)
    self.gameObject:SetActive(bool)
end


