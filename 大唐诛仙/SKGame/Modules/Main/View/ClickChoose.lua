ClickChoose = BaseClass(LuaUI)
function ClickChoose:__init( ... )
	self.URL = "ui://0042gnith4yxew";
	self:__property(...)
	self:Config()
end
function ClickChoose:SetProperty( ... )
end
function ClickChoose:Config()
	self.goldIconUrl = UIPackage.GetItemURL("Common" , "btnBg_002") -- UIPackage.GetItemURL("Main" , "ActivityBtn")
	self.grayedIconUrl = UIPackage.GetItemURL("Common" , "btnBg_001")
	self.bgKuang.height = 59
end

function ClickChoose:SetData( infolist )
	local scene = SceneController:GetInstance():GetScene()
	self.view = scene
	local pt = PuppetVo.Type
	local js = CustomJoystick.mainJoystick
	local funT = PlayerFunBtn.Type
	for i,v in ipairs(infolist) do
		local btn = UIPackage.CreateObject("Common" , "CustomButton3")
		local t = v.type
		if t == pt.NPC or t == pt.Collect then
			btn.icon = self.goldIconUrl
		elseif t == pt.PLAYER then
			btn.icon = self.grayedIconUrl
		end
		if t == pt.Collect then
			btn.title = "可采集"
		elseif t == pt.PLAYER or t == pt.NPC then
			btn.title = v.name
		end
		if t == pt.NPC or t == pt.Collect then
			self.btnList:AddChildAt(btn, 0)
		else
			self.btnList:AddChild(btn)
		end
		self.bgKuang.height = self.bgKuang.height + 68
		self.btnList.height = self.btnList.height + 68

		btn.onTouchBegin:Add(function ()
			if v.guid and t == pt.PLAYER then --选中界面
				if (js and js.joystick_touch.shape == Stage.inst.touchTarget) then return end
				local data = {}
				data.playerId = v.vo.playerId
				data.funcIds = {funT.CheckPlayerInfo,
								funT.AddFriend,
								funT.Chat, 
								funT.InviteTeam,
								funT.EnterTeam,
								funT.EnterFamily}

				GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
			end
			if v.guid and t == pt.NPC then	
				if scene.npcBehaviorMgr then
					scene.npcBehaviorMgr:Behavior(v)
				end	
			end
			if v.guid and  t == pt.Collect and scene.isCollecting == false then
				scene.curCollectObj = v
				local tf = v.transform
				local targetPos = Vector3.New(tf.position.x or 0, tf.position.y or 0, tf.position.z or 0)
				local mainPlayerPos = scene:GetMainPlayerPos()

				if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos , targetPos , math.sqrt((SceneConst.CollectDistance ^ 2) * 2)) then
					scene:HandleStopMove()
				else
					targetPos.z = targetPos.z + SceneConst.CollectDistance
					scene:GetMainPlayer():MoveToPositionByAgent(targetPos)
				end
			end
			UIMgr.HidePopup(self.ui)
		end)
	end
end

function ClickChoose:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","ClickChoose");

	self.bgKuang = self.ui:GetChild("bgKuang")
	self.btnList = self.ui:GetChild("btnList")
end
function ClickChoose.Create( ui, ...)
	return ClickChoose.New(ui, "#", {...})
end
function ClickChoose:__delete()
end