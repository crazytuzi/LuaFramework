ShengXiaoPieceView = ShengXiaoPieceView or BaseClass(BaseRender)

function ShengXiaoPieceView:__init()
	--获取组件
	self:ListenEvent("OpenSkillView", BindTool.Bind(self.OpenSkillView, self))
	self:ListenEvent("OpenTearsueView", BindTool.Bind(self.OpenTearsueView, self))
	self:ListenEvent("OpenBagView", BindTool.Bind(self.OpenBagView, self))
	self:ListenEvent("OnSelectMoveType", BindTool.Bind(self.OnSelectMoveType, self))
	self:ListenEvent("OnSelectNomalType", BindTool.Bind(self.OnSelectNomalType, self))
	self:ListenEvent("OnPageDown", BindTool.Bind(self.OnPageDown, self))
	self:ListenEvent("OnPageUp", BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OpenDetail", BindTool.Bind(self.OpenDetail, self))
	self:ListenEvent("CloseDetail", BindTool.Bind(self.CloseDetail, self))
	self:ListenEvent("OnTakeOffPiece", BindTool.Bind(self.OnTakeOffPiece, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:InitDetailView()

	self.cur_chapter = ShengXiaoData.Instance:GetMaxChapter()
	self.is_move_state = false
	self.select_piece_value = 0
	self.show_anim_count = 0
	self.skill_icon = self:FindObj("SkillIcon")
	self.skill_path = self:FindVariable("skill_path")
	self.skill_name = self:FindVariable("skill_name")

	self.group_name_list = {}
	self.group_image_list = {}
	self.capbility_list = {}
	self.show_acitve_list = {}
	self.chapter_name = self:FindVariable("chapter_name")
	self.show_black = self:FindVariable("show_black")
	self.cur_chapter_value = self:FindVariable("cur_chapter")
	self.max_chapter_value = self:FindVariable("max_chapter")
	self.show_piece_detail = self:FindVariable("show_piece_detail")
	self.extra_add = self:FindVariable("extra_add")
	self.show_extra_add = self:FindVariable("show_extra_add")

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.red_point_list = {
		[RemindName.ErnieView] = self:FindVariable("ShowErnieRedPoint"),
	}
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	for i = 1, 3 do
		self.group_name_list[i] = self:FindVariable("group_name_" .. i)
		self.group_image_list[i] = self:FindVariable("group_image_" .. i)
		self.capbility_list[i] = self:FindVariable("capbility" .. i)
		self.show_acitve_list[i] = self:FindVariable("show_active_" .. i)
		self:ListenEvent("OpenCombine" .. i, BindTool.Bind(self.OpenCombine, self, i))
	end

	self.piece_list = {}
	self.piece_content = self:FindObj("PieceContent")
	for i = 1, 7 do
		local group_obj = self.piece_content:FindObj("Group" .. i)
		self.piece_list[i] = {}
		for j = 1, 7 do
			if nil ~= group_obj:FindObj("piece" .. j) then
				self.piece_list[i][j] = PieceItem.New()
				self.piece_list[i][j]:SetInstanceParent(group_obj:FindObj("piece" .. j))
				self.piece_list[i][j].parent_view = self
				if i > 4 then
					self.piece_list[i][j]:SetData({x = j + i - 4, y = i})
				else
					self.piece_list[i][j]:SetData({x = j, y = i})
				end
			end
		end
	end
	self.move_data1 = nil
	self.move_data2 = nil
	self.show_detail_data = nil
	if self.anim_countdown == nil then
		self.anim_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowAnim, self, 1), 1)
	end
	RemindManager.Instance:Fire(RemindName.ErnieView)
end

function ShengXiaoPieceView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShengXiaoPieceView:InitDetailView()
	self.cur_piece_path = self:FindVariable("cur_piece_path")
	self.cur_piece_name = self:FindVariable("cur_piece_name")

	--获取变量
	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.bao_ji = self:FindVariable("Baoji")
	self.ming_zhong = self:FindVariable("Mingzhong")
	self.kang_bao = self:FindVariable("KangBao")
	self.shan_bi = self:FindVariable("Shanbi")

	self.show_baoji = self:FindVariable("ShowBaoji")
	self.show_fangyu = self:FindVariable("ShowFangyu")
	self.show_gongji = self:FindVariable("ShowGongji")
	self.show_hp = self:FindVariable("ShowHp")
	self.show_kangbao = self:FindVariable("ShowKangBao")
	self.show_mingzhong = self:FindVariable("ShowMingzhong")
	self.show_shanbi = self:FindVariable("ShowShanbi")

	self.detail_cap = self:FindVariable("detail_cap")

	self.total_cap = self:FindVariable("total_cap")
end

function ShengXiaoPieceView:ShowAnim(index)
	if index > 3 then return end
	local show_anim_list = ShengXiaoData.Instance:GetShowAnimListByChatper(self.cur_chapter)
	if self.has_light then
		self.has_light = false
		self.show_anim_count = (self.show_anim_count + 1) % 3
		self:FLushCellAnim(false)
	elseif show_anim_list and show_anim_list[self.show_anim_count] then
		self.has_light = true
		self:FLushCellAnim(true, show_anim_list[self.show_anim_count])
	else
		self.show_anim_count = (self.show_anim_count + 1) % 3
		self:ShowAnim(index + 1)
	end
end

function ShengXiaoPieceView:__delete()
	self.move_data1 = nil
	self.move_data2 = nil
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				v1:DeleteMe()
				v1 = nil
			end
		end
	end
	if self.anim_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.anim_countdown)
		self.anim_countdown = nil
	end
	self.show_detail_data = nil
	self.move_data1 = nil
	self.move_data2 = nil
	self.select_piece_value = 0
	self.red_point_list = {}
	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ShengXiaoPieceView:FlushPieceView()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			v1:OnFlush()
		end
	end
	self.total_cap:SetValue(self:CalculateTotalCap())
