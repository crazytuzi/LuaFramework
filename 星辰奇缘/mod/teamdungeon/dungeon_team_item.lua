-- 组队副本单个队伍
-- ljh 20160620
DungeonTeamItem = DungeonTeamItem or BaseClass()

function DungeonTeamItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.index = _index

    self.headSlot = HeadSlot.New()
	self.headSlot:SetRectParent(self.transform:FindChild("LeaderHead"))
	
	self.leaderName = self.transform:FindChild("LeaderName"):GetComponent(Text)

	self.memberHeadList = {}
	for memberIndex = 1, 4 do 
		table.insert(self.memberHeadList, self.transform:FindChild(string.format("Member%s/Image", memberIndex)).gameObject)
	end

    local btn = nil
    btn = self.transform:Find("Button"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self.parent:OnJionButtonClick(self.index) end)
end

--设置
function DungeonTeamItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function DungeonTeamItem:Release()
end

function DungeonTeamItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function DungeonTeamItem:update_my_self(_data, _index)
	local data = _data
	self.index = _index
	self.gameObject.name = tostring(_index)
	
	data.id = data.rid
    self.headSlot:SetAll(data, {isSmall = true})

    self.leaderName.text = data.name

    for memberIndex = 1, 4 do 
		if memberIndex < data.member_num then
			self.memberHeadList[memberIndex]:SetActive(true)
		else
			self.memberHeadList[memberIndex]:SetActive(false)
		end
	end
end

function DungeonTeamItem:Refresh(args)
    
end
