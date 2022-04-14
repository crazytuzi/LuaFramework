GuildAnswerItem = GuildAnswerItem or class("GuildAnswerItem",BaseCloneItem)
local GuildAnswerItem = GuildAnswerItem


function GuildAnswerItem:ctor(obj,parent_node,layer)
	GuildAnswerItem.super.Load(self)
end

function GuildAnswerItem:dctor()
	for i=1, #self.events do
		self.model:RemoveListener(self.events[i])
	end
end

function GuildAnswerItem:LoadCallBack()
	self.nodes = {
		"index", "answer","bg","selected","right","wrong"
	}
	self:GetChildren(self.nodes)
	self.index = GetText(self.index)
	self.answer = GetText(self.answer)
	self.model = GuildHouseModel.GetInstance()
	self.events = {}
	self:AddEvent()
	self:UpdateView()
end

function GuildAnswerItem:AddEvent()
	local function call_back(target,x,y)
		self.model:Brocast(GuildHouseEvent.AnswerClick, self.data[1])
	end
	AddClickEvent(self.bg.gameObject,call_back)

	local function call_back(index)
		SetVisible(self.selected, self.data[1]==index)
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.AnswerClick, call_back)

	local function call_back(data)
		--[[if data.answer == self.data[1] then
			if data.is_right then
				SetVisible(self.right, true)
				SetVisible(self.wrong, false)
			else
				SetVisible(self.right, false)
				SetVisible(self.wrong, true)
			end
		end--]]
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.AnswerEvent, call_back)

	local function call_back()
		if tonumber(self.data[1]) == tonumber(self.answer_id) then 
			SetVisible(self.right, true)
			SetVisible(self.wrong, false)
		else
			SetVisible(self.right, false)
			SetVisible(self.wrong, true)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.QuestionEnd, call_back)
end

--data:{index, 内容}
function GuildAnswerItem:SetData(data, answer)
	self.answer_id = answer
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function GuildAnswerItem:UpdateView()
	if self.data then
		self.index.text = self.model:AnswerIndexToLetter(tonumber(self.data[1]))
		self.answer.text = self.data[2]
		SetVisible(self.selected, false)
		SetVisible(self.right, false)
		SetVisible(self.wrong, false)
	end
end