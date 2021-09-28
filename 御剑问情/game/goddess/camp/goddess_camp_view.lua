--------------------------------------------------------------------------
--GoddessCampView 	女神阵型面板
--------------------------------------------------------------------------
Lineup_type = {
	"fight",
	"assist_one",
	"assist_two",
	"assist_three"
}

GODDESS_MODEL_ID_1 = 7001001
GODDESS_MODEL_ID_2 = 7003001
GODDESS_MODEL_ID_3 = 7002001
GODDESS_MODEL_ID_4 = 7004001
GODDESS_MODEL_ID_5 = 7004001
GODDESS_MODEL_ID_6 = 7004001
GODDESS_MODEL_ID_7 = 7004001

GoddessCampView = GoddessCampView or BaseClass(BaseRender)
local DIFFERENT_GRADE = 1 --服务端1阶 客户端0阶
local SHOW_ANIM_CAMP =
{
	CAMP_1 = 1,
	CAMP_2 = 2,
	CAMP_3 = 3,
	CAMP_4 = 4,
}

function GoddessCampView:__init(instance)
	self:InitView()
	self.select_lineup_type = ""
	self.select_xiannv_id = -1
	self.show_anim_camp = SHOW_ANIM_CAMP.CAMP_1
end

function GoddessCampView:__delete()
	if self.goddess_select_view then
		self.goddess_select_view:DeleteMe()
		self.goddess_select_view = nil
	end

	for _, v in ipairs(self.lineup_list) do
		local cell = v.cell
		cell:DeleteMe()
	end
	self.lineup_list = {}


	self.goddess_display1 = nil
	self.goddess_display2 = nil
	self.goddess_display3 = nil
	self.goddess_display4 = nil
	
	if self.model_view1  then
		self.model_view1:DeleteMe()
		self.model_view1 = nil
	end
	if self.model_view2  then
		self.model_view2:DeleteMe()
		self.model_view2 = nil
	end
	if self.model_view3  then
		self.model_view3:DeleteMe()
		self.model_view3 = nil
	end
	if self.model_view4 then
		self.model_view4:DeleteMe()
		self.model_view4 = nil
	end
end

function GoddessCampView:InitView()
	self:ListenEvent("question_btn",BindTool.Bind(self.QuestionBtnOnClick, self))
	self.power_value = self:FindVariable("power_value")
	self.lineup_state_text = self:FindVariable("lineup_state_text")
	self.block = self:FindObj("block")
	self.desc_list = {}
	for i=1,3 do
		self.desc_list[i] = self:FindVariable("desc_" .. i)
	end
	self.question_text = self:FindVariable("question_text")
	self.icon_content = self:FindObj("icon_content")
	self.goddess_select_view = GoddessSelectView.New(self.icon_content)
	self.goddess_select_view.parent = self
	self.lineup_list = {}
	for i = 1, 4 do
		self.lineup_list[i] = {}
		self.lineup_list[i].cell = LineupCell.New(self:FindObj("lineup_" .. i))
		self.lineup_list[i].lineup_value = self:FindVariable("lineup_value" .. i)
		-- self.lineup_list[i].lineup_name_value = self:FindVariable("lineup_name"..i)
		self.lineup_list[i].cell:SetLineupType(Lineup_type[i])
		self.lineup_list[i].show_shadow = self:FindVariable("show_shadow_"..i)
	end
	self.grade_text_1 = self:FindVariable("grade_text_1")
	self.grade_text_2 = self:FindVariable("grade_text_2")
	self.grade_text_3 = self:FindVariable("grade_text_3")
	self.is_open = false
	local grade_list = GoddessData.Instance:GetShowHaloGradeList()
	if next(grade_list) then
		local text_1 = ""
		local text_2 = ""
		local text_3 = ""
		if #grade_list ~= 0 then
			text_1 = grade_list[1] - DIFFERENT_GRADE .. Language.Common.Jie
			text_2 = grade_list[2] - DIFFERENT_GRADE .. Language.Common.Jie
			text_3 = grade_list[3] - DIFFERENT_GRADE .. Language.Common.Jie
		end

		local grade = ShengongData.Instance:GetShengongInfo().grade
		if grade < grade_list[1] then
			text_1 = ToColorStr(text_1, TEXT_COLOR.WHITE)
		else
			text_1 = ToColorStr(text_1, TEXT_COLOR.WHITE)
		end

		if grade < grade_list[2] then
			text_2 = ToColorStr(text_2, TEXT_COLOR.WHITE)
		else
			text_2 = ToColorStr(text_2, TEXT_COLOR.WHITE)
		end

		if grade < grade_list[3] then
			text_3 = ToColorStr(text_3, TEXT_COLOR.WHITE)
		else
			text_3 = ToColorStr(text_3, TEXT_COLOR.WHITE)
		end
		self.grade_text_1:SetValue(text_1)
		self.grade_text_2:SetValue(text_2)
		self.grade_text_3:SetValue(text_3)
	end

	--仙女模型显示
	self.goddess_display1 = self:FindObj("goddess_display1")
	self.goddess_display2 = self:FindObj("goddess_display2")
	self.goddess_display3 = self:FindObj("goddess_display3")
	self.goddess_display4 = self:FindObj("goddess_display4")


	--引导用按钮
	self.line_up_fight = self:FindObj("lineup_1")
	self.godess_icon1 = self.icon_content.godess_icon1
