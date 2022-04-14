--
-- @Author: LaoY
-- @Date:   2019-03-13 22:01:03
-- buff管理

BuffManager = BuffManager or class("BuffManager",BaseManager)

-- 测试特效id
-- 120110001
-- 120210001

-- buff 外在表现类型
BuffManager.ExteriorType = {
	Null = 0,
	Image = 1,
	Effect =2,
	ImageAndEffect = 3,
}

function BuffManager:ctor()
	BuffManager.Instance = self
	self:Reset()

	UpdateBeat:Add(self.Update,self,3)
end

function BuffManager:Reset()
	self.buff_list = {}
end

function BuffManager.GetInstance()
	if BuffManager.Instance == nil then
		BuffManager()
	end
	return BuffManager.Instance
end

function BuffManager:AddBuff(object_id,p_buff)
	local object = SceneManager:GetInstance():GetObject(object_id)
	if not object then
		return
	end
	self.buff_list[object_id] = self.buff_list[object_id] or {}
	local buff_info_list = self.buff_list[object_id]
	-- if buff_info_list[p_buff.id] then
	-- 	buff_info_list[p_buff.id]:destroy()
	-- 	buff_info_list[p_buff.id] = nil
	-- end
	local buff = Buff(object_id,p_buff)
	buff_info_list[buff.id] = buff
	self:ObjectShowBuffImage(object_id)
end

function BuffManager:RemoveBuff(object_id,buff_id)
	if not self.buff_list[object_id] or not self.buff_list[object_id][buff_id] then
		return
	end
	local buff = self.buff_list[object_id][buff_id]

	-- 如果删除某个buff，部分需要特殊处理 最后要删除
	-- todo
	-- 执行特殊处理前，要先删除要移除的buff
	self.buff_list[object_id][buff_id] = nil
	if buff:IsShowImg() then
		self:ObjectShowBuffImage(object_id)
	end
	buff:destroy()
end

-- 场景对象 同时最多显示一张buff图片 最新添加的那个
function BuffManager:ObjectShowBuffImage(object_id)
	local buff_info_list = self.buff_list[object_id]
	if not buff_info_list then
		return
	end

	local new_add_buff
	local new_add_buff_time
	local cur_show_buff
	for id,buff in pairs(buff_info_list) do
		if buff:IsShowImg() then
			cur_show_buff = buff
		end
		if buff:IsShowImageType() and (not new_add_buff_time or buff.add_time >  new_add_buff_time) then
			new_add_buff_time = buff.add_time
			new_add_buff = buff
		end
	end
	local object = SceneManager:GetInstance():GetObject(object_id)
	if object then
		object:HideBuffImage()
	end
	if new_add_buff then
		if cur_show_buff then
			cur_show_buff:SetImageState(false)
		end
		new_add_buff:ShowImage()
	end
end

function BuffManager:RemoveObject(object_id)
	if not object_id then
		return
	end
	local buff_info_list = self.buff_list[object_id]
	self.buff_list[object_id] = nil
	if buff_info_list then
		for k,buff in pairs(buff_info_list) do
			buff:destroy()
		end
	end
end

function BuffManager:UpdateBuff(object_id,p_buff)
	local buff = self.buff_list[object_id] and self.buff_list[object_id][p_buff.id]
	if not buff then
		Yzprint('--LaoY BuffManager.lua,line 117--',object_id)
		self:AddBuff(object_id,p_buff)
	else
		buff:UpdateBuff(p_buff)
		self:ObjectShowBuffImage(object_id)
	end
end

function BuffManager:Update(deltaTime)
	local del_tab
	for object_id,buff_list in pairs(self.buff_list) do
		for id,buff in pairs(buff_list) do
			if buff:IsEnd() then
				del_tab = del_tab or {}
				del_tab[#del_tab+1] = {object_id = object_id,id = id}
			end
		end
	end

	-- 到期直接删除
	if del_tab then
		for k,v in pairs(del_tab) do
			local object_data = SceneManager:GetInstance():GetObjectInfo(v.object_id)
			if object_data then
				object_data:RemoveBuff(v.id)
			end
		end
	end
end