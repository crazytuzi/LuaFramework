--
-- @Author: LaoY
-- @Date:   2018-09-19 20:18:40
--
UIMountModel = UIMountModel or class("UIMountModel",UIModel)
local UIMountModel = UIMountModel

function UIMountModel:ctor(parent,npc_id,load_call_back,isIdle)
	self.abName = npc_id;--"model_mount_" ..
	self.assetName = npc_id;--"model_mount_" ..
	self.load_call_back = load_call_back
	if isIdle == nil then
		self.isIdle = true
	else
		self.isIdle = isIdle
	end

	UIMountModel.super.Load(self)
end

function UIMountModel:dctor()
end

function UIMountModel:LoadCallBack()
	if self.isIdle then
		self:AddAnimation({"show","idle"},false,"idle",0)
	end
	--self:AddAnimation({"show","idle"},false,"idle",0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform , pos.x , pos.y , -200);
    --SetLocalRotation(self.transform , 0,0,0);
	if self.load_call_back then
		self.load_call_back()
	end
end

function UIMountModel:AddEvent()
end

function UIMountModel:SetData(data)

end