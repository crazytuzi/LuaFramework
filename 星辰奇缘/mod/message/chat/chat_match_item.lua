-- ------------------------
-- 聊天匹配项
-- hosr
-- ------------------------
ChatMatchItem = ChatMatchItem or BaseClass(MsgItem)

function ChatMatchItem:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.container

    self.data = nil

    self.selfWidth = 340
    self.selfHeight = 80

    self.needDelete = false

    self:InitPanel()
end

function ChatMatchItem:__delete()
    self.mainPanel = nil
    self.parent = nil
    self.data = nil
    self.selfWidth = nil
    self.selfHeight = nil
    self.needDelete = nil

    self.transform = nil
    self.rect = nil
    self.label = nil
    self.button = nil
    self.slider = nil
    self.valueTxt = nil
end

function ChatMatchItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self.mainPanel.baseMatchItem)
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatMatchItem"
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2.zero
    self.transform.localPosition = Vector3.zero

    self.label = self.transform:Find("Label"):GetComponent(Text)
    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:ClickButton() end)
    self.slider = self.transform:Find("Slider"):GetComponent(Slider)
    self.slider.value = 0
    self.valueTxt = self.transform:Find("Value"):GetComponent(Text)
    self.valueTxt.text = "0/5"
    self.gameObject:SetActive(false)
end

function ChatMatchItem:ClickButton()
    if self.data ~= nil then
        TeamManager.Instance:JoinRecruitTeam(self.data.rid, self.data.platform, self.data.zone_id)
        -- TeamManager.Instance:Send11724(self.data.rid, self.data.platform, self.data.zone_id)
    end
end

function ChatMatchItem:Reset()
    self.label.text = ""
    self.slider.value = 0
    self.valueTxt.text = "0/5"
    self.selfWidth = 340
    self.selfHeight = 80
    self.needDelete = false
    self.rect.anchoredPosition = Vector3.zero
end

function ChatMatchItem:SetData(data)
    self.showType = data.showType
    self.data = data.extraData
    self.label.text = data.msgData.showString
    self.slider.value = data.extraData.member_num
    self.valueTxt.text = string.format("%s/%s", data.extraData.member_num, self.data.member_max)
    self.gameObject:SetActive(true)
    self.selfWidth = 340
    self.selfHeight = 80
end