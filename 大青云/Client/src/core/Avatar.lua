--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 15:29
--玩家，怪物, npc, horse以及一些有特效，动态属性，动作的游戏显示对象
_G.classlist['CAvatar'] = 'CAvatar'
_G.CAvatar = {};
_G.CAvatar.objName = 'CAvatar'
_G.CAvatar.defaultRotateTime = 350
local metaAvatar = {__index = CAvatar}

function CAvatar:new()
    local obj = {}
	obj.objNode = nil
    obj.objSceneMap = nil
    obj.avatarLoader = _Loader.new()
    obj.objMesh = _Mesh.new()
    obj.matTrans = _Matrix3D.new()
    obj.addedScene = false
	obj.airHeight = nil
    obj.setAllAction = {}
    obj.setAllPart = {}
    obj.vecSpeed = _Vector3.new(0,0,0)
    obj.fSpeed = 50
    obj.dwLastMoveTime = 0
    obj.dwLastRotTime = 0
    obj.funOnMoveDone = function() end
    obj.szIdleAction = ""
    obj.szMoveAction = ""
    obj.dwRotTime = 0
    obj.scaleValue = 1
    obj.objPP = _ParticlePlayer.new()
    obj.pickFlag = enPickFlag.EPF_Role
    obj.currSkillAnima = nil
    obj.currAnima = nil
    obj.jumpState = false
    obj.prepFlag = true
    obj.chanState = 0
    obj.prepState = 0
    obj.moveState = false
    obj.flyState = false
    obj.rollState = false
    obj.knockBackState = false
    obj.lastBezierTime = 0
	obj.sketch = false;
	obj.closeEffect = false;
	obj.closeEnvironment = false;
	obj.RotateTime = _G.CAvatar.defaultRotateTime
    obj.UpdateMove = CAvatar.UpdateMoveByRender
    obj.StopMove = CAvatar.StopMoveByRender
    obj.MoveTo = CAvatar.MoveToByRender
    setmetatable(obj, metaAvatar)
    return obj
end

function CAvatar:InitCAvatar()

	self.objNode = nil;
    self.objSceneMap = nil;
    --self.avatarLoader = _Loader.new()
    asyncLoad(true);
    self.objMesh = _Mesh.new()
	if self.matTrans then 
		self.matTrans:setTranslation(0,0,0) 
	else
		self.matTrans = _Matrix3D.new();
	end
    self.addedScene = false;
	self.airHeight = nil
	--动画列表
    self.setAllAction = {};
    --子模型列表
    self.setAllPart = {};
    --主节点，主玩家节点，用来做渲染优化
    ------------------------------
    --移动速度向量
    self.vecSpeed = _Vector3.new(0,0,0);
    self.fSpeed = 50;    --now server control this value
    self.dwLastMoveTime = 0;
    self.dwLastRotTime = 0;
    self.funOnMoveDone = function()end;
    --本次移动需要移动的距离
    --本次移动的目标位置
    self.szMeshFile = "";
    self.szSklFile = "";
    --待机动作
    self.szIdleAction = "";
    --走路动作
    self.szMoveAction = "";
    self.dwRotTime = 0;
    self.scaleValue = 1
    self.objPP = _ParticlePlayer.new() --播放跳字的特效播放器
    self.pickFlag = enPickFlag.EPF_Role;
    self.UpdateMove = self.UpdateMoveByRender;--设置成渲染更新位置
    self.StopMove = self.StopMoveByRender;--设置成渲染更新位置
    self.MoveTo = self.MoveToByRender;--设置成渲染更新位置

    self.currSkillAnima = nil
    self.currAnima = nil

    self.jumpState = false
    self.prepFlag = true
    self.chanState = 0
    self.prepState = 0
    self.moveState = false
    self.flyState = false
    self.rollState = false
    self.knockBackState = false
    self.lastBezierTime = 0
    

end

function CAvatar:Destroy()
    self:StopAllPfx()
    self:StopAllAction()
    if self.funOnMoveDone then
        self.funOnMoveDone = nil
    end
	if self.UpdateMove then
        self.UpdateMove = nil
    end
    if self.StopMove then
        self.StopMove = nil
    end
    if self.MoveTo then
        self.MoveTo = nil
    end
    if self.objSkeleton then
        self.objSkeleton:clearAnimas()
        self.objSkeleton.pfxPlayer:stopAll(true)
        self.objSkeleton.pfxPlayer:clearParams()
        self.objSkeleton = nil
    end
    local mesh = self.objMesh
    if mesh then
        if mesh.objBlender then
            mesh.objBlender:clear()
            mesh.objBlender = nil
        end
		if mesh.blender then
            mesh.blender:clear()
			mesh.blender = nil
		end
        if mesh.objHighLight then
            mesh.objHighLight:clear()
            mesh.objHighLight = nil
        end
        if mesh.objGray then
            mesh.objGray:clear()
            mesh.objGray = nil
        end
        self.objMesh:clearAnimas()
        self.objMesh:clearSubMeshs()
        self.objMesh = nil
    end
    if self.objPP then
        self.objPP:stopAll(true)
        self.objPP:clearParams()
        self.objPP = nil
    end
    if self.currAnima then
        self.currAnima:stop()
        self.currAnima = nil
    end
    self.starBezier = nil
    self.endBezier = nil
    self.controlPoint =nil
    self.nextPoint =nil
    self.bezierTime = nil
    self.lastBezierTime = nil
    self.bezierCallback = nil
    self.matTrans = nil
    self.currSkillAnima = nil
    self.szIdleAction = nil
    self.szMoveAction = nil
    self.vecSpeed = nil
    self.avatarLoader = nil
    self.pfxPlayerMat = nil
    self.useStoryPosZ = nil
    self.rect = nil
    self.decal = nil
    self.setAllAction = nil
    self.setAllPart = nil
    self.objMesh = nil
    self.objNode = nil
    self.vecPos = nil
    self = nil
end

function CAvatar:DrawMesh()
    self.objMesh:drawMesh()
end

