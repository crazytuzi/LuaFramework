--
-- @Author: LaoY
-- @Date:   2021-11-17 20:25:02
--

NftPayItem = NftPayItem or class("NftPayItem",BaseCloneItem)

function NftPayItem:ctor(obj,parent_node,layer)
	NftPayItem.super.Load(self)
end

function NftPayItem:dctor()
end

function NftPayItem:LoadCallBack()
	self.nodes = {
		"img_icon",
		"txt_name","txt_count",
	}
	self:GetChildren(self.nodes)

	self.m_NftPayItem = GetImage(self)
	self.m_img_icon = GetImage(self.img_icon)

	self.m_txt_name = GetText(self.txt_name)
	self.m_txt_count = GetText(self.txt_count)

	self:AddEvent()
end

function NftPayItem:AddEvent()
	local function call_back(target,x,y)
		if self.m_CallBack then
			self.m_CallBack(self.m_Index)
		end
	end
	AddClickEvent(self.gameObject,call_back)
end

function NftPayItem:SetCallBack(call_back)
	self.m_CallBack = call_back
end

function NftPayItem:SetData(index)
	self.m_Index = index
	local name = self.m_Index == 1 and "JOJO" or "BNB"
	self.m_txt_name.text = name


	local num = index * 100000
	local countStr = GetShowNumber(num)
	self.m_txt_count.text = countStr

	self:UpdateIcon()
end

function NftPayItem:UpdateIcon()
	local abName = 'nft_image'
	local assetName = self.m_Index == 1 and "img_logo_jojo" or "img_logo_bnb"
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	lua_resMgr:SetImageTexture(self,self.m_img_icon, abName, assetName,true)
end

function NftPayItem:SetSelState(bo)
	local abName = 'nft_image'
	local assetName = bo and "img_bg_sel_2" or "img_bg_2"
	if self.bg_assetName == assetName then
		return
	end

	self.bg_assetName = assetName
	lua_resMgr:SetImageTexture(self,self.m_NftPayItem, abName, assetName,true)
end