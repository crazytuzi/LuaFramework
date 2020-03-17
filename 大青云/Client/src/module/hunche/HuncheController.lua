_G.HuncheController = setmetatable({}, {__index = IController})
HuncheController.name = "HuncheController"

function HuncheController:Create()
	-- CControlBase:RegControl(self, true)
	-- CPlayerControl:AddPickListen(self)
	-- self.bCanUse = true
	MsgManager:RegisterCallBack(MsgType.SC_SetFollowerGuid, self, self.OnSetFollowerGuid)
	return true
end

function HuncheController:Update(interval)
	return true
end

function HuncheController:Destroy()
	return true
end

function HuncheController:OnEnterGame()
	return true
end

function HuncheController:OnChangeSceneMap()
	HuncheModel:DeleteAllHunche()
	return true
end

function HuncheController:OnLeaveSceneMap()
	HuncheModel:DeleteAllHunche()
	return true
end

function HuncheController:OnBtnPick(button, type, node)
	self:OnMouseClick(node, button)
end

function HuncheController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function HuncheController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function HuncheController:OnMouseOut(node)
    if node == nil then
    	return
    end
	local cid = node.cid
	if not cid then
		return
	end
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end
	local avatar = hunche:GetAvatar()
	if avatar then 
		avatar:DelHighLight()
    end
    CCursorManager:DelState("dialog")
end

function HuncheController:OnMouseOver(node)
	if node == nil then
    	return
    end
	local cid = node.cid
	if not cid then
		return
	end
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end
	local avatar = hunche:GetAvatar()
	if avatar then
		local light = Light.GetEntityLight(enEntType.eEntType_Patrol,CPlayerMap:GetCurMapID());
		avatar:SetHighLight( light.hightlight );
    end
    CCursorManager:AddStateOnChar("dialog", cid)
end

function HuncheController:OnMouseClick(node, button)
	if not node then
		return
	end
	local cid = node.cid
	if not cid then
		return
	end
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end
	MarryGiveFive:Show()
end

function HuncheController:AddHunche(info)
	local cid = info.charId
	local manName = info.manName
	local womanName = info.womanName
	local hunche = HuncheModel:GetHunche(cid)
    if hunche then
        return
	end
	local id = info.configId
	local x = info.x
	local y = info.y
	local faceto = info.faceto
	hunche = Hunche:New(id, cid, x, y, faceto)
	if not hunche then
		return
	end
	hunche:Show()
	hunche:SetName(manName, womanName)
	HuncheModel:AddHunche(hunche)

	if hunche:GetMainHunche() then
		HuncheController:OnMainHuncheEnterGame()
	end

end

function HuncheController:DeleteHunche(cid)
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end

	if hunche:GetMainHunche() then
		HuncheController:OnMainHuncheExitGame()
	end

	HuncheModel:DeleteHunche(hunche)
	hunche:Delete()
end

function HuncheController:MoveTo(cid, x, y)
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end
	hunche:MoveTo(x, y)
end

function HuncheController:StopMove(cid, x, y, faceto)
	local hunche = HuncheModel:GetHunche(cid)
    if not hunche then
        return
	end
	hunche:StopMove(x, y, faceto)
end

function HuncheController:GetHunche(cid)
	return HuncheModel:GetHunche(cid)
end

function HuncheController:GetFollowerPos()
	if HuncheController.followerGuid then
		local hunche = HuncheModel:GetHunche(HuncheController.followerGuid)
		if hunche then
			return hunche:GetPos()
		end
	end
end

function HuncheController:OnMainHuncheEnterGame()
	MarryUtils:EnterSee()
end

function HuncheController:OnMainHuncheExitGame()
	MarryUtils:ExitSee()
end

--------------------------------------
function HuncheController:OnSetFollowerGuid(msg)
	local roleID = msg.roleID
	HuncheController.followerGuid = roleID
	if roleID ~= "0_0" then
		if not UIMarrySendMoneyView:IsShow() then 
			UIMarrySendMoneyView:Show();
		end;
		--如果正在打坐，取消
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit()
		end
		--关闭npc面板
		if UIMarryNpcBox:IsShow() then 
			UIMarryNpcBox:Hide();
		end;
	-- 	CControlBase:SetControlDisable(true)
	-- 	UIManager:HideLayerBeyond("story", "float", "loading")
	else
	-- 	CControlBase:SetControlDisable(false)
	-- 	UIManager:RecoverAllLayer()
		if UIMarrySendMoneyView:IsShow() then 
			UIMarrySendMoneyView:Hide();
		end;
	end

end