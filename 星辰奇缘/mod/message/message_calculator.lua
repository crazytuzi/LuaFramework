-- ----------------------------------------------------
-- 文字宽度计算器
-- 平时都很常用的，用来实时的取文本宽度的
-- 这里巧妙的用来获取从标签取出来的文本的实际宽度
-- 很简单的一个方法,别被吓到了~~
-- hosr
-- ----------------------------------------------------
MessageCalculator = MessageCalculator or BaseClass()

function MessageCalculator:__init(gameObject)
    self.gameObject = gameObject
    self.magicText = self.gameObject:GetComponent(Text)
    self.magicText.fontSize = 17
    self.magicText.lineSpacing = 1
    self.gameObject:SetActive(true)
end

function MessageCalculator:SimpleGetWidth(str)
    self.magicText.text = str
    return math.ceil(self.magicText.preferredWidth)
end

function MessageCalculator:ChangeFoneSize(fontSize)
    self.magicText.fontSize = fontSize
end

function MessageCalculator:LineSpace(fontSize, lineSpacing)
    self.magicText.fontSize = fontSize
    self.magicText.lineSpacing = lineSpacing
    self.magicText.text = ""
    return self.magicText.preferredHeight
end