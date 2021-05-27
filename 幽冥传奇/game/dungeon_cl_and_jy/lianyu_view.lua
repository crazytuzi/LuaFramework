local LianYuView = BaseClass(SubView)

function LianYuView:__init()
     self.texture_path_list = {
		'res/xui/fuben_cl.png',
    	'res/xui/fuben.png',
    	'res/xui/level_and_deify.png',
	}
	self.config_tab = {
		{"fuben_cl_and_jy_ui_cfg", 8, {0}},
	}
end
function LianYuView:__delete()
  
    -- self.remind_img = nil
end

function LianYuView:ReleaseCallBack()
	-- if self.award_list_view then
	-- 	self.award_list_view:DeleteMe()
	-- end
	-- self.award_list_view = nil

	-- if nil ~= self.cell then
	-- 	self.cell:DeleteMe()
	-- 	self.cell = nil
	-- end
	-- if self.guaka_list then
	-- 	self.guaka_list:DeleteMe()
	-- 	self.guaka_list = nil
	-- end
	if self.data_chanege then
		GlobalEventSystem:UnBind(self.data_chanege)
		self.data_chanege = nil 
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end

	if self.alert_sweep then
		self.alert_sweep:DeleteMe()
		self.alert_sweep = nil
	end
	if self.alert_view1 then
		self.alert_view1:DeleteMe()
		self.alert_view1 =nil 
	end
end

function LianYuView:LoadCallBack()

	XUI.AddClickEventListener(self.node_t_list.btn_sweep_lianyu.node, BindTool.Bind1(self.OnBtnSweep, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_fight.node, BindTool.Bind1(self.OnEnnterFight, self), true)

	local ph_duihuan = self.ph_list["ph_buy_num"]
	local text = RichTextUtil.CreateLinkText(Language.Lianyu.BuyNumsShow, 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x, ph_duihuan.y +15)
	self.node_t_list.layout_lianyu.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnBuyNum, self, 1), true)

	self.data_chanege = GlobalEventSystem:Bind(LIAN_FUBEN_EVENT.DATA_CHANGE, BindTool.Bind1(self.DataChange, self))

	-- 设置"副本"面板默认打开"副本-材料"面板
	DungeonCtrl.SetViewDefaultChild("Material")
end

function LianYuView:DataChange()
	self:FlushTimes()
end

function LianYuView:OnBuyNum()
	if FubenData.Instance:GetHadBuyNum() >= #PurgatoryFubenConfig.buyCount then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.TipsHadBuyNum)
		return
	end
	local had_buy_num =  FubenData.Instance:GetHadBuyNum()
	local comsume_cfg =  PurgatoryFubenConfig.buyCount[had_buy_num + 1]
	if comsume_cfg == nil then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.TipsHadBuyNum)
		return
	end
	if self.alert_view == nil then
		self.alert_view = Alert.New()
	end
	self.alert_view:SetOkString(Language.Common.Cancel)
    self.alert_view:SetCancelString(Language.Common.Confirm)
    local text = string.format(Language.Babel.BuyTips, comsume_cfg.consume[1].count)
    self.alert_view:SetLableString5(text, RichVAlignment.VA_CENTER)

    local path =  ResPath.GetCommon("gold")
   local  need_text = string.format(Language.Lianyu.Consume_Show, path, comsume_cfg.consume[1].count)

   self.alert_view:SetLableString6(need_text, RichVAlignment.VA_CENTER)
    -- self.alert_view:SetLableString4(consume_data.btn_top_desc_rich, RichVAlignment.VA_CENTER)
    self.alert_view:SetCancelFunc(function ()
    	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= comsume_cfg.consume[1].count then
    		--BabelCtrl.Instance:SendOpeateBabel(OperateType.BuyNum)
    		DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.buy)
    	else
    		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
    	end
    end)
	self.alert_view:SetOkFunc(function ()
    	self.alert_view:Close()
    end)
    self.alert_view:Open()
end

