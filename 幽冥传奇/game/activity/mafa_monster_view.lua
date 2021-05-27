MaFaMonsterView = MaFaMonsterView or BaseClass(XuiBaseView)

function MaFaMonsterView:__init()
	self.is_modal = true
	self.can_penetrate = false
	self.config_tab = {
		{"mafa_explore_ui_cfg", 6, {0}},
	}
	self.desc = ""
	self.reward_pos = 0
	self.data = {} 
end

function MaFaMonsterView:__delete()

end

function MaFaMonsterView:ReleaseCallBack()

end

function MaFaMonsterView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self.node_t_list.txt_ingnore.node:addClickEventListener(BindTool.Bind(self.IngnoreBoss, self))
		self.node_t_list.btn_kill.node:addClickEventListener(BindTool.Bind(self.FigthtBoss, self))
	end
end

function MaFaMonsterView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaMonsterView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MaFaMonsterView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function MaFaMonsterView:SetData(data)
	self.data = data 
end
--刷新界面
function MaFaMonsterView:OnFlush(param_t, index)
	local consume = self.data.passConsumes
	if consume ~= nil then
		local consume_type = consume[1] and consume[1].type
		local consume_count = consume[1] and consume[1].count
		local consume_id = consume[1] and consume[1].id
		local config = {}
		if consume_type > 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(consume_type)
			config = ItemData.Instance:GetItemConfig(virtual_item_id)
		else
			config = ItemData.Instance:GetItemConfig(consume_id)
		end 
		if config ~= nil then
			self.node_t_list.txt_consume.node:setString(string.format(Language.AllDayActivity.ConsumeMoney, config.name, consume_count))
		end
	end
	local moster_id = self.data.boss and self.data.boss[1] and self.data.boss[1].monsterId
	local boss_cfg = BossData.GetMosterCfg(moster_id)
	if boss_cfg ~= nil then
		local name = boss_cfg.name
		local txt = string.format(self.data.desc, name)
		RichTextUtil.ParseRichText(self.node_t_list.rich_text.node, txt, 24)
	end
end

function MaFaMonsterView:IngnoreBoss()
	ActivityCtrl.Instance:ReqCustomsOprate(1)
end

function MaFaMonsterView:FigthtBoss()
	ActivityCtrl.Instance:ReqCustomsOprate(2)
end