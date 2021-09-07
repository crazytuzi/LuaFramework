-----------------------------------
-- 处理场景跳跃动作
-----------------------------------
SceneJump = SceneJump or BaseClass(BaseDramaPanel)

function SceneJump:__init()
    self.upstr = "prefabs/effect/10043.unity3d"
    self.downstr = "prefabs/effect/10045.unity3d"
    self.upeffect = nil
    self.downeffect = nil

    self.resList = {
        {file = self.upstr, type = AssetType.Main},
        {file = self.downstr, type = AssetType.Main},
    }

    self.test = {
        {
            {x = 1470, y = 1176}
            ,{x = 1303, y = 1677}
            ,{x = 791, y = 1909}
        },
        {
            {x = 1760, y = 1036}
            ,{x = 1641, y = 1433}
            ,{x = 1303, y = 1677}
            ,{x = 791, y = 1909}
        },
        {
            {x = 791, y = 1909}
            ,{x = 1303, y = 1677}
            ,{x = 1641, y = 1433}
            ,{x = 1760, y = 1036}
        }
    }

    self.callback = nil

    self.roleView = SceneManager.Instance.sceneElementsModel.self_view
    if self.roleView ~= nil then
        self.roleObj = SceneManager.Instance.sceneElementsModel.self_view.gameObject
    end
end

function SceneJump:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    GameObject.DestroyImmediate(self.upeffect)
    GameObject.DestroyImmediate(self.downeffect)
    self:AssetClearAll()
    self.gameObject = nil
end

function SceneJump:InitPanel()
    self.upeffect = GameObject.Instantiate(self:GetPrefab(self.upstr))
    self.upeffect.transform.localScale = Vector3.one
    self.upeffect.transform.localRotation = Quaternion.identity
    self.upeffect.transform:Rotate(Vector3(25, 0, 0))
    self.upeffect:SetActive(false)

    self.downeffect = GameObject.Instantiate(self:GetPrefab(self.downstr))
    self.downeffect.transform.localPosition = Vector3.zero
    self.downeffect.transform.localScale = Vector3.one
    self.downeffect.transform:Rotate(Vector3(25, 0, 0))
    self.downeffect:SetActive(false)
end

function SceneJump:OnInitCompleted()
    self:Play()
end

function SceneJump:Play()
    if self:CheckBreakOff() then
        return
    end

    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = false
    if self.openArgs.target ~= nil then
        self.roleView = self.openArgs.target
        self.roleObj = self.openArgs.target.gameObject
    end
    self.points = self.openArgs.val
    self.step = 0
    if self.roleView ~= nil then
        self:Begin()
    end
end

function SceneJump:Begin()
    self.step = self.step + 1
    self:Runto(self.points[self.step])
end

function SceneJump:Runto(pos)
    if self:CheckBreakOff() then
        return
    end

    self.roleView.moveEnd_CallBack = function() self:MoveEnd() end
    pos = SceneManager.Instance.sceneModel:transport_small_pos(pos.x, pos.y)
    self.roleView:MoveTo(pos.x, pos.y)
end

function SceneJump:MoveEnd()
    if self:CheckBreakOff() then
        return
    end

    self.roleView.moveEnd_CallBack = nil
    -- SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(false)
    -- SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
    self:JumpUp()
end

function SceneJump:JumpUp()
    if self:CheckBreakOff() then
        return
    end

    if self.step == #self.points then
        self.upeffect:SetActive(false)
        self.downeffect:SetActive(false)
        -- SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)
        -- SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
        self:Stand(nil)
        if self.callback ~= nil then
            self.callback()
        end
    else
        self.beginPos = self.points[self.step]
        self.endPos = self.points[self.step + 1]
        self.beginPos = SceneManager.Instance.sceneModel:transport_small_pos(self.beginPos.x, self.beginPos.y)
        self.endPos = SceneManager.Instance.sceneModel:transport_small_pos(self.endPos.x, self.endPos.y)

        if not BaseUtils.is_null(self.upeffect) then
            self.upeffect.transform.position = Vector3(self.beginPos.x, self.beginPos.y, 0)
            self.upeffect:SetActive(false)
            self.upeffect:SetActive(true)
        end
        SoundManager.Instance:Play(270)

        self.roleView:FaceToPoint(self.endPos)
        -- self.roleView:PlayAction(SceneConstData.UnitAction.JumpUp)
        self:PlayJumpAction(SceneConstData.UnitAction.JumpUp)
        self.step = self.step + 1
        LuaTimer.Add(0.2, function() self:JumpMove() end)
    end
end

function SceneJump:JumpMove()
    if self:CheckBreakOff() then
        return
    end

    -- self.roleView:PlayAction(SceneConstData.UnitAction.JumpMove)
    self:PlayJumpAction(SceneConstData.UnitAction.JumpMove)
    local time = 0.65
    Tween.Instance:Move(self.roleObj, self.endPos, time, function() self:JumpDown() end, nil)
end

function SceneJump:JumpDown()
    if self:CheckBreakOff() then
        return
    end

    self.roleObj.transform.position = Vector3(self.endPos.x, self.endPos.y, self.endPos.y)
    if not BaseUtils.is_null(self.downeffect) then
        self.downeffect.transform.position = Vector3(self.endPos.x, self.endPos.y, 0)
        self.downeffect:SetActive(false)
        self.downeffect:SetActive(true)
    end
    -- self.roleView:PlayAction(SceneConstData.UnitAction.JumpDown)
    self:PlayJumpAction(SceneConstData.UnitAction.JumpDown)
    LuaTimer.Add(0.8,  function() self:JumpUp() end)
end

function SceneJump:Stand(callback)
    if self:CheckBreakOff() then
        return
    end

    -- self.roleView:PlayAction(SceneConstData.UnitAction.Stand)
    self:PlayJumpAction(SceneConstData.UnitAction.Stand)
    if callback ~= nil then
        LuaTimer.Add(0.1, callback)
    end
end

function SceneJump:Loop(vec3)
    self.roleObj.transform.position = vec3
end

function SceneJump:OnJump()
end

function SceneJump:PlayJumpAction(actionType)
    if self.roleView.transform_id == 0 then
        if actionType == SceneConstData.UnitAction.JumpUp then
            self.roleView:PlayAction(SceneConstData.UnitAction.JumpUp)
        elseif actionType == SceneConstData.UnitAction.JumpMove then
            self.roleView:PlayAction(SceneConstData.UnitAction.JumpMove)
        elseif actionType == SceneConstData.UnitAction.JumpDown then
            self.roleView:PlayAction(SceneConstData.UnitAction.JumpDown)
        elseif actionType == SceneConstData.UnitAction.Stand then
            self.roleView:PlayAction(SceneConstData.UnitAction.Stand)
        end
    else
        if actionType == SceneConstData.UnitAction.JumpUp then
            self.roleView:PlayActionName("Jumpup1", true)
        elseif actionType == SceneConstData.UnitAction.JumpMove then
            self.roleView:PlayActionName("Jumpmove1", true)
        elseif actionType == SceneConstData.UnitAction.JumpDown then
            self.roleView:PlayActionName("Jumpdown1", true)
        elseif actionType == SceneConstData.UnitAction.Stand then
            self.roleView:PlayAction(SceneConstData.UnitAction.Stand) 
        end
    end
end

function SceneJump:CheckBreakOff()
    if BaseUtils.is_null(self.upeffect) or BaseUtils.is_null(self.downeffect) or self.roleView == nil or BaseUtils.is_null(self.roleView.gameObject) then
        self:DeleteMe()
        return true
    end
end