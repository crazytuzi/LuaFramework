local CDialogueLayerAniView = class("CDialogueLayerAniView", CViewBase)

function CDialogueLayerAniView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dialogue/DialogueLayerAniView.prefab", cb)
	--界面设置
	self.m_DepthType = "Login"
	--self.m_GroupName = "main"	
	--self.m_ExtendClose = "Shelter"
	self.m_InitDone = true
end

function CDialogueLayerAniView.OnCreateView(self)
	self.m_AniBgTextrue = self:NewUI(1, CActorTexture)
	self.m_ActorBox = self:NewUI(5, CDialogueLayerActorBox)
	self.m_ActorRoot = self:NewUI(6, CBox)
	self.m_Container = self:NewUI(7, CBox)
	self.m_CameraScaleDot = self:NewUI(8, CBox)
	self.m_ScaleRoot = self:NewUI(9, CBox)
	self.m_LeftSayLabel = self:NewUI(10, CLabel)
	self.m_LeftSayBg = self:NewUI(11, CSprite)
	self.m_RightSayLabel = self:NewUI(12, CLabel)
	self.m_RightSayBg = self:NewUI(13, CSprite)
	self.m_ActorPanel = self:NewUI(14, CPanel)

	UITools.ResizeToRootSize(self.m_Container)
	self.m_LayerScale = 1
	self.m_PS = g_DialogueAniCtrl:GetAniPlaySpeed() --播放速度
	self.m_NpcList = {}
	self:InitContent()

	--页面加载完成时，停止主角寻路
	local oHero = g_MapCtrl:GetHero()
	if oHero and oHero:IsWalking() then
		oHero:StopWalk()
	end
end

function CDialogueLayerAniView.InitContent(self)
	self.m_ActorBox:SetActive(false)
	g_DialogueAniCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlDialogueAniEvent"))
end

function CDialogueLayerAniView.SetData(self, config)
	config = config or {}
	local mapId = config.mapId or 3012
	self.m_AniBgTextrue:ChangeShape(mapId, {})
end

--只有在编辑器模式下，才能打开
function CDialogueLayerAniView.ShowPathConfigBox(self)
	self.m_PathConfigGrid = self:NewUI(2, CGrid)
	self.m_PathCloneBox = self:NewUI(3, CBox)
	self.m_ConfigInfoBox = self:NewUI(4, CBox)
	self.m_ConfigInfoBox.m_LoadInput = self.m_ConfigInfoBox:NewUI(1, CInput)
	self.m_ConfigInfoBox.m_LoadBtn = self.m_ConfigInfoBox:NewUI(2, CButton)
	self.m_ConfigInfoBox.m_SaveInput = self.m_ConfigInfoBox:NewUI(3, CInput)
	self.m_ConfigInfoBox.m_SaveBtn = self.m_ConfigInfoBox:NewUI(4, CButton)
	self.m_ConfigInfoBox.m_QuitBtn = self.m_ConfigInfoBox:NewUI(5, CButton)

	self.m_ConfigInfoBox.m_LoadBtn:AddUIEvent("click", callback(self, "OnClickLoad"))
	self.m_ConfigInfoBox.m_SaveBtn:AddUIEvent("click", callback(self, "OnClickSave" ))
	self.m_ConfigInfoBox.m_QuitBtn:AddUIEvent("click", callback(self, "OnClickQuit"))

	self.m_ConfigInfoBox.m_LoadInput:SetText("")
	self.m_ConfigInfoBox.m_SaveInput:SetText("")
	self.m_ConfigInfoBox:SetActive(true)

	self.m_ConfigLoadMapId = 0
	self.m_ConfigSaveMapId = 0
	self.m_PathCloneList = {}

	self.m_Cell_Max_WidthNum = 60
	self.m_Cell_Max_HeightNum = 30
	self.m_PathCloneBox:SetActive(false)
	self.m_PathConfigGrid:SetMaxPerLine(60)
	self.m_InitIndx = 0
	self.m_InitDone = false
	self.m_TestWalker = false

	self.m_PathConfigTable = {}
	Utils.AddTimer(callback(self, "OnCellInit", 0), 0, 0)
end

function CDialogueLayerAniView.OnClickSave(self)
	if self.m_InitDone == false then
		g_NotifyCtrl:FloatMsg("未初始化完成，请稍后...")
		return
	end	
	local text = self.m_ConfigInfoBox.m_SaveInput:GetText()
	if text == "" then
		g_NotifyCtrl:FloatMsg("请输入地图编号")
	end
	local map = tonumber(text)
	printc(">>>>>>>>正在保存数据")
	table.print(self.m_PathConfigTable)
	self.m_TestWalker = false
	g_DialogueAniCtrl:SaveLayerAniData(map, self.m_PathConfigTable)
end