end

function GoddessCampView:GetSelectIconView()
	return self.goddess_select_view
end

function GoddessCampView:FlushShowShadow()
	local pos_list = GoddessData.Instance:GetXianNvPos()
	for i=1,4 do
		self.lineup_list[i].show_shadow:SetValue(pos_list[i] == -1)
	end
end

function GoddessCampView:ReflushLineupView(to_flush)
	local goddess_data = GoddessData.Instance
	local pos_list = goddess_data:GetXianNvPos()
	local xn_item_list = goddess_data:GetXianNvlist()
	for k,v in pairs(pos_list) do
		self:SetXianNvDispaly(k,v)
		if v == -1 then
			if self.lineup_list[k] then
				-- self.lineup_list[k].lineup_name_value:SetValue("")
				self.lineup_list[k].lineup_value:SetValue(0)
				self.lineup_list[k].cell:SetModel(-1)
			end
		else
			local xiannv_cfg = goddess_data:GetXianNvLevelCfg(v,GameVoManager.Instance:GetMainRoleVo().level)
			local zhizhi_cfg = goddess_data:GetXianNvZhiziCfg(v,xn_item_list[v].xn_zizhi)
			local xiannv_gongji = xiannv_cfg.xiannv_gongji + zhizhi_cfg.xiannv_gongji
			if self.lineup_list[k] then
				-- self.lineup_list[k].lineup_name_value:SetValue(goddess_data:GetXianNvCfg(v).name)
				self.lineup_list[k].cell:SetModel(v)
				self.lineup_list[k].lineup_value:SetValue(goddess_data:GetSingleCampPower(k))
			end
		end
		if self.lineup_list[k] then
			self.lineup_list[k].cell:CheckRedPoint()
		end
	end
	self.power_value:SetValue(goddess_data:GetPower())
	self:SetCancelContentActive()
	if not to_flush then
		if self.is_chuzhan then
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessChuZhanOk)
			self.is_chuzhan = false
		end
	end
end

