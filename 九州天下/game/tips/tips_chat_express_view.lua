TipsExpressView = TipsExpressView or BaseClass(BaseView)

local NORMAL = 1
local DYNAMICL = 2
local SPECIAL = 3

local MAX_CELL_NUM = 175
local ROW = 4
local COLUMN = 5
local BIGFACE_ROW = 4
local BIGFACE_COL = 5

local EMOJINUM = 40
local BIGFACENUM = 51
local SPECIALNUM = 33

function TipsExpressView:__init()
	self.ui_config = {"uis/views/tips/chattips", "EmojiView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
end

function TipsExpressView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for i = 1, 5 do
		self["toggle" .. i] = nil
	end

	for i = 1, 5 do
		self["bigtoggle" .. i] = nil
	end
	self.list_view = nil
	self.list_view_bigface = nil
end

function TipsExpressView:LoadCallBack()
	MAX_CELL_NUM = 175
	self.show_state = NORMAL
	self:ChangeData(EMOJINUM)
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	self.list_view_bigface = self:FindObj("ListViewBigFace")

	for i = 1, 5 do
		self["toggle" .. i] = self:FindObj("PageToggle" .. i)
	end

	for i = 1, 5 do
		self["bigtoggle" .. i] = self:FindObj("TogglebBig" .. i)
	end

	--修改最大页数
	local list_page_scroll = self.list_view.list_page_scroll
	local count = #self.cell_data
	local page = math.ceil(count / (ROW * COLUMN))
	list_page_scroll:SetPageCount(page)


	for j = page + 1, 5 do
		self["toggle" .. j]:SetActive(false)
	end

	for j = page + 1, 5 do
		self["bigtoggle" .. j]:SetActive(false)
	end

	self:ListenEvent("OnClickNormalButton",
		BindTool.Bind(self.OnClickNormalButton, self))
	self:ListenEvent("OnClickDynamicButton",
		BindTool.Bind(self.OnClickDynamicButton, self))
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickCool",
		BindTool.Bind(self.OnClickCool, self))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list_delegate_bigface = self.list_view_bigface.list_simple_delegate
	list_delegate_bigface.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate_bigface.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsExpressView:SetCallback(callback)
	self.call_back = callback
end

function TipsExpressView:CallBack(face_id)
	if self.call_back then
		self.call_back(face_id)
	end
end

function TipsExpressView:GetNumberOfCells()
	if self.show_state == DYNAMICL then
		return MAX_CELL_NUM / BIGFACE_ROW
	end
	return MAX_CELL_NUM / ROW
end

function TipsExpressView:RefreshCell(cell, data_index)
	local group = self.cell_list[cell]
	local cur_row = BIGFACE_ROW
	local cur_col = BIGFACE_COL
	if self.show_state == DYNAMICL then
		cur_row = BIGFACE_ROW
		cur_col = BIGFACE_COL
	end
	if group == nil then
		group = ExpressShowGroup.New(cell.gameObject, self.show_state)
		group.express_view = self
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / cur_col)
	local column = data_index - page * cur_col
	local grid_count = cur_col * cur_row
	for i = 1, cur_row do
		local index = (i - 1) * cur_col  + column + (page * grid_count)

		group:SetParent(i)
		group:SetData(i, self.cell_data[index + 1])
		group:SetIndex(i, index)
	end
end

function TipsExpressView:ChangeData(max_count)
	if max_count and max_count > 0 then
		self.cell_data = {}
		for k = 1, max_count do
			table.insert(self.cell_data, k)
		end
	end
end

function TipsExpressView:ChangeView()
	local list_page_scroll = self.list_view.list_page_scroll
	local toggle_str = "toggle"
	if self.show_state == DYNAMICL then
		list_page_scroll = self.list_view_bigface.list_page_scroll
		toggle_str = "bigtoggle"
	end

	local PrefabName = ""
	local data = {}
	local cur_row = ROW
	local cur_col = COLUMN
	if self.show_state == NORMAL then
		self:ChangeData(EMOJINUM)
		PrefabName = "EmojiObj"
	elseif self.show_state == DYNAMICL then
		self:ChangeData(BIGFACENUM)
		cur_row = BIGFACE_ROW
		cur_col = BIGFACE_COL
		PrefabName = "BigFaceObj"
	elseif self.show_state == SPECIAL then
		self:ChangeData(SPECIALNUM)
		PrefabName = "SpecialObj"
	end

	--修改最大页数
	local count = #self.cell_data
	local page = math.ceil(count/(cur_row * cur_col))
	list_page_scroll:SetPageCount(page)
	for i = 1, page do
		self[toggle_str .. i]:SetActive(true)
	end
	for j = page + 1, 5 do
		self[toggle_str .. j]:SetActive(false)
	end

	MAX_CELL_NUM = cur_row * cur_col * page

	PrefabPool.Instance:Load(AssetID("uis/views/tips/chattips_prefab", PrefabName), function(prefab)
		if prefab and self.list_view then
			if self.show_state == NORMAL then
				local list_delegate = self.list_view.list_simple_delegate
				list_delegate.CellPrefab = prefab:GetComponent(typeof(ListViewCell))
				self.list_view.scroller:ReloadData(0)
			elseif self.show_state == DYNAMICL then
				if self.list_view_bigface ~= nil then
					local list_delegate = self.list_view_bigface.list_simple_delegate
					list_delegate.CellPrefab = prefab:GetComponent(typeof(ListViewCell))
					self.list_view_bigface.scroller:ReloadData(0)
				end
			end
			
			PrefabPool.Instance:Free(prefab)
		end
	end)
	GlobalTimerQuest:AddDelayTimer(function()
		self[toggle_str .. "1"].toggle.isOn = true
	end, 0)