function CDialogueLayerAniView.OnClickLoad(self)
	if self.m_InitDone == false then
		g_NotifyCtrl:FloatMsg("未初始化完成，请稍后...")
		return
	end
	local text = self.m_ConfigInfoBox.m_LoadInput:GetText()
	if text == "" then
		g_NotifyCtrl:FloatMsg("请输入地图编号")
	end
	local map = tonumber(text)
	self.m_PathConfigTable = {}
	local d = data.dialoguelayeraninvdata.DATA
	if d and d[map] then
		self.m_PathConfigTable = table.copy(d[map]) 
	end
	if map == 0 then
		self.m_PathConfigTable = {}
		for i = 1, 30 do
			for _i = 1, 60 do
				self.m_PathConfigTable[i] = self.m_PathConfigTable[i] or {}
				self.m_PathConfigTable[i][_i] = 1
			end
		end
	else
		self.m_AniBgTextrue:ChangeShape(map, {})
	end 
	self.m_InitIndx = 0
	printc(">>>>在加载导航 ", map)
	table.print(self.m_PathConfigTable)
	self.m_TestWalker = true
	self:OnCellInit(self.m_Cell_Max_HeightNum * self.m_Cell_Max_WidthNum)
end

function CDialogueLayerAniView.OnClickQuit(self)
	self:CloseView()
end

function CDialogueLayerAniView.OnCellInit(self, time)
	if time == 0 then
		time = 30
	end
	for i = 1, time do 
		if self.m_InitIndx > self.m_Cell_Max_HeightNum * self.m_Cell_Max_WidthNum then
			self.m_InitDone = true
			self.m_PathConfigGrid:Reposition()
			g_NotifyCtrl:FloatMsg("导航格子初始化完成")
			return false
		end
		local x = math.floor(self.m_InitIndx / self.m_Cell_Max_WidthNum) + 1
		local y = math.floor(self.m_InitIndx % self.m_Cell_Max_WidthNum) + 1
		self.m_PathCloneList[x] = self.m_PathCloneList[x] or {}
		local oBox
		if self.m_PathCloneList[x][y] then
			oBox = self.m_PathCloneList[x][y]
		else
			oBox = self.m_PathCloneBox:Clone()	
			self.m_PathCloneList[x][y] = oBox
			self.m_PathConfigGrid:AddChild(oBox)
		end
		oBox:SetActive(true)
		oBox.m_PathSpr = oBox:NewUI(1, CSprite)
		local isPath = false
		if self.m_PathConfigTable[x] and self.m_PathConfigTable[x][y] == 1 then
			isPath = true
		end				
		oBox.m_PathSpr:SetActive(isPath)
		oBox:SetName(string.format("%d-%d",x ,y))
		oBox:AddUIEvent("click", callback(self, "OnClickPathCell", x, y, oBox))
		self.m_InitIndx = self.m_InitIndx + 1		
	end
	return true
end

function CDialogueLayerAniView.OnClickPathCell(self, x, y, oBox)
	if self.m_InitDone == false then
		g_NotifyCtrl:FloatMsg("未初始化完成，请稍后...")
		return
	end
	if self.m_TestWalker then
		self.m_ActorBox:WalkTo(x, y)
		return
	end

	if self.m_PathConfigTable then
		if self.m_PathConfigTable[x] and self.m_PathConfigTable[x][y] == 1 then
			self.m_PathConfigTable[x][y] = 0
		else
			self.m_PathConfigTable[x] = self.m_PathConfigTable[x] or {}
			self.m_PathConfigTable[x][y] = 1
		end
		if oBox and oBox.m_PathSpr then
			oBox.m_PathSpr:SetActive(self.m_PathConfigTable[x][y] == 1)
		end
	end
end

function CDialogueLayerAniView.Destroy(self)
	self:StopSideSayTimer()
	if self.m_NpcList then
		for i, v in ipairs(self.m_NpcList) do
			v:Destroy()
		end
	end
	CViewBase.Destroy(self)
end

function CDialogueLayerAniView.AddNpc(self, idx, config)
	local oNpc = self.m_ActorBox:Clone()
	if oNpc then
		config = config or {}
		oNpc:SetActive(true)
		oNpc:SetParent(self.m_ActorRoot.m_Transform)
		oNpc:ChangeShape(config.model_info.shape)
		oNpc:SetLocalPos(Vector3.New(config.pos_info.x, config.pos_info.y, 0))
		oNpc:SetFaceRight(config.faceright)
		oNpc:SetResRight(config.resourceright)
		oNpc:AddEffectMode(config.addeffectmode)
		oNpc:SetNpcDepth(config.depth)
		oNpc:SetNpcNormalScaleAndYOffset(config.scale, config.yoffset, true)
		local w, h = self.m_Container:GetSize()
		oNpc:SetBaseData({width = w, height = h})
		self.m_NpcList[idx] = oNpc
	end
end

