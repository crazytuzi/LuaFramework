-- ----------------------------
-- 剧情动作--单位移动
-- hosr
-- ----------------------------
DramaUnitMove = DramaUnitMove or BaseClass()

function DramaUnitMove:__init()
    self.callback = nil
    self.unit = nil
end

function DramaUnitMove:__delete()
    if self.unit ~= nil then
        self.unit.moveEnd_CallBack = nil
        self.unit = nil
    end
end

function DramaUnitMove:Show(action)
    local pos = SceneManager.Instance.sceneModel:transport_small_pos(action.x, action.y)
    if action.unit_id == 0 then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = function() self:MoveEnd() end
        self.unit = SceneManager.Instance.sceneElementsModel.self_view
        SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(pos.x, pos.y)
    else
        local uniquenpcid = BaseUtils.get_unique_npcid(action.unit_id, 0)
        local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniquenpcid]
        self.unit = npcView
        if npcView ~= nil then
            npcView.moveEnd_CallBack = function() self:MoveEnd() end
            npcView:MoveTo_NoPaths(pos.x, pos.y)
        end
    end
end

function DramaUnitMove:Hiden()
end

function DramaUnitMove:MoveEnd()
    self.unit.moveEnd_CallBack = nil
    if self.callback ~= nil then
        self.callback()
    end
end

-- 跳过处理
function DramaUnitMove:OnJump()
    self.callback = nil
    if self.unit ~= nil then
        self.unit.moveEnd_CallBack = nil
    end
end