end
--灵珠+组合+技能+守护瑞兽加成的总战力
function ShengXiaoPieceView:CalculateTotalCap()
	local totalCap = 0		--用于储存需要返回的总战力
	--计算灵阵中所有灵珠的战力加成
	local ROW_COUNT = 7		--灵阵行数
	local COL_COUNT = 7		--灵阵列数
	for x = 1,COL_COUNT do
		for y = 1,ROW_COUNT do
			local quality = ShengXiaoData.Instance:GetTianXianInfoByChapter(x,y,self.cur_chapter)				--获得对应位置灵珠的品质（1~4）
			local detail_cfg = ShengXiaoData.Instance:GetBeadCfg(quality)
			local cap = CommonDataManager.GetCapability(detail_cfg)												--获得灵珠的战力
			totalCap = totalCap + cap																			--累加灵珠的战力到总战力中
		end
	end

	--计算已经激活的组合的战力加成
	local actve_data_list = ShengXiaoData.Instance:GetActiveListByChatper(self.cur_chapter)  					--获得当前组合激活的情况
	for i = 1, 3 do
		--如果组合已激活
		if actve_data_list[i] ~= 0 then
			local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_chapter - 1) * 3 + i - 1)

			--计算守护瑞兽属性对组合战力的加成
			local info = ShengXiaoData.Instance:GetXingLingInfo(self.cur_chapter)
			local level = info.level
			local spirit_cap = 0
			if level >= 0 then
				local cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_chapter - 1, level)
				spirit_cap = CommonDataManager.GetCapability(one_combine_cfg) * (cfg.xingtu_add_prob / 10000)
			end

			totalCap = totalCap + CommonDataManager.GetCapability(one_combine_cfg) + spirit_cap
		end
	end

	--计算技能的战力加成
	if ShengXiaoData.Instance:GetOneChapterActive(self.cur_chapter) then
		local cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_chapter)	
		local total_cap = ShengXiaoData.Instance:GetChapterTotalCap()  											--所有组合激活时候的战力总和
		totalCap = totalCap + (total_cap * cfg.per_attr / 100)													--计算并累加技能所增加的战力									
	end

	return totalCap
end

function ShengXiaoPieceView:FLushCellAnim(value, show_anim_list)
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			local x, y = 0, 0
			if v1:GetData() then
				x = v1:GetData().x
				y = v1:GetData().y
			end
			local bool = value
			if bool and show_anim_list and show_anim_list[y- 1] then
				bool = show_anim_list[y - 1][x - 1] ~= nil
			else
				bool = false
			end

			v1:SetShowAnim(bool)
		end
	end
end