function CDialogueLayerAniView.WalkTo(self, idx, pos, faceright)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:WalkTo(pos.x, pos.y)		
	end
end

function CDialogueLayerAniView.SetPlayerPos(self, idx, pos, faceright)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SetLocalPos(Vector3.New(pos.x, pos.y, 0))
		oNpc:SetFaceRight(faceright)	
	end
end

function CDialogueLayerAniView.SetPlayerFaceTo(self, idx, faceright)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SetFaceRight(faceright)	
	end
end

function CDialogueLayerAniView.SetPlayerActive(self, idx, visible, isfade)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SetNpcActive(visible, isfade)
	end
end

function CDialogueLayerAniView.SetPlayerSay(self, idx, msg, time)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SayMsg(msg, time)
	end
end

function CDialogueLayerAniView.SetPlayerDoAction(self, idx, action, config)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:CrossFade(action, config)
	end
end

function CDialogueLayerAniView.SetPlayerShowSocialEmoji(self, idx, emoji, visible)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SetSocialEmoji(emoji, visible)
	end
end

function CDialogueLayerAniView.SetCameraScale(self, isscale, center, time, scale)
	if isscale then
		self.m_CameraScaleDot:SetLocalPos(Vector3.New(-center.x, -center.y , 0))
	else
		self.m_CameraScaleDot:SetLocalPos(Vector3.New(0, 0 , 0))	
		scale = 1
	end	
	self.m_LayerScale = scale
	local pos = self.m_CameraScaleDot:GetPos()
	DOTween.DOKill(self.m_Transform)
	local tween1 = DOTween.DOScale(self.m_ScaleRoot.m_Transform, Vector3.New(scale, scale, scale), time)
	local tween2 = DOTween.DOMove(self.m_ScaleRoot.m_Transform, Vector3.New(pos.x, pos.y, 0), time)
end


function CDialogueLayerAniView.SetPlayerDepth(self, idx, depth)
	local oNpc = self.m_NpcList[idx]
	if oNpc then
		oNpc:SetNpcDepth(depth)
	end
end

function CDialogueLayerAniView.ShowSideSay(self, msg, isLeft)
	if not msg or msg == "" then
		return
	end
	self:StopSideSayTimer()
	local label = nil
	local bgSpr = nil
	if isLeft == true then
		label = self.m_LeftSayLabel
		bgSpr = self.m_LeftSayBg
	else
		label = self.m_RightSayLabel
		bgSpr = self.m_RightSayBg
	end
	label:SetText(msg)
	local _w = label:GetWidth()
	if _w > 180 then
		label:SetOverflow(enum.UILabel.Overflow.ResizeHeight)
		label:SetWidth(180)
	end
	label:SetActive(true)
	label:SetLocalScale(Vector3.New(self.m_LayerScale, self.m_LayerScale, self.m_LayerScale))
	self.m_SideSayTimer = Utils.AddTimer(callback(self, "SideSayMsgEnd", label, bgSpr), 0, 2)
	Utils.AddTimer(callback(self, "DelaySetSideSayBg", label, bgSpr), 0, 0)	
end
 
function CDialogueLayerAniView.StopSideSayTimer(self)
	if self.m_SideSayTimer then
		Utils.DelTimer(self.m_SideSayTimer)
		self.m_SideSayTimer = nil
	end
	self.m_LeftSayLabel:SetActive(false)
	self.m_RightSayLabel:SetActive(false)
end

function CDialogueLayerAniView.SideSayMsgEnd(self, label, bgSpr)
	if not Utils.IsNil(label) and not Utils.IsNil(bgSpr) then
		label:SetText("")
		label:SetOverflow(enum.UILabel.Overflow.ResizeFreely)
		label:SetActive(false)			
		bgSpr:SetSize(20, 20)
		label:SetLocalScale(Vector3.New(1, 1, 1))
	end
end

function CDialogueLayerAniView.DelaySetSideSayBg(self, label, bgSpr)
	if not Utils.IsNil(label) and not Utils.IsNil(bgSpr) then
		local w, h = label:GetSize() 
		bgSpr:SetSize(w + 24, h + 20)
	end
end
 
function CDialogueLayerAniView.DelayClose(self)
	self.m_AniBgTextrue:PlayAni("idleWar", false)
	self.m_ActorPanel:SetActive(false)
	Utils.AddTimer(callback(self, "CloseView"), 0, 1.2)
end

function CDialogueLayerAniView.OnCtrlDialogueAniEvent(self, oCtrl)
	if oCtrl.m_EventID == define.DialogueAni.Event.PlayAniSpeed then
		self.m_PS = g_DialogueAniCtrl:GetAniPlaySpeed()
		if self.m_NpcList and next(self.m_NpcList) then
			for i, v in ipairs(self.m_NpcList) do
				v:SetPlaySpeed(self.m_PS)
			end
		end
	end
end

return CDialogueLayerAniView