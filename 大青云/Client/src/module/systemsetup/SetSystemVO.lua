--[[
	2015年1月15日, PM 04:44:11
	wangyanwei 
]]

_G.SetSystemVO = {};

function SetSystemVO:new(obj)
	local _obj = setmetatable({},{__index = self})
	self.musicIsOpen 	= 	obj.musicIsOpen;  			 --开启音效
	self.musicBGIsOpen  = 	obj.musicBGIsOpen;			 --开启背景音效
	self.teamIsOpen		= 	obj.teamIsOpen;				 --开启组队
	self.dealIsOpen 	= 	obj.dealIsOpen;				 --开启交易
	self.friendIsOpen 	= 	obj.friendIsOpen;			 --开启好友
	self.unionIsOpen 	=	obj.unionIsOpen;			 --开启工会添加
	
	--------------显示设置-------------
	self.showPlayerNum	=   obj.showPlayerNum;           --显示设置
	self.isShowSkill	=	obj.isShowSkill;			 --是否屏蔽他人技能特效
	self.isOpenFlash	=	obj.isOpenFlash;			 --是否显示低血量闪屏特效
	self.isShowCommonMonster	=	obj.isShowCommonMonster; --是否屏蔽普通怪物造型
	self.roleAutoPointSet		=	obj.roleAutoPointSet; --是否自动加点
	self.isShowTitle		=	obj.isShowTitle; --是否显示他人称号
	self.teamInviteOpen         =obj.teamInviteOpen;      --是否接受组队邀请
	self.teamApplayOpen         =obj.teamApplayOpen;       --是否接受入队申请
	self.unAllPlayerShowName = obj.unAllPlayerShowName; --隐藏全部玩家 显示名称
	------新添显示四个选项----
	self.highDefinition =	obj.highDefinition;
	self.flowRight 		=	obj.flowRight;
	
	--画面配置--
	self.drawLevel = obj.drawLevel;
	
	--多倍视角
	self.doubleLooks = obj.doubleLooks;

	return _obj;
end

--获取画面等级
function SetSystemVO:GetDrawLevel()
	return self.drawLevel;
end

--获取音乐是否开启
function SetSystemVO:GetMusicIsOpen()
	return self.musicIsOpen;
end

--获取背景音乐是否开启
function SetSystemVO:GetBGMusicIsOpen()
	return self.musicBGIsOpen;
end

--是否开启了高清
function SetSystemVO:GetHighDefinition()
	return self.highDefinition;
end

--是否开启了泛光
function SetSystemVO:GetFlowRight()
	return self.flowRight;
end

--获取是否开启组队
function SetSystemVO:GetTeamIsOpen()
	return self.teamIsOpen;
end

--获取是否开启交易
function SetSystemVO:GetDealIsOpen()
	return self.dealIsOpen
end

--获取是否开启添加好友
function SetSystemVO:GetFriendIsOpen()
	return self.friendIsOpen
end

--获取是否开启添加帮派
function SetSystemVO:GetUnionIsOpen()
	return self.unionIsOpen
end

--获取是否隐藏全部 --否 val值  0 隐藏全部 1 十人 2 二十人 3 三十人 4 全部开启 5 只显示名字
function SetSystemVO:GetUnShowNum()
	return self.showPlayerNum
end

--获取是否屏蔽他人技能
function SetSystemVO:GetIsShowSkill()
	return self.isShowSkill
end

--获取是否关闭闪屏
function SetSystemVO:GetIsOpenFlash()
	return self.isOpenFlash
end

--获取是否屏蔽普通怪物
function SetSystemVO:GetIsShowCommonMonster()
	return self.isShowCommonMonster
end

--获取是否开启人物属性自动加点
function SetSystemVO:GetRoleAutoSet()
	return self.roleAutoPointSet
end
--获取是否接受组队邀请
function SetSystemVO:GetTeamInvite()
	return self.teamInviteOpen
end
--获取是否接受入队申请
function SetSystemVO:GetTeamApplay()
	return self.teamApplayOpen
end
--获取是否显示他人称号
function SetSystemVO:GerIsShowTitle()
	return self.isShowTitle;
end

--是否多倍视角
function SetSystemVO:GetIsDoubleLooks()
	return self.doubleLooks;
end

function SetSystemVO:GetUnAllPlayerShowName()
	return self.unAllPlayerShowName;
end