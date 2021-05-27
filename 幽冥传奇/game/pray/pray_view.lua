PrayView = PrayView or BaseClass(XuiBaseView)
function PrayView:__init()
	self:SetModal(true)
	self.texture_path_list = {"res/xui/pray.png", "res/xui/fight.png", 'res/xui/limit_activity.png',}
	self.config_tab = {
			{"pray_ui_cfg", 1, {0}},
			-- {"common_ui_cfg", 1, {0}},
			-- {"common_ui_cfg", 2, {0}},
		}
	-- self.title_img_path = ResPath.GetPray("word_title")
end

function PrayView:__delete()

end	

function PrayView:ReleaseCallBack()
	self.play_eff = nil
	self:DeleteCreatePlayDelayTimer()
end

function PrayView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- RichTextUtil.ParseRichText(self.node_t_list.rich_interp.node, Language.Pray.DescContent, 18)
		-- XUI.SetRichTextVerticalSpace(self.node_t_list.rich_interp.node, 8)
		XUI.AddClickEventListener(self.node_t_list.btn_pray1.node, BindTool.Bind(self.OnPrayBindGoldClicked, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_pray2.node, BindTool.Bind(self.OnPrayBindCoinClicked, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind(self.OnClose, self), true)		
		self.node_t_list.btn_pray1.node:setHittedScale(1.03)
		self.node_t_list.btn_pray2.node:setHittedScale(1.03)		
		self.node_t_list.txt_win_title_name.node:loadTexture(ResPath.GetPray("word_title"))
		-- self.effec =  RenderUnit.CreateEffect(56, self.node_t_list.layout_pray.node, 100, FrameTime.Effect2, loops, self.ph_list.ph_eff.x, self.ph_list.ph_eff.y, callback_func)
		-- self.effec:setScale(0.45)
		-- self.node_t_list.layout_get_num_info.node:setVisible(false)
	end
end

function PrayView:OnClose()
	self:Close()
end

function PrayView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	PrayCtrl.Instance:PrayMoneyReq(0,1)
	PrayCtrl.Instance:PrayMoneyReq(0,2)
end

function PrayView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.is_clicked = false
	self.tick = 100
end

function PrayView:ShowIndexCallBack(index)
	self:Flush(index)
end

function PrayView:OnFlush(param_list, index)
	for i=1,2 do
		local data = PrayData.Instance:GetPrayMoneyData(i)
		local max_cnt = PrayData.GetPrayMaxCnt(i)
		XUI.SetLayoutImgsGrey(self.node_t_list["btn_pray"..i].node, data.oper_cnt >= max_cnt, true)		
		-- self.node_t_list["lbl_rest_pray_time"..i].node:setString(Language.Pray.PrayTime)
		self.node_t_list["lbl_cost"..i].node:setString(PrayData.Instance:GetPrayCostStrByTime(i))
		local cur_money_str = PrayData.GetCurGetMoneyStr(data.oper_cnt+1,i)
		self.node_t_list["layout_get_num_info"..i].node:setVisible(cur_money_str ~= "")
		self.node_t_list["lbl_cur_get_money"..i].node:setString(cur_money_str)
		if self.is_clicked then
			self:CreatePlayEffec()
			self.is_clicked = false
			if  data.awar_info[1] and data.awar_info[1].double_flag == 1 then
				self:CreateCritTip(data.awar_info[1].get_money)
			end
		end
	end
end

local effec_ids = {
	57,
	58,
	59,
	60,
	61,
	62,
	63,
	64,
	65,
	66,
}
function PrayView:OnPrayBindGoldClicked()
	self:TypePrayBindGold(1)
end

function PrayView:OnPrayBindCoinClicked()
	self:TypePrayBindGold(2)
end

function PrayView:TypePrayBindGold(index)
	self.tick = 0
	self.is_clicked = true
	PrayCtrl.Instance:PrayMoneyReq(1,index)
end

function PrayView:CreatePlayEffec()
	self:DeleteCreatePlayDelayTimer()
	self:CreatePlayDelayTimer()
	if self.tick < 50 then
		for i = 1, 3 do
			local eff_id = effec_ids[math.random(1, #effec_ids)]
			local size = self.root_node:getContentSize()
			local x = size.width/2 + math.random(-430, 430)
			local y = size.height + 150
			self:PlayPrayEffect(eff_id, x, y)
		end
	else
		self:DeleteCreatePlayDelayTimer()
	end
	self.tick = self.tick + 1
end

function PrayView:PlayPrayEffect(eff_id, x, y)
	local effec = RenderUnit.CreateEffect(eff_id, self.root_node, 50, frame_interval, loops, x, y, callback_func)
	local move_time = math.random(7, 9) * 0.15
	local moveby = cc.MoveBy:create(move_time, cc.p(0, -655))
	-- local delay = cc.DelayTime:create(0.02)
	local fadeout = cc.FadeOut:create(0.15)
	local func = function()
				effec:setStop()
				effec:removeFromParent(true)
				effec = nil
		end
	local call_back = cc.CallFunc:create(func)
	local action = cc.Sequence:create(moveby, fadeout, call_back)
	effec:runAction(action)
	
end

function PrayView:CreatePlayDelayTimer()
	if nil == self.create_eff_delay_timer then
		self.create_eff_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:CreatePlayEffec()
			end, 0.0045)
	end
	
end

function PrayView:DeleteCreatePlayDelayTimer()
	if self.create_eff_delay_timer then
		GlobalTimerQuest:CancelQuest(self.create_eff_delay_timer)
		self.create_eff_delay_timer = nil
	end
end

function PrayView:OnInterpClicked()
	DescTip.Instance:SetContent(Language.Pray.DescContent, Language.Pray.TipTitle)
end

--创建暴击提示字
function PrayView:CreateCritTip(num, imgName)
	-- local tip_w, tip_h = 300, 100
	-- local tipLayout = XUI.CreateLayout(HandleRenderUnit:GetWidth() / 2 + 60 , HandleRenderUnit:GetHeight() / 2, tip_w, tip_h)
	local titleImg = XUI.CreateImageView(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2, ResPath.GetFightResPath("r_baoji"), true)
	HandleRenderUnit:AddUi(titleImg, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)
	-- titleImg:setAnchorPoint(0, 1)
	-- tipLayout:addChild(titleImg, 2, 1)
	-- local rich_text = XUI.CreateRichText(115, tip_h - titleImg:getContentSize().height + 20, tip_w, 32)
	-- rich_text:setIgnoreSize(true)
	-- rich_text:setAnchorPoint(0, 1)
	-- tipLayout:addChild(rich_text, 2, 2)
	-- XUI.RichTextAddImage(rich_text, ResPath.GetPray(imgName), true)
	-- rich_text:refreshView()
	-- local numBar = NumberBar.New()
	-- numBar:SetRootPath(ResPath.GetFightResPath("y_"))
	-- numBar:SetSpace(-2)
	-- numBar:SetHasPlus(true)
	-- numBar:GetView():setScale(0.7)
	-- numBar:SetNumber(num)
	-- XUI.RichTextAddElement(rich_text, numBar:GetView())

	local moveby = cc.MoveBy:create(0.65, cc.p(0, 120))
	local fadeIn = cc.FadeIn:create(0.25)
	local spawn = cc.Spawn:create(moveby, fadeIn)
	local delay = cc.DelayTime:create(0.65)
	local fadeout = cc.FadeOut:create(0.85)
	local func = function()
				titleImg:removeFromParent(true)
				titleImg = nil
		end
	local call_back = cc.CallFunc:create(func)
	local action = cc.Sequence:create(spawn, delay, fadeout, call_back)
	titleImg:runAction(action)
end