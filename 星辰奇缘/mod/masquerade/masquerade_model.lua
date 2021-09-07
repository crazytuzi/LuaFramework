-- @author 黄耀聪
-- @date 2016年6月29日

MasqueradeModel = MasqueradeModel or BaseClass(BaseModel)

function MasqueradeModel:__init()
    self.playerList = {}
    self.mapInfo = {}
    self.myInfo = {score = 0, win = 0, win_streak = 0, lev = 0}
    self.hideStatus = true
    self.floorToDiff = {}
    local lastId = nil
    for i,v in ipairs(DataElf.data_floor) do
        if lastId == nil then
            self.floorToDiff[v.id] = v.next_score
        elseif i == #DataElf.data_floor then
            self.floorToDiff[v.id] = v.grade_score - DataElf.data_floor[lastId].next_score
        else
            self.floorToDiff[v.id] = v.next_score - DataElf.data_floor[lastId].next_score
        end
        lastId = v.id
    end
    self.floorToDiff[0] = 0
    self.max_floor = #self.floorToDiff

    -- BaseUtils.dump(self.floorToDiff)
end

function MasqueradeModel:__delete()
end

function MasqueradeModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = MasqueradeRankWindow.New(self)
    end
    self.mainWin:Open(args)
end

function MasqueradeModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function MasqueradeModel:AddPlayer(data, index)
    local key = BaseUtils.Key(data.rid, data.platform, data.r_zone_id)
    self.playerList[key] = self.playerList[key] or {}
    local tab = self.playerList[key]
    for k,v in pairs(data) do
        tab[k] = v
    end
end

function MasqueradeModel:AddMap(data)
    self.mapInfo[data.map_base_id] = self.mapInfo[data.map_base_id] or {}
    local tab = self.mapInfo[data.map_base_id]
    for k,v in pairs(data) do
        tab[k] = v
    end
end

function MasqueradeModel:OpenMainUIPanel()
    if MainUIManager.Instance.MainUICanvasView.gameObject ~= nil and not BaseUtils.is_null(MainUIManager.Instance.MainUICanvasView.gameObject) then
        if self.mainuiPanel == nil then
            self.mainuiPanel = MasqueradeMainUIPanel.New(self, MainUIManager.Instance.MainUICanvasView.gameObject)
        end
        self.mainuiPanel:Show()
    end

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {107, 116})
    end

    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.hideStatus)
end

function MasqueradeModel:CloseMainUIPanel()
    if self.mainuiPanel ~= nil then
        self.mainuiPanel:DeleteMe()
        self.mainuiPanel = nil

        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {107, 116})
        end
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
    end
end

function MasqueradeModel:OpenPreviewWindow(args)
    if self.previewWin == nil then
        self.previewWin = MasqueradePreviewWindow.New(self)
    end
    self.previewWin:Open(args)
end

function MasqueradeModel:ClosePreviewWindow()
    if self.previewWin ~= nil then
        WindowManager.Instance:CloseWindow(self.previewWin)
    end
end