function ShengXiaoPieceView:FLushItemHL()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			v1:FlushHL()
		end
	end
end

function ShengXiaoPieceView:OpenTearsueView()
	RemindManager.Instance:Fire(RemindName.ShengXiao_Piece)
	ViewManager.Instance:Open(ViewName.ErnieView)
end

function ShengXiaoPieceView:OpenBagView()
	ShengXiaoCtrl.Instance:OpenShengXiaoBag(self.cur_chapter)
end

function ShengXiaoPieceView:OpenSkillView()
	ShengXiaoCtrl.Instance:OpenShengXiaoSkill(self.cur_chapter)
end

function ShengXiaoPieceView:OnSelectMoveType()
	self.is_move_state = not self.is_move_state
	if self.is_move_state then
		self.show_black:SetValue(true)
	else
		self.move_data1 = nil
		self.move_data2 = nil
		self:FLushItemHL()
		self.show_black:SetValue(false)
	end
end

function ShengXiaoPieceView:OnSelectNomalType()
	self.move_data1 = nil
	self.move_data2 = nil
	self:FLushItemHL()
	self.is_move_state = false
	self.show_black:SetValue(false)
end

function ShengXiaoPieceView:OnPageDown()
	if self.cur_chapter <= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMoreChapter)
		return
	end
	self.cur_chapter = self.cur_chapter - 1
	self:ShowAnim(1)
	self:FlushAll()
end

function ShengXiaoPieceView:OnPageUp()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	if self.cur_chapter >= 5 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMoreChapter)
		return
	end
	if self.cur_chapter >= max_chatpter then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NextChapter)
		return
	end
	self.cur_chapter = self.cur_chapter + 1
	self:ShowAnim(1)
	self:FlushAll()
end

function ShengXiaoPieceView:OpenDetail()
	self.show_piece_detail:SetValue(true)
	self:FlushDetailView()
end

function ShengXiaoPieceView:CloseDetail()
	self.show_piece_detail:SetValue(false)
end

function ShengXiaoPieceView:OpenCombine(idnex)
	local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_chapter - 1) * 3 + idnex - 1)
	TipsCtrl.Instance:ShowAttrView(one_combine_cfg)
end


function ShengXiaoPieceView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(177)
end

function ShengXiaoPieceView:OnTakeOffPiece()
	-- local can_change_chapter = ShengXiaoData.Instance:GetMaxChapter()
	-- if self.cur_chapter < can_change_chapter then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
	-- 	self:CloseDetail()
	-- 	return
	-- end
	local flag = self:CheckLingZhuMove(self.show_detail_data.y - 1,self.show_detail_data.x - 1)
	if nil ~= self.show_detail_data then
		if flag == true then
			yes_func = BindTool.Bind(self.SendTakeOffPiece, self)
			TipsCtrl.Instance:ShowCommonAutoView("", Language.ShengXiao.MoveEndTips, yes_func)
		else
			self:SendTakeOffPiece()
		end
	end
	self:CloseDetail()
end

function ShengXiaoPieceView:SendTakeOffPiece()
	ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XIE_BEAD, self.show_detail_data.x - 1, self.show_detail_data.y - 1, self.cur_chapter - 1)
end

