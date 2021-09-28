



local _M = {}
_M.__index = _M




function _M.ShowActorNavi(parent,targetx,targety)
	DramaHelper.ShowActorNavi(targetx,targety,false)
	local r = parent:GetRootEvent()
	r:SetAttribute('ShowNavi',true)
end

function _M.ShowNavi(parent,fx,fy,tx,ty)
	DramaHelper.ShowNaviTwoPosition(fx,fy,tx,ty)
	local r = parent:GetRootEvent()
	r:SetAttribute('ShowNavi',true)
end

function _M.IsDecorationEnable(parent,name)
	return DramaHelper.IsDecorationEnable(name)
end




function _M.HideNavi(parent)
	DramaHelper.HideNavi()
	local r = parent:GetRootEvent()
	r:SetAttribute('ShowNavi',nil)
end


function _M.IsExistNavi(parent)
	return DramaHelper.IsExistNavi()
end




function _M.GetFlagPositon(parent,flag)
	return DramaHelper.GetFlagPositon(flag)
end



function _M.GetActorPostion(parent)
	local pt = DataMgr.Instance.UserData.Position
	return pt.x,pt.y
end



function _M.PlayEffect(parent,path,param)
	local id = DramaHelper.PlaySceneEffect(path,param)
	local r = parent:GetRootEvent()
	local effects = r:GetAttribute('PlayEffect') or {}
	effects[id] = true
	r:SetAttribute('PlayEffect',effects)
	return id
end



function _M.StopEffect(parent,id)
	DramaHelper.StopSceneEffect(id)
	local r = parent:GetRootEvent()
	local effects = r:GetAttribute('PlayEffect') or {}
	effects[id] = nil 	
end

function _M.InRockMove(parent)
	return DramaHelper.IsInRockMove()
end


function _M.StopSeek(parent)
	if GameSceneMgr.Instance.BattleRun and 
		 GameSceneMgr.Instance.BattleRun.BattleClient then
		GameSceneMgr.Instance.BattleRun.BattleClient:StopSeek()
	end	

	EventManager.Fire("Event.Delivery.Close", {})
end

function _M.Seek(parent,sceneId,pointerID)
	DataMgr.Instance.UserData:Seek(sceneId,pointerID)
end


function _M.GetCurrentSceneID(parent)
	return DataMgr.Instance.UserData.SceneId
end

function _M.GetCurrengMapID(parent)
 return DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)
end


function _M.IsSeekState(parent)
	return DataMgr.Instance.UserData:IsSeekState()
end


function _M.IsAutoFightState(parent)
	return DataMgr.Instance.UserData.AutoFight
end


function _M.SetAutoFight(parent,var)
	DataMgr.Instance.UserData.AutoFight = var
end

function _M.SetTempAutoFight(parent,var)
	local r = parent:GetRootEvent()
	if not r:HasAttribute('SetTempAutoFight') then
		r:SetAttribute('SetTempAutoFight',DataMgr.Instance.UserData.AutoFight)
	end	
	DataMgr.Instance.UserData.AutoFight = var
end


function _M.IsCombatState(parent)
	return DramaHelper.IsCombatState()
end




function _M.IsNearNpc(parent,npcid,r)
	
end


function _M._asyncWaitSeekEnd(self)
	self:AddTimer(function (delta)
		if not DataMgr.Instance.UserData:IsSeekState() then
			self:Done()
		end
	end,0.3)
	self:Await()		
end





function _M.HideAllUnit(parent,var)
	local r = parent:GetRootEvent()
	if var then
		r:SetAttribute('SetUnitHideType',BattleClientBase.HideType)
		local t = GameUtil.TryEnumToInt(BattleClientBase.UnitHideType.All)
		BattleClientBase.SetUnitHideType(t)
	else
		BattleClientBase.SetUnitHideType(r:GetAttribute('SetUnitHideType'))
		r:SetAttribute('SetUnitHideType',nil)
	end
end

function _M.Clear(parent)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	local effects = r:GetAttribute('PlayEffect') or {}
	for id,v in pairs(effects) do
		if v then
			DramaHelper.StopSceneEffect(id)
		end
	end
	if r:HasAttribute('ShowNavi') then
		DramaHelper.HideNavi()
	end
	if r:HasAttribute('SetUnitHideType') then
		BattleClientBase.SetUnitHideType(r:GetAttribute('SetUnitHideType'))
	end		

	if r:HasAttribute('SetTempAutoFight') then
		DataMgr.Instance.UserData.AutoFight = r:GetAttribute('SetTempAutoFight')
	end	
end

return _M
