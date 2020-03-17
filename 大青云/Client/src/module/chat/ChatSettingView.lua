--[[
聊天设置面板
lizhuangzhuang
2014年9月22日11:48:29
]]
_G.classlist['UIChatSetting'] = 'UIChatSetting'
_G.UIChatSetting = BaseUI:new("UIChatSetting");
UIChatSetting.objName = 'UIChatSetting'
--公告,通知过滤
UIChatSetting.NoticeFilter = {
	["checkBox1"] = {key=1},
	["checkBox2"] = {key=2},
	["checkBox3"] = {key=3},
	["checkBox4"] = {key=4},
	["checkBox5"] = {key=5},
};
--频道过滤
UIChatSetting.ChannelFilter = {
	["checkBox6"] = {key=ChatConsts.Channel_Team},
	["checkBox7"] = {key=ChatConsts.Channel_Guild},
	["checkBox8"] = {key=ChatConsts.Channel_World},
	["checkBox9"] = {key=ChatConsts.Channel_Private},
}

function UIChatSetting:Create()
	self:AddSWF("chatSetting.swf",true,"center");
end

function UIChatSetting:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnSave.click = function() self:OnBtnSaveClick(); end
	
end

function UIChatSetting:OnShow()
	local objSwf = self:GetSWF("UIChatSetting");
	if not objSwf then return; end
	--notice
	local noticeSetting = ChatModel.chatSetting.notice;
	for btnName,vo in pairs(self.NoticeFilter) do
		if objSwf[btnName] then
			objSwf[btnName].selected = noticeSetting[vo.key];
		end
	end
	--channel
	local channelSetting = ChatModel.chatSetting.channel;
	for btnName,vo in pairs(self.ChannelFilter) do
		if objSwf[btnName] then
			objSwf[btnName].selected = channelSetting[vo.key];
		end
	end
end

--点击关闭
function UIChatSetting:OnBtnCloseClick()
	self:Hide();
end

--点击保存
function UIChatSetting:OnBtnSaveClick()
	local objSwf = self:GetSWF("UIChatSetting");
	if not objSwf then return; end
	--notice
	local noticeSetting = ChatModel.chatSetting.notice;
	for btnName,vo in pairs(self.NoticeFilter) do
		if objSwf[btnName] then
			noticeSetting[vo.key] = objSwf[btnName].selected;
		end
	end
	--channel
	local channelSetting = ChatModel.chatSetting.channel;
	for btnName,vo in pairs(self.ChannelFilter) do
		if objSwf[btnName] then
			channelSetting[vo.key] = objSwf[btnName].selected;
		end
	end
	self:Hide();
end