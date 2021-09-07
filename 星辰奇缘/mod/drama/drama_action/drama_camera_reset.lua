-- ----------------------------
-- 剧情动作--镜头移动  恢复
-- hosr
-- ----------------------------
DramaCameraReset = DramaCameraReset or BaseClass()

function DramaCameraReset:__init()
    self.callback = nil
end

function DramaCameraReset:__delete()
    -- print("DramaCameraReset:__delete")
    if self.tweenDesc ~= nil then
        Tween.Instance:Cancel(self.tweenDesc)
        self.tweenDesc = nil
    end
end

function DramaCameraReset:Show(action)
    SceneManager.Instance.MainCamera.lock = true
    local startpos = SceneManager.Instance.MainCamera.transform.position
    local endpos = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position

    self.tweenDesc = Tween.Instance:Move(SceneManager.Instance.MainCamera.gameObject, endpos, action.time/1000, function() self:ActionOver() end).id
end

function DramaCameraReset:Hiden()
end

function DramaCameraReset:ActionOver()
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaCameraReset:OnJump()
    self.callback = nil
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
end