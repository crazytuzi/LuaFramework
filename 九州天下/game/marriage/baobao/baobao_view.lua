require("game/marriage/baobao/baobao_common_view")
require("game/marriage/baobao/baobao_attr_view")
require("game/marriage/baobao/baobao_aptitude_view")
require("game/marriage/baobao/baobao_bless_view")
require("game/marriage/baobao/baobao_guard_view")

BaoBaoView = BaoBaoView or BaseClass(BaseRender)

function BaoBaoView:__init(instance)
	self:SetMaskBg()
	self.cur_index = TabIndex.marriage_baobao
	self.is_show_aptitude = false
	self.image_view = BaoBaoImageView.New(self:FindObj("ImageView"))
	self.attr_view = BaoBaoAttrView.New(self:FindObj("AttrView"))
	self.aptitude_view = BaoBaoAptitudeView.New(self:FindObj("AptitudeView"), self)
	self.bless_view = BaoBaoBlessView.New(self:FindObj("BlessView"))
	self.guard_view = BaoBaoGuardView.New(self:FindObj("GuardView"))

	self:ListenEvent("OpenZizhiClick", BindTool.Bind(self.OpenZizhiClick, self, true))
	self.show_aptitude = self:FindVariable("ShowAptitude")
	self.show_aptitude:SetValue(false)

	BaobaoData.Instance:SetSelectedBabyIndex(1)

	self.attr_toggle = self:FindObj("AttrToggle").toggle
	self.bless_toggle = self:FindObj("BessToggle").toggle
	self.guard_toggle = self:FindObj("GuardToggle").toggle

	self.attr_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_baobao))
	self.bless_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_baobao_bless))
	self.guard_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_baobao_guard))
end

function BaoBaoView:__delete()
	if self.image_view then
		self.image_view:DeleteMe()
		self.image_view = nil
	end
	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
	if self.aptitude_view then
		self.aptitude_view:DeleteMe()
		self.aptitude_view = nil
	end
	if self.bless_view then
		self.bless_view:DeleteMe()
		self.bless_view = nil
	end
	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end
end

function BaoBaoView:ShowOrHideTab()
	
end

function BaoBaoView:OnToggleChange(index, is_on)
	if not is_on then return end
	self.cur_index = index
	self:Flush()
end

function BaoBaoView:SelectBaoBaoGuard()
	self.guard_toggle.isOn = true
end

function BaoBaoView:OpenBaobaoCallBack()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		self.bless_toggle.isOn = true
	else
		ViewManager.Instance:FlushView(ViewName.Marriage, "baobao")
	end
end

function BaoBaoView:OnFlush()
	if self.parent.cur_index ~= TabIndex.marriage_baobao then return end
	if self.cur_index == TabIndex.marriage_baobao then
		self.image_view:Flush()
		if self.is_show_aptitude then
			self.aptitude_view:Flush()
		else
			self.attr_view:Flush()
		end
	elseif self.cur_index == TabIndex.marriage_baobao_bless then
		self.bless_view:Flush()
	elseif self.cur_index == TabIndex.marriage_baobao_guard then
		self.image_view:Flush()
		self.guard_view:Flush()
	end
end

function BaoBaoView:OpenZizhiClick(value)
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	self.is_show_aptitude = value
	self.show_aptitude:SetValue(value)
	if self.is_show_aptitude then
		self.aptitude_view:Flush()
	else
		self.attr_view:Flush()
	end
end