function GoddessCampView:SetXianNvDispaly(linqIndex,xiannv_id)
	if self.model_view1 == nil then
		self.model_view1 = RoleModel.New("goddess_camp_panel")
		self.model_view1:SetDisplay(self.goddess_display1.ui3d_display)
	end
	if self.model_view2 == nil then
		self.model_view2 = RoleModel.New("goddess_camp_panel")
		self.model_view2:SetDisplay(self.goddess_display2.ui3d_display)
	end
	if self.model_view3 == nil then
		self.model_view3 = RoleModel.New("goddess_camp_panel_small")
		self.model_view3:SetDisplay(self.goddess_display3.ui3d_display)
	end
	if self.model_view4 == nil then
		self.model_view4 = RoleModel.New("goddess_camp_panel")
		self.model_view4:SetDisplay(self.goddess_display4.ui3d_display)
	end

	if linqIndex == 1 then
		if xiannv_id == -1 then
			self.goddess_display1:SetActive(false)
		else
			self.goddess_display1:SetActive(true)
		end
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
		if not xiannv_cfg then return end
		local resid = xiannv_cfg.resid
		self.model_view1:SetMainAsset(ResPath.GetGoddessModel(resid))
		--位置大小不读配置直接在prefab上定死
		--self.model_view1:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.FULL_PANEL)
	end 
	if linqIndex == 2 then
		if xiannv_id == -1 then
			self.goddess_display2:SetActive(false)
			return
		else
			self.goddess_display2:SetActive(true)
		end
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
		if not xiannv_cfg then return end
		local resid = xiannv_cfg.resid
		self.model_view2:SetMainAsset(ResPath.GetGoddessModel(resid))
		--self.model_view2:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.FULL_PANEL)
	end
	if linqIndex == 3 then
		if xiannv_id == -1 then
			self.goddess_display3:SetActive(false)
			return
		else
			self.goddess_display3:SetActive(true)
		end
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
		if not xiannv_cfg then return end
		local resid = xiannv_cfg.resid
		self.model_view3:SetMainAsset(ResPath.GetGoddessModel(resid))
		--self.model_view3:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.FULL_PANEL)
	end
	if linqIndex == 4 then
		if xiannv_id == -1 then
			self.goddess_display4:SetActive(false)
			return
		else
			self.goddess_display4:SetActive(true)
		end
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
		if not xiannv_cfg then return end
		local resid = xiannv_cfg.resid
		self.model_view4:SetMainAsset(ResPath.GetGoddessModel(resid))
		--self.model_view4:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.FULL_PANEL)
	end

end





function GoddessCampView:GetIsOpen()
	return self.is_open
end

function GoddessCampView:SetShowAnimCamp(show_anim_camp)
	self.show_anim_camp = show_anim_camp
end

function GoddessCampView:GetShowAnimCamp()
	return self.show_anim_camp
end

function GoddessCampView:SetIsOpen(is_open)
	self.is_open = is_open
end

function GoddessCampView:SetBlockActive(is_active)
	self.block:SetActive(is_active)
end

function GoddessCampView:XiannvChuZhan(is_replace)
	local goddess_data = GoddessData.Instance
	local pos_list = {}
	for k,v in pairs(goddess_data:GetXianNvPos()) do
		pos_list[k] = v
	end
	local linup_index = -1
	local already_chuzhan = false
	for k,v in pairs(Lineup_type) do
		if v == self.select_lineup_type then
			linup_index = k
		end
	end

	if pos_list[linup_index] == self.select_xiannv_id then
		return
	end

	for k,v in pairs(Lineup_type) do
		if pos_list[k] == self.select_xiannv_id and v ~= self.select_lineup_type then
			pos_list[k] = -1
			pos_list[linup_index] = self.select_xiannv_id
			already_chuzhan = true
			break
		end
	end

	if already_chuzhan == false then
		pos_list[linup_index] = self.select_xiannv_id
	end

	if is_replace then
		local to_index = goddess_data:GetXiannvLinupType(self.select_lineup_type)
		local form_index = goddess_data:GetPoslistIndex(self.select_xiannv_id)
		if form_index ~= -1 then
			pos_list[to_index] = goddess_data:GetXianNvPos()[form_index]
			pos_list[form_index] = goddess_data:GetXianNvPos()[to_index]
		end
	end
	GoddessCtrl.Instance:SendCSXiannvCall(pos_list)
end

function GoddessCampView:AllCellListOnFlush()
	self.goddess_select_view:AllCellListOnFlush()
end

function GoddessCampView:SetLineupTypeStateText()
	local state_text = ""
	for k,v in pairs(Lineup_type) do
		if v == self.select_lineup_type then
			if k == 1 then
				state_text = "出战阵位"
			elseif k == 2 then
				state_text = "助战位一"
			elseif k == 3 then
				state_text = "助战位二"
			elseif k == 4 then
				state_text = "助战位三"
			end
		end
	end
	self.lineup_state_text:SetValue(state_text)
end

function GoddessCampView:QuestionBtnOnClick()
	local tips_id = 30 -- 女神帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GoddessCampView:SetSelectLineupType(lineup_type)
	self.select_lineup_type = lineup_type
end

function GoddessCampView:GetSelectLineupType()
	return self.select_lineup_type
end

function GoddessCampView:SetSelectXiannvId(xian_nv_id)
	self.select_xiannv_id = xian_nv_id
end

