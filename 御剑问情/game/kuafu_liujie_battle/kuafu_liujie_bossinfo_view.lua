KuafuLiuJieBossInfoView = KuafuLiuJieBossInfoView or BaseClass(BaseRender)
function KuafuLiuJieBossInfoView:__init()
	self.main_boss = self:FindObj("MainBoss")
	-- self.SecondaryBoss = self:FindObj("SecondaryBoss")
	self.main_boss_list = {}
	self.secondary_boss_list = {}
	self.item_list = {}
	self.monster_num_list = {}
	local main_city_cfg = KuafuGuildBattleData.Instance:GetCityShowItemCfg(0)
	for i=1,#main_city_cfg do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.main_boss)
		local data ={item_id = main_city_cfg[i]}
		item_cell:SetData(data)
		table.insert(self.main_boss_list,item_cell)
	end

	-- local secondary_boss_cfg = KuafuGuildBattleData.Instance:GetCityShowItemCfg(1)
	-- for i=1,#secondary_boss_cfg do
	-- 	local item_cell = ItemCell.New()
	-- 	item_cell:SetInstanceParent(self.SecondaryBoss)
	-- 	local data ={item_id = secondary_boss_cfg[i]}
	-- 	item_cell:SetData(data)
	-- 	table.insert(self.secondary_boss_list,item_cell)
	-- end
	self:ListenEvent("OnClickLog", BindTool.Bind1(self.OnClickLog, self))
	for i=1,6 do
		self.item_list[i] = KuafuLiuJieBossInfoRender.New(self:FindObj("Item" .. i))
		self.item_list[i]:SetIndex(i)
	end

	for i=1,5 do
		self.monster_num_list[i] = self:FindVariable("text_monster" .. i)
	end
    

	self.show_effect = self:FindVariable("ShowEffect")	
end

function KuafuLiuJieBossInfoView:__delete()
	for k,v in pairs(self.main_boss_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.secondary_boss_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.secondary_boss_list = {}
	self.main_boss_list = {}
	self.monster_num_list = {}
end

function KuafuLiuJieBossInfoView:OpenCallBack()
    KuafuGuildBattleCtrl.Instance:SendGuildBattleGetMonsterInfoReq()
end

function KuafuLiuJieBossInfoView:InitData()

end

function KuafuLiuJieBossInfoView:OnClickLog()
	KuafuGuildBattleCtrl.Instance:SendKuaFuLiuJieLogInfoReq()
end

function KuafuLiuJieBossInfoView:OnFlush()
	local num = KuafuGuildBattleData.Instance:GetBossNum()
	if num == nil then
		return
	end
	self.show_effect:SetValue(num > 0)
	for k,v in pairs(self.item_list) do
		v:SetData(num)
	end

    local monster_cfg = KuafuGuildBattleData.Instance:GetCrossGuildBattleMonsterInfo()
    for i=1,5 do
        local num = monster_cfg[i+1] or 0		
        self.monster_num_list[i]:SetValue(string.format(Language.KuafuGuildBattle.kfGuildMonsterRemind, num))
	end
end



KuafuLiuJieBossInfoRender = KuafuLiuJieBossInfoRender or BaseClass(BaseRender)
function KuafuLiuJieBossInfoRender:__init()
	self.remind_boss = self:FindVariable("remind_boss")
end

function KuafuLiuJieBossInfoRender:__delete()

end

function KuafuLiuJieBossInfoRender:SetIndex(index)
	self.index = index
end

function KuafuLiuJieBossInfoRender:SetData(data)
	self.remind_boss:SetValue(string.format(Language.KuafuGuildBattle.kfGuildBossRemind, data))
end