GuildMazeChatCell = GuildMazeChatCell or BaseClass(ChatCell)

function GuildMazeChatCell:__init()

end

function GuildMazeChatCell:__delete()

end

function GuildMazeChatCell:OnFlush()
	ChatCell.OnFlush(self)
	self.time:SetValue("")
end

--加载聊天框
function GuildMazeChatCell:LoadWindow(main_role_id)
	local asset = ""
	local prefab_name = ""
	local left = true
	local bubble_type = self.data.channel_window_bubble_type
	bubble_type = bubble_type or -1
	bubble_type = bubble_type + 1
	if bubble_type == -1 then bubble_type = 0 end
	if main_role_id == self.role_id then
		left = false
	end

	self.is_special_bubble = false
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SCENE then
		asset = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	elseif not bubble_type or bubble_type == 0 then
		asset = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	else  -- 特殊气泡框只加载容器
		asset = "uis/views/miscpreload_prefab"
		prefab_name = left and "BubbleSlotLeft" or "BubbleSlotRight"
		self.is_special_bubble = true
	end
	-- 公会迷宫特殊处理
	color = COLOR.WHITE
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.GUILD then
		if not bubble_type or bubble_type == 0 then
			asset = "uis/views/miscpreload_prefab"
			prefab_name = left and "GuildMazeContentLeft" or "GuildMazeContentRight"
		else
			asset = "uis/views/miscpreload_prefab"
			prefab_name = left and "GuildMazeBubbleSlotLeft" or "GuildMazeBubbleSlotRight"
		end
		color = TEXT_COLOR.GUILD_MAZE
	end

	if self.content_obj then
		GameObject.Destroy(self.content_obj.gameObject)
	end

	self.content_obj = GameObject.Instantiate(PreloadManager.Instance:GetPrefab(asset, prefab_name))
	local parent_obj = left and self.left_view or self.right_view
	self.content_obj.transform:SetParent(parent_obj.transform, false)
	local rich_text = self.content_obj:GetComponent(typeof(RichTextGroup))
	self:SetContent(rich_text, left, color)

	if self.is_easy then
		return
	end
	if self.is_special_bubble then
		asset = ResPath.GetBubblePrefab("", bubble_type)
		prefab_name = left and string.format("BubbleLeft%s", bubble_type) or string.format("BubbleRight%s", bubble_type)
		PrefabPool.Instance:Load(AssetID(asset, prefab_name), function(prefab)
			if nil == prefab then
				return
			end
			if not self.is_special_bubble then
				PrefabPool.Instance:Free(prefab)
				return
			end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			obj.transform:SetParent(self.content_obj.transform, false)
			obj.transform:SetSiblingIndex(0)
		end)
	end
end