end

function TipsExpressView:OnClickNormalButton()
	self.show_state = NORMAL
	self:ChangeView()
end

function TipsExpressView:OnClickDynamicButton()
	self.show_state = DYNAMICL
	self:ChangeView()
end

function TipsExpressView:OnClickCloseButton()
	self:Close()
end


function TipsExpressView:OnClickCool()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_cool_chat)
	ViewManager.Instance:Close(ViewName.TipsExpressView)
end


ExpressShowGroup = ExpressShowGroup or BaseClass(BaseRender)

function ExpressShowGroup:__init(obj, show_state)
	self.cells = {}
	if show_state == NORMAL then
		for i = 1, BIGFACE_ROW do
			local obj = NormalFaceIconCell.New(self:FindObj("Icon" .. i))
			table.insert(self.cells, obj)
		end
	elseif show_state == DYNAMICL then
		for i = 1, BIGFACE_ROW do
			local obj = BigFaceIconCell.New(self:FindObj("Icon" .. i))
			table.insert(self.cells, obj)
		end
	elseif show_state == SPECIAL then
		self.cells = {
			SpecialIconCell.New(self:FindObj("Icon1")),
			SpecialIconCell.New(self:FindObj("Icon2")),
			SpecialIconCell.New(self:FindObj("Icon3")),
			SpecialIconCell.New(self:FindObj("Icon4")),
		}
	end
	self.show_state = show_state
end

function ExpressShowGroup:__delete()
	for k, v in ipairs(self.cells) do
		if v then
			v:DeleteMe()
		end
	end
	self.cells = {}

	self.express_view = nil
end

function ExpressShowGroup:SetParent(i)
	self.cells[i].group_view = self
end

function ExpressShowGroup:SetData(i, data)
	if self.show_state == DYNAMICL then
		self.cells[i]:SetGray(not CoolChatData.Instance:GetActiveStatusByIndex(data))
	end
	self.cells[i]:SetData(data)
end

function ExpressShowGroup:SetIndex(i, index)
	self.cells[i]:SetIndex(index)
end

function ExpressShowGroup:CallBack(face_id)
	self.express_view:CallBack(face_id)
end

--普通
EmojiIconCell = EmojiIconCell or BaseClass(BaseRender)

function EmojiIconCell:__init()
	self.icon = self:FindVariable("image")
	self.hide = self:FindVariable("Hide")
	self:ListenEvent("Click", BindTool.Bind(self.ClickIcon, self))
end

function EmojiIconCell:__delete()
	self.group_view = nil
end

function EmojiIconCell:SetIndex(index)
	self.index = index
end

function EmojiIconCell:HideIcon(Value)
	self.hide:SetValue(Value)
end


function EmojiIconCell:SetData(data)
	if not data then self:HideIcon(true) return end
	self:HideIcon(false)
	self.data = data
	local bubble, asset = ResPath.GetEmoji(self.data)
	self.icon:SetAsset(bubble, asset)
end

function EmojiIconCell:ClickIcon()
	if not self.data then return end
	if self.group_view then
		self.group_view:CallBack(self.data)
	end
	-- ChatCtrl.Instance:SetFace(self.data)
end

--动态
BigFaceIconCell = BigFaceIconCell or BaseClass(BaseRender)

function BigFaceIconCell:__init()
	self.hide = self:FindVariable("Hide")
	self.frame = self:FindObj("Frame")
	self:ListenEvent("Click", BindTool.Bind(self.ClickIcon, self))
	self.is_gray = false
end

function BigFaceIconCell:__delete()
	self.group_view = nil
end

function BigFaceIconCell:SetIndex(index)
	self.index = index
end

function BigFaceIconCell:HideIcon(Value)
	self.hide:SetValue(Value)
end

function BigFaceIconCell:ReloadIcon()
	local index = self.data - 1
	local PrefabName = string.format("Image%s", index)
	if nil == self.frame or nil == self.frame.transform then return end
	
	PrefabPool.Instance:Load(AssetID("uis/icons/bigface/face_" .. (100 + index) .. "_prefab", PrefabName), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			if IsNil(obj) then
				return
			end
			
			local transform = obj.transform
			if nil == self.frame or nil == self.frame.transform then return end
			if IsNil(self.frame.transform) then return end
			if self.frame.transform.childCount then
				for i = 0, self.frame.transform.childCount - 1 do
					local child = self.frame.transform:GetChild(i)
					if child then
						GameObject.Destroy(child.gameObject)
					end
				end
			end
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			if variable_table then
				local gray = variable_table:FindVariable("Gray")
				if gray then
					gray:SetValue(self.is_gray)
				end
			end
			transform:SetParent(self.frame.transform, false)
		end
	end)
end

function BigFaceIconCell:SetData(data)
	if not data or data == 0 then self:HideIcon(true) return end
	self:HideIcon(false)
	self.data = data
	self:ReloadIcon()
end

function BigFaceIconCell:SetGray(state)
	self.is_gray = state or false
end

function BigFaceIconCell:ClickIcon()
	if not self.data then return end
	if not CoolChatData.Instance:GetActiveStatusByIndex(self.data) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Expression.NotActive)
		return
	end
	local face_id = self.index + COMMON_CONSTS.BIGCHATFACE_ID_FIRST
	if self.group_view then
		self.group_view:CallBack(face_id)
	end
end

--特殊
SpecialIconCell = SpecialIconCell or BaseClass(BaseRender)

function SpecialIconCell:__init()
	self.hide = self:FindVariable("Hide")
	self.frame = self:FindObj("Frame")
	self:ListenEvent("Click", BindTool.Bind(self.ClickIcon, self))
end

function SpecialIconCell:__delete()
	self.group_view = nil
end

function SpecialIconCell:SetIndex(index)
	self.index = index
end

function SpecialIconCell:HideIcon(Value)
	self.hide:SetValue(Value)
end

function SpecialIconCell:ReloadIcon()
	local PrefabName = string.format("Image%s", self.data - 1)

	PrefabPool.Instance:Load(AssetID("uis/icons/special_prefab", PrefabName), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			if IsNil(obj) then
				return
			end
			local transform = obj.transform

			if IsNil(transform) then
				return
			end

			if self.frame == nil or IsNil(self.frame.transform) then
				return
			end

			for i = 0, self.frame.transform.childCount - 1 do
				local child = self.frame.transform:GetChild(i)
				if child then
					GameObject.Destroy(child.gameObject)
				end
			end
			transform:SetParent(self.frame.transform, false)
		end
	end)
end

function SpecialIconCell:SetData(data)
	if not data then self:HideIcon(true) return end
	self:HideIcon(false)
	self.data = data
	self:ReloadIcon()
end

function SpecialIconCell:ClickIcon()
	if not self.data then return end
	local face_id = self.index + COMMON_CONSTS.SPECIALFACE_ID_FIRST
	if self.group_view then
		self.group_view:CallBack(face_id)
	end
end

--动态
NormalFaceIconCell = NormalFaceIconCell or BaseClass(BaseRender)

function NormalFaceIconCell:__init()
	self.hide = self:FindVariable("Hide")
	self.frame = self:FindObj("Frame")
	self:ListenEvent("Click", BindTool.Bind(self.ClickIcon, self))
	self.is_gray = false
end

function NormalFaceIconCell:__delete()
	self.group_view = nil
end

function NormalFaceIconCell:SetIndex(index)
	self.index = index
end

function NormalFaceIconCell:HideIcon(Value)
	self.hide:SetValue(Value)
end

function NormalFaceIconCell:ReloadIcon()
	if nil == self.data then return end
	local index = 100 + self.data - 1
	local PrefabName = string.format("Image%s", index)
	-- local file_name = 
	PrefabPool.Instance:Load(AssetID("uis/icons/normalface/" .. index .. "_prefab", PrefabName), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			local scale = 0.9
			transform.localScale = Vector3(scale, scale, scale)
			-- if self.frame then
			
			-- end
			if nil ~= self.frame and not IsNil(self.frame.transform) then	
				for i = 0, self.frame.transform.childCount - 1 do
					local child = self.frame.transform:GetChild(i)
					if child then
						GameObject.Destroy(child.gameObject)
					end
				end
				transform:SetParent(self.frame.transform, false)
			end
		end
	end)
end

function NormalFaceIconCell:SetData(data)
	if not data or data == 0 then self:HideIcon(true) return end
	self:HideIcon(false)
	self.data = data
	self:ReloadIcon()
end

function NormalFaceIconCell:SetGray(state)
	self.is_gray = state or false
end

function NormalFaceIconCell:ClickIcon()
	if not self.data then return end
	if self.group_view then
		self.group_view:CallBack(self.data)
	end
end
