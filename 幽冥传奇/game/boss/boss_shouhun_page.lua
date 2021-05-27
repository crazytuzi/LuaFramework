BossShouhunPage = BossShouhunPage or BaseClass()

ShouHun_Pos = {{376,524},{539,428},{539,255},{378,161},{212,257},{213, 422}}
Effect_Pos = {{380, 345},{380, 325},{312, 352},{312, 352}, {425, 375}, {410, 421}}
function BossShouhunPage:__init()
	self.is_first_login = true
end	

function BossShouhunPage:__delete()
	if self.shouhun_cell ~= nil then
		for i, v in ipairs(self.shouhun_cell) do
			v:DeleteMe()
		end
		self.shouhun_cell = nil
	end
	if self.play_effect then
		self.play_effect:setStop()
		self.play_effect = nil 
	end

	if self.play_btn_effect then
		self.play_btn_effect:setStop()
		self.play_btn_effect = nil
	end

	if self.effect_data ~= nil then
		for k, v in pairs(self.effect_data) do
			v:setStop()
		end
		self.effect_data = {}
	end
	if self.boss_shouhun_change then
		GlobalEventSystem:UnBind(self.boss_shouhun_change)
		self.boss_shouhun_change = nil
	end	
	if self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil 
	end

	if self.delay_play_time then
		GlobalTimerQuest:CancelQuest(self.delay_play_time)
		self.delay_play_time = nil 
	end

	if self.delay_play_time_1 then
		GlobalTimerQuest:CancelQuest(self.delay_play_time_1)
		self.delay_play_time_1 = nil 
	end
	self.effec = nil 
	self:RemoveEvent()
	
end	

--初始化页面接口
function BossShouhunPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateCells()
	self.boss_shouhun_change = GlobalEventSystem:Bind(BossShouhunType.SHOUHUN_BACK, BindTool.Bind(self.OnShouhunLevelChangeBack, self))	
	self.effect_data = {}
	self:SetShowPlayEff()
	self:SetAllShowPlayEffect()
	self:SetBtnEffct()
	self.bool_flush = false
	self:InitEvent()
end	

function BossShouhunPage:InitEvent()
	self.view.node_t_list.page5["btn_tips"].node:addClickEventListener(BindTool.Bind(self.OpenDescTip, self))
	self.view.node_t_list.page5["btn_chouqu"].node:addClickEventListener(BindTool.Bind(self.ExtractShouhun, self))
	self.view.node_t_list.page5.layout_autocompose_hook["btn_nohint_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickBossShouAuto, self))
	self.view.node_t_list.page5.layout_autocompose_hook["img_hook"].node:setVisible(BossData.Instance:GetKeyData() == 1)
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback, self)			--监听人物属性数据变化
	self.view.node_t_list.img_bg.node:setVisible(false)

	-- self.effec = RenderUnit.CreateEffect(10, self.view.node_t_list.layout_gongming.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	-- self.effec:setScaleX(1.3)
	-- self.effec:setScaleY(0.8)
	-- self.effec:setPositionX(155)

	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_gongming.node, BindTool.Bind(self.OpenUnionView, self), true)
end

function BossShouhunPage:RemoveEvent()
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
end

function BossShouhunPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			for k,v in pairs(BossData.Instance:GetNewShouHunData()) do
				self.shouhun_cell[k]:SetData(v)
			end
			self:FlushData()
			-- self:CanShowBoolActivity()
		elseif k == "recycle_view" then
	
			self:FlushData()
			-- self:CanShowBoolActivity()
		end
	end

end


function BossShouhunPage:FlushData()
	self:FlushRightView()
	local remain_time, total_time = BossData.Instance:GetLimitTime()
	if total_time ~= nil and remain_time ~= nil then
		local num = total_time - remain_time
		self.view.node_t_list["txt_times"].node:setString(num.."/"..total_time)
	end
	local num = total_time - remain_time + 1
	local count = nil 
	if num > total_time then
		count = Language.Boss.Max_Value
	else
		count = BossData.Instance:GetConsumeCount(num)
	end
	self.view.node_t_list.txt_consume_jifen.node:setString(count)
	local attr_cfg = BossData.Instance:GetTotalAttr()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr = CommonDataManager.DelAttrByProf(prof, attr_cfg)

	local content = RoleData.FormatAttrContent(attr, rich_param)
	local txt = ""
	if content == "" then
		txt = Language.Boss.WeiJiHuo
	else
		txt = content
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_total_value.node, txt, 22, COLOR3B.OLIVE)
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_total_value.node, 5)
	self:PlayEffect()
