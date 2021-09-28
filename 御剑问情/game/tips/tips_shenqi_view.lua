ShenQiTipsView = ShenQiTipsView or BaseClass(BaseView)

function ShenQiTipsView:__init()
	self.ui_config = {"uis/views/tips/shenqitips_prefab", "ShenQiEffectTips"}

	self.data = nil
	self.index = 1
	self.show_type = ShenqiData.ChooseType.JianLing
	self.item_id = 0
end

function ShenQiTipsView:__delete()

end

function ShenQiTipsView:LoadCallBack()
    --variable
	self.xiaoguo = self:FindVariable("XiaoGuo")
	self.tiaojian = self:FindVariable("TiaoJian")
	self.chengfa = self:FindVariable("ChengFa")
	self.total_num = self:FindVariable("Total_Num")
	self.now_num = self:FindVariable("Now_Num")
	self.show_active = self:FindVariable("ShowActive")
	self.name = self:FindVariable("Name")
	self.use_text = self:FindVariable("UseText")
	self.is_jianling = self:FindVariable("IsJiangLing")
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.hp = self:FindVariable("Hp")
	self.kangbao = self:FindVariable("KangBao")
	self.shanbi = self:FindVariable("ShanBi")
	self.baoji = self:FindVariable("BaoJi")
	self.mingzhong = self:FindVariable("MingZhong")

	--event
	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("ClickActive", BindTool.Bind(self.ClickActive, self))
	self:ListenEvent("ClickUse", BindTool.Bind(self.ClickUse, self))

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	
	--obj
	self.model = RoleModel.New()
	self.model:SetDisplay(self:FindObj("Display").ui3d_display)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.button_use = self:FindObj("ButtonUse")
	self.text_gray = self:FindObj("UseText")
end

function ShenQiTipsView:ReleaseCallBack()
	if self.model then
		self.model:RemoveHead()
		if self.model.draw_obj ~= nil then
			self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
		end		
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.xiaoguo = nil
	self.tiaojian = nil
	self.chengfa = nil
	self.total_num = nil
	self.now_num = nil
	self.show_active = nil
	self.name = nil
	self.use_text = nil
	self.is_jianling = nil
	self.gongji = nil
	self.fangyu = nil
	self.hp = nil
	self.kangbao = nil
	self.shanbi = nil
	self.baoji = nil
	self.mingzhong = nil

	self.button_use = nil
	self.text_gray = nil
	self.item_data_event = nil
end

function ShenQiTipsView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenQiTipsView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function ShenQiTipsView:OnFlush()
	self:FlushOther()
	self:FlushAttribute()
	self:FlushNowEffect()
	self:FlushModel()
end
	
function ShenQiTipsView:Show(index, cfg, shenqi_type)
	if nil == cfg and nil == cfg[index] then
		return
	end

	self.index = index
	self.data = cfg[index]
	self.show_type = shenqi_type
end

function ShenQiTipsView:FlushOther()
	if nil == self.data then
		return
	end

	self.name:SetValue(self.data.name)
	self.xiaoguo:SetValue(self.data.str1)
	self.tiaojian:SetValue(self.data.str2)
	self.chengfa:SetValue(self.data.str3)

end

function ShenQiTipsView:FlushAttribute()
	self.gongji:SetValue(self.data.gongji)
	self.fangyu:SetValue(self.data.fangyu)
	self.hp:SetValue(self.data.maxhp)
	self.kangbao:SetValue(self.data.jianren)
	self.shanbi:SetValue(self.data.shanbi)
	self.baoji:SetValue(self.data.baoji)
	self.mingzhong:SetValue(self.data.mingzhong)
end

--刷新激活状态
function ShenQiTipsView:FlushNowEffect()
	local info = ShenqiData.Instance:GetShenqiAllInfo()
	if nil == info then
		return
	end

	--没有激活
	local is_active = false
	local is_use = false
	if self.show_type == ShenqiData.ChooseType.JianLing then
		self.is_jianling:SetValue(true)
		is_active = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
		is_use = (self.index == info.shenbing_cur_texiao_id)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		self.is_jianling:SetValue(false)
		is_active = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
		is_use = (self.index == info.baojia_cur_texiao_id)
	end

	if not is_active then
		self.show_active:SetValue(false)
		self.item_cell:SetData({item_id = self.data.active_texiao_stuff_id})
		
		local now_num = ItemData.Instance:GetItemNumInBagById(self.data.active_texiao_stuff_id)
		if now_num < self.data.active_texiao_stuff_count then
			self.now_num:SetValue(ToColorStr(now_num, TEXT_COLOR.RED))
		else
			self.now_num:SetValue(ToColorStr(now_num, TEXT_COLOR.YELLOW))
		end
		self.total_num:SetValue(self.data.active_texiao_stuff_count)
	else
	--激活
		self.show_active:SetValue(true)
		--先将按钮置灰，后面再修改效果
		if is_use then
			self.use_text:SetValue(Language.ShenQi.isUse)
			self.button_use.grayscale.GrayScale = 255
			self.text_gray.grayscale.GrayScale = 255
			self.button_use.button.interactable = false
		else
			self.use_text:SetValue(Language.ShenQi.Use)
			self.button_use.grayscale.GrayScale = 0
			self.text_gray.grayscale.GrayScale = 0
			self.button_use.button.interactable = true			
		end
	end	
end

--宝甲 GetBaojiaResCfgByIamgeID
function ShenQiTipsView:FlushModel()
	if self.model then
		self.model:SetPanelName("shenqi_baojia_tips")
		if self.show_type == ShenqiData.ChooseType.JianLing then
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetRoleResid(main_role:GetRoleResId())			
			local head_id = ShenqiData.Instance:GetHeadResId(self.index)
			if head_id then
				local bundle, name = ResPath.GetHeadModel(head_id)
				self.model:SetHeadRes(bundle, name)
			end

			self.model:SetLoadComplete(function()
				self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
			end)
			--两次强制关闭舞蹈
			self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
		elseif self.show_type == ShenqiData.ChooseType.BaoJia then
			if self.model ~= nil and self.model.draw_obj ~= nil then
				self.model:RemoveHead()
				local id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.index)
				if nil ~= id then
					self.model:SetRoleResid(id)
					self.model:SetLoadComplete(function()
						self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 1)
					end)
					--两次强制跳舞
					self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 1)
				end
			end
		end		
	end
end

function ShenQiTipsView:ClickClose()
	self:Close()
end

function ShenQiTipsView:ClickActive()
	if self.show_type == ShenqiData.ChooseType.JianLing then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENGBING_TEXIAO_ACTIVE, self.index)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BaoJia_TEXIAO_ACTIVE, self.index)
	end
end

function ShenQiTipsView:ClickUse()
	if self.show_type == ShenqiData.ChooseType.JianLing then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_TEXIAO, self.index)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_TEXIAO, self.index)
	end
end

function ShenQiTipsView:ItemDataChangeCallback()
	self:FlushNowEffect()
end