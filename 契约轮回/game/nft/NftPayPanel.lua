--
-- @Author: LaoY
-- @Date:   2021-11-17 20:24:36
--

NftPayPanel = NftPayPanel or class("NftPayPanel",BasePanel)

function NftPayPanel:ctor()
	self.abName = "nft"
	self.assetName = "NftPayPanel"
	self.layer = "UI"

	self.use_background = true
	self.click_bg_close = true
	self.change_scene_close = true

	self.m_ItemList = {}
end

function NftPayPanel:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	for k,item in pairs(self.m_ItemList) do
		item:destroy()
	end
	self.m_ItemList = {}

end

function NftPayPanel:Open(iType)
	self.m_Type = iType
	NftPayPanel.super.Open(self)
end

function NftPayPanel:LoadCallBack()
	self.nodes = {
		"img_bg","img_bg/btn_Pay","img_bg/NftPayItem","img_bg/txt_balance",
	}
	self:GetChildren(self.nodes)


	self.m_txt_balance = GetText(self.txt_balance)

	self.m_NftPayItem_GameObject = self.NftPayItem.gameObject

	SetVisible(self.m_NftPayItem_GameObject,false)

	self:AddEvent()
end

function NftPayPanel:AddEvent()

	local function call_back(target,x,y)
		--- 请求服务端需要购买
		self:Close()
	end
	AddButtonEvent(self.btn_Pay.gameObject,call_back)


	-- local function call_back()
	
	-- end
	-- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(event_name, call_back)
end

function NftPayPanel:OpenCallBack()
	self:UpdateView()
end

function NftPayPanel:UpdateInfo()
	local str
	if self.m_Index == 1 then
		str = string.format("JOJO 余额：%s",0)
	else
		-- str = string.format("BNB余额：%s",0)
		str = ""
	end
	self.m_txt_balance.text = str
end

function NftPayPanel:UpdateView()

	local function cb(index)
		self:UpdateSelIndex(index)
	end

	for i=1,2 do
		local item = self.m_ItemList[i]
		if not item then
			item = NftPayItem(self.m_NftPayItem_GameObject,self.img_bg)
			item:SetCallBack(cb)
			if i == 1 then
				item:SetPosition(0,72)
			else
				item:SetPosition(0,-32)
			end
			self.m_ItemList[i] = item
		end
		item:SetData(i)
	end

	local index = self.m_Index or 1
	self.m_Index = nil
	self:UpdateSelIndex(index)
end

function NftPayPanel:UpdateSelIndex(index)
	if self.m_Index == index then
		return
	end
	self.m_Index = index
	for k,item in pairs(self.m_ItemList) do
		item:SetSelState(self.m_Index == k)
	end

	self:UpdateInfo()
end

function NftPayPanel:CloseCallBack()
	
end