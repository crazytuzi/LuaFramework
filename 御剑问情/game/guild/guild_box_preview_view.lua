GuildBoxPreviewView = GuildBoxPreviewView or BaseClass(BaseView)

function GuildBoxPreviewView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildBoxPreviewView"}
	self.view_layer = UiLayer.Pop
end

function GuildBoxPreviewView:__delete()

end

function GuildBoxPreviewView:LoadCallBack()
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))

	self.preview_cell = {}
	for i = 1, 5 do
		self.preview_cell[i] = {}
		self.preview_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.preview_cell[i].cell = ItemCell.New()
		self.preview_cell[i].cell:SetInstanceParent(self.preview_cell[i].obj)
	end
end

function GuildBoxPreviewView:OpenCallBack()
	self:Flush()
end

function GuildBoxPreviewView:ReleaseCallBack()
	for k,v in pairs(self.preview_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.preview_cell = nil
end

function GuildBoxPreviewView:CloseCallBack()

end

function GuildBoxPreviewView:OnFlush()
	local config = GuildData.Instance:GetBoxConfig()[5]
	if config then
		local item_id = config.assist_reward.item_id
		local num = config.assist_reward.num
		self.preview_cell[5].cell:SetData({item_id = item_id, num = num})

		self.preview_cell[1].obj:SetActive(true)
		item_id = config.item_reward.item_id
		num = config.item_reward.num
		self.preview_cell[1].cell:SetData({item_id = item_id, num = num})
	end
end