end

function BossShouhunPage:OnShouhunLevelChangeBack(data)
	local index = nil 
	for k, v in pairs(data) do
		index = k
	end
	 if self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil 
	end

	if self.delay_play_time then
		GlobalTimerQuest:CancelQuest(self.delay_play_time)
		self.delay_play_time = nil 
	end
	self.view.node_t_list.img_bg.node:setVisible(false)
	if BossData.Instance:GetKeyData() == 0 then
		self.play_effect:setPosition(375, 345)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(27)
		self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect*0.9, false)
		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
				self.play_effect:setPosition(380, 350)
				local anim_path, anim_name = ResPath.GetEffectUiAnimPath(28)
				self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
		end, 0.5)
		self.delay_play_time = GlobalTimerQuest:AddDelayTimer(function ()
				if index ~= nil then
					self.view.node_t_list.img_bg.node:setVisible(true)
					self.view.node_t_list.img_bg.node:loadTexture(ResPath.GetBoss("boss_"..index.."_3"))
					for i, v in ipairs(self.effect_data) do
						v:setPosition(Effect_Pos[i][1], Effect_Pos[i][2])
						v:setVisible(true)
						local anim_path, anim_name = ResPath.GetEffectUiAnimPath(33)
						v:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
						local move_by = cc.MoveTo:create(1, cc.p(ShouHun_Pos[index][1], ShouHun_Pos[index][2]))
						local scale_to = cc.ScaleTo:create(2.0, 0.5)
						local spawn = cc.Spawn:create(move_by, scale_to)
						local delay_time = cc.DelayTime:create(0.3)
						local callback =  cc.CallFunc:create(function()
							v:setVisible(false)	
						end)
						local action = cc.Sequence:create(spawn, delay_time, callback)
						v:runAction(action)
					end
				end
		end, 0.5)
		self.delay_play_time_1 = GlobalTimerQuest:AddDelayTimer(function ()
			for k,v in pairs(BossData.Instance:GetNewShouHunData()) do
				self.shouhun_cell[k]:SetData(v)
			end	
			XUI.SetButtonEnabled(self.view.node_t_list.page5["btn_chouqu"].node, true)
			if BossData.Instance:CheckShouHunCanAct() == 1 then
				self.play_btn_effect:setVisible(true)
			else
				self.play_btn_effect:setVisible(false)
			end
		end, 1.5)
	else
		if index ~= nil then
			self.view.node_t_list.img_bg.node:setVisible(true)
			self.view.node_t_list.img_bg.node:loadTexture(ResPath.GetBoss("boss_"..index.."_3"))
			for k,v in pairs(BossData.Instance:GetNewShouHunData()) do
				self.shouhun_cell[k]:SetData(v)
			end	
		end
	end
	
end

function BossShouhunPage:OpenDescTip()
	DescTip.Instance:SetContent(Language.Boss.content, Language.Boss.TiTle)
end

function BossShouhunPage:ExtractShouhun()
	BossCtrl.Instance:SendReqLightenNextSarah()
	if BossData.Instance:GetKeyData() == 0 then 
		local remain_time, total_time = BossData.Instance:GetLimitTime()
		local num = total_time - remain_time + 1
		local count = 0 
		if num > 50 then
			XUI.SetButtonEnabled(self.view.node_t_list.page5["btn_chouqu"].node, true)
			self.play_btn_effect:setVisible(false)
		else
			count = BossData.Instance:GetConsumeCount(num)
			local shouhun_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BOSS_VALUE)
			if shouhun_num > count then
				XUI.SetButtonEnabled(self.view.node_t_list.page5["btn_chouqu"].node, false)
				self.play_btn_effect:setVisible(false)
			else
				XUI.SetButtonEnabled(self.view.node_t_list.page5["btn_chouqu"].node, true)
				self.play_btn_effect:setVisible(false)
			end
		end
	else
		XUI.SetButtonEnabled(self.view.node_t_list.page5["btn_chouqu"].node, true)
		if BossData.Instance:CheckShouHunCanAct() == 1 then
			self.play_btn_effect:setVisible(true)
		end
	end
