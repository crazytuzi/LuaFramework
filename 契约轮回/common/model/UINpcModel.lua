--
-- @Author: LaoY
-- @Date:   2018-09-19 20:18:40
--
UINpcModel = UINpcModel or class("UINpcModel",UIModel)

function UINpcModel:ctor(parent,res_id,load_call_back)
	self.abName = res_id
	self.assetName = res_id
	self.load_call_back = load_call_back
	-- poolMgr:AddConfig(self.abName,self.assetName,1,60,true)
	UINpcModel.super.Load(self)
end

function UINpcModel:dctor()
	--print(111111111111)
end

function UINpcModel:LoadCallBack()
	self:AddAnimation({"idle","casual"},true,nil,0)

	if self.load_call_back then
		self.load_call_back()
	end
end

function UINpcModel:AddEvent()
end

function UINpcModel:SetData(data)

end