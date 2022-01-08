--[[
******通用揭秘啊你头部栏*******

	-- by david.dai
	-- 2014/6/5
]]

local GeneralHead = class("GeneralHead", BaseLayer)

function GeneralHead:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.common.GeneralHead")
end

function GeneralHead:initUI(ui)
	self.super.initUI(self,ui)

	self.btn_return 			= TFDirector:getChildByPath(ui, 'btn_return')
	self.btn_return.logic 		= self

	self.type 					= nil
	self.img_title				= TFDirector:getChildByPath(ui, 'img_title')
	
	self.resViewer = {}
	self.resType   = {}

	for i=1,3 do
		local img_res_bg 		= TFDirector:getChildByPath(ui, 'img_res_bg_'..i)
		local img_res_icon 		= TFDirector:getChildByPath(ui, 'img_res_icon_'..i)
		local txt_res_number 	= TFDirector:getChildByPath(ui, 'txt_number_'..i)
		local btn_res_add 		= TFDirector:getChildByPath(ui, 'btn_add_'..i)

		--默认不显示
		img_res_bg:setVisible(false)
		btn_res_add.logic 		= self
		self.resViewer[i] 		= {bg=img_res_bg,icon=img_res_icon,number=txt_res_number,add=btn_res_add}

		btn_res_add:setClickAreaLength(100);
	end

	self.btn_chat 				= TFDirector:getChildByPath(ui, 'btn_chat')
	self.btn_chat.logic 		= self

	self.btn_return:setClickAreaLength(100);
	self.btn_chat:setClickAreaLength(100);

	self.buyButtonEventBound= nil

end

function GeneralHead:removeUI()
	self.super.removeUI(self)

	self.buyButtonEventBound = nil
	
end

--[[
	处理资源购买
]]
function GeneralHead.handleBuyResource(widget)
	local resType = widget.resType
	if resType == HeadResType.SYCEE then
		PayManager:showPayLayer()
	elseif resType == HeadResType.COIN then
		CommonManager:showNeedCoinComfirmLayer()
	elseif resType == HeadResType.PUSH_MAP then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.PUSH_MAP)
	elseif resType == HeadResType.QUNHAO then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.QUNHAO)
	elseif resType == HeadResType.CLIMB then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.CLIMB)
	elseif resType == HeadResType.SKILL_POINT then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.SKILL_POINT)
		
	elseif resType == HeadResType.JIEKUANGLING then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.MINE)
	elseif resType == HeadResType.BAOZI then
		VipRuleManager:showReplyLayer(EnumRecoverableResType.BAOZI)
	elseif resType == HeadResType.YUELI then
		print("======= to get yueli =======")
	end

end

--[[
	设置控制图层
]]
function GeneralHead:setLogic(logic)
	self.logic = logic
end

--[[
设置资源类型
]]
function GeneralHead:setData(type,resTypeList)
	self.type = type
	self.resType = resTypeList

	local titleTexturePath = self:getTitleImagePath(self.type)
	if titleTexturePath == nil then
		self.img_title:setVisible(false)
	else
		self.img_title:setTexture(titleTexturePath)
		self.img_title:setVisible(true)
	end

	self:boundBuyButtonEvent()
end

--[[
初始化界面，并且绑定购买按钮事件
]]
function GeneralHead:boundBuyButtonEvent()
	-- 如果已经绑定过事件直接返回
	if self.buyButtonEventBound then
		return
	end

	local chatButtonPos = self.btn_chat:getPosition()
	--注册购买按钮事件
    if self.resType and #self.resType > 0 then
		local resType = nil
		--local position  = nil
		--local startX = chatButtonPos.x - 140
		--local offsetX = -210
		local length = #self.resType
		local idx = 0
		local resViewer = nil

		for i=1,length do
			idx =  4 - i
			resViewer = self.resViewer[idx]
			resViewer.bg:setVisible(true)
			resType = self.resType[length + 1 - i]
			resViewer.icon:setTexture(GetResourceIconForGeneralHead(resType))
			resViewer.number:setText(getResValueExpressionByTypeForGH(resType))
			local canBuy = canBuyResource(resType)
			resViewer.add.resType = resType
			if canBuy then
				resViewer.add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.handleBuyResource),1)
				resViewer.add:setClickAreaLength(100)
			else
				resViewer.add:setVisible(false)
			end
		end
		for i=1,idx-1 do
			resViewer = self.resViewer[i]
			resViewer.bg:setVisible(false)
		end
		self.buyButtonEventBound = true
	end
