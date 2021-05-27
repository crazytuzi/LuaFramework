-- 星魂boss

local MayaBossView = BaseClass(SubView)

function MayaBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 11, {0}},
	}
end

function MayaBossView:__delete()
end

function MayaBossView:LoadCallBack(index, loaded_times)
	self.layer_list = nil
	self:CreateLayerList()
	-- self:CreateMonsterAnimation()
	self.select_index = 1

	-- XUI.AddClickEventListener(self.node_t_list.layout_maya.btn_tip.node, BindTool.Bind(self.OnClickTipHandler, self))
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind2(self.OnBtnLeft, self))
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind2(self.OnBtnRight, self))

	XUI.AddClickEventListener(self.node_t_list.layout_maya.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.Flush, self))
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))
end

function MayaBossView:ShowIndexCallBack()
	self:Flush()
end

function MayaBossView:ReleaseCallBack()
	if nil ~= self.layer_list then
		self.layer_list:DeleteMe()
		self.layer_list = nil
	end

	GlobalEventSystem:UnBind(self.scene_change)
end

-- 左边按钮点击
function MayaBossView:OnBtnLeft()
	local index = self.layer_list:GetCurPageIndex() or 0
	if index > 1 then
		self.layer_list:ChangeToPage(index - 1)
	end
	self:UpdateBtnState()
end

-- 右边按钮点击
function MayaBossView:OnBtnRight()
	local index = self.layer_list:GetCurPageIndex() or 0
	if index < self.layer_list:GetPageCount() then
		self.layer_list:ChangeToPage(index + 1)
	end
	self:UpdateBtnState()
end

function MayaBossView:UpdateBtnState()
	self.node_t_list.btn_left.node:setVisible(not (self.layer_list:GetCurPageIndex() == 1))
	self.node_t_list.btn_right.node:setVisible(not (self.layer_list:GetCurPageIndex() == self.layer_list:GetPageCount()))

end

function MayaBossView:CreateLayerList()
	local ph = self.ph_list.ph_layer_list
	local cell_num = #FieldNpcCfg[248].layer
	if nil == self.layer_list  then
		self.layer_list = BaseGrid.New() 
		self.layer_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.layer_list:CreateCells({w = ph.w, h = ph.h, itemRender = MayaBossView.LayerRender, ui_config = self.ph_list.ph_layer_item, cell_count = cell_num, col = 3, row = 1})
		self.node_t_list.layout_maya.node:addChild(grid_node, 100)
		self.layer_list:GetView():setPosition(ph.x, ph.y)		
		self.layer_list:SetSelectCallBack(BindTool.Bind(self.OnMayaSelectCallBack, self))
	end
end

function MayaBossView:OnPageChangeCallBack( ... )
	self:UpdateBtnState()
end

function MayaBossView:OnMayaSelectCallBack(item)
	self.select_index = item:GetIndex() + 1
	self:SetLayerComsume(self.select_index)
end


function MayaBossView:OnFlush(param_t)
	local boss_list = NewlyBossData.Instance:MayaBossData()
	self.layer_list:SetDataList(boss_list)
	self.layer_list:SelectCellByIndex(0)

	self:UpdateBtnState()
end

function MayaBossView:SetLayerComsume(index)
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local cfg = FieldNpcCfg[248].layer[index]
	local color = role_lv >= cfg.plv and "55ff00" or "ff0000"
	local lv_str = string.format(Language.Boss.CircleBossLv[2], color, cfg.plv .. "级")
	RichTextUtil.ParseRichText(self.node_t_list.rich_lv_need.node, lv_str, 19)	

	local item = ItemData.FormatItemData(cfg.consumes[1])
	if item then
		local name = ItemData.Instance:GetItemConfig(item.item_id).name
		-- local n = BagData.Instance:GetItemNumInBagById(item.item_id, nil)
		local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
		self.node_t_list.lbl_consume.node:setString("消耗屠魔令：")
		self.node_t_list.lbl_need_num.node:setString(n .. "/" .. item.num)
		self.node_t_list.lbl_need_num.node:setColor(n >= item.num and COLOR3B.GREEN or COLOR3B.RED)
	end
end

function MayaBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN or
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function MayaBossView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Boss.RareBossTips, Language.Boss.RareBossTipsName)
end

function MayaBossView:OnClickChallengeHandler()
	local data = self.layer_list:GetDataList()[self.select_index-1]
	
	local cfg = FieldNpcCfg[248].layer[self.select_index].consumes[1]
	cfg = ItemData.FormatItemData(cfg)
	
	if cfg == nil then return end
	local comsume = ShopData.GetItemPriceCfg(cfg.item_id)
	local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
	if n >= cfg.num then
		BossCtrl.CSChuanSongBossScene(data.type, data.boss_id)
	else
		if comsume then
			TipCtrl.Instance:OpenQuickTipItem(false, {cfg.item_id, comsume.price[1].type, 1})
		else
			TipCtrl.Instance:OpenGetStuffTip(cfg.item_id)
		end
	end
end

function MayaBossView:SceneChange()
	-- local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	-- if fuben_type == FubenType.PersonalBoss then 
	-- 	ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	-- end
end


MayaBossView.LayerRender = BaseClass(BaseRender)
local LayerRender = MayaBossView.LayerRender
function LayerRender:__init()
	self:AddClickEventListener()
end

function LayerRender:__delete()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end
end

function LayerRender:CreateChild()
	BaseRender.CreateChild(self)
	
	if self.boss_list == nil then
		local ph = self.ph_list.ph_bossnum_list
		self.boss_list = ListView.New()
		self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MayaBossView.MayaNumRender, nil, nil, self.ph_list.ph_bossnum_item)
		self.boss_list:SetItemsInterval(0)
		self.boss_list:SetJumpDirection(ListView.Top)
		self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectMayaNumCallback, self))
		self.view:addChild(self.boss_list:GetView(), 20)
		self.boss_list:GetView():setTouchEnabled(false)
	end
end

function LayerRender:SelectMayaNumCallback()
	-- body
end

function LayerRender:OnFlush()
	if nil == self.data then return end

	local layer_data = NewlyBossData.Instance:GetSceneData(self.data.scene_id, 6)
	local lv_data = NewlyBossData.Instance:GetBossLv(layer_data, 6)
	
	self.boss_list:SetDataList(lv_data)
	
	self.node_tree.img_layer_bg.node:loadTexture(ResPath.GetBigPainting("mysd_bg_" .. 5, false))
	self.node_tree.img_layer_num.node:loadTexture(ResPath.GetBoss("my_name_" .. self.data.layer))
end

function LayerRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetBoss("select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	
	self.view:addChild(self.select_effect, 999, 999)
end

MayaBossView.MayaNumRender = BaseClass(BaseRender)
local MayaNumRender = MayaBossView.MayaNumRender
function MayaNumRender:__init()
end

function MayaNumRender:__delete()
end

function MayaNumRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.lbl_boss_num.node)
end

function MayaNumRender:OnFlush()
	if nil == self.data then return end

	local num = NewlyBossData.Instance:GetBossNum(self.data.id_cfg, 6)
	local color = num > 0 and "55ff00" or "8b7c6a"
	local str = string.format(Language.Boss.MayaBossNum, color, self.data.boss_lv, num)
	
	RichTextUtil.ParseRichText(self.node_tree.lbl_boss_num.node, str, 18)
end

function MayaNumRender:CreateSelectEffect()
	
end

return MayaBossView