-- 世界寻宝
ExploreWorldPage = ExploreWorldPage or BaseClass()


function ExploreWorldPage:__init()
end	

function ExploreWorldPage:__delete()
	self:RemoveEvent()
	if self.xunbao_item_handler then
		GlobalEventSystem:UnBind(self.xunbao_item_handler)
		self.xunbao_item_handler = nil
	end
	if self.effec then
		self.effec = nil
	end

	if nil ~= self.treasure_cell_list then
		for k,v in pairs(self.treasure_cell_list) do
			v:DeleteMe()
		end
		self.treasure_cell_list = {}
	end

	if nil ~= self.award_cell_list then
		for k,v in pairs(self.award_cell_list) do
			v:DeleteMe()
		end
		self.award_cell_list = {}
	end

	self.after_effect_call_back = nil
	if self.play_effect ~= nil then
		self.play_effect:removeFromParent()
		self.play_effect = nil 
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
	if self.time_event then
		GlobalEventSystem:UnBind(self.time_event)
		self.time_event = nil
	end

	ClientCommonButtonDic[CommonButtonType.XUNBAO_XUNBAO1_BTN] = nil
end	

--初始化页面接口
function ExploreWorldPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.continue_xunbao_type = 1
	self.jiesuan_timer = nil
	self.show_data_t = {}
	self.last_click_time = 0
	Runner.Instance:AddRunObj(self)
	self:InitEvent()
	self.view.node_t_list.layout_jisuan.node:setVisible(false)

	ClientCommonButtonDic[CommonButtonType.XUNBAO_XUNBAO1_BTN] = self.view.node_t_list.btn_tanbao_1.node
end	


--初始化事件
function ExploreWorldPage:InitEvent()
	self.show_data_t = {}
	self.item_list = {}
	for _,v in pairs(ExploreData.Instance:GetShowItemList()) do
		local item = {item_id = v.id,num = v.count,is_bind = v.bind}
		table.insert(self.show_data_t,item)
	end

	XUI.AddClickEventListener(self.view.node_t_list.btn_tanbao_1.node, BindTool.Bind2(self.OnClickXunBaoHandler, self, 1))
	XUI.AddClickEventListener(self.view.node_t_list.btn_xunbao_10.node, BindTool.Bind2(self.OnClickXunBaoHandler, self, 2))
	XUI.AddClickEventListener(self.view.node_t_list.btn_xunbao_50.node, BindTool.Bind2(self.OnClickXunBaoHandler, self, 3))
	XUI.AddClickEventListener(self.view.node_t_list.img_sign.node, BindTool.Bind2(self.OpenIconTips, self))
	XUI.AddClickEventListener(self.view.node_t_list.layout_jisuan.node, BindTool.Bind2(self.OnClickJiesuanBack, self))
	XUI.AddClickEventListener(self.view.node_t_list.jiesuan_yes_btn.node, BindTool.Bind2(self.OnClickJiesuanBack, self))
	XUI.AddClickEventListener(self.view.node_t_list.jiesuan_xunbao_btn.node, BindTool.Bind2(self.OnClickContinue, self))

	self:CreateTreasureCell()

	CommonAction.ShowJumpAction(self.view.node_t_list.img_sign.node, 18)
	if not self.effec then
		self.effec = RenderUnit.CreateEffect(41, self.view.node_t_list.img_sign.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec:setLocalZOrder(-1)
	end

	self.check_box = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box:setVisible(false)
	self.view.node_t_list.checkBoxConsume.node:addChild(self.check_box, 19)
	XUI.AddClickEventListener(self.view.node_t_list.checkBoxConsume.node, BindTool.Bind(self.OnCheckBox, self))
	self.view.node_t_list.checkBoxConsume.node:setVisible(false)
	--self.after_effect_call_back = BindTool.Bind(self.OnSetJiesuanVisible,self)
	
	self.xunbao_item_handler = GlobalEventSystem:Bind(ExploreEventType.XUNBAO_AWARD_BACK,BindTool.Bind(self.OnAwardItemCallBack,self))

	self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.FlushData, self))
end

function ExploreWorldPage:OnCheckBox()
	self.check_box:setVisible(not self.check_box:isVisible())
end

--移除事件
function ExploreWorldPage:RemoveEvent()
	if self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil 
	end	

	if self.jiesuan_timer then
		GlobalTimerQuest:CancelQuest(self.jiesuan_timer)
		self.jiesuan_timer = nil
	end	

end

function ExploreWorldPage:Update(now_time, elapse_time)

end	

