--
-- @Author: chk
-- @Date:   2018-12-16 19:40:55
--
FactionMessagePanel = FactionMessagePanel or class("FactionMessagePanel",WindowPanel)
local FactionMessagePanel = FactionMessagePanel

function FactionMessagePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionMessagePanel"
	self.layer = "UI"

	self.panel_type = 5
	self.itemSettors = {}
	self.model = FactionModel.GetInstance()
end

function FactionMessagePanel:dctor()
	for i, v in pairs(self.itemSettors) do
		v:destroy()
	end
end

function FactionMessagePanel:Open( data)
	self.data = data
	FactionMessagePanel.super.Open(self)
end

function FactionMessagePanel:LoadCallBack()
	self.nodes = {
		"info/name/nameValue",
		"info/lv/lvValue",
		"info/rank/rankValue",
		"info/fightRank/fightRankValue",
		"info/president/presidentValue",
		"info/power/powerValue",
		"member/Scroll View/Viewport/Content",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()

	self:SetTileTextImage("faction_image","faction_m_f",true)
end

function FactionMessagePanel:AddEvent()

end

function FactionMessagePanel:OpenCallBack()
	self:UpdateView()
end

function FactionMessagePanel:UpdateView( )

	self.nameValue:GetComponent('Text').text = self.data.name
	self.lvValue:GetComponent('Text').text = self.data.level .. ""
	self.rankValue:GetComponent('Text').text = self.data.rank .. ""
	self.fightRankValue:GetComponent('Text').text = ""
	self.presidentValue:GetComponent('Text').text = self.model:GetCareerByType(self.data.members,
			enum.GUILD_POST.GUILD_POST_CHIEF)[1].base.name
	self.powerValue:GetComponent('Text').text = self.data.power .. ""
	local careers = self.model:GetCareers(self.data.members)
	local function call_back (c1,c2)
		if c1 ~= nil and c2 ~= nil then
			return c1.post > c2.post
		end
	end
	table.sort(careers,call_back)
	local index = 1
	for i, v in pairs(careers) do
		self.itemSettors[#self.itemSettors+1] = FactionMessageItemSettor(self.Content)
		self.itemSettors[#self.itemSettors]:UpdateItem(v,index)
		index = index + 1
	end
end

function FactionMessagePanel:CloseCallBack(  )

end