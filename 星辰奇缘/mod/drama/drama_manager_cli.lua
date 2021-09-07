-- --------------------------------------
-- 客户端自己播放流程剧本控制
-- hosr
-- --------------------------------------
DramaManagerCli = DramaManagerCli or BaseClass(BaseManager)

function DramaManagerCli:__init()
    if DramaManagerCli.Instance then
        return
    end

    DramaManagerCli.Instance = self
    self.transformer = DramaDataTransform.New()

    self.guideMain = function() self:GuideMainTask() end
    self.selfLoadedListener = function() self:SelfLoad() end
    EventMgr.Instance:AddListener(event_name.self_loaded, self.selfLoadedListener)
end

function DramaManagerCli:GetModel()
    return DramaManager.Instance.model
end

function DramaManagerCli:SelfLoad()
    if LoginManager.Instance.first_enter then
        LoginManager.Instance.first_enter = false
        self:NewGuyFirstShow()
    end
end

-- 新手第一次进入场景剧情
function DramaManagerCli:NewGuyFirstShow()
    local dat = DataPlot.data_drama[10000]
    local dramaData = DramaData.New()
    dramaData:SetData(dat)

    table.insert(dramaData.action_list, {id = 1, type = DramaEumn.ActionType.Playplot, val = 9020})
    table.insert(dramaData.action_list, {id = 2, type = DramaEumn.ActionType.Playguide, val = 10000})
    table.insert(dramaData.action_list, {id = 3, type = DramaEumn.ActionType.Endplot})
    DramaManager.Instance.model:BeginDrama(dramaData)
end

function DramaManagerCli:FirstPetShow()
    local dat = DataPlot.data_drama[10006]
    local dramaData = DramaData.New()
    dramaData:SetData(dat)

    local action = self.transformer:Format({label = DramaEumn.ActionType.First_pet, val = 10001})
    action.id = 1
    table.insert(dramaData.action_list, action)
    table.insert(dramaData.action_list, {id = 2, type = DramaEumn.ActionType.Endplot})
    DramaManager.Instance.model:BeginDrama(dramaData)
end

function DramaManagerCli:Jump()
    local dat = DataPlot.data_drama[10020]
    local dramaData = DramaData.New()
    dramaData:SetData(dat)

    table.insert(dramaData.action_list, {id = 1, type = DramaEumn.ActionType.Playplot, val = 10010})
    table.insert(dramaData.action_list, {id = 2, type = DramaEumn.ActionType.Playplot, val = 10011})
    table.insert(dramaData.action_list, {id = 3, type = DramaEumn.ActionType.Endplot})
    DramaManager.Instance.model:BeginDrama(dramaData)
end

function DramaManagerCli:TouchYifu()
    local dat = DataPlot.data_drama[10035]
    local dramaData = DramaData.New()
    dramaData:SetData(dat)

    table.insert(dramaData.action_list, {id = 1, type = DramaEumn.ActionType.TouchNpc, battle_id = 0, unit_id = 20012})
    table.insert(dramaData.action_list, {id = 2, type = DramaEumn.ActionType.Playplot, val = 10051})
    table.insert(dramaData.action_list, {id = 3, type = DramaEumn.ActionType.TouchNpc, battle_id = 0, unit_id = 20010})
    table.insert(dramaData.action_list, {id = 4, type = DramaEumn.ActionType.Endplot})
    DramaManager.Instance.model:BeginDrama(dramaData)
end

function DramaManagerCli:ExquisiteShelf(dramaList, callback)
    local dat = DataPlot.data_drama[10035]
    local dramaData = DramaData.New()
    dramaData:SetData(dat)

    SceneManager.Instance.sceneElementsModel:Show_Npc(false)

    for index, value in ipairs(dramaList) do
        value.id = index
        table.insert(dramaData.action_list, value)
    end
    DramaManager.Instance.model:BeginDrama(dramaData)
end
