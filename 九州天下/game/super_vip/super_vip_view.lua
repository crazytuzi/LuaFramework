SuperVipView = SuperVipView or BaseClass(BaseView)

function SuperVipView:__init()
	self.ui_config = {"uis/views/supervip","SuperVip"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self:SetMaskBg()
end

function SuperVipView:__delete()

end

function SuperVipView:LoadCallBack()
	self.qq = self:FindVariable("qq")
	self.desc = self:FindVariable("desc")
	self.gold_num = self:FindVariable("gold_num")
	self.img_gm = self:FindVariable("img_gm")

	self:ListenEvent("OnClickCharge", BindTool.Bind(self.OnClickCharge, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.Close, self))
end

function SuperVipView:ReleaseCallBack() 
	self.qq = nil
	self.desc = nil
	self.gold_num = nil
	self.img_gm = nil
end

function SuperVipView:OpenCallBack()
	local func = function(gm_info)
		self:Flush("gm_info", {gm_info = gm_info})
	end
	SuperVipCtrl.Instance:GmVerifyCallBack(func)
end

function SuperVipView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "gm_info" then
			if next(v.gm_info) then
				local need_chongzhi = SuperVipData.Instance:GetNeedChongzhiNum()
				self.gold_num:SetValue(need_chongzhi)

				local total_chongzhi = PlayerData.Instance:GetTotalChongZhi()
				if total_chongzhi >= need_chongzhi then
					self.qq:SetValue(string.format(Language.SuperVip.ShowQQ, v.gm_info.qq))
				else
					self.qq:SetValue(Language.SuperVip.NotShowQQ)
				end

				self.img_gm:SetAsset(ResPath.GetSuperVipImage(v.gm_info.img))
				self.desc:SetValue(Language.SuperVip.GmInfo)
			end
		end
	end
end

function SuperVipView:OnClickCharge()
	ViewManager.Instance:Open(ViewName.RechargeView)
end