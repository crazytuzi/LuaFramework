-- 师徒，成为师徒提示面板
-- @author zgs
BeBSPanel = BeBSPanel or BaseClass(BasePanel)

function BeBSPanel:__init(model)
    self.model = model
    self.name = "BeBSPanel"

    self.resList = {
        {file = AssetConfig.bebs_panel, type = AssetType.Main}
    }
    self.data = nil
    self.OnOpenEvent:AddListener(function()
        self.data = self.openArgs
        self:UpdatePanel()
    end)

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePanel()
    end)
end


function BeBSPanel:RemovePanel()
    self:DeleteMe()
end

function BeBSPanel:OnInitCompleted()
    self.data = self.openArgs
    self:UpdatePanel()
end

function BeBSPanel:__delete()
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.bbsp = nil
    self.model = nil
end

function BeBSPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bebs_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("Main/Con")

    self.descText = self.MainCon:FindChild("DescText"):GetComponent(Text)
    -- self.descText2 = self.MainCon:FindChild("DescText2"):GetComponent(Text)

    self.dailyButton = self.MainCon:Find("DailyButton"):GetComponent(Button)
    self.taskButton = self.MainCon:FindChild("TaskButton"):GetComponent(Button)

    self.dailyButton.onClick:AddListener( function() self:onClickDailyButton() end)
    self.taskButton.onClick:AddListener( function() self:onClickTaskButton() end)

    -- self:DoClickPanel()
end

function BeBSPanel:onClickDailyButton()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {})
    -- BaseUtils.dump(self.data)
    if self.model.myTeacherInfo.status == 3 then
        --师傅
        local stuData = self.data
        stuData.rid = self.data.id
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
    elseif self.model.myTeacherInfo.status == 1 then
        --徒弟
         local stuData = {rid = RoleManager.Instance.RoleData.id,platform = RoleManager.Instance.RoleData.platform,zone_id = RoleManager.Instance.RoleData.zone_id, status = 1}
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
    end
    self:Hiden()
end

function BeBSPanel:onClickTaskButton()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    local key = BaseUtils.get_unique_npcid(47, 1)
    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
    self:Hiden()
end

function BeBSPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    -- print("BeBSPanel:DoClickPanel()"..debug.traceback())
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end


function BeBSPanel:UpdatePanel()
    if self.model.myTeacherInfo.status == 3 then
        self.descText.text = TI18N("恭喜你们成功结为师徒！弟子刚接触这个世界，作为师傅的你要好好爱护TA哦！\n徒弟完成<color='#00ff00'>师徒日常</color>和<color='#00ff00'>师徒目标</color>后，双方都可以获得<color='#ffff00'>丰厚奖励</color>哦！")
    elseif self.model.myTeacherInfo.status == 1 then
        self.descText.text = TI18N("恭喜你们成功结为师徒！遇到什么不懂的问题，可以多跟师傅交流哦！\n打师徒面板完成<color='#00ff00'>师徒日常</color>和<color='#00ff00'>师徒目标</color>可获得<color='#ffff00'>丰厚奖励</color>，不要错过哦！")
    end
end
