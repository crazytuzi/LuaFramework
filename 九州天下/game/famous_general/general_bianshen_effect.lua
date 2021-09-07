-- PaintingEffect GeneralBianShenEffect
FamousGeneralEffect = FamousGeneralEffect or BaseClass(BaseView)
function FamousGeneralEffect:__init()
	self.ui_config = {"uis/views/miscpreload", "PaintingEffect"}
	self:SetMaskBg()
end

function FamousGeneralEffect:ReleaseCallBack()
	self.raw_image = nil
	self.raw_image_left = nil
end

function FamousGeneralEffect:LoadCallBack()
	self.raw_image = self:FindVariable("ShowBG")
	self.raw_image_left = self:FindVariable("ShowBGLeft")
	local use_seq = FamousGeneralData.Instance:GetCurUseSeq()
	local bundle, asset = ResPath.GetRawImage("BianShen_" .. use_seq)
	self.raw_image:SetAsset(bundle, asset)
	bundle, asset = ResPath.GetRawImage("effect_left")
	self.raw_image_left:SetAsset(bundle, asset)
	self.animator:ListenEvent("EffectStop", function ()
		self:Close()
	end)
end