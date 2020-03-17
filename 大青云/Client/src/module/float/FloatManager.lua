--[[
漂浮文字管理器
lizhuangzhuang
2014年7月31日20:32:41
]]

_G.FloatManager = {};

--是否正在显示全服公告
FloatManager.isShowAllServerAnn = false;
--是否正在显示公告
FloatManager.isShowAnn = false;
FloatManager.isShowGMAnn = false;
--全服公告列表
FloatManager.allServerAnnList = {};
--公告列表
FloatManager.annList = {};
--GM公告列表
FloatManager.gmAnnList = {};

--屏幕中间漂浮
function FloatManager:AddCenter(text)
	UIFloat:ShowCenter(text);
end

-- adder:houxudong date:2016/8/25 18:03:25
function FloatManager:AddCenterLunch(text)
	text = '经验+'..text
	UIFloat:ShowActivityLunch(text);
end

--普通的漂浮文字(按钮或鼠标)
function FloatManager:AddNormal(text,mc)
	local pos = nil;
	if not mc then
		pos = _sys:getRelativeMouse();
	else
		pos = UIManager:PosLtoG(mc,mc._width/2,0)
	end
	UIFloat:ShowNormal(text,pos.x,pos.y);
end

--显示技能类漂浮文字
function FloatManager:AddSkill(text)
	UIFloat:ShowSkillInfo(text);
end

--显示中下方活动内公告
function FloatManager:AddActivity(text)
	UIFloat:ShowActivity(text);
end

--------------------------------------客户端直接发SysNotice----------------------------------------
function FloatManager:AddSysNotice(id,param)
	local cfg = t_sysnotice[id];
	if not cfg then 
		FloatManager:AddCenter("错误的提示编号,"..id);
		return; 
	end
	if not param then param = ""; end
	if cfg.channel > 0 then
		ChatController:AddSysNotice(cfg.channel,id,param);
	end
	if cfg.float ~= 0 then
		local sysNoticeStr = NoticeUtil:GetSysNoticeStr(id,param);
		if sysNoticeStr and sysNoticeStr~="" then
			if cfg.float == 1 then
				self:AddCenter(sysNoticeStr);
			elseif cfg.float == 2 then
				self:AddNormal(sysNoticeStr);
			elseif cfg.float == 3 then
				self:AddSkill(sysNoticeStr);
			end
		end
	end
end
---------------------------------------玩家信息处理---------------------------------------------
--显示玩家信息类漂浮文字
function FloatManager:AddUserInfo(text)
	UIFloatBottom:ShowUserInfo(text);
	ChatController:AddUserInfo(text);
end

--玩家属性变化
function FloatManager:OnPlayerAttrChange(type,value,oldValue)
	value = toint(value,0.5);
	oldValue = toint(oldValue,0.5);
	if value == oldValue then return; end
	if type==enAttrType.eaBindGold or type==enAttrType.eaUnBindGold then
		if value > oldValue then
			self:AddUserInfo(string.format(StrConfig['float2'],getNumShow(value-oldValue)));
		else
			self:AddUserInfo(string.format(StrConfig['float4'],getNumShow(oldValue-value)));
		end
	elseif type == enAttrType.eaZhenQi then
		if value > oldValue then
			self:AddUserInfo(string.format(StrConfig['float3'],getNumShow(value-oldValue)));
		else
			self:AddUserInfo(string.format(StrConfig['float5'],getNumShow(oldValue-value)));
		end
	elseif type == enAttrType.eaExp then
		if value > oldValue then
			self:AddUserInfo(string.format(StrConfig['float1'],getNumShow(value-oldValue)));
		end
	elseif type == enAttrType.eaBindMoney then
		if value > oldValue then
			self:AddUserInfo(string.format(StrConfig['float9'],getNumShow(value-oldValue)));
		else
			self:AddUserInfo(string.format(StrConfig['float10'],getNumShow(oldValue-value)));
		end
	elseif type == enAttrType.eaUnBindMoney then
		if value > oldValue then
			self:AddUserInfo(string.format(StrConfig['float11'],getNumShow(value-oldValue)));
		else
			self:AddUserInfo(string.format(StrConfig['float12'],getNumShow(oldValue-value)));
		end
	-- elseif type == enAttrType.eaRealmExp then
	-- 	if value > oldValue then
	-- 		self:AddUserInfo(string.format(StrConfig['float13'],getNumShow(value-oldValue)));
	-- 	else
	-- 		self:AddUserInfo(string.format(StrConfig['float14'],getNumShow(oldValue-value)));
	-- 	end
	end
end

--物品获得失去提示
function FloatManager:OnPlayerItemAddReduce(type,itemId,num)
	local cfg = t_item[itemId] or t_equip[itemId];
	if not cfg then return; end
	local str = "";
	if type == 1 then
		local name = "<font color='"..TipsConsts:GetItemQualityColor(cfg.quality).."'>"..cfg.name.."</font>";
		str = string.format(StrConfig['float7'],name,num);
	else
		local name = "<font color='"..TipsConsts:GetItemQualityColor(cfg.quality).."'>"..cfg.name.."</font>";
		str = string.format(StrConfig['float8'],name,num);
	end
	self:AddUserInfo(str);
end

--消耗经验提示
function FloatManager:OnExpReduce(num)
	self:AddUserInfo(string.format(StrConfig['float6'],getNumShow(num)));
end

----------------------------------------公告处理---------------------------------------------------
--显示全服公告
function FloatManager:AddAllServerAnn(text)
	table.push(self.allServerAnnList,text);
	if self.isShowAllServerAnn then
		return;
	end
	self:ShowNextAllServerAnn();
end

--显示下一个全服公告
function FloatManager:ShowNextAllServerAnn()
	if #self.allServerAnnList <= 0 then 
		self.isShowAllServerAnn = false;
		return; 
	end
	local text = table.remove(self.allServerAnnList,1);
	UIFloat:AddAllServerAnnounce(text);
	self.isShowAllServerAnn = true;
end

--显示公告
function FloatManager:AddAnn(text)
	table.push(self.annList,text);
	if self.isShowAnn then
		return;
	end
	self:ShowNextAnn();
end

--显示GM公告
function FloatManager:AddGmAnn(text)
	table.push(self.gmAnnList,text);
	if self.isShowGMAnn then
		return;
	end
	self:ShowNextAnn();
end

--显示下一个公告
function FloatManager:ShowNextAnn()
	if #self.gmAnnList > 0 then
		local text = table.remove(self.gmAnnList,1);
		UIFloat:AddAnnounce(text);
		self.isShowGMAnn = true;
		self.isShowAnn = true;
		return;
	else
		self.isShowGMAnn = false;
	end
	if #self.annList <= 0 then
		self.isShowAnn = false;
		return;
	end
	local text = table.remove(self.annList,1);
	UIFloat:AddAnnounce(text);
	self.isShowAnn = true;
end

--清空所有的公告   --adder:houxudong  date:2016/10/24 17:12:25
function FloatManager:AddAnnounceForMakinoBattle(text)
	UIFloat:ShowDungeonText(text);
end