function LianYuView:OnBtnSweep( ... )  --扫荡经验副本
	if FubenData.Instance:GetRewardCanGet() > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.LianyuReward)
	else
		local sweep_consume = PurgatoryFubenConfig.sweepConsume[1]

		local item_config = ItemData.Instance:GetItemConfig(sweep_consume.id)


		local name = item_config.name
		local color = string.format("%06x", item_config.color)

		local text = string.format(Language.Lianyu.Text1Show, color, name, sweep_consume.count)


		self.alert_sweep = self.alert_sweep or Alert.New()
		self.alert_sweep:SetOkString(Language.Common.Cancel)
   		self.alert_sweep:SetCancelString(Language.Lianyu.TipsShow2)
   		self.alert_sweep:SetLableString(text, RichVAlignment.VA_CENTER)


   		local path = ResPath.GetItem(item_config.icon)

   		local num = BagData.Instance:GetItemNumInBagById(sweep_consume.id)
   		local color1 = num >= sweep_consume.count and "00ff00" or "ff0000"
   		local text2 = num .."/".. (sweep_consume.count)
   		local consume_text = string.format(Language.Lianyu.Text2SHow, color, name, color1, text2)
   		self.alert_sweep:SetLableString6(consume_text, RichVAlignment.VA_CENTER)
   		self.alert_sweep:SetOkFunc(function ()
	    	self.alert_sweep:Close()
	    end)

   		self.alert_sweep:SetCancelFunc(function ()
   			if num >= sweep_consume.count then
   				DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.sweep)
   			else
   				TipCtrl.Instance:OpenGetNewStuffTip(sweep_consume.id)
   			end
   		end)
	    self.alert_sweep:Open()
		
	end
end

function LianYuView:OnEnnterFight()
	if FubenData.Instance:GetRewardCanGet() > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.LianyuReward)
	else
		local had_buy_num = FubenData.Instance:GetHadBuyNum()
		local enter_times = FubenData.Instance:GetEnterTimes()
		local total_count = had_buy_num + PurgatoryFubenConfig.dayEnCount
		local remain_time = total_count - enter_times > 0 and  total_count - enter_times or 0 

		if remain_time <= 0 and  had_buy_num < #PurgatoryFubenConfig.buyCount then
			if self.alert_view1 == nil then
				self.alert_view1 = Alert.New()
			end
			local had_buy_num =  FubenData.Instance:GetHadBuyNum()
			local comsume_cfg =  PurgatoryFubenConfig.buyCount[had_buy_num + 1]
			if comsume_cfg == nil then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.TipsHadBuyNum)
				return
			end
			self.alert_view1:SetOkString(Language.Common.Cancel)
		    self.alert_view1:SetCancelString(Language.Common.Confirm)
		    local text = string.format(Language.Babel.BuyTips, comsume_cfg.consume[1].count)
		    self.alert_view1:SetLableString5(text, RichVAlignment.VA_CENTER)
		    local path =  ResPath.GetCommon("gold")
		   local  need_text = string.format(Language.Lianyu.Consume_Show, path, comsume_cfg.consume[1].count)

		   	self.alert_view1:SetLableString6(need_text, RichVAlignment.VA_CENTER)
		     self.alert_view1:SetCancelFunc(function ()
		    	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= comsume_cfg.consume[1].count then
		    		--BabelCtrl.Instance:SendOpeateBabel(OperateType.BuyNum)
		    		DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.buy)
		    	else
		    		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		    	end
		    end)
			self.alert_view1:SetOkFunc(function ()
		    	self.alert_view1:Close()
		    end)
		    self.alert_view1:Open()
		elseif remain_time <= 0  and had_buy_num >=  #PurgatoryFubenConfig.buyCount then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Lianyu.NoTimeTips)
		elseif remain_time > 0 then
			DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.fight)
		end
		
	end
end

function LianYuView:ShowIndexCallBack()
	self:Flush(index)
end

function LianYuView:CloseCallBack()
end


function LianYuView:OpenCallBack()
-- 	if FubenData.Instance:GetCurFightLevel() > 0 then --奖励未领取，打开领取奖励
-- 		ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
-- 	end
end

function LianYuView:FlushTimes( ... )
	local had_buy_num = FubenData.Instance:GetHadBuyNum()
	local enter_times = FubenData.Instance:GetEnterTimes()
	local total_count = had_buy_num + PurgatoryFubenConfig.dayEnCount
	local remain_time = total_count - enter_times > 0 and  total_count - enter_times or 0 

	self.node_t_list.text_remain_num.node:setString( "剩余次数："..remain_time.."/"..total_count)

	local max_bo = FubenData.Instance:GetLiyuMaxBo()
	local bool = false
	if max_bo >= #PurgatoryFubenConfig.MonsterWaveNum and remain_time > 0 then
		bool = true
	end

	XUI.SetButtonEnabled(self.node_t_list.btn_sweep_lianyu.node, bool)

	local btn_text = "进入炼狱"
	if FubenData.Instance:GetRewardCanGet() > 0 then
		btn_text = "领取奖励"
	end
	self.node_t_list.btn_fight.node:setTitleText(btn_text)

end

function LianYuView:OnFlush()
	self:FlushTimes()
end

return LianYuView