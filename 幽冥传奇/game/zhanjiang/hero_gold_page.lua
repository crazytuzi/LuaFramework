--神兵神盾页面
HeroGoldPage = HeroGoldPage or BaseClass()

function HeroGoldPage:__init()
	self.view = nil
	self.page = nil
	self.upLevelBtn = nil
	self.lookBtn = nil
	self.helpBtn = nil
	self.equipType = nil
	self.is_first_login = true
	
end	

function HeroGoldPage:__delete()
	self:RemoveEvent()
	if nil ~= self.buy_scroll_list then
		self.buy_scroll_list:DeleteMe()
		self.buy_scroll_list = nil
	end	
	self.effec = nil
	self.effec_1 = nil
	self.page = nil
	self.view = nil
	self.equipType = nil
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
	self.effec_dum = nil
end	

--初始化页面接口
function HeroGoldPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.layout_hero_gold

	self.equipType = ComposeType.Shendun

	
	self:CreateViewElement()
	self:InitEvent()
end

function HeroGoldPage:CreateViewElement()
	if nil == self.buy_scroll_list then
		local ph = self.view.ph_list.ph_buy_list
		self.buy_scroll_list = ListView.New()
		self.buy_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroGoldPageItemRender, nil, nil, self.view.ph_list.ph_buy_item)
		self.page.componment4.node:addChild(self.buy_scroll_list:GetView(), 100)
		self.buy_scroll_list:SetItemsInterval(5)
		self.buy_scroll_list:SetJumpDirection(ListView.Top)
		self.buy_scroll_list:JumpToTop()
	end
	if self.tabbar == nil then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.page.node, 5,555,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.Zhanjiang.TabGrop, false, ResPath.GetCommon("toggle_104_normal"))
		self.tabbar:SetSpaceInterval(3)
		self.tabbar:SelectIndex(1)
		self.SelectIndex = 1
	end
	self:creatEffct()	
end	


--初始化事件
function HeroGoldPage:InitEvent()
	XUI.AddClickEventListener(self.page.componment3.uplevelBtn.node,BindTool.Bind(self.OnClickUpLevel,self),true)
	XUI.AddClickEventListener(self.page.componment5.node,BindTool.Bind(self.OnActive,self),false)
	XUI.AddClickEventListener(self.page.componment5.active_btn.node,BindTool.Bind(self.OnActive,self),true)
end

function HeroGoldPage:SelectTabCallback(index)
	self.SelectIndex = index
	self:UpdateData()
end

function HeroGoldPage:changeeBar(index)
	if self.tabbar then
		self.SelectIndex = index
		self.tabbar:SelectIndex(self.SelectIndex)
		self:UpdateData()
	end
end 

--移除事件
function HeroGoldPage:RemoveEvent()

end

