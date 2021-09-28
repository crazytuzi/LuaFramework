LongXingView = LongXingView or BaseClass(BaseView)

local GRID_NUM = 30

function LongXingView:__init()
	self.ui_config = {"uis/views/longxing_prefab", "LongXingView"}
	self.play_audio = true
	self.grid_cell_list = {}
end

function LongXingView:__delete()
end

function LongXingView:ReleaseCallBack()

	if self.grid_cell_list then
		for k,v in pairs(self.grid_cell_list) do
			v:DeleteMe()
		end
	end
	self.grid_cell_list = {}

	--清理对象和变量
	self.titl_text = nil
	self.zuanshi_num = nil
	self.ishide_upbtn = nil
	self.xiaoguo_text = nil
	self.zhanli_num = nil
	self.yidong_num = nil
	self.next_num = nil
	self.leiji_num = nil
	self.is_complete = nil
	self.grid_list = nil
	self.my_rawimage = nil
	self.my_image_res = nil
	self.my_image_state = nil
	self.play_img = nil
	self.upgrade_btn = nil
	self.show_play = nil
	self.title_img = nil
	self.upgrade_btn_text = nil
	self.show_red = nil
	self.rank_text = nil
	self.is_gray = nil
	self.display = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function LongXingView:LoadCallBack()
	self.titl_text = self:FindVariable("Title_Text")
	self.zuanshi_num = self:FindVariable("Zuanshi_Num")
	self.ishide_upbtn = self:FindVariable("IsHide_UpBtn")
	self.xiaoguo_text = self:FindVariable("Xiaoguo_Text")
	self.zhanli_num = self:FindVariable("Zhanli_Num")
	self.yidong_num = self:FindVariable("Yidong_Num")
	self.next_num = self:FindVariable("Next_Num")
	self.leiji_num = self:FindVariable("Leiji_Num")
	self.is_complete = self:FindVariable("IsComplete")
	self.show_play = self:FindVariable("Show_Play")
	self.title_img = self:FindVariable("Title_Img")
	self.upgrade_btn_text = self:FindVariable("UpgradeBtn_Text")
	self.show_red = self:FindVariable("Show_Red")
	self.rank_text = self:FindVariable("Rank_Text")
	self.is_gray = self:FindVariable("IsGray")

	self.display = self:FindObj("Display")

	self.upgrade_btn = self:FindObj("UpgradeBtn")
	self.grid_list = self:FindObj("GridList")
	for i=1,GRID_NUM do
		local gird_obj = self.grid_list.transform:FindHard("Grid_" .. i)
		PrefabPool.Instance:Load(AssetID("uis/views/longxing_prefab", "LongXingGridCell"), function(prefab)
			if nil == prefab then
				return
			end

			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			obj.transform:SetParent(gird_obj.transform, false)
			local cell = LongXingGridCell.New(obj)
			self.grid_cell_list[i] = cell
			local data = {}
			if i == GRID_NUM then
				data = LongXingData.Instance:GetRewardListByGrid(GRID_NUM + LongXingData.Instance:GetCurrloop() % 2) or LongXingData.Instance:GetMaxReward()
			else
				data = LongXingData.Instance:GetRewardListByGrid(i)
			end
			self.grid_cell_list[i]:SetData(data)
		end)
	end

	--头像相关
	self.my_image_res = self:FindVariable("MyImageRes")
	self.my_image_state = self:FindVariable("MyImageState")				--是否显示自己的默认头像
	self.my_rawimage = self:FindObj("MyRawImage")
	self.play_img = self:FindObj("PlayImg")


	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickUpgrade",BindTool.Bind(self.ClickUpgrade,self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.ClickHelp,self))

	self:Flush()

end

function LongXingView:OpenCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "longxing_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.LongXingRemind)
	end
	self:SetMyHead()
end

