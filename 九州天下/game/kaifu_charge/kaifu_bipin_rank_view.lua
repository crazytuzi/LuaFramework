BiPinRankView = BiPinRankView or BaseClass(BaseView)

function BiPinRankView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","BiPinRank"}
end

function BiPinRankView:__delete()
	if self.bipin_rank_list then
		for k,v in pairs(self.bipin_rank_list) do
			v:DeleteMe()
		end
		self.bipin_rank_list = {}
	end
end

function BiPinRankView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickCheck, self))
	self.type_rank_des = self:FindVariable("TypeRankDes")
	self:BiPinScroller()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.type_rank_des:SetValue(Language.Common.BiPinType[activity])
end

function BiPinRankView:OnClickCheck()
	self:Close()
end

function BiPinRankView:OpenCallBack()
end


function BiPinRankView:ActSendGetRankListReq()
	local act = KaiFuChargeData.Instance:GetBiPinActivity()              -- 活动号
	if ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_MOUNT)
	elseif ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_WING)
	elseif ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_HALO)
	elseif ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_FIGHTMOUNT)
	elseif ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_JL_HALO)
	elseif  ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_ZHIBAO)
	elseif ActivityData.Instance:GetActivityIsOpen(act) then
		RankCtrl.Instance:SendGetPersonRankListReq(BiPIN_RANK_TYPE.PERSON_RANK_TYPE_UPGRADE_SHENYI)
	end
end

function BiPinRankView:ShowRankList()

end

function BiPinRankView:OnFlush()
	
	-- if server_day < 8 then
	-- 	for i=1, 7 do
	-- 		self.toggle[i]:SetActive( i+1 == server_day)
	-- 	end
	-- end

	if self.bipin_rank_item.scroller.isActiveAndEnabled then
		self.bipin_rank_item.scroller:ReloadData(0)
	end
end

-- 排行榜格子
function BiPinRankView:BiPinScroller()
	self.bipin_rank_list = {}
	self.bipin_rank_item = self:FindObj("BiPinRankItem")
	local delegate = self.bipin_rank_item.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #RankData.Instance:GetRankList()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1
		local target_cell = self.bipin_rank_list[cell]

		if nil == target_cell then
			self.bipin_rank_list[cell] =  BiPinRankList.New(cell.gameObject)
			target_cell = self.bipin_rank_list[cell]
			target_cell.mother_view = self
		end
		local data = RankData.Instance:GetRankList()
		if data then
			local cell_data = data[data_index]
			cell_data.data_index = data_index
			target_cell:SetIndex(data_index)
			target_cell:SetData(cell_data)
		end
	end
end




---------------------------------------------------------------
--比拼滚动条格子

BiPinRankList = BiPinRankList or BaseClass(BaseCell)

function BiPinRankList:__init()
	self.rank_num = self:FindVariable("Rank_Num")
	-- self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.name = self:FindVariable("Name")
	self.jieshu = self:FindVariable("JieShu")
	self.roleimage = self:FindObj("RoleImage")
	self.rawimage = self:FindObj("RawImage")
	self.camp = self:FindVariable("Camp")
	self.type_text = self:FindVariable("TypeText")
	self.value_text = self:FindVariable("ValueText")
	self.rank_img = self:FindVariable("RankImg")
	self.show_rank_img = self:FindVariable("ShowRankImg")

	self.index = 1
end

function BiPinRankList:__delete()
end

function BiPinRankList:SetIndex(index)
	self.index = index
end

function BiPinRankList:OnFlush()
	if self.data == nil then return end
	local grade = KaiFuChargeData.Instance:ConvertGrade(self.data.rank_value)
	self.name:SetValue(self.data.user_name)
	self.camp:SetValue(Language.RankTogle.ArtCamp[self.data.camp])
	self.value_text:SetValue(grade)
	AvatarManager.Instance:SetAvatarKey(self.data.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(self.data.user_id)
	if AvatarManager.Instance:isDefaultImg(self.data.user_id) == 0 or avatar_path_small == 0 then
		self.roleimage.gameObject:SetActive(true)
		self.rawimage.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.roleimage.image:LoadSprite(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.roleimage.gameObject) or IsNil(self.rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.user_id, false)
			end
			self.rawimage.raw_image:LoadSprite(path, function ()
				self.roleimage.gameObject:SetActive(false)
				self.rawimage.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.data.user_id, false, callback)
	end
	if self.index <= 3 then 
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.rank_img:SetAsset(bundle, asset)
		self.show_rank_img:SetValue(true)
	else
		self.rank_num:SetValue(self.index)
		self.show_rank_img:SetValue(false)
	end
end