function CAvatar:DrawDecal()
    if not self.objNode then
        return
    end

	if not self.objNode.visible then
        return
    end

	if self.objNode.dwType ~= enEntType.eEntType_Monster then
		if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
			return
		end
	end
	
	if _G.lightShadowQualitys[_G.lightShadowQuality].openDecalShadow == false then
		return
	end
	
    local vecPos = self:GetPos()
	if vecPos == nil then
        return
    end

    self.rect = self.rect or _Rect.new()

    local size = 6
    self.rect.x1 = vecPos.x - size
    self.rect.x2 = vecPos.x + size
    self.rect.y1 = vecPos.y - size
    self.rect.y2 = vecPos.y + size

    local terrain = self.objSceneMap.objScene.terrain
    local layer = terrain.heightLayer
    terrain.heightLayer = 1
    self.decal = terrain:buildDecal(self.objSceneMap.commShadowImg, 
        _Color.Gray,
        self.rect, self.decal)
    terrain.heightLayer = layer

    if self.decal then
	   self.decal:drawMesh()	
    end
end

function CAvatar:ResetTerrain()
    self:GetSkl().pfxPlayer.terrain = self.objSceneMap.objScene.terrain;
end

function CAvatar:GetSkl()
    return self.objSkeleton
end

function CAvatar:GetBoneCount()
	if self.objSkeleton == nil then
		return 0;
	end
    return self.objSkeleton:getBoneCount();
end

function CAvatar:GetFaceCount()
	if self.objMesh == nil then
		return 0;
	end
	return self.objMesh:getFaceCount();
end

function CAvatar:GetStatInfo()
	return "[Face:" .. self:GetFaceCount() .. "][Bone:" .. self:GetBoneCount() .. "]";
end

local vec = _Vector3.new();
function CAvatar:EnterSceneMap(objSceneMap,vecPos,fDirValue)
    --Debug("CEntity:EnterSceneMap()")

	if not objSceneMap then
        Debug("CEntity:EnterSceneMap() not objSceneMap")
        return
    end
    if not objSceneMap.getSceneHeight then
        Debug("CEntity:EnterSceneMap() not objSceneMap.getSceneHeight")
        return
    end
    if self.matTrans ~= nil then
        self.matTrans:identity();
    else
        self.matTrans = _Matrix3D.new();
    end
    if vecPos then
        vec.x, vec.y = vecPos.x,vecPos.y;
		local offsetZ = vecPos.z or 0
		if self.airHeight and self.airHeight ~= 0 then
			offsetZ = offsetZ + self.airHeight
		end
        local hight = objSceneMap:getSceneHeight(vec.x, vec.y)
		if hight == nil then return end; -- bad state
        vec.z = hight + offsetZ;
        self.matTrans:setTranslation(vec);
    end;
    if fDirValue then
        vec.x, vec.y, vec.z = 0,0,1;
        self.matTrans:mulRotationLeft(vec,fDirValue);
    end;
    if self.objNode then self.objNode = nil end
    self.objNode = objSceneMap:AddEntity(self, self.matTrans);
    if self.cfgScale then
        self.scaleValue = 1
        self:SetScale(self.cfgScale)
    end
    if not self.objNode then
        assert(false)
    end;
	-- Debug("check it: 0", self.avatarLoader.progress)
	--print("check it: 0", self.avatarLoader.progress)
	self.showClipperTime = GetCurTime()
	
	---时间问题，引擎有问题
    if not self.avatarLoader.unShowLoading and self.avatarLoader.progress ~= 1 then
        -- Debug("check it: 1", self.avatarLoader.progress)
		-- print("check it: 1", self.avatarLoader.progress)
        self.objMesh:onDrawMesh(function(m)
			if GetCurTime() - self.showClipperTime >= 500 then
				local p = (_G.aabb.z2 - _G.aabb.z1) * self.avatarLoader.progress + self:GetPos().z
				-- Debug("check it: 2", self.avatarLoader.progress, p)
				--print("check it: 2", self.avatarLoader.progress, p)
				_G.c1:clipZPositive(p)
				_G.c2:clipZNegative(p)

				_rd:useClipper(c1)
				_G.dummy1:drawMesh()
				_rd:popClipper()

				_rd:useClipper(c2)
				_G.dummy2:drawMesh()
				_rd:popClipper()
			end		
        end)
    end
    self.avatarLoader:onFinish(function()
        -- Debug("self.avatarLoader:onFinish")
		-- print(debug.traceback())
		if self.objPlayer and self.objPlayer.onAvatarLoadCompleted then 
			self.objPlayer:onAvatarLoadCompleted() 
		end
        if self.objMesh then self.objMesh:onDrawMesh() end
    end)
    self.objSceneMap = objSceneMap;
    self.objPP.terrain = self.objSceneMap.objScene.terrain;
	if self.objSkeleton then
		self.objSkeleton.pfxPlayer.terrain = self.objSceneMap.objScene.terrain; --设置播放地表粒子时的地表信息
	end
    if self.horse then
        self.horse.objSkeleton.pfxPlayer.terrain = self.objSceneMap.objScene.terrain
    end
    self.objNode.entity = self
    self.objNode.isEntity = true
    self.addedScene = true ---表明已经进入场景
    self:OnEnterScene(self.objNode);
    return self.objNode;
end;

function CAvatar:EnterSceneMapByTransform(objSceneMap, trans)
    --Debug("CEntity:EnterSceneMap()")
    if not objSceneMap then return end;
    self.matTrans = trans:clone()
    self.objNode = objSceneMap:AddEntity(self, self.matTrans);
    if not self.objNode then
        Error("AddEntity Fail :CEntity:EnterSceneMap");
        return;
    end;
    self.objSceneMap = objSceneMap;
    self:GetSkl().pfxPlayer.terrain = self.objSceneMap.objScene.terrain; --设置播放地表粒子时的地表信息
    self.objNode.entity = self;

    self:OnEnterScene(self.objNode);
    return self.objNode;
end;

function CAvatar:ExitSceneMap()
    if not self.objSceneMap then return end
    self.objNode.entity = nil
    self.objSceneMap:DelEntity(self)
    self.objSceneMap = nil
    self.addedScene = false
    self.objNode = nil
	self.airHeight = nil
	if self.objPlayer then
        self.objPlayer = nil
    end
end

--驱动--
local boneVecPos = _Vector3.new()
function CAvatar:Update(e)
    self:UpdateMove(e);
    self:OnUpdate(e);
    self:UpdateBezier(e)
    if self.Control then
		if self.controlBySkn then
			if self.objSkeleton and self.objSkeleton:getBone("beatpoint") then
				local boneMat = self.objSkeleton:getBone("beatpoint")
				boneMat.parent = self.objNode.transform
				boneMat:getTranslation(boneVecPos)
				self.Control:UpdateCameraPos(boneVecPos, true);
				-- FPrint('beatpoint镜头跟随')
			else
				self.Control:UpdateCameraPos(self:GetPos());
			end
		else
			self.Control:UpdateCameraPos(self:GetPos());
		end
		CPlayerMap:ComputeChangeMap();
    end;
    self:updateScaling()
