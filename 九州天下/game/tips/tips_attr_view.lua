TipsAttrView = TipsAttrView or BaseClass(BaseView)

function TipsAttrView:__init()
	self.ui_config = {"uis/views/tips/attrtips", "AttrTipView"}
	self.data = {}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
end

function TipsAttrView:__delete()

end

function TipsAttrView:LoadCallBack()
	--获取变量
	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.bao_ji = self:FindVariable("Baoji")
	self.ming_zhong = self:FindVariable("Mingzhong")
	self.kang_bao = self:FindVariable("KangBao")
	self.shan_bi = self:FindVariable("Shanbi")

	self.show_baoji = self:FindVariable("ShowBaoji")
	self.show_fangyu = self:FindVariable("ShowFangyu")
	self.show_gongji = self:FindVariable("ShowGongji")
	self.show_hp = self:FindVariable("ShowHp")
	self.show_kangbao = self:FindVariable("ShowKangBao")
	self.show_mingzhong = self:FindVariable("ShowMingzhong")
	self.show_shanbi = self:FindVariable("ShowShanbi")


	self.tips_name = self:FindVariable("tips_name")
	self.capability = self:FindVariable("Capability")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsAttrView:ReleaseCallBack()
	-- 清理变量和对象
	self.hp = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.bao_ji = nil
	self.ming_zhong = nil
	self.kang_bao = nil
	self.shan_bi = nil
	self.show_baoji = nil
	self.show_fangyu = nil
	self.show_gongji = nil
	self.show_hp = nil
	self.show_kangbao = nil
	self.show_mingzhong = nil
	self.show_shanbi = nil
	self.capability = nil
	self.tips_name = nil
end

function TipsAttrView:CloseWindow()
	self:Close()
end

function TipsAttrView:OpenCallBack()
	self:Flush()
end

function TipsAttrView:SetAttrData(data)
	self.data = data or {}
end

-- 过滤属性不显示
function TipsAttrView:MaskProperty(...)
	local args = {...}
	for i=1, #args do
		self.data[args[i]] = -1
	end
end

function TipsAttrView:OnFlush()
	if type(self.data) ~= "table" then
		self.data = {}
	end

	local hp = self.data.max_hp or self.data.maxhp or 0
	local gong_ji = self.data.gong_ji or self.data.gongji or 0
	local fang_yu = self.data.fang_yu or self.data.fangyu or 0
	local ming_zhong = self.data.ming_zhong or self.data.mingzhong or 0
	local shan_bi = self.data.shan_bi or self.data.shanbi or 0
	local bao_ji = self.data.bao_ji or self.data.baoji or 0
	local jian_ren = self.data.jian_ren or self.data.jianren or 0
	local move_speed = self.data.move_speed
	local per_jingzhun = self.data.per_jingzhun
	local per_baoji = self.data.per_baoji
	local per_pofang = self.data.per_pofang
	local per_mianshang = self.data.per_mianshang

	if hp and hp > 0 then
		self.show_hp:SetValue(true)
		self.hp:SetValue(hp)
	else
		self.show_hp:SetValue(false)
	end

	if gong_ji and gong_ji > 0 then
		self.show_gongji:SetValue(true)
		self.gong_ji:SetValue(gong_ji)
	else
		self.show_gongji:SetValue(false)
	end

	if fang_yu and fang_yu > 0 then
		self.show_fangyu:SetValue(true)
		self.fang_yu:SetValue(fang_yu)
	else
		self.show_fangyu:SetValue(false)
	end

	if ming_zhong and ming_zhong > 0 then
		self.show_mingzhong:SetValue(true)
		self.ming_zhong:SetValue(ming_zhong)
	else
		self.show_mingzhong:SetValue(false)
	end

	if shan_bi and shan_bi > 0 then
		self.show_shanbi:SetValue(true)
		self.shan_bi:SetValue(shan_bi)
	else
		self.show_shanbi:SetValue(false)
	end

	if bao_ji and bao_ji > 0 then
		self.show_baoji:SetValue(true)
		self.bao_ji:SetValue(bao_ji)
	else
		self.show_baoji:SetValue(false)
	end

	if jian_ren and jian_ren > 0 then
		self.show_kangbao:SetValue(true)
		self.kang_bao:SetValue(jian_ren)
	else
		self.show_kangbao:SetValue(false)
	end

	local cap = CommonDataManager.GetCapability(self.data)
	if cap and cap >= 0 then
		self.capability:SetValue(cap)
	else
		self.capability:SetValue(0)
	end

	self.tips_name:SetValue(self.data.name or Language.JingLing.AttrTipTitle)
end