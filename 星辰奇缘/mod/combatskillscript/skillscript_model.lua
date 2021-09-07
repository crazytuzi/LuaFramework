-- 战斗出招表
-- @author huangzefeng
-- @date 20160616
SkillScriptModel = SkillScriptModel or BaseClass(BaseModel)

function SkillScriptModel:__init(mgr)
    self.win = nil
    self.currTab = nil
    self.mgr = mgr

end


function SkillScriptModel:OpenRoleSelectPanel(iscombat)
    if self.rolepanel == nil then
        self.rolepanel = RoleScriptSelectPanel.New(self)
    end
    self.rolepanel:Show(iscombat)
end

function SkillScriptModel:CloseRolePanel()
    if self.rolepanel ~= nil then
        self.rolepanel:DeleteMe()
        self.rolepanel = nil
    end
end

function SkillScriptModel:OpenPetSelectPanel(iscombat)
    if self.petpanel == nil then
        self.petpanel = PetScriptSelectPanel.New(self)
    end
    self.petpanel:Show(iscombat)
end


function SkillScriptModel:ClosePetPanel()
    if self.petpanel ~= nil then
        self.petpanel:DeleteMe()
        self.petpanel = nil
    end
end

function SkillScriptModel:OpenEditWindow(args)
    if self.window == nil then
        self.window = SkillScriptEditWindow.New(self)
    end
    self.window:Open(args)
end


function SkillScriptModel:CloseWindow()
    if self.window ~= nil then
        if self.window:CheckChange() then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.showClose = true
            confirmData.blueSure = true
            confirmData.greenCancel = true
            confirmData.sureLabel = TI18N("保存")
            confirmData.cancelLabel = TI18N("不保存")
            confirmData.sureCallback = function()
                if self.window ~= nil then
                    self.window:CheckSave()
                    WindowManager.Instance:CloseWindow(self.window)
                end
            end
            confirmData.cancelCallback = function()
                if self.window ~= nil then
                    WindowManager.Instance:CloseWindow(self.window)
                end
            end
            confirmData.content = TI18N("您当前有出招方案未保存，是否保存？")
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            WindowManager.Instance:CloseWindow(self.window)
        end
    end
end
