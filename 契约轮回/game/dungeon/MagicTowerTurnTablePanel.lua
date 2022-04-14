--
-- @Author: LaoY
-- @Date:   2018-12-08 17:46:24
--
MagicTowerTurnTablePanel = MagicTowerTurnTablePanel or class("MagicTowerTurnTablePanel",BasePanel)
local MagicTowerTurnTablePanel = MagicTowerTurnTablePanel

function MagicTowerTurnTablePanel:ctor()
	self.abName = "dungeon"
	self.assetName = "MagicTowerTurnTablePanel"
	self.layer = "UI"

	self.use_background = true
	self.click_bg_close = false
	self.change_scene_close = true

	self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER
	self.model = DungeonModel:GetInstance()
	
	DungeonCtrl:GetInstance():RequestLotoInfo(self.dungeon_type)
end

function MagicTowerTurnTablePanel:dctor()
	if self.model_event_list then
		self.model:RemoveTabListener(self.model_event_list)
		self.model_event_list = {}
	end

	if self.turn_table then
		self.turn_table:destroy()
		self.turn_table = nil
	end

	if self.reward_item then
		self.reward_item:destroy()
		self.reward_item = nil
	end	
end

function MagicTowerTurnTablePanel:Open( )
	MagicTowerTurnTablePanel.super.Open(self)
end

function MagicTowerTurnTablePanel:LoadCallBack()
	self.nodes = {
		"btn_go","turn_con","text_num","text_time","text_tip","btn_close"
	}
	self:GetChildren(self.nodes)

	self.text_num_component = self.text_num:GetComponent('Text')
	self.text_time_component = self.text_time:GetComponent('Text')
	self.text_tip_component = self.text_tip:GetComponent('Text')

	self.text_tip_component.text = "Tips: Clear every 5 stages to get 1 chance"

	self.reward_item = GoodsIconSettor(self.child_transform)
	self.reward_item:UpdateSize(94)
	self.reward_item:SetPosition(213,83)
	self:AddEvent()
end

function MagicTowerTurnTablePanel:AddEvent()
	local function call_back(target,x,y)
		if self.turn_table then
			if self.turn_table:IsAction() then
				Notify.ShowText("Roulette in progress")
				return
			end
			-- self.turn_table:SetTurnToIndex(3,handler(self,self.OnTurnCallBack))
			DungeonCtrl:GetInstance():RequestLoto(self.dungeon_type)
		end
	end	
	AddClickEvent(self.btn_go.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)

	local function call_back(dungeon_type)
		if dungeon_type == self.dungeon_type then
			self:UpdateView()
		end
    end
    self.model_event_list = self.model_event_list or {}
    self.model_event_list[#self.model_event_list+1] = self.model:AddListener(DungeonEvent.LotoInfoUpdate, call_back)

    local function call_back(dungeon_type,hit)
    	if dungeon_type == self.dungeon_type then
	    	self.turn_table:SetTurnToIndex(hit,handler(self,self.OnTurnCallBack))
    	end
    end
    self.model_event_list[#self.model_event_list+1] = self.model:AddListener(DungeonEvent.LotoResult, call_back)
end

function MagicTowerTurnTablePanel:OnTurnCallBack(index)
	-- Notify.ShowText("222",index)
	self:UpdateTableHit()
	self:CheckIsEmpty()
end

function MagicTowerTurnTablePanel:CheckIsEmpty()
	if table.nums(self.info.hits) >= 8 then
		DungeonCtrl:GetInstance():RequestLotoInfo(self.dungeon_type)
	end
end

function MagicTowerTurnTablePanel:OpenCallBack()
	self:UpdateView()
end

function MagicTowerTurnTablePanel:UpdateInfo()
	local data = self.model.dungeon_info_list[self.dungeon_type];
    if not data then
        return;
    end
    local info = data.info;
	if not info then
		return
	end
	local str = string.format("Lucky attempt: <color=#ffec15>%s</color>",info.loto_times)
	self.text_num_component.text = str
end

function MagicTowerTurnTablePanel:UpdateView( )
	self:UpdateInfo()
	local info = self.model.loto_info[self.dungeon_type]
	if not info then
		return
	end
	self.info = info

	local str = string.format("Round: %s",info.pool)
	self.text_time_component.text = str

	if not self.turn_table then
		self.turn_table = TurnTable(self.turn_con)
		self.turn_table:SetPointer("dungeon_image","img_pointer")
	end
	local cf = Config.db_dunge_magic_loto[info.pool]
	if not cf then
		return
	end

	local data = {}
	local reward_list = String2Table(cf.reward)
	for i=1,#reward_list do
		local reward = reward_list[i]
		data[i] = {reward[2],reward[3]}
	end
	self.turn_table:SetData(data,160,118)
	
	local show = String2Table(cf.show)
	self.reward_item:UpdateIconByItemIdClick(show[1],show[2])
	
	if self.turn_table:IsAction() then
		return
	end
	self:UpdateTableHit()
end

function MagicTowerTurnTablePanel:UpdateTableHit()
	local item_list = self.turn_table:GetItemList()
	for k,item in pairs(item_list) do
		item:SetHaveGetVisible(self:IsHit(item.index))
	end
end

function MagicTowerTurnTablePanel:IsHit(item_index)
	for k,index in pairs(self.info.hits) do
		if index == item_index then
			return true
		end
	end
	return false
end

function MagicTowerTurnTablePanel:CloseCallBack(  )

end