function ShengXiaoPieceView:FlushDetailView()
	if self.select_piece_value <= 0 then return end
	local detail_cfg = ShengXiaoData.Instance:GetBeadCfg(self.select_piece_value)
	local beadCfg = ShengXiaoData.Instance:GetBeadCfg(self.select_piece_value)
	if beadCfg then
		self.cur_piece_path:SetAsset(ResPath.GetItemIcon(beadCfg.item_id))
	end
	self.cur_piece_name:SetValue(ItemData.Instance:GetItemName(detail_cfg.item_id))

	local hp = detail_cfg.max_hp or detail_cfg.maxhp or 0
	local gong_ji = detail_cfg.gong_ji or detail_cfg.gongji or 0
	local fang_yu = detail_cfg.fang_yu or detail_cfg.fangyu or 0
	local ming_zhong = detail_cfg.ming_zhong or detail_cfg.mingzhong or 0
	local shan_bi = detail_cfg.shan_bi or detail_cfg.shanbi or 0
	local bao_ji = detail_cfg.bao_ji or detail_cfg.baoji or 0
	local jian_ren = detail_cfg.jian_ren or detail_cfg.jianren or 0

	if hp and hp >= 0 then
		self.show_hp:SetValue(true)
		self.hp:SetValue(hp)
	else
		self.show_hp:SetValue(false)
	end

	if gong_ji and gong_ji >= 0 then
		self.show_gongji:SetValue(true)
		self.gong_ji:SetValue(gong_ji)
	else
		self.show_gongji:SetValue(false)
	end

	if fang_yu and fang_yu >= 0 then
		self.show_fangyu:SetValue(true)
		self.fang_yu:SetValue(fang_yu)
	else
		self.show_fangyu:SetValue(false)
	end

	if ming_zhong and ming_zhong >= 0 then
		self.show_mingzhong:SetValue(true)
		self.ming_zhong:SetValue(ming_zhong)
	else
		self.show_mingzhong:SetValue(false)
	end

	if shan_bi and shan_bi >= 0 then
		self.show_shanbi:SetValue(true)
		self.shan_bi:SetValue(shan_bi)
	else
		self.show_shanbi:SetValue(false)
	end

	if bao_ji and bao_ji >= 0 then
		self.show_baoji:SetValue(true)
		self.bao_ji:SetValue(bao_ji)
	else
		self.show_baoji:SetValue(false)
	end

	if jian_ren and jian_ren >= 0 then
		self.show_kangbao:SetValue(true)
		self.kang_bao:SetValue(jian_ren)
	else
		self.show_kangbao:SetValue(false)
	end

	local cap = CommonDataManager.GetCapability(detail_cfg)
	if cap and cap >= 0 then
		self.detail_cap:SetValue(cap)
	else
		self.detail_cap:SetValue(0)
	end

end

function ShengXiaoPieceView:SelectChange(data)
	if data == nil then return end
	if not self.is_move_state then
		self.move_data1 = nil
		self.move_data2 = nil
		if ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter ,data.y , data.x) > 0 then
			self.select_piece_value = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, data.y , data.x)
			self.show_detail_data = data
			self:OpenDetail()
		else
			local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
			-- if self.cur_chapter >= max_chatpter then
			-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			-- end
			self:OpenBagView()		--普通模式点击空白格子弹出灵珠背包
		end
	else
		-- local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
		-- if self.cur_chapter < max_chatpter then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
		-- 	return
		-- end
		local has_clear = false
		if self.move_data1 == nil then
			local type_1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, data.y , data.x)
			if type_1 <= 0 then
				self:OpenBagView()  	--移动模式点击空白格子弹出灵珠背包
				return
			end
			has_clear = true
			self.move_data1 = data
		else
			if self.move_data1.x == data.x and self.move_data1.y == data.y then
				self.move_data1 = nil
				has_clear = true
			end
		end
		if not has_clear then
			self.move_data2 = data
		end
		if self.move_data1 and self.move_data2 then
			local type1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, self.move_data1.y , self.move_data1.x)
			local type2 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, self.move_data2.y , self.move_data2.x)
			if type1 > 0 or type2 > 0 then
				local flag = self:CheckLingZhuMove(self.move_data1.y - 1, self.move_data1.x - 1, self.move_data2.y - 1, self.move_data2.x - 1)		--检查要移动的灵珠是否属于已激活篇章中组合的一员
				if flag == true then
					yes_func = BindTool.Bind(self.SendFastMoveReq, self)
					TipsCtrl.Instance:ShowCommonAutoView("", Language.ShengXiao.MoveEndTips, yes_func)
				else
					self:SendFastMoveReq()
				end
			else
				self.move_data2 = nil
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			end
		end
	end
	self:FLushItemHL()
end

function ShengXiaoPieceView:SendFastMoveReq()
	ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD,
		self.move_data1.x - 1, self.move_data1.y - 1, self.move_data2.x - 1, self.move_data2.y - 1, self.cur_chapter - 1)
	self.move_data1 = nil
	self.move_data2 = nil
end

