TowerSelectView = TowerSelectView or BaseClass(BaseView)

function TowerSelectView:__init()
	self.ui_config = {"uis/views/fubenview", "TowerSelect"}
	self.full_screen = false
	self.play_audio = true
	self.firstopen = 0
end

function TowerSelectView:__delete()

end

--组队界面技能选择
function TowerSelectView:LoadCallBack()
	self.panel = self:FindObj("Panel")
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("GongJi",BindTool.Bind(self.SendGongJi, self))
	self:ListenEvent("FangYu",BindTool.Bind(self.SendFangYu, self))
	self:ListenEvent("JiaXue",BindTool.Bind(self.SendZiDong, self))
	self:ListenEvent("FuZhu",BindTool.Bind(self.SendFuZhu, self))
end

function TowerSelectView:ReleaseCallBack()
	self.panel = nil
end

function TowerSelectView:OpenCallBack()
	if self.firstopen == 0 then 
		self.firstopen = 1	
		FuBenCtrl.Instance:FlushManyPeopleView()
		TeamFbCtrl.Instance:OnFlushTeamFBContent()
	end
	self:Flush()
	self:SetPos()
end

function TowerSelectView:IsOpenView()
	if self.panel then
		return true
	else
		return false
	end
end
function TowerSelectView:SetPos()
	local pos = TeamFbData.Instance:GetPos()
	self.panel.transform.position = pos
end

function TowerSelectView:CloseWindow()
	self:Close()
end

function TowerSelectView:SendGongJi()
	local exist_flag = TeamFbData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_GONGJI)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = TeamFbData.Instance:GetID()
	TeamFbCtrl.Instance:SendTeamTowerDefendSetAttrType(id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_GONGJI)
	self:Close()
end

function TowerSelectView:SendFangYu()
	local exist_flag = TeamFbData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_FANGYU)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = TeamFbData.Instance:GetID()
	TeamFbCtrl.Instance:SendTeamTowerDefendSetAttrType(id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_FANGYU)
	self:Close()
end

function TowerSelectView:SendZiDong()
	local id = TeamFbData.Instance:GetID()
	TeamFbCtrl.Instance:SendTeamTowerDefendSetAttrType(id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_INVALID)
	self:Close()
end

function TowerSelectView:SendFuZhu()
	local exist_flag = TeamFbData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_ASSIST)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = TeamFbData.Instance:GetID()
	TeamFbCtrl.Instance:SendTeamTowerDefendSetAttrType(id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_ASSIST)
	self:Close()
end