-- @Author: lwj
-- @Date:   2019-03-16 19:29:55
-- @Last Modified time: 2019-03-16 19:29:57

SysPredictionPanel = SysPredictionPanel or class("SysPredictionPanel", BasePanel)
local SysPredictionPanel = SysPredictionPanel

function SysPredictionPanel:ctor()
    self.abName = "main"
    self.assetName = "SysPredictionPanel"
    self.layer = "UI"

    self.use_background = true
    self.click_bg_close = true
    --self.model = CombineModel.GetInstance()
end

function SysPredictionPanel:CloseSelectPanel()
    self:Close()
end

function SysPredictionPanel:dctor()
end

function SysPredictionPanel:Open(data)
    self.data = data
    BasePanel.Open(self)
end

function SysPredictionPanel:LoadCallBack()
    self.nodes = {
        "btn_close", "des", "limit", "icon",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.limit = GetText(self.limit)
    self.icon = GetImage(self.icon)
    self:AddEvent()
end

function SysPredictionPanel:AddEvent()
    local function call_back(target, x, y)
        self:Close(self)
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
end

function SysPredictionPanel:OpenCallBack()
    self:UpdateView()
end

function SysPredictionPanel:UpdateView()
    if self.data then
        lua_resMgr:SetImageTexture(self, self.icon, self.data.res_tbl[1], tostring(self.data.res_tbl[2]), true, nil, false)
        self.des.text = self.data.pre_des
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        local remain = self.data.level - cur_lv
        local des = "Unlocks at L.%d"
        if self.data.task ~= 0 then
            des = "Main quests unlock at Lv.%d"
        end
        if remain < 1 then
            self.limit.text = string.format(des, self.data.level)
        else
            self.limit.text = string.format(des .. "\n(Lv.%d short)", self.data.level, remain)
        end
    end
end

function SysPredictionPanel:CloseCallBack()
end