function GoddessCampView:UnwieldLineup()
	local pos_list = GoddessData.Instance:GetXianNvPos()
	for k,v in pairs(Lineup_type) do
		if v == self.select_lineup_type then
			if k ~= 1 then
				pos_list[k] = -1
				self.lineup_list[k].cell:CancelTheQuest()
				break
			end
		end
	end
	GoddessCtrl.Instance:SendCSXiannvCall(pos_list)
end

function GoddessCampView:SetIsChuZhan(is_chuzhan)
	self.is_chuzhan = is_chuzhan
end

function GoddessCampView:SetCancelContentActive()
	local pos_list = GoddessData.Instance:GetXianNvPos()
	for k,v in pairs(Lineup_type) do
		if v == self.select_lineup_type then
			if k == 1 then
				self.goddess_select_view:SetCancelContentActive(false)
			else
				if pos_list[k] == -1 then
					self.goddess_select_view:SetCancelContentActive(false)
				else
					self.goddess_select_view:SetCancelContentActive(true)
				end
			end
		end
	end
	self.goddess_select_view:SetCancelToggleFalse()
end

function GoddessCampView:CancelAllQuest()
	for i = 1, 4 do
		self.lineup_list[i].cell:CancelTheQuest()
	end
end
--------------------------------------------------------------------------
--GoddessSelectView 	女神选择面板
--------------------------------------------------------------------------
GoddessSelectView = GoddessSelectView or BaseClass(BaseRender)

function GoddessSelectView:__init(instance)
	self.cell_list = {}
	for i = GameEnum.MIN_XIANNV_ID,GameEnum.MAX_XIANNV_ID do
		self.cell_list[i] = {}
		self.cell_list[i].cell = SelectIconCell.New(self:FindObj("icon_cell" .. i))
		self.cell_list[i].cell:InitIcon(i,GoddessData.Instance:GetXianNvCfg(i).name)
		self.cell_list[i].cell:OnFlush()
	end
	self.icon_content = self:FindObj("icon_content")
	self.cancel_content = self:FindObj("cancel_content")
	self.cancel_content:SetActive(false)
	self.cancel_toggle = self:FindObj("cancel_toggle")
	self.cancel_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.CancelTogleOnClick, self))
	self.close_toggle = self:FindObj("close_toggle")
	self:ListenEvent("close_click",BindTool.Bind(self.CloseTogleOnClick, self))
	self.block = self:FindObj("block")
	self.ani = self.block.animator
	self.ani:ListenEvent("exit", BindTool.Bind(self.AniFinish, self))

	--引导用按钮
	self.godess_icon1 = self:FindObj("icon_cell0")
end

function GoddessSelectView:__delete()
	for _, v in ipairs(self.cell_list) do
		local cell = v.cell
		cell:DeleteMe()
	end
	self.cell_list = {}
end

function GoddessSelectView:CloseTogleOnClick()
	self.ani:SetBool("show", false)
end

function GoddessSelectView:AllCellListOnFlush()
	for i=GameEnum.MIN_XIANNV_ID , GameEnum.MAX_XIANNV_ID do
		self.cell_list[i].cell:OnFlush()
	end
end

function GoddessSelectView:SetCancelToggleFalse()
	self.cancel_toggle.toggle.isOn = false
end

function GoddessSelectView:CancelTogleOnClick(is_click)
	if is_click then
		self.parent:UnwieldLineup()
		self.parent:SetIsChuZhan(false)
	end
end

function GoddessSelectView:SetViewOpenOrNot(is_on)
	self.icon_content:SetActive(is_on)
end

function GoddessSelectView:SetCancelContentActive(is_active)
	self.cancel_content:SetActive(is_active)
end

function GoddessSelectView:AniFinish()
	self.icon_content:SetActive(false)
	self.parent:SetBlockActive(false)
end

--------------------------------------------------------------------------
--SelectIconCell	女神选择图标
--------------------------------------------------------------------------
SelectIconCell = SelectIconCell or BaseClass(BaseCell)

function SelectIconCell:__init()
	self.icon = self:FindObj("icon")
	self.icon_img = self:FindVariable("icon")
	self.show_icon_white = self:FindVariable("show_icon_white")
	self.icon_state_bg = self:FindObj("icon_state_bg")   --出战标签
	self.icon_state_bg2 = self:FindObj("icon_state_bg2") --助战标签
	self.name = self:FindVariable("name")
	self.state_text = self:FindVariable("state_text")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnIconBtnClick,self))
	self.is_active = false
	self.xian_nv_id = 0
