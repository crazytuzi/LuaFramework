local CEditorCameraView = class("CEditorCameraView", CViewBase)


function CEditorCameraView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorCamera/EditorCameraView.prefab", cb)
	self.m_DepthType = "Menu"
	rawset(_G, "config",require "logic.editor.editor_camera.editor_camera_config")
	self:RedefineFunc()
end

function CEditorCameraView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self.m_SetupBox = self:NewUI(2, CEditorCameraSetupBox)
	self.m_LeftBtn = self:NewUI(3, CButton)
	self.m_RightBtn = self:NewUI(4, CButton)
	self.m_UpBtn = self:NewUI(5, CButton)
	self.m_DownBtn = self:NewUI(6, CButton)
	self.m_FocusBtn = self:NewUI(7, CButton)
	self.m_DefaultBtn = self:NewUI(8, CButton)
	self.m_ForwardBtn = self:NewUI(9, CButton)
	self.m_BackwardBtn = self:NewUI(10, CButton)
	
	self:InitContent()
end

function CEditorCameraView.InitContent(self)
	self.m_RightBtn:AddUIEvent("repeatpress", callback(self, "MoveRight"))
	self.m_LeftBtn:AddUIEvent("repeatpress", callback(self, "MoveLeft"))
	self.m_UpBtn:AddUIEvent("repeatpress", callback(self, "MoveUp"))
	self.m_DownBtn:AddUIEvent("repeatpress", callback(self, "MoveDown"))
	self.m_ForwardBtn:AddUIEvent("repeatpress", callback(self, "MoveForward"))
	self.m_BackwardBtn:AddUIEvent("repeatpress", callback(self, "MoveBackward"))
	self.m_RightBtn:SetRepeatDelta(0)
	self.m_LeftBtn:SetRepeatDelta(0)
	self.m_UpBtn:SetRepeatDelta(0)
	self.m_DownBtn:SetRepeatDelta(0)
	self.m_ForwardBtn:SetRepeatDelta(0)
	self.m_BackwardBtn:SetRepeatDelta(0)
	self.m_FocusBtn:AddUIEvent("click", callback(self, "FocusOn"))
	self.m_DefaultBtn:AddUIEvent("click", callback(self, "ResetDefault"))
	
	self.m_InitDone = true
	g_WarTouchCtrl:SetPathMove(false)
	-- self:RefreshWar()
end

function CEditorCameraView.RedefineFunc(self)
	local function nilfunc() end
	CCreateRoleView.ctor = nilfunc
	CViewCtrl.CloseAll = nilfunc
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
	CMainMenuView.ShowView = nilfunc
	CHouseMainView.ShowView = nilfunc
	CHouseTouchCtrl.OnSwipe = function(s, swipePos)
		local oCam = g_CameraCtrl:GetHouseCamera()
		local v = oCam:GetEulerAngles()
		v.y = v.y - swipePos.x/7
		oCam:SetLocalEulerAngles(v)
	end
	CTeamCtrl.GetMemberSize = function() return 4 end
end

function CEditorCameraView.RefreshWar(self)
	-- local iCnt = self.m_UserCache["warrior_cnt"] or 1
	warsimulate.Start(8, 140)
end

function CEditorCameraView.GetCamera(self)
	return self.m_SetupBox:GetCamera()
end


function CEditorCameraView.GetLookAtObj(self)
	return g_WarCtrl:GetRoot()
end

function CEditorCameraView.MoveRight(self)
	local cam = self:GetCamera()
	cam:Translate(cam.m_Transform.right*0.1, enum.Space.World)
end

function CEditorCameraView.MoveLeft(self)
	local cam = self:GetCamera()
	cam:Translate(-cam.m_Transform.right*0.1, enum.Space.World)
end

function CEditorCameraView.MoveUp(self)
	local cam = self:GetCamera()
	cam.m_Transform:Translate(cam.m_Transform.up*0.1, enum.Space.World)
end

function CEditorCameraView.MoveDown(self)
	local cam = self:GetCamera()
	cam.m_Transform:Translate(-cam.m_Transform.up*0.1, enum.Space.World)
end

function CEditorCameraView.MoveForward(self)
	local cam = self:GetCamera()
	cam.m_Transform:Translate(cam.m_Transform.forward*0.3, enum.Space.World)
end

function CEditorCameraView.MoveBackward(self)
	local cam = self:GetCamera()
	cam.m_Transform:Translate(-cam.m_Transform.forward*0.3, enum.Space.World)
end

function CEditorCameraView.FocusOn(self, obj)
end

function CEditorCameraView.ResetDefault(self)
end

return CEditorCameraView