function ExploreWorldPage:FlushData()
	for k,v in pairs(self.show_data_t) do
		if self.treasure_cell_list[k] ~= nil then
			self.treasure_cell_list:SetData(v)
		end
	end
end

--更新视图界面
function ExploreWorldPage:UpdateData(data)
	local id = DmkjConf.DmParam[1][1].item.id 
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then
		return 
	end	
	self.last_click_time = 0
	
	self.view.node_t_list.txt_need_gold_1_ci.node:setString(DmkjConf.DmParam[1][1].yb..Language.Common.Gold.."("..item_cfg.name.."X".."1"..")")
	self.view.node_t_list.txt_need_gold_10_ci.node:setString(DmkjConf.DmParam[1][2].yb..Language.Common.Gold.."("..item_cfg.name.."X".."5"..")")
	self.view.node_t_list.txt_need_gold_50_ci.node:setString(DmkjConf.DmParam[1][3].yb..Language.Common.Gold.."("..item_cfg.name.."X".."10"..")")
end	

function ExploreWorldPage:CreateTreasureCell()
	self.treasure_cell_list = {}
	for i = 1, 12 do
		local ph = self.view.ph_list["ph_item_cell"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBg(ResPath.GetCommon("cell_100"))
		self.view.node_t_list.layout_wor_showitem.node:addChild(cell:GetView(), 103)
		cell:AddClickEventListener(BindTool.Bind(self.SelectBaoWuCallBack, self, cell))
		cell:SetData(self.show_data_t[i])
		table.insert(self.treasure_cell_list, cell)
		local act_eff = RenderUnit.CreateEffect(920, self.view.node_t_list.layout_wor_showitem.node, 200, nil, nil,  ph.x + 2, ph.y + 2)
	end

	self.award_cell_list = {}
	for i = 1, 10 do
		local ph = self.view.ph_list["ph_award_cell"..i]
		local cell = ExploreCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBg(ResPath.GetCommon("cell_100"))
		self.view.node_t_list.layout_jisuan.node:addChild(cell:GetView(), 103)
		table.insert(self.award_cell_list, cell)
	end	
end

function ExploreWorldPage:SelectBaoWuCallBack()
end

function ExploreWorldPage:OpenIconTips()
	local data = {item_id = 4235, num = 1, is_bind = 0}
	TipsCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE, {not_compare = true})
end

function ExploreWorldPage:OnAwardItemCallBack(item_list)
	self.view.node_t_list.layout_jisuan.node:setVisible(false)
	for i = 1, #item_list do
		self.award_cell_list[i]:SetData(item_list[i])
		self.award_cell_list[i]:GetView():setVisible(false)
	end
	for i = #item_list + 1,10 do
		self.award_cell_list[i]:SetData(nil)
	end	

	self.item_list = item_list	
	--self:PlayExploreSuccEffect(effec_id, x, y)

	if self.jiesuan_timer then
		GlobalTimerQuest:CancelQuest(self.jiesuan_timer)
		self.jiesuan_timer = nil
	end
	self.jiesuan_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnSetJiesuanVisible,self), 0.2)

	local len = #item_list
	if len == 1 then
		self.continue_xunbao_type = 1
		self.view.node_t_list.jiesuan_xunbao_btn.node:setTitleText(string.format(Language.Explore.ExploreTickFormat,1))
	elseif len == 5 then
		self.continue_xunbao_type = 2
		self.view.node_t_list.jiesuan_xunbao_btn.node:setTitleText(string.format(Language.Explore.ExploreTickFormat,5))
	else
		self.continue_xunbao_type = 3
		self.view.node_t_list.jiesuan_xunbao_btn.node:setTitleText(string.format(Language.Explore.ExploreTickFormat,10))
	end	
end	

-- function ExploreWorldPage:PlayExploreSuccEffect(effec_id, x, y)
-- 	if self.play_effect then
-- 		self.play_effect:removeFromParent()
-- 		self.play_effect = nil
-- 	end
-- 	self.play_effect = RenderUnit.CreateEffect(effec_id or 43, self.view.node_t_list.layout_world_explore.node, 999, 
-- 		0.08, 1, x or 350, y or 300, self.after_effect_call_back)
-- end

function ExploreWorldPage:OnClickContinue()
	if self.last_click_time < Status.NowTime then
		self.last_click_time = Status.NowTime + 1
		self:OnClickXunBaoHandler(self.continue_xunbao_type)
	end
end	

