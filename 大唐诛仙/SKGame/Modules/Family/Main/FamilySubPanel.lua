-- 个人信息面板
FamilySubPanel = BaseClass(LuaUI)
function FamilySubPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Family","FamilySubPanel");

	self.name = self.ui:GetChild("name")
	self.headIcon = self.ui:GetChild("headIcon")
	self.GRXX = self.ui:GetChild("GRXX")
	self.YQZD = self.ui:GetChild("YQZD")
	self.FSXX = self.ui:GetChild("FSXX")
	self.ZRZZ = self.ui:GetChild("ZRZZ")
	self.QCJZ = self.ui:GetChild("QCJZ")

	self.playerId = 0
	self.data = nil
	self.mainPlayer = SceneModel:GetInstance():GetMainPlayer()

	self:AddListener()
end

function FamilySubPanel:Update( data )
	self.data = data
	self.playerId = data.playerId
	self.familyName = data.familyName
	self.career = data.career
	self.level = data.level
	self.online = data.online
	self.playerName = data.playerName
	self.name.text = self.playerName
	self.headIcon.icon = "Icon/Head/r1"..self.career 
	self.headIcon.title = self.level
	self:SetBtnState()
end

function FamilySubPanel:SetBtnState()
	local isLeader = FamilyModel:GetInstance():IsFamilyLeader()
	self.ZRZZ.grayed = not isLeader
	self.ZRZZ.touchable = isLeader
	self.QCJZ.grayed = not isLeader
	self.QCJZ.touchable = isLeader
	if not isLeader then
		-- self.ZRZZ.title.color = newColorByString("ffffff")
		-- self.QCJZ.title.color = newColorByString("ffffff")
	end
end

function FamilySubPanel:AddListener()
	-- 个人信息
	self.GRXX.onClick:Add(function ()
		FamilyModel:GetInstance():SetFamilyModelShow(false)
		PlayerInfoController:GetInstance():ReqCheckOtherPlayerInfo(self.playerId)
		UIMgr.HidePopup()
	end)

	--邀请组队
	self.YQZD.onClick:Add(function ()
		if self.mainPlayer and not self.mainPlayer:HasTeam() then
			ZDCtrl:GetInstance():C_CreateTeam()
		end
		ZDCtrl:GetInstance():C_Invite(self.playerId)
		UIMgr.HidePopup()
	end)

	-- 发送信息
	self.FSXX.onClick:Add(function ()
		local chatVo = {}
		chatVo.sendPlayerLevel = self.level
		chatVo.sendPlayerCareer = self.career
		chatVo.sendPlayerId = self.playerId
		chatVo.online = self.online
		chatVo.sendPlayerName = self.playerName
		chatVo.familyName = self.familyName
		FriendController:GetInstance():IsFriendChat(chatVo)
		UIMgr.HidePopup()
	end)

	-- 转让族长
	self.ZRZZ.onClick:Add(function ()
		UIMgr.HidePopup()
		UIMgr.Win_Confirm(
			"温馨提示", 
			StringFormat("确定要将族长之位转让给[COLOR=#217BBB]{0}[/COLOR]吗？", self.name.text), 
			"确定", 
			"取消", 
			function ()
				FamilyCtrl:GetInstance():C_ChangeFamilyLeader( self.playerId )
			end, 
			nil)
	end)

	-- 请出家族
	self.QCJZ.onClick:Add(function ()
		UIMgr.HidePopup()
		UIMgr.Win_Confirm(
			"温馨提示", 
			StringFormat("确定要将[COLOR=#217BBB]{0}[/COLOR]请出家族吗？", self.name.text), 
			"确定", 
			"取消", 
			function ()
				FamilyCtrl:GetInstance():C_KickFamilyPlayer( self.playerId )
			end, 
			nil)
	end)
end

-- Dispose use FamilySubPanel obj:Destroy()
function FamilySubPanel:__delete()
	self.playerId = 0
	self.data = nil
end