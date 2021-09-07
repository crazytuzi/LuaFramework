-- ----------------------------
-- 剧情动作--镜头缩放
-- hosr
-- ----------------------------
DramaCameraZoom = DramaCameraZoom or BaseClass()

function DramaCameraZoom:__init()
    self.callback = nil
end

function DramaCameraZoom:__delete()
    if self.tweenDesc ~= nil then
        Tween.Instance:Cancel(self.tweenDesc)
        self.tweenDesc = nil
    end
    SceneManager.Instance.MainCamera.camera.orthographicSize = SceneManager.Instance.DefaultCameraSize
end

function DramaCameraZoom:Show(action)
    local nowVal = SceneManager.Instance.MainCamera.camera.orthographicSize
    local endVal = SceneManager.Instance.DefaultCameraSize * action.val
    local time = action.time / 1000
    self.tweenDesc = Tween.Instance:ValueChange(nowVal, endVal, time, function() self:ActionOver() end, nil, function(val) self:UpdateVal(val) end).id
end

function DramaCameraZoom:Hiden()
end

function DramaCameraZoom:UpdateVal(val)
    SceneManager.Instance.MainCamera.camera.orthographicSize = val
end

function DramaCameraZoom:ActionOver()
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaCameraZoom:OnJump()
    self.callback = nil
end