end

--[[
	通过类型获取标题图片地址
]]
function GeneralHead:getTitleImagePath(type)
	if type == ModuleType.Mall then
		return "ui_new/common/title_shop.png"
	elseif type == ModuleType.Recruit then
		return "ui_new/common/title_jiuguan.png"
	elseif type == ModuleType.Bag then
		return "ui_new/common/xx_beibao_title.png"
	elseif type == ModuleType.Smithy then
		return "ui_new/common/xx_tiejiangpu_title.png"
	elseif type == ModuleType.RoleTransfer then
		return "ui_new/rolebreakthrough/xl_biaoti_title.png"
	elseif type == ModuleType.Task then
		return "ui_new/task/cj_chengjiu.png"
	elseif type == ModuleType.Notify then
		return "ui_new/notify/xx.png"
	elseif type == ModuleType.Qiyu then
		return "ui_new/qiyu/title.png"
	elseif type == ModuleType.RoleTrain then
		return "ui_new/rolerisingstar/js_jingmai_title.png"	
	elseif type == ModuleType.PVP then
		return "ui_new/spectrum/jz_jz_title.png"	
	elseif type == ModuleType.Arena then
		return "ui_new/spectrum/qh_qunhaopu_icon.png"	
	elseif type == ModuleType.Climb then
		return "ui_new/climb/wls_wls_title.png"	
	elseif type == ModuleType.Climb_Soul then
		return "ui_new/climb/wls_soul_title.png"
	elseif type == ModuleType.HandBook then
		return "ui_new/handbook/handbook_title.png"
	elseif type == ModuleType.Bloodybattle then
		return "ui_new/bloodybattle/xz_title.png"
	elseif type == ModuleType.Leaderboard then
		return "ui_new/leaderboard/title_leaderboard.png"
	elseif type == ModuleType.JifenShop then
		return "ui_new/spectrum/title_shop.png"
	elseif type == ModuleType.YunYingHuoDong then
		return "ui_new/operatingactivities/yy_title.png"
	elseif type == ModuleType.SmithySell then
		return "ui_new/smithy/img_chushou.png"
	elseif type == ModuleType.Hermit then
		return "ui_new/common/title_guiyin.png"
	elseif type == ModuleType.Faction then
		return "ui_new/faction/img_bp.png"
	elseif type == ModuleType.Jyt_Faction then
		return "ui_new/faction/img_jyt.png"
	elseif type == ModuleType.Rank_Faction then
		return "ui_new/faction/img_bpph.png"
	elseif type == ModuleType.Zyt_Faction then
		return "ui_new/faction/img_zyt.png"
	elseif type == ModuleType.Friend then
		return "ui_new/friend/img_haoyou.png"
	elseif type == ModuleType.BossFight then
		return "ui_new/demond/img_biaoti.png"
	elseif type == ModuleType.ZhengBa then
		return "ui_new/Zhenbashai/img_wldh_word.png"
	elseif type == ModuleType.Wulin then
		return "ui_new/Zhenbashai/img_wl.png"
	elseif type == ModuleType.FactionMall then
		return "ui_new/faction/img_zbgb.png"
	elseif type == ModuleType.WeekRace then
		return "ui_new/Zhenbashai/img_wldh_word.png"
	elseif type == ModuleType.NorthClimb then
		return "ui_new/Zhenbashai/wls_wls_title.png"
	elseif type == ModuleType.Hs_Faction then
		return "ui_new/faction/houshan/img_hs.png"
	elseif type == ModuleType.PracticeFaction then
		return "ui_new/faction/xiulian/img_xiulian.png"
	elseif type == ModuleType.InheritFaction then
		return "ui_new/faction/xiulian/img_cc.png"
	elseif type == ModuleType.PracticeXL then
		return "ui_new/faction/xiulian/img_xiulian2.png"
	elseif type == ModuleType.Employ then
		return "ui_new/yongbing/img_yongbing.png"
	elseif type == ModuleType.Mining then
		return "ui_new/mining/img_caikuang.png"
	elseif type == ModuleType.LootMineral then
		return "ui_new/mining/img_jiekuang.png"
	elseif type == ModuleType.ChooseMineral then
		return "ui_new/mining/img_xuankuang.png"
	elseif type == ModuleType.Qimendun then
		return "ui_new/qimengdun/img_qimendun.png"
	elseif type == ModuleType.QiYuan then
		return "ui_new/shop/img_qiyuan.png"
	elseif type == ModuleType.FactionFight then
		return "ui_new/faction/fight/img_bpzf.png"
	elseif type == ModuleType.FactionMessage then
		return "ui_new/faction/fight/img_zhankuang.png"
	elseif type == ModuleType.FactionFightMessage then
		return "ui_new/faction/fight/img_duizhan.png"
	elseif type == ModuleType.Gamble then
		return "ui_new/qiyu/dushi/img_dushi.png"
	elseif type == ModuleType.TianShu then
		return "ui_new/tianshu/img_tianshu.png"
	elseif type == ModuleType.Smriti then
		return "ui_new/smithy/img_zhuangbeizhuanhuan.png"
	elseif type == ModuleType.youli then
		return "ui_new/youli/img_youli.png"
	elseif type == ModuleType.JingYao then
		return "ui_new/tianshu/img_jy.png"
	elseif type == ModuleType.JingyaoFenjie then
		return "ui_new/tianshu/img_fenjie.png"
	elseif type == ModuleType.CangShuGe then
		return "ui_new/youli/shop/img_csg.png"
	elseif type == ModuleType.XiaKe then
		return "ui_new/shop/img_xksc.png"
	elseif type == ModuleType.Honor then
		return "ui_new/shop/img_kfsc.png"
	elseif type == ModuleType.KFWLDH then
		return "ui_new/wulin/img_kfwldh.png"
	elseif type == ModuleType.HuanGong then
		return "ui_new/shop/img_huangong.png"
	elseif type == ModuleType.EquipChange then
		return "ui_new/roleequip/img_kuaisuhz.png"
    else
		return nil
	end
