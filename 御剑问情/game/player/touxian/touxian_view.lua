TouxianView = TouxianView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function TouxianView:__init()
	self.ui_config = {"uis/views/touxian_prefab","TouxianView"}
end

function TouxianView:__delete()

end

function TouxianView:ReleaseCallBack()
	self.cur_touxian = nil
	self.next_touxian = nil
	if self.stuff then
		self.stuff:DeleteMe()
		self.stuff = nil
	end
	self.maxhp = nil
	self.gongji = nil
	self.fangyu = nil
	self.n_maxhp = nil
	self.n_gongji = nil
	self.n_fangyu = nil
	self.has_touxian = nil
	self.has_n_touxian = nil
	self.cur_cap = nil
	self.next_cap = nil
	self.cap_need = nil
	self.skill_dec = nil
	self.stuff_num = nil
	self.stuff_obj = nil
	self.red_point = nil
	self.n_title_img = nil
	self.title_img = nil
	self.rank_text = nil
	self.yun_time = nil
	self.yun_per = nil
	self.hurt_per = nil
	self.n_rank_text = nil
	self.show_cur_level = nil

	RemindManager.Instance:UnBind(self.remind_change)
end

function TouxianView:LoadCallBack()
	self.cur_touxian = self:FindObj("CurTouxian")
	self.next_touxian = self:FindObj("NextTouxian")

	self.stuff = ItemCell.New()
	self.stuff_obj = self:FindObj("NeedItem")
	self.stuff:SetInstanceParent(self.stuff_obj)

	self.maxhp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")

	self.n_maxhp = self:FindVariable("HpN")
	self.n_gongji = self:FindVariable("GongjiN")
	self.n_fangyu = self:FindVariable("FangyuN")

	self.has_touxian = self:FindVariable("HasTouxian")
	self.has_n_touxian = self:FindVariable("HasNextTouxian")
	self.cur_cap = self:FindVariable("CurCap")
	self.next_cap = self:FindVariable("NextCap")
	self.cap_need = self:FindVariable("CapNeed")
	self.hurt_per = self:FindVariable("HurtPer")
	self.yun_per = self:FindVariable("YunPer")
	self.yun_time = self:FindVariable("YunTime")
	self.stuff_num = self:FindVariable("StuffNum")
	self.red_point = self:FindVariable("RedPoint")

	self.rank_text = self:FindVariable("Rank_Text")
	self.n_rank_text = self:FindVariable("Rank_Text_N")
	self.title_img = self:FindVariable("Title_Img")
	self.n_title_img = self:FindVariable("Title_Img_N")
	self.show_cur_level = self:FindVariable("ShowCurLevel")

	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickUp",
		BindTool.Bind(self.OnUpGrade, self))
	self:ListenEvent("OnClickBuy", 
		BindTool.Bind(self.OnClickBuy, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Touxian)
end


function TouxianView:OpenCallBack()
	self:Flush()
	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end


function TouxianView:CloseCallBack()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end
function TouxianView:ItemDataChangeCallback()
	self:Flush()
end

function TouxianView:OnFlush(param_list)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("rolejingjie_auto").other[1]
	self.hurt_per:SetValue(other_cfg.yazhi_add_hurt_per / 100)
	self.yun_per:SetValue(other_cfg.yazhi_xuanyun_trigger_rate / 100)
	self.yun_time:SetValue(other_cfg.yazhi_xuanyun_durations / 1000)
	local cur_touxian_level = TouxianData.Instance:GetTouxianLevel()
	local cur_touxian_cfg = TouxianData.Instance:GetTouxianCfg(cur_touxian_level)
	self.has_touxian:SetValue(cur_touxian_cfg ~= nil)
	if cur_touxian_cfg then
		self.maxhp:SetValue(cur_touxian_cfg.maxhp)
		self.gongji:SetValue(cur_touxian_cfg.gongji)
		self.fangyu:SetValue(cur_touxian_cfg.fangyu or 0)
		self.cur_touxian.text.text = cur_touxian_cfg.name
		self.cur_touxian.outline.effectColor = TouxianData.GetTouxianColor(cur_touxian_level)
		self.cur_cap:SetValue(CommonDataManager.GetCapability(cur_touxian_cfg))
		self.title_img:SetAsset(ResPath.GetLongxingLevelIcon(TouxianData.GetTouxianIcon(cur_touxian_level)))
		self.rank_text:SetValue(TouxianData.GetTouxianNum(cur_touxian_level))
		self.show_cur_level:SetValue(cur_touxian_level > 0)
	end
	local n_touxian_cfg = TouxianData.Instance:GetTouxianCfg(cur_touxian_level + 1)
	self.has_n_touxian:SetValue(n_touxian_cfg ~= nil)
	if n_touxian_cfg then
		self.n_maxhp:SetValue(n_touxian_cfg.maxhp)
		self.n_gongji:SetValue(n_touxian_cfg.gongji)
		self.n_fangyu:SetValue(n_touxian_cfg.fangyu or 0)
		self.next_touxian.text.text = n_touxian_cfg.name
		self.next_touxian.outline.effectColor = TouxianData.GetTouxianColor(cur_touxian_level + 1)
		self.next_cap:SetValue(CommonDataManager.GetCapability(n_touxian_cfg))
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		local str = "%d/%d"
		if role_cap < n_touxian_cfg.cap_limit then
			str = "<color=#fe3030>%d</color>/%d"
		else
			str = "<color=#0000f1>%d</color>/%d"
		end
		self.cap_need:SetValue(string.format(str, role_cap, n_touxian_cfg.cap_limit))
		str = "%d / %d"
		local num = ItemData.Instance:GetItemNumInBagById(n_touxian_cfg.stuff_id)
		if num < n_touxian_cfg.stuff_num then
			str = "<color=#fe3030>%d</color> / %d"
		else
			str = "<color=#0000f1>%d</color> / %d"
		end
		self.stuff_num:SetValue(string.format(str, num, n_touxian_cfg.stuff_num))
		self.stuff:SetData({item_id = n_touxian_cfg.stuff_id, num = 1})
		self.n_title_img:SetAsset(ResPath.GetLongxingLevelIcon(TouxianData.GetTouxianIcon(n_touxian_cfg.jingjie_level)))
		self.n_rank_text:SetValue(TouxianData.GetTouxianNum(n_touxian_cfg.jingjie_level))
	else
		self.stuff_num:SetValue("-- / --")
		self.stuff:SetData({})
		self.cap_need:SetValue(Language.Common.YiManJi)
	end
end

function TouxianView:OnClickBuy()
	local cur_touxian_level = TouxianData.Instance:GetTouxianLevel() or 0
	local n_touxian_cfg = TouxianData.Instance:GetTouxianCfg(cur_touxian_level + 1)
	if not n_touxian_cfg then
	    return
	end
  
	local time = TouxianData:GetTime()
	if time <= 0 then
		local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], n_touxian_cfg.stuff_id)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
		TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
		TouxianData:SetTime(Status.NowTime)
	else
		if Status.NowTime - time >= 30 then 
			local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], n_touxian_cfg.stuff_id)
			ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
			TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
			TouxianData:SetTime(Status.NowTime)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Cold)
	    end
	end
end

function TouxianView:OnUpGrade()
	TouxianCtrl.SendUpTouxian()
end

function TouxianView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.Touxian then
		self.red_point:SetValue(RemindManager.Instance:GetRemind(RemindName.Touxian) > 0)
	end
end