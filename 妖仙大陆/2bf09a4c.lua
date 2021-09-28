local _M = {}
_M.__index = _M

local function TouchModel(self,pointerEventData)

    if nil ~= self.Model3DAssetBundel then
        IconGenerator.instance:SetRotate(self.Model3DAssetBundel, -pointerEventData.delta.x)
        if pointerEventData.delta.x > 10 or pointerEventData.delta.x < -10 then
            self.isMove = true
        end
    end
end





local function PlayRunAnimation(self, id)

    
    if self.inaction then
        return true
    else
        local getaction = false
        local attakstr = {
            "n_show",
        }
        self.curactionIndex = self.curactionIndex + 1
        if self.curactionIndex > #attakstr then
            self.curactionIndex = 1
        end
        EventManager.Fire("Event.PlayAnimationSound",{})
        getaction = IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, attakstr[self.curactionIndex], WrapMode.Once, -1, 1, 0, function( ... )
            
            
                
                IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, "n_idle", WrapMode.Loop, -1, 1, 0, nil, 0)
                self.inaction = nil
                self.runState = false
                
                
                
            
            
        end, 0) 
        if getaction then
            self.inaction = true
        end 
        
        return  getaction
    end
end

function _M.SetBaseAnimation(self, isRun)
    
    self.runState = isRun
    if isRun then
        local checktimes = 0
        self.curDeadIndex = math.random(1, 2)
        while PlayRunAnimation(self, -1) == false and checktimes < 2 do
            checktimes = checktimes + 1
        end
    else
        IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, "n_idle", WrapMode.Loop, -1, 1, 0, nil, 0)
    end
end

function _M.DoOneRunAction(self, id)
    
    if self.runState then
        return
    end
    local checktimes = 0
    if not self.isMove and self.inaction == nil then
        while PlayRunAnimation(self, id) == false and checktimes < 5 do
            checktimes = checktimes + 1
        end
    end
end

function _M.ClearModel(self)
    
    if nil ~= self.Model3DGameObj then
        GameObject.Destroy( self.Model3DGameObj )
        IconGenerator.instance:ReleaseTexture(self.Model3DAssetBundel)
        self.Model3DGameObj = nil;
        self.Model3DAssetBundel = nil;
    end
end

function _M.InitModelAvaterstr(self, node, avaterstr, loadok, isRun, id)
    
    _M.ClearModel(self)

    self.moveLength = 0   
    self.curactionIndex = 1
    self.inaction = nil

    avaterstr = "/res/unit/mount/"..avaterstr..".assetbundles"

    local width = (node.Height > node.Width) and node.Height or node.Width
    self.Model3DGameObj, self.Model3DAssetBundel = GameUtil.Add3DModel(node, avaterstr, nil, "", 0, true)
    
    IconGenerator.instance:SetModelScale(self.Model3DAssetBundel, Vector3.New(2, 2, 2))
    if avaterstr == "/res/unit/mount/mnt_xianjian_01.assetbundles" then
        IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(2.2, -1.7, 18))
        IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(17, 220, 17))
    elseif avaterstr == "/res/unit/mount/mnt_lingbaohulu_01.assetbundles" then
        IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(0, -4.5, 20))
        IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(0, 225, 0))
    else
        IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(0, -3.0, 15))
        IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(0, 225, 0))
    end
    IconGenerator.instance:SetCameraParam(self.Model3DAssetBundel, 0.1, 50, 5)
    IconGenerator.instance:SetLoadOKCallback(self.Model3DAssetBundel, function (key)
        
        if loadok ~= nil then
            loadok(self)
        end
        _M.SetBaseAnimation(self, isRun)
    end)

    node.event_PointerUp = function(displayNode, pos)
        _M.DoOneRunAction(self, id)   
        self.isMove = nil 
    end

    node.event_PointerMove = function(displayNode, pos)
        TouchModel(self, pos)
    end
end

return _M