function ExploreWorldPage:OnClickXunBaoHandler(explore_type)
	-- local info = DmkjConf.DmParam[1][explore_type]
	-- if ItemData.Instance:GetItemNumInBagById(info.item.id,nil) < info.item.count then
	-- 	if self.check_box:isVisible() then
	-- 		if nil == self.alert_view then
	-- 			self.alert_view = Alert.New()
	-- 		end
	-- 		local item_cfg = ItemData.Instance:GetItemConfig(info.item.id)
	-- 		local color = string.format("%06x", item_cfg.color)
	-- 		local difference_value =  info.item.count - ItemData.Instance:GetItemNumInBagById(info.item.id,nil)
	-- 		local difference_yb = info.yb * difference_value
	-- 		local des = string.format(Language.Explore.TipDesc, color, item_cfg.name, difference_yb,difference_value,color, item_cfg.name)
	-- 		self.alert_view:SetLableString(des)
	-- 		self.alert_view:SetShowCheckBox(true)
	-- 		self.alert_view:SetOkFunc(function ()
	-- 			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= difference_yb then
	-- 				ExploreCtrl.Instance:SendXunbaoReq(explore_type, 1)	
	-- 			else
	-- 				ViewManager.Instance:Open(ViewName.ChargePlatForm)
	-- 			end
	-- 		end)
	-- 		self.alert_view:Open()
	-- 	else
	-- 		ExploreCtrl.Instance:SendXunbaoReq(explore_type, 0)
	-- 	end
	-- else
	-- 	ExploreCtrl.Instance:SendXunbaoReq(explore_type, 0)
	-- end
	ExploreCtrl.Instance:SendXunbaoReq(explore_type, 1)	
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ExploreWorldPage:OnClickJiesuanBack()
	self.view.node_t_list.layout_jisuan.node:setVisible(false)
end	

function ExploreWorldPage:OnSetJiesuanVisible()
	self.view.node_t_list.layout_jisuan.node:setVisible(true)	
	for k,v in pairs(self.award_cell_list) do
		v:GetView():setVisible(false)
		v:SetExploreQuality(0,1)
	end
	if self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil 
	end
	self:CheckPlayItemEffect(1)
end	

function ExploreWorldPage:CheckPlayItemEffect(index)
	if index <= #self.item_list and index <= #self.award_cell_list then
		local cell = self.award_cell_list[index]
		cell:GetView():setVisible(true)
		local data = ExploreData.Instance:CanPlayeffct(self.item_list)
		if #data == 0 then
			local scale_to = cc.ScaleTo:create(0.1, 1.3)
			local scale_to_1 = cc.ScaleTo:create(0.1, 1)
			local action = cc.Sequence:create(scale_to, scale_to_1,call_back_2)
			cell:GetView():stopAllActions()
			cell:GetView():runAction(action)	
		else
			for k1, v1 in pairs(data) do
				if index == v1 then
					local call_back = cc.CallFunc:create(function()
						cell:SetExploreQuality(29, 1.5)
					end)
					local scale_to_1 = cc.ScaleTo:create(0.1, 1.5)
					local rote_to_2 = cc.RotateTo:create(0.1, 360)
					local call_back_3 = cc.CallFunc:create(function()
										cell:GetView():setScale(1)
									end)
					local spawn_1 = cc.Spawn:create(scale_to_1, rote_to_2)
					local call_back_2 = cc.CallFunc:create(function()
										cell:SetExploreQuality(7, 1)
									end)
					local action = cc.Sequence:create(call_back, spawn_1, call_back_3, call_back_2)
					--v:GetView():stopAllActions()
					cell:GetView():runAction(action)
				else
					local scale_to = cc.ScaleTo:create(0.1, 1.3)
					local scale_to_1 = cc.ScaleTo:create(0.1, 1)
					local action = cc.Sequence:create(scale_to, scale_to_1,call_back_2)
					--v:GetView():stopAllActions()
					cell:GetView():runAction(action)
				end
			end
		end

		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
				self:CheckPlayItemEffect(index + 1)
		end, 0.3)
	end	
end	


ExploreCell = ExploreCell or BaseClass(BaseCell)

function ExploreCell:SetExploreQuality(effect_id, scale)
	scale = scale or 1
	if effect_id > 0 and nil == self.exploreCell_effect then
		self.exploreCell_effect = AnimateSprite:create()
		self.exploreCell_effect:setPosition(BaseCell.SIZE / 2, BaseCell.SIZE / 2)
		self.view:addChild(self.exploreCell_effect, 99, 99)
	end

	if nil ~= self.exploreCell_effect then
		if effect_id > 0 then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.exploreCell_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
			self.exploreCell_effect:setScale(scale)
		else
			self.exploreCell_effect:setStop()
		end
		self.exploreCell_effect:setVisible(effect_id > 0)
	end
end	


