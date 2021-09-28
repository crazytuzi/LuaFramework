RankItem = BaseClass(LuaUI)

RankItem.CurSelectItem = nil
function RankItem:__init(...)
	self.URL = "ui://7dvfcqznjg8tm";
	self:__property(...)
	self:Config()
end

function RankItem:SetProperty(...)
	
end

function RankItem:Config()
	
end

function RankItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Rank","RankItem");

	self.line = self.ui:GetChild("line") 
	self.select = self.ui:GetChild("select") 

	self.cellWidth = 820
	self.cellheight = 44
	self.colRankList = {}
	self.colNormalList = {}
	self.colCareerList = {}

	self:AddEvent()
	self:UnSelect()
end

function RankItem.Create(ui, ...)
	return RankItem.New(ui, "#", {...})
end

function RankItem:AddEvent()
	self.ui.onClick:Add(self.OnRankItemClickHandler, self)
end

function RankItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnRankItemClickHandler, self)
end

function RankItem:OnRankItemClickHandler(context)
	if RankItem.CurSelectItem then
		RankItem.CurSelectItem:UnSelect()
	end
	self:Select()


	if SceneModel:GetInstance():GetMainPlayer().playerId == self.data.playerId then
		return
	end

	if not self.data then return end
	local data = {}
	data.playerId = self.data.playerId
	data.funcIds = {PlayerFunBtn.Type.AddFriend, PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.InviteTeam, PlayerFunBtn.Type.CheckPlayerInfo}
	GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
end

function RankItem:Select()
	RankItem.CurSelectItem = self
	self.select.visible = true
end

function RankItem:UnSelect()
	self.select.visible = false
end

function RankItem:Refresh(data, cols)
	self.data = data
	self.cols = cols

	self:Update()
end

function RankItem:Update()
	self:Reset()
	local colWidth = self.cellWidth / #self.cols
	local x = 0
	for i = 1, #self.cols do
		local property = RankModel:GetInstance():GetMappingProperty(self.cols[i])
		local value = self.data[property]
		local col = nil
		if self.cols[i] == 1 then --排名
			col = self:GetColRankFromPool()
			local rank = col:GetChild("rank")
			local rankImg = col:GetChild("rankImg")
			rank.visible = false
			if value == 1 or value == 2 or value == 3 then
				rankImg.url = UIPackage.GetItemURL("Rank" , value)
			else
				rankImg.url = ""
				rank.visible = true
				rank.text = value
			end
		elseif self.cols[i] == 3 then --职业
			col = self:GetColCareerFromPool()
			local careerMark = col:GetChild("careerMark")
			local career = col:GetChild("career")
			careerMark.url = RankConst.CareerMark[value]
			career.text = GetCfgData("newroleDefaultvalue"):Get(value).careerName
		else --文本
			col = self:GetColNormalFromPool()
			local name = col:GetChild("name")
			name.text = value
		end
		col.width = colWidth
		col.x = x
		self.ui:AddChild(col)
		x = x + colWidth
	end
end

function RankItem:Reset()
	for i = 1, #self.colRankList do
		self.ui:RemoveChild(self.colRankList[i])
	end
	for i = 1, #self.colNormalList do
		self.ui:RemoveChild(self.colNormalList[i])
	end
	for i = 1, #self.colCareerList do
		self.ui:RemoveChild(self.colCareerList[i])
	end
	self:UnSelect()
end

function RankItem:GetColRankFromPool()
	for i = 1, #self.colRankList do
		if self.colRankList[i].parent == nil then
			return self.colRankList[i]
		end
	end
	local item = UIPackage.CreateObject("Rank", "RankColRank")
	table.insert(self.colRankList, item)
	return item
end

function RankItem:DestoryColRankPool()
	for i = 1, #self.colRankList do
		destroyUI(self.colRankList[i])
	end
	self.colRankList = nil
end

function RankItem:GetColNormalFromPool()
	for i = 1, #self.colNormalList do
		if self.colNormalList[i].parent == nil then
			return self.colNormalList[i]
		end
	end
	local item = UIPackage.CreateObject("Rank", "RankColNormal")
	table.insert(self.colNormalList, item)
	return item
end

function RankItem:DestoryColNormalPool()
	for i = 1, #self.colNormalList do
		destroyUI(self.colNormalList[i])
	end
	self.colNormalList = nil
end

function RankItem:GetColCareerFromPool()
	for i = 1, #self.colCareerList do
		if self.colCareerList[i].parent == nil then
			return self.colCareerList[i]
		end
	end
	local item = UIPackage.CreateObject("Rank", "RankColCareer")
	table.insert(self.colCareerList, item)
	return item
end

function RankItem:DestoryColNamePool()
	for i = 1, #self.colCareerList do
		destroyUI(self.colCareerList[i])
	end
	self.colCareerList = nil
end

function RankItem:__delete()
	self:RemoveEvent()

	self:DestoryColRankPool()
	self:DestoryColNormalPool()
	self:DestoryColNamePool()
end