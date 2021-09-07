-- ----------------------------
-- 剧情动作--单位朝向
-- hosr
-- ----------------------------
DramaUnitDir = DramaUnitDir or BaseClass()

function DramaUnitDir:__init()
    self.callback = nil
end

function DramaUnitDir:__delete()
end

function DramaUnitDir:Show(action)
    if action.unit_id == 0 then
        SceneManager.Instance.sceneElementsModel.self_view:FaceTo(SceneConstData.UnitFaceToIndex[action.val + 1])
    else
        local uniquenpcid = BaseUtils.get_unique_npcid(action.unit_id, action.battle_id)
        local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniquenpcid]
        if npcView ~= nil then
            npcView:FaceTo(SceneConstData.UnitFaceToIndex[action.val + 1])
        end
    end
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaUnitDir:Hiden()
end

-- 跳过处理
function DramaUnitDir:OnJump()
    self.callback = nil
end