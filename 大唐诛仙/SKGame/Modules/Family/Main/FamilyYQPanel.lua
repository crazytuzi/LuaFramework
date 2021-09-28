-- 邀请面板
FamilyYQPanel = BaseClass(LuaUI)
function FamilyYQPanel:__init( data )
	self.ui = UIPackage.CreateObject("Family","FamilyYQPanel");

	self.txtInvite = self.ui:GetChild("txtInvite")
	self.btnRef = self.ui:GetChild("btnRef")
	self.btnAgr = self.ui:GetChild("btnAgr")

	self.isClick = false
	
	self:InitData( data )
end

function FamilyYQPanel:InitData( data )
	self.playerFamilyId = data.playerFamilyId
	self.txtInvite.text = StringFormat("您的好友[COLOR=#217BBB]{0}[/COLOR]正在\n邀请您加入[COLOR=#2F7F88]{1}[/COLOR]家族", data.playerName, data.familyName)

	self.btnAgr.onClick:Add(function () -- 接受
		FamilyCtrl:GetInstance():C_InviteMsgDeal( self.playerFamilyId, 1 )
		FamilyModel:GetInstance():SetRedTips(false)
		self.isClick = true
		FamilyModel:GetInstance():ResetInviteTime()
		-- FamilyModel:GetInstance():RemoveInvitePanel( true, self.playerFamilyId )
		self:Destroy()
	end)

	self.btnRef.onClick:Add(function () -- 拒绝
		FamilyCtrl:GetInstance():C_InviteMsgDeal( self.playerFamilyId, 0 )
		FamilyModel:GetInstance():SetRedTips(false)
		self.isClick = true
		FamilyModel:GetInstance():ResetInviteTime()
		-- FamilyModel:GetInstance():RemoveInvitePanel( false, self.playerFamilyId )
		self:Destroy()
	end)

	self:SetCountDown()
end

function FamilyYQPanel:SetCountDown()
	-- 是否操作
	local endTime = FamilyModel:GetInstance():GetInviteTime()
	-- 如果没有操作继续倒数
	if endTime > 0 and not self.isClick then
		setupFuiRender(self.btnRef, 
		function ()
			self.btnRef.title = StringFormat("拒绝({0}s)", math.floor(endTime), true)
			endTime = endTime - 1
			FamilyModel:GetInstance():ResetInviteTime( endTime )
			if endTime < 0 then
				stopFuiRender(self.btnRef)
				FamilyCtrl:GetInstance():C_InviteMsgDeal( self.playerFamilyId, 0 )
				self.isClick = true
				FamilyModel:GetInstance():ResetInviteTime()
				self:Destroy()
			end
		end, 
		1)
	end
end

-- Dispose use FamilyYQPanel obj:Destroy()
function FamilyYQPanel:__delete()
	self.isClick = false
end