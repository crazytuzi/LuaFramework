FactionEscortTipsPanel = FactionEscortTipsPanel or class("FactionEscortTipsPanel", WindowPanel)
local FactionEscortTipsPanel = FactionEscortTipsPanel

function FactionEscortTipsPanel:ctor()
    self.abName = "factionEscort"
    self.assetName = "FactionEscortTipsPanel"
    self.image_ab = "factionEscort_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 4
    self.model = FactionEscortModel:GetInstance()
    
    self.is_show_open_action = true
end

function FactionEscortTipsPanel:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
end

function FactionEscortTipsPanel:CloseCallBack()

end

function FactionEscortTipsPanel:Open()
    FactionEscortTipsPanel.super.Open(self)
end

function FactionEscortTipsPanel:LoadCallBack()
    self.nodes =
    {
        "des","goBtn"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self:SetTileTextImage("factionEscort_image", "escrot_tips_title")
    self.des = GetText(self.des)
    self:AddEvent()
    self:InitUI()

end

function FactionEscortTipsPanel:InitUI()
    local startTime1,startTime2,startTime3,startTime4 = self.model:DoubleStartText()
    local endTime1,endTime2,endTime3,endTime4 = self.model:DoubleEndText()
    self.des.text = string.format("2.200% Rewards time <color=#27C31F>%s:%s-%s:%s</color> and  <color=#27C31F>%s:%s-%s:%s</color>",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)
end


function FactionEscortTipsPanel:AddEvent()

    local function call_back()
        if self.model.isEscorting then
            Notify.ShowText("You are on an escort quest")
            return
        else
            local roadDb = Config.db_escort_road
            local start = roadDb[1].start
            local npcDB = Config.db_npc
            local sceneID = npcDB[start].scene
            local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneID,start)
            local main_role = SceneManager:GetInstance():GetMainRole()
            local start_pos = main_role:GetPosition()
            function callback()
                local npc_object = SceneManager:GetInstance():GetObject(start)
                if npc_object then
                    npc_object:OnClick()
                end
            end
            --local sceneData = SceneManager:GetInstance():GetSceneInfo()
            --if sceneData.scene ~=  then
            --
            --end
           -- OperationManager:GetInstance():TryMoveToPosition(sceneID,start_pos,endPos,callback)
            local boo = SceneControler:GetInstance():UseFlyShoeToPos(sceneID,endPos.x,endPos.y,true,callback)
            if  not boo  then
                OperationManager:GetInstance():TryMoveToPosition(sceneID,start_pos,endPos,callback)
            end
            self:Close()
        end
    end
    AddButtonEvent(self.goBtn.gameObject,call_back)
    --  self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortStart, handler(self, self.FactionEscortStart))  --刷新
end



