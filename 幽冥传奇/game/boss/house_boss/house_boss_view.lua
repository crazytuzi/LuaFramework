local HouseBossView = BaseClass(SubView)

function HouseBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
    	{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 4, {0}},
	}
end

function HouseBossView:__delete()
end

function HouseBossView:LoadCallBack(index, loaded_times)
	self.tab_list = nil
	self.index = 1
	self.enter_scene = 0
	self:CreateVipTabList()
	self:CreateHouseBossListItem()
	
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.OnUpdateBossData, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
end

function HouseBossView:ShowIndexCallBack()
	self:Flush()
end

function HouseBossView:ReleaseCallBack()
	if self.tab_list then 
		self.tab_list:DeleteMe()
		self.tab_list = nil 
	end
	if self.house_boss_item then 
		self.house_boss_item:DeleteMe()
		self.house_boss_item = nil 
	end
	GlobalEventSystem:UnBind(self.scene_change)
end


function HouseBossView:CreateVipTabList()
	if nil ~= self.tab_list then
		return
	end

	local ph = self.ph_list.ph_house_tab_list
	self.tab_list = ListView.New()
	self.tab_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, HouseBossView.HouseTabRender, nil, nil, self.ph_list.ph_house_tab_item)
	self.tab_list:SetItemsInterval(2)
	self.tab_list:SetJumpDirection(ListView.Top)
	self.tab_list:SetSelectCallBack(BindTool.Bind(self.SelectTabCallback, self))
	self.node_t_list.layout_house_boss.node:addChild(self.tab_list:GetView(), 20)
end

function HouseBossView:CreateHouseBossListItem()
	if nil == self.house_boss_item then
		local ph = self.ph_list.ph_house_item_list
		self.house_boss_item = ListView.New()
		self.house_boss_item:Create(ph.x, ph.y, ph.w, ph.h, nil, WildBossItemRender, nil, nil, self.ph_list.ph_house_item)
		self.house_boss_item:SetItemsInterval(2)
		self.house_boss_item:SetJumpDirection(ListView.Top)
		self.house_boss_item.item_render:SetBtnClickCallBack(BindTool.Bind(self.ButtonClickCallback, self))
		self.node_t_list.layout_house_boss.node:addChild(self.house_boss_item:GetView(), 20)
	end
end

function HouseBossView:OnFlush(param_t)
	local tab_list = HouseBossData.Instance:GetVipTabList()
	self.tab_list:SetDataList(tab_list)
	self.tab_list:SelectIndex(1)
	self:FlushHousBossData()
end

function HouseBossView:OnUpdateBossData()
	self:FlushHousBossData()
end

function HouseBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_VIP_GRADE then 
		self:FlushHousBossData()
	end
end

function HouseBossView:FlushHousBossData()
	local boss_list = HouseBossData.Instance:GetHouseBossList(self.index)
	self.house_boss_item:SetDataList(boss_list)
end

function HouseBossView:SelectTabCallback(item)
	if self.index == item.index then return end
	local boss_list = HouseBossData.Instance:GetHouseBossList(item.index)
	self.house_boss_item:SetDataList(boss_list)
	self.house_boss_item:SetJumpDirection(ListView.Top)
	self.index = item.index
end

function HouseBossView:SceneChange()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.enter_scene then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end

function HouseBossView:ButtonClickCallback(item)
	local data = item:GetData()
	self.enter_scene = data.scene_id
end




HouseBossView.HouseTabRender = BaseClass(BaseRender)
local HouseTabRender = HouseBossView.HouseTabRender

function HouseTabRender:__init()
end

function HouseTabRender:__delete()
end

function HouseTabRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_can_enter.node:setVisible(false)
	local pos_x, pos_y = self.node_tree.img_can_enter.node:getPosition()
	self.txt_remind_link = RichTextUtil.CreateLinkText(Language.Common.RemindSet, 20, COLOR3B.GREEN)
	self.txt_remind_link:setPosition(pos_x, pos_y)
	self.view:addChild(self.txt_remind_link, 50)
	self.txt_remind_link:setVisible(false)
	XUI.AddClickEventListener(self.txt_remind_link, BindTool.Bind(self.OnClickLinkText, self), true)
end

function HouseTabRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_can_enter.node:setVisible(self.data.remind and self.data.index ~= 1)
	self.txt_remind_link:setVisible(self.index == 1 and HouseBossData.IsVipCondMatch(self.index))
	if self.data.remind then 
		local fade_in = cc.FadeIn:create(0.6)
		local fade_out = cc.FadeOut:create(1)
		local sequence = cc.Sequence:create(fade_out, fade_in)
		local forever = cc.RepeatForever:create(sequence)
		self.node_tree.img_can_enter.node:runAction(forever)
	end
	self.node_tree.img_vip_bg.node:loadTexture(ResPath.GetBoss("boss_house_vip_" .. self.data.index))
end

function HouseTabRender:SetSelect(is_select)
	BaseRender.SetSelect(self, is_select)
	if self.node_tree.img_can_enter then 
		self.node_tree.img_can_enter.node:setVisible(not is_select)
	end
	if self.txt_remind_link then
		self.txt_remind_link:setVisible(is_select and HouseBossData.IsVipCondMatch(self.index))
	end
end

function HouseTabRender:OnClickLinkText()
	local boss_list = HouseBossData.Instance:GetHouseBossRemindList(self.index)
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = boss_list})
end

return HouseBossView