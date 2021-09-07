-- @author 黄耀聪
-- @date 2016年7月21日

BackendModel = BackendModel or BaseClass(BaseModel)

function BackendModel:__init()
    self.backendCampaignTab = {}
    self.rankDataTab = {}
end

function BackendModel:__delete()
end

function BackendModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = BackendWindow.New(self)
    end
    self.mainWin:Open(args)
end

function BackendModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function BackendModel:ShowQuestionaireWindow(bo,args)
    if bo == true then
        if self.questionaireWin == nil then
            self.questionaireWin = QuestionaireWindow.New(self)
        end
        self.questionaireWin:Open(args)
    else
        if self.questionaireWin ~= nil then
            WindowManager.Instance:CloseWindow(self.questionaireWin)
        end
    end
end

function BackendModel:GetTabData(id)
    local tabData = {}
    local baseTime = BaseUtils.BASE_TIME
    local campData = self.backendCampaignTab[id] or {}

    for _,menu in pairs(campData.menu_list) do
        if tonumber(menu.panel_type) ~= BackendEumn.PanelType.Hiden and (baseTime >= menu.start_time and baseTime <= menu.end_time) then
            table.insert(tabData, {campId = id, menuId = menu.id, text = menu.title, sortIndex = menu.sort_val, icon = menu.ico})
        end
    end
    return tabData
end

function BackendModel:OpenRank(args)
    if self.rankWin == nil then
        self.rankWin = BackendRankWindow.New(self)
    end
    self.rankWin:Open(args)
end