end;

local s_bonePos = _Vector3.new()
function CAvatar:GetCameraFollowLook()
	local boneMat = self.objSkeleton:getBone("beatpoint")
	boneMat.parent = self.objNode.transform
	boneMat:getTranslation(s_bonePos)
	
	return s_bonePos
end

function CAvatar:OnUpdate(e)

end;

--进入地图
function CAvatar:OnEnterScene(objNode)

end;

function CAvatar:IsInMap()
    if (self.objNode) and (self.objSceneMap) then
        return true
    end
    return false
end

function CAvatar:GetPos()
    if not self.vecPos then
        self.vecPos = _Vector3.new()
    end
    if self.objNode and self.objNode.transform then
        self.objNode.transform:getTranslation(self.vecPos)
        return self.vecPos
    end
    if self.objMesh and self.objMesh.transform then
        self.objMesh.transform:getTranslation(self.vecPos)
        return self.vecPos
    end
    --Error("self.objNode nil By CEntity:SetPos")
    --Error(debug.traceback())
    return nil
end

--设置实体的位置 
--time参数添加给创建角色使用
local tar, cur, dis = _Vector3.new(), _Vector3.new(), _Vector3.new()
function CAvatar:SetPos(tabPos, time)
	if not self.objSceneMap then return; end
    tar.x, tar.y, tar.z = tabPos.x, tabPos.y, tabPos.z
    if self.objNode then
        self.objNode.transform:getTranslation(cur)
        tar.z = self.objSceneMap:getSceneHeight(tar.x, tar.y)
		if self.airHeight and self.airHeight ~= 0 then
			tar.z = tar.z + self.airHeight
		end
        _Vector3.sub(tar, cur, dis)
        self.objNode.transform:mulTranslationRight(dis, time)
    elseif self.objMesh then
        self.objMesh.transform:getTranslation(cur)
        tar.z = self.objSceneMap:getSceneHeight(tar.x, tar.y)
		if self.airHeight and self.airHeight ~= 0 then
			tar.z = tar.z + self.airHeight
		end
        _Vector3.sub(tar, cur, dis)
        self.objMesh.transform:mulTranslationRight(dis, time)
    else
        Error("self.objNode nil By CEntity:SetPos")
        Error(debug.traceback())
    end
end

--获取实体的朝向
local rotationRot = _Vector4.new()
function CAvatar:GetDirValue()
    -- if not self.rot then
    -- end
    if self.objNode then
        self.objNode.transform:getRotation(rotationRot)
    elseif self.objMesh then
        self.objMesh.transform:getRotation(rotationRot)
    end
    if rotationRot then
    	local dir = rotationRot.r
    	if rotationRot.z < 0 then
    	    dir = 2 * math.pi - dir
    	end
    	return dir
    end
end

function CAvatar:GetDir()
    return self:GetDirValue()
end

--设置实体的朝向
local axis = _Vector3.new(0,0,1)
local currRot = _Vector4.new()
function CAvatar:SetDirValue(tar, nTime)
    if not self.objNode then
        Error("self.objNode nil By CEntity:SetDirValue");
		Error(debug.traceback())
        return nil;
    end;
    self.objNode.transform:getRotation(currRot);
    local cur = currRot.r;
    if currRot.z < 0 then
        cur = 2*math.pi - cur;
    end;
    --Debug("CEntity:SetDirValue ", cur, tar)
    self.objNode.transform:mulRotationLeft(axis,tar - cur, nTime);
end;

--世界空间矩阵

function CAvatar:GetTransform()
    return self.objNode.transform;
end


--------------------------------------------------------------------------------
--particle
--------------------------------------------------------------------------------
--特效播放相关
local defMat = _Matrix3D.new()
local mat = _Matrix3D.new()
function CAvatar:PlayerPfx(dwPfxID)
    local pfxCfg = ResPfxConfig[dwPfxID]
    if not pfxCfg then
        return
    end
    mat:setTranslation(0, 0, 0)
    return self:PlayerPfxByMat(dwPfxID, mat)
end

function CAvatar:PlayerPfxByMat(dwPfxID, mat)
    local pfxCfg = ResPfxConfig[dwPfxID]
    if not pfxCfg then
        return
    end
    self:DoPfxPlayer(tostring(dwPfxID), pfxCfg, mat)
    return tostring(dwPfxID)
end

local axisx = _Vector3.new(1, 0, 0)
local axisy = _Vector3.new(0, 1, 0)
local axisz = _Vector3.new(0, 0, 1)
function CAvatar:DoPfxPlayer(szName, pfxCfg, mat)
    if mat then
        if pfxCfg.RotationStart then
            if pfxCfg.RotationStart.x > 0 then
                mat:mulRotationLeft(axisx, pfxCfg.RotationStart.x)
            end
            if pfxCfg.RotationStart.y > 0 then
                mat:mulRotationLeft(axisy, pfxCfg.RotationStart.y)
            end
            if pfxCfg.RotationStart.z > 0 then
                mat:mulRotationLeft(axisz, pfxCfg.RotationStart.z)
            end
        end

        if pfxCfg.RotationStop then
            if pfxCfg.RotationStop.x > 0 then
                mat:mulRotationLeft(axisx, pfxCfg.RotationStop.x, pfxCfg.RotationTime)
            end
            if pfxCfg.RotationStop.y > 0 then
                mat:mulRotationLeft(axisy, pfxCfg.RotationStop.y, pfxCfg.RotationTime)
            end
            if pfxCfg.RotationStop.z > 0 then
                mat:mulRotationLeft(axisz,pfxCfg.RotationStop.z,pfxCfg.RotationTime)
            end
        end

        if pfxCfg.ScalingStart then
            mat:mulScalingLeft(pfxCfg.ScalingStart)
        end

        if pfxCfg.ScalingStop then
            mat:mulScalingLeft(pfxCfg.ScalingStop, pfxCfg.ScalingTime)
        end

        if pfxCfg.MoveStart then
            mat:mulTranslationRight(pfxCfg.MoveStart)
        end
        if pfxCfg.MoveStop then
            mat:mulTranslationRight(pfxCfg.MoveStop,pfxCfg.MoveTime)
        end
    end
    local pfx = self:SklPlayPfx(szName, pfxCfg.pfxName)
    if not pfx then
        return
    end
    if mat then
        pfx.transform:set(mat)
    end
    return szName
