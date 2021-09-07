-- -----------------------------------------
-- 幻化收藏手册
-- hosr
-- -----------------------------------------
HandbookManager = HandbookManager or BaseClass(BaseManager)

function HandbookManager:__init()
	if HandbookManager.Instance then
		return
	end
	HandbookManager.Instance = self
	self.model = HandbookModel.New()

	-- 当前自动幻化id
	self.autoId = 0
	self.handbookTab = {}
	self.needStarShowId = 0 -- 需要做星星特效的id
	self.isChange = false -- 从收藏切换到升星

	self.no_speed_list = {} 	--屏蔽攻速的图鉴组合

	self.shopItemList = nil

	self:InitHandler()

	self.onUpdataSlowState = EventLib.New()
	self.onUpdateMergeState = EventLib.New()  --图鉴合成幻化果回调
	self.onUpdateMergeselect = EventLib.New()
end

function HandbookManager:RequestInitData()
	self.needStarShowId = 0
	self.isChange = false
	self.update_time_stemp = 0
	self.shopItemList = {}
	self:Send17100()
end

function HandbookManager:InitHandler()
    self:AddNetHandler(17100, self.On17100)
    self:AddNetHandler(17101, self.On17101)
    self:AddNetHandler(17102, self.On17102)
    self:AddNetHandler(17103, self.On17103)
    self:AddNetHandler(17104, self.On17104)
    self:AddNetHandler(17105, self.On17105)
    self:AddNetHandler(17106, self.On17106)
    self:AddNetHandler(17107, self.On17107)
    self:AddNetHandler(17108, self.On17108)
    self:AddNetHandler(17109, self.On17109)
    self:AddNetHandler(17110, self.On17110)
	  self:AddNetHandler(17111, self.On17111)
		self:AddNetHandler(17112, self.On17112)
		self:AddNetHandler(17113, self.On17113)
end

-- 请求图鉴
function HandbookManager:Send17100()
	self:Send(17100, {})
	self:Send(17111, {})
end

function HandbookManager:On17100(data)
	self.handbookTab = {}
	for i,v in ipairs(data.handbook_list) do
		local handbook = HandbookItemData.New()
		handbook:Update(v)
		self.handbookTab[v.id] = handbook
	end

	self.no_speed_list = {}
	for i,v in ipairs(data.ban_speed_set_list) do
		self.no_speed_list[v.set_id] = true
	end

	self.model:FormatData()
end

-- 图鉴收藏
function HandbookManager:Send17101(id, list)
	local data = {id = id, list = list}
	self:Send(17101, data)
end

function HandbookManager:On17101(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 更新图鉴
function HandbookManager:On17102(data)
	local handbook = self.handbookTab[data.id]
	if handbook == nil then
		handbook = HandbookItemData.New()
		handbook:Update(data)
		self.handbookTab[data.id] = handbook
		self.needStarShowId = handbook.id
	else
		local base = DataHandbook.data_base[handbook.id]
		if data.status == HandbookEumn.Status.Active and handbook.status == HandbookEumn.Status.InActive then
			self.model:ShowGetNew(BaseUtils.copytab(DataHandbook.data_base[handbook.id]))
		end
		if data.star_val > handbook.star_val or data.star_step > handbook.star_step or data.active_step > handbook.active_step then
			self.needStarShowId = handbook.id
		end
		if data.active_step == base.max_active_step then
			self.isChange = true
		end
		handbook:Update(data)
	end
	self.model:FormatMatch()
	EventMgr.Instance:Fire(event_name.handbook_infoupdate)
end

-- 图鉴升星
function HandbookManager:Send17103(id, list)
	self:Send(17103, {id = id, list = list})
end

function HandbookManager:On17103(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 设置自动幻化
function HandbookManager:Send17104(id)
	self:Send(17104, {id = id})
end

function HandbookManager:On17104(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		self.autoId = data.auto_book_id
	end
	EventMgr.Instance:Fire(event_name.handbook_autochange)
end

-- 幻化
function HandbookManager:Send17105(id)
	self:Send(17105, {id = id})
end

function HandbookManager:On17105(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 请求兑换商店列表
function HandbookManager:Send17106()
	self:Send(17106, {})
end

function HandbookManager:On17106(data)
	self.update_time_stemp = data.next_time
	self.shopItemList = data.store_items
	EventMgr.Instance:Fire(event_name.handbook_shopupdate)
end

-- 图鉴商店购买
function HandbookManager:Send17107(idx)
	self:Send(17107, {idx = idx})
end

function HandbookManager:On17107(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
	end
end

-- 分解碎片
function HandbookManager:Send17108(id)
	self:Send(17108, {id = id})
end

function HandbookManager:On17108(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 刷新图鉴商店
function HandbookManager:Send17109()
	self:Send(17109, {})
end

function HandbookManager:On17109(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 设置需求
function HandbookManager:Send17110(id, is_need)
	self:Send(17110, {id = id, is_need = is_need})
end

function HandbookManager:On17110(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 需求状态
function HandbookManager:Send17111()
	self:Send(17111, {})
end

function HandbookManager:On17111(data)
	self.model:InitNeedData(data)
	-- NoticeManager.Instance:FloatTipsByString(data.msg)
end

--屏蔽攻速
function HandbookManager:Send17112(id,flag)
	self:Send(17112, {set_id = id, flag = flag})
end

function HandbookManager:On17112(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.result == 1 then
        self.onUpdataSlowState:Fire()
    end
end


--图鉴合成幻化果
function HandbookManager:Send17113(handbook_id, item_id, list, attrId)
	  -- print("Send17113")
		local temp = {handbook_id = handbook_id, item_id = item_id, list = list, attr_id = attrId}
    self:Send(17113, temp)
end

function HandbookManager:On17113(data)
	  -- BaseUtils.dump(data,"on17113")
		NoticeManager.Instance:FloatTipsByString(data.msg)
		if data.result == 1 then
			  local currId = data.id
			  self.onUpdateMergeState:Fire(currId)
		end
end

-- ----------------------
-- ----------------------
function HandbookManager:GetDataById(id)
	return self.handbookTab[id]
end

function HandbookManager:GetMatchNumById(id)
	local val = self.model.matchTab[id]
	if val == nil then
		val = 0
	end
	return val
end

function HandbookManager:GetHandbookNum(effect_type)
	local num = 0
	for _, data in pairs(DataHandbook.data_base) do
		if data.effect_type == effect_type then
			num = num + 1
		end
	end
	return num
end

function HandbookManager:GetHandbookNumByActiveEffectType(active_effect_type)
	local num = 0
	for _, data in pairs(DataHandbook.data_attr) do
		if data.star == 2 and data.active_effect_type == active_effect_type then
			num = num + 1
		end
	end
	return num
end

function HandbookManager:GetHandbookNumByStarEffectType(star_effect_type)
	local num = 0
	for _, data in pairs(DataHandbook.data_attr) do
		if data.star == 2 and data.star_effect_type == star_effect_type then
			num = num + 1
		end
	end
	return num
end