end

function GeneralHead:onShow()
	self.super.onShow(self)
    self:refreshUI();
end

--[[
	刷新页面
]]
function GeneralHead:refreshUI()
	if self.resType and #self.resType > 0 then
		local length = #self.resType
		local idx = 0
		for i=1,length do
			idx =  4 - i
			resType = self.resType[length + 1 - i]
			self.resViewer[idx].number:setText(getResValueExpressionByTypeForGH(resType))
		end

	end
	CommonManager:updateRedPoint(self.btn_chat, ChatManager:isHaveNewChat(),ccp(0,0))
end

function GeneralHead.returnButtonClick(sender)
	--quanhuan add 2015-9-16 17:17:05
	MissionManager:quickPassToGetFGoods(nil, nil)
	TFWebView.removeWebView();
    AlertManager:close(AlertManager.TWEEN_1);
end

function GeneralHead.chatButtonClick(sender)
	--print("GeneralHead chat button click : ")
	ChatManager:showChatLayer()
end

function GeneralHead:registerEvents()
	if self.registerEventsCalled then
		return
	end
	self.super.registerEvents(self)

	self.btn_return:addMEListener(TFWIDGET_CLICK, audioClickfun(self.returnButtonClick,play_fanhui),1)
	self.btn_return:setClickAreaLength(100)
	self.btn_chat:addMEListener(TFWIDGET_CLICK, audioClickfun(self.chatButtonClick),1)
	self.btn_chat:setClickAreaLength(100)

	if not self.updateUserDataCallBack then
		self.updateUserDataCallBack = function(event)
    	    self:refreshUI()
    	end
		TFDirector:addMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch ,self.updateUserDataCallBack)
		TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack)
	end

	self:boundBuyButtonEvent()

	self.registerEventsCalled = true
end

function GeneralHead:removeEvents()
    if self.btn_return == nil then
    	return
    end
    self.super.removeEvents(self)
    self.btn_return:removeMEListener(TFWIDGET_CLICK)
    self.btn_chat:removeMEListener(TFWIDGET_CLICK)

    --移除购买按钮事件
    if self.resViewer then
    	for i=1,3 do
    		if self.resViewer[i] and self.resViewer[i].add then
				self.resViewer[i].add:removeMEListener(TFWIDGET_CLICK)
			end
		end
	end

	TFDirector:removeMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch ,self.updateUserDataCallBack)
	TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack)
	self.updateUserDataCallBack = nil
	self.buyButtonEventBound = nil
	self.registerEventsCalled= nil
end

function GeneralHead:getSize()
	return self.ui:getSize()
end

function GeneralHead:setResVisibleByIndex(index, bVisible)
	if self.resViewer[index] and self.resViewer[index].bg then
		self.resViewer[index].bg:setVisible(bVisible)
	end
end

return GeneralHead
