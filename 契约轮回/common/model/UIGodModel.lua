UIGodModel = UIGodModel or class("UIGodModel",UIModel)
local this = UIGodModel

function UIGodModel:ctor(parent,npc_id,load_call_back)
    self.abName = npc_id;--"model_monster_" ..
    self.assetName = npc_id;--"model_monster_" ..
    self.load_call_back = load_call_back
    UIGodModel.super.Load(self)
end

function UIGodModel:dctor()
end

function UIGodModel:LoadCallBack()
    self:AddAnimation({"idle","show1"},false,"idle",0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform , pos.x , pos.y , -200);
    --SetLocalRotation(self.transform , 0,0,0);
    if self.load_call_back then
        self.load_call_back()
    end
end

function UIGodModel:AddEvent()
end

function UIGodModel:SetData(data)

end

function UIGodModel:PlayAnimation(actionName,isLoop)
    AnimationManager:GetInstance():AddAnimation(self, self.animator, actionName, isLoop, "idle", 0.1)
end
