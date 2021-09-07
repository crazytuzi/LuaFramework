-- ---------------------------------
-- 诸神之战 活动时间展示 单元
-- hosr
-- ---------------------------------
GodsWarArrangeItem = GodsWarArrangeItem or BaseClass()

function GodsWarArrangeItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.width = 200
	self.height = 0
	self:InitPanel()
end

function GodsWarArrangeItem:__delete()
end

function GodsWarArrangeItem:InitPanel()
	self.transform = self.gameObject.transform
	self.rect = self.transform:GetComponent(RectTransform)

	self.icon = self.transform:Find("Icon"):GetComponent(Image)
	self.title = self.transform:Find("Title"):GetComponent(Text)
	self.content = self.transform:Find("Content"):GetComponent(Text)
	self.content.horizontalOverflow = 1
	self.content.verticalOverflow = 1
	self.contentRect = self.transform:Find("Content"):GetComponent(RectTransform)
	self.select = self.transform:Find("Select").gameObject
end

-- {type = 1, start_time = {{2016,10,26,0,0,0}}, end_time = {{2016,10,26,23,59,59}}},
function GodsWarArrangeItem:SetData(data)
	self.title.text = GodsWarEumn.StepName[data.state_code]
	local start_Month = os.date("%m",data.start_time)
	local start_Day = os.date("%d",data.start_time)
	local start_Hour = os.date("%H",data.start_time)
	local start_Min = os.date("%M",data.start_time)

	local end_Month = os.date("%m",data.end_time)
	local end_Day = os.date("%d",data.end_time)
	local end_Hour = os.date("%H",data.end_time)
	local end_Min = os.date("%M",data.end_time)

	-- local start_Day =
	local str = ""
	local start_time = data.start_time
	local end_time = data.end_time
	if data.state_code <= 3 then
		str = string.format("%s月%s日-%s月%s日\n%s:%s-%s:%s", GodsWarEumn.Format(start_Month), GodsWarEumn.Format(start_Day), GodsWarEumn.Format(end_Month), GodsWarEumn.Format(end_Day), GodsWarEumn.Format(start_Hour), GodsWarEumn.Format(start_Min), GodsWarEumn.Format(end_Hour), GodsWarEumn.Format(end_Min))
	else
		str = string.format("%s月%s日 %s:%s-%s:%s", GodsWarEumn.Format(start_Month), GodsWarEumn.Format(start_Day), GodsWarEumn.Format(start_Hour), GodsWarEumn.Format(start_Min), GodsWarEumn.Format(end_Hour), GodsWarEumn.Format(end_Min))
	end
	self.content.text = str

	self.height = self.content.preferredHeight
	self.contentRect.sizeDelta = Vector2(self.width, self.height)
	self.height = self.height + 35
	self.rect.sizeDelta = Vector2(210, self.height)
	self.gameObject:SetActive(true)
end

function GodsWarArrangeItem:Select(bool)
	self.select:SetActive(bool)
end