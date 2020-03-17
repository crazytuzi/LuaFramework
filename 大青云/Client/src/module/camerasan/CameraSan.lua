--[[
摄像机动作
liyuan
2014年10月15日21:33:06
]]

_G.C_CameraSan = { }
setmetatable(C_CameraSan,{__index = C_CameraBase});
function C_CameraSan:new()
	local cameraSan = C_CameraBase:new()
	setmetatable(cameraSan, {__index = C_CameraSan})
	--动画列表
    cameraSan.setAllAction = {};
	cameraSan.currAnima = nil
	
	cameraSan.cam0 = _Camera.new( )
	cameraSan.name = 'C_CameraSan'
	cameraSan.skl = _Skeleton.new( 'Camera_kaichang.skl' )
	
	cameraSan.mesh = _Mesh.new( )
	cameraSan.mesh.skeleton = cameraSan.skl
	cameraSan.tar = nil
	cameraSan.eye0 = _Vector3.new( )
	cameraSan.look0 = _Vector3.new( )
	cameraSan.mat0 = _Matrix3D.new( )
	cameraSan.mat1 = _Matrix3D.new( )
	cameraSan.isPlay = false
	
	return cameraSan
end

function C_CameraSan:ExecAction(name, tar, loop, callback)
	-- FPrint('C_CameraSan1')
	if not self.skl then
        return
    end
	
	local anima = self:GetAnimation(name)
	if not anima then
		return
	end
	
	-- FPrint('C_CameraSan2')
	if self.currAnima == anima and anima.loop == true and anima.isPlaying then
        return anima.duration, anima
    end
	-- FPrint('C_CameraSan3')
	self.tar = tar
	anima:stop()
	
	anima:onStop(function()
		self.isPlay = false
        if callback then
            callback(self, anima)
			callback =  nil
        end
        _sys.asyncLoad = true
    end)
	
	self.isPlay = true
	anima:play()
    anima.loop = loop or false
    self.currAnima = anima
    return anima.duration, anima
end

--停止动作
function C_CameraSan:StopAction(name)
    if not self.skl then
        return
    end
    local anima = self.setAllAction[name]
    if not anima then
        return
    end

    if anima.isPlaying then
        anima:stop()
    end
end

--停止所有动作
function C_CameraSan:StopAllAction()
	self.isPlay = false
	for k,v in pairs(self.setAllAction) do
		if v.isPlaying then
			v:stop()
		end
	end
end

function C_CameraSan:GetAnimation(name)
	if not name or name == "" then
		return
	end
    local anima = self.setAllAction[name]
    if not anima then
        --Debug("first load anima", name)
        _sys.asyncLoad = true  -- 异步
        anima = self.skl:addAnima(name)
        if not anima then
            assser(false, "Fuck can't find ", name)
            return
        end
        self.setAllAction[name] = anima
    end
    return anima
end

function C_CameraSan:getCamera() 
	return self.cam0 
end

function C_CameraSan:Update()
	if not self.isPlay then return end
	-- FPrint('C_CameraSan3')
	if not self.skl then
        return
    end
	-- FPrint('C_CameraSan4')
	if self.mesh then self.mesh:drawMesh( ) end
	self.mat1 = self.skl:getBone( 'eye', self.mat1 )
	self.eye0 = self.mat1:getTranslation( self.eye0 )
	self.mat1 = self.skl:getBone( 'look', self.mat1 )
	self.look0 = self.mat1:getTranslation( self.look0 )
	
	self.mat0 = self.tar(self.mat0)
	self.eye0 = self.mat0:apply( self.eye0 )
	self.look0 = self.mat0:apply( self.look0 )
	
	self.cam0.eye.x = self.eye0.x
	self.cam0.eye.y = self.eye0.y
	self.cam0.eye.z = self.eye0.z
	
	self.cam0.look.x = self.look0.x
	self.cam0.look.y = self.look0.y
	self.cam0.look.z = self.look0.z
end
