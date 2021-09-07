-----------------------------------
-- 处理剧情跳跃动作
-- lqg
-----------------------------------
DramaJump = DramaJump or BaseClass(BaseDramaPanel)

function DramaJump:__init()
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

    self.roleObj = SceneManager.Instance.sceneElementsModel.self_view.gameObject
end

function DramaJump:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    GameObject.DestroyImmediate(self.upeffect)
    GameObject.DestroyImmediate(self.downeffect)
    self:AssetClearAll()
    self.gameObject = nil
end

function DramaJump:InitPanel()
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

function DramaJump:OnInitCompleted()
    self:Play()
end

function DramaJump:Play()
    -- 不允许跳过
    SceneManager.Instance.MainCamera.lock = false
    DramaManager.Instance.model:ShowJump(false)
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = false
    self.points = self.openArgs.val
    self.step = 0
    self:Begin()
end

function DramaJump:Begin()
    self.step = self.step + 1
    self:Runto(self.points[self.step])
end

function DramaJump:Runto(pos)
    SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = function() self:MoveEnd() end
    pos = SceneManager.Instance.sceneModel:transport_small_pos(pos.x, pos.y)
    SceneManager.Instance.sceneElementsModel.self_view:MoveTo(pos.x, pos.y)
end

function DramaJump:MoveEnd()
    SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(false)
    SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
    self:JumpUp()
end

function DramaJump:JumpUp()
    if BaseUtils.isnull(self.roleObj) then
        return
    end
    if self.step == #self.points then
        self.upeffect:SetActive(false)
        self.downeffect:SetActive(false)
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)
        SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
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

        SceneManager.Instance.sceneElementsModel.self_view:FaceToPoint(self.endPos)
        SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.JumpUp)
        self.step = self.step + 1
        LuaTimer.Add(0.2, function() self:JumpMove() end)
    end
end

function DramaJump:JumpMove()
    if BaseUtils.isnull(self.roleObj) then
        return
    end
    SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.JumpMove)
    local time = BaseUtils.distance_bypoint(self.endPos, self.beginPos) / 3.5
    Tween.Instance:Move(self.roleObj, self.endPos, time, function() self:JumpDown() end, nil)
end

function DramaJump:JumpDown()
    if BaseUtils.isnull(self.roleObj) then
        return
    end
    self.roleObj.transform.position = Vector3(self.endPos.x, self.endPos.y, self.endPos.y)
    if not BaseUtils.is_null(self.downeffect) then
        self.downeffect.transform.position = Vector3(self.endPos.x, self.endPos.y, 0)
        self.downeffect:SetActive(false)
        self.downeffect:SetActive(true)
    end
    SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.JumpDown)
    LuaTimer.Add(0.8,  function() self:JumpUp() end)
end

function DramaJump:Stand(callback)
    if BaseUtils.isnull(self.roleObj) then
        return
    end
    SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.Stand)
    if callback ~= nil then
        LuaTimer.Add(0.1, callback)
    end
end

function DramaJump:Loop(vec3)
    if BaseUtils.isnull(self.roleObj) then
        return
    end
    self.roleObj.transform.position = vec3
end

function DramaJump:OnJump()
end