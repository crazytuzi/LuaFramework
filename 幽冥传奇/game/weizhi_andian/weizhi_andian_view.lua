WeiZhiADView = WeiZhiADView or BaseClass(XuiBaseView)

local radio_height = 40
function WeiZhiADView:__init()
	if	WeiZhiADView.Instance then
		ErrorLog("[WeiZhiADView]:Attempt to create singleton twice!")
	end

	self.texture_path_list[1] = "res/xui/npc_dialog.png"
	self:SetIsAnyClickClose(true)
	-- self:SetModal(true)
	self.npc_obj_id = 0
	self.func_name = ""
	self.go_need_text = ""
	self.select_index = 1
	self.radio_list = {}
	self.def_index = 1
	self.config_tab = {
		{"weizhi_andian_ui_cfg", 1, {0}},
	}
	self.def_index = 1
end

function WeiZhiADView:__delete()

end

function WeiZhiADView:ReleaseCallBack()
	if nil ~= next(self.radio_list) then
		for k,v in pairs(self.radio_list) do
			v:DeleteMe()
		end
	end
	self.radio_list = {}
end

function WeiZhiADView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WeiZhiADView:LoadCallBack(index, loaded_times)
	local cfg_level = WeiZhiAnDianCfg and WeiZhiAnDianCfg.Level
	if nil == cfg_level then return end
	self.node_t_list.text_money.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))

	XUI.AddClickEventListener(self.node_t_list.btn_goto.node, function()
		TaskCtrl.SendNpcTalkReq(self.npc_obj_id, self.func_name)
	end, true)

	for i=1,3 do
		local MaxLevelTip = string.format(Language.Fuben.Text_4, Language.Fuben.CNum[i], cfg_level[i].min)
		local OtherTips = string.format(Language.Fuben.Text_3, Language.Fuben.CNum[i], cfg_level[i].min, cfg_level[i].max)
		local _text = i == 3 and MaxLevelTip or OtherTips
		self:AddRadio(i, {text = _text})
	end
end

function WeiZhiADView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WeiZhiADView:GetFloor()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local cfg = WeiZhiAnDianCfg
	for k,v in pairs(cfg.Level) do
		if level <= v.max then
			return k
		end
	end
	return 1
end

function WeiZhiADView:AddRadio(index, param)
	if nil == self.radio_list[index] then
		self.radio_list[index] = WZRadioRender.New()
		self.node_t_list.layout_weizhi_andian.node:addChild(self.radio_list[index]:GetView(), 300)
		self.radio_list[index]:GetView():setPosition(670, 200 - radio_height * index)
		self.radio_list[index]:SetIndex(index)
		self.radio_list[index]:AddClickEventListener(BindTool.Bind(self.OnClickRadio, self, index), false)
	end
	self.radio_list[index]:SetData(param)
	self.radio_list[index]:SetVisible(true)
end

function WeiZhiADView:OnClickRadio(index)
	for k, v in pairs(self.radio_list) do
		v:SetSelect(k == index)
	end
	self:FlushIndexVeiw(index)
end

function WeiZhiADView:FlushIndexVeiw(index)
	local cfg = WeiZhiAnDianCfg
	if nil == cfg then return end
	local MaxLevelTip = cfg.Level[index].min .. Language.Fuben.IntoTip
	local OtherTips = cfg.Level[index].min .. "-" .. cfg.Level[index].max .. Language.Fuben.TextLevel
	local text = index == 3 and MaxLevelTip or OtherTips
	self.node_t_list.text_need_1.node:setString(text)
	self.node_t_list.text_need_2.node:setString(self.go_need_text)
	self.node_t_list.text_desc_1.node:setString(cfg.Desc[index].num .. Language.Fuben.TextCeng)
	self.node_t_list.text_desc_2.node:setString(cfg.Desc[index].bossCount .. Language.Fuben.TextZhi)
	self.node_t_list.text_desc_3.node:setString(cfg.Desc[index].Rrefresh .. Language.Fuben.TextFZ)
	self.node_t_list.text_desc_4.node:setString(cfg.Desc[index].drops)

	self.node_t_list.btn_goto.node:setEnabled(index == self:GetFloor())
end

function WeiZhiADView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:PraseCLFubenData(v)
			self:OnClickRadio(self:GetFloor())
  		end
	end
end

function WeiZhiADView:PraseCLFubenData(data)
	local btn_t = RichTextUtil.Parse2Table(data.btn_list)
	for i, v in ipairs(btn_t) do
		if type(v) == "table" and v[1] == "btn" then
			self.func_name = v[4]
		end
	end
	self.npc_obj_id = data.obj_id
	self.go_need_text = data.cond
end

------------------------------------------------------------------------
WZRadioRender = WZRadioRender or BaseClass(BaseRender)
function WZRadioRender:__init()
end

function WZRadioRender:__delete()
	self.text_count = nil
end

function WZRadioRender:SetData(data)
	BaseRender.SetData(self, data)
	if nil ~= data then
		self.view:setContentWH(320, radio_height)
	end
end

function WZRadioRender:CreateChild()
	BaseRender.CreateChild(self)

	self.is_select = false

	self.img_check_bg = XUI.CreateImageView(15, radio_height / 2, ResPath.GetCommon("check_1_bg"), true)
	self.view:addChild(self.img_check_bg)
	self.img_check_cross = XUI.CreateImageView(15, radio_height / 2, ResPath.GetCommon("check_1_cross"), true)
	self.view:addChild(self.img_check_cross)

	self.text_count = XUI.CreateText(30, radio_height / 2, 0, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20)
	self.text_count:setAnchorPoint(0, 0.5)
	self.view:addChild(self.text_count)
	self.text_count:setString(self.data.text)

	self:SetSelect(self.index == 1)

	self:SetNormalColor()
end

function WZRadioRender:OnFlush()
	if nil == self.data then return end

end

function WZRadioRender:IsSelect()
	return self.img_check_cross:isVisible()
end

function WZRadioRender:SetSelect(is_select)
	self.is_select = is_select
	self.img_check_cross:setVisible(is_select)
	self.text_count:setColor(is_select and COLOR3B.GREEN or (self.normal_color or COLOR3B.WHITE))
end

function WZRadioRender:SetNormalColor(color)
	self.normal_color = color or COLOR3B.WHITE
	self.text_count:setColor(self.is_select and COLOR3B.GREEN or (self.normal_color or COLOR3B.WHITE))
end
