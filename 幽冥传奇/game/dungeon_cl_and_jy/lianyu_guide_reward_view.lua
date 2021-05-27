LianYuRewardView = LianYuRewardView or BaseClass(BaseView)
function LianYuRewardView:__init()
	 self.is_modal = true
	 self.is_any_click_close = true	
	  self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
	}
	 self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"fuben_cl_and_jy_ui_cfg", 9, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
end

function LianYuRewardView:__delete()
	-- body
end

function LianYuRewardView:ReleaseCallBack( )
	if self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil 
	end
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil 
	end
end

function LianYuRewardView:LoadCallBack( )
	if nil == self.reward_list then
		local ph = self.ph_list.ph_list--获取区间列表
		self.reward_list = ListView.New()
		self.reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, LianyuListItem, nil, nil, self.ph_list.ph_list_item_reward1)
		self.reward_list:SetItemsInterval(2)--格子间距
		self.reward_list:SetMargin(5)
		self.reward_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.latout_lianyu_get_reward.node:addChild(self.reward_list:GetView(), 20)
		--self.reward_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.reward_list:GetView():setAnchorPoint(0.5, 0.5)
	end
end

function LianYuRewardView:OnGetReward(index)
	-- local consume = PurgatoryFubenConfig.getAwardsType[index] and  PurgatoryFubenConfig.getAwardsType[index].consume
	-- if consume == nil then
	-- 	DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.get, index)
	-- 	ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
	-- 	return
	-- end
	-- if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= consume[1].count then
	-- 	DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.get, index)
	-- 	ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
	-- else
	-- 	self.alert = self.alert or Alert.New()
	-- 	self.alert:SetLableString(Language.Lianyu.TIPsShow)
	-- 	self.alert:SetOkString(Language.Common.Confirm)
	-- 	self.alert:SetCancelString(Language.Common.Cancel)
	-- 	self.alert:SetOkFunc(function ( ... )
	-- 		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	-- 		ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
	-- 	end)
	-- 	self.alert:Open()
	-- end
end

function LianYuRewardView:OpenCallBack()
	-- body
end

function LianYuRewardView:ShowIndexCallBack()
	self:Flush(index)
end

function LianYuRewardView:OnFlush()
	local max_bo = FubenData.Instance:GetLiyuMaxBo()
	if max_bo == 0 then
		max_bo = 1
	end
	-- local reward = DungeonData.Instance:GetMonsterNumByBo(max_bo)
	-- local show_list = {}
	-- for i,v in ipairs(reward or {}) do
	-- 	show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	-- end
	-- self.cell_list:SetDataList(show_list)

	-- local text= string.format(Language.Activity.CurWaveNum, max_bo)
	-- self.node_t_list.text_show.node:setString(text)

	-- for k, v in pairs(PurgatoryFubenConfig.getAwardsType) do
	-- 	local text = string.format(Language.Lianyu.GetRewardLingqu, v.times)
	-- 	self.node_t_list["btn_"..k].node:setTitleText(text)

	-- 	local consume = v.consume 

	-- 	local need_text = "" 
	-- 	if consume then
	-- 		local path = ResPath.GetCommon("gold")
	-- 		need_text = string.format(Language.Lianyu.Consume_Show, path, consume[1].count)
	-- 	end
	-- 	if self.node_t_list["rich_consume"..k] then
	-- 		RichTextUtil.ParseRichText(self.node_t_list["rich_consume"..k].node, need_text)
	-- 		XUI.RichTextSetCenter(self.node_t_list["rich_consume"..k].node)
	-- 	end
	-- end
	local bo_num = FubenData.Instance:GetLianyuCurBoNum()
	if bo_num == 0 then
		bo_num = 1
	end
	-- local score =  DungeonData.Instance:GetScore(last_level, last_bo)
	local score_level = PurgatoryFubenConfig.MonsterWaveNum[bo_num] and PurgatoryFubenConfig.MonsterWaveNum[bo_num].score_level or 1
	self.node_t_list.img_level_lianyu.node:loadTexture(ResPath.GetFubenCL("level_".. score_level))

	local data = PurgatoryFubenConfig.getAwardsType
	self.reward_list:SetDataList(data)


	--local total_bo = DungeonData.Instance:GetHadMonsterLevel(last_level)

	local text = string.format(Language.JiYanFubenShow.showDesc2, bo_num)
	
	RichTextUtil.ParseRichText(self.node_t_list.text_show.node, text)
	XUI.RichTextSetCenter(self.node_t_list.text_show.node)
end

function LianYuRewardView:CloseCallBack()
	-- body
end
LianyuListItem = LianyuListItem or BaseClass(BaseRender)
function LianyuListItem:__init( ... )
	-- body
end

function LianyuListItem:__delete( ... )
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil 
	end
end


function LianyuListItem:CreateChild( ... )
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell
	if self.cell == nil then
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x, ph.y - 5)
		self.view:addChild(self.cell:GetView(), 99)
		self.cell:GetView():setScale(0.88)
	end
	XUI.AddClickEventListener(self.node_tree.btn_get.node, BindTool.Bind1(self.GetReward,self), true)
end

function LianyuListItem:OnFlush()
	if self.data == nil then
		return
	end
	local text = ""
	if self.data.consume then
		local path = ResPath.GetCommon("gold")
	
		 text = string.format(Language.Bag.ComposeTip, path,"20,20", 1, 0, 0, "00ff00", self.data.consume[1].count)
	end
	RichTextUtil.ParseRichText(self.node_tree.text_consume.node, text)
	XUI.RichTextSetCenter(self.node_tree.text_consume.node)

	local bo_num = FubenData.Instance:GetLianyuCurBoNum()
	if bo_num == 0 then
		bo_num = 1
	end
	local reward = DungeonData.Instance:GetMonsterNumByBo(bo_num)
	self.cell:SetData({item_id = reward[1].id, num = 1, is_bind = 0})
	self.node_tree.img_level.node:loadTexture(ResPath.GetFubenCL("times".. self.data.times))
	local num = reward[1].count * self.data.times
	self.node_tree.text_num.node:setString("X"..num)
end


function LianyuListItem:GetReward()
	local consume = PurgatoryFubenConfig.getAwardsType[self.index] and  PurgatoryFubenConfig.getAwardsType[self.index].consume
	if consume == nil then
		DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.get, self.index)
		ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
		return
	end
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= consume[1].count then
		DungeonCtrl.SendOprateLianYuFubenReq(DUNGEONDATA_LIANYU_OPRATE_TYPE.get, self.index)
		ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
	else
		self.alert = self.alert or Alert.New()
		self.alert:SetLableString(Language.Lianyu.TIPsShow)
		self.alert:SetOkString(Language.Common.Confirm)
		self.alert:SetCancelString(Language.Common.Cancel)
		self.alert:SetOkFunc(function ( ... )
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			ViewManager.Instance:CloseViewByDef(ViewDef.LianyuReward)
		end)
		self.alert:Open()
	end
end
