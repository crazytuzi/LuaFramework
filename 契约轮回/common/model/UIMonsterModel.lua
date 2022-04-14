--
-- @Author: LaoY
-- @Date:   2018-09-19 20:18:40
--
UIMonsterModel = UIMonsterModel or class("UIMonsterModel",UIModel)
local this = UIMonsterModel

function UIMonsterModel:ctor(parent,npc_id,load_call_back)
	self.abName = npc_id;--"model_monster_" ..
	self.assetName = npc_id;--"model_monster_" ..
	self.load_call_back = load_call_back
	UIMonsterModel.super.Load(self)
end

function UIMonsterModel:dctor()
end

function UIMonsterModel:LoadCallBack()
	self:AddAnimation({"idle"},false,"idle",0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform , pos.x , pos.y , -200);
    --SetLocalRotation(self.transform , 0,0,0);
	if self.load_call_back then
		self.load_call_back()
	end
end

function UIMonsterModel:AddEvent()
end

function UIMonsterModel:SetData(data)

end