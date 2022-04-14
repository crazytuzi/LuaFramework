-- @Author: lwj
-- @Date:   2019-08-23 20:15:02 
-- @Last Modified time: 2019-08-23 20:17:41

CoupleModel = CoupleModel or class("CoupleModel", BaseBagModel)
local CoupleModel = CoupleModel

function CoupleModel:ctor()
    CoupleModel.Instance = self
    self:Reset()
end

function CoupleModel:Reset()
    self.is_remind_cd = false
    self.remind_cd = 0
    self.is_openning_left_center = false
    self.dunge_enter_info = {}
    self.is_Answerring = false          --是否正在答题
    self.cur_ques_id = 1                --当前题目id
    self.is_choosed = false             --是否已经选择
    self.is_need_open_panel = false     --是否需要请求完数据之后打开界面
    self.is_need_show_end_panel = false --是否在退出副本后，显示结算界面
    self.end_data = {}                  --结算信息（直接退出副本时）
    self.dunge_panel_info = {}          --副本panel信息
end

function CoupleModel.GetInstance()
    if CoupleModel.Instance == nil then
        CoupleModel()
    end
    return CoupleModel.Instance
end

function CoupleModel:SetEnterInfo(info)
    self.dunge_enter_info = info
end

function CoupleModel:GetEnterInfo()
    return self.dunge_enter_info
end

function CoupleModel:GetKillCreapByCreapId(id)
    if self.dunge_enter_info and self.dunge_enter_info.count then
        local result = 0
        for i, v in pairs(self.dunge_enter_info.count) do
            if i == id then
                result = v
                break
            end
        end
        return result
    end
    return 0
end

function CoupleModel:IsCoupleScene(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE then
        return true
    end
    return false
end

function CoupleModel:CheckCPDungeonRD()
    local dunge_info = DungeonModel.GetInstance():GetDungeonInfoByStype(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE) or self.dunge_panel_info
    if not dunge_info or (not dunge_info.info) then
        return
    end
    local count = dunge_info.info.rest_times
    local is_show = false
    if count > 0 then
        is_show = true
    end
    return is_show
end