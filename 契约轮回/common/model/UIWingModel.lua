--
-- @Author: LaoY
-- @Date:   2018-09-19 20:18:40
--
UIWingModel = UIWingModel or class("UIWingModel", UIModel)
local this = UIWingModel

function UIWingModel:ctor(parent, npc_id, load_call_back, abName, assetName, act_name_list, defa_act)
    self.npc_id = npc_id;
    self.self_defa_act = "idle"
    if abName then
        self.self_defa_act = "idle2"
        self.abName = abName .. npc_id
        assetName = assetName or abName
        self.assetName = assetName .. npc_id
    else
        self.abName = "model_wing_" .. npc_id
        self.assetName = "model_wing_" .. npc_id
    end
    self.act_name_list = act_name_list
    self.defa_act = defa_act
    self.load_call_back = load_call_back
    UIWingModel.super.Load(self)
end

function UIWingModel:dctor()
end

function UIWingModel:LoadCallBack()
    --SetLocalRotation(self.transform , 0,0,0);
    local name_list = self.act_name_list or self.self_defa_act
    local defa_act = self.defa_act or self.self_defa_act
    self:AddAnimation(name_list, false, defa_act, 0.1)--,"casual"--"show" ,
    self.animator:CrossFade(name_list[1], 0)
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform, pos.x, pos.y, -200);
    if self.load_call_back then
        self.load_call_back()
    end
end

function UIWingModel:AddEvent()
end

function UIWingModel:SetData(data)

end