end

function CAvatar:PlayerPfxOnSkeleton(szName, mat)
    local pfx = self:SklPlayPfx(szName, szName)
    if not pfx then
        return
    end
    if mat then
        pfx.transform:set(mat)
    end
    return pfx
end

function CAvatar:PlayPfxOnBone(szBindPoint, logicname, resname)
    local pfx = self:SklPlayPfx(logicname, resname)
    if not pfx then
        return
    end
    local skl = self:GetSkl()
    if szBindPoint and szBindPoint ~= "" then
        local BindMat  = skl:getBone(szBindPoint)
        if BindMat then
            pfx.transform = BindMat
        end
    end
end

--播放绑定在骨骼上的特效
--自动取骨骼(特效mingdeng_02.pfx,骨骼pfx_mingdeng_02)
function CAvatar:PlayPfxOnBindBone(szName)
    if not szName:find(".pfx$") then
        return
    end
    local boneName = string.sub(szName, 1, #szName-4)
    boneName = "pfx_" .. boneName
    self:PlayPfxOnBone(boneName, szName, szName)
end

function CAvatar:StopPfxByName(logicName, notstopnow)
    if not self.objMesh then
        return
    end
    local skl = self:GetSkl()
    if not skl then
        return
    end
    if notstopnow then
        skl.pfxPlayer:stop(logicName, false)
    else    
        skl.pfxPlayer:stop(logicName, true)
    end
end

--停止一个特效，参数为上面执行返回的ID
function CAvatar:StopPfx(dwID)
    if not dwID or dwID == 0 then
        return
    end
    if not self.objMesh then
        return
    end
    local skl = self:GetSkl()
    if not skl then
        return
    end
    local szName = tostring(dwID)
    skl.pfxPlayer:stop(szName, true)
end

function CAvatar:StopAllPfx()
    if not self.objMesh then
        return
    end
    local skl = self:GetSkl()
    if not skl then
        return
    end
    skl.pfxPlayer:stopAll(true)
    skl.pfxPlayer:clearParams()
    if self.objPP then
        self.objPP:stopAll(true)
    end
end

--设置放大倍数，
function CAvatar:SetScale(scaleValue)
    if self.scaleValue == scaleValue then
        return
    end
    if self.objNode then
        local oldScaleValue = self.scaleValue
        self.scaleValue = scaleValue
        local tempScaleValue = 1 / oldScaleValue * scaleValue
        self.objNode.transform:mulScalingLeft(tempScaleValue, tempScaleValue, tempScaleValue)
    end
end

function CAvatar:SetCfgScale(cfgScale)
    self.cfgScale = cfgScale
end

function CAvatar:GetScale()
    return self.scaleValue
end

--更换骨骼
function CAvatar:ChangeSkl(dwSklID)
	-- FPrint('更换骨骼更换骨骼更换骨骼更换骨骼'..dwSklID)
    if self.objMesh == nil then
		-- FPrint('更换骨骼更换骨骼更换骨骼更换骨骼self.objMesh == nil'..dwSklID)
        return ;
    end;
    self.objSkeleton = nil;
    self.objSkeleton = self.objMesh:attachSkeleton(dwSklID);
    -- TODO.
    if not self.objSkeleton then
        self.objSkeleton = nil
        LuaGC()
        self.objSkeleton = self.objMesh:attachSkeleton(dwSklID);
    end
    if not self.objSkeleton then
        local errorMsg = "skeleton change skl attachSkeleton nil " .. dwSklID .. "  memUsage = " .. _sys.memUsage
        _debug:throwException(errorMsg)
        return
    end
    self.objSkeleton:ignoreShake(true);
	
	if self.sketch then
		self:StopAllPfx();
	end
	
	if self.closeEffect then
		self:StopAllPfx();
	end
	
end;

--渲染跳血掉字
local dir, pos = _Vector3.new(), _Vector3.new()
local mat = _Matrix3D.new()
local wMat = _Matrix3D.new()
local pos2d = _Vector2.new()
local pos3d = _Vector3.new()
local scale3d = _Vector3.new()
local scale3 = _Vector3.new()
local sca = _Vector3.new()
local zaxis = _Vector3.new(-1, 0, 0)
function CAvatar:RenderSkipNumber(param)
    if not self.objSceneMap then
        return
    end
    local skl = self:GetSkl()
    if not skl then
        return
    end

    local sPfxInfo = SkipFontConfig[param.config]
    if not sPfxInfo then
        return
    end
    if not sPfxInfo.BindPos then
        return
    end
    if not sPfxInfo.PfxName then
        return
    end
    local cfgImage = sPfxInfo.Num
    local txtLen = 1
    local arrNum = {}
    if param.text then
        arrNum[txtLen]= cfgImage[param.text]
        txtLen = txtLen + 1
    end
    
    if param.number then
        local szTemp = tostring(param.number)
        local nLen = string.len(szTemp)
        for nY = 1, nLen do
            local szIndex = string.char(szTemp:byte(nY))
            if cfgImage[szIndex] then
                arrNum[txtLen] = cfgImage[szIndex]
                txtLen = txtLen + 1
            end
        end
        if cfgImage["shandian"] then
            arrNum[txtLen] = cfgImage["shandian"]
            txtLen = txtLen + 1
        end
        if cfgImage["sp"] then
            arrNum[txtLen] = cfgImage["sp"]
            --txtLen = txtLen + 1
        end
    end

    _Vector3.sub( _rd.camera.look, _rd.camera.eye, dir)
    local vecPos = self:GetPos()
    mat:setTranslation(vecPos.x, vecPos.y, vecPos.z)
    local boneMat = skl:getBone(sPfxInfo.BindPos)
    if boneMat then
        boneMat:getTranslation(pos)
        mat:mulTranslationRight(pos)
        --boneMat:getScaling(sca)
        --mat:mulScalingLeft( 1 / sca.x, 1 / sca.y, 1 / sca.z )
    end
    mat:mulFaceToLeft(0, -1, 0, dir.x, dir.y, dir.z)
    local pfx = self.objPP:play(sPfxInfo.PfxName)
    pfx.transform:set(mat)
    pfx.keepInPlayer = false
    pfx.transform.ignoreScaling = true

    local offset = 0
    if arrNum[1] and arrNum[2] and (arrNum[1].h - arrNum[2].h > 0) then
        offset = (arrNum[1].h - arrNum[2].h) / 2
    end

    if next(arrNum) then
        local emitters = pfx:getEmitters()
        if emitters and emitters[1] then
            emitters[1]:onRender( function()
                _rd:pop3DMatrix(wMat)
                wMat:getTranslation(pos3d)
                wMat:getScaling(scale3d)
                _rd:projectPoint(pos3d.x, pos3d.y, pos3d.z, pos2d)
                _rd:push3DMatrix(wMat)
                local x = pos2d.x
                local y = pos2d.y
                for i, v in pairs(arrNum) do
                    if i == 1 then
                        v:drawImage( x, y, x + v.w * scale3d.x, y + v.h * scale3d.x)
                        x = x + v.w * scale3d.x
                    else
                        v:drawImage(x, y + offset * scale3d.x, x + v.w * scale3d.x, y + offset * scale3d.x + v.h * scale3d.x)
                        x = x + v.w * scale3d.x                    
                    end
                end
            end)
        end
    end
	param = nil
end
------------------------------------------
--设置部件
------------------------------------------
function CAvatar:SetPart(szName,szMeshFile,unfmt)
	
    if not self.objMesh then
        return
    end
    if not szName or szName == "" then
        return;
    end;
	
	local mshs = GetPoundTable(szMeshFile);
	if mshs and #mshs>1 then
		for i,msh in ipairs(mshs) do
			self:SetPart(msh,msh,unfmt);
		end
		return;
	end
	
    if self.setAllPart[szName] then --已经有了
        self.objMesh:delSubMesh(szName);
        self.setAllPart[szName] = nil;
    end;

    if not szMeshFile or szMeshFile == "" then
        if szName == "Face" then  --for wuhun change face biz
            Debug("#################ok we got it reset default face")
            szMeshFile = self.defaultFaceMeshFile;
        elseif szName == "Hair" then
            Debug("#################ok we got it reset default Hair")
            szMeshFile = self.defaultHairMeshFile;
        else
            return;
        end
    end;
    --_startTiming()

    asyncLoad(true);
    local SubMesh = _Mesh.new(szMeshFile);

    SubMesh.name = szName;
    --SubMesh.isPaint = true
    self.objMesh:addSubMesh(SubMesh);

    self.setAllPart[szName] = SubMesh;
	
	local new = false;
	if not unfmt then
		local mn = FileFormatTransform(szMeshFile,'fmt');
		if mn then
			if _sys:fileExist(mn,false) then
				SubMesh.sketch = self.sketch;
				SubMesh.closeEnvironment = self.closeEnvironment;
				SubMesh:loadLMaterialManager(mn);
				new = true;
			end
		end
	end
	
	if not new then
		SubMesh:enumMesh('', true, function(mesh, name) 				--Old
			--Debug('mesh: ', mesh, name)
			local i = mesh:getTexture(0)
			if i and i.resname ~= '' then 
				--Debug(i, i.resname)
				local spemap = i.resname:gsub('.dds$','_h.dds')
				--Debug('spemap ', spemap)
				if spemap and spemap:find('dds') and spemap:find('_h') and _sys:fileExist(spemap, true) then
					--Debug('avatar set specularmap: ', spemap)
					mesh:setSpecularMap(_Image.new(spemap))
				end
						
			end
		end)
	end
	
    if szName == "Face" then  --for wuhun change face biz
        if self.defaultFaceMeshFile == nil then
            self.defaultFaceMeshFile = szMeshFile
        end
    elseif szName == "Hair" then
        if self.defaultHairMeshFile == nil then
            self.defaultHairMeshFile = szMeshFile
        end
    end

    --_app.console:print('  Load ' .. szMeshFile .. ' takes ' .. _stopTiming() .. 'ms')
    
    return SubMesh
end;

function CAvatar:DeleteMesh(szName)
    if self.setAllPart[szName] then
        self.objMesh:delSubMesh(szName)
        self.setAllPart[szName] = nil
    end
end

function CAvatar:AddSubMesh(subMeshFile)
    if not subMeshFile or string.len(subMeshFile) <= 0 then
        return
    end
    asyncLoad(true);
    local subMesh = _Mesh.new(subMeshFile)
    --subMesh.isPaint = true
    self.objMesh:addSubMesh(subMesh)
end


local tar, cur, dir = _Vector3.new(), _Vector3.new(), _Vector3.new()
local mat = _Matrix3D.new()
local tabCurRot = _Vector4.new(); local tabTarRot = _Vector4.new();
-- isPlayMoveAction 为true时不播放移动动作
function CAvatar:MoveToByRender(tabPos, funOnMoveDone, fSpeed, bUseCanTo, isPlayMoveAction, dwDis)
    if not self.objNode then 
        return
    end
    if funOnMoveDone then
        self.funOnMoveDone = funOnMoveDone
    end
    --设置移动速度
    if fSpeed == nil then assert(false, "Fuck") end
    self.fSpeed = fSpeed
    self.bUseCanTo = bUseCanTo

    --计算位移距离
    self.objNode.transform:getTranslation(cur)
    tar.x,tar.y,tar.z = tabPos.x, tabPos.y, tabPos.z
    dir.x,dir.y,dir.z = tar.x - cur.x, tar.y - cur.y, 0
    local dwDist = dir:magnitude()
    dir:normalize()
    dwDis = dwDis and dwDis or 0.01
    dwDis = dwDis == 50 and 20 or dwDis
    if math.abs(dwDist) < dwDis then
        self.dwLastMoveTime = 0
		self.funOnMoveDone = nil;
		if funOnMoveDone then
			funOnMoveDone();
		end
    else
        self.moveState = true
        if self.dwLastMoveTime == 0 then
            if self.chanState ~= ChanSkillState.StateInit then
            else
                if not isPlayMoveAction then
                    self:ExecMoveAction()
                end
            end
        end

        --计算位移时间
        _Vector3.mul(dir, self.fSpeed / 1000, self.vecSpeed)
        self.dwLastMoveTime = (dwDis == 0.01) and dwDist / (self.fSpeed / 1000) or (dwDist - dwDis) / (self.fSpeed / 1000)
        --计算转向时间
        self.objNode.transform:getRotation(tabCurRot)
        local dwCurRot = tabCurRot.r * tabCurRot.z
        mat:setFaceTo(0, -1, 0, dir.x, dir.y, 0):getRotation(tabTarRot)
        local dwTarRot = tabTarRot.r * tabTarRot.z
        local dwRadian = dwTarRot - dwCurRot
        if math.abs(dwRadian) < 0.01 then
            self.dwLastRotTime = 0
        else
            if dwRadian < -math.pi then 
                dwRadian = dwRadian + 2 * math.pi
            end
            if dwRadian > math.pi then
                dwRadian = dwRadian - 2 * math.pi
            end
            self.dwLastRotTime = self.RotateTime
            self.dwRotSpeed = dwRadian/(self.dwLastRotTime)
        end
    end
end

function CAvatar:StopMoveByRender(vecPos, dwDir)
    if not self.objNode then
        return
    end
    self.moveState = false
    self:StopMoveAction()

    self.dwLastMoveTime = 0
    self.vecSpeed.x, self.vecSpeed.y, self.vecSpeed.z = 0, 0, 0
    if vecPos then
        self:SetPos(vecPos)
    end

    self.dwLastRotTime = 0
    self.dwRotSpeed = 0
    if dwDir then
        self:SetDirValue(dwDir)
    end
end

function CAvatar:UpdateMoveByRender(dwInterval)
    -- Debug("UpdateMoveByRender ", dwInterval, self.dwLastMoveTime)
    if self.dwLastMoveTime > 0 then
        if self.dwLastMoveTime > dwInterval then
            --local intervalTime = dwInterval;
            self.dwLastMoveTime = self.dwLastMoveTime - dwInterval;
            self:UpdatePosByRender(dwInterval);
        else
            local intervalTime = self.dwLastMoveTime;
            self.dwLastMoveTime = 0;
            self:UpdatePosByRender(intervalTime);
            --self:StopMoveByRender()
            if self.funOnMoveDone and not self:funOnMoveDone() then
                self.funOnMoveDone = nil;
            end
        end;
    end;

    if self.dwLastRotTime > 0 then
        if self.dwLastRotTime > dwInterval then
            self:UpdateRotByRender(dwInterval);
            self.dwLastRotTime = self.dwLastRotTime - dwInterval;
        else
            self:UpdateRotByRender(self.dwLastRotTime);
            self.dwLastRotTime = 0;
        end;
    end;
end;

local addpos, curpos, tarpos = _Vector3.new(), _Vector3.new(), _Vector3.new()
function CAvatar:UpdatePosByRender(dwInterval)
    if not self.objNode then
        return
    end

    --计算下一步位移的位置
    _Vector3.mul(self.vecSpeed,dwInterval,addpos)
    self.objNode.transform:getTranslation(curpos)
    _Vector3.add(curpos, addpos, tarpos)
    tarpos.z = self.objSceneMap:getSceneHeight(tarpos.x, tarpos.y)
    addpos.z = (tarpos.z or 0) - (curpos.z or 0)
	if self.airHeight and self.airHeight ~= 0 then
		addpos.z = addpos.z + self.airHeight
	end
	if self.useStoryPosZ then--剧情巡逻的强制高度
		addpos.z = 0
	end
	--判断该位置是否可到达
    if self:CheckCanPass() == false then
        local bPass = self.objSceneMap:CanMoveTo(curpos, tarpos)
        if not bPass then
            MainPlayerController:OnCannotMove()
            return
        end
    end
    --实施位移
    self.objNode.transform:mulTranslationRight(addpos)
     --触发地图上位置改变
    if self.objPlayer then
        self.objPlayer:OnPosChange(tarpos)
    end
end

local axis = _Vector3.new(0,0,1);
function CAvatar:UpdateRotByRender(dwInterval)
    if not self.objNode then return end;
    local dwRot = self.dwRotSpeed * dwInterval;
    self.objNode.transform:mulRotationLeft(axis,dwRot);
end

function CAvatar:UpdateSpeed(fSpeed)
	if self.objNode and self.objNode.bIsMe then
		if StoryController:IsStorying() then
			return
		end
	end

    if self.dwLastMoveTime > 0 then
        self.dwLastMoveTime = self.dwLastMoveTime * self.fSpeed / fSpeed
        _Vector3.mul(self.vecSpeed,fSpeed / self.fSpeed,self.vecSpeed)
    end
    self.fSpeed = fSpeed
    if fSpeed == 0 then
        self:StopMoveByRender()
    end
end

function CAvatar:GetAnimaFile(dwAnimaID)

end

--高亮相关函数
function CAvatar:SetHighLight(dwLightColor)
    if not self.objMesh then
        return
    end
    if self.objMesh.objHighLight then
        self:DelHighLight()
    end
    self.objMesh.objHighLight = _Blender.new()
    self.objMesh.objHighLight:highlight(dwLightColor)
end

function CAvatar:DelHighLight()
    if self.objMesh then
        self.objMesh.objHighLight = nil
    end
end


function CAvatar:SetSelectLight(objSelectLight)
    if self.objMesh then
        _Vector3.sub(_rd.camera.look, _rd.camera.eye, objSelectLight.direction)
        self.objMesh.objSelectLight = objSelectLight
    end
end

function CAvatar:DeleteSelectLight()
    if self.objMesh then
        self.objMesh.objSelectLight = nil
    end
end

function CAvatar:SetGray(from, to)
    if not self.objMesh then
        return
    end
    if self.objMesh.objGray then
        self:DeleteGray()
    end
    self.objMesh.objGray = _Blender.new()
    self.objMesh.objGray:gray(from, to)

end

function CAvatar:DeleteGray()
    if self.objMesh then
        self.objMesh.objGray = nil
    end
end

function CAvatar:SetBlender(color)
    if not self.objMesh then
        return
    end
    if self.objMesh.objBlender then
        self:DeleteBlender()
    end
    self.objMesh.objBlender = _Blender.new()
    self.objMesh.objBlender:blend( color )
end

function CAvatar:DeleteBlender()
    if self.objMesh then
        self.objMesh.objBlender = nil
    end
end

function CAvatar:PlaySkillAction(animaFile, loop, stopCallback)
    self.skillPlaying = true
    local callback = function(...)
        self.skillPlaying = false
        if stopCallback then
            stopCallback(...)
			stopCallback = nil
        end
    end
    local nResCode, anima = self:ExecAction(animaFile, loop, callback)
    if not nResCode or nResCode < 0 then
        local errorMsg = "avatar execAction " .. animaFile
        _debug:throwException(errorMsg)
    else
        self.currSkillAnima = anima
    end
    return nResCode, animaFile, anima
end

function CAvatar:GetAnimation(name,removeold)
	if not name or name == "" then
		return
	end
	
	local anima = self.setAllAction[name];
	if removeold then
		if self.currAnima then
			self:GetSkl():delAnima(self.currAnima.logicName);
			self.setAllAction[self.currAnima.logicName] = nil;
			self.currAnima.logicName = nil;	
			self.currAnima = nil;	
		end
		self:GetSkl():delAnima(name);
		self.setAllAction[name] = nil;
		anima = nil;
		self:StopAllAction();
	end
	
    if not anima then
        --Debug("first load anima", name)
        asyncLoad(true);  -- 异步
        anima = self:GetSkl():addAnima(name)
        if not anima then
            local errorMsg = "skeleton addAnima nil " .. name .. "  memUsage = " .. _sys.memUsage
            _debug:throwException(errorMsg)
            return
        end
        self.setAllAction[name] = anima
		anima.logicName = name;
    end
    return anima
end

function CAvatar:GetAnimaByFileName(fileName)
    return self.setAllAction[fileName]
end

--执行某个动作
function CAvatar:ExecAction(name, loop, callback,removeold)
    local skl = self:GetSkl()
    if not skl then
        return
    end
    if self.objSceneMap and self.objSceneMap.objScene then
        if skl.pfxPlayer
            and skl.pfxPlayer.terrain == nil then
            skl.pfxPlayer.terrain = self.objSceneMap.objScene.terrain;
            Debug("pfx reset terrain.")
        end
        --TODO 如果骑乘战斗时，decal播放不正确，需要对坐骑骨骼例子播放器做同上处理
    end
    local anima = self:GetAnimation(name,removeold)
	if not anima then
		return
	end
    if self.currAnima == anima and anima.loop == true and anima.isPlaying then
        return anima.duration, anima
    end
    anima:stop()
    anima:stopPfxEvents(true)

    anima:onStop(function()
        if callback then
            callback(self, anima)
			callback = nil
        end
        asyncLoad(true);
    end)

    anima:onEvent(function(e)
        return self:EventCallback(e)
    end)
	
    anima:play()
    anima.loop = loop or false
    self.currAnima = anima
    return anima.duration, anima
end

function CAvatar:EventCallback(e)
	self:DoExtendAnima(e);
    local eventName = string.sub(e, 1, 3)
    if eventName == "sfx" then     -- 技能音效
        if not (self.objNode and self.objNode.bIsMe) or SoundManager.objSfxPlayer.volume <= 0 then
            return true
        end
    elseif eventName == "pfx" then
        if self:IsHidePfx() then
            return true
        end
    end
    return false
end

function CAvatar:DoExtendAnima(event)
end

--设置默认待机动画
function CAvatar:SetIdleAction(szDefAnmFile, bIsExec)
    if self.szIdleAction ~= szDefAnmFile and szDefAnmFile and szDefAnmFile ~= "" then
        if bIsExec then
           self:StopIdleAction()
        end
        self.szIdleAction = szDefAnmFile
    end
    if bIsExec then
        self:ExecIdleAction()
    end
end

function CAvatar:GetIdleAction()
    return self.szIdleAction
end

--设置走路动作
function CAvatar:SetMoveAction(szMoveAction)
    if self.szMoveAction ~= szMoveAction and szMoveAction and szMoveAction ~= "" then
        --if self.moveState then
           self:StopMoveAction()        
        --end
        self.szMoveAction = szMoveAction
    end
    if self.moveState then
        self:ExecMoveAction()
    end
end

--获取当前移动动作
function CAvatar:GetMoveAction()
    return self.szMoveAction
end

--获取当前移动状态
function CAvatar:GetMoveState()
    return self.moveState
end

--播放默认动作
function CAvatar:ExecIdleAction()
    self:ExecAction(self.szIdleAction, true)
end

function CAvatar:StopIdleAction()
    self:StopAction(self.szIdleAction)
end

--播放位移动作
function CAvatar:ExecMoveAction()
    self:ExecAction(self.szMoveAction, true)
end

function CAvatar:StopMoveAction()
    self:StopAction(self.szMoveAction)
end

--停止动作
function CAvatar:StopAction(szActionName)
    if not self:GetSkl() then
        return
    end
    local anima = self.setAllAction[szActionName]
    if not anima then
        return
    end
    if anima.isPlaying then
        anima:stop()
        anima:stopPfxEvents(true)
    end
end

--停止动作但是不停止特效
function CAvatar:StopActionNotStopPfx(szActionName)
    if not self:GetSkl() then
        return
    end
    local anima = self.setAllAction[szActionName]
    if not anima then
        return
    end
    if anima.isPlaying then
        anima:stop()
    end
end

--停止所有动作
function CAvatar:StopAllAction()
	DestroyTbl(self.setAllAction)
    local skl = self:GetSkl()
    if not skl then
        return
    end
    skl:clearAnimas()
    skl:stopAnimas()
end

function CAvatar:StopCurrSkillAction()
    if not self.currSkillAnima then
        return
    end
    self.currSkillAnima:stop()
    self.currSkillAnima:stopPfxEvents(true)
end

--暂停当前所有动作
function CAvatar:PauseCurrAnima(isPause)
    local skl = self:GetSkl()
    if not skl then
        return
    end
    local animas = skl:getAnimas()
    if animas then
        for i = 1, #animas do
            animas[i].pause = isPause
        end
    end
end

function CAvatar:IsHidePfx(skillId)
    if self.noPfx then
        return true
    end
    if not self:IsInMap() then
        return false
    end
    if ArenaBattle.arenaState then
        return false
    end
    if AutoBattleController.isAutoHidePfx == true then
        return true
    end
    if SetSystemController.hidePfx and not (self.objNode and self.objNode.bIsMe) then
        return true
    end
    if skillId then
        local skillConfig = t_skill[skillId]
        if skillConfig and skillConfig.showtype == SkillConsts.ShowType_Binghun then
             if not (self.objNode and self.objNode.bIsMe) then
                return true
            end
        end
    end
    return false
end

--bezier曲线
function CAvatar:BezierTo(endPosition, time, callback)
    if not self.objNode then
        return
    end
    if time <= 0 then
        return
    end

    if not self.starBezier then
        self.starBezier = _Vector3.new()
    end
    if not self.endBezier then
        self.endBezier = _Vector3.new()
    end
    if not self.controlPoint then
        self.controlPoint =_Vector3.new()
    end
    if not self.nextPoint then 
        self.nextPoint =_Vector3.new()
    end

    self.objNode.transform:getTranslation(self.starBezier)
    self.endBezier.x, self.endBezier.y, self.endBezier.z = endPosition.x, endPosition.y, endPosition.z
    self.controlPoint.x, self.controlPoint.y, self.controlPoint.z = GetMidPos(self.starBezier, self.endBezier)
    self.bezierTime = time
    self.lastBezierTime = time
    self.bezierCallback = callback
end

function CAvatar:StopBezier()
    self.bezierTime = 0
    self.lastBezierTime = 0
    if self.bezierCallback then self.bezierCallback = nil end
end

local addPosition = _Vector3.new()
local selfPosition =  _Vector3.new()
function CAvatar:UpdateBezier(renderTime)
    if not self.objNode then
        return
    end
    if self.lastBezierTime <= 0 then
        return
    end
    self.lastBezierTime = math.max(self.lastBezierTime - renderTime, 0)
    local t = 1 - self.lastBezierTime / self.bezierTime
    self.nextPoint.x = (1 - t)^2 * self.starBezier.x + 2 * t * (1 - t) * self.controlPoint.x + t^2 * self.endBezier.x
    self.nextPoint.y = (1 - t)^2 * self.starBezier.y + 2 * t * (1 - t) * self.controlPoint.y + t^2 * self.endBezier.y
    self.nextPoint.z = (1 - t)^2 * self.starBezier.z + 2 * t * (1 - t) * self.controlPoint.z + t^2 * self.endBezier.z

    self.objNode.transform:getTranslation(selfPosition)
    addPosition.x = self.nextPoint.x - selfPosition.x
    addPosition.y = self.nextPoint.y - selfPosition.y
    addPosition.z = self.nextPoint.z - selfPosition.z
    self.objNode.transform:mulTranslationRight(addPosition)

    if self.lastBezierTime <= 0 then
        if self.bezierCallback then
            self.bezierCallback()
			self.bezierCallback = nil
        end
        self:StopBezier()
    end
end

function CAvatar:SetNullPick()
    if self.objMesh and self.objMesh.node then
        self.objMesh.node.pickFlag = enPickFlag.EPF_Null
    end
end

-- extend _Animation method
function _Animation.DelayStartAnima(self, currentAnima, loop)
    currentAnima:onStop(function()
        self:play()
        currentAnima.loop = loop
        Debug('startAnimaFuck', self.name)
    end)
end

function CAvatar:EnterUIScene(scene, pos, dir, scale, type)
    if not scene then
        return
    end
    if self.matTrans ~= nil then
        self.matTrans:identity()
    else
        self.matTrans = _Matrix3D.new()
    end
    if pos then
        vec.x, vec.y, vec.z = pos.x, pos.y, pos.z
        self.matTrans:setTranslation(vec)
    end
    if dir then
        vec.x, vec.y, vec.z = 0, 0, 1
        self.matTrans:mulRotationLeft(vec, dir)
    end
    local sceneNode = scene:add(self.objMesh, self.matTrans)
	if scale then 
		sceneNode.transform:mulScalingLeft(scale)
	end
    self.objNode = sceneNode
	self.objNode.dwType = type
    return sceneNode
end

function CAvatar:ExitUIScene()
    local node  = self.objNode
    if node then
        local scene = node.scene
        if scene then
            scene:del(node)
        end
    end
    self.objNode = nil
end

function CAvatar:CheckCanPass()
    if StoryController:IsStorying() then
        return true
    end
    if self.bUseCanTo then
        return true
    end
    if not (self.objNode and self.objNode.bIsMe) then
        return true
    end
    return false
end

function CAvatar:SklPlayPfx(logicname, resname, bind)
    if not self.objMesh then
        return
    end
    local skl = self:GetSkl()
    if not skl then
        return
    end
    if not logicname or logicname == "" then
        return
    end
    if not resname or resname == "" then
        return
    end
    if self.objSceneMap and self.objSceneMap.objScene then
        skl.pfxPlayer.terrain = self.objSceneMap.objScene.terrain
    end
    asyncLoad(true) -- 异步
    local pfx = skl.pfxPlayer:play(logicname, resname)
    if pfx then
        if bind then
            pfx.bind = bind
        end
        pfx.keepInPlayer = false
    end
    return pfx
end

function CAvatar:ResetMat(x, y)
    local selfDir = self:GetDir()
    local selfMat = _Matrix3D:new()
    local z = self.objSceneMap:getSceneHeight(x, y)
    selfMat:setTranslation(x, y, z)
    self.objNode.transform = selfMat
    self:SetDirValue(selfDir)
end

--- 设置缩放信息
function CAvatar:setShapeInfo(param)
    local skl = self:GetSkl()
    if not skl then return end
    if self.scaleStartTime then 
        --之前缩放进行中
        return
    end
    self.scaleParam = param
    self.scaleStartTime = GetCurTime()
    local root = self:GetSkl():getBone("root")
    if root then
        self.OldScaleVec = root:getScaling()
    end
end

--- 执行缩放
function CAvatar:updateScaling()
    if not self.scaleStartTime then 
        return 
    end
    local skl = self:GetSkl()
    if not skl then return end
    local time = GetCurTime() - self.scaleStartTime
    local param = self.scaleParam
    local mat = _Matrix3D.new(1, 1, 1)
    local scale = 1

    local func = function(skl, mat, oldScaleValue, scale)
         if oldScaleValue then
            mat:setScaling(oldScaleValue.x * scale, oldScaleValue.y * scale, oldScaleValue.z * scale)
        else
            mat:setScaling(scale, scale, scale)
        end

        skl:adjustRoot(mat)
    end
    if time > param.toScaleTime + param.scaleTime + param.recoverTime then
        func(skl, mat, self.oldScaleValue, 1)
        self.scaleParam = nil
        self.scaleStartTime = nil
        self.oldScaleValue = nil
        return
    end

    if time < param.toScaleTime then
        scale =  1 + (param.scale - 1) * time / param.toScaleTime
    elseif time > param.toScaleTime + param.scaleTime then
        scale = param.scale + (1- param.scale) *(time - param.toScaleTime - param.scaleTime)/param.recoverTime
    else
        scale = param.scale
    end

    func(skl, mat, self.oldScaleValue, scale)
end