--更新视图界面
function HeroGoldPage:UpdateData(data)	
	local cfg
	if self.SelectIndex == ZhanjiangData.TempType.GoldBingLevel then
		cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldBingLevel)
	elseif self.SelectIndex == ZhanjiangData.TempType.GoldDunLevel then
		cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldDunLevel)
	end
	local flag1,flag2 = self:GetHeroGoldRemind()
	self.tabbar:SetRemindByIndex(1, flag1 > 0)
	self.tabbar:SetRemindByIndex(2, flag2 > 0)
	if not cfg or cfg.temp_value <= 0 then
		self:Clear()
		self.page.componment5.node:setVisible(true)
		self:UpdateConsume(0)
		self:UpdateAttr()
		self.page.componment1.node:setVisible(false)
		self:UpdateShop({})
		self.effec_dum:setVisible(false)
	else
		self.page.componment5.node:setVisible(false)
		self.page.componment1.node:setVisible(true)
		if not self.effec then
			self.effec = RenderUnit.CreateEffect(43, self.page.componment1.img_layout.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec:setLocalZOrder(-10)
		end
		if not self.effec_1 then
			self.effec_1 = RenderUnit.CreateEffect(43, self.page.componment1.img_layout_1.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec_1:setLocalZOrder(109)
			self.effec_1:setOpacity(90)
		end
		self.effec_dum:setVisible(true)
		self:UpdateAttr(cfg.temp_value)	
	end
end

--激活
function HeroGoldPage:OnActive()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ZhanjiangCtrl.Instance:SetHeroGoldReq(self.SelectIndex)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	

--升级点击
function HeroGoldPage:OnClickUpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ZhanjiangCtrl.Instance:SetHeroGoldReq(self.SelectIndex)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--物品改变
function HeroGoldPage:ItemDataListChangeCallback()
	self:UpdateData()
end

function HeroGoldPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT then
		self:UpdateData()
	end	
end	

function HeroGoldPage:creatEffct()
	if not self.effec_dum then
		local ph = self.view.ph_list.current_container
		self.effec_dum = AnimateSprite:create()
		self.page.node:addChild(self.effec_dum,9999)
		self.effec_dum:setPosition(ph.x,ph.y)
	end	
end	

function HeroGoldPage:UpdateAttr(level)
	if not level then
		for i = 1, 4 do
			self.page.componment2["layout_bg" .. i].node:setVisible(false)
		end
		return
	end
	local level_cfg_now = ZhanjiangData.Instance:GetHeroGoldCfg(self.SelectIndex,level)
	local level_cfg_next = ZhanjiangData.Instance:GetHeroGoldCfg(self.SelectIndex,level+1)
	local data = {}
	local dataList = {}
	local num = 0
	for i=1,1 do
		data[i]= {}
		if level_cfg_now and level_cfg_now[i] then
			data[i].level_cfg_now = level_cfg_now[i]
		end
		if level_cfg_next and level_cfg_next[i] then
			data[i].level_cfg_next = level_cfg_next[i]
		end
	end
	if level_cfg_next then
		num = #level_cfg_next
	else
		num = #level_cfg_now
	end
	if level_cfg_now then
		dataList = {}
		level_cfg_now[#level_cfg_now].index = self.SelectIndex
		level_cfg_now[#level_cfg_now].num = 1
		level_cfg_now[#level_cfg_now].level = level
		table.insert(dataList,level_cfg_now[#level_cfg_now])
		if level_cfg_next then
			level_cfg_next[#level_cfg_next].num = 2
			level_cfg_next[#level_cfg_next].level = level
			level_cfg_next[#level_cfg_next].index = self.SelectIndex
			table.insert(dataList,level_cfg_next[#level_cfg_next])
		else
			level_cfg_now[#level_cfg_now].level = 0
			level_cfg_now[#level_cfg_now].num = 2
			level_cfg_now[#level_cfg_now].index = self.SelectIndex
			table.insert(dataList,level_cfg_now[#level_cfg_now])
		end
		self:UpdateShop(dataList)
	end

	for i = 1, 4 do
		if not data[i]  then
			self.page.componment2["layout_bg" .. i].node:setVisible(false)
		else
			self.page.componment2["layout_bg" .. i].node:setVisible(true)
			if data[i].level_cfg_now and next(data[i].level_cfg_now) then			
				self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString(Language.Role.BuffAttrName[data[i].level_cfg_now.type].. "：" or "")
				self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString(data[i].level_cfg_now.value)
			else
				self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString("0")
			end

			if data[i].level_cfg_next and next(data[i].level_cfg_next) then
				self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString(Language.Role.BuffAttrName[data[i].level_cfg_next.type].. "：" or "")
				self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString(data[i].level_cfg_next.value)
			else
				self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString(Language.Guild.Nothing)
			end
		end
	end
	self:UpdateConsume(level)	
	local cur_step,cur_level = math.ceil(level/10),math.mod(level,10)
	self.page.componment1.step_image.node:loadTexture(ResPath.GetCommon("step_" .. cur_step))
	if self.effec_dum then
		local effct = ZhanjiangData.Instance:GetHeroGoldEffctCfg(self.SelectIndex,cur_step)
		local ph = self.view.ph_list.current_container
		if self.SelectIndex == 1 then
			self.effec_dum:setPosition(ph.x+70,ph.y+80)
			self.effec_dum:setRotation(270)
			self.effec_dum:setScale(1)
		else
			self.effec_dum:setScale(ZhanjiangData.EffctWH[cur_step])
			self.effec_dum:setRotation(0)
			self.effec_dum:setPosition(ph.x,ph.y)
		end
		local path, name = ResPath.GetEffectAnimPath(effct)
		self.effec_dum:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	end
	for i = 1, 10 do
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end
	if level >1 and cur_level == 0 then
		cur_level = 10
	else		
		for i = cur_level + 1,10 do
			self.page.componment3["starImg" .. i].node:setVisible(true)
			self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_lock"))
		end
	end
	if cur_level>=1 then
		for i = 1,cur_level do
			self.page.componment3["starImg" .. i].node:setVisible(true)
			self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_select"))
		end
	end	
end	

function HeroGoldPage:UpdateShop(data)
	if self.buy_scroll_list then
		self.buy_scroll_list:SetDataList(data)
	end
end	

function HeroGoldPage:Clear()
	for i = 1, 4 do
		self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString("")
		self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString("")
		self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString("")
	end	
	for i = 1, 10 do
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end	
end	

function HeroGoldPage:UpdateConsume(level)	
	if level<= 0 then
		self.page.componment3.consumeTipText.node:setString("")
		self.page.componment3.progress_bar.node:setPercent(0)
		self.page.componment3.progressText.node:setString("")	
	else
		local cost = ZhanjiangData.Instance:GetHeroGoldCostCfg(self.SelectIndex,level+1)
		if cost and next(cost) then
			local num = ItemData.Instance:GetItemNumInBagById(cost[1].id)
			self.page.componment3.progress_bar.node:setPercent(num /cost[1].count * 100)
			self.page.componment3.progressText.node:setString(num .. "/" .. cost[1].count)
		else
			self.page.componment3.progress_bar.node:setPercent(100)
			self.page.componment3.progressText.node:setString("100/100")
		end
	end
end	


function HeroGoldPage:GetHeroGoldRemind()
	local flag1,flag2 = 0,0
	local cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldBingLevel)
	if cfg and cfg.temp_value and cfg.temp_value <=0 then
		local cost = ZhanjiangData.Instance:GetHeroGoldCostCfg(1,1)
		if cost and  cost[1] and cost[1].count then
			local had_num = ItemData.Instance:GetItemNumInBagById(cost[1].id,nil)
			if had_num>=cost[1].count then
				flag1 = 1
			end
		end
	elseif cfg and cfg.temp_value and cfg.temp_value >0 then
		local cost = ZhanjiangData.Instance:GetHeroGoldCostCfg(1,cfg.temp_value+1)
		if cost and  cost[1] and cost[1].count then
			local had_num = ItemData.Instance:GetItemNumInBagById(cost[1].id,nil)
			if had_num>=cost[1].count then
				flag1 = 1
			end
		end
	end
	cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldDunLevel)
	if  cfg and cfg.temp_value and cfg.temp_value <=0 then
		local activat = HeroGoldDunData.Instance:GetEquipBossCfg()
		local flag = true
		for i,v in ipairs(activat) do
			if v.state ~= 1 then
				flag = false
				break 
			end
		end
		if flag then
			flag2 =  1
		end
	elseif cfg and cfg.temp_value and cfg.temp_value >0 then
		local cost = ZhanjiangData.Instance:GetHeroGoldCostCfg(2,cfg.temp_value+1)
		if cost and  cost[1] and cost[1].count then
			local had_num = ItemData.Instance:GetItemNumInBagById(cost[1].id,nil)
			if had_num>=cost[1].count then
				flag2 = 1
			end
		end
	end
	return flag1,flag2
end


------------------
HeroGoldPageItemRender = HeroGoldPageItemRender or BaseClass(BaseRender)
function HeroGoldPageItemRender:__init()
	
end

function HeroGoldPageItemRender:__delete()

end

function HeroGoldPageItemRender:CreateChild()
	BaseRender.CreateChild(self)

end

function HeroGoldPageItemRender:OnFlush()
	if not self.data then return end
	if self.data.index == 2 then
		if self.data.num == 2 then
			if self.data.level == 0 then
				local str = Language.Zhanjiang.HeroGoldDunNode..Language.Common.MaxLv				
				RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
			else				
				local net_level = self.data.level +1
				local str = "Lv."..net_level.." "..Language.Zhanjiang.HeroGoldDunNode..string.format(Language.Equipment.ClearEquip_Color,"ff0000","("..Language.Role.NotActive..")") 
				RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
			end
		else
			local str  = "Lv."..self.data.level.." "..Language.Zhanjiang.HeroGoldDunNode.."("..Language.Role.HadActive..")"
			RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
		end

		self.node_tree.img_skill.node:loadTexture(ResPath.GetHeroGold("hero_gold_dun_icon"))
		local x = RoleData.FormatValueStr(self.data.type, self.data.value)
		RichTextUtil.ParseRichText(self.node_tree.lbl_item_cost.node,string.format(Language.Zhanjiang.HeroGoldDun,RoleData.FormatValueStr(self.data.type, self.data.value)),20,cc.c3b(0xff, 0xff, 0xff))	
	else
		if self.data.num == 2 then
			if self.data.level == 0 then
				local str = Language.Zhanjiang.HeroGoldBingNode..Language.Common.MaxLv				
				RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
			else
				local net_level = self.data.level +1
				local str = "Lv."..net_level.." "..Language.Zhanjiang.HeroGoldBingNode..string.format(Language.Equipment.ClearEquip_Color,"ff0000","("..Language.Role.NotActive..")")
				RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
			end
		else
			local str  = "Lv."..self.data.level.." "..Language.Zhanjiang.HeroGoldBingNode.."("..Language.Role.HadActive..")"
			RichTextUtil.ParseRichText(self.node_tree.txt_level.node,str,20,cc.c3b(0x00, 0xff, 0x00))
		end
		self.node_tree.img_skill.node:loadTexture(ResPath.GetHeroGold("hero_gold_bing_icon"))
		RichTextUtil.ParseRichText(self.node_tree.lbl_item_cost.node,string.format(Language.Zhanjiang.HeroGoldBing,RoleData.FormatValueStr(self.data.type, self.data.value)),20,cc.c3b(0xff, 0xff, 0xff))	
	end
end
