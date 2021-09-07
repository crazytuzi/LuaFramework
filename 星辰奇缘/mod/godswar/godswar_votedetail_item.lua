-- ---------------------------------
-- 诸神之战投票选择元素
-- hosr
-- ---------------------------------
GodsWarVoteDetailItem = GodsWarVoteDetailItem or BaseClass()

function GodsWarVoteDetailItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarVoteDetailItem:__delete()
end

function GodsWarVoteDetailItem:InitPanel()
	self.transform = self.gameObject.transform

	self.select = self.transform:Find("Select").gameObject
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.desc = self.transform:Find("Desc"):GetComponent(Text)

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

-- {tuple, id, [
--         {uint32, tid, "战队ID,ID为0代表无公会"}
--         ,{string, platform, "平台标识"}
--         ,{uint16, zone_id, "区号"}
--     ]
-- }
-- ,{string, name, "战队名字"}
-- ,{uint32, voted_cnt, "投票数"}
function GodsWarVoteDetailItem:SetData(data)
	self.data = data
	if self.data == nil then
		return
	end
	self.name.text = self.data.name
	self.desc.text = BaseUtils.GetServerNameMerge(self.data.platform, self.data.zone_id)
end

function GodsWarVoteDetailItem:ClickSelf()
	if self.parent ~= nil then
		self.parent:Select(self)
	end
end

function GodsWarVoteDetailItem:Select(bool)
	self.select:SetActive(bool)
end