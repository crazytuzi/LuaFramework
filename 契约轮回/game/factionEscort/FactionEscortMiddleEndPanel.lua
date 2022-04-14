FactionEscortMiddleEndPanel = FactionEscortMiddleEndPanel or class("FactionEscortMiddleEndPanel", BaseRewardPanel)
local FactionEscortMiddleEndPanel = FactionEscortMiddleEndPanel

function FactionEscortMiddleEndPanel:ctor()
    self.abName = "factionEscort"
    self.assetName = "FactionEscortMiddleEndPanel"
    self.image_ab = "factionEscort_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.items = {}
    self.model = FactionEscortModel:GetInstance()
    self.isTimes = false

end

function FactionEscortMiddleEndPanel:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
end

function FactionEscortMiddleEndPanel:CloseCallBack()

end

function FactionEscortMiddleEndPanel:Open(qua,data)
    self.qua = qua
    self.data = data
    dump(self.data)
    local des = "Confirm"
    if self.data.progress == 1 then
        des = "Keep travelling"
    end
    self.btn_list = {
        {btn_res = "common:btn_blue_2",btn_name = "Cancel",call_back = handler(self,self.Close)},
        {btn_res = "common:btn_yellow_2",btn_name = des,format = "Auto closing in %s sec", auto_time=10, call_back = handler(self,self.OkFunc)},

    }
    FactionEscortMiddleEndPanel.super.Open(self)
end

function FactionEscortMiddleEndPanel:LoadCallBack()
    self.nodes =
    {
        "ScrollView/Viewport/Content","tips",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.tips = GetText(self.tips)
    self:AddEvent()
    self:InitUI()

end

function FactionEscortMiddleEndPanel:InitUI()
    local rewards = self.data.rewards
    local index = 0
    for i, v in pairs(rewards) do
        if self.items[index] == nil  then
            self.items[index] = GoodsIconSettorTwo(self.Content)
        end

        local param = {}
        param["model"] = self.model
        param["item_id"] = i
        param["num"] = v
        self.items[index]:SetIcon(param)

        --self.items[index]:UpdateIconByItemIdClick(i,v)
        index = index + 1
    end
    if self.data.progress == 1 then
       -- self:Close()
       -- SetVisible(self.tips,false)
        local db = Config.db_escort_road
        local npcDB = Config.db_npc
        local id = db[1].second
        local npcName = npcDB[id].name
        self.tips.text = string.format("The above are the gifts from <color=#27C31F>%s</color>",npcName)
        return
    end
   -- if self.data.result == 0 then --失败
      --  SetVisible(self.win,false)
        --local itemStr = Config.db_escort_product[self.key].failure
     --   self:InitItems()
   -- else
        --SetVisible(self.lose,false)
        --   local itemStr = Config.db_escort_product[self.key].complete
       -- self:InitItems()
        SetVisible(self.tips,true)
        local db = Config.db_escort[1]
        local aTimes = db.attend - self.model.escortCount
        if aTimes <= 0 then
            self.tips.text = "Your daily attempts are used up, please come back tomorrow."
            self.isTimes = false
           -- SetVisible(self.okbtn,false)
        else
            self.isTimes = true
            self.tips.text = string.format("Today you still have <color=#43f673>%s</color>Polar cross chance. Continue?",aTimes)
        end
   -- end






end



function FactionEscortMiddleEndPanel:AddEvent()
    --local function call_back()
    --    self:Close()
    --end
    --AddClickEvent(self.qxbtn.gameObject,call_back)
    --  self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortStart, handler(self, self.FactionEscortStart))  --刷新
end
function FactionEscortMiddleEndPanel:OkFunc()
    if self.data.progress == 1 then
         self:Close()
        return
    end
    if self.isTimes then
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

       -- OperationManager:GetInstance():TryMoveToPosition(sceneID,start_pos,endPos,callback)
       local boo =  SceneControler:GetInstance():UseFlyShoeToPos(sceneID,endPos.x,endPos.y,true,callback)
        if not boo then
            OperationManager:GetInstance():TryMoveToPosition(sceneID,start_pos,endPos,callback)
        end
    end
    self:Close()
end