function ShengXiaoPieceView:FlushAll()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local total_cap = 0
	for i = 1, 3 do
		local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_chapter - 1) * 3 + i - 1)
		self.group_name_list[i]:SetValue(one_combine_cfg.name)
		self.group_image_list[i]:SetAsset(ResPath.GetXingHunIcon((self.cur_chapter - 1) * 3 + i))
		self.capbility_list[i]:SetValue(CommonDataManager.GetCapability(one_combine_cfg))
		total_cap = total_cap + CommonDataManager.GetCapability(one_combine_cfg)
		-- if self.cur_chapter < max_chatpter then
		-- 	self.show_acitve_list[i]:SetValue(true)
		-- else
			local actve_data_list = ShengXiaoData.Instance:GetActiveListByChatper(self.cur_chapter)
			self.show_acitve_list[i]:SetValue(actve_data_list[i])
		-- end
	end
	ShengXiaoData.Instance:SetChapterTotalCap(total_cap)
	self.cur_chapter_value:SetValue(self.cur_chapter)
	self.max_chapter_value:SetValue(max_chatpter)
	local cur_chapter_cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_chapter)
	self.chapter_name:SetValue(cur_chapter_cfg.name)
	-- if self.cur_chapter < max_chatpter then
	-- 	self.skill_icon.grayscale.GrayScale = 0
	-- else
		-- self.skill_icon.grayscale.GrayScale = ShengXiaoData.Instance:GetOneChapterActive(self.cur_chapter) and 0 or 255
	-- end
	local cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_chapter)
	self.skill_path:SetAsset(ResPath.GetShengXiaoSkillIcon(self.cur_chapter))
	self.skill_name:SetValue(cfg.skill)
	local is_all_finish = ShengXiaoData.Instance:GetIsFinishAll()
	if is_all_finish ~= 0 or self.cur_chapter == 1 then
		self.show_extra_add:SetValue(true)
	else
		self.show_extra_add:SetValue(self.cur_chapter ~= max_chatpter)
	end
	local info = ShengXiaoData.Instance:GetXingLingInfo(self.cur_chapter)
	local level = info.level
	local extra_value = 0
	if level >= 0 then
		local cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_chapter - 1, level)
		extra_value = cfg.xingtu_add_prob / 100
	end
	self.extra_add:SetValue(string.format(Language.Common.ShowYellowStr, extra_value))
	self:FlushPieceView()
end


--用于判断移动的灵珠是否属于已经激活篇章中组合的一员，  x1,y1是原位置，x2,y2是新位置
function ShengXiaoPieceView:CheckLingZhuMove(x1, y1, x2, y2)
	local actve_data_list = ShengXiaoData.Instance:GetActiveListByChatper(self.cur_chapter)  --获得当前组合激活的情况
	local result = true
	--判断篇章是否激活
	for i = 1, 3 do
		--如果有组合未激活
		if actve_data_list[i] == 0 then
			result = false
		end
	end
	--如果篇章已激活（所有组合激活）
	if result == true then
		result = self:CheckContains(x1,y1)   	--检查灵珠是否属于激活组合的一员
	end

	if x2 and y2 then
		--判断原位置和移动位置的灵珠是否相等
		local type1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, x1+1 , y1+1)
		local type2 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, x2+1 , y2+1)
		if type1 and type2 then 
			if type1 == type2 then
				result = false
			end
		end
	end
	return result
end
--用于检查灵珠是否属于激活组合的一员
function ShengXiaoPieceView:CheckContains(x,y)
	local bead_by_combine_list = ShengXiaoData.Instance:GetShowAnimListByChatper(self.cur_chapter)					--获取已激活的灵阵中所有灵珠的坐标信息
	local active_List = {}  																						--用于记录属于激活灵阵的灵珠位置
	--把bead_by_combine_list转换成坐标（x，y）一维表
	for k1,v1 in pairs(bead_by_combine_list) do
		for k2,v2 in pairs(v1) do
			local cell_x = k2
			for k3,v3 in pairs(v2) do
				local cell_y = k3
				if not self:IsInTable({ x = cell_x, y = cell_y },active_List) then
					table.insert(active_List , { x = cell_x, y = cell_y })
				end
			end
		end
	end
	if self:IsInTable({x = x,y = y},active_List) then
		return true
	end
	return false
end
--判断坐标是否在表里已经有了
function ShengXiaoPieceView:IsInTable(coordinate, tbl)
	for k,v in ipairs(tbl) do
	  if v.x == coordinate.x and v.y == coordinate.y then
	  	return true;
	  end
	end
	return false;
end






PieceItem = PieceItem or BaseClass(BaseCell)

