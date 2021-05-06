local CTaskSlipGrassPage = class("CTaskSlipGrassPage", CPageBase)

function CTaskSlipGrassPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTaskSlipGrassPage.OnInitPage(self)
	self.m_GrassObj = self:NewUI(1, CBox)
	self.m_FlowerBrokenPointList = {}
	self.m_CutIdx = {}
	for i = 1, 4 do
		self.m_FlowerBrokenPointList[i] = self:NewUI(i + 1, CBox)		
	end	
	self.m_CutWidget = self:NewUI(6, CBox)
	self.m_PressSpr = self:NewUI(7, CSprite)
	self.m_FlowerPosList = {}
	for i = 1, 4 do
		local oBox = self:NewUI(7 + i, CBox)
		local pos = oBox:GetLocalPos()
		local w, h = oBox:GetSize()
		self.m_FlowerPosList[i] = {}
		self.m_FlowerPosList[i].pos = pos
		self.m_FlowerPosList[i].w = w
		self.m_FlowerPosList[i].h = h		
	end
	self.m_PressEff = self:NewUI(12, CUIEffect)
	self.m_PressEff:Above(self.m_PressSpr)
	self.m_TitleLabel = self:NewUI(13, CLabel)
	self.m_EndData = 
	{
		parent = self.m_Transform,
		sibling = self.m_CutWidget:GetSiblingIndex(),
	}
	self:InitContent()
end

function CTaskSlipGrassPage.InitContent(self)
	local rootw, rooth =  UITools.GetRootSize()	
	self.m_CutWidget:SetSize(rootw * 2, 2 * rooth)
	self.m_PressSpr:SetActive(false)
	g_UITouchCtrl:AddDragObject(self.m_CutWidget, self:GetDragArgs())
	self:AutoDoShiMen()
end

function CTaskSlipGrassPage.OnCut(self, idx)
	if not self.m_CutIdx[idx] then
		self.m_CutIdx[idx] = true
		self.m_FlowerBrokenPointList[idx]:SetActive(true)							
		local vet = {self.m_FlowerBrokenPointList[idx].m_Transform.localPosition, Vector3.New(-1.7, -0.9, 0)}
		local tween = DOTween.DOLocalPath(self.m_FlowerBrokenPointList[idx].m_Transform, vet, 0.5, 0, 0, 10, nil)
		DOTween.SetEase(tween, 1)
		local function finish()
			self.m_FlowerBrokenPointList[idx]:SetActive(false)
			if table.count(self.m_CutIdx) == #self.m_FlowerBrokenPointList then
				self:FinishAction()
			end
		end
		DOTween.OnComplete(tween, finish)
	end
end

function CTaskSlipGrassPage.FinishAction(self)
	self:StopAutoDoingShiMenTimer()
	self.m_TitleLabel:SetText("任务完成")
	local cb = function ( )
		if self.m_ParentView and self.m_ParentView.CompleteCallBack then
			self.m_ParentView:CompleteCallBack()
		end
	end
	Utils.AddTimer(cb, 0, 2)
end

function CTaskSlipGrassPage.GetDragArgs(self)
	local dArgs = {
		start_delta = {x=99999, y=99999},
		cb_dragging = callback(self, "OnDragging"),
		cb_dragend = callback(self, "OnDragEnd"),
		cb_dragstart = callback(self, "OnDragStart"),
		drag_obj = self.m_MoveTexture,
		long_press = 0,
	}
	return dArgs
end


function CTaskSlipGrassPage.OnDragging(self, oDragObj)
	local pos = oDragObj:GetLocalPos()
	for i, v in ipairs(self.m_FlowerPosList) do
		if self:CheckTrigger(pos, v) then
			self:OnCut(1)
			self:OnCut(2)
			self:OnCut(3)
			self:OnCut(4)
			break
		end
	end
end

function CTaskSlipGrassPage.OnDragEnd(self, oDragObj)
	self.m_PressSpr:SetActive(false)
	self.m_CutWidget.m_Transform.parent = self.m_EndData.parent
	self.m_CutWidget:SetSiblingIndex(self.m_EndData.sibling)
	UITools.MarkParentAsChanged(self.m_CutWidget.m_GameObject)
	return true
end

function CTaskSlipGrassPage.OnDragStart(self, oDragObj)
	self.m_PressSpr:SetActive(true)
	return true
end

function CTaskSlipGrassPage.CheckTrigger(self, tPos, oPosTable)
	if tPos.x >= oPosTable.pos.x - oPosTable.w / 2 and
	   tPos.x <= oPosTable.pos.x + oPosTable.w / 2 and
	   tPos.y >= oPosTable.pos.y - oPosTable.h / 2 and
	   tPos.y <= oPosTable.pos.y + oPosTable.h / 2 then
	 	return true
	end
end

function CTaskSlipGrassPage.AutoDoShiMen(self)
	if g_TaskCtrl:IsAutoDoingShiMen() then
		self:StopAutoDoingShiMenTimer()
		local cb = function ()
			if Utils.IsNil(self) then
				return
			end				
			self:OnCut(1)
			self:OnCut(2)
			self:OnCut(3)
			self:OnCut(4)
		end
		self.m_AutoDoingShimenTimer = Utils.AddTimer(cb, 0, CTaskCtrl.AutoDoingSM.Time)
	end
end

function CTaskSlipGrassPage.StopAutoDoingShiMenTimer(self)
	if self.m_AutoDoingShimenTimer then
		Utils.DelTimer(self.m_AutoDoingShimenTimer)
		self.m_AutoDoingShimenTimer = nil
	end
end

function CTaskSlipGrassPage.Destroy(self)
	self:StopAutoDoingShiMenTimer()
	CPageBase.Destroy(self)
end

return CTaskSlipGrassPage