end

function SelectIconCell:GetXiannvId()
	return self.xian_nv_id
end

function SelectIconCell:InitIcon(xian_nv_id,name)
	self.xian_nv_id = xian_nv_id
	self.name:SetValue(name)
end

function SelectIconCell:OnFlush()
	local level = GoddessData.Instance:GetXianNvItem(self.xian_nv_id).xn_zizhi
	local pos_list = GoddessData.Instance:GetXianNvPos()
	local is_chuzhan = false
	for k,v in pairs(pos_list) do
		if v == self.xian_nv_id then
			if k == 1 then
				self.icon_state_bg:SetActive(true)
				self.icon_state_bg2:SetActive(false)
				self.state_text:SetValue(Language.Goddess.ChuZhanZhong)
			else
				self.icon_state_bg:SetActive(false)
				self.icon_state_bg2:SetActive(true)
				self.state_text:SetValue(Language.Goddess.ZhuZhanZhong)
			end
			is_chuzhan = true
		end
	end
	if level == 0 then
		self.icon.grayscale.GrayScale = 255  --置灰
		self.show_icon_white:SetValue(true)
		-- self.root_node.toggle.interactable = false
	else
		-- self.root_node.toggle.interactable = true
		self.icon.grayscale.GrayScale = 0
		self.show_icon_white:SetValue(false)
	end

	if is_chuzhan == false then
		self.icon_state_bg:SetActive(false)
		self.icon_state_bg2:SetActive(false)
		self.state_text:SetValue(" ")
	end
	local res_id = GoddessData.Instance:GetXianNvCfg(self.xian_nv_id).resid
	local bundle, asset = ResPath.GetGoddessIcon(res_id)
	self.icon_img:SetAsset(bundle, asset)
end

function SelectIconCell:OnIconBtnClick(is_click)
	if is_click then
		local goddess_data = GoddessData.Instance
		local level = goddess_data:GetXianNvItem(self.xian_nv_id).xn_zizhi
		if level == 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.GoddessNoActiveTip)
		else
			local goddess_camp_view = GoddessCtrl.Instance:GetGoddessCampView()
			if goddess_camp_view then
				local pos_list = goddess_data:GetXianNvPos()
				local Shengong_grade = ShengongData.Instance:GetShengongInfo().grade
				local lineup_type = goddess_camp_view:GetSelectLineupType()
				local can_go_camp = goddess_data:GetCanGoCampState(Shengong_grade,goddess_data:GetCampIndex(lineup_type))
				local lineup_index = goddess_data:GetXiannvLinupType(lineup_type)
				if can_go_camp then
					if self.xian_nv_id == pos_list[1] and pos_list[lineup_index] == -1 then
						TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.WuFaTiHuan)
						return
					end
					goddess_camp_view:SetSelectXiannvId(self.xian_nv_id)
					local lineup_xiannv_id = pos_list[goddess_data:GetXiannvLinupType(lineup_type)]
					index = goddess_data:GetPoslistIndex(self.select_xiannv_id)
					if pos_list[lineup_index] == -1 or lineup_xiannv_id == -1 then
						goddess_camp_view:XiannvChuZhan()
						goddess_camp_view:SetIsChuZhan(true)
					else
						goddess_camp_view:XiannvChuZhan(true)
						goddess_camp_view:SetIsChuZhan(true)
					end
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.WeiKaiQi)
				end
			end
		end
	end
end
--------------------------------------------------------------------------
--LineupCell	女神阵位
--------------------------------------------------------------------------
LineupCell = LineupCell or BaseClass(BaseCell)

function LineupCell:__init()
	self:ListenEvent("click",BindTool.Bind(self.OnLineupClick, self))
	--self.model = self:FindObj("model")
	self.state_text = self:FindVariable("state_text")
	-- self.model_view = RoleModel.New()
	-- self.model_view:SetDisplay(self.model.ui3d_display)
	self.lineup_type = ""
	self.show_red_point = self:FindVariable("show_red_point")
end

function LineupCell:__delete()
	-- self.model_view = nil
	self:CancelTheQuest()
	self:CancelTheQuestTwo()
end

