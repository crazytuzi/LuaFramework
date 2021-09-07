-- ----------------------------
-- 剧情动作--镜头震动
-- hosr
-- ----------------------------
DramaCameraShake = DramaCameraShake or BaseClass()

function DramaCameraShake:__init()
    self.callback = nil
    self.shake_mode = {
        [1] = {
            {0.035, 0}
            ,{-0.035, 0}
            ,{0.035, 0}
            ,{-0.035, 0}
        }
        ,[2] = {
            {0.05, 0}
            ,{-0.05, 0}
            ,{0.05, 0}
            ,{-0.05, 0}
        }
    }
end

function DramaCameraShake:__delete()
    -- print("DramaCameraShake:__delete")
    if self.handler ~= nil then
        self.handler:DeleteMe()
        self.handler = nil
    end
end

function DramaCameraShake:Show(action)
    self.handler = ShakeCameraHandler.New(SceneManager.Instance.MainCamera.gameObject, self.shake_mode[action.mode], action.time/1000, function() self:ActionOver() end)
    self.handler:Play()
    -- SoundManager.Instance:Play(263)
end

function DramaCameraShake:Hiden()
end

function DramaCameraShake:ActionOver()
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaCameraShake:OnJump()
    self.callback = nil
end