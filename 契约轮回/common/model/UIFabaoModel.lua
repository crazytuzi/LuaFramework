--
-- @Author: LaoY
-- @Date:   2018-09-19 20:18:40
--
UIFabaoModel = UIFabaoModel or class("UIFabaoModel", UIModel)
local UIFabaoModel = UIFabaoModel

function UIFabaoModel:ctor(parent, npc_id, load_call_back)
    self.npc_id = npc_id;
    self.abName = "model_fabao_" .. npc_id
    self.assetName = "model_fabao_" .. npc_id
    self.load_call_back = load_call_back
    UIFabaoModel.super.Load(self)
end

function UIFabaoModel:dctor()
end

function UIFabaoModel:LoadCallBack()
    self:AddAnimation({ "show", "idle" }, false, "idle", 0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform, pos.x, pos.y, -200);
    --SetLocalRotation(self.transform , 0,0,0);
    if self.load_call_back then
        self.load_call_back()
    end
end

function UIFabaoModel:AddEvent()
end

function UIFabaoModel:SetData(data)

end