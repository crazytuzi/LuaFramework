TipsGoddessAttrView = TipsGoddessAttrView or BaseClass(BaseView)

function TipsGoddessAttrView:__init()
	self.ui_config = {"uis/views/goddess", "GoddessAttrTipView"}
	self.data = {}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
end

function TipsGoddessAttrView:__delete()
	
end

function TipsGoddessAttrView:LoadCallBack()
	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.bao_ji = self:FindVariable("Baoji")
	self.ming_zhong = self:FindVariable("Mingzhong")
	self.kang_bao = self:FindVariable("KangBao")
	self.shan_bi = self:FindVariable("Shanbi")
	self.ice_master = self:FindVariable("IceMaster")
	self.fire_master = self:FindVariable("FireMaster")
	self.thunder_master = self:FindVariable("ThunderMaster")
	self.poison_master = self:FindVariable("PoisonMaster")
	self.per_pvp_hurt_increase = self:FindVariable("PerPvpHurtIncrease")
	self.per_pvp_hurt_reduce = self:FindVariable("PerPvpHurtReduce")
	self.per_pofang = self:FindVariable("PerPofang")
	self.per_mianshang = self:FindVariable("PerMianshang")
	self.attr_percent = self:FindVariable("AttrPercent")

	self.capability = self:FindVariable("Capability")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsGoddessAttrView:ReleaseCallBack()
	self.hp = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.bao_ji = nil
	self.ming_zhong = nil
	self.kang_bao = nil
	self.shan_bi = nil
	self.ice_master = nil
	self.fire_master = nil
	self.thunder_master = nil
	self.poison_master = nil
	self.per_pvp_hurt_increase = nil
	self.per_pvp_hurt_reduce = nil
	self.per_pofang = nil
	self.per_mianshang = nil
	self.attr_percent = nil

	self.capability = nil
end

function TipsGoddessAttrView:CloseWindow()
	self:Close()
end

function TipsGoddessAttrView:OpenCallBack()
	self:Flush()
end

function TipsGoddessAttrView:SetAttrData(data)
	self.data = data or {}
end

function TipsGoddessAttrView:OnFlush()
	if type(self.data) ~= "table" then
		return
	end

	self.hp:SetValue(self.data.maxhp or self.data.maxhp or 0)
	self.gong_ji:SetValue(self.data.gongji or self.data.gong_ji or 0)
	self.fang_yu:SetValue(self.data.fangyu or self.data.fang_yu or 0)
	self.bao_ji:SetValue(self.data.baoji or self.data.bao_ji or 0)
	self.ming_zhong:SetValue(self.data.mingzhong or self.data.ming_zhong or 0)
	self.kang_bao:SetValue(self.data.jianren or self.data.jian_ren or 0)
	self.shan_bi:SetValue(self.data.shanbi or self.data.shan_bi or 0)
	self.ice_master:SetValue(self.data.icemaster or self.data.ice_master or 0)
	self.fire_master:SetValue(self.data.firemaster or self.data.fire_master or 0)
	self.thunder_master:SetValue(self.data.thundermaster or self.data.thunder_master or 0)
	self.poison_master:SetValue(self.data.poison_master or self.data.poison_master or 0)
	self.per_pvp_hurt_increase:SetValue((self.data.perpvphurtincrease or self.data.per_pvp_hurt_increase or 0) / 100)
	self.per_pvp_hurt_reduce:SetValue((self.data.perpvphurtreduce or self.data.per_pvp_hurt_reduce or 0) / 100)
	self.per_pofang:SetValue((self.data.perpofang or self.data.per_pofang or 0) / 100)
	self.per_mianshang:SetValue((self.data.permianshang or self.data.per_mianshang or 0) / 100)
	self.attr_percent:SetValue((self.data.attrpercent or self.data.attr_percent or 0) / 100)

	local cap = CommonDataManager.GetCapability(self.data)
	if cap and cap >= 0 then
		self.capability:SetValue(cap)
	else
		self.capability:SetValue(0)
	end
end