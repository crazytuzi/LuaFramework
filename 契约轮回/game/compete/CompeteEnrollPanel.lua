---
--- Created by  Administrator
--- DateTime: 2019/11/21 10:59
---
CompeteEnrollPanel = CompeteEnrollPanel or class("CompeteEnrollPanel", BasePanel)
local this = CompeteEnrollPanel

function CompeteEnrollPanel:ctor(parent_node, parent_panel)
    self.abName = "compete";
    self.image_ab = "compete_image";
    self.assetName = "CompeteEnrollPanel"
    self.use_background = true
    self.show_sidebar = false
    self.model = CompeteModel:GetInstance()
    self.items = {}
    self.events = {}
    self.gEvent = {}
    self.type = 0  --1报名 2跳转
end

function CompeteEnrollPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvent)
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
end

function CompeteEnrollPanel:LoadCallBack()
    self.model.isFirstOpenEroll = false
    self.model:CheckEnrollRedPoint()
    self.nodes = {
        "bg","enrollBtn","enrollBtn/enrollBtnTex","closeBtn",
        "textParent","nums","start/startTime","end/endTime","CompeteEnrollItem",
    }
    self:GetChildren(self.nodes)
    self.bigBg = GetImage(self.bg)
    self.enrollBtnTex = GetText(self.enrollBtnTex)
    self.nums = GetText(self.nums)
    self.endTime = GetText(self.endTime)
    self.startTime = GetText(self.startTime)
    self:InitUI()
    self:AddEvent()
    lua_resMgr:SetImageTexture(self, self.bigBg, "iconasset/icon_big_bg_compete_big_bg2", "compete_big_bg2", true)
    CompeteController:GetInstance():RequstCompetePanelInfo()
end

function CompeteEnrollPanel:InitUI()
    self:InitTextItems()
end

function CompeteEnrollPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    local function call_back()  --
        if self.type == 2 then
           -- self.enrollBtnTex = "查看流程"
            lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 5);
            self:Close()
        else
           -- self.enrollBtnTex = "点击报名"
            CompeteController:GetInstance():RequstCompeteEnroll(self.model.actId)
        end
    end
    AddClickEvent(self.enrollBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompetePanelInfo,handler(self,self.CompetePanelInfo))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteEnroll,handler(self,self.CompeteEnroll))

    local function call_back(id)
        if self.items[1] and self.items[1].data[1] == id then
            self.items[1]:UpdateNums()
        end
    end
    self.gEvent[#self.gEvent + 1]  = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

end

function CompeteEnrollPanel:InitTextItems()
    local tab = self.model:GetEnrollCondition()
    local costTab = self.model:GetEnterCost()
    if costTab then
         --local costId = costTab[1]
        -- local num = costTab[2]
        local item = self.items[1]
        if not item  then
            item = CompeteEnrollItem(self.CompeteEnrollItem.gameObject,self.textParent,"UI")
            self.items[1] = item
        end
        item:SetData(costTab)
    end
    for i = 1, #tab do
        local item = self.items[i + 1]
        if not item  then
            item = CompeteEnrollItem(self.CompeteEnrollItem.gameObject,self.textParent,"UI")
            self.items[i + 1] = item
        end
        item:SetData(tab[i])
    end

end


function CompeteEnrollPanel:CompetePanelInfo(data)
        if self.model.isEnroll then
            self.type = 2
            self.enrollBtnTex.text = "View process"
        else
            if self.model.curPeriod ~= enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL then
                self.type = 2
                self.enrollBtnTex.text = "View process"
            else
                self.type = 1
                self.enrollBtnTex.text = "Tap to register"
            end

        end
    self.enrollNum = (data.enroll_num) * 2
    self.nums.text = string.format("Registered: <color=#6CFE00>%s</color>",self.enrollNum)

    local endtime = os.date("%m/%d/%H/%M", data.enroll_etime)
    self.endTime.text = endtime
    local startTime = os.date("%m/%d/%H/%M", data.select_stime)
    self.startTime.text = startTime
end

function CompeteEnrollPanel:CompeteEnroll(data)
    Notify.ShowText("Successfully signed up")
    if self.model.isEnroll then
        self.type = 2
        self.enrollBtnTex.text = "View process"
    else
        self.type = 1
        self.enrollBtnTex.text = "Tap to register"
    end
    self.enrollNum = self.enrollNum + 1
    self.nums.text = string.format("Registered: <color=#6CFE00>%s</color>",self.enrollNum)
    self.items[1]:UpdateNums()
end