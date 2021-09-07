-- ----------------------------
-- 剧情动作--镜头移动
-- hosr
-- ----------------------------
DramaCameraMove = DramaCameraMove or BaseClass()

function DramaCameraMove:__init()
    self.callback = nil
end

function DramaCameraMove:__delete()
    if self.tweenDesc ~= nil then
        Tween.Instance:Cancel(self.tweenDesc)
        self.tweenDesc = nil
    end
    if not SceneManager.Instance.MainCamera.lock then
        SceneManager.Instance.MainCamera.lock = false
        SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
    end
end

function DramaCameraMove:Show(action)
    SceneManager.Instance.MainCamera.lock = true
    local startpos = SceneManager.Instance.MainCamera.transform.position
    local endpos = SceneManager.Instance.sceneModel:transport_small_pos(action.x, action.y)
    endpos = Vector3(endpos.x, endpos.y, 0)
    self.tweenDesc = Tween.Instance:Move(SceneManager.Instance.MainCamera.gameObject, endpos, action.time/1000, function() self:ActionOver() end).id
end

function DramaCameraMove:Hiden()
end

function DramaCameraMove:ActionOver()
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaCameraMove:OnJump()
    self.callback = nil
    SceneManager.Instance.MainCamera.lock = false
end