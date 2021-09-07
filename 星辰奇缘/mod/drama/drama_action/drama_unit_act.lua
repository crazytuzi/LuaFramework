-- ----------------------------
-- 剧情动作--单位播放指定动作
-- hosr
-- ----------------------------
DramaUnitAct = DramaUnitAct or BaseClass()

function DramaUnitAct:__init()
    self.callback = nil
    self.attacks = {10010, 20010, 30010, 40010, 50011, 60020}
    self.unit = nil
    self.directBack = false

    self.delayId = 0
end

function DramaUnitAct:__delete()
    if self.unit ~= nil then
        self.unit.action_callback = nil
        self.unit = nil
    end

    if self.delayId ~= 0 then
        LuaTimer.Delete(self.delayId)
        self.delayId = 0
    end
end

function DramaUnitAct:Show(action)
    if self.delayId ~= 0 then
        LuaTimer.Delete(self.delayId)
        self.delayId = 0
    end
    self.delayId = LuaTimer.Add(action.ext_val + 5000, function() print("没正常播放动作") self:ActionTimeout() end)

    self.unit = nil
    self.directBack = false
    local actid = SceneConstData.UnitActionStr[action.msg]
    local pos = SceneManager.Instance.sceneModel:transport_small_pos(action.x, action.y)
    if action.unit_id == 0 then
        self.unit = SceneManager.Instance.sceneElementsModel.self_view
        SceneManager.Instance.sceneElementsModel.self_view.action_callback = function() self:ActionTimeout() end
        if actid == nil then
            SceneManager.Instance.sceneElementsModel.self_view:play_action_name(action.msg)
        else
            if actid == SceneConstData.UnitAction.Attack then
                --角色普攻动作  狂剑 10010  魔导 20010   战弓 30010   兽灵 40010   秘言 50011 月魂 60020
                actid = self.attacks[RoleManager.Instance.RoleData.classes]
                SceneManager.Instance.sceneElementsModel.self_view:play_action_name(actid)
            else
                if actid == SceneConstData.UnitAction.Dead then
                    self.directBack = true
                    SceneManager.Instance.sceneElementsModel.self_view.action_callback = nil
                end
                SceneManager.Instance.sceneElementsModel.self_view:PlayAction(actid)
            end
        end
    else
        local uniquenpcid = BaseUtils.get_unique_npcid(action.unit_id, action.battle_id)
        local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniquenpcid]
        if npcView ~= nil then
            self.unit = npcView
            npcView.action_callback = function() self:ActionTimeout() end
            if actid == nil then
                npcView:play_action_name(action.msg)
            else
                if actid == SceneConstData.UnitAction.Dead then
                    self.directBack = true
                    npcView.action_callback = nil
                end
                npcView:PlayAction(actid)
            end
        else
            self:ActionTimeout()
        end
    end
    if self.directBack then
        self:ActionTimeout()
    end
end

function DramaUnitAct:Hiden()
end

function DramaUnitAct:ActionTimeout()
    if self.delayId ~= 0 then
        LuaTimer.Delete(self.delayId)
        self.delayId = 0
    end
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaUnitAct:OnJump()
    if self.delayId ~= 0 then
        LuaTimer.Delete(self.delayId)
        self.delayId = 0
    end

    self.callback = nil
    self.unit = nil
end




