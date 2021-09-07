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

	self.group_name_list = {}
	self.group_image_list = {}
	self.capbility_list = {}
	self.show_acitve_list = {}
	self.chapter_name = self:FindVariable("chapter_name")
	self.show_black = self:FindVariable("show_black")
	self.cur_chapter_value = self:FindVariable("cur_chapter")
	self.max_chapter_value = self:FindVariable("max_chapter")
	self.show_piece_detail = self:FindVariable("show_piece_detail")
	self.show_ernie_red_point = self:FindVariable("ShowErnieRedPoint")

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
end

function ShengXiaoPieceView:ShowAnim(index)
	if index > 3 then return end
	local show_anim_list = ShengXiaoData.Instance:GetShowAnimListByChatper(self.cur_chapter)
	if self.has_light then
		self.has_light = false
		self.show_anim_count = (self.show_anim_count + 1) % 3
		self:FLushCellAnim(false)
	elseif show_anim_list[self.show_anim_count] then
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
end

function ShengXiaoPieceView:FlushPieceView()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			v1:OnFlush()
		end
	end
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
			-- local x = k1
			-- if k > 4 then
			-- 	x = k1 + k - 4
			-- end
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
	ShengXiaoData.Instance:SetErnieState(true)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Piece)
	self.show_ernie_red_point:SetValue(ShengXiaoData.Instance:IsShowErnieRedPoint())
	ViewManager.Instance:Open(ViewName.ErnieView)
end

function ShengXiaoPieceView:OpenBagView()
	ShengXiaoCtrl.Instance:OpenShengXiaoBag()
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
	local can_change_chapter = ShengXiaoData.Instance:GetMaxChapter()
	if self.cur_chapter < can_change_chapter then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
		self:CloseDetail()
		return
	end
	if nil ~= self.show_detail_data then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XIE_BEAD, self.show_detail_data.x - 1
			, self.show_detail_data.y - 1)
	end
	self:CloseDetail()
end

function ShengXiaoPieceView:FlushDetailView()
	if self.select_piece_value <= 0 then return end
	local detail_cfg = ShengXiaoData.Instance:GetBeadCfg(self.select_piece_value)
	self.cur_piece_path:SetAsset(ResPath.GetPieceIcon(self.select_piece_value))
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
			if self.cur_chapter >= max_chatpter then
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			end
		end
	else
		local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
		if self.cur_chapter < max_chatpter then
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
			return
		end
		local has_clear = false
		if self.move_data1 == nil then
			local type_1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, data.y , data.x)
			if type_1 <= 0 then
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
				ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD,
					self.move_data1.x - 1, self.move_data1.y - 1, self.move_data2.x - 1, self.move_data2.y - 1)
				self.move_data1 = nil
				self.move_data2 = nil
			else
				self.move_data2 = nil
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			end
		end
	end
	self:FLushItemHL()
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
		if self.cur_chapter < max_chatpter then
			self.show_acitve_list[i]:SetValue(true)
		else
			local actve_data_list = ShengXiaoData.Instance:GetActiveList()
			self.show_acitve_list[i]:SetValue(actve_data_list[i])
		end
	end
	ShengXiaoData.Instance:SetChapterTotalCap(total_cap)
	self.cur_chapter_value:SetValue(self.cur_chapter)
	self.max_chapter_value:SetValue(max_chatpter)
	local cur_chapter_cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_chapter)
	self.chapter_name:SetValue(cur_chapter_cfg.name)
	if self.cur_chapter < max_chatpter then
		self.skill_icon.grayscale.GrayScale = 0
	else
		self.skill_icon.grayscale.GrayScale = ShengXiaoData.Instance:GetMaxChapterActive() and 0 or 255
	end
	self.skill_path:SetAsset(ResPath.GetShengXiaoSkillIcon(self.cur_chapter))
	self:FlushPieceView()
	self.show_ernie_red_point:SetValue(ShengXiaoData.Instance:IsShowErnieRedPoint())
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
	if self.data == nil then return end

	local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	if self.parent_view.cur_chapter ~= max_chapter or ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.CanNotTake)
		return 
	end

	if nil ~= drag_data then
		local x = math.floor(drag_data / 100)
		local y = drag_data % 100

		local cur_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, self.data.y, self.data.x)
		local drag_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, y, x)
		ShengXiaoData.Instance:SetTianXiangSignBead({y = y - 1, x = x - 1, type = cur_type})
		ShengXiaoData.Instance:SetTianXiangSignBead({y = self.data.y - 1, x = self.data.x - 1, type = drag_type})
		self.parent_view:FlushPieceView()
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD,
			x - 1, y - 1, self.data.x - 1, self.data.y - 1)
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
		self.icon.image.enabled = true
		self.image_path:SetAsset(ResPath.GetPieceIcon(cur_type))
	end

	self.icon.uidrag:SetDragData(self.data.x * 100 + self.data.y)

	local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	if self.parent_view.cur_chapter ~= max_chapter then
		self.icon.uidrag:SetIsCanDrag(false)
	elseif ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		self.icon.uidrag:SetIsCanDrag(false)
	else
		self.icon.uidrag:SetIsCanDrag(true)
	end
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