function PieceItem:__init()
	local bundle, asset = ResPath.GetMiscPreloadRes("PieceItem")
	local prefab = PreloadManager.Instance:GetPrefab(bundle, asset)
	self:SetInstance(GameObject.Instantiate(prefab))

	self.parent_view = nil
	self.image_path = self:FindVariable("image_path")
	self.show_hl = self:FindVariable("show_hl")
	-- self.show_icon = self:FindVariable("show_icon")
	self.show_anim = self:FindVariable("show_anim")
	self:ListenEvent("click", BindTool.Bind(self.OnClickItem, self))

	self.icon = self:FindObj("icon")
	self.icon.image.enabled = false

	self.bg = self:FindObj("Item")

	self.show_hl:SetValue(false)

	self.drag_event = BindTool.Bind(self.DragEvent, self)
	self.bg.uidrag:ListenDropCallback(self.drag_event)
	self.icon.uidrag:ListenDropCallback(self.drag_event)
end

function PieceItem:__delete()
	self.parent_view = nil

	self.bg.uidrag:UnListenDropCallback(self.drag_event)
	self.icon.uidrag:UnListenDropCallback(self.drag_event)
end

function PieceItem:DragEvent(drag_data, drag_obj)
	if self.data == nil or drag_data == nil then return end

	-- local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	-- if self.parent_view.cur_chapter ~= max_chapter or ShengXiaoData.Instance:GetIsFinishAll() == 1 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
	-- 	return
	-- end

	local y = math.floor(drag_data / 100) - 1
	local x = drag_data % 100 - 1
	local flag = self.parent_view:CheckLingZhuMove(x, y, self.data.y - 1,self.data.x - 1)		--检查要移动的灵珠是否属于已激活篇章中组合的一员
	if flag == true then
		yes_func = BindTool.Bind(self.SendMoveReq, self, drag_data, drag_obj)
		TipsCtrl.Instance:ShowCommonAutoView("", Language.ShengXiao.MoveEndTips, yes_func)
	else
		self:SendMoveReq(drag_data, drag_obj)
	end

end

--发送移动灵珠的请求
function PieceItem:SendMoveReq(drag_data, drag_obj)
	if nil ~= drag_data then
		local x = math.floor(drag_data / 100)
		local y = drag_data % 100

		local cur_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, self.data.y, self.data.x)
		local drag_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, y, x)
		ShengXiaoData.Instance:SetTianXiangSignBead({chapter = self.parent_view.cur_chapter - 1,y = y - 1, x = x - 1, type = cur_type})
		ShengXiaoData.Instance:SetTianXiangSignBead({chapter = self.parent_view.cur_chapter - 1,y = self.data.y - 1, x = self.data.x - 1, type = drag_type})
		self.parent_view:FlushPieceView()
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD, x - 1, y - 1, self.data.x - 1, self.data.y - 1, self.parent_view.cur_chapter - 1)
	end
end

function PieceItem:OnFlush()
	if self.data == nil then
		return
	end
	self.show_hl:SetValue(false)
	self.icon.image.enabled = false

	local cur_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, self.data.y, self.data.x)
	if cur_type > 0 then
		local beadCfg = ShengXiaoData.Instance:GetBeadCfg(cur_type)
		self.icon.image.enabled = true
		self.image_path:SetAsset(ResPath.GetItemIcon(beadCfg.item_id))--ResPath.GetPieceIcon(cur_type)
	end

	self.icon.uidrag:SetDragData(self.data.x * 100 + self.data.y)

	-- local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	-- if self.parent_view.cur_chapter ~= max_chapter then
	-- 	self.icon.uidrag:SetIsCanDrag(false)
	-- elseif ShengXiaoData.Instance:GetIsFinishAll() == 1 then
	-- 	self.icon.uidrag:SetIsCanDrag(false)
	-- else
		self.icon.uidrag:SetIsCanDrag(true)
	-- end
end

function PieceItem:FlushHL()
	if self.parent_view.move_data1 then
		if self.data.x == self.parent_view.move_data1.x and self.parent_view.move_data1.y == self.data.y then
			self.show_hl:SetValue(true)
			return
		end
	end
	self.show_hl:SetValue(false)
end

function PieceItem:SetShowAnim(is_show)
	self.show_anim:SetValue(is_show)
end

function PieceItem:OnClickItem()
	self.parent_view:SelectChange(self.data)
end