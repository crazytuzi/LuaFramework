FriendlyTipsPanel = FriendlyTipsPanel or class("FriendlyTipsPanel",BasePanel)
local FriendlyTipsPanel = FriendlyTipsPanel

function FriendlyTipsPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "FriendlyTipsPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.model = FriendModel:GetInstance()

	self.item_list = {}
	self.item_list2 = {}
end

function FriendlyTipsPanel:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	for i=1, #self.item_list2 do
		self.item_list[i]:destroy()
	end
end

function FriendlyTipsPanel:Open( )
	FriendlyTipsPanel.super.Open(self)
end

function FriendlyTipsPanel:LoadCallBack()
	self.nodes = {
		"content","content/FriendlyTipItem", "lefttips/btitle","lefttips/bicon","lefttips/blevel_title/blevel",
		"lefttips/bintimacy_title/bintimacy","lefttips/bcontent/TipAttribItem","lefttips","lefttips/bcontent",
	}
	self:GetChildren(self.nodes)
	self.bicon = GetImage(self.bicon)
	self.btitle = GetText(self.btitle)
	self.blevel = GetText(self.blevel)
	self.bintimacy = GetText(self.bintimacy)

	self.FriendlyTipItem_gameobject = self.FriendlyTipItem.gameObject
	self.TipAttribItem_gameobject = self.TipAttribItem.gameObject
	self:AddEvent()
end

function FriendlyTipsPanel:AddEvent()

end

function FriendlyTipsPanel:OpenCallBack()
	self:UpdateView()
end

function FriendlyTipsPanel:UpdateView( )
	SetVisible(self.FriendlyTipItem, false)
	for i=1, #Config.db_flower_honey do
		local item = FriendlyTipItem(self.FriendlyTipItem_gameobject, self.content)
		item:SetData(Config.db_flower_honey[i].level)
		self.item_list[i] = item
	end
	self:UpdateBuff()
end

function FriendlyTipsPanel:CloseCallBack(  )

end

--data:role_id
function FriendlyTipsPanel:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateBuff()
	end
end

function FriendlyTipsPanel:UpdateBuff()
	SetVisible(self.TipAttribItem, false)
	local pfriend = self.model:GetPFriend(self.data)
	local buff_id = self:GetFriendValuebuff(pfriend.intimacy)
	local buff = Config.db_buff[buff_id]
	if buff then
		self.btitle.text = buff.name
		self.blevel.text = buff.level
		self.bintimacy.text = pfriend.intimacy
		lua_resMgr:SetImageTexture(self,self.bicon, 'iconasset/icon_skill', buff.icon,true)
		local attribs = String2Table(buff.attrs)
		for i=1, #attribs do
			local item = TipAttribItem(self.TipAttribItem_gameobject, self.bcontent)
			item:SetData(attribs[i])
			self.item_list2[i] = item
		end
	end
end

function FriendlyTipsPanel:GetFriendValuebuff(intimacy)
    local buff = 1
	for i=1, #Config.db_flower_honey do
		local intimacy_item = Config.db_flower_honey[i]
		if intimacy >= intimacy_item.honey then
			buff = intimacy_item.buff
		end
	end
	return buff
end