function LineupCell:OnLineupClick()
	local goddess_data = GoddessData.Instance
	local goddess_camp_view = GoddessCtrl.Instance:GetGoddessCampView()
	if goddess_camp_view then
		local Shengong_grade = ShengongData.Instance:GetShengongInfo().grade
		goddess_camp_view:SetSelectLineupType(self.lineup_type)
		local can_go_camp = goddess_data:GetCanGoCampState(Shengong_grade, goddess_data:GetCampIndex(self.lineup_type))
		if can_go_camp then
			local select_view = goddess_camp_view:GetSelectIconView()
			if select_view then
				select_view:SetViewOpenOrNot(true)
			end
			goddess_camp_view:SetBlockActive(true)
			goddess_camp_view:SetCancelContentActive()
			goddess_camp_view:SetLineupTypeStateText()
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.WeiKaiQi)
		end
	end
end

function LineupCell:SetLineupType(lineup_type)
	self.lineup_type = lineup_type
	self:CheckRedPoint()
end

function LineupCell:CheckRedPoint()
	local goddess_data = GoddessData.Instance
	local lineup_index = goddess_data:GetXiannvLinupType(self.lineup_type)
	local pos_list = goddess_data:GetXianNvPos()
	if pos_list[lineup_index] == -1 and lineup_index ~= 1 then
		if pos_list[1] == -1 then
			self.show_red_point:SetValue(false)
		else
			self.show_red_point:SetValue(goddess_data:GetCampRedPoint(lineup_index))
		end
	else
		self.show_red_point:SetValue(false)
	end
end

function LineupCell:SetModel(xian_nv_id)
	local goddess_data = GoddessData.Instance
	if xian_nv_id == -1 then
		UIScene:DeleteModel(GoddessData.Instance:GetXiannvLinupType(self.lineup_type))
		return
	end
	local lineup_index = goddess_data:GetXiannvLinupType(self.lineup_type)
	local call_back = function(model, obj)
		if obj then
			obj.transform.localPosition = Vector3(0,0,0)
			obj.transform.localScale = GoddessData.Instance:GetCampScale(lineup_index)
		end
	end
	UIScene:SetModelLoadCallBack(call_back, lineup_index)
	local shengong_res = ShengongData.Instance:GetGoddessShengongRes()
	local bundle1, asset1 = ResPath.GetGoddessModel(goddess_data:GetXianNvCfg(xian_nv_id).resid)
	local bundle_list = {}
	local asset_list = {}
	if shengong_res == -1 then
		bundle_list = {[SceneObjPart.Main] = bundle1}
		asset_list = {[SceneObjPart.Main] = asset1}
	else
		local bundle2, asset2 = ResPath.GetGoddessWeaponModel(shengong_res)
		bundle_list = {[SceneObjPart.Main] = bundle1, [SceneObjPart.Weapon] = bundle2}
		asset_list = {[SceneObjPart.Main] = asset1, [SceneObjPart.Weapon] = asset2}
	end
	UIScene:ModelBundle(bundle_list, asset_list, goddess_data:GetXiannvLinupType(self.lineup_type))
	-- self:CalToShowAnim(true)
end

function LineupCell:CalToShowAnim(is_change_tab)
	self:CancelTheQuest()
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			self:PlayAnim(is_change_tab)
			is_change_tab = false
			timer = GameEnum.GODDESS_ANIM_LONG_TIME
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end
	end, 0)
end

function LineupCell:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	self:CancelTheQuestTwo()
	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	local count = 1
	local lineup_index = GoddessData.Instance:GetXiannvLinupType(self.lineup_type)
	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if UIScene.role_model then
				local part = nil
				for k,v in pairs(UIScene.model_list) do
					if v.pint_tai == "Pingtai0".. (lineup_index + 1) then
						part = v.model
					end
				end
				if part then
					part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
					count = count + 1
				end
				timer = GameEnum.GODDESS_ANIM_SHORT_TIME
				is_change_tab = false
				if count == 4 then
					count = 1
					GlobalTimerQuest:CancelQuest(self.time_quest_2)
					self.time_quest_2 = nil
					self:CalToShowAnim()
				end
			end
		end
	end, 0)
end


function LineupCell:GetLineUpType()
	return self.lineup_type
end

function LineupCell:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function LineupCell:CancelTheQuestTwo()
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end