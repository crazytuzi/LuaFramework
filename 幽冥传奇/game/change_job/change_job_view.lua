ChangeJobView = ChangeJobView or BaseClass(XuiBaseView)

function ChangeJobView:__init()
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"change_job_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.texture_path_list = {"res/xui/hero_gold.png",}
	self:SetModal(true)
	self.title_img_path = ResPath.GetHeroGold("change_job_title")
end

function ChangeJobView:__delete()
end

function ChangeJobView:ReleaseCallBack()
	if self.job_list then
		self.job_list:DeleteMe()
		self.job_list = nil
	end
	if self.achieve_evt then
		GlobalEventSystem:UnBind(self.achieve_evt)
		self.achieve_evt = nil
	end
end

function ChangeJobView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:JobReceiveList()
		self.node_t_list.lookseeBtn.node:addClickEventListener(BindTool.Bind(self.ChangeJob, self))

		local ss =  ConfigManager.Instance:GetServerConfig("attr/ChangeJobAttrsConfig")[1][1][1]

		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local attrs_t = CommonDataManager.DelAttrByProf(prof,ss)
		local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
		for i,v in ipairs(title_attrs) do
			self.node_t_list["txt_show_" .. i].node:setString(v.type_str..":")
			self.node_t_list["txt_attr_" .. i].node:setString(v.value_str)  
		end
		self.achieve_evt = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE, BindTool.Bind(self.FlushList, self))
	end
end

function ChangeJobView:JobReceiveList()
	if nil == self.job_list then
		self.job_list = ListView.New()
		local ph = self.ph_list.ph_reward_list
		self.job_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, JobReceiveAttrRender, gravity, is_bounce, self.ph_list.ph_reward_item)
		self.job_list:SetItemsInterval(1)
		self.job_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layot_change_job.node:addChild(self.job_list:GetView(), 100)
		self:FlushList()
		local skill = ChangeJobConfig.skillDesc[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)][1]
		local item_cfg = ItemData.Instance:GetItemConfig(ChangeJobConfig.Awards[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)].id)
		local co = string.format("%06x", item_cfg.color)
		local colDec = string.format("{wordcolor;%s;%s}",co,item_cfg.name)
		local str = colDec..":"..skill
		RichTextUtil.ParseRichText(self.node_t_list.txt_skill.node,str,20,cc.c3b(0xff, 0xff, 0xff))
	end
end

function ChangeJobView:ChangeJob()
	ChangeJobCtrl.Instance:ChangeJobReq()
end
 
function ChangeJobView:FlushList()
	local job=  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_JOB_LEVEL)
	local cfg = ChangeJobData.Instance:GetChangeJobCfg()
	if cfg and self.job_list then
		self.job_list:SetDataList(cfg)
		local flag = 1
		for i,v in ipairs(cfg) do
			local achieve_finish = AchieveData.Instance:GetAwardState(v.index)
			if achieve_finish.finish ~= 1 then
				flag = 0
				break
			end
		end
		XUI.SetLayoutImgsGrey(self.node_t_list.lookseeBtn.node, flag <= 0, true)
	end
end

function ChangeJobView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChangeJobView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChangeJobView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChangeJobView:OnFlush(param_t, index)
	local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local str = string.format("team_bg_%s_%s",job,sex)
	local nextimg =string.format("team_bg_%s_%s",job+3,sex)
	self.node_t_list.img_now.node:loadTexture(ResPath.GetBigPainting(nextimg, true))
	self.node_t_list.img_next.node:loadTexture(ResPath.GetBigPainting(str, true))
	self.node_t_list.img_now.node:setScale(1.15)
	self.node_t_list.img_next.node:setScale(1.15)
	self.node_t_list.txt_now.node:setString(Language.HeroGold.nameList[job])
	self.node_t_list.txt_next.node:setString(Language.HeroGold.nameList[job+3])
	self:FlushList()
	for k,v in pairs(param_t) do
		if k == "recycle_success" then
			local ph = self.ph_list.ph_img_1
			self:SetShowPlayEff(72,ph.x,ph.y)
			XUI.SetLayoutImgsGrey(self.node_t_list.lookseeBtn.node, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_JOB_LEVEL) >0, true)
		end
	end
end

function ChangeJobView:SetShowPlayEff(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.node_t_list.layot_change_job.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, 0.15, false)
end


JobReceiveAttrRender = JobReceiveAttrRender or BaseClass(BaseRender)
function JobReceiveAttrRender:__init()
end

function JobReceiveAttrRender:__delete()
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end

end

function JobReceiveAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateDrawNode()
end

function JobReceiveAttrRender:OnFlush()
	if self.data == nil then return end
	if self.data and self.data.index then
		self.node_tree.img_bg.node:setOpacity(0)
		local achi_cfg = AchieveData.GetAchieveConfig(self.data.index)
		local achieve_all = achi_cfg[1].conds[1]
		if achi_cfg and achi_cfg[1]  then
			local achieve_finish = AchieveData.Instance:GetAwardState(self.data.index)
			self.draw_node:clear()
			local str
			if achieve_finish.finish == 1 then
				local x, y = self.node_tree.txt_achi.node:getPositionX(), 
				self.node_tree.txt_achi.node:getPositionY()
				local pos1 = cc.p(x, y - 12)
				local pos2 = cc.p(pos1.x + 360 , pos1.y)
				self.draw_node:drawSegment(pos1, pos2, 1.5, cc.c4f(0.894, 0.741, 0.137, 1))
				str = self.data.id.."."..achi_cfg[1].name.."("..achieve_all.count.."/"..achieve_all.count..")"
			else
				local num_tab = AchieveData.Instance:GetAchieveFinishCount(achieve_all.eventId)
				local count = num_tab and num_tab.count or 0
				str = self.data.id.."."..achi_cfg[1].name.."("..count.."/"..achieve_all.count..")"		
			end	
			RichTextUtil.ParseRichText(self.node_tree.txt_achi.node,str,22,cc.c3b(0xff, 0xff, 0xff))
		end
	end
end

function JobReceiveAttrRender:CreateDrawNode()
	self.draw_node = cc.DrawNode:create()
	self.view:addChild(self.draw_node,999)
	self.draw_node:clear()
end