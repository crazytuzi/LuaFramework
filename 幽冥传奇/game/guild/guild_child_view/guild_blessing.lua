
GuildZhuFuPage = GuildZhuFuPage or BaseClass()

function GuildZhuFuPage:__init()
	self.view = nil
end	

function GuildZhuFuPage:__delete()
	--ClientCommonButtonDic[CommonButtonType.COMPOSE_XF_ACTIVATE_BTN] = nil
	self:RemoveEvent()
	self.view = nil
	
end	

--初始化页面接口
function GuildZhuFuPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	
	self:InitEvent()
end	

-- --初始化事件
function GuildZhuFuPage:InitEvent()
	self:InitZhuFuView()

end

-- --移除事件
function GuildZhuFuPage:RemoveEvent()
	self:DeleteZhuFuView()
end

function GuildZhuFuPage:UpdateData(data)
	self:OnFlushZhuFuView()
end

function GuildZhuFuPage:InitZhuFuView()
	XUI.AddClickEventListener(self.view.node_t_list.btn_up_lessing.node, BindTool.Bind1(self.OnUpLv, self))
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_info.node, Language.Guild.ZhuFuInfo, 22, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.view.node_t_list.txt_info.node)
end

function GuildZhuFuPage:DeleteZhuFuView()
	
end

function GuildZhuFuPage:OnFlushZhuFuView()
	local guild_info = GuildData.Instance:GetGuildInfo()
	local bless_level  = guild_info.zhufu_level
	self.view.node_t_list.txt_had_gongxian.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_CON))
	local comsume = GuildConfig.guildBless[bless_level+1]
	--local guild_comsume = GuildData.Instance:GetUpgradeConsume(guild_info.cur_guild_level + 1)
	local color = COLOR3B.GREEN
	local txt = ""
	local txt_3 = ""
	local txt_4 = string.format(Language.Guild.ZhuFuLevel, bless_level)
	local txt_5 = string.format(Language.Guild.GuildLevel, guild_info.cur_guild_level)
	local txt_6 = ""
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_cur_levl.node, txt_4, 22, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.view.node_t_list.txt_cur_levl.node)
	-- if guild_comsume ~= nil then
	-- 	txt_6 = string.format(Language.Guild.GuildLevel, guild_info.cur_guild_level + 1)
	-- else
	-- 	txt_6 = ""
	-- end

	if comsume == nil then
		txt = Language.Guild.ConSumeBless
		txt_3 = ""
		color = COLOR3B.GREEN
	else
		txt = comsume.needGx
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_CON) >= comsume.needGx then
			color = COLOR3B.GREEN
		else
			color = COLOR3B.RED
		end
		txt_3 = string.format(Language.Guild.ZhuFuLevel, bless_level + 1)
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_next_levl.node, txt_3, 22,COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.view.node_t_list.txt_next_levl.node)
	self.view.node_t_list.txt_consume_gongxian.node:setString(txt)
	self.view.node_t_list.txt_had_gongxian.node:setColor(color)
	local cur_attr = GuildData.Instance:GetGuildZhuFuCfg(bless_level)
	local txt_1 = ""
	if cur_attr == nil then
		txt_1 = Language.Guild.Nothing
	else
		txt_1 = RoleData.FormatAttrContent(cur_attr) 
	end
	local txt_2 = ""
	local next_attr = GuildData.Instance:GetGuildZhuFuCfg(bless_level+1)
	if next_attr == nil then
		txt_2 = Language.Guild.ConSumeBless
	else
		txt_2 = RoleData.FormatAttrContent(next_attr)
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_txt.node, txt_1, 22, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_txt.node, txt_2, 22, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_lev.node, txt_5, 22, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.view.node_t_list.txt_lev.node)
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_next_lev.node, txt_5, 22, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.view.node_t_list.txt_next_lev.node)
end

function GuildZhuFuPage:OnUpLv()
	GuildCtrl.ReqGuildBlessing()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end