-- 家族好友面板
FamilyHYPanel = BaseClass(LuaUI)
function FamilyHYPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Family","FamilyHYPanel");

	self.btnHY = self.ui:GetChild("btnHY")
	self.layerHY = self.ui:GetChild("layerHY")
	self.textNF = self.ui:GetChild("textNF")
	self.btnClose = self.ui:GetChild("btnClose")

	self.items = {}
	self.model = FamilyModel:GetInstance()

	self:InitEvent()
end

function FamilyHYPanel:InitEvent()
	FriendController:GetInstance():C_FriendList(1)
	self:Update()
	self.model:SetFamilyModelShow(false)
	self:Config()
end

function FamilyHYPanel:Config()
	self.btnClose.onClick:Add(function ()
		self:Destroy()
	end)
end

function FamilyHYPanel:Update()
	local friendList = {}
	SerialiseProtobufList( self.model:GetInviteFriends(), function ( data )       
		table.insert(friendList, data)
	end )
	local num = #friendList or 0
	-- 显示在线好友
	if num > 0 then
		self.textNF.visible = false
		local offsetY = offsetY or 5
		local itemY = itemY or 94
		-- 显示在线好友
		for i,v in ipairs(friendList) do
			local friendItem = FamilyHYItem.New(self.layerHY)
			friendItem:SetHYItem( v )
			friendItem:SetXY(8, (i-1)*(offsetY+itemY))
			self.items[i] = friendItem
		end
	end
end

-- Dispose use FamilyHYPanel obj:Destroy()
function FamilyHYPanel:__delete()
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end

	if self.model then
		self.model:SetFamilyModelShow(true)
		self.model = nil
	end
	
	GlobalDispatcher:DispatchEvent(EventName.PLAYER_MODEL)
end