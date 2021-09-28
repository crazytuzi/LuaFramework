TipsLockVipView = TipsLockVipView or BaseClass(BaseView)

local IMAGE_LIST_LENGTH = 2

function TipsLockVipView:__init()
	self.ui_config = {"uis/views/tips/lockviptips_prefab", "LockVipTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsLockVipView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickChongZhi",
		BindTool.Bind(self.OnClickChongZhi, self))

	self.vip_level = self:FindVariable("VipLevel")
	self.notice = self:FindVariable("Notice")
end

function TipsLockVipView:ReleaseCallBack()
	self.vip_level = nil
	self.notice = nil
end

function TipsLockVipView:SetOpenReason(index)
	self.reason = index
	self:Flush()
end

-- 符文塔挂机权限是客户端定义的，直接写死
function TipsLockVipView:ShowRuneImage()
	self:SetOpenReason(99)
end

function TipsLockVipView:OpenCallBack()
	self:Flush()
end

function TipsLockVipView:OnClickCloseButton()
	self:Close()
end

function TipsLockVipView:CloseCallBack()

end

function TipsLockVipView:OnFlush()
	local str = Language.Vip.LockVip[self.reason]
	if nil == str or str == "" then
		self.vip_level:SetValue(Language.Vip.DefaultLockVip1)
		self.notice:SetValue(Language.Vip.DefaultLockVip2)
	else
		local level = self:CalculateVipLevel()
		if level == 1 then
			self.vip_level:SetValue(Language.Vip.FirstCharge)
		else
			self.vip_level:SetValue(string.format(Language.Vip.VipLevel, level))
		end
		self.notice:SetValue(str)
	end

end

function TipsLockVipView:CalculateVipLevel()
	-- 符文塔特殊处理
	if self.reason == 99 then
		local other_cfg = GuaJiTaData.Instance:GetRuneOtherCfg()
		if other_cfg then
			return other_cfg.auto_vip_limit or 0
		end
	end
	local now_vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local next_vip_level = now_vip_level
	local vip_config = VipData.Instance:GetVipLevelCfg()
    if vip_config then
        local info = vip_config[self.reason]
        if info then
        	local number = info["param_" .. now_vip_level] or 0
        	for i = now_vip_level + 1, 15 do
        		local next_number = info["param_" .. i] or 0
        		if next_number > number then
        			next_vip_level = i
        			break
        		end
        	end
        end
    end
    return next_vip_level
end

function TipsLockVipView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end