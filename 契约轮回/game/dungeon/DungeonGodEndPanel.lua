
--- Created by Admin.
--- DateTime: 2019/11/2 16:11
DungeonGodEndPanel = DungeonGodEndPanel or class("DungeonGodEndPanel", BasePanel)
local this = DungeonGodEndPanel

function DungeonGodEndPanel:ctor()
    self.abName = "dungeon";
    self.assetName = "DungeonGodEndPanel"
    self.layer = "UI"
    self.events = {}
    self.items = {}
    self.model = DungeonModel.GetInstance()
end


function DungeonGodEndPanel:dctor()
    if self.enditem then
        self.enditem:destroy();
    end
    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
    end
    self.items = {}
    GlobalEvent:RemoveTabListener(self.events);
    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    self:StopAllSchedules()
end

function DungeonGodEndPanel:Open(data, is_saodang)
    self.data = data;
    self.is_saodang = is_saodang
    WindowPanel.Open(self)
end

function DungeonGodEndPanel:LoadCallBack()
    self.nodes = {
        "win/endCon","win/awardCon","win/zhandoujiangli","lose","win"
    }
    self:GetChildren(self.nodes)
    local orderIndex = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
    self:SetOrderIndex(orderIndex + 100)

    self:InitUI()
    self:AddEvent()
end

function DungeonGodEndPanel:InitUI()
    self.enditem = DungeonEndItem(self.transform, self.data);
    self.enditem:StartAutoClose(50);
    self.enditem.close_format = "Confirm";

    if self.data.isClear  then
        SetVisible(self.lose.gameObject,false)

        for i, v in pairs(self.data.reward) do
            if self.items[i] == nil then
                self.items[i] = GoodsIconSettorTwo(self.awardCon.transform)
            end

            local param = {}
            param["item_id"] = i;
            param["num"] = v;
            param["can_click"] = true;
            self.items[i]:SetIcon(param)
        end
    else
        SetVisible(self.win.gameObject,false)
    end

end

function DungeonGodEndPanel:AddEvent()
    local function closeCallBack()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close();
    end
    self.enditem:SetAutoCloseCallBack(closeCallBack);
    self.enditem:SetCloseCallBack(closeCallBack);

    local  time = 8;
    self.enditem:StartAutoClose(time);



    local function call_back()
        if self.is_saodang then
            self:Close()
        else
            self:Close()
            DungeonCtrl:GetInstance():RequestLeaveDungeon();
            SceneControler:GetInstance():RequestSceneLeave();
        end
    end
    self.enditem:SetCloseCallBack(call_back);
    self.enditem:SetAutoCloseCallBack(call_back)


    local function call_back()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)

    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
end
function DungeonGodEndPanel:StopAllSchedules()

end