DiedMailPop = DiedMailPop or BaseClass(BaseView)

function DiedMailPop:__init()
	self.ui_config = {"uis/views/diedmail", "DiedMailPop"}
	self.play_audio = true
	self.full_screen = false
	self:SetMaskBg()
end

function DiedMailPop:__delete()

end

function DiedMailPop:ReleaseCallBack()
	self.MostText = nil
	self.mostguojia = nil 
	self.mostname = nil
	self.Textnum = nil
	self.kill_list = nil
	self.kill_list2 = nil
	self.list_view_delegate = nil
	self.list_view_delegate2 = nil
end

function DiedMailPop:LoadCallBack()
	self:ListenEvent("OnClick", BindTool.Bind(self.Close, self))
	self.MostText = self:FindVariable("MostText")
	self.Textnum = self:FindVariable("Textnum")
	self.mostguojia = self:FindVariable("mostguojia")
	self.mostname = self:FindVariable("mostname")

	self.kill_list = self:FindObj("KillerList")
	self.list_view_delegate = self.kill_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView,self)

	self.kill_list2 = self:FindObj("KillerList2")
	self.list_view_delegate2 = self.kill_list2.list_simple_delegate
	self.list_view_delegate2.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell2, self)
	self.list_view_delegate2.CellRefreshDel = BindTool.Bind(self.FlushItem2,self)
	self:Flush()
end

function DiedMailPop:OpenCallBack()

end

function DiedMailPop:OnFlush()
	local yesterday_die_times = DiedMailData.Instance:GetTotalDieTimes()
	self.Textnum:SetValue(yesterday_die_times)
	local most_times = DiedMailData.Instance:GetKillerList()
	if next(most_times) then
		self.mostguojia:SetValue(Language.Common.CampName[most_times[1].camp])
		self.mostname:SetValue(most_times[1].name)
	end
end

function DiedMailPop:GetNumberOfCells()
	kill_list = DiedMailData.Instance:GetKillerList()
	i = #kill_list < 3 and #kill_list or 3 
	return i
end

function DiedMailPop:GetNumberOfCell2()
	local kill_list2 = DiedMailData.Instance:GetKillerList()
	i = #kill_list2 < 4 and 0 or (#kill_list2 - 3)
	return i
end

function DiedMailPop:RefreshView(cell, data_index)
	data_index = data_index + 1

	local killer_item = self.kill_list[cell]
	if killer_item == nil then
		killer_item = DiedItem.New(cell.gameObject)		
		killer_item.parent_view = self
		self.kill_list[cell] = equip_cell
	end
	killer_item:SetIndex(data_index)
	local data = DiedMailData.Instance:GetKillerList()
	killer_item:SetData(data[data_index])
end

function DiedMailPop:FlushItem2(cell,data_index)
	data_index = data_index + 1
	local killer_item = self.kill_list2[cell]
	if killer_item == nil then
		killer_item = DeathItem.New(cell.gameObject)
		killer_item.parent_view = self
		self.kill_list2[cell] = equip_cell
	end
	killer_item:SetIndex(data_index)
	local data = DiedMailData.Instance:GetKillerList()
	killer_item:SetData(data[data_index+3])
end

----------------------------------------------------------
DiedItem = DiedItem or BaseClass(BaseCell)

function DiedItem:__init()
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self.rank = self:FindVariable("rankimg")
	self.guojia = self:FindVariable("guojia")
	self.mingzi = self:FindVariable("mingzi")
	self.level = self:FindVariable("dengji") 
	self.cishu = self:FindVariable("cishu")
	self:ListenEvent("OpenCheck", BindTool.Bind(self.ClickItem, self))
end

function DiedItem:__delete()

end

function DiedItem:OnFlush()
	if next(self.data) then
		self.guojia:SetValue(Language.Common.CampName[self.data.camp])
		self.mingzi:SetValue(self.data.name)
		self.level:SetValue(self.data.level)
		self.cishu:SetValue(self.data.kill_me_times)
	end
	local bundle, asset = ResPath.GetRankIcon(self.index)
	self.rank:SetAsset(bundle,asset)

	AvatarManager.Instance:SetAvatarKey(self.data.uid, self.data.avatar_big, self.data.avater_small)
	if self.data.avater_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.uid, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				if self.data.avater_small == 0 then
					self.image_obj.gameObject:SetActive(true)
					self.raw_image_obj.gameObject:SetActive(false)
					return
				end
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.data.uid, false, callback)
	end
end

function DiedItem:ClickItem()
	CheckData.Instance:SetCurrentUserId(self.data.uid)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.uid)
	ViewManager.Instance:Open(ViewName.CheckEquip)
end

----------------------------------------
DeathItem = DeathItem or BaseClass(BaseCell)
function DeathItem:__init()
	self.paiming = self:FindVariable("paiming")
	self.guojia = self:FindVariable("guojia")
	self.mingzi = self:FindVariable("mingzi")
	self.cishu = self:FindVariable("cishu")
end

function DeathItem:__delete()

end

function DeathItem:OnFlush()
	self.paiming:SetValue(self.index+3)
	if next(self.data) then
		self.guojia:SetValue(Language.Common.CampName[self.data.camp])	
		self.mingzi:SetValue(self.data.name)
		self.cishu:SetValue(self.data.kill_me_times)
	end
end

-- function DeathItem:FlushItem()
-- 	self.paiming:SetValue(self.index+3)
-- 	if next(self.data) then
-- 		self.guojia:SetValue(Language.Common.CampName[self.data.camp])	
-- 		self.mingzi:SetValue(self.data.name)
-- 		self.cishu:SetValue(self.data.kill_me_times)
-- 	end
-- end