function LongXingView:OnFlush()
	local info = LongXingData.Instance:GetSCMolongInfo()

	for i=1,GRID_NUM do
		if self.grid_cell_list[i] then
			local data = LongXingData.Instance:GetRewardListByGrid(i)
			if i == GRID_NUM then
				data = LongXingData.Instance:GetRewardListByGrid(GRID_NUM + LongXingData.Instance:GetCurrloop()) or LongXingData.Instance:GetMaxReward()
			end
			self.grid_cell_list[i]:SetData(data)
		end
	end
	self.title_img:SetAsset(ResPath.GetLongxingLevelIcon(math.ceil(info.rank_grade / 10)))
	self.rank_text:SetValue(info.rank_grade)
	self.leiji_num:SetValue(info.accumulate_consume_gold)
	local rank_cfg = LongXingData.Instance:GetRankByGrade(info.rank_grade)
	self.titl_text:SetValue(rank_cfg.rank_name)
	self.zhanli_num:SetValue(rank_cfg.war_value)

	if info.rank_cumulate_gold >= rank_cfg.cumulate_gold then
		self.upgrade_btn.button.interactable = true
		self.show_red:SetValue(true)
		if info.rank_grade >= LongXingData.Instance:GetRankMaxGrade() then
			self.upgrade_btn.button.interactable = false
			self.upgrade_btn_text:SetValue(Language.Common.YiManJi)
			self.show_red:SetValue(false)
		else
			self.upgrade_btn_text:SetValue(Language.LongXing.ShengJi)
			self.upgrade_btn.button.interactable = true
			self.show_red:SetValue(true)
		end
		self.zuanshi_num:SetValue("<color=#0000f1>"..info.rank_cumulate_gold.."</color>".."/"..rank_cfg.cumulate_gold)
	else
		self.upgrade_btn.button.interactable = false
		self.show_red:SetValue(false)
		self.zuanshi_num:SetValue("<color=#fe3030>"..info.rank_cumulate_gold.."</color>".."/"..rank_cfg.cumulate_gold)

	end
	self.is_gray:SetValue(self.upgrade_btn.button.interactable)
	self.xiaoguo_text:SetValue(rank_cfg.value_percent)


	--判断是否是第一步
	if info.total_move_step == 0 then
		self.show_play:SetValue(false)
		self.is_complete:SetValue(info.curr_loop > 1 or false)
	else
		self.is_complete:SetValue(false)
		self.show_play:SetValue(true)
		self.play_img.transform.position = self.grid_list.transform:FindHard("Grid_" .. info.total_move_step).transform.position
	end

	local today_move_step = info.today_move_step<=0 and 0 or info.today_move_step
	local next_need_gold = 0
	if today_move_step >= 5 then
		next_need_gold = 0
	else
		next_need_gold = LongXingData.Instance:GetMoveByStep(today_move_step>=5 and 5 or today_move_step+1).consume_gold - info.today_consume_gold
	end

	self.yidong_num:SetValue(5-info.today_move_step)
	self.next_num:SetValue(next_need_gold)

	local index = GRID_NUM + LongXingData.Instance:GetCurrloop() % 2
	local longxing_cfg = LongXingData.Instance:GetRewardListByGrid(index)
	self:SetModel(longxing_cfg.model_show)
end

function LongXingView:CloseWindow()
	self:Close()
end

function LongXingView:ClickUpgrade()
	-- print_log("?>>>>>>>>>>>")
	LongXingCtrl.Instance:SendMolongRankInfoReq()
end

function LongXingView:ClickHelp()
	local tip_id = 241
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

--设置我的头像
function LongXingView:SetMyHead()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = main_role_vo.role_id
	local prof = main_role_vo.prof
	local sex = main_role_vo.sex
	CommonDataManager.NewSetAvatar(role_id, self.my_image_state, self.my_image_res, self.my_rawimage, sex, prof, false)
end

function LongXingView:SetModel(model_show)
	if self.model == nil then
		self.model = RoleModel.New("free_gift_panel")
		self.model:SetDisplay(self.display.ui3d_display)
	end
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	local display_name = "free_gift_panel"
	if string.find(bundle, "goddess") ~= nil then
		self.model:SetTrigger("show_idle_1")
	elseif string.find(bundle, "mount") ~= nil then
		self.model:SetPanelName("longxing_mount_model")
		-- self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif string.find(bundle, "wing") ~= nil then
		self.model:SetPanelName("longxing_wing_model")
		-- self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	end
	self.model:SetMainAsset(bundle, asset)
end

---------------------------龙行天下格子--------------------------
LongXingGridCell = LongXingGridCell or BaseClass(BaseCell)

function LongXingGridCell:__init()
	self.show_reward = self:FindVariable("Show_Reward")
	self.show_bushu = self:FindVariable("Show_Bushu")
	self.show_fanli = self:FindVariable("Show_Fanli")
	self.show_play = self:FindVariable("Show_Play")
	self.bushu_num = self:FindVariable("Bushu_Num")
	self.fanli_num = self:FindVariable("Fanli_Num")

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("Reward_Item"))
	self.reward_item:GetTransForm():SetLocalScale(0.6, 0.6, 0.6)

end

function LongXingGridCell:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

end

-- function LongXingGridCell:SetIndex(index)
-- 	self.index = index
-- end

function LongXingGridCell:OnFlush()
	local today_move_step = LongXingData.Instance:GetTotalMoveStep()
	self.bushu_num:SetValue(self.data.grid)

	if self.data.reward_item then
		self.reward_item:SetData(self.data.reward_item)
	end
	if self.data.fanli_rate > 0 then
		self.fanli_num:SetValue(self.data.fanli_rate)
	end

	if self.data.grid <= today_move_step then
		self.show_reward:SetValue(false)
		self.show_fanli:SetValue(false)
	else
		self.show_reward:SetValue(self.data.reward_item~=nil)
		self.show_fanli:SetValue(self.data.fanli_rate>0)
	end
end
