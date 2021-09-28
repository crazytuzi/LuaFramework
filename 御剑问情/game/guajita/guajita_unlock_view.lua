GuajiTaFbUnlockView = GuajiTaFbUnlockView or BaseClass(BaseView)

function GuajiTaFbUnlockView:__init()
	self.ui_config = {"uis/views/guajitaview_prefab", "GuajiTaFinishView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.data = nil
end

function GuajiTaFbUnlockView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self.dec = self:FindVariable("Dec")
	self.is_one = self:FindVariable("IsOne")
	self.one_img = self:FindVariable("OneImg")
	self.item_img1 = self:FindVariable("ItemImg1")
	self.item_img2 = self:FindVariable("ItemImg2")
	self.item_img3 = self:FindVariable("ItemImg3")
	self.title_img = self:FindVariable("TitleImg")
end

function GuajiTaFbUnlockView:ReleaseCallBack()
	self.dec = nil
	self.is_one = nil
	self.one_img = nil
	self.item_img1 = nil
	self.item_img2 = nil
	self.item_img3 = nil
	self.title_img = nil
end

function GuajiTaFbUnlockView:__delete()

end

function GuajiTaFbUnlockView:SetData(data)
	self.data = data
	self:Open()
end

function GuajiTaFbUnlockView:OpenCallBack()
	self:Flush()
end

function GuajiTaFbUnlockView:CloseCallBack()
	self.data = nil
end

function GuajiTaFbUnlockView:OnClickClose()
	FuBenCtrl.Instance:SendEnterNextFBReq()
	self:Close()
end

function GuajiTaFbUnlockView:OnFlush()
	if nil == self.data then return end
	local sp_type = self.data.sp_type
	self.is_one:SetValue(sp_type ~= GuaJiTaData.SP_TYPE.TYPE)
	if sp_type == GuaJiTaData.SP_TYPE.TYPE then
		local item_t = Split(self.data.sp_show, "#")
		local name_t = {"", "", ""}
		for i=1,3 do
			local item_id = tonumber(item_t[i])
			if item_id then
				self["item_img" .. i]:SetAsset( ResPath.GetItemIcon(item_id))
				name_t[i] = RuneData.Instance:GetNameByItemId(item_id)
			end
		end
		self.dec:SetValue(string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", name_t[1], name_t[2], name_t[3]))
	else
		if sp_type == GuaJiTaData.SP_TYPE.SLOT then
			self.one_img:SetAsset("uis/views/guajitaview/images_atlas", "img_open_slot")
			self.dec:SetValue(string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", 1))
		else
			self.one_img:SetAsset("uis/views/guajitaview/images_atlas", "img_uplevel")
			self.dec:SetValue(string.format(Language.Rune.GuajitaUnlockDec[sp_type] or "", self.data.upperlimit_increase))
		end
	end
	self.title_img:SetAsset("uis/views/guajitaview/images_atlas", "sp_word" .. sp_type)
end