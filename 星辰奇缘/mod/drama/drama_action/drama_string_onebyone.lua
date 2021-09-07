-- -----------------------------
-- 字符串逐字出现
-- -----------------------------
DramaOneByOne = DramaOneByOne or BaseClass()

function DramaOneByOne:__init(callback)
    self.timeId = 0
    self.content = ""
    self.callback = callback
    self.update = nil
    self.stringTab = {}
    self.step = 0
    self.result = ""
    self.text = nil
end

function DramaOneByOne:__delete()
    LuaTimer.Delete(self.timeId)
    self.timeId = 0
end

function DramaOneByOne:Show(text, str)
    self.content = str
    self.step = 0
    self.result = ""
    self.text = text
    self.stringTab = StringHelper.ConvertStringTable(str)
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.timeId = LuaTimer.Add(0, 10, function() self:Begin() end)
end

function DramaOneByOne:Begin()
    self.step = self.step + 1
    if self.step <= #self.stringTab then
        self.result = self.result .. self.stringTab[self.step]
        self.text.text = self.result
    else
        self:End()
    end
end

function DramaOneByOne:End()
    LuaTimer.Delete(self.timeId)
    self.timeId = 0
    self.text.text = self.content
    if self.callback ~= nil then
        self.callback()
    end
end