TiantiItem =BaseClass(LuaUI)
function TiantiItem:__init( vo, callback )
	self.URL = "ui://mrcfhfspt5hd3"

	self:RegistUI(self.ui)
	self.vo = vo
	self.isInited = true
	self.model = TiantiModel:GetInstance()
	self:Update(vo)
	self.callback = callback
	self.ui.onClick:Add(function ( e )
		if self.callback then
			self.callback(self)
		end
	end)

	self.funsClick.onClick:Add(function ( e )
		if not self.vo then return end
		local data = {}
		data.playerId = self.vo.playerId
		data.funcIds = {PlayerFunBtn.Type.AddFriend, PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.InviteTeam, PlayerFunBtn.Type.CheckPlayerInfo}
		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	end)

	self.btn_addFriend.onClick:Add(function ( e )
		FriendController:GetInstance():C_ApplyAddFriend(self.id)
	end)
end

function TiantiItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tianti","TiantiItem")

	self.c1 = self.ui:GetController("c1")
	self.bg = self.ui:GetChild("bg")
	self.selected = self.ui:GetChild("selected")
	self.order = self.ui:GetChild("order")
	self.btn_addFriend = self.ui:GetChild("btn_addFriend")
	self.levelBg = self.ui:GetChild("levelBg")
	self.txtLv1 = self.ui:GetChild("txtLv1")
	self.txtName = self.ui:GetChild("txtName")
	self.txtCareer = self.ui:GetChild("txtCareer")
	self.icon = self.ui:GetChild("icon")
	self.txtLv2 = self.ui:GetChild("txtLv2")
	self.txtStarNum = self.ui:GetChild("txtStarNum")
	self.startIcon = self.ui:GetChild("startIcon")
	self.headComp = self.ui:GetChild("headComp")
	self.funsClick = self.ui:GetChild("funsClick")
	self.btn_addFriend.visible = false
end
function TiantiItem:Update( vo )
	if not self.isInited then return end
	if not vo then return end
	self.id = vo.playerId
	local cfg = self.model:GetStageCfg(vo.stage or 1)
	local rank, font = self.model:GetRankChar(vo.rank, false)
	setTxtFontOrSize(self.order, font)
	self.order.text = rank
	self.txtName.text = vo.playerName
	self.headComp.icon = "Icon/Head/r"..vo.career
	self.txtLv1.text = StringFormat("等级 {0}", vo.level)
	self.txtLv2.text = StringFormat("{0}段位", cfg.stageName)
	self.txtStarNum.text = StringFormat("x{0}", vo.star)
	self.icon.url = "Icon/Tianti/dwicon1"..vo.stage
	--self.btn_addFriend.visible = not LoginModel:GetInstance():IsRole( vo.playerId )
end
function TiantiItem:__delete()
	self.isInited = false
end