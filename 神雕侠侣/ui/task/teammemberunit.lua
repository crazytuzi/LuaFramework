TeamMemberUnit = {}
TeamMemberUnit.__index = TeamMemberUnit
function TeamMemberUnit.new(id, hp, maxHp, mp, maxMp, level, name, shapeId, schoolID)
	local self = {}
	setmetatable(self, TeamMemberUnit)
	local winMgr = CEGUI.WindowManager:getSingleton()
	LogInsane("Load team member "..id)
    self.pWnd = winMgr:loadWindowLayout("teammaincell.layout", tostring(id))
    self.pWnd:subscribeEvent("MouseClick", TeamMemberUnit.HandleMouseClick,self)
    self.pIcon = winMgr:getWindow(id.."teammaincell/icon")
    local config = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeId)
    local iconpath = GetIconManager():GetImagePathByID(config.littleheadID)
    self.pIcon:setProperty("Image", iconpath:c_str())
    self.pHp = CEGUI.toProgressBar(winMgr:getWindow(id.."teammaincell/hp"))
    self.pHp:setBarType(0)
    self.pHp:setProgress(hp/maxHp)
    self.pMp = CEGUI.toProgressBar(winMgr:getWindow(id.."teammaincell/mp"))
    self.pMp:setBarType(2)
    self.pMp:setProgress(mp/maxMp)
    self.pLevel = winMgr:getWindow(id.."teammaincell/level")
    self.pLevel:setText(tostring(level))
    self.pName = winMgr:getWindow(id.."teammaincell/name")
    self.pName:setText(name)
    self.pMark = winMgr:getWindow(id.."teammaincell/mark")
	self.pSchool = winMgr:getWindow(id .. "teammaincell/school")
	self.pSchool:setProperty("Image", "set:MainControl5 image:" .. self:getSchoolStr(schoolID))
    return self
end
        
function TeamMemberUnit:getSchoolStr(id)
    if id == 11 then
    	return "gumu"
    elseif id == 12 then
    	return "gaibang"
    elseif id == 14 then
    	return "baituo"
    elseif id == 15 then
    	return "dali"
    elseif id == 17 then
    	return "taohua"
    elseif id == 19 then
        return "bahuagu"
    else
    	return ""
    end
end
	
function TeamMemberUnit:HandleMouseClick(e)
	LogInsane("TeamMemberUnit:HandleMouseClick")  
    if GetTeamManager():IsOnTeam() then
        if CTaskTracingDialog.getSingleton() then
        	LogInsane("dlg:setTeamHandleBtnStat")
        	local dlg = CTaskTracingDialog.getSingleton()
            dlg:setTeamHandleBtnStat(not dlg.m_bTeamHandleBtnVisible)
        end
        if CTaskTracingDialog.getSingleton() then
   			local dlg = CTaskTracingDialog.getSingleton()
            dlg.m_pLeaveBtn:setVisible(dlg.m_bTeamHandleBtnVisible)
        end
        LogInsane("GetTeamManager():GetMemberSelf().eMemberState"..GetTeamManager():GetMemberSelf().eMemberState)
        LogInsane("eTeamMemberAbsent"..eTeamMemberAbsent)
        if CTaskTracingDialog.getSingleton() and 
        	((not GetTeamManager():IsMyselfLeader() and 
        	(GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent or 
			GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberNormal)) or 
        	(GetTeamManager():IsMyselfLeader() and GetTeamManager():IsHaveAbsentMember()))
       	then
            local dlg = CTaskTracingDialog.getSingleton()
			dlg:setBackBtnVisible()
        end
    end
    return true;
end
        
