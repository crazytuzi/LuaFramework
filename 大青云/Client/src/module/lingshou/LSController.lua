_G.LSController = setmetatable({}, {__index = IController})
LSController.name = "LSController"

function LSController:Create()
	return true
end

function LSController:Update(interval)
	return true
end

function LSController:Destroy()
	return true
end

function LSController:OnEnterGame()
	return true
end

function LSController:OnChangeSceneMap()
	LSModel:DeleteAllLingShou()
	return true
end

function LSController:OnLeaveSceneMap()
	LSModel:DeleteAllLingShou()
	return true
end

function LSController:AddLingShou(info)
	local cid = info.charId
	local ls = LSModel:GetLingShou(cid)
    if ls then
        return
	end
	local lsId = info.configId
	local x = info.x
	local y = info.y
	local faceto = info.faceto
	local speed = info.speed
	local ownerId = info.ownerId
	local nType = info.nType
	ls = LS:New(lsId, cid, x, y, faceto, nType)
	if not ls then
		return
	end
	ls:Show()
	ls:SetSpeed(speed)
	ls:SetOwnerId(ownerId)
	LSModel:AddLingShou(ls)
	if StoryController:IsStorying() then
		ls:Hide()
	end
end

function LSController:DeleteLingShou(cid)
	local ls = LSModel:GetLingShou(cid)
    if not ls then
        return
	end
	LSModel:DeleteLingShou(ls)
	ls:Delete()
end

function LSController:MoveTo(cid, x, y)
	local ls = LSModel:GetLingShou(cid)
    if not ls then
        return
	end
	ls:MoveTo(x, y)
end

function LSController:StopMove(cid, x, y, faceto)
	local ls = LSModel:GetLingShou(cid)
    if not ls then
        return
	end
	ls:StopMove(x, y, faceto)
end

function LSController:GetLingShou(cid)
	return LSModel:GetLingShou(cid)
end

function LSController:OnChangePos(msg)
	local cid = msg.roleId
	local x = msg.posX
	local y = msg.posY
	local ls = LSModel:GetLingShou(cid)
    if not ls then
        return
	end
	ls:SetPos(x, y)
end