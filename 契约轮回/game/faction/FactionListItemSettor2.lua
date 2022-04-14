--
-- @Author: chk
-- @Date:   2018-12-24 16:57:19
--

FactionListItemSettor2 = FactionListItemSettor2 or class("FactionListItemSettor2",BaseItem)
local FactionListItemSettor2 = FactionListItemSettor2

function FactionListItemSettor2:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionListItem2"
	self.layer = layer

	self.bg = {}
	self.model = FactionModel:GetInstance()
	FactionListItemSettor2.super.Load(self)
end



function FactionListItemSettor2:dctor()
	
	self.bg = nil
end

function FactionListItemSettor2:LoadCallBack()
	self.nodes = {
		"bg_0",
		"bg_1",
		"rank_img",
		"rank_text",
		"name",
		"president",
		"lv",
		"number",
		"power",
		"fightLv",
	}
	self:GetChildren(self.nodes)
	self.bg[0] = self.bg_0
	self.bg[1] = self.bg_1

	self.fightLv = GetText(self.fightLv)
	self:AddEvent()

	self:UpdateItem()
end

function FactionListItemSettor2:AddEvent()


end

function FactionListItemSettor2:SetData(data,index)
	self.index = index
	self.data = data
	if self.is_loaded then
		self:UpdateItem()
	end
end
local desTab = {[0] = "No ratings",[1]= "Divine",[2]= "Holy",[3] = "Heaven",[4] = "Earth",[5] = "Mortal"}
function FactionListItemSettor2:UpdateItem()


	self.fightLv.text = desTab[self.data.ext.guild_war_field]
	--if not self.data.ext.guild_war_field or self.data.ext.guild_war_field == 0 then
	--	SetVisible(self.fightLvImg.gameObject,false)
	--	SetVisible(self.fightLv.gameObject,true)
	--	self.fightLv.text = "暂无评级"
	--else
	--	SetVisible(self.fightLvImg.gameObject,true)
	--	SetVisible(self.fightLv.gameObject,false)
	--	lua_resMgr:SetImageTexture(self,self.fightLvImg,"faction_image","faction_b_Rank" .. self.data.ext.guild_war_field,true)
	--end
	local rectTra = self.transform:GetComponent('RectTransform')
	if self.index % 2 == 0 then
		SetVisible(self.bg_0.gameObject,true)
		SetVisible(self.bg_1.gameObject,false)
	else
		SetVisible(self.bg_0.gameObject,false)
		SetVisible(self.bg_1.gameObject,true)
	end
	rectTra.anchoredPosition = Vector2(rectTra.anchoredPosition.x,-(self.index - 1) * rectTra.sizeDelta.y)
	if self.data.rank <= 3 then
		SetVisible(self.rank_img.gameObject,true)
		SetVisible(self.rank_text.gameObject,false)

		lua_resMgr:SetImageTexture(self,self.rank_img:GetComponent('Image'),"faction_image","faction_r_" .. self.data.rank,true)
	else
		SetVisible(self.rank_img.gameObject,false)
		SetVisible(self.rank_text.gameObject,true)

		self.rank_text:GetComponent('Text').text = self.data.rank .. ""
	end

	self.name:GetComponent('Text').text = self.data.name
	self.president:GetComponent('Text').text = self.data.chief .. ""
	self.lv:GetComponent('Text').text = self.data.level
	self.number:GetComponent('Text').text = self.data.num .. "/" .. Config.db_guild[self.data.level].memb
	self.power:GetComponent('Text').text = self.data.power .. ""
end
