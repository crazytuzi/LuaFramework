-- 真心话 单项题目
-- ljh
TruthordareQuestionsItem = TruthordareQuestionsItem or BaseClass()

function TruthordareQuestionsItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.text = self.gameObject.transform:FindChild("Text"):GetComponent(Text)
    self.textExt = MsgItemExt.New(self.text, 265, 16, 22)
    self.button = self.gameObject.transform:FindChild("Button").gameObject
    self.buttonText = self.gameObject.transform:FindChild("Button/Text"):GetComponent(Text)
	self.toggle = self.gameObject.transform:FindChild("Toggle"):GetComponent(Toggle)

    local btn = nil
    btn = self.button:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self.parent:OnItemButtonClick(self.gameObject) end)

    self.toggle.onValueChanged:RemoveAllListeners()
    self.toggle.onValueChanged:AddListener(function(on) self.parent:OnItemToggleChange(self.gameObject, on) end)
end

--设置
function TruthordareQuestionsItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function TruthordareQuestionsItem:Release()
end

function TruthordareQuestionsItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function TruthordareQuestionsItem:update_my_self(_data, _index)
	local data = _data
	self.gameObject.name = tostring(data.id)

    -- self.text.text = data.question
    local strResult = self.model:GetQuestionsText(data.question)
    self.textExt:SetData(strResult)
    self.toggle.isOn = (data.is_choose == 1)
    self.button:SetActive(data.role_name ~= "")
    self.buttonText.text = string.format("<color='#25EEF6'>%s</color>出题", data.role_name)
end

function TruthordareQuestionsItem:Refresh(args)
    
end
