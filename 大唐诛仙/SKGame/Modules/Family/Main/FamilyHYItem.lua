-- 家族好友元件
FamilyHYItem = BaseClass(LuaUI)
function FamilyHYItem:__init(root)
	self:LayoutUI(root)
	self:InitEvent()
end

function FamilyHYItem:InitEvent()
	self.btnYQ.onClick:Add(function ()
		FamilyCtrl:GetInstance():C_InviteJoinFamily( self.vo.playerId )
		UIMgr.Win_FloatTip(StringFormat("已向{0}发出了邀请", self.vo.playerName))
		self.btnYQ.grayed = true
		self.btnYQ.touchable = false
	end)
end

function FamilyHYItem:SetHYItem( item )
	self.name.text = item.playerName
	self.headIcon.title = item.level
	self.headIcon.icon = "Icon/Head/r1"..item.career
	self.vo = {
		playerId = item.playerId,
		playerName = item.playerName
	}
	self.btnYQ.grayed = false
	self.btnYQ.touchable = true
end

function FamilyHYItem:LayoutUI(root)
	self.ui = UIPackage.CreateObject("Family","FamilyHYItem");
	root:AddChild(self.ui)
	self.name = self.ui:GetChild("name")
	self.headIcon = self.ui:GetChild("headIcon")
	self.btnYQ = self.ui:GetChild("btnYQ")
end

function FamilyHYItem:__delete()
	self.vo = {}
end