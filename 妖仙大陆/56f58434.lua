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

local function PlayRunAnimation(self)
    
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
        getaction = IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, attakstr[self.curactionIndex], WrapMode.Once, -1, 1, 0, function( ... )
            
            
                
                IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, "f_idle", WrapMode.Loop, -1, 1, 0, nil, 0)
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
        while PlayRunAnimation(self) == false and checktimes < 2 do
            checktimes = checktimes + 1
        end
    else
        IconGenerator.instance:PlayUnitAnimation(self.Model3DAssetBundel, "f_idle", WrapMode.Loop, -1, 1, 0, nil, 0)
    end
end

function _M.DoOneRunAction(self)
    
    if self.runState then
        return
    end
    local checktimes = 0
    if not self.isMove and self.inaction == nil then
        while PlayRunAnimation(self) == false and checktimes < 5 do
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

function _M.InitModelAvaterstr(self, node, petData, loadok, isRun)
    
    _M.ClearModel(self)

    self.moveLength = 0   
    self.curactionIndex = 1
    self.inaction = nil

    local avaterstr = "/res/unit/pet/"..petData.Model..".assetbundles"

    local modelY = -0.66
    if petData.ModelY ~= nil then
        modelY = petData.ModelY 
    end

    local scale = petData.ModelPercent / 100
    
    
    
    
    

    local width = (node.Height > node.Width) and node.Height or node.Width
    self.Model3DGameObj, self.Model3DAssetBundel = GameUtil.Add3DModel(node, avaterstr, nil, "", 0, true)
    IconGenerator.instance:SetModelScale(self.Model3DAssetBundel, Vector3.New(scale,scale, scale))
    IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(0, modelY, 3.2))
    IconGenerator.instance:SetCameraParam(self.Model3DAssetBundel, 0.1, 50, 5)
    IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(0, 135, 0))
    IconGenerator.instance:SetLoadOKCallback(self.Model3DAssetBundel, function (key)
        
        if loadok ~= nil then
            loadok(self)
        end
        _M.SetBaseAnimation(self, isRun)
    end)

    node.event_PointerUp = function(displayNode, pos)


    end

    node.event_PointerMove = function(displayNode, pos)
        TouchModel(self, pos)
    end

    node.event_PointerClick = function (displayNode, pos)
        _M.SetBaseAnimation(self,true)
        XmdsSoundManager.GetXmdsInstance():PlaySound(petData.Sound);    
    end

end

return _M
