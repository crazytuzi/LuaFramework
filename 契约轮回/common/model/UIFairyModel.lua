UIFairyModel = UIFairyModel or class("UIFairyModel",UIModel)
local UIFairyModel = UIFairyModel

function UIFairyModel:ctor(parent,res_id,load_call_back)
	UIFairyModel.Instance = self
	self.abName = "model_cw_" .. res_id
	self.assetName = "model_cw_" .. res_id
	self.load_call_back = load_call_back
	UIFairyModel.super.Load(self)
end


function UIFairyModel:dctor()
end

function UIFairyModel:LoadCallBack()
	self:AddAnimation({"idle"},false,"idle",0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform , pos.x , pos.y , -200);
    --SetLocalRotation(self.transform , 0,0,0);
	if self.load_call_back then
		self.load_call_back()
	end
end

function UIFairyModel:AddEvent()
end

function UIFairyModel:SetData(data)

end