end

function BossShouhunPage:CreateCells()
	self.shouhun_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list["ph_item_"..i]
		local data =  BossData.Instance:GetNewShouHunData()
		local cur_data = data[i]
		local cell = self:CreateRender(ph, cur_data)
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind1(self.OpenTip, self), false)
		table.insert(self.shouhun_cell, cell)
	end
end

function BossShouhunPage:OpenTip(cell)
	if nil == cell or cell:GetData() == nil then return end
	self.select_data = cell:GetData()
	self.select_index = cell:GetIndex()
	BossCtrl.Instance:OpenTip(self.select_index, self.select_data)
end

function BossShouhunPage:CreateRender(ph, cur_data)
	local cell = BossShouHunRender.New()
	local render_ph = self.view.ph_list.ph_list_item 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setAnchorPoint(0, 0)
	cell:GetView():setPosition(ph.x, ph.y)
	self.view.node_t_list["page5"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function BossShouhunPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_BOSS_VALUE then
		self:FlushRightView()
		self:FlushData()
		self:PlayEffect()
	end
end

function BossShouhunPage:FlushRightView()
	local count = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BOSS_VALUE)
	self.view.node_t_list.txt_jifen.node:setString(count)
end

function BossShouhunPage:PlayEffect()
	local remain_time, total_time = BossData.Instance:GetLimitTime()
	local num = total_time - remain_time + 10
	local consume_count = BossData.Instance:GetConsumeCount(num) or 0
	if remain_time > 0 and consume_count <= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BOSS_VALUE) then
		self.play_btn_effect:setPosition(385, 50)
		self.play_btn_effect:setScale(1)
		self.play_btn_effect:setScaleX(0.6)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(10)
		self.play_btn_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.play_btn_effect:setVisible(true)
	else
		self.play_btn_effect:setVisible(false)
	end
end

function BossShouhunPage:OnClickBossShouAuto()
	local vis = self.view.node_t_list.page5.layout_autocompose_hook["img_hook"].node:isVisible()
	BossData.Instance:SetKeyCompose(vis and 0 or 1)	
	self.view.node_t_list.page5.layout_autocompose_hook["img_hook"].node:setVisible(not vis)
end

function BossShouhunPage:SetShowPlayEff()
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list["page5"].node:addChild(self.play_effect,999)
	end	
end

function BossShouhunPage:SetAllShowPlayEffect()
	self.effect_data = {}
	for i = 1, 6 do
		local play_effect = AnimateSprite:create()
		self.view.node_t_list["page5"].node:addChild(play_effect,999)
		table.insert(self.effect_data, play_effect)
	end
end

function BossShouhunPage:SetBtnEffct()
	if self.play_btn_effect == nil then
		self.play_btn_effect = AnimateSprite:create()
		self.view.node_t_list["page5"].node:addChild(self.play_btn_effect,999)
	end	
end


BossShouHunRender = BossShouHunRender or BaseClass(BaseRender)

function BossShouHunRender:__init()

end

function BossShouHunRender:__delete()
	if self.mask_progress_bar1 then
		self.mask_progress_bar1:DeleteMe()
		self.mask_progress_bar1 = nil 
	end

	if self.mask_progress_bar2 then
		self.mask_progress_bar2:DeleteMe()
		self.mask_progress_bar2 = nil 
	end

	if self.mask_progress_bar3 then
		self.mask_progress_bar3:DeleteMe()
		self.mask_progress_bar3 = nil 
	end

	if self.mask_progress_bar4 then
		self.mask_progress_bar4:DeleteMe()
		self.mask_progress_bar4 = nil 
	end

end

function BossShouHunRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossShouHunRender:OnFlush()
	self.node_tree.img_txt_bg.node:setLocalZOrder(998)
	self.node_tree.txt_desc.node:setLocalZOrder(999)
	if self.index > 0 then
		if self.mask_progress_bar4 == nil then
			self.mask_progress_bar4 = MaskProgressBar.New(self.view,
									XUI.CreateImageView(0,0,ResPath.GetBoss("bg_13"), true),
									XUI.CreateImageViewScale9(0,0,100,100,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
									cc.size(108,108),true)
		end

		if self.mask_progress_bar2 == nil then
			self.mask_progress_bar2 = MaskProgressBar.New(self.view,
									XUI.CreateImageView(0,0,ResPath.GetBoss("boss_"..self.index.."_1"), true),
									XUI.CreateImageViewScale9(0,0,131,125,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
									cc.size(131,125),true)
		end

		if self.mask_progress_bar3 == nil then
			self.mask_progress_bar3 = MaskProgressBar.New(self.view,
									XUI.CreateImageView(0,0,ResPath.GetBoss("bg_14"), true),
									XUI.CreateImageViewScale9(0,0,100,100,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
									cc.size(108,108))
		end	
		self.mask_progress_bar3:getView():setPosition(25,10)
		self.mask_progress_bar4:getView():setPosition(25,10)

		if self.mask_progress_bar1 == nil then
				self.mask_progress_bar1 = MaskProgressBar.New(self.view,
									XUI.CreateImageView(0,0,ResPath.GetBoss("boss_"..self.index.."_2"), true),
									XUI.CreateImageViewScale9(0,0,131,125,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
									cc.size(131,125))
			end
		
		self.mask_progress_bar1:getView():setPosition(13,0)
		self.mask_progress_bar2:getView():setPosition(13,0)
	end
	if self.data == nil then return end
	if self.index > 0 then
		local txt = string.format(Language.Boss.AttributeName[self.index], self.data.shouhun_level)
		self.node_tree.txt_desc.node:setString(txt)
		local need_exp = BossData.Instance:GetUpLvExp(self.data.shouhun_pos, self.data.shouhun_level + 1)
		if need_exp ~= 0 then
			if self.data.shouhun_level <= 0 and self.data.shouhun_exp == 0 then
				self.mask_progress_bar3:setProgressPercent(0,false)
				self.mask_progress_bar4:setProgressPercent(1,false)
				self.mask_progress_bar1:setProgressPercent(0,false)
				self.mask_progress_bar2:setProgressPercent(1,false)
				self.mask_progress_bar1:GetView():setVisible(false)
				self.mask_progress_bar3:GetView():setVisible(false)
			elseif self.data.shouhun_level > 0 and self.data.shouhun_exp == 0 then
				self.mask_progress_bar1:setProgressPercent(0, false)
				self.mask_progress_bar3:setProgressPercent(0, false)
				self.mask_progress_bar2:setProgressPercent(1, false)
				self.mask_progress_bar4:setProgressPercent(1, false)
				self.mask_progress_bar1:GetView():setVisible(false)
				self.mask_progress_bar3:GetView():setVisible(false)
			else
				local temp_percent = self.data.shouhun_exp/need_exp
				if temp_percent < self.mask_progress_bar3:GetTargetPercent() then
					temp_percent = temp_percent + 1
				end	
				self.mask_progress_bar3:setProgressPercent(temp_percent,true)
				temp_percent = self.data.shouhun_exp/need_exp
				if temp_percent <  self.mask_progress_bar1:GetTargetPercent() then
					temp_percent = temp_percent + 1
				end	
				self.mask_progress_bar1:setProgressPercent(temp_percent,true)
				self.mask_progress_bar3:GetView():setVisible(true)
				self.mask_progress_bar1:GetView():setVisible(true)
			end
		else
			self.mask_progress_bar1:setProgressPercent(1,false)
			self.mask_progress_bar2:setProgressPercent(0,false)
			self.mask_progress_bar3:setProgressPercent(1,false)
			self.mask_progress_bar4:setProgressPercent(